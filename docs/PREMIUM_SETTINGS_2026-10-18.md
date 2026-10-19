# Premium Settings — review build 0.6.2+16

Review branch: `redesign/premium-settings-20261018`, based on the approved Home/Nawafil branch at `fbdd7dd113331c2856ca656dcefd59ad238ec6fc`. No merge, store publication or repository-visibility change.

## Actual implementation

The attached “Premium Arabic Islamic App Settings UI(1).png” is the visual reference. This is a real Flutter screen with a compact botanical header, midnight-teal gradient panels, cream typography, restrained gold borders/medallions and light interlaced-square decoration. It reuses the existing original local botanical artwork; no new image, dependency, remote font or recording was added.

The language selector controls the existing Arabic/English preference and direction. Appearance previews open all ten original themes; Stone & Teal remains the default. Reminder controls retain saved times and enablement, the original permission request, daily inexact scheduling, IDs and preference keys. Defaults remain 07:00/18:00/22:00 and reminders remain opt-in. The reader slider retains the 19–38 range and changes the actual reader preference. The live personal counter and its reset use the original Tasbih key; reset affects that counter alone. Haptics and automatic advancement use the existing setters/keys.

The complete original privacy/source/audio-license explanation remains available verbatim in the expandable details section. Software licenses opens the real Flutter license page. Erase requires confirmation and clears only the original activity/favorites/prayer/Tasbih keys, retaining settings and reminders. Its explanation now lists that scope explicitly. Opening or cancelling it does not delete data.

Settings construction is deferred until its first visit. It then remains mounted in the existing IndexedStack, retaining scroll/expansion/control state on later tab visits. This removes the new control panel's layout work from cold launch. Existing local Home images are also precached before the Home reveal, fixing the intermittent interval where controls appeared before artwork decoded. Approved opening/Home/Nawafil renderer files, layouts, artwork and animations remain unchanged. The personal-counter medallion reuses the approved bead painter.

The reminder service now loads the complete existing package's bundled timezone dataset, covering valid device aliases offline, and emits initialization diagnostics only in debug builds. Settings distinguishes initialization failure from denied permission. No prayer-time calculation, UTC fallback, scheduling rule or delivery-mode change was introduced. Alias support is separately tested; it is not claimed as the proven cause of the earlier emulator permission warning. Package documentation explains the reduced/default dataset: <https://pub.dev/packages/timezone>.

## Preservation

The approved Home renderer, Nawafil implementation, filled sujood icon, cinematic opening, Quran text, religious catalog, widget/audio services and original assets remain unchanged. CI checks all 51 locked opening/native-launch/launcher files and the content audit. No new religious material or audio was introduced. Existing qualified religious proofreading, audio licensing and store-signing release gates remain in place.

## Executed checks

| Check | Actual result |
| --- | --- |
| Flutter doctor and dependency resolution | Executed in GitHub Actions |
| Static/content/native-asset checks | Passed in build #99 |
| Flutter analysis | No issues in build #99 |
| Automated app tests | 90 passed in build #99 |
| Separate branding test | Passed in build #99 |
| Settings layout coverage | All 10 themes × Arabic/English, 320 px at 200% text; no overflow |
| Settings interactions | Theme/language selection, reader font preference, personal count/reset, haptics, auto-advance, privacy expansion, erase cancellation/confirmation and retained erase scope tested |
| Preference persistence | Reopened state restores theme, language, font, Tasbih, haptics and auto-advance; reminder values retained through erase |
| Deferred Settings | First visit opens it; counter and expanded privacy state survive tab changes |
| Reminder clock rules | Year/date rollover, next-day behavior, DST and offline UTC/GMT/named aliases passed |
| Android debug packaging | Passed in build #99; universal APK includes arm64-v8a, armeabi-v7a and x86_64 |
| Strict cold-start frame guard | Passed in #99: 0.0 s flat intervals; 63 cinematic candidate frames |
| Final native Settings checks | Passed in #99: three reminders, 08:15 clock selection and process restart, personal count persistence/reset, haptics, auto-advance, privacy expansion, canceled deletion and real licenses |
| iOS build/runtime for this phase | Not run; no signed iOS claim |

