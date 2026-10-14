# Wird — ورد

Arabic-first, private, offline Flutter application for Android and iOS, expanded from the supplied starter.

**The preserved premium app and completed Athkar collections are under review on `redesign/premium-20261013`, in PR #1.** Fresh [workflow #44](https://github.com/Hmx77/Wird/actions/runs/38535771707) passed all 36 tests and analysis on both hosts, Android debug packaging/offline native checks, and unsigned iOS device/simulator builds with installation and launch. Download `wird-debug-apk` from its Artifacts list. See `docs/BUILD_STATUS_CONTENT_2026-10-14.md` for exact results, fixes, artifact identifiers and remaining production gates. The repository remains private; no merge or store publication has occurred.

The redesign adds the approved original-artwork crop and separate kasra layer, a warm botanical opening, darker home cards, four navigation tabs with an owned sujood icon, Arabic names for all ten themes, licensed offline Arabic fonts and visual/native smoke checks. All 19 legacy content IDs and existing preference keys are preserved; the reference-based catalog now adds source-checked material and explicit review holds. The hidden calendar/activity interface retains its stored data. See `docs/REDESIGN_TRACEABILITY.md` for requirement mapping and acceptance gates.

## Implemented source

- Exact uploaded logo preserved byte-for-byte in-app, with mechanically resized launcher copies and native splash screens. Original source PNG is unchanged; the review UI clips excess canvas and draws the separately approved kasra in code.
- All ten starter palettes, default **Stone & Teal**: Olive & Cream, Ocean Blue, Mocha & Sand, Soft Lavender, Emerald & Gold, Midnight Blue, Charcoal & Sage, Dusty Rose & Stone, Stone & Teal, Sage & Ivory.
- Arabic-first interface with saved Arabic/English UI selection, RTL religious text, scalable text, focus mode, and source/benefit/meaning panels. Religious text remains in Arabic; English religious translations await review.
- **49 category-specific source-checked entries:** 18 morning, 15 evening, 16 bedtime. All 66 attached reference screens are mapped; 17 screens remain withheld under the strict Quran/Sahih policy. The catalog contains 36 distinct Arabic bodies and 35 underlying recitation/guidance units, not 66 unique Athkar. Full Al-Mulk includes all 30 verses from the verbatim attributed Tanzil dataset.
- Persistent repetition counters, undo, long-press reset, optional haptics and auto-advance; separate local-date progress with midnight refresh. Tahlil offers independently sourced 1/10/100 alternatives in one entry; changing a target resets today’s count while preserving historical targets. Source notes distinguish daily/general practice from timed morning/evening prescriptions.
- Favorites, Arabic search ignoring diacritics, tatweel and common alef forms.
- Referenced Sunnah/Nawafil guidance and optional prayer tracking.
- Stored activity history remains preserved; the redesign hides the calendar/activity dashboard and its navigation tab.
- Three opt-in daily local reminders, selected clock times, permissions, notification reader routing, Android reboot restoration and timezone refresh on resume. Inexact delivery can be delayed by battery restrictions.
- Full-text Arabic PNG share cards with reference, timing and the selected count context; OS share sheet and iPad anchor.
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

The data check runs with Dart after dependency resolution. Static Python checks need only the standard library. These do not prove Flutter/plugin compilation or scholarly authenticity.

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

All three supplied PDFs (25 morning, 23 evening, 18 bedtime screens) have now been visually inspected and compared. See `docs/CONTENT_VERIFICATION_2026-10-14.md`, `docs/reference-comparison.csv`, `docs/reference-screen-map.json` and `docs/content-audit.json` for every correction, preserved variant, source, pending item and counting definition. The sevenfold حسبي الله attribution warning and other disputed, Hasan-only or weak routes remain in the private review queue, outside the reader/search/share catalog. No qualified scholarly approval is claimed; independent Arabic/religious proofreading remains required before public release. Earlier redesign manifests describe the historical 19-entry baseline.
