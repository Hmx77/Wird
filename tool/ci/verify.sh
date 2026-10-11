#!/usr/bin/env bash
set -euo pipefail
mkdir -p verification
flutter --version
flutter doctor -v
flutter pub get
dart format lib test tool
dart format --output=none --set-exit-if-changed lib test tool
dart tool/content_check.dart
python3 tool/static_check.py
flutter analyze
flutter test --reporter expanded
case "${1:-debug}" in
  debug) flutter build apk --debug ;;
  ios) flutter build ios --release --no-codesign ;;
  validate) ;;
  *) echo 'Usage: verify.sh debug|ios|validate' >&2; exit 1;;
esac
