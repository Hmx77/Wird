# Release readiness — 14 October 2026

## Current content release gates

The supplied 25/23/18 PDFs are now available and all 66 screens have been compared. Current catalog: 18 morning, 15 evening, 16 bedtime entries; 17 reference screens remain withheld for religious review. See `CONTENT_VERIFICATION_2026-10-14.md` for every decision. The original logo remains unchanged; the Quran payload is now the credited verbatim Tanzil text with 54 source verse records, including all 30 Al-Mulk verses. All 19 legacy IDs remain compatible.

`BUILD_STATUS_CONTENT_2026-10-14.md` records fresh source revisions, actual test/build results, earlier failures and artifact ZIP digests. The current full validation uses 36 automated tests, in addition to native asset rendering. The earlier 22-test/19-entry results in `BUILD_STATUS_2026-10-14.md` are historical redesign evidence.

The repository and development artifacts remain private. No merge or store publication has occurred. PR #1 remains open for review; its owner's existing review status is preserved.

Production still requires:

- Qualified independent religious/Arabic proofreading of admitted text, citations, timing, benefits and rendered typography. No qualified approval has been obtained.
- Resolution of the 17 held reference screens and partial/disputed clauses if they are to be admitted. Sevenfold حسبي الله attribution/count/benefit caution remains explicit; Quran wording alone does not authenticate that practice.
- Owner-controlled Android signing for release APK/AAB and reliable upgrades. CI debug keys are test keys and may differ between fresh runners; this is not a production signing identity.
- Apple team, certificates/profiles, identifiers and matching App Group provisioning for Runner and WirdWidget. Unsigned device/simulator compilation and simulator launch do not produce a distributable signed IPA.
- Physical-device notification/widget/accessibility, signed-upgrade/data-retention and owner visual acceptance checks below.
- Verified redistribution rights and Arabic review before any audio is enabled. Zero recordings have been added.

The local Flutter startup invocation `/tmp/wird-flutter-sdk/bin/flutter --version` triggered the earlier security warning. It was not retried with unrestricted metadata access. GitHub-hosted builds install a metadata firewall before Flutter startup and invoke validation with a clean environment. Local pure Dart checks run with network syscalls denied. See `STARTUP_SECURITY.md` for evidence and limits.

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
