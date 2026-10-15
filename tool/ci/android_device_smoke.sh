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
trap 'kill "$wird_emulator_pid" 2>/dev/null || true' EXIT
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
adb shell input keyevent KEYCODE_HOME
adb shell input swipe 540 1900 540 350 600
sleep 2
adb exec-out screencap -p > verification/device/android-launcher.png
adb shell am start -W -n ae.wird.app/.MainActivity
wird_wait_for_home window
adb exec-out screencap -p > verification/device/android-home-offline.png
adb shell am force-stop ae.wird.app
adb shell screenrecord --time-limit 30 /sdcard/wird-startup.mp4 &
record_pid=$!
sleep 1
adb shell am start -W -n ae.wird.app/.MainActivity
wait "$record_pid"
adb pull /sdcard/wird-startup.mp4 verification/device/startup.mp4
if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -hide_banner -loglevel error -i verification/device/startup.mp4 \
    -vf fps=1/4 verification/device/android-startup-%02d.png
fi
adb shell wm size 720x1280
adb shell wm density 320
adb shell settings put system font_scale 1.5
adb shell am force-stop ae.wird.app
adb shell am start -W -n ae.wird.app/.MainActivity
wird_wait_for_home small-large-font
adb exec-out screencap -p > verification/device/android-small-large-font.png
adb shell wm size 1600x2560
adb shell wm density 240
adb shell settings put system font_scale 1
adb shell am force-stop ae.wird.app
adb shell am start -W -n ae.wird.app/.MainActivity
wird_wait_for_home tablet
adb exec-out screencap -p > verification/device/android-tablet.png
adb logcat -d -s AndroidRuntime:E flutter:E > verification/device/runtime-errors.log
if grep -Eq 'FATAL EXCEPTION|Unhandled Exception' verification/device/runtime-errors.log; then
  echo 'Native runtime error captured.' >&2; exit 1
fi
adb shell dumpsys package ae.wird.app > verification/device/package.txt
adb emu kill
printf '%s\n' 'PASS: Android 36 emulator offline startup, large-font/small/tablet captures; no fatal runtime errors.'
