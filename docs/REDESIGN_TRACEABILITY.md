# Premium redesign baseline and traceability - 13 October 2026

Historical redesign baseline. The completed 14 October catalog and all 66 PDF decisions are recorded in `CONTENT_VERIFICATION_2026-10-14.md`; fresh 36-test Android/iOS verification and current APK artifacts are recorded in `BUILD_STATUS_CONTENT_2026-10-14.md`. Original branding and the approved premium design remain preserved.

Authoritative source: attached 28-page master specification, read in full including visual appendix. Baseline remote commit: 8656ab8f0d0341acb1e1f05071713b5da1b1f80e. Repo remains private. Work is isolated on redesign/premium-20261013; no merge/store release authorized.

Baseline source inspection confirms 6 morning, 5 evening and 8 bedtime entries. Redesign analysis and all 22 automated tests passed on Linux and macOS. Android debug APK generation passed run #28. Xcode 26.3 unsigned device compilation, simulator compilation, installation and launch passed run #29 after fixing the widget bundle name and version parity. The original artwork PNG and religious source text remain unchanged. See BUILD_STATUS_2026-10-14.md for actual run revisions, earlier failures, native review results and artifact digests.

| Requirement | Implementation | Acceptance remaining |
|---|---|---|
| FR-01 launcher | Reproducible Flutter artwork renderer; adaptive safe zone; all iOS sizes | Generated/mask/native captures reviewed; owner acceptance pending |
| FR-02 kasra | Original PNG immutable; one separate vector kasra under waw | Small-size visual proof and owner acceptance |
| FR-03 opening | Ivory botanical/crescent/skyline vector composition; OS-compatible native opening | iOS launch and Android cold-launch captures passed; physical performance pending |
| FR-04 home | Dark theme-derived teal/slate home and restrained gold accents | Actual Android phone/tablet and iOS screens reviewed |
| FR-05 header/cards | Cropped official branding, concise category entry points | Widget tests and native large-font captures passed |
| FR-06 tracking | ProgressPage removed from shell only; stored data/code retained | Four-tab/persistence tests passed; physical signed-update gate remains |
| FR-07 localization | All ten palette names have explicit Arabic mappings; English identities unchanged | Language/theme tests passed; review screenshots preserved |
| FR-08 sujood | Owned vector kneeling torso and forehead at ground level | Navigation icon visible in native captures; owner acceptance pending |
| FR-09 navigation | Four tabs; search/favorites via home and library | Automated navigation tests passed |
| FR-10 brand system | Shared original artwork, vector kasra, warm opening and richer home; licensed Noto Sans Arabic | Cross-platform appearance and owner acceptance |
| FR-11 catalog | 19 existing stable IDs and source text unchanged; CSV manifest and source review | BLOCKED: original 25-screen source references unavailable; qualified independent proofreading pending |

## Content review outcome

No entries were added to reach an arbitrary number. Original 25 morning-reference images are absent from the supplied PDF appendix and current repository. Prior-context retrieval found descriptions of the set but no retrievable image identifiers or exact source-screen contents. Please provide the original set to complete omission mapping. Unseen screens 3/25 and 4/25 will not be reconstructed from prior assistant guesses.

The existing catalog was rechecked against Bukhari 6306, 6320, 6312, 5017, 2311; Muslim 2692, 2726a, 2723a, 2715, 2727a; Abu Dawud 5088, 5074, 5068 (explicit Sahih Al-Albani attribution on source). Bukhari 6320's bedtime wording is preserved; Muslim 2714a is a distinct variant, not merged into it. Muslim 2727a supports the collective bedtime 33/33/34 practice. Quran references remain 112, 113, 114 and 2:255. This development source review is not independent scholarly certification.

The manifest CSV includes exact bundled Arabic, timing/count context, sources and benefits. Every included row retains a pending independent-review gate. Excluded: sevenfold hasbi practice and any weak/Hasan-only/disputed candidate. Pending: missing reference inventory; evening bika variants; English religious translations. Existing docs/CONTENT_REVIEW.md records source-specific notes. No unsupported benefit was added.

## Rights and data compatibility

Original artwork source SHA-256 stays 68190c2046747a8c0f8556cbbbcf395887e9f69489887615448d69e85f926244. Excess canvas is clipped during composition; original letters and leaf remain untouched. Single kasra is a code-drawn layer. Noto Sans Arabic was fetched from Google Fonts, blob f1d01edce4ebaedcbe9a06fc75fec07b304ec3df, distributed with its unmodified SIL OFL 1.1 license. Botanical and sujood paths are original project code. No competitor artwork, recording, analytics, backend or mandatory login was added.

Preference keys, theme indices, entry IDs, counters, favorites, notification settings and app IDs remain compatible. Tracking is hidden, not erased. Generated native assets must be produced before native build using flutter test tool/brand_assets_test.dart; CI and local build scripts include this step.

## Device acceptance checklist

Check signing-certificate compatibility before installing an update. The prior GitHub-hosted debug signing key was ephemeral and not retained, so an in-place update to an existing installation may require the original key or a verified local backup. Do not uninstall the existing app just to bypass a signature mismatch. App-layer tests verify existing storage keys and data persistence; signing continuity is a separate device gate. Confirm favorites/counts/theme/language survive a properly signed update. Check Android adaptive circle/squircle masks on light/dark wallpaper and Android 12+ cold/warm launch. Check iPhone safe areas and native launch on a signed device/simulator. Navigate four tabs; confirm no calendar/activity dashboard, working sujood navigation, counters/undo/reset, favorite/search/share, all ten localized themes, max reading/system font size, offline relaunch, timezone/day changes, opt-in notifications, reboot restoration and home-screen widget. Actual physical-device QA remains unperformed until evidence is captured.
