# Release readiness — 14 October 2026

## Actual checks

| Check | Result |
|---|---|
| Original logo and bundled religious source text | Original SHA-256 values retained |
| Dependency installation and Flutter analysis | Passed on Linux and macOS |
| Automated Flutter tests | All 22 passed on Linux and macOS |
| Reproducible native artwork generation | Passed; debug-banner pixel gate, icon dimensions, opaque RGB iOS output |
| Content, theme, XML/plist, audio-rights and signing-policy checks | Passed; not independent scholarly certification |
| Android debug APK | Built successfully in run #28; 161,304,484 bytes |
| iOS unsigned device compilation | Passed with Xcode 26.3 in run #29 |
| iOS simulator installation and launch | Passed in run #29, with actual screen capture |
| Android offline emulator validation | Passed in run #33; foreground/home content independently confirmed in all three views |
| Android signed release APK/AAB | Not built: signing material unavailable |
| Signed iOS IPA / App Store submission | Not built or submitted: Apple signing unavailable |
| Physical-device notifications/widgets/accessibility | Pending |

The local Flutter startup invocation `/tmp/wird-flutter-sdk/bin/flutter --version` triggered the earlier security warning. It was not retried with unrestricted metadata access. GitHub-hosted builds install a metadata firewall before Flutter startup and invoke validation with a clean environment. Local standalone Dart checks run with network syscalls denied. See STARTUP_SECURITY.md for evidence and limits.

See BUILD_STATUS_2026-10-14.md for actual source revisions, runs, artifact hashes and failures. Source remains on a private draft review branch; no store publication or merge has occurred.

## Device QA required

1. Android/iOS fresh installation; small/large screens, all themes, landscape/tablets, large accessibility fonts, TalkBack/VoiceOver.
2. Airplane-mode reading, counters, favorites, search, terminate/reopen persistence.
3. Local midnight and timezone changes. Reminders refresh to the device timezone on app resume; immediate rescheduling after travel while never reopening the app is not guaranteed.
4. Notification allow/deny/revoke, edits, cancellation, Android reboot and reader routing for cold/warm launch. Delivery is inexact and OS-controlled.
5. Add/remove widgets, progress/deletion refresh, prior-day reset. Android periodic refresh and iOS timeline delivery are OS-controlled. Validate provisioned App Group on iPhone.
6. All share cards, especially long three-surah text: no clipping, Arabic shaping, RTL and iPad share-sheet position.
7. Once licensed recordings exist: pronunciation, play/pause/replay/seek, interruptions, leaving/backgrounding reader, no automatic worship-counter increments.
8. Validate production-signed builds and startup performance on actual devices; debug emulator timing is not a release benchmark.

## External input / access still needed

- Licensed recordings or written redistribution permission for audio.
- Independent qualified religious/Arabic proofreading and resolution of the content review queue before public release.
- Apple Developer signing team/profiles/App Group; Google Play account and Android upload keystore for distribution.
- The original 25 morning-reference screens to finish the requested omission comparison.
- Physical devices for the remaining notification, widget, accessibility and signed-update tests.
- Ownership confirmation for provisional bundle identifiers before registration.

No store publishing, account configuration or contacting third parties was performed.

## Not claimed

Compiled/store-ready release, complete Athkar encyclopedia, scholarly certification, Hijri calendar, location-based prayer calculator, licensed audio collection or background audio. Broader occasion-based duas and unseen earlier feature decisions remain unresolved instead of fabricated.
