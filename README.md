# Wird — ورد

Arabic-first, private, offline Flutter application for Android and iOS, expanded from the supplied starter.

**Status: development implementation, not a tested store release.** See [the current evidence and blockers](docs/BUILD_STATUS_2026-10-10.md) and [GitHub automation](docs/GITHUB_ACTIONS.md). Dart parsing/formatting, the executable content check and native structural checks passed. Full Flutter dependency resolution, analysis/tests, device QA and release compilation were blocked. No APK, AAB or IPA is included or claimed.

## Implemented source

- Exact uploaded logo preserved byte-for-byte in-app, with mechanically resized launcher copies and native splash screens. No redesign, recoloring or cropping.
- All ten starter palettes, default **Stone & Teal**: Olive & Cream, Ocean Blue, Mocha & Sand, Soft Lavender, Emerald & Gold, Midnight Blue, Charcoal & Sage, Dusty Rose & Stone, Stone & Teal, Sage & Ivory.
- Arabic-first interface with saved Arabic/English UI selection, RTL religious text, scalable text, focus mode, and source/benefit/meaning panels. Religious text remains in Arabic; English religious translations await review.
- **19 source-checked entries:** six morning, five evening, eight bedtime. Curated collection, not every possible authentic dhikr.
- Persistent repetition counters, undo, long-press reset, optional haptics and auto-advance; separate local-date progress with midnight refresh.
- Favorites, Arabic search ignoring diacritics, tatweel and common alef forms.
- Referenced Sunnah/Nawafil guidance and optional prayer tracking.
- Seven-day history and monthly activity grid; no invented religious streak rewards.
- Three opt-in daily local reminders, selected clock times, permissions, notification reader routing, Android reboot restoration and timezone refresh on resume. Inexact delivery can be delayed by battery restrictions.
- Full-text Arabic PNG share cards with reference, timing and count context; OS share sheet and iPad anchor.
- Local audio playback, pause, replay and seek implementation with rights-evidence and Arabic-review gates. **Zero recordings supplied.** Unavailable state is honest; no unlicensed or synthetic substitute. No background audio service claimed.
- Native Android RemoteViews widget and iOS WidgetKit extension integrated into projects. Show local progress, discard prior-day counts, open the app. iOS App Group provisioning required.
- Local-data deletion, software licenses and privacy information. No accounts, backend, ads or analytics.

## Run and verify

**Windows:** follow [the setup and build guide](docs/WINDOWS_BUILD.md), then run `./tool/build-windows.ps1 -Mode Debug` in PowerShell. It stops on validation, analysis, test or build failure. See [the startup security record](docs/STARTUP_SECURITY.md) for the blocked command and isolation result.

Baseline: Flutter 3.35.7 / Dart 3.9, Java 17, Android SDK 35, minSdk 23, iOS 14+, Xcode on macOS, CocoaPods. Direct dependency versions are pinned. **pubspec.lock was not fabricated**; retain the real generated lockfile after resolving on a permitted build host.

Native project files are included. Do not overwrite them with `flutter create .`.

```sh
flutter pub get
dart tool/content_check.dart
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

Prior-conversation retrieval failed. The supplied starter, current request and visible decisions were used. Unseen requirements have not been invented. The larger 19+ morning list mentioned in the starter was not supplied; unresolved additions remain in the review queue.
