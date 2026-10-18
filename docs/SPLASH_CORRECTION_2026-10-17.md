# Cinematic opening correction — Android build 0.4.0+11

The splash uses the approved arch/mosque/lantern background and a transparent cream/gold wordmark mechanically extracted from the approved artwork, preserving its original calligraphy, leaf and kasra. WIRD and ذِكْرٌ يُرَافِقُ يَوْمَكَ remain real text. Both original logo files and the launcher artwork are unchanged.

## Implementation

Android's main host draws a native cinematic ImageView before creating its FlutterFragment. It retains the scene in that same window while the engine starts. The fragment uses texture rendering, registers the app's generated plugins, and forwards lifecycle, permission and intent events. A short translucent entry activity suppresses the disconnected OS icon preview; the functioning host remains opaque. Widget and notification routing are retained.

Crucially, **both drawable/launch_background.xml and drawable-v21/launch_background.xml now use the cinematic scene**. The overlooked API-21 resource previously overrode the corrected base resource and exposed the old centered square icon during the native/Flutter handoff. Build 10's recording revealed this even though its tests and weaker frame check passed. Build 11 corrects that override.

Flutter precaches artwork before releasing its first frame and waits for rasterization before allowing the opening to exit. The 1,200 ms hold overlaps initialization, followed by a 350 ms dissolve. The functioning home stays mounted underneath. There are no buttons, CTA or required interactions. Reduced motion removes the animated reveal. Returning activation reuses the existing main activity.

The hold and dissolve constants do not establish total cold-launch time: debug engine startup and hosted-emulator latency can exceed 1.8 seconds. Physical-device profile/release timing remains unverified.

## Verification

Android build 11 workflow: https://github.com/Hmx77/Wird/actions/runs/39100695318

Source: `3891f034ceedc2ffd2b5e984a1c968d797283106`.

All four jobs passed: Android, iOS, Android device and review assets. Android and macOS each completed dependency resolution, static analysis (no issues), 40 app tests and one separate branding-render test. Android debug packaging succeeded; its APK was installed on a fresh Android 36 emulator. iOS unsigned device and simulator builds succeeded, followed by iOS 26 simulator installation, launch and actual home capture. This is a fresh build-11 iOS execution, not reused build-10 evidence.

- [Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39100695318/artifacts/12126820970): artifact contains `app-debug.apk`, uploaded from Flutter's exact output path. Artifact ZIP is 91,453,577 bytes and expires 1 November 2026. Its digest is `sha256:a2bd660d5d9352300843eb600c38dbc2fd964e55214d05c08c165d4459b7f80a`. The browser's artifact download handoff timed out here, so no local APK download is claimed; CI installation and the artifact metadata/UI were verified.
- [Android native recording and reports](https://github.com/Hmx77/Wird/actions/runs/39100695318/artifacts/12125699898).
- [Android verification logs](https://github.com/Hmx77/Wird/actions/runs/39100695318/artifacts/12126781255).
- [iOS verification logs and captures](https://github.com/Hmx77/Wird/actions/runs/39100695318/artifacts/12127150155).
- [Actual launcher-tap-to-home MP4](review-images/android-native/startup.mp4), [opening screenshot](review-images/android-native/opening.png), [home screenshot](review-images/android-native/home.png), [workflow/artifact proof](wird-build11-success.jpg).

The recording and native captures are also preserved in Git at `36a7ac91017bc68cbc6d5aed8eb24600ff4488ad`. Human inspection confirms the refined wordmark, cinematic scene and functioning home. The sampled frame guard found zero unexpected intermediate icon/blank frames. A separate local decode inspected all 57 encoded frames and found no flat frames or unexpected frames after the scene began; [encoded-frame report](review-images/android-native/encoded-frame-review.json).

The recorded state changes were launcher at 0.000 s, cinematic scene at 3.486 s, home at 7.487 s. Thus the scene remained visible about **4.0 seconds** on this cold debug emulator run. The desired 1.2–1.8-second total launch has **not** been demonstrated and is not marked complete. Variable-frame-rate emulator capture cannot establish smooth physical-display motion or production timing. The old separate icon screen is absent from this recording; this is evidence for the tested environment, not every Android device.

Offline radio state, warm launcher activation with one reused main activity, small-screen large-font and tablet home captures passed; no fatal runtime errors were found. Initial launcher/home readiness assertions were retried successfully within their existing bounded polling loops. Non-fatal GitHub Actions annotations report forced Node 24 execution of Node-20-targeting action versions and macOS runner capacity; all jobs still completed successfully.

Local shell syntax and Python compilation passed. The strengthened recording check was executed against the **actual rejected build-10 MP4** and correctly rejected the icon interval at recording seconds 7.2–7.9. It compares each sampled frame (100 ms intervals) against cinematic and actual home references, rejects unexpected intermediate frames, and requires the recording to end on home. This supplements human visual review; it cannot certify every unsampled display frame or all physical devices.


## Preservation and limits

Athkar and Quran files, ordering, 49 category entries (18 morning, 15 evening, 16 bedtime), all ten themes and Stone & Teal default, home layout, saved preference keys, counters, bookmarks, reminders, widgets and offline behavior remain preserved. No recordings were added and audio remains unavailable without licensed and reviewed files. No qualified religious approval is claimed. No merge into main or store publication occurred.

Release signing, Apple provisioning, qualified religious proofreading, physical-device motion and the 1.2–1.8-second launch target remain open requirements. The source version is aligned at 0.4.0+11 for app and widget. Run 39100582455 was cancelled before completing after detecting that the initial version increment also needed the widget build number aligned; it is not a passed run. Flutter doctor reports hosted-runner environment limitations; successful platform builds do not mean every doctor category is green. Metadata blocking and clean-environment tool startup remain enabled.

## Rejected attempts retained for traceability

- Build 6: good background but pasted square logo and disconnected native opening; superseded.
- Build 7 / run 39048166152: technical checks passed, actual cinematic scene skipped; rejected.
- Build 8 / run 39049669817: native guard rejected a 3.8 s flat gap; rejected.
- Build 9 / run 39051121992: native guard rejected a 2.5 s blank gap; unsigned iOS builds/tests passed but simulator launch timed out; rejected. An early color-only classifier could mistake launcher icons for the scene and was replaced with reference correlation.
- Build 10 / run 39053717982: analysis, 40 tests and brand rendering per host, Android package/offline native checks and iOS unsigned builds/simulator launch passed. Human review still found the old icon at the handoff, so visual acceptance failed. The stronger build-11 guard now detects this real regression.

Evidence for rejected build 10 is preserved at commit `830faa3ecb76d83e28177987f7a30b1f8de5f6b3`, including docs/review-images/android-native/startup.mp4 and sampled PNGs. It must not be presented as proof of a seamless accepted launch.
