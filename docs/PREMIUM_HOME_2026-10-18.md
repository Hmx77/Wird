# Premium Home — Option A / Bento + Category Grid

Review branch: `redesign/refined-20261015`. Approved opening baseline: `14f4444f7ae44cd19ce01d3783e2cd3921f42573`. Initial home implementation: `594466361f22d92eae24099006470fa977406d6e`.

Initial workflow: https://github.com/Hmx77/Wird/actions/runs/39102571721 . Results remain pending until execution and actual Android screenshot inspection. This document must not be interpreted as a passed build report before those results are recorded.

## Layout and live behavior

| Reference element | Flutter implementation |
| --- | --- |
| Teal scenic header | Original transparent wordmark with its existing kasra; live Arabic/English heading and tagline, mosque scenery, working settings/search controls. |
| لحظات من السكينة | Original local arch/lantern illustration with real daily completed-entry progress (out of 49). Tapping resumes a partially read entry today, otherwise the first unfinished entry in a time-appropriate collection. This is a convenience default, not a new religious timing claim. |
| Morning/evening pair | Two illustrated live reader links in RTL order, morning at right: 18 and 15 entries respectively. |
| Bedtime | Full-width original night-oasis illustration; 16 entries, real progress and reader link. |
| Four shortcuts | Actual favorites count, Nawafil tab, persistent personal tasbih counter, all-collections tab. No invented demo counts. |
| Bottom navigation | Rounded teal navigation surface, restrained gold active styling, cream labels, filled prostration vector traced from the owner's supplied reference. |

Cards use content-driven heights, live text and responsive Flutter layout. Category cards stack and shortcuts reflow to two columns at larger accessibility text scales. A scrollable layout keeps every destination reachable on small phones. Both Arabic RTL and English LTR are supported. Decorative imagery is excluded from accessibility semantics; controls and progress remain accessible.

The reference's decorative Quran line has not been introduced as new religious content. Existing Quran/Athkar text, source references, ordering and counts are unchanged. There is no new audio.

## Artwork and icon provenance

Four original scenery images were created with the built-in image-generation tool specifically for this home. They contain no text, UI labels, logos, phone frames, people or third-party recordings. They are bundled in `assets/home/` as optimized WebP files, approximately 300 KB total, with exact dimensions and hashes in `home-artwork-provenance.json`. No network image loading or backend was introduced.

Prompt set: cinematic painterly-realistic sunrise mountain mosque valley in deep teal/gold; sunset lake mosque with amber sun and indigo mountains; panoramic midnight mosque oasis with crescent and palm silhouettes; arch and lantern on the left with dark engraved teal wall on the right for live labels. All prompts require no text, logos, UI, people or watermark. Existing logo/splash artwork was not generated again for this design.

The Nawafil icon is a filled even-odd vector derived mechanically from `IMG_0194(1).jpeg`, the owner-supplied prostration silhouette. It preserves the tucked knees, rounded back, grounded head and internal cutouts. The icon renders at 28 logical pixels in navigation and 42 in the shortcut; actual-size render and device navigation captures are required for review.

## Preservation

`approved-opening-lock.json` records Git blob hashes for 51 approved opening/native-launch/launcher files. CI checks committed source before formatting. After the existing brand-render regression test, CI restores approved committed PNGs before packaging, so test-generated candidates never replace the accepted splash or launcher images. The approved cinematic Dart source, native entry/host, Android launch styles/resources and iOS LaunchScreen source are unchanged by this phase.

All ten existing themes and default index 8 (Stone & Teal), counters, bookmarks, preference keys, stored history, notifications, widgets and offline services remain. App and widget version metadata are aligned at 0.5.0+13. No merge into main, store publication or visibility change is part of this task.

## Verification to record

- Flutter dependency resolution, analysis, full regression suite and branding test.
- New Arabic/English home-route, counter persistence, partial-reading resume, progress update and actual-size silhouette tests.
- Existing all-ten-theme tests at 200% text in Arabic and English and small/tablet layout tests.
- Actual Android cold/warm launch and offline home captures, category/shortcut navigation, small-screen large-text and tablet captures.
- Actual screenshot comparison with the approved image; any proportion or typography corrections must be documented.
- APK artifact `wird-debug-apk`, containing `app-debug.apk`; iOS unsigned build/simulator checks where available.

Physical-device notification/widget behavior, release signing/Apple provisioning, licensed audio supply and qualified religious proofreading remain production gates. This phase does not claim scholarly approval.

## Visual review of build 12

Run 39102571721 passed all four jobs, including analysis, 44 app tests plus a branding test on each host, Android packaging, eight actual offline category/shortcut/navigation checks, responsive native captures, unsigned iOS device/simulator builds and iOS simulator launch. Approved opening/source locks passed. The actual Android screenshot at commit bca2179bba32697cc7688998b9b88094a704a220 was compared with the supplied reference. The illustrated bento composition, right-hand morning card, warm cream type, original wordmark and filled sujood silhouette were present. However, the shortcut row was slightly clipped above navigation and decorative RTL arrows were auto-mirrored twice. Build 12 is superseded for visual acceptance.

Build 13 tightens header/progress/bedtime proportions so all normal-size shortcuts fit above navigation, increases shortcut text legibility, places settings/search in reference order, and explicitly fixes icon text direction to prevent double mirroring. New regression assertions check shortcut bottom bounds against the navigation top in Arabic and English, and check arrow direction. The screenshot tests now precache all home artwork before capture. Final run results and actual corrected captures remain to be recorded.

