# Botanical Serenity — Sunnah and Nawafil review

Review build: **0.6.1+15**. Branch: `redesign/refined-20261015`. Draft review: https://github.com/Hmx77/Wird/pull/2 . No merge or store publication is authorized or performed.

## Implementation

The former white checkbox list is replaced by live, responsive Flutter components in `lib/nawafil_ui.dart`: a botanical sunrise header, a gold-edged rawatib summary, custom accessible checked rows, a separate source/context card and three other voluntary-prayer rows. The bottom navigation is preserved; the Nawafil tab now uses light status icons and the same dark surface as the approved Home. The existing corrected filled sujood path is reused in the header, night-prayer row and unchanged navigation.

The five existing rawatib booleans and date-qualified saved IDs are unchanged. The existing groups-completed count remains visible. A derived rakah indicator sums the checked groups' existing 2+4+2+2+2 values out of 12; it does not introduce partial-rakah recording or alter tracking semantics. Duha, Witr and Qiyam remain independent and do not affect that ring. This is optional personal tracking, not a measure of reward.

All four religious notes/references, every prayer name, rakah value and saved key are copied verbatim from the existing page. No quotation, new religious ruling, repetition count or audio recording was added. The note is displayed as existing explanatory prose, not recast as a verbatim hadith quotation. The reference image's additional religious wording/count ranges were deliberately not imported.

Only one new original local artwork asset is used: `assets/home/botanical-serenity.webp` (1200×800, 83,140 bytes). It was created with the built-in image-generation tool for this project and optimized to WebP. See `nawafil-artwork-provenance.json` for its prompt/provenance and SHA-256. No third-party photo or recording was substituted. Text and interactive elements are real widgets; no reference screenshot is embedded in the screen.

The approved opening, launcher, Home implementation and religious catalog are unchanged. The native/widget version is aligned at 0.6.1+15. Existing ten palettes tint the shared dark surface; Arabic and English UI and Arabic source-text direction remain supported. Controls expose checked semantics and a whole-row tap target. Reduced-motion settings remove the checkbox color transition. Long content expands vertically rather than truncating.

## Final verification

Final source: `e63ab89abc7139548a1a80fd998228be654d5320`.
Final Android run: https://github.com/Hmx77/Wird/actions/runs/39121693620 . Android build job `117658423529` and emulator job `117659932323` succeeded.

| Check | Actual result |
| --- | --- |
| Flutter dependency resolution and content/static checks | Passed |
| Flutter analysis | No issues on Linux and macOS |
| Automated app suite | 66 tests passed on each host; includes all ten themes, Arabic/English at 200% text on a 320px viewport, state restoration and numeric direction |
| Separate branding test | Passed on each host; approved native assets restored before packaging |
| Android debug packaging | Passed; `app-debug.apk` uploaded as `wird-debug-apk` |
| Android 36 emulator | Passed offline launcher/startup guard, warm activity reuse, categories/shortcuts/navigation, prayer checks and persistence, Home small/large-font/tablet captures; no fatal runtime errors |
| Native rawatib tracking | Fajr checked: 2/12 and 1/5; same state observed after force-stop/relaunch; then unchecked back to 0/12 |
| Other prayers | Duha, Witr and Qiyam each toggled on and off with checked accessibility state assertions |
| Approved opening/launcher source | All 51 locked Git blobs unchanged; independently compared against final evidence commit |
| Religious text | Catalog hashes unchanged; all four original Nawafil religious notes/references remain verbatim |
| iOS unsigned device build | Passed, 41.1MB Runner.app |
| iOS simulator | Passed on fresh macOS retry: simulator build, install, native launch and screen capture; no fatal runtime errors detected. The first launch command stalled, and its existing bounded second attempt succeeded. |

The initial build-15 iOS job passed analysis, 66 app tests, the branding check and the unsigned device build. After the Xcode simulator build finished, Flutter's rsync packaging copy failed with `Input/output error` while writing `Flutter.framework`. The failure is retained in the main run. Fresh macOS retry on the exact same app source: https://github.com/Hmx77/Wird/actions/runs/39122416227 . That iOS job succeeded, including analysis, all 66 app tests, the separate branding test, both unsigned builds, simulator install/launch and screen capture. The first simulator launch command stalled for its bounded 180 seconds; the existing second attempt succeeded. No app code, isolation or account access was changed for either retry. [iOS reports and simulator captures](https://github.com/Hmx77/Wird/actions/runs/39122416227/artifacts/12135247721) are available. The iOS-only retry intentionally skipped Android and gallery jobs; Android results belong to the main final run.

