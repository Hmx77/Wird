# Wird completed-content build verification — 14 October 2026

Private development build; not scholarly or production approval. No merge or publication authorized or performed.

## Final delivery — workflow 44

**Success, 18m 46s:** https://github.com/Hmx77/Wird/actions/runs/38535771707

Final application/test revision: `e58b8d125e358dcb3f8e8ffc7ef45a0f3a609d05`, branch `redesign/premium-20261013`.

| Check | Actual result |
|---|---|
| Dependency resolution, format, content, branding and static policy checks | Passed on Android/Linux and iOS/macOS |
| Flutter analysis | Zero issues on both hosts |
| Automated tests | All **36 passed** on each host, plus the separate one-test brand renderer |
| Android debug build | Succeeded; Android job 12m 46s |
| Final APK native offline installation | Installed successfully; normal, small/large-font and tablet home assertions passed; native job 5m 37s |
| iOS device build | Unsigned release `Runner.app`, 31.7 MB; succeeded |
| iOS simulator build/install/launch | Succeeded; iOS job 11m 33s |
| Review outputs | Successful guarded commit, 13s |
| Signed release APK/AAB or signed IPA | Not built; owner signing unavailable |

**Download:** open the successful run above while signed in, then **Artifacts → wird-debug-apk**. The uploaded archive contains one **app-debug.apk**. The upload log confirms one file using `build/app/outputs/flutter-apk/app-debug.apk`; the exact final APK was then downloaded by CI and installed on Android 36.

- Final `wird-debug-apk`: artifact **11880298413**, ZIP **84,866,130 bytes**, SHA-256 **1cfd2be0f9d6b5a17646dfb819443d6813674f60febb083e5f863b84faa06926**. This is the ZIP digest. Actual uncompressed APK staged by adb: **161,343,620 bytes**.
- `wird-android-verification`: artifact **11881315606**, SHA-256 **c65349afdbf28e99b6cb5bd806896cbd11a6dcffd520d1728fa8facb9d9f10c7**, 6.06 MB displayed.
- `wird-ios-verification`: artifact **11880237774**, SHA-256 **b29e6778b0ec76f3273ac6a3d54adb7cc9413350ed44baf2688907c35e7e59b8**, 6.26 MB displayed.
- `wird-android-device-review`: artifact **11880767363**, ZIP **1,049,048 bytes**, SHA-256 **046b84af3997a7ce5f69b9df5d2dc06badae9385da40a095709bd507614e2e47**.

All four artifacts are present on the run. Logs and source/66-screen comparison reports accompany the verification artifacts. Generated reader images are committed under `docs/review-images`; review-image commit prefix **c5558a3**. Inspected Al-Mulk's final verses 29–30 and its reachable counter at maximum reading font size: numbered Arabic text renders, numeric labels correctly show **12 / 16** and **0 / 1**, and the loaded test icon font removes placeholder glyphs. Arabic religious text remains RTL. Also inspected the tahlil capture with selected target 10, visible **1 / 10** after one tap and separate alternatives/timing notes, and the bad-dream capture with **0 / 1**, its Muslim citation and the explanation that this acknowledges guidance rather than repeating the hadith. These isolated reader captures supplement actual native home screenshots; they are not qualified proofreading.

The Android smoke job reports one debug-emulator relaunch wait timeout, followed by successful foreground-content assertions for every required view; normal cold launches report approximately 12–16 seconds on that emulator. Do not treat this as release performance evidence. `flutter doctor` host warnings and Node 20 deprecation warnings (runner forced Node 24) remain in logs; the final workflow has **zero error annotations**. Physical-device and release QA remain below.

The browser rejected the artifact-download action through its URL security policy. No bypass was attempted; the APK is provided through the verified GitHub Actions artifact, not falsely claimed as attached locally. Artifacts retain for 14 days. Debug signing is for testing and is not a stable production update identity.

## Previous successful content build — run 42


Full fresh workflow: https://github.com/Hmx77/Wird/actions/runs/38532717056

Revision: `9496cdf62c44b6c8eabb3def113bdad122cbdc59`, branch `redesign/premium-20261013`.

49 category entries: morning 18, evening 15, bedtime 16. All 66 supplied reference screens compared; 17 withheld pending religious review. 36 distinct full Arabic bodies, 35 explicitly defined underlying units. Full Al-Mulk contains all 30 verses. All 19 legacy IDs, original logo, ten themes and premium layout retained. No audio added.

## Executed checks

- Android Ubuntu 24.04, Flutter 3.35.7 / Dart 3.9.2, Java 17: dependency resolution, zero formatter changes, content checker, brand renderer (one test), static policy check, zero analysis issues and **all 36 automated tests passed**.
- iOS macOS 15 ARM64, Xcode 26.3 / CocoaPods 1.17.0: dependency resolution, zero formatter changes, content checker, brand renderer (one test), static policy check, zero analysis issues and **all 36 automated tests passed**.
- `flutter doctor -v` executed on both hosts. It reported non-target host gaps: Android licenses for newly preinstalled preview SDKs / missing Android Studio, and missing Linux desktop GTK/driver tooling on Ubuntu. This is not represented as an entirely clean doctor result. Android uses preinstalled API 36; iOS uses the selected Xcode.
- Metadata firewall was installed before Flutter startup, and app verification/build tools ran with a clean allowlisted environment. No cloud metadata access or credential exposure was authorized.

