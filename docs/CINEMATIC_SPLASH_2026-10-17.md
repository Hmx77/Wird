# Automatic cinematic opening — 17 October 2026

Review branch: `redesign/refined-20261015`. No merge or store publication.

## Implemented behavior

- Full-bleed, bundled deep-teal arch/mosque/lantern scene inspired by the owner's reference, without baked text or UI. The original approved logo (including its kasra), `WIRD`, and `ذِكْرٌ يُرَافِقُ يَوْمَكَ` are real Flutter widgets.
- No CTA, welcome button, touch hint, tap recognizer, or required interaction. The splash automatically dissolves over the actual functioning `WirdShell` and then removes its overlay while preserving the shell's state.
- Gentle 1.8% background drift and 3% logo scale/fade. A 1.2-second visual hold after initialization is ready, followed by a 350ms dissolve, targets 1.55 seconds for the ready welcome/reveal. OS process/engine startup is additional and device-dependent. If required initialization is slower, keep the branded screen instead of revealing blank content.
- Reduced motion disables scale/drift and uses an immediate automatic reveal after the brief hold. The opening runs once per process launch, never on theme/preference rebuild or returning from another page. No new preference keys.
- Native Android/iOS launch backgrounds match deep teal. Android's mandatory system splash remains OS-controlled; its existing mark and approved launcher icon remain unchanged.
- All existing home UI, 10 palettes, offline services, reminders, saved data and religious content remain unchanged. Audio remains unavailable without licensed recordings.

## Artwork provenance

New asset: `assets/brand/wird_sanctuary_20261017.png`, generated with the built-in image tool for this project. The owner's attached reference supplied mood/composition only; the phone frame, written logo, status bar and touch instruction were not copied into the asset. Original logo files were not edited.

Prompt: cinematic premium portrait Islamic architectural background, pointed arch framing distant mosque/minarets and crescent at blue-hour twilight; deep teal/midnight palm/leaf foreground; warm lanterns and reflective stone path; dark quiet lower-middle space for separate logo/text; full bleed; no writing, logo, phone, borders, status bar, CTA, touch hint or watermark.

## Final executed validation

[Workflow 39018043548](https://github.com/Hmx77/Wird/actions/runs/39018043548) completed successfully on source `c0d269b615dcdae17a3793987cc94b7726d9c5c0`. All four jobs passed.

| Check | Actual result |
|---|---|
| Linux/macOS dependency resolution and analysis | Passed; no analysis issues |
| Automated suite | 40 tests passed on each host |
| Separate branding/rendering test | Passed on each host |
| Content/static policy checks | Passed: 49 entries, 10 themes, exact logo, native manifests, audio/signing gates |
| Android debug APK | Built and installed successfully; version 0.4.0+6, ae.wird.app |
| Android native runtime | Automatic offline cold launch, interactive home, small/enlarged-text/tablet captures and no fatal runtime errors passed |
| iOS | Unsigned device and simulator builds passed; iOS 26 simulator installed/launched the app and captured actual home |

- [Download wird-debug-apk](https://github.com/Hmx77/Wird/actions/runs/39018043548/artifacts/12096165559): contains `app-debug.apk`.
- [Download actual Android recording and screenshots](https://github.com/Hmx77/Wird/actions/runs/39018043548/artifacts/12095708264): contains `startup.mp4`, sampled PNG frames, offline home/launcher/size captures and logs. Recording file pulled from emulator: 2,165,710 bytes. Artifacts expire 31 October 2026.
- [Actual cinematic frame](https://github.com/Hmx77/Wird/blob/ce71efcb634ee39dd0472a17eeb687e112898212/docs/review-images/android-native/android-startup-15.png).
- [Following actual home frame](https://github.com/Hmx77/Wird/blob/ce71efcb634ee39dd0472a17eeb687e112898212/docs/review-images/android-native/android-startup-17.png).

The corrected cinematic frame and following actual home frame were visually inspected. The logo/tagline are fully lit with no debug underlines, and no CTA appears. Sampled frames document the automatic reveal; the full recording is retained in the artifact. A standalone browser download of the media artifact did not complete in this environment; the verified GitHub artifact remains the delivery location. Do not claim a full local video playback inspection.

The complete comparison against baseline `51f375124b05f6007347189a593342c5893e56f6` confirms launcher/AppIcon files and religious corpus files are unchanged. The real home layout, all themes and saved preference keys remain preserved. There is no static home screenshot in the Flutter app assets.

## Corrections and earlier attempts

- Run 39016563628 was superseded after a scene-aware color-check correction. The previous debug-red heuristic detected legitimate lantern pixels; the guard remains on generated brand/icon assets.
- Run 39016690418 passed tests, analysis, Android packaging and iOS runtime, but its native Android recording step stopped before app launch because ffmpeg was absent. The capture script now installs it from Ubuntu's official package repository when missing, with cloud-metadata blocking unchanged.
- Native-only run 39017614442 passed using that APK, but visual inspection found inherited runtime debug underlines. A Material text-style parent and regression assertion fixed the issue. The visual hold now starts after initialization is ready. Those earlier cinematic APKs are superseded by the final artifact linked above.

No local Flutter SDK is installed. Local shell syntax and modified XML/plist checks passed; Flutter/platform results above come from executed GitHub Actions. Debug cold process/engine startup is additional to the brief Flutter welcome/reveal, especially on an emulator; physical release startup performance is not claimed.

Production signing, physical-device acceptance and qualified religious proofreading remain separate release gates. No merge, store publication, credential exposure or visibility change was performed.
