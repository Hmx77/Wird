#!/usr/bin/env bash
set -euo pipefail
mkdir -p verification/ios-device
xcrun simctl list devices available --json > verification/ios-device/available-devices.json
wird_sim_id=$(python3 - <<'PY'
import json
from pathlib import Path
j=json.loads(Path('verification/ios-device/available-devices.json').read_text())
for runtime, devices in j['devices'].items():
    if 'iOS-26' in runtime:
        for device in devices:
            if device.get('isAvailable') and device['name'].startswith('iPhone'):
                print(device['udid']);raise SystemExit(0)
raise SystemExit('No preinstalled iOS 26 iPhone simulator is available; no runtime license acceptance attempted.')
PY
)
xcrun simctl boot "$wird_sim_id"
xcrun simctl bootstatus "$wird_sim_id" -b
trap 'xcrun simctl shutdown "$wird_sim_id" || true' EXIT
xcrun simctl install "$wird_sim_id" build/ios/iphonesimulator/Runner.app
xcrun simctl launch --terminate-running-process "$wird_sim_id" ae.wird.app
sleep 5
xcrun simctl io "$wird_sim_id" screenshot verification/ios-device/ios-home.png
xcrun simctl spawn "$wird_sim_id" log show --last 1m --style compact --predicate 'process == "Runner" AND messageType == error' > verification/ios-device/runtime-errors.log
if rg -q 'Unhandled Exception|Fatal error|EXC_BAD_ACCESS' verification/ios-device/runtime-errors.log; then
  echo 'iOS runtime error captured.' >&2; exit 1
fi
printf '%s\n' 'PASS: iOS 26 simulator installation, native launch and actual home-screen capture.'
