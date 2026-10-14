# Wird verification — 14 October 2026

Source is private in Hmx77/Wird, on `redesign/premium-20261013`, draft PR #1. Main has not been merged and no app store publication has occurred.

## Evidence

| Operation | Exact source / run | Actual result |
|---|---|---|
| Android dependencies, doctor, assets, analysis, tests, packaging | a3e444de82b30793744896e73db84c07614f26db; run #28 / 38443686018, Android job 115456444205 | Passed; zero analysis issues, 22 tests plus asset-renderer test; debug APK built |
| iOS dependencies, doctor, assets, analysis, tests, device compilation and simulator launch | f47e141d391ff6538a5f74f22c347e2bd47269c3; run #29 / 38446354579, iOS job 115465665560 | Passed; Xcode 26.3, 22 tests plus renderer, unsigned device and simulator builds, installation/launch and actual screenshot |
| Android installation, verified offline radios, visible home in normal/large-font/tablet views, fatal-error scan | 3131ed43bb9d11222f37794aea87d7aebe824e1b; run #33 / 38503414257, Android-device job 115655347132 | Passed using the exact APK artifact from run #28; all three foreground/home-content assertions passed |
| Native artwork and review-image preservation | Run #33, review-assets job 115657021350 | Passed; generated icons, opening and UI/native images committed only to the unchanged review branch |
| Local checks | Current source; isolated standalone Dart / Python / Bash | Content and static checks, shell syntax, YAML job/permission checks, RGB PNG checksum/pixel roundtrip and native foreground-assertion fixtures passed |
| Signed Android release APK/AAB | Release workflow configured, not run | Blocked by missing owner signing material |
| Signed iOS IPA / device distribution | Xcode project prepared, not archived with signing | Blocked by Apple team, identifier ownership and App Group provisioning |

The overall historical #28 and #29 workflows are marked failed because separate downstream/platform steps failed. Their Android packaging and corrected iOS jobs passed as recorded above. Run #33 is a successful native recheck, not a new APK compilation; its Android/iOS compile jobs intentionally reuse the existing verified artifacts.

## Download and integrity

Open https://github.com/Hmx77/Wird/actions/runs/38443686018, find **Artifacts**, download **wird-debug-apk**, unzip it and install `app-debug.apk` on an Android device.

- APK: 161,304,484 bytes; debug build, version 0.4.0+4, target SDK 36. This supersedes the earlier 0.2 baseline APK.
- APK artifact ZIP: ID 11838456054; SHA-256 **af9272f2d53f350b85c62cfdeff72c3d86ca7946639ec1d445b65fff7999d653**. This is the ZIP digest, not a fabricated raw APK digest.
- Native Android evidence: run #33 artifact `wird-android-device-review`, ID 11866762128; ZIP SHA-256 **f0105f059a0ac991b60f16c019dc59f5ca9f872ba6d9eca52711fd545f841fcd**.
- iOS evidence: run #29 artifact `wird-ios-verification`, ID 11839192061; ZIP SHA-256 **1667636c0da8a5718783d2170eb7a3d07be75d1efabecc84a56c4e47c5eb9cd8**.
- Artifacts have 14-day retention. Browser download attempts did not produce a local APK attachment; the verified private GitHub artifact remains available. No old APK is presented as the redesigned build.

The earlier hosted debug signing key was ephemeral. Preserve existing app data and check signing-certificate continuity before attempting an update; do not uninstall an existing installation just to bypass a signature mismatch.

## Fixes and actual limitations

- Hosted runner capacity: removed unused reproducible .NET/Haskell toolchains to resolve native-library packaging exhaustion.
- Widget/font rendering: moved real asynchronous font/image operations out of fake test time; rendered iOS assets at their exact integer dimensions; removed test debug ribbons, added a red-pixel regression check, encoded opaque RGB iOS icons and verified adaptive mask safe zones.
- UI tests: corrected theme-picker scrolling and Arabic back navigation in the harness; all 22 tests then passed on both hosts.
- iOS installation: supplied the missing widget CFBundleName and matching 0.4.0/build-4 extension metadata, with a static regression check. Actual simulator installation/launch subsequently passed.
- Android native tests: unified AVD directories, replaced an unavailable ripgrep dependency with standard commands, waited for package-service readiness, staged APK installation and replaced the unavailable phone-service command with verified airplane mode/Wi-Fi settings.
- Runtime acceptance: Android `am start -W` sometimes reported a timeout on the slow debug/software-rendered emulator. The strengthened check independently verified foreground app and actual home content before every screenshot. Debug emulator timings are not a physical-device release performance benchmark.
- Non-blocking hosted-action Node.js deprecation warnings remain; their actions completed successfully.

## Preserved product and content

Original source logo SHA-256: **68190c2046747a8c0f8556cbbbcf395887e9f69489887615448d69e85f926244**. Religious source file SHA-256: **dc67bce7879061eeb4b1a4c9008e09b31f1846f8f4152a39a139a208e14762c2**.

The original artwork is immutable; only the specification-approved excess-canvas crop and one separate kasra layer are composed. All ten palettes retain their identities/indices, with Stone & Teal default and explicit Arabic names. The warm opening, dark home, owned sujood vector, four-tab navigation, favorites/search, reader counters and stored local progress are implemented. The calendar/activity dashboard is hidden while its code/data remain preserved. Core operation needs no login or backend.

The existing 19 entries remain six morning, five evening and eight bedtime. No unseen entry was invented to reach a requested total. Original 25 morning-reference screens remain unavailable; exact omission comparison is blocked. Every included entry still requires qualified independent proofreading before public release, and unresolved/excluded material stays in the review manifest. No unlicensed audio or synthetic substitute was added; zero licensed recordings have been supplied.

## Production gates

1. Original 25-reference inventory and independent qualified Arabic/religious proofreading, including unresolved variant/translation questions.
2. Owner Android upload key and Apple signing team, bundle IDs and App Group provisioning.
3. Physical-device notification allow/deny/reboot/timezone delivery, actual widget behavior, accessibility, signed data-preserving updates and startup performance.
4. Properly licensed recordings with rights evidence and pronunciation review if audio is to be enabled.
5. Owner visual acceptance and explicit store-publication approval before public distribution.

Security: the blocked local invocation was `/tmp/wird-flutter-sdk/bin/flutter --version`. No unrestricted metadata retry occurred. Hosted SDK startup uses a metadata firewall and clean validation environment; standalone local Dart checks deny network syscalls. See STARTUP_SECURITY.md. Windows build commands are maintained in WINDOWS_BUILD.md, including asset generation before native builds.
