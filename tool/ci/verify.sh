#!/usr/bin/env bash
set -euo pipefail
mkdir -p verification
python3 tool/ci/check_approved_opening.py
flutter --version
flutter doctor -v
flutter pub get
dart format lib test tool
mkdir -p verification/settings-source/lib verification/settings-source/test
cp lib/settings_ui.dart lib/feature_panels.dart lib/ui_strings.dart verification/settings-source/lib/
cp test/settings_premium_test.dart test/redesign_test.dart verification/settings-source/test/
dart format --output=none --set-exit-if-changed lib test tool
dart tool/content_check.dart
mkdir -p verification/content
cp docs/CONTENT_VERIFICATION_2026-10-14.md docs/reference-comparison.csv docs/reference-screen-map.json docs/content-audit.json docs/quran-source.json verification/content/
dart tool/export_catalog.dart > verification/content/runtime-catalog.json
flutter test tool/brand_assets_test.dart --reporter expanded
python3 tool/ci/check_approved_opening.py --restore-assets
python3 tool/static_check.py
flutter analyze
WIRD_REVIEW_IMAGES=1 flutter test --reporter expanded
case "${1:-debug}" in
  debug) flutter build apk --debug ;;
  ios) flutter build ios --release --no-codesign ;;
  validate) ;;
  *) echo 'Usage: verify.sh debug|ios|validate' >&2; exit 1;;
esac

