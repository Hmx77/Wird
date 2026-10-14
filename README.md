# Wird — ورد

Arabic-first, private, offline Flutter application for Android and iOS, expanded from the supplied starter.

**Premium redesign is under review on `redesign/premium-20261013`, in draft PR #1.** Run #28 passed dependency resolution, analysis, all 22 tests, asset generation and Android debug packaging. Run #29 passed the same iOS checks, unsigned device compilation and actual iOS 26 simulator installation/launch with Xcode 26.3. Android offline runtime revalidation is recorded separately in `docs/BUILD_STATUS_2026-10-14.md`. The repository remains private; no merge or store publication has occurred.

The redesign adds the approved original-artwork crop and separate kasra layer, a warm botanical opening, darker home cards, four navigation tabs with an owned sujood icon, Arabic names for all ten themes, licensed offline Arabic fonts and visual/native smoke checks. Existing content and preference keys are preserved. The hidden calendar/activity interface retains its stored data. See `docs/REDESIGN_TRACEABILITY.md` for requirement mapping and acceptance gates.

## Implemented source

- Exact uploaded logo preserved byte-for-byte in-app, with mechanically resized launcher copies and native splash screens. Original source PNG is unchanged; the review UI clips excess canvas and draws the separately approved kasra in code.
- All ten starter palettes, default **Stone & Teal**: Olive & Cream, Ocean Blue, Mocha & Sand, Soft Lavender, Emerald & Gold, Midnight Blue, Charcoal & Sage, Dusty Rose & Stone, Stone & Teal, Sage & Ivory.
- Arabic-first interface with saved Arabic/English UI selection, RTL religious text, scalable text, focus mode, and source/benefit/meaning panels. Religious text remains in Arabic; English religious translations await review.
- **19 source-checked entries:** six morning, five evening, eight bedtime. Curated collection, not every possible authentic dhikr.
- Persistent repetition counters, undo, long-press reset, optional haptics and auto-advance; separate local-date progress with midnight refresh.
- Favorites, Arabic search ignoring diacritics, tatweel and common alef forms.
- Referenced Sunnah/Nawafil guidance and optional prayer tracking.
- Stored activity history remains preserved; the redesign hides the calendar/activity dashboard and its navigation tab.
- Three opt-in daily local reminders, selected clock times, permissions, notification reader routing, Android reboot restoration and timezone refresh on resume. Inexact delivery can be delayed by battery restrictions.
- Full-text Arabic PNG share cards with reference, timing and count context; OS share sheet and iPad anchor.
- Local audio playback, pause, replay and seek implementation with rights-evidence and Arabic-review gates. **Zero recordings supplied.** Unavailable state is honest; no unlicensed or synthetic substitute. No background audio service claimed.
- Native Android RemoteViews widget and iOS WidgetKit extension integrated into projects. Show local progress, discard prior-day counts, open the app. iOS App Group provisioning required.
- Local-data deletion, software licenses and privacy information. No accounts, backend, ads or analytics.

## Run and verify

**Windows:** follow [the setup and build guide](docs/WINDOWS_BUILD.md), then run `./tool/build-windows.ps1 -Mode Debug` in PowerShell. It stops on validation, analysis, test or build failure. See [the startup security record](docs/STARTUP_SECURITY.md) for the blocked command and isolation result.

Baseline: Flutter 3.35.7 / Dart 3.9, Java 17, Android compile SDK 36 (target 36), minSdk 23, iOS 14+, Xcode on macOS, CocoaPods. Direct dependency versions are pinned. **pubspec.lock was not fabricated**; retain the real generated lockfile after resolving on a permitted build host.

Native project files are included. Do not overwrite them with `flutter create .`.

```sh
flutter pub get
dart tool/content_check.dart
flutter test tool/brand_assets_test.dart
python3 tool/static_check.py
flutter analyze
flutter test
flutter run
```

The data check runs with standalone Dart. Static Python checks need only the standard library. These do not prove Flutter/plugin compilation or scholarly authenticity.

## Release preparation

```sh
bash tool/release.sh android
# macOS with signing configured:
bash tool/release.sh ios
```

Android: copy `android/key.properties.example` to `android/key.properties` and configure your upload keystore. Release signing never uses the debug key automatically.

iOS: open `ios/Runner.xcworkspace`; select your Apple team for Runner and WirdWidget and register the matching App Group. Provisional identifiers: `ae.wird.app`, `ae.wird.app.WirdWidget`, `group.ae.wird.app`. Confirm ownership and change all related references together if necessary.

`.github/workflows/verify.yml` supplies Android debug checks and optional manually triggered unsigned iOS checks. `.github/workflows/release-android.yml` prepares signed Android artifacts only when existing signing secrets are supplied. It **has not run** and does not publish to stores. Check current store SDK requirements before submission.

## Review and limitations

See `docs/RELEASE_READINESS.md`, `docs/CONTENT_REVIEW.md`, `docs/AUDIO_PERMISSIONS.md`, and `docs/PRIVACY.md`.

The original 25 morning-reference images remain unavailable. Prior-context retrieval found descriptions but no exact source inventory. No unseen entries were invented. The existing 19-entry catalog remains pending qualified independent Arabic/religious proofreading before public release. See `docs/REDESIGN_TRACEABILITY.md` and `docs/redesign-content-manifest.csv`.
