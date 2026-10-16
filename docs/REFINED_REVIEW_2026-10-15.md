# Refined branding and home review — 15 October 2026

Review branch: `redesign/refined-20261015`, based on `6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef` of `redesign/premium-20261013`. The new PR targets that development branch and builds on PR #1. No merge or store publication.

## Changes

- Preserve both owner-supplied logo originals byte-for-byte. Use the latest 1254px artwork with its existing kasra; remove the old zoom and separately painted kasra. Provenance: `branding-source.json`.
- Native icons use a mechanically separated original cream/gold foreground over a full-bleed teal background. No baked rounded-square mask in the Android adaptive foreground; iOS icons are opaque RGB. Original calligraphy is never redrawn. Flutter asset generation explicitly waits for image decoding and checks visible artwork, kasra and circular safe-zone pixels.
- Match ivory native/Flutter launch surfaces, centered full logo, restrained decoration, WIRD and the requested Arabic tagline. Start Flutter before asynchronous service setup; hold the native surface only until image decoding completes. No minimum splash timer. Notification launch routing waits for service initialization.
- Replace the oversized intro with compact outlined categories, smaller identity/search header, muted slate foundations and theme-derived accents. Three content-height rows avoid a fourth empty grid slot and expand with accessibility text.
- Keep four navigation destinations with restrained active highlights and replace the prostration vector with an original side-view showing kneeling legs, forearms, hands and forehead at the mat.
- Increment build number to 5, preserving application identifiers, signing settings and all saved preference keys.

## Preservation

`lib/content.dart`, `lib/quran_text.dart`, `docs/content-audit.json`, `docs/reference-screen-map.json`, all entry IDs/count choices and religious-review decisions are unchanged from the base commit. 49 category entries remain: 18 morning, 15 evening, 16 bedtime; 17 withheld reference screens remain withheld. Thirty verses of Al-Mulk remain unchanged. No new audio or religious content. Ten palette identities and Stone & Teal default remain unchanged. Counters, favorites, reminders, widgets, history and offline services retain their existing storage and implementation.

## Verification record — updated 16 October 2026

[Review PR #2](https://github.com/Hmx77/Wird/pull/2) remains a draft against the existing redesign branch. No merge or publication.

The previous Android build in [run #50](https://github.com/Hmx77/Wird/actions/runs/38742573464) succeeded, with 37 automated tests, the separate brand-rendering test, analysis and offline native Android checks passing. The overall run was cancelled after an iOS simulator stall; it must not be described as wholly successful. [Run #51](https://github.com/Hmx77/Wird/actions/runs/38745822972) reused and installed that exact APK successfully, and passed analysis, 37 tests and both unsigned iOS builds, but failed at the 300-second simulator boot deadline before app installation.

Follow-up corrections affect verification tooling only:
- Explicit DefaultTextStyle in the transparent brand renderer fixes Ahem fallback squares and debug underlines in the generated opening preview. The runtime opening already inherits its text style through Scaffold.
- Android screenshot capture now retries within bounds and validates PNG signature, dimensions, chunk CRCs and the complete file, rejecting empty/truncated captures.
- iOS checks create a fresh disposable device from an already installed iOS 26 runtime/device type. No runtime licenses, signing credentials or network protections are changed.

Local checks on 16 October: bash syntax and Python compilation passed. Four screenshot-guard cases passed: valid PNG accepted; empty, truncated and corrupted PNGs rejected. No local Flutter SDK is installed in the renewed workspace; Flutter results come from CI.

Fresh full verification: [run #53](https://github.com/Hmx77/Wird/actions/runs/38847462743), source commit `25ff7bb8e9412e6b20700abbbffff463bc3742b9`. iOS: analysis, 37 suite tests, the separate brand-rendering test, unsigned device build (32.3 MB), simulator build, fresh iOS 26.2 iPhone 17 Pro installation/launch and screenshot capture all passed. Android: dependency resolution, analysis, 37 suite tests, separate brand-rendering test, debug packaging and offline emulator installation/launch/small-screen/enlarged-text/tablet checks all passed. All four workflow jobs succeeded.

CI retains cloud-metadata blocking and clean build environments. It uploads `wird-debug-apk` containing `app-debug.apk`, verification logs and actual visual/native outputs. The review-output writer is restricted to this exact review branch and refuses to push if the branch advanced during the build.

The downloadable [wird-debug-apk artifact](https://github.com/Hmx77/Wird/actions/runs/38847462743/artifacts/12024500649) contains `app-debug.apk` (version 0.4.0+5, application ID `ae.wird.app`). It was downloaded and installed by the native Android job. Archive SHA-256: `bba47461b521a8157925be42d6907f546f2710d59afcc75d98e85933186b10ca`. It expires 30 October 2026. Android, native-device and iOS verification reports are separate artifacts on the same run.

The run #53 launcher PNG is a valid 1,370,234-byte image but captured the home wallpaper rather than the installed app icon. The initial empty-file diagnosis was incorrect: the connector omitted inline content for the large image. A follow-up assertion now requires the launcher and the Wird label in its accessibility hierarchy before capture. Native-only [run #55](https://github.com/Hmx77/Wird/actions/runs/38881787978) reuses the exact successful APK and iOS evidence from #53. Run #55 passed Android native and review-asset jobs (Android/iOS rebuild jobs deliberately skipped). The first launcher attempt lacked the app label; the bounded retry found it and captured the installed icon. Offline home, small screen with enlarged font, tablet and fatal-runtime checks passed. The same APK is also available in [artifact 12037828184](https://github.com/Hmx77/Wird/actions/runs/38881787978/artifacts/12037828184).

Earlier #46/#47 failures came from accessibility-test viewport handling, corrected by scrolling to each card and resetting the viewport for each theme. Doctor warnings about unused SDK 37 licenses, Android Studio and Linux desktop dependencies do not invalidate the executed Android SDK 36 and iOS builds; no license was accepted automatically.

## Before / after evidence

Before images remain available at the immutable baseline commit. After images are populated only by successful rendering and native checks, under `docs/review-images/`.

| Area | Before | After |
|---|---|---|
| Arabic home and navigation | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/home-ar-430.png) | [After](review-images/home-ar-430.png) |
| English home | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/home-en-430.png) | [After](review-images/home-en-430.png) |
| Opening | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/opening.png) | [After](review-images/opening.png) |
| Android circular launcher | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/adaptive-circle.png) | [After](review-images/adaptive-circle.png) |

## Remaining acceptance gates

Full CI run #53 passed. The corrected opening preview and actual iOS home were visually inspected. Physical Samsung One UI and physical iOS launcher/startup checks are unavailable here; do not equate emulator/simulator coverage with those checks. Apple provisioning and Android release signing remain owner-controlled; no signed release or app-store readiness is claimed. Qualified religious/Arabic proofreading remains required before public release.

GitHub reports the repository as **public** on 15 October 2026. Visibility is left unchanged as explicitly requested in the latest plan. Older reports saying private describe earlier sessions and must not be treated as current visibility evidence.

