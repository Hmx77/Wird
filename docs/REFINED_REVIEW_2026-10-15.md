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

## Verification record

Local: Dart formatting and Python structural/content-hash checks executed successfully. Full Flutter analysis, tests, builds and native launch checks must be recorded from the fresh CI run before acceptance. A direct pure-Dart check initially failed before package resolution; it is retried with an explicit local package mapping. Local Flutter engine artifacts are unavailable; no local Flutter build is claimed.

CI retains cloud-metadata blocking and clean build environments. It uploads `wird-debug-apk` containing `app-debug.apk`, verification logs and actual visual/native outputs. The review-output writer is restricted to this exact review branch and refuses to push if the branch advanced during the build.

## Before / after evidence

Before images remain available at the immutable baseline commit. After images are populated only by successful rendering and native checks, under `docs/review-images/`.

| Area | Before | After |
|---|---|---|
| Arabic home and navigation | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/home-ar-430.png) | [After](review-images/home-ar-430.png) |
| English home | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/home-en-430.png) | [After](review-images/home-en-430.png) |
| Opening | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/opening.png) | [After](review-images/opening.png) |
| Android circular launcher | [Before](https://github.com/Hmx77/Wird/blob/6aa2c421330f41bc1a0a77eb9837ca8340d3f9ef/docs/review-images/adaptive-circle.png) | [After](review-images/adaptive-circle.png) |

## Remaining acceptance gates

Actual CI results and visual inspection pending. Physical Samsung One UI and physical iOS launcher/startup checks are unavailable here; do not equate emulator/simulator coverage with those checks. Apple provisioning and Android release signing remain owner-controlled; no signed release or app-store readiness is claimed. Qualified religious/Arabic proofreading remains required before public release.

GitHub reports the repository as **public** on 15 October 2026. Visibility is left unchanged as explicitly requested in the latest plan. Older reports saying private describe earlier sessions and must not be treated as current visibility evidence.