## Build-13 native harness failure

Run 39103633484, app source 630adde4cbd4ba7f0fd50fabe38ea7fea69a0adf, passed Android/iOS analysis, all 44 app tests plus the branding test on each host, Android APK packaging and unsigned iOS device/simulator builds with successful iOS simulator launch. Its Android device step failed before the app became foreground, so this run alone is not accepted as Android visual proof. No app crash diagnosis is claimed: the failed harness did not preserve runtime diagnostics.

The launcher was observed before installing ffmpeg, leaving stale coordinates and a long inactivity interval before tapping; a screen-off/timing issue is suspected. The test harness now keeps its disposable emulator awake and installs capture tooling before observing the launcher. A failed first launch also preserves screen, recording and runtime/window diagnostics. A native-only recheck reuses the **unchanged** build-13 APK and successful iOS evidence from run 39103633484; only the harness changed, and the app/splash code was not rebuilt or altered for this recheck. The first failed run remains recorded rather than being described as passed.

## Final verified delivery — build 0.5.0+13

**Native recheck succeeded:** https://github.com/Hmx77/Wird/actions/runs/39104615496 . It reused the exact app APK from platform build/test run https://github.com/Hmx77/Wird/actions/runs/39103633484 . In the native-only recheck, Android/iOS compilation jobs were deliberately skipped; no fresh build/test execution is claimed for those skipped jobs. The source of the APK is `630adde4cbd4ba7f0fd50fabe38ea7fea69a0adf`; recheck harness source is `753706a37c1df9e1944d6e03b3955789d58488d1`.

| Executed check | Actual result |
| --- | --- |
| Dependency resolution and analysis | Passed on Android/Linux and macOS; no analysis issues. |
| App regression tests | 44 passed on each host, plus the separate one-test branding render. |
| All existing themes and locale layouts | Ten themes × Arabic/English at 200% text; responsive 320/430/1024 logical-pixel cases at 150%; passed. |
| Progress and navigation | New tests cover three categories, search/settings, all four shortcuts, partial-reading resume, real completed-entry progress and personal-counter updates; passed. |
| Shortcut bounds and RTL arrows | Final normal-size Arabic/English assertions passed; corrected actual native screenshot inspected. |
| Preserved opening and content | 51 committed opening/native/icon files checked unchanged; 32 approved PNGs restored before packaging; 49-entry content/source checks passed. |
| Android 36 fresh emulator | Same APK installed offline, first cold launch from launcher icon, real home capture, warm single-activity reuse, eight category/shortcut/navigation checks, enlarged-text small-screen/tablet captures; passed. No fatal runtime errors found. |
| iOS | Unsigned device and simulator builds, iOS 26 simulator installation/launch and actual home capture passed in platform run 39103633484. |

[Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39104615496/artifacts/12127548226) contains `app-debug.apk`. The archive is 91,783,764 bytes and expires 1 November 2026. Artifact metadata and GitHub UI were verified, and CI successfully downloaded and installed this APK. This browser could not complete the artifact ZIP download handoff; no local APK download is claimed.

[Actual native reports and captures](https://github.com/Hmx77/Wird/actions/runs/39104615496/artifacts/12128285524) include the real screenshots, UIAutomator assertions, offline settings, startup recording and runtime checks. Platform logs remain in the Android/iOS verification artifacts in run 39103633484. The earlier native failure is retained above; it is not relabeled as passed.

### Actual visual comparison

The corrected Android capture at Git commit `b4bfb60f95e133664deec8a72ddf1e8a0e0ea1a3` was visually compared with the supplied Option A reference. It has the scenic deep-teal header, original wordmark, arch/lantern progress card, morning-at-right/evening-at-left pair, illustrated bedtime strip, all four fully visible shortcut cards and rounded gold-accented bottom navigation. Every title, count and progress value is a Flutter widget. The scenery is original artwork, not a static screenshot of the mockup. The reference's decorative Quran line and invented sample progress/favorite counts were intentionally not copied. The bedtime content uses a compact horizontal arrangement to preserve the full shortcut row on normal phone screens. Larger accessibility text reflows category cards and shortcuts and remains scrollable. The constrained tablet column has generous surrounding space rather than stretching the phone cards across the full tablet width.

The supplied filled prostration silhouette was inspected at actual navigation size in the native Nawafil-tab capture and in the larger shortcut. It uses the source silhouette with its internal cutouts, not the former stroke approximation. Actual small-screen 150% text and tablet captures were also inspected. Physical-device behavior remains unverified.

- [Final Android home](review-images/home-bento-android-build13.png)
- [Actual small-screen enlarged text](review-images/home-bento-large-text-build13.jpg)
- [Actual selected sujood navigation](review-images/home-bento-sujood-navigation-build13.jpg)
- [Actual tablet home](review-images/home-bento-tablet-build13.png)
- [Successful native recheck and artifact evidence](review-images/home-bento-run-proof-build13.jpg)
- [Real launch movie in the evidence commit](https://github.com/Hmx77/Wird/blob/b4bfb60f95e133664deec8a72ddf1e8a0e0ea1a3/docs/review-images/android-native/startup.mp4)

The phase is implemented and verified for owner review. It remains unmerged and unpublished. Signing/provisioning, real-device notification/widget delivery and qualified religious proofreading remain production requirements. No new audio recordings or religious material were introduced.
