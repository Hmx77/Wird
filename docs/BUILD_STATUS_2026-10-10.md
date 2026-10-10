# Actual delivery status — 10 October 2026

## Repository

Created `https://github.com/Hmx77/Wird` through the authenticated Hmx77 browser session and verified its **Private** label. Only GitHub's initial README commit is present. The connected GitHub API returned 404 for the repository and its main ref after creation; account identity itself resolved as Hmx77. No other project was modified.

Source upload and Actions execution are pending access to this new repository. The connector must include Wird, or the user must authorize use of the signed-in browser for the otherwise connector-supported upload and Actions operations. No account token was requested, read or exposed.

## Changes in this source package

- Arabic-first interface plus saved English UI selection and locale-aware navigation, controls, reminders and progress labels. Religious passages and their explanations remain in the reviewed Arabic; English religious translations await review.
- Explicit RTL for selectable religious text even in English mode. Original logo bytes and all ten palettes retained; Stone & Teal remains default.
- English category search, responsive branding row and reader index bounds.
- Calendar month alignment to the locale's first weekday; calendar-day history avoids subtracting fixed 24-hour durations across DST.
- Safer local-storage, source-link, deletion, reminder and asynchronous audio errors; notifications after disposed state are suppressed.
- Shared reminder scheduling function with calendar-based date rollover. Reminder defaults are consistent between display and rescheduling, and persisted times are bounded.
- Audio loader permits only known reviewed entries and rejects duplicate mappings, invalid paths/hashes, missing evidence or missing Arabic approval. No recordings added.
- Android release resource rule retains the notification icon. Android SDK 35, Java 17 and AGP configuration retained; iOS deployment target aligned to 14 in the framework plist and English locale declared.
- Android verification workflow, optional unsigned macOS/iOS validation, and manually dispatched signed Android workflow. Read-only repository token, no checkout credential persistence, metadata firewall before Flutter setup and clean process environment for builds. Signing secrets are required; missing secrets stop release. No store publishing step exists.
- Added localization/theme/asset, audio-policy and reminder/DST tests. Existing reader, content and state tests retained.

## Evidence and limits

| Check | Actual result |
|---|---|
| Original logo and content SHA-256 | Matched existing audit; neither altered |
| Dart format/parser | Passed under kernel-enforced no-network filter |
| Standalone Dart content check | Passed: 19 entries and source/count/search invariants |
| Python structural check | Passed: themes, assets, native XML/plists, audio gate and signing configuration |
| Workflow YAML | Parsed; read-only permissions checked |
| Shell script syntax | Passed `bash -n` |
| Missing-signing-secrets check | Exits before writing signing files |
| Flutter startup | Attempted safely; failed while downloading SDK because network was denied |
| Flutter doctor / pub get / analyze / flutter test | Not reached; startup is blocked |
| Newly authored Flutter tests | Not executed; no claim of passing |
| GitHub Actions runs | None; source/workflows are not uploaded yet |
| Android debug APK / release APK / AAB | None generated |
| iOS native compilation / IPA | Not executed; requires macOS/Xcode and signing for installation |
| Device notification / widget / accessibility QA | Not executed |

`dart format` emitted the expected missing `flutter_lints` resolution warning because Flutter dependencies are not installed. Parsing is not type analysis. Source checks are not independent religious certification.

## Secure startup investigation

The original rejection concerned `/tmp/wird-flutter-sdk/bin/flutter --version`, during SDK/tool bootstrap, not application execution. The original internal request origin remains unproven; no packet trace was retained.

The namespace sandbox preflight failed with `Operation not permitted`. For this attempt, a small local launcher installed a seccomp filter denying `socket`, `connect` and `io_uring_setup`, enforced native x86-64 syscalls, set `no_new_privs`, and closed inherited non-standard descriptors. A Python socket-construction test returned EPERM. Child commands inherited only a clean environment with a fresh HOME, PATH, CI and analytics settings. No private environment variables or user credential files were supplied.

Official standalone Dart 3.9.2 was downloaded via a fixed public SDK URL and used only for offline formatting/content checks under that filter. Flutter 3.35.7 source was cloned from its official public repository. Running its `bin/flutter --version` under the same filter exited 1: `curl: (6) Could not resolve host: storage.googleapis.com`, followed by failure to retrieve the engine Dart SDK. All attempted networking remained denied. Direct public prebuilt Flutter archive lookups also returned HTTP 404 in this environment. No unrestricted retry was made.

## Production gates

Successful Flutter analysis/tests and Android build; actual device QA; qualified religious/Arabic proofreading; approved licensed recordings if audio is to be offered; owned bundle IDs and App Group provisioning; user-provided release signing and developer accounts; current store SDK/privacy compliance. No store publication is authorized or performed.
