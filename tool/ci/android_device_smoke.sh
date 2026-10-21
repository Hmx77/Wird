#!/usr/bin/env bash
set -euo pipefail
mkdir -p verification/device
wird_sdk_user_root="${RUNNER_TEMP:?}/wird-emulator"
export ANDROID_SDK_HOME="$wird_sdk_user_root"
export ANDROID_USER_HOME="$wird_sdk_user_root/.android"
export ANDROID_EMULATOR_HOME="$ANDROID_USER_HOME"
export ANDROID_AVD_HOME="$ANDROID_USER_HOME/avd"
mkdir -p "$ANDROID_AVD_HOME"
sdkmanager="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
avdmanager="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
# Existing runner licenses only. No --licenses, automatic acceptance or account.
"$sdkmanager" --install 'system-images;android-36;google_apis;x86_64' </dev/null
printf 'no\n' | "$avdmanager" create avd --name wird-review --package 'system-images;android-36;google_apis;x86_64' --device pixel_7 --force --path "$ANDROID_AVD_HOME/wird-review.avd"
test -s "$ANDROID_AVD_HOME/wird-review.avd/config.ini"
if [ ! -s "$ANDROID_AVD_HOME/wird-review.ini" ]; then
  printf 'avd.ini.encoding=UTF-8\npath=%s\ntarget=android-36\n' "$ANDROID_AVD_HOME/wird-review.avd" > "$ANDROID_AVD_HOME/wird-review.ini"
fi
test -s "$ANDROID_AVD_HOME/wird-review.ini"
"$ANDROID_HOME/emulator/emulator" -list-avds | tee verification/device/avds.txt
grep -qx 'wird-review' verification/device/avds.txt
accel=off
if [ -e /dev/kvm ]; then
  # Narrow ephemeral runner-user access, never a world-writable device rule.
  sudo setfacl -m "u:$(id -un):rw" /dev/kvm
  accel=on
fi
"$ANDROID_HOME/emulator/emulator" -avd wird-review -no-window -no-audio -no-boot-anim -no-snapshot -gpu swiftshader_indirect -memory 3072 -cores 2 -accel "$accel" >verification/device/emulator.log 2>&1 &
wird_emulator_pid=$!
wird_cleanup() {
  # Preserve diagnostics already collected before an intentional emulator shutdown.
  if [ "$(timeout 5 "$ANDROID_HOME/platform-tools/adb" get-state 2>/dev/null || true)" != device ]; then
    kill "$wird_emulator_pid" 2>/dev/null || true
    return
  fi
  timeout 12 "$ANDROID_HOME/platform-tools/adb" logcat -d -s AndroidRuntime:E flutter:I | sed -E 's~https?://[^[:space:]]+~[redacted-url]~g' > verification/device/runtime-diagnostics.log 2>/dev/null || true
  timeout 12 "$ANDROID_HOME/platform-tools/adb" shell dumpsys package ae.wird.app > verification/device/package-diagnostics.txt 2>/dev/null || true
  timeout 12 "$ANDROID_HOME/platform-tools/adb" shell getprop persist.sys.timezone > verification/device/timezone.txt 2>/dev/null || true
  timeout 12 "$ANDROID_HOME/platform-tools/adb" shell appops get ae.wird.app POST_NOTIFICATION > verification/device/notification-permission.txt 2>/dev/null || true
  kill "$wird_emulator_pid" 2>/dev/null || true
}
trap wird_cleanup EXIT
export PATH="$ANDROID_HOME/platform-tools:$PATH"
wird_boot_deadline=$((SECONDS + 600))
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; do
  if ! kill -0 "$wird_emulator_pid" 2>/dev/null || [ "$SECONDS" -ge "$wird_boot_deadline" ]; then
    python3 - <<'PYLOG'
import pathlib,re
for line in pathlib.Path('verification/device/emulator.log').read_text(errors='replace').splitlines()[-100:]:
    if not re.search(r'(?i)(token|password|secret|authorization|jwt)',line):
        print(line)
