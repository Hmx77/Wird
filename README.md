# Wird — ورد

Arabic-first, offline Flutter application for Android and iOS, expanded from the supplied starter.

**Current review:** [PR #2](https://github.com/Hmx77/Wird/pull/2), on `redesign/refined-20261015`, targets the existing `redesign/premium-20261013` branch. The latest owner-supplied artwork is preserved byte-for-byte with its existing kasra. The latest revision adds an automatic cinematic deep-teal opening with a mosque/arch/lantern scene, the original logo and exact Arabic tagline, then dissolves into the functioning home screen without any CTA or tap. The muted home and four-tab navigation remain unchanged.

See [the automatic splash report](docs/CINEMATIC_SPLASH_2026-10-17.md) for build 0.4.0+6. [Final workflow](https://github.com/Hmx77/Wird/actions/runs/39018043548) passed all four jobs: analysis and 40 tests on Linux/macOS, Android packaging/offline native checks, unsigned iOS builds and iOS simulator installation/launch. [Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39018043548/artifacts/12096165559), containing `app-debug.apk`. [Actual Android recording and screenshots](https://github.com/Hmx77/Wird/actions/runs/39018043548/artifacts/12095708264) include `startup.mp4` and sampled native frames. Earlier cinematic artifacts were superseded after fixing a capture dependency and a runtime text-style issue; use this final build. The earlier [refinement report](docs/REFINED_REVIEW_2026-10-15.md) records the previous build history.

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

