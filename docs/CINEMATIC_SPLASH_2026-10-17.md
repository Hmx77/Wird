# Automatic cinematic opening — 17 October 2026

Review branch: `redesign/refined-20261015`. No merge or store publication.

## Implemented behavior

- Full-bleed, bundled deep-teal arch/mosque/lantern scene inspired by the owner's reference, without baked text or UI. The original approved logo (including its kasra), `WIRD`, and `ذِكْرٌ يُرَافِقُ يَوْمَكَ` are real Flutter widgets.
- No CTA, welcome button, touch hint, tap recognizer, or required interaction. The splash automatically dissolves over the actual functioning `WirdShell` and then removes its overlay while preserving the shell's state.
- Gentle 1.8% background drift and 3% logo scale/fade. A 1.2-second visual hold followed by a 350ms dissolve targets 1.55 seconds from the first Flutter splash frame when initialization is ready. OS process/engine startup is additional and device-dependent. If required initialization is slower, keep the branded screen instead of revealing blank content.
- Reduced motion disables scale/drift and uses an immediate automatic reveal after the brief hold. The opening runs once per process launch, never on theme/preference rebuild or returning from another page. No new preference keys.
- Native Android/iOS launch backgrounds match deep teal. Android's mandatory system splash remains OS-controlled; its existing mark and approved launcher icon remain unchanged.
- All existing home UI, 10 palettes, offline services, reminders, saved data and religious content remain unchanged. Audio remains unavailable without licensed recordings.

## Artwork provenance

New asset: `assets/brand/wird_sanctuary_20261017.png`, generated with the built-in image tool for this project. The owner's attached reference supplied mood/composition only; the phone frame, written logo, status bar and touch instruction were not copied into the asset. Original logo files were not edited.

Prompt: cinematic premium portrait Islamic architectural background, pointed arch framing distant mosque/minarets and crescent at blue-hour twilight; deep teal/midnight palm/leaf foreground; warm lanterns and reflective stone path; dark quiet lower-middle space for separate logo/text; full bleed; no writing, logo, phone, borders, status bar, CTA, touch hint or watermark.

## Validation

New Flutter tests cover automatic entry without CTA, readiness gating, preservation across rebuilds and reduced motion. Existing content/theme/navigation/counter tests remain in the suite. CI renders the opening and checks brand provenance, runs analysis/tests and builds the debug APK. Native Android checks record the FIRST cold launch with no input from launcher through home, retaining `startup.mp4` and sampled PNG frames in `wird-android-device-review`. The APK remains a separate `wird-debug-apk` artifact containing `app-debug.apk`.

Results will be updated after the final CI run. No local Flutter SDK is available; local shell syntax validation passed, and Flutter results must come from executed CI.

Production signing, physical-device acceptance and qualified religious proofreading remain separate release gates.