Download [wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39121693620/artifacts/12134501811); extract `app-debug.apk`. The artifact was observed available and unexpired; GitHub reports 91,877,288 bytes for the ZIP. [Android verification reports](https://github.com/Hmx77/Wird/actions/runs/39121693620/artifacts/12134631501) and [native screenshots, recording, accessibility dumps and interaction JSON](https://github.com/Hmx77/Wird/actions/runs/39121693620/artifacts/12134572217) are also available.

### Inspected Android captures

- [Full header and main rawatib screen](review-images/nawafil-header-build15.png).
- [Header close-up](review-images/nawafil-header-closeup-build15.png).
- [Rawatib progress close-up](review-images/nawafil-rawatib-progress-closeup-build15.png) and [all five prayer rows](review-images/nawafil-rawatib-rows-closeup-build15.png).
- [Source-note close-up](review-images/nawafil-source-note-closeup-build15.png) and [full source-note screen](review-images/nawafil-note-build15.png).
- [Other-prayers close-up](review-images/nawafil-other-closeup-build15.jpg) and [screen preview](review-images/nawafil-other-build15.jpg). This JPEG is a browser capture of the actual Android screenshot; the [original full-resolution PNG](https://github.com/Hmx77/Wird/blob/8051c5d6ca6b4941395ac4db405e507513ec53d0/docs/review-images/android-native/android-nawafil-other-prayers.png) remains in the immutable native gallery.
- Checkbox proof: [before](review-images/nawafil-checkbox-before-closeup-build15.png), [checked after process restart](review-images/nawafil-checkbox-persisted-closeup-build15.png), [full persisted state](review-images/nawafil-persisted-build15.png).
- [Actual navigation-size sujood icon](review-images/nawafil-sujood-navigation-closeup-build15.png).

The close-ups are exact crops of actual captures. No rendered text, icon, checkbox or other UI content was retouched. Header foliage/sunrise, cream/gold hierarchy, subtle borders, five rawatib rows, readable complete note, other prayers and the filled sujood icon were visually inspected against the supplied botanical reference. The app remains a live Flutter screen. The corrected group fractions and citation range were inspected in the build-15 captures.

Numeric fractions and citation ranges use Unicode left-to-right isolation only at rendering time. This fixes the visually reversed Arabic group fraction and 1180–1181 range while retaining the exact underlying religious strings and references. Both Arabic and English localization are applied before numeric isolation.

## Executed earlier checks and corrections

- Platform run https://github.com/Hmx77/Wird/actions/runs/39109673004 tested build 0.6.0+14 (`a65722fbaeaafc4d71b463372e0c15ebb1fef143`). Dependency resolution, content/static validation, analysis with no issues, 65 app tests and one separate branding test passed on Linux/Android and macOS/iOS. Android debug packaging, unsigned iOS device and simulator builds, and an iOS 26 simulator launch to real Home succeeded.
- The first implementation run https://github.com/Hmx77/Wird/actions/runs/39109420017 passed analysis but failed 20 new large-text cases: the summary ring and other-prayers heading overflowed. Both layouts were corrected; all subsequent 65 app tests passed without weakening those cases.
- The build-14 platform run's native Android job reached Home, but a fixed 12-second recording ended too soon on the slow fresh emulator. The strict frame guard failed. Recording now stops after actual Home readiness within a bounded 100-second maximum; the guard remains unchanged.
- Native recheck https://github.com/Hmx77/Wird/actions/runs/39120592197 reached Home, but its guard flagged frames at 10.1–10.3 seconds. Actual frame `android-startup-21.png` showed real Home widgets before illustrations finished decoding. No approved Home or splash source was changed. Independent feature checks now continue after a guard failure, but its nonzero exit is retained at the end; failures are never converted into a green job.
- Build-14 native run https://github.com/Hmx77/Wird/actions/runs/39121005544 passed the unchanged strict opening guard and all device checks. It installed the existing APK on a fresh offline Android 36 emulator, tapped the actual launcher icon, verified one reusable Flutter activity, exercised all categories/shortcuts/navigation, toggled rawatib progress 0→2→0, confirmed persistence after a true process restart, toggled Duha/Witr/Qiyam on and off, and captured the sections. Small/large-text and tablet Home captures also passed; no fatal runtime errors were found. That native-only run intentionally skipped compilation and reused the prior platform APK.
- Actual build-14 images were inspected. Header, rawatib rows, explanatory note and correct sujood silhouettes matched the botanical direction. The secondary group fraction and one citation range needed numeric direction isolation; this is the sole app-code correction in build 15. A regression case was added; build 15 subsequently passed all 66 tests and its Android native checks. The corrected numbers were visually confirmed in its new captures.

All earlier failures remain inspectable at their run links. The original 51 approved opening/native-launch/launcher files passed the immutability check in the executed platform run. Native candidate assets from the separate branding test were restored to approved versions before packaging.

## Release limits

This is a debug review delivery, not a production release. Apple provisioning/signing and physical-device checks remain separate requirements. Existing qualified Arabic/religious proofreading and licensed-audio gates remain in place. No new religious content or recording was introduced.