PYLOG
    echo 'Emulator exited or did not boot before its deadline.' >&2
    exit 1
  fi
  sleep 5
done
# Keep only this disposable test emulator awake throughout package setup.
adb shell settings put system screen_off_timeout 1800000
adb shell svc power stayon true
adb shell input keyevent KEYCODE_WAKEUP
adb shell input keyevent 82
wird_package_deadline=$((SECONDS + 120))
until timeout 10 adb shell cmd package list packages >/dev/null 2>&1; do
  if [ "$SECONDS" -ge "$wird_package_deadline" ]; then
    echo 'Android package service did not become ready.' >&2; exit 1
  fi
  sleep 5
done
sleep 5
if ! adb install --no-streaming -r build/app/outputs/flutter-apk/app-debug.apk; then
  adb shell df -h /data || true
  adb logcat -d -s AndroidRuntime:E PackageManager:E > verification/device/install-errors.log
  exit 1
fi
adb shell cmd connectivity airplane-mode enable
adb shell svc wifi disable
adb shell settings put global mobile_data 0
wird_network_deadline=$((SECONDS + 60))
until [ "$(adb shell settings get global airplane_mode_on | tr -d '\r')" = 1 ] && [ "$(adb shell settings get global wifi_on | tr -d '\r')" = 0 ]; do
  if [ "$SECONDS" -ge "$wird_network_deadline" ]; then
    echo 'Offline radio settings were not confirmed.' >&2; exit 1
  fi
  sleep 2
done
{ adb shell settings get global airplane_mode_on; adb shell settings get global wifi_on; adb shell settings get global mobile_data; } > verification/device/offline-radio-settings.txt
wird_wait_for_home() {
  wird_view_stage="$1"
  wird_view_deadline=$((SECONDS + 90))
  while [ "$SECONDS" -lt "$wird_view_deadline" ]; do
    if timeout 15 adb shell uiautomator dump "/sdcard/wird-$wird_view_stage.xml" >/dev/null 2>&1 &&
       adb pull "/sdcard/wird-$wird_view_stage.xml" "verification/device/$wird_view_stage.xml" >/dev/null 2>&1 &&
       python3 - "verification/device/$wird_view_stage.xml" <<'PYVIEW'
import sys, xml.etree.ElementTree as ET
nodes=list(ET.parse(sys.argv[1]).getroot().iter('node'))
labels=' '.join(n.get('text','')+' '+n.get('content-desc','') for n in nodes)
assert any(n.get('package') == 'ae.wird.app' for n in nodes), 'Wird is not the foreground app'
assert 'الصباح' in labels or 'Morning' in labels, 'Wird home content is not ready'
PYVIEW
    then
      echo "PASS: interactive Wird home visible for $wird_view_stage"
      return 0
    fi
    sleep 3
  done
  echo "Wird home did not become visible for $wird_view_stage." >&2
  return 1
}
# Validate every capture; adb can return success with an empty PNG during boot.
wird_capture() {
  local target="$1"
  local attempt
  for attempt in 1 2 3 4 5; do
    if timeout 20 adb exec-out screencap -p > "$target" &&
       python3 - "$target" <<'PYPNG'
import pathlib, struct, sys, zlib
raw = pathlib.Path(sys.argv[1]).read_bytes()
assert raw[:8] == bytes([137,80,78,71,13,10,26,10]), 'Missing PNG signature'
pos = 8
seen = set()
while pos < len(raw):
    length = struct.unpack('>I', raw[pos:pos+4])[0]
    kind = raw[pos+4:pos+8]
    payload = raw[pos+8:pos+8+length]
    crc = raw[pos+8+length:pos+12+length]
    assert len(crc) == 4 and zlib.crc32(kind + payload) == struct.unpack('>I', crc)[0], 'Truncated PNG'
    seen.add(kind)
    if kind == b'IHDR':
        width, height = struct.unpack('>II', payload[:8])
        assert width > 0 and height > 0
    pos += length + 12
assert {b'IHDR', b'IDAT', b'IEND'} <= seen and pos == len(raw), 'Incomplete PNG'
PYPNG
    then
      echo "PASS: valid screenshot $target"
      return 0
    fi
    sleep 2
  done
  echo "No valid screenshot for $target" >&2
  return 1
}
if ! command -v ffmpeg >/dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends ffmpeg
fi
command -v ffmpeg >/dev/null
# Observe launcher coordinates after tool installation, never before a long install.
# Wait for the installed app label in the launcher drawer, not just wallpaper.
wird_launcher_ready=false
for attempt in 1 2 3 4 5; do
  adb shell input keyevent KEYCODE_HOME
  sleep 2
  adb shell input swipe 540 2200 540 500 600
  sleep 2
  if timeout 15 adb shell uiautomator dump /sdcard/wird-launcher.xml >/dev/null 2>&1 &&
     adb pull /sdcard/wird-launcher.xml verification/device/launcher.xml >/dev/null 2>&1 &&
     python3 - <<'PYLAUNCHER'
