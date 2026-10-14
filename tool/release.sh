#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
dart tool/content_check.dart
flutter test tool/brand_assets_test.dart
python3 tool/static_check.py
flutter analyze
flutter test
case "${1:-}" in
  android)
    if [ ! -f android/key.properties ]; then
      echo "Configure android/key.properties with your upload keystore; release will not use a debug key." >&2
      exit 1
    fi
    flutter build appbundle --release
    ;;
  ios)
    if [ "$(uname -s)" != Darwin ]; then echo "iOS requires macOS and Xcode." >&2; exit 1; fi
    flutter build ipa --release
    ;;
  *) echo "Usage: bash tool/release.sh android|ios" >&2; exit 1 ;;
esac
