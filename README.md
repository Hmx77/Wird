# Wird — ورد

Arabic-first, offline Flutter application for Android and iOS, expanded from the supplied starter.

**Current review:** [Two premium appearances — draft PR #5](https://github.com/Hmx77/Wird/pull/5), on `redesign/two-premium-themes-20261020`, targeting the approved Tasbih review branch. Exactly **Midnight Teal (default)** and **Ivory Serenity** are available throughout the existing app, with safe legacy-preference migration and preserved offline worship data.

[Successful final Android verification #130](https://github.com/Hmx77/Wird/actions/runs/39558077077) · [Download wird-debug-apk / app-debug.apk](https://github.com/Hmx77/Wird/actions/runs/39558077077/artifacts/12327556051) · [Actual paired screenshots, results, migration and limitations](docs/TWO_PREMIUM_THEMES_2026-10-21.md).

Android and macOS analysis and **92 app tests + 1 branding test on each platform passed** in the #129 build jobs. Android debug and unsigned iOS device/simulator builds and actual iOS simulator install/launch passed. #129 was canceled only after both build jobs succeeded to stop its duplicate native review. #130 completed the full offline Android suite on the identical APK: live two-theme switching/restart with all other saved preferences unchanged, existing feature regressions, small/large-text/tablet checks and settled major-screen captures. No merge or publication. Debug signing differs from earlier review builds; uninstalling can erase local progress. See the report for exact test scopes and signing requirements.

**Previous Tasbih review:** [Premium Personal Tasbih — draft PR #4](https://github.com/Hmx77/Wird/pull/4), branch `redesign/premium-tasbih-20261019`, targets the Reader review branch. The real standalone screen now has a gold-rimmed counter, deep-teal botanical atmosphere, refined controls, saved-count integration, optional haptics, reduced motion and accessible scrolling. Approved screens, original branding, ten themes, religious catalog and local data keys remain preserved.

[Actual Android screen](docs/review-images/android-native/android-tasbih-six.png) · [Counter/restart/reset recording](docs/review-images/android-native/tasbih-interactions.mp4) · [Full verified report and before/after](docs/PREMIUM_TASBIH_2026-10-20.md) · [Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39376665711/artifacts/12243887475) · [Successful native review #122](https://github.com/Hmx77/Wird/actions/runs/39376665711).

Linux/macOS analysis and **139 app tests + 1 branding test on each platform** passed in the #121 build jobs, with Android APK and unsigned iOS device/simulator packaging and simulator launch. Full offline Android interaction verification passed in #122 on the exact same APK, including six taps, 25 rapid taps, restart persistence, reset, 200% text and 320dp controls. See the report for precise scopes and retained earlier failures. Debug signing differs from older builds; do not uninstall an existing copy with saved progress without considering data loss. No merge or publication.

**Previous Library/Reader review:** [PR #3](https://github.com/Hmx77/Wird/pull/3), on `redesign/premium-reader-20261019`, targets the approved Settings review branch. Build **0.6.3+17** implements the botanical deep-teal Athkar Library and manuscript Reader with full source text, live search/bookmarks, complete references, existing counter controls and persistence. The approved splash, launcher, Settings, Nawafil and Home layout are preserved; only the Home Library popup route colors were integrated.

[Actual Library render](docs/review-images/library-premium-ar.png) · [Actual Reader render](docs/review-images/reader-premium-main.png) · [Counter and controls](docs/review-images/reader-premium-counter.png) · [Before/after and full results](docs/PREMIUM_READING_2026-10-19.md) · [Download final build-17 APK](https://github.com/Hmx77/Wird/actions/runs/39265460158/artifacts/12192697789).

Android and macOS analysis passed, with **114 app tests + 1 separate branding test on each platform**. Android debug packaging, unsigned iOS device/simulator packaging and actual iOS 26 simulator install/launch passed in [build #112](https://github.com/Hmx77/Wird/actions/runs/39261132223); the overall run was canceled after those build jobs and its native selector run was superseded. [Focused Reader recheck #115](https://github.com/Hmx77/Wird/actions/runs/39265460158) passed on the identical APK: Library/search/bookmarks, count/Undo/restart/navigation/evidence, all 30 Al-Mulk markers, 150% text and reachable counter, cold/warm launch and small/tablet checks. Home/Settings native interactions passed separately in #113 on that same APK. See the report for exact scopes and retained earlier failures. No merge or publication has occurred.

**Debug update limitation:** build 17's runner-generated debug certificate differs from build 16, so it cannot update that installation in place. Avoid uninstalling an existing copy without considering loss of local progress. Stable owner-controlled signing is required for reliable updates; this APK is not a production release.

## Previous Home and Nawafil review

**Previous review:** [PR #2](https://github.com/Hmx77/Wird/pull/2), on `redesign/refined-20261015`, targets `redesign/premium-20261013`. Review build **0.6.1+15** implements Botanical Serenity for Sunnah and Nawafil: an original local botanical sunrise header, gold/cream tracking rows, the preserved source note and optional prayers, accessible checks, and a derived rakah ring alongside the existing five-group progress. Arabic fractions and citation ranges retain their logical order. The approved premium Home, splash, launcher, original branding, religious catalog, ten themes and local state are preserved.

[Actual Android Nawafil screen](docs/review-images/nawafil-header-build15.png) · [Source note](docs/review-images/nawafil-note-build15.png) · [Other prayers](docs/review-images/nawafil-other-build15.jpg) · [Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39121693620/artifacts/12134501811) · [Final verification run](https://github.com/Hmx77/Wird/actions/runs/39121693620) · [Complete Nawafil verification report](docs/PREMIUM_NAWAFIL_2026-10-18.md).

Build-15 Android analysis, 66 app tests plus a separate branding test, debug packaging and offline Android 36 emulator checks passed. Checkbox state survived a real process restart, and the corrected Arabic fractions/citation range were visually inspected. All ten themes/Arabic and English at 200% text are covered by tests. The main run's first iOS simulator packaging copy failed with a runner I/O error. A [fresh macOS retry on the same app source](https://github.com/Hmx77/Wird/actions/runs/39122416227) then passed analysis, all 66 app tests, branding, unsigned device/simulator builds and simulator install/launch, including its bounded launch retry. The report retains the earlier failures. This is an unmerged debug review, with Apple signing and physical-device release checks still outstanding.

The approved [premium Home](docs/review-images/home-bento-android-build13.png) retains its illustrated bento layout, 18/15/16 category counts, four working shortcuts and supplied filled sujood silhouette. Its previous phase and actual build results remain documented in [the Home report](docs/PREMIUM_HOME_2026-10-18.md). The new Nawafil scene adds approximately 81 KiB of original optimized local artwork; all text and controls are real Flutter widgets.

The earlier content work remains in [PR #1](https://github.com/Hmx77/Wird/pull/1). Both source logo originals, all 49 content entries, ten themes, stored preference keys and offline features are preserved. The supplied latest artwork already includes the kasra; no separate kasra is added. Native icon layers are mechanically derived from the original artwork.

Repository visibility was observed as **public** on 16 October 2026 and was left unchanged under the latest task instruction. This review has not been merged or published to an app store.

## Implemented source

- Both exact owner-supplied logo source files remain unchanged. The latest high-resolution artwork, including its original kasra, is used in-app. Native adaptive icon and splash assets are reproducibly derived and checked for safe-zone placement, alpha handling and iOS opacity.
- Exactly two premium appearances: **Midnight Teal** (default) and **Ivory Serenity**. Retired palette preferences migrate safely to stable local IDs without resetting worship data.
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



