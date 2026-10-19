# Premium Athkar Library and Reader — 19 October 2026

Review build **0.6.3+17**, branch `redesign/premium-reader-20261019`, draft [PR #3](https://github.com/Hmx77/Wird/pull/3), targeting `redesign/premium-settings-20261018`. Nothing has been merged or published.

## Implementation

The real Flutter Library now uses a botanical, architectural header, deep-teal search field, live category count, favorites filter and gold-bordered entry cards. Entry bookmarks work independently of opening a reader. Search still normalizes Arabic diacritics and supports existing English category metadata. Full citations wrap without truncation.

The real Reader uses a manuscript-style teal/cream reading card, fine geometric corners, local botanical atmosphere, gold progress treatment and a circular repetition control. Full selectable Arabic text, citations, evidence/meaning/benefit/timing panels, source links, focus mode, share, font controls, repetition alternatives, Undo, long-press reset, automatic advancement and previous/next navigation retain their existing state logic. Animations honor the system reduced-motion setting. Long passages scroll; they are not images.

Reusable components live in `lib/reading_ui.dart`. `main.dart` retains the public routes and existing state/services. The only change to the approved Home implementation is its Library/Favorites popup Scaffold/AppBar colors, so those routes match the new Library. Home layout, artwork and controls are unchanged. An exact normalization guard checks this limited exception.

No dependency, religious body, prescribed count, source attribution, audio recording or backend was introduced. The existing source-gated catalog remains **49 category entries: 18 morning, 15 evening, 16 bedtime**, including all 30 verses of Al-Mulk. This is not a claim of 49 unique texts or qualified scholarly approval. The existing 17-screen withheld review queue remains excluded from reader/search/share. Existing caution about disputed timing, counts and benefits remains visible in evidence panels. Independent religious/Arabic proofreading is still required before public release.

## Preservation and provenance

- Approved Settings base: `b9612529cc835c788a4874aa8b75ac8a42de0a73`.
- Final app/Android/iOS build source: `57723380107ff0199e3c80afd13ed73e2257278e`.
- Native recheck source: `7d18cf090d2fff759a902368f75b21bf68b54a51`. Comparing Git trees against the build source found **no application, asset, platform or dependency changes**. Only CI/test drivers and saved review images differ; application, assets, platform and dependency blobs match.
- CI preservation checks passed for 22 approved content, rendering, service and asset files, with the exact Home Library route-color exception. Separate native/splash/launcher guards also passed.
- Independently inspected the final APK ZIP: all 12 checked shipped local assets match their approved Git blob hashes, including both logo assets, wordmark, cinematic scene, fonts, botanical and Home artwork, and the gated audio manifest.
- Ten palettes remain available with Stone & Teal default. Arabic and English UI support, local persistence and offline content remain unchanged. Approved splash, launcher, Settings, Nawafil and sujood rendering files remain protected.
- Cloud metadata is blocked before tool startup; Flutter/build commands run in a clean environment. No signing credentials or account secrets were accessed or added.

## Executed verification

| Check | Actual result |
| --- | --- |
| Android dependency resolution, doctor and static/content checks | Passed in build #112 |
| Android Flutter analysis | Passed, no issues |
| Android app tests | **114 passed**, including 24 Library/Reader tests |
| Separate Android branding test | **1 passed** |
| macOS dependency/static/content checks and analysis | Passed, no analysis issues |
| macOS app tests and separate branding test | **114 + 1 passed** |
| Ten themes × Arabic/English at 320 logical pixels and 200% text | All 20 layout tests passed |
| Exact source-text binding | All 49 entries passed; large Al-Mulk at 38px and 200% text reached its counter |
| Widget interactions | Search, favorites, route, count, Undo, restart persistence, navigation, fonts, evidence, allowed-count menu and automatic advancement passed |
| Android debug packaging | Passed; installable multi-ABI APK produced |
| iOS unsigned device build | Passed, Runner.app 41.4 MB |
| iOS simulator build/install/launch | Passed on iOS 26; actual Home capture saved |
| Final Android native interaction recheck | Home/Settings passed in #113; focused #115 passed Library, Reader, count/Undo/restart/navigation/evidence, all 30 Al-Mulk verse markers, 150% text, reachable counter, small/large-font and tablet checks; no fatal runtime errors |

Full build/test logs and rendered captures: [build #112](https://github.com/Hmx77/Wird/actions/runs/39261132223). Its Android and iOS jobs succeeded. The overall run was canceled after both build jobs because the native test selectors had been superseded. The final native recheck uses the identical built APK and a driver-only correction; #112 is not reported as an entirely successful workflow.

Native checks: [run #113](https://github.com/Hmx77/Wird/actions/runs/39262974186), followed by the explicit [focused Reader recheck #115](https://github.com/Hmx77/Wird/actions/runs/39265460158), reusing the exact APK from #112 rather than rebuilding unchanged application code. Native Android runs with Wi-Fi/mobile data disabled. iOS native testing covers installation/launch/Home only; Library/Reader native iOS interactions have not been exercised. Their widget tests did run successfully on macOS.

## Actual renders and before/after

| View | Capture |
| --- | --- |
| Library before | [Build-16 Library fixture](review-images/library-before-build16.png), rendered from the original Flutter implementation in a test-only fixture |
| Reader before | [Actual build-16 Flutter render](review-images/reader-before-build16.png) |
| Library after | [Real Flutter render](review-images/library-premium-ar.png) |
| Favorites | [Real Flutter render](review-images/library-premium-favorites.png) |
| Reader after | [Real Flutter render](review-images/reader-premium-main.png) |
| Expanded evidence | [Real Flutter render](review-images/reader-premium-evidence.png) |
| Counter and controls | [Real Flutter render](review-images/reader-premium-counter.png) |
| Large Al-Mulk | [Real Flutter render](review-images/reader-premium-mulk-large.png) |

These are unretouched application renders, not generated mockups. Visual inspection confirmed the deep-teal/gold palette, botanical header, architectural curve, rounded fine-border cards, cream Arabic text and working visible counter. Reference proportions were adapted to preserve complete source text and accessibility rather than crop content to the mockup's length. Actual Android #113 captures confirm the same design, readable selected favorites, expanded evidence, 1/3 counting and 2/3 after a process restart. Actual #115 large Al-Mulk and counter captures were inspected successfully. The combined suite now has successful evidence for every scoped check; #113 remains recorded as a failed workflow because its offscreen-title assertion failed.

## Native Android evidence

[Successful focused run #115](https://github.com/Hmx77/Wird/actions/runs/39265460158) and its review-assets job both passed. Its retained `recheck-scope.txt` explicitly records that Home/Settings interactions were not repeated. Those same-APK regression checks passed in #113. The final Library/Reader captures below are from #115; restored Settings/Nawafil captures in the same folder are from #113 on the identical #112 APK.

| View/check | Actual capture |
| --- | --- |
| Library | [Android Library](review-images/android-native/android-library-premium.png) |
| Search | [Evening search, 15 entries](review-images/android-native/android-library-search.png) |
| Favorites | [Independent bookmark and 1-entry filter](review-images/android-native/android-library-favorites.png) |
| Reader | [Complete selectable passage](review-images/android-native/android-reader-main.png) |
| Evidence | [Expanded information](review-images/android-native/android-reader-evidence.png) |
| Count/Undo | [Counter at 1/3](review-images/android-native/android-reader-counter.png); native assertions also verified Undo to 0/3 |
| Restart | [Counter at 2/3 after restart](review-images/android-native/android-reader-persisted.png) |
| Full Al-Mulk | [Main view](review-images/android-native/android-reader-mulk.png), [150% text](review-images/android-native/android-reader-mulk-large.png), [reachable full counter](review-images/android-native/android-reader-mulk-counter.png) |
| Responsive Home regression | [Small/large font](review-images/android-native/android-small-large-font.png), [tablet](review-images/android-native/android-tablet.png) |

Native #115 confirms `passed: true`, offline mode, 49 Library entries, Evening search 15, Bedtime search 16, favorites 1, the count sequence 1/3 → Undo 0/3 → 1/3 → process restart → 2/3, previous/next navigation, evidence expansion and long-passage scrolling. All 30 Al-Mulk verse markers were exposed in order. Cold-launch frame guard passed with 0.0s flat intervals and 45 cinematic candidate frames; this is regression evidence, not a redesign of the approved splash.

[Android test/build report](https://github.com/Hmx77/Wird/actions/runs/39261132223/artifacts/12190917895) · [iOS test/build report](https://github.com/Hmx77/Wird/actions/runs/39261132223/artifacts/12190873571) · [Native screenshots, startup video, scope and interaction JSON](https://github.com/Hmx77/Wird/actions/runs/39265460158/artifacts/12192208626).

## Debug APK

[Download verified `wird-debug-apk` from successful run #115](https://github.com/Hmx77/Wird/actions/runs/39265460158/artifacts/12192697789). The artifact contains exactly **`app-debug.apk`**. Verified ZIP SHA-256: `7adc4fb136c7e422de33eadb49440c936e85f6e68e2ecdf606f4516a01cf851d`.

APK SHA-256: `9703562bacba4cfa7448a017505d1f29c531f879ed11a878970e8f43d4eb83e6`; **168,550,874 bytes**; `arm64-v8a`, `armeabi-v7a`, `x86_64`. Artifact retention is 14 days. This is a debug review APK, not a signed production release. The complete #115 ZIP was downloaded and digest-checked; its single APK is byte-for-byte identical to the #112 built/tested APK. Both ZIPs were independently checked.

The runner-generated debug certificate differs from build 16. The embedded **public** certificates were compared; no private key was read. Consequently build 17 cannot update build 16 in place. Do not uninstall an existing installation casually: uninstalling can erase its saved progress/preferences. Stable owner-controlled signing is required for reliable future updates. See [certificate and asset verification](reader-debug-signing-check.json).

## Earlier failures and corrections

- #101: new widget tests failed because they queried lazy-list children before scrolling them into view. Existing 90 app tests passed. Corrected traversal.
- #102: 113 tests passed; one remaining previous-button lookup needed the same reveal helper. Corrected it. The initial screenshot harness also needed real bundled fonts and a repaint before capture; actual final captures now contain Arabic glyphs and a visible counter.
- #103: analysis and 114 app tests passed; packaging was canceled for the necessary Home Library route-color correction.
- #104: Android/iOS builds and tests passed. New native Library test could not find the search field because Android exposes its prompt as `hint`; corrected the driver to read it and wait for actual focus.
- #105, #108, #110 and #114: automatic draft-PR workflows were action-required and did not execute. They are not test results.
- #106: final Android/iOS jobs passed; old search target failed and the stale gallery commit was correctly blocked.
- #107: native search passed, but a broad `المفضلة` match selected the entry bookmark again instead of the favorites filter. Saved XML showed the unchanged 49-item filter and unselected bookmark. Corrected to an exact filter match and class-specific reader-row target. No production code was changed for these driver fixes.

- #109: favorites, entry routing and expanded evidence were captured successfully. The driver then excluded the fully visible Next button at `[47,2164][260,2290]` because its inherited 89%-height cutoff was intended for screens with bottom navigation. Reader footer buttons now use a bounded 98% cutoff, still requiring valid on-screen bounds. A replay against the actual failure XML selected the correct Next center; the driver passes Python compilation. Evidence matching was subsequently refined to its observed combined accessibility node, and explicit stage logs were added. Production source remains unchanged.

- Visual review after #109 found poor contrast in the selected favorites filter: its translucent color allowed the light Material chip theme to show through. The selected state now explicitly resolves to opaque gold with dark-teal text/icon. A 4.5:1 contrast assertion was added to the existing live favorites interaction test. Both platform build jobs passed in #112; earlier #106 APKs are intermediate evidence, not the final corrected deliverable.

- #111: a stricter exact meaning-heading query failed because Android merges the full evidence card into one accessibility node. The XML confirms that the panel was open with its complete text. The final driver matches its observed `المعنى` prefix and excludes the toggle. Replaying the actual failure XML selects both the evidence panel and Next button correctly.
- #112: the corrected production UI passed all 114 app tests, branding, analysis, Android APK packaging, unsigned iOS device/simulator builds and iOS simulator install/launch. Its obsolete native driver was superseded; cancellation was requested after both successful platform jobs and the overall run is cancelled.

- #113: Home/Settings offline checks, Library search/bookmarks, evidence, count/Undo/restart and previous/next navigation passed. It reached Al-Mulk correctly at 12/16; Android exposed its full SelectableText with all 30 ordered verse markers, while the title was offscreen. The driver failed its title-only assertion. The corrected check requires the actual category position and all 30 ordered markers, without relying on an offscreen title. Replaying #113 XML passed.
- #115: **passed**, explicitly focused native Reader recheck on the unchanged #112 APK. It repeats cold/warm launch, Library/Reader interactions, large Al-Mulk, small/large-font and tablet checks. Already-passed Home/Nawafil/Settings interactions are reported from #113, not claimed as repeated in this focused run. Full native verification remains the default; the focused flag requires an explicit existing APK. Python compilation, shell syntax, workflow YAML and actual-XML selector/verse-marker replays passed locally.

The final review commit also restores the exact CI-tested formatted `reading_ui.dart` and `reading_premium_test.dart` from the successful #112 report, and saves these reports plus original before/after evidence. No further application behavior was changed after verification.

## Remaining release work

Qualified Arabic/religious proofreading, licensed reviewed recordings if audio is desired, stable Android release signing, Apple team/App Group signing and physical-device validation remain outstanding. Notification permission/time persistence is covered by existing native tests; actual delayed notification delivery on physical devices is not claimed. Repository visibility was observed public and is left unchanged under the current restriction. No merge or store publication is authorized or performed.
