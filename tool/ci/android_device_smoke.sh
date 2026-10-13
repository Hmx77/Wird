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
adb shell svc wifi disable
adb shell svc data disable
adb shell input keyevent KEYCODE_HOME
adb shell input swipe 540 1900 540 350 600
sleep 2
adb exec-out screencap -p > verification/device/android-launcher.png
adb shell am start -W -n ae.wird.app/.MainActivity
sleep 4
adb exec-out screencap -p > verification/device/android-home-offline.png
adb shell uiautomator dump /sdcard/wird-review.xml
adb pull /sdcard/wird-review.xml verification/device/window.xml
adb shell am force-stop ae.wird.app
adb shell screenrecord --time-limit 8 /sdcard/wird-startup.mp4 &
record_pid=$!
sleep 1
adb shell am start -W -n ae.wird.app/.MainActivity
wait "$record_pid"
adb pull /sdcard/wird-startup.mp4 verification/device/startup.mp4
adb shell wm size 720x1280
adb shell wm density 320
adb shell settings put system font_scale 1.5
adb shell am force-stop ae.wird.app
adb shell am start -W -n ae.wird.app/.MainActivity
sleep 3
adb exec-out screencap -p > verification/device/android-small-large-font.png
adb shell wm size 1600x2560
adb shell wm density 240
adb shell settings put system font_scale 1
adb shell am force-stop ae.wird.app
adb shell am start -W -n ae.wird.app/.MainActivity
sleep 3
adb exec-out screencap -p > verification/device/android-tablet.png
adb logcat -d -s AndroidRuntime:E flutter:E > verification/device/runtime-errors.log
if grep -Eq 'FATAL EXCEPTION|Unhandled Exception' verification/device/runtime-errors.log; then
  echo 'Native runtime error captured.' >&2; exit 1
fi
adb shell dumpsys package ae.wird.app > verification/device/package.txt
adb emu kill
printf '%s\n' 'PASS: Android 36 emulator offline startup, large-font/small/tablet captures; no fatal runtime errors.'