The Settings narrow/large-text checks above are Flutter widget tests. Existing native small/large-font/tablet captures exercise Home; they are not represented as native Settings captures at those sizes. Physical-phone reminder delivery under OEM battery policies is a remaining release check, distinct from scheduling/settings persistence.

## Build and evidence

App source: `06cbb985878f95d7c624b868100b49f6c8ef3778`, formatted by CI before analysis/tests/packaging. The reviewed formatted Settings source is copied back only from a successful matching Android build. A native-only reuse cannot overwrite source from an older APK run.

- [Verification #99: analysis, 90 app tests, branding and APK](https://github.com/Hmx77/Wird/actions/runs/39148494898)
- [Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39148494898/artifacts/12144078020)
- [Actual build/test logs](https://github.com/Hmx77/Wird/actions/runs/39148494898/artifacts/12143883930)

The downloaded artifact contains exactly **app-debug.apk**. APK bytes: **168,540,190**. APK SHA-256: `9e44874a7155bc7222de46fe7ed154b89ae99d9783084acf4e1ced7deff7cc1a`. Its twelve shipped original assets match the approved baseline Git blobs byte-for-byte. Source-only concept artwork remains outside the bundle, as before.

Actual Android captures: [top](review-images/android-native/android-settings-top.png), [middle](review-images/android-native/android-settings-middle.png), [bottom](review-images/android-native/android-settings-bottom.png). Native #99 completed successfully, including offline checks and Home small/large-font/tablet captures. The full #113 native run repeats these preserved Settings interactions. The complete current application also passed unsigned iOS device/simulator builds and iOS 26 launch in #112; native iOS Settings interactions are not claimed.

## Retained failures and corrections

- **#91 (`39140044013`)**: analysis passed; tests caught 200%-text reminder-control overflow, obsolete ListView navigation selectors, a lazy-theme-selector assertion and a test-only `bedtime` key instead of the existing `sleep` key. Fixed without changing stored IDs or relaxing overflow checks.
- **#92 (`39140389035`)**: 87 app tests passed; one time-picker test matched a fixed Arabic cancellation string. It now reads the actual Material localization label.
- **#93 (`39140728215`)**: 88 app tests/branding/Android packaging passed; native reminder enablement showed a permission warning. Later device checks explicitly verify both OS notification permission and AppOps before testing switches. A separate timezone-alias compatibility improvement remains covered by its own test.
- **#94 (`39141476225`)**: CI mistakenly analyzed copied Dart report files as source. Report copies now use `.txt`; application analysis was not excluded or relaxed.
- **#95 (`39142514997`)**: 89 app tests and packaging passed. Native capture flagged 0.5 s of Home controls before illustrations decoded, then the Nawafil destination was not reached after counter-sheet dismissal. The device test now waits for the sheet to finish dismissing.
- **#96 (`39144064986`)**: three reminder switches enabled with verified OS permission. The test produced invalid time input while editing and using RTL semantic field order. The app correctly rejected it. A 0.2 s illustration-decode interval was also retained as a startup-guard failure.
- **#97 (`39145094161`)**: deferred Settings construction passed 90 app tests and resolved the observed startup guard failure in this run. Native time fields contained 8/15 but were targeted in reversed semantic order, making the hour 15 in a 12-hour input. The app correctly rejected it. The test failure was retained; exact numeric counter matching was also added.
- **#98 (`39147094925`)**: native-only reuse of #97 retained another 0.2 s Home image-decode interval. Keyboard selection did not clear the old hour reliably (78 instead of 8), so the test correctly stopped. #99 instead selects the visible clock dial and waits for local Home artwork before reveal. No input-validation rule or startup guard was weakened.
- Earlier failures remain visible in their original Actions runs. No failing native result is relabeled as a pass. Runtime diagnostics redact local debug-service URLs.