import unicodedata, xml.etree.ElementTree as ET
nodes = list(ET.parse('verification/device/launcher.xml').getroot().iter('node'))
labels = ' '.join(n.get('text', '') + ' ' + n.get('content-desc', '') for n in nodes)
labels = ''.join(c for c in unicodedata.normalize('NFD', labels) if unicodedata.category(c) != 'Mn')
assert any('launcher' in n.get('package', '').lower() for n in nodes), 'Launcher not foreground'
assert 'wird' in labels.lower() or 'ورد' in labels, 'Installed Wird icon not visible'
PYLAUNCHER
  then
    wird_launcher_ready=true
    break
  fi
done
if [ "$wird_launcher_ready" != true ]; then
  echo 'Installed Wird launcher icon was not found.' >&2
  exit 1
fi
echo 'PASS: installed Wird icon visible in launcher drawer'
wird_capture verification/device/android-launcher.png
# Record the actual launcher tap and first cold launch through real home.
# Preserve the whole bounded cold launch on a slow hosted emulator. Stop only
# after actual interactive Home has been observed, with the frame guard intact.
adb shell screenrecord --time-limit 100 /sdcard/wird-startup.mp4 &
record_pid=$!
sleep 1
read -r wird_tap_x wird_tap_y < <(python3 - <<'PYTAP'
import re, unicodedata, xml.etree.ElementTree as ET
for node in ET.parse('verification/device/launcher.xml').getroot().iter('node'):
    label = node.get('text', '') + ' ' + node.get('content-desc', '')
    label = ''.join(c for c in unicodedata.normalize('NFD', label) if unicodedata.category(c) != 'Mn')
    if 'wird' in label.lower() or 'ورد' in label:
        x1,y1,x2,y2 = map(int, re.findall(r'\d+', node.attrib['bounds']))
        print((x1+x2)//2, (y1+y2)//2)
        break
else:
    raise SystemExit('No visible launcher target')
PYTAP
)
adb shell settings put system show_touches 1
adb shell input tap "$wird_tap_x" "$wird_tap_y"
if ! wird_wait_for_home window; then
  wird_capture verification/device/android-startup-failure.png || true
  adb shell dumpsys window > verification/device/startup-window-state.txt || true
  adb shell dumpsys activity activities > verification/device/startup-activities.txt || true
  adb logcat -d -s AndroidRuntime:E flutter:E > verification/device/startup-runtime-errors.log || true
  adb shell pkill -2 screenrecord || true
  wait "$record_pid" || true
  adb pull /sdcard/wird-startup.mp4 verification/device/startup.mp4 || true
  echo 'Cold launcher activation failed; actual screen, movie and runtime diagnostics preserved.' >&2
  exit 1
fi
wird_capture verification/device/android-home-offline.png
sleep 2
adb shell pkill -2 screenrecord || true
wait "$record_pid" || true
adb pull /sdcard/wird-startup.mp4 verification/device/startup.mp4
test -s verification/device/startup.mp4
ffmpeg -hide_banner -loglevel error -i verification/device/startup.mp4 \
  -vf fps=2 verification/device/android-startup-%02d.png
ffmpeg -hide_banner -loglevel error -i verification/device/startup.mp4 \
  -vf fps=10,scale=32:72,format=rgb24 -f rawvideo verification/device/startup-rgb.raw
ffmpeg -hide_banner -loglevel error -i android/app/src/main/res/drawable-nodpi/wird_launch_scene.png \
  -vf scale=32:72,format=rgb24 -frames:v 1 -f rawvideo verification/device/startup-reference.raw
ffmpeg -hide_banner -loglevel error -i verification/device/android-home-offline.png \
  -vf scale=32:72,format=rgb24 -frames:v 1 -f rawvideo verification/device/startup-home-reference.raw
# Keep the opening guard strict, but do not discard independent feature checks
# merely because a transient Home artwork-loading frame fails classification.
wird_startup_guard=0
python3 tool/ci/check_startup_frames.py || wird_startup_guard=$?
printf '%s\n' "$wird_startup_guard" > verification/device/startup-guard-exit-code.txt
if [ "$wird_startup_guard" -eq 0 ]; then
  printf '%s\n' 'PASS: first cold launch recorded from actual launcher tap; no interaction after entry'
else
  echo 'Startup frame guard failed; preserving failure while continuing independent feature checks.' >&2
fi
# Returning launcher activation must reuse the existing Flutter activity.
adb shell input keyevent KEYCODE_HOME
adb shell monkey -p ae.wird.app -c android.intent.category.LAUNCHER 1 >/dev/null
wird_wait_for_home warm-launch
wird_capture verification/device/android-warm-home.png
adb shell dumpsys activity activities > verification/device/warm-activities.txt
python3 - <<'PYWARM'
import pathlib, re
text = pathlib.Path('verification/device/warm-activities.txt').read_text()
instances = re.findall(r'Hist\s+#\d+:\s+ActivityRecord\{[^\n]*ae\.wird\.app/(?:ae\.wird\.app)?\.MainActivity', text)
assert len(instances) == 1, f'Expected one reusable Flutter activity, found {len(instances)}'
print('PASS: returning launcher activation reuses one Flutter activity')
PYWARM
if [[ "${WIRD_READER_ONLY:-false}" == "true" ]]; then
  printf '%s\n' 'Focused Reader recheck: prior Home/Settings results are reported separately.' | tee verification/device/recheck-scope.txt
else
  python3 tool/ci/premium_home_smoke.py
fi
python3 tool/ci/reader_device_smoke.py
python3 tool/ci/tasbih_device_smoke.py
python3 tool/ci/appearance_device_smoke.py
adb shell wm size 720x1280
adb shell wm density 320
adb shell settings put system font_scale 1.5
adb shell am force-stop ae.wird.app
adb shell am start -W -n ae.wird.app/.MainActivity
wird_wait_for_home small-large-font
wird_capture verification/device/android-small-large-font.png
adb shell wm size 1600x2560
adb shell wm density 240
adb shell settings put system font_scale 1
adb shell am force-stop ae.wird.app
adb shell am start -W -n ae.wird.app/.MainActivity
wird_wait_for_home tablet
wird_capture verification/device/android-tablet.png
adb logcat -d -s AndroidRuntime:E flutter:E > verification/device/runtime-errors.log
if grep -Eq 'FATAL EXCEPTION|Unhandled Exception' verification/device/runtime-errors.log; then
  echo 'Native runtime error captured.' >&2; exit 1
fi
adb shell dumpsys package ae.wird.app > verification/device/package.txt
adb shell getprop persist.sys.timezone > verification/device/timezone.txt
adb shell appops get ae.wird.app POST_NOTIFICATION > verification/device/notification-permission.txt
adb logcat -d -s AndroidRuntime:E flutter:I | sed -E 's~https?://[^[:space:]]+~[redacted-url]~g' > verification/device/runtime-diagnostics.log
adb emu kill
printf '%s\n' 'PASS: Android 36 emulator offline feature checks, large-font/small/tablet captures; no fatal runtime errors.'
# An opening guard failure remains a real nonzero job result, never a green pass.
exit "$wird_startup_guard"


