#!/usr/bin/env bash
set -euo pipefail
mkdir -p verification/device
sdkmanager="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
avdmanager="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
# Existing runner licenses only. No --licenses, automatic acceptance or account.
"$sdkmanager" --install 'system-images;android-36;google_apis;x86_64' </dev/null
printf 'no\n' | "$avdmanager" create avd --name wird-review --package 'system-images;android-36;google_apis;x86_64' --device pixel_7 --force
accel=off
if [ -e /dev/kvm ]; then
  # Narrow ephemeral runner-user access, never a world-writable device rule.
  sudo setfacl -m "u:$(id -un):rw" /dev/kvm
  accel=on
fi
"$ANDROID_HOME/emulator/emulator" -avd wird-review -no-window -no-audio -no-boot-anim -no-snapshot -gpu swiftshader_indirect -accel "$accel" >verification/device/emulator.log 2>&1 &
export PATH="$ANDROID_HOME/platform-tools:$PATH"
timeout 600 bash -c 'until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d "\r")" = 1 ]; do sleep 5; done'
adb shell input keyevent 82
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell svc wifi disable
adb shell svc data disable
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
if rg -q 'FATAL EXCEPTION|Unhandled Exception' verification/device/runtime-errors.log; then
  echo 'Native runtime error captured.' >&2; exit 1
fi
adb shell dumpsys package ae.wird.app > verification/device/package.txt
adb emu kill
printf '%s\n' 'PASS: Android 36 emulator offline startup, large-font/small/tablet captures; no fatal runtime errors.'
