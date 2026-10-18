# Wird — ورد

Arabic-first, offline Flutter application for Android and iOS, expanded from the supplied starter.

**Current review:** [PR #2](https://github.com/Hmx77/Wird/pull/2), on `redesign/refined-20261015`, targets `redesign/premium-20261013`. Review build **0.6.1+15** implements Botanical Serenity for Sunnah and Nawafil: an original local botanical sunrise header, gold/cream tracking rows, the preserved source note and optional prayers, accessible checks, and a derived rakah ring alongside the existing five-group progress. Arabic fractions and citation ranges retain their logical order. The approved premium Home, splash, launcher, original branding, religious catalog, ten themes and local state are preserved.

[Actual Android Nawafil screen](docs/review-images/nawafil-header-build15.png) · [Source note](docs/review-images/nawafil-note-build15.png) · [Other prayers](docs/review-images/nawafil-other-build15.jpg) · [Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39121693620/artifacts/12134501811) · [Final verification run](https://github.com/Hmx77/Wird/actions/runs/39121693620) · [Complete Nawafil verification report](docs/PREMIUM_NAWAFIL_2026-10-18.md).

Build-15 Android analysis, 66 app tests plus a separate branding test, debug packaging and offline Android 36 emulator checks passed. Checkbox state survived a real process restart, and the corrected Arabic fractions/citation range were visually inspected. All ten themes/Arabic and English at 200% text are covered by tests. The main run's first iOS simulator packaging copy failed with a runner I/O error. A [fresh macOS retry on the same app source](https://github.com/Hmx77/Wird/actions/runs/39122416227) then passed analysis, all 66 app tests, branding, unsigned device/simulator builds and simulator install/launch, including its bounded launch retry. The report retains the earlier failures. This is an unmerged debug review, with Apple signing and physical-device release checks still outstanding.

The approved [premium Home](docs/review-images/home-bento-android-build13.png) retains its illustrated bento layout, 18/15/16 category counts, four working shortcuts and supplied filled sujood silhouette. Its previous phase and actual build results remain documented in [the Home report](docs/PREMIUM_HOME_2026-10-18.md). The new Nawafil scene adds approximately 81 KiB of original optimized local artwork; all text and controls are real Flutter widgets.

The earlier content work remains in [PR #1](https://github.com/Hmx77/Wird/pull/1). Both source logo originals, all 49 content entries, ten themes, stored preference keys and offline features are preserved. The supplied latest artwork already includes the kasra; no separate kasra is added. Native icon layers are mechanically derived from the original artwork.

Repository visibility was observed as **public** on 16 October 2026 and was left unchanged under the latest task instruction. This review has not been merged or published to an app store.

## Implemented source

- Both exact owner-supplied logo source files remain unchanged. The latest high-resolution artwork, including its original kasra, is used in-app. Native adaptive icon and splash assets are reproducibly derived and checked for safe-zone placement, alpha handling and iOS opacity.
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

Baseline: Flutter 3.35.7 / Dart 3.9, Java 17, Android compile SDK 36 (target 36), minSdk 23, iOS 14+, Xcode on macOS, CocoaPods. Direct dependency versions are pinned. The generated `pubspec.lock` is committed; preserve it when reproducing the tested build.

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

All three supplied PDFs (25 morning, 23 evening, 18 bedtime screens) have now been visually inspected and compared. See `docs/CONTENT_VERIFICATION_2026-10-14.md`, `docs/reference-comparison.csv`, `docs/reference-screen-map.json` and `docs/content-audit.json` for every correction, preserved variant, source, pending item and counting definition. The sevenfold حسبي الله attribution warning and other disputed, Hasan-only or weak routes remain in the development review queue, outside the reader/search/share catalog. No qualified scholarly approval is claimed; independent Arabic/religious proofreading remains required before public release. Earlier redesign manifests describe the historical 19-entry baseline.

