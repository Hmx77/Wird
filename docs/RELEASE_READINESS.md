> Latest status and changes: `BUILD_STATUS_2026-10-10.md`. GitHub repository exists privately; source upload and CI execution await repository access.

# Release readiness — 9 October 2026

## Actual checks

| Check | Result |
|---|---|
| Exact source logo vs uploaded PNG | SHA-256 matched |
| Dart formatter/parser across lib/test/tool | Passed |
| Standalone Dart content regression checks | Passed: 19 entries, IDs, sections, counts, sources, Arabic search |
| Native XML/storyboards/plists/entitlements | Parsed successfully |
| iOS icon dimensions | Passed |
| Ten themes / default palette | Passed structural check |
| Audio manifest / release signing policy | Passed structural check |
| Android receiver / iOS extension configuration | Passed structural check only |
| Flutter resolution / analysis / full tests | Blocked, not passed |
| Android APK/AAB | Not compiled |
| iOS IPA | Not compiled; no macOS/Xcode here |
| Device/accessibility/store testing | Not run |
| Offline structural checks after resumption | Passed again; Python reads explicitly use UTF-8 for Windows Arabic compatibility |
| Windows PowerShell build script | Included; not executed (PowerShell unavailable here) |

Flutter startup attempted a link-local cloud metadata request while setting up its tooling. Automatic approval review rejected it because the endpoint can expose instance metadata or credentials. That initialization was not retried or bypassed. Standalone Dart was used only for independent offline parsing/formatting and the package-free content check; this is not a Flutter test run.

## Tests included, awaiting Flutter

- `test/content_test.dart`: corpus/source invariants.
- `test/state_test.dart`: counter bounds, persistence, defaults, midnight separation, corruption recovery, deletion.
- `test/reader_test.dart`: immediate reader counter/favorite updates.

The supplied CI workflow has not executed. Resolve dependencies on an approved host, preserve the real lockfile, and run all gates before calling the app production-ready.

## Device QA required

1. Android/iOS fresh installation; small/large screens, all themes, landscape/tablets, large accessibility fonts, TalkBack/VoiceOver.
2. Airplane-mode reading, counters, favorites, search, terminate/reopen persistence.
3. Local midnight and timezone changes. Reminders refresh to the device timezone on app resume; immediate rescheduling after travel while never reopening the app is not guaranteed.
4. Notification allow/deny/revoke, edits, cancellation, Android reboot and reader routing for cold/warm launch. Delivery is inexact and OS-controlled.
5. Add/remove widgets, progress/deletion refresh, prior-day reset. Android periodic refresh and iOS timeline delivery are OS-controlled. Validate provisioned App Group on iPhone.
6. All share cards, especially long three-surah text: no clipping, Arabic shaping, RTL and iPad share-sheet position.
7. Once licensed recordings exist: pronunciation, play/pause/replay/seek, interruptions, leaving/backgrounding reader, no automatic worship-counter increments.
8. Native compilation and plugin compatibility. Source parsing cannot establish runtime behavior.

## External input / access still needed

- Licensed recordings or written redistribution permission for audio.
- Independent qualified religious/Arabic proofreading and resolution of the content review queue before public release.
- Apple Developer signing team/profiles/App Group; Google Play account and Android upload keystore for distribution.
- A Flutter build host with safe isolation or the local Windows setup in `WINDOWS_BUILD.md`. The no-network namespace preflight failed here; unrestricted cloud metadata access is not requested or authorized. See `STARTUP_SECURITY.md`.
- Ownership confirmation for provisional bundle identifiers before registration.

No store publishing, account configuration or contacting third parties was performed.

## Not claimed

Compiled/store-ready release, complete Athkar encyclopedia, scholarly certification, Hijri calendar, location-based prayer calculator, licensed audio collection or background audio. Broader occasion-based duas and unseen earlier feature decisions remain unresolved instead of fabricated.
