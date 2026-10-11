# Actual verification — 11 October 2026

Repository: private `Hmx77/Wird`. Source, original assets, tests and workflows are uploaded. No other repository or store was modified.

## Fixes validated during this session

- Reader widget test scrolls the counter label into view and waits for scrolling before tapping. The old test missed an off-screen target; its state assertion remains intact.
- Android Kotlin build script explicitly imports `java.util.Properties`, avoiding Gradle's `java` extension shadowing the package name.
- Android compile SDK is 36 to satisfy resolved shared_preferences_android and url_launcher_android dependencies. Minimum SDK remains 23 and target SDK remains 35.
- Android modules pin Glance 1.1.1. The plugin's dynamic resolution previously selected 1.3.0-alpha02, which requires SDK 37 and AGP 9.1.0. Glance 1.1.1 includes Google's protobuf security fix.

## Actual results

Combined workflow run: https://github.com/Hmx77/Wird/actions/runs/38159340833

Commit tested: `cffa374365db8aba74f841b9542bb833eb505a99`.

| Check | Result |
|---|---|
| Metadata firewall before tool startup | Passed on Linux and macOS |
| Flutter startup and dependency installation | Passed, Flutter 3.35.7 / Dart 3.9.2 |
| Flutter analysis | No issues on Linux and macOS |
| Automated tests | 12 passed on each platform |
| Content and asset regression checks | Passed: 19 entries, all 10 themes, exact logo |
| Unsigned iOS device compilation | Passed with Xcode 15.4; Runner.app, 33.0 MB |
| Android debug APK | Passed; installable debug APK generated and downloaded (162,293,330 bytes) |
| Signed Android APK / AAB | Not generated; release signing credentials unavailable |
| Signed iOS IPA | Not generated; Apple signing unavailable |
| Physical-device notifications, widgets and accessibility | Not yet tested |

The downloaded iOS verification archive passed ZIP integrity and matched GitHub's SHA-256 `62ed10730d655c1de0461d56a5f83d47c1934d1167eed2cd225642c1a2ecf206`. It contains the actual build log, pubspec.lock and ios/Podfile.lock.

## Remaining production gates

Qualified independent Arabic/religious proofreading is required before public release. Automated source/count checks do not constitute scholarly certification. No unlicensed audio is included; playable recordings require appropriate rights evidence and Arabic approval. Existing Android release credentials and Apple developer signing/provisioning are required for production installation. Bundle identifier `ae.wird.app` and App Group `group.ae.wird.app` need ownership confirmation before store release. Physical-device QA remains required.

The historical report dated 10 October describes the earlier local startup limitation; GitHub-hosted safe startup and iOS compilation have now succeeded. No unrestricted metadata access was approved, no credentials were exposed, and no store publication occurred.

APK SHA-256: `6dd14aa720441ca02b8ce1e441f7431d561752dbce0987dac4ec4912a14cba22`. Artifact ZIP SHA-256: `4eeb194ab4386d4a7af7a1d4a68a502f03b3d81051d33bac104a18e43c5201d9`. The downloaded archive and APK passed ZIP CRC integrity checks. The APK includes ARM64, ARMv7 and x86_64 libraries; embedded original-logo bytes matched the required checksum. This is a debug build, not a signed production release.

Combined run succeeded in 12m 51s: Android 12m 41s, iOS 4m 48s. Earlier runs failed on an off-screen test tap, Gradle Properties import, and Android dependency SDK/AGP requirements; these were fixed before the successful run. Workflow action deprecation warnings remain maintenance work and did not prevent either build.