## Fixed failures

- Run 38 stopped at two `avoid_relative_lib_imports` infos in CLI tools. Replaced with package imports; strict analysis then passed.
- Run 39: 28 tests passed, eight failed. Two legacy flow assertions assumed the old first reader ID; six new tests selected the internal EditableText instead of SelectableText. Updated flow expectation to the actual first admitted entry and matched the typed Arabic widget explicitly.
- Run 40: 33 passed, three failed. Long-reader scroll gestures selected the internal selection viewport, and the previous assertion correction accidentally touched a fixed legacy favorite fixture.
- Run 41: 35 passed, one failed. Correct page scrolling passed all new reader tests; restored the legacy favorite fixture assertion.
- Run 42: all 36 tests passed independently on both hosts. No test disabled or skipped to bypass a failure.

## Native build and artifacts

- iOS job **succeeded in 10m 37s**. Unsigned release device build produced `build/ios/iphoneos/Runner.app` (31.7 MB); simulator debug build also succeeded. iOS 26 iPhone 17 Pro installation and launch returned process 16555, captured `ios-home.png` and passed the native fatal-error scan. This is not an IPA signed for device distribution.
- iOS verification artifact: `11879601334`, SHA-256 `72f096d0a377da43ffb37f59f6e5788decaada06ceeb13b947e6415234c42481`, 6.21 MB. Logs, content reports and screenshots are downloadable from the run.
- Android job **succeeded in 12m 33s**. Gradle `assembleDebug` completed in 556.6 seconds and produced `build/app/outputs/flutter-apk/app-debug.apk`. A Kotlin daemon initial-start warning recovered automatically; the successful build is evidenced, without hiding that warning.
- The upload step confirmed **one file**, using the configured exact APK path. `wird-debug-apk` artifact ID **11880045350**, ZIP size **84,873,096 bytes** (80.9 MiB displayed), SHA-256 **606923b38e4d0c7991cc57f1eb4990b7a3051340770d9d3ae7ab7fee83142f11**. This is the artifact ZIP digest, not the uncompressed APK digest. It is a fresh build of the 49-entry catalog, not a reused earlier APK.
- Android verification artifact: `11879671632`, SHA-256 `360fdba4b1fda9549e931ec57ba916f9dd0709339a7d3dca4e6096f076f4628f`, 6.01 MB.
- Fresh uncompressed APK transferred by adb: **161,351,228 bytes**. Package installation returned `Success`. Normal, small/large-font and tablet interactive home assertions passed offline. Native job succeeded in 7m 9s, including the fatal runtime scan. Device review artifact 11879812869 (612,656 ZIP bytes), SHA-256 ae3c66fb5a346ab9a32b37ca72728e297fdf976e704d2e0beeb769b6c066629d. Debug emulator `am start -W` reported timeouts on some relaunches; actual visible-home assertions are the runtime evidence, not the timeout status and not a release performance benchmark.

Download while signed in to Hmx77: open the run link above, select **Artifacts → wird-debug-apk**, unzip and install **app-debug.apk**. Artifacts have 14-day retention; the workflow can generate a new test build. The browser's artifact-download action was blocked by its URL security policy; no bypass was attempted and no ZIP/APK is claimed as attached locally.

## Follow-up visual correction

Run 42 completed successfully in 20m 1s, including the review-image commit `0c62dc1e4b4a1e4f7fbfaf4572411f8185daa02c`.

Inspection of the isolated Arabic reader captures established correct full Arabic rendering, numbered Mulk ending and reachable counters. It also exposed reversed numeric fractions under the inherited Arabic direction. The reader position and repetition fraction now explicitly use LTR direction; the surrounding Arabic remains RTL and the premium styling is unchanged. Regression assertions verify both directions. The isolated screenshot fixture also now loads MaterialIcons, as the existing redesign fixture already did, to avoid placeholder glyphs in its test images. This was a test-fixture font issue, not missing icon assets in the installed application.

Fresh follow-up workflow **44**: https://github.com/Hmx77/Wird/actions/runs/38535771707

Revision `e58b8d125e358dcb3f8e8ffc7ef45a0f3a609d05`. Its actual successful checks/build/artifacts are recorded in the final-delivery section above. The older APK is not labelled as containing this final display correction.

## Production gates

Qualified independent religious/Arabic proofreading remains required for the admitted catalog. Seventeen reference screens, additional clauses, disputed repetition counts and benefits remain outside reader/search/share while their source decisions are unresolved. See `CONTENT_VERIFICATION_2026-10-14.md` and the full 66-screen manifests.

Signed Android release APK/AAB require the owner's upload signing configuration. The release workflow is prepared but has not been run without signing. iOS physical-device distribution requires the Apple team, certificates/profiles and matching App Group provisioning. Physical-device reminders, widgets, accessibility, signed upgrades and owner visual acceptance remain release checks. Audio is unavailable until verified redistribution permission and Arabic review are supplied.
