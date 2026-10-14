# Wird content verification — 14 October 2026

Source-checked **private development catalog**, not qualified scholarly approval and not approved for public release. Every attached reference page was visually inspected. Reference screenshots establish order and requested structure; they do not authenticate narrations. All three collections remain offline and separate.

## Actual totals

| Collection | Reference screens inspected | Category entries in the reader | Pending screens |
|---|---:|---:|---:|
| Morning | 25 | 18 | 7 |
| Evening | 23 | 15 | 8 |
| Bedtime | 18 | 16 | 2 |
| Total | 66 | 49 | 17 |

The 49 category-specific entries contain **36 distinct full displayed Arabic bodies** and **35 underlying recitation/guidance units**. Units are explicitly listed by `contentUnitIds` in `content-audit.json`: the combined bedtime three-surah body is decomposed into Ikhlas/Falaq/Nas already present elsewhere; identical formulas across categories count once, differing morning/evening words count separately, Al-Mulk counts as one complete surah, the two concluding Baqarah verses as one reading unit, and bad-dream guidance as one guidance unit. These definitions are not a claim of 66 unique Athkar.

All 19 original entry IDs are retained to preserve existing favorites and local progress. Bedtime screens 4–6 retain their existing combined three-surah routine; screen 15 retains three existing counters (33/33/34). Excluded screens do not create blank reader entries, public share cards or false completion targets. Reading order of admitted material follows reference order.

The supplied bedtime screenshots internally show a denominator of 19, while the attachment contains 18 pages. This review covers exactly those 18 supplied reference screens; no nineteenth screen was invented.

## Quran text and completeness

Downloaded the official **Tanzil Quran Text 1.1, Uthmani** dataset. Tanzil documents manual verification against Medina Mushaf, including letter/diacritic checksums: https://tanzil.net/docs/tanzil_project. The original retrieved file SHA-256 and selected 54 verbatim verse records are retained in `quran-source.json`. `quran_text.dart` carries the publisher's full notice and exact selected text. Number markers are display boundaries, not edits to the verse text. The publisher includes basmala in the first-verse record for the selected surahs; no separate numbered basmala is added.

- 2:255: entire Ayat al-Kursi.
- 2:285–286: both complete final Baqarah verses, in order.
- 109:1–6, 112:1–4, 113:1–5, 114:1–6: full surahs.
- 67:1–30: full Al-Mulk, all 30 numbered verses, including the cropped remainder. No text was completed from memory/OCR guesses.

Publisher attribution and an external Tanzil source button accompany Quran readings; the notice is available through the existing software-license page and included in source/data. Redistribution terms: https://tanzil.net/docs/text_license. No Quran translations or audio downloaded. The Qur'an is independently source-checked; our application still needs qualified proofreading of display and typography before public release.

## Important corrections and unresolved issues

- **حسبي الله… seven times:** preserve the screenshot caution. Quran 9:129 is authentic scripture, but this does not authenticate seven timed repetitions or the promised benefit. Abu Dawud 5081 is a companion report, and the cited version is graded Mawdu by Al-Albani. This judgement concerns that particular report, **not the Quranic words themselves**. Its different routes, attribution and benefits require qualified review. Kept only in the private review queue; no sevenfold verified counter.
- Fourfold أشهدك (Abu Dawud 5069), gratitude (5073), and the conquest/light kingdom formula (5084) are graded Daif in the retrieved source. They remain pending, with reference counts preserved in the review manifest.
- Bodily wellbeing (5090), رضيت بالله (Ibn Majah 3870), يا حي يا قيوم morning/evening (Sahih al-Jami 5820), and fright-at-night (3893) have Hasan classifications in the checked routes. Hasan is not silently relabelled Sahih; a book called صحيح does not make every entry Sahih.
- The short creator supplication uses the complete Sahih Abu Dawud 5067 matn. The different ordering and extra وأن أقترف… of Hasan Tirmidhi 3529 remain pending; no silent composite text.
- Ikhlas/Falaq/Nas morning/evening: three each, with an explicit Sahih grading recorded in Al-Albani's Sahih al-Jami 4406. Abu Dawud's displayed Hasan and Tirmidhi's Hasan-Sahih judgements are also documented rather than erased. The bedtime blow/recite/wipe cycle remains a separate Bukhari 5017 practice repeated three times.
- Bedtime اللهم قني عذابك: Abu Dawud 5045 is graded **Sahih except ثلاث مرار**. Supported words retained; screenshot count three not approved. Counter one explicitly means acknowledging a reading, not a newly prescribed numerical repetition.
- Exact evening بك أمسينا… المصير independently checked in Ibn Majah 3868; correct existing morning …النشور remains sourced to Abu Dawud 5068. Different transmitted variants are not blended.
- Tahlil 1/10/100 are separate alternatives in **one entry** per category. Sources: Abu Dawud 5077 (morning/evening, once), Muslim 2693 (ten, general), Bukhari 3293 (one hundred **in a day**). Benefits remain conditional on their own count; evening display does not invent a hundred-for-protection-until-morning claim. Choosing a new target resets that entry's current-day count; historical targets stay attached to their dates. Saved choices persist locally.
- Morning istighfar: Bukhari 6307 says **more than seventy daily**, while Muslim 2702a/2702b support one hundred daily. The screenshot's hundred count is not falsely attributed to Bukhari or made a mandated morning-only count.
- Salawat: the general practice/benefit remains, using a complete explicitly transmitted Bukhari 3370 formula and Muslim 408's one-for-ten benefit. The screenshot short formula is not claimed as an exact narrated matn. Ten at morning/evening and a special intercession promise are withheld (Silsilah al-Daifah 5788). Tracking one is clearly labelled as non-prescribed.
- Evening fitrah wording أمسينا is pending exact wording review; the checked Sahih al-Jami 4674 displayed matn uses أصبحنا even when mentioning evening usage. No replacement is guessed. The independently checked morning formula is included.
- Bedtime الواحد القهار: the screenshot Bukhari attribution was not established. Ibn Hibban 5530 has a sound-chain judgement by Shuayb al-Arnaut, while Ibn Hajar's judgement is معلول. Kept pending qualified conflict review, not represented as undisputed Sahih.
- Full Al-Mulk is admitted as verified Quran. Specific bedtime/reward claims from Tirmidhi 2892, graded Daif by Darussalam in the checked source, remain pending. No invented promise attached to the surah.
- Bad dreams: full Muslim 2262 guidance and the explicitly identified excerpt from 2263a were checked independently, not inferred from the cropped screen. Muslim 2261a provides the blow/refuge/protection context. Leftward blowing/spitting and refuge are threefold; turn side; prayer; do not relate the bad dream. Counter one acknowledges reading guidance, **not repeating it as a daily bedtime ritual**.
- Correct existing Sahih variants are preserved, including evening Muslim 2723a and Bukhari 6312. Other screenshot composites are corrected to one explicitly cited complete variant, with differences listed below.
- Bukhari 6311's surrender invocation is to be the **last words before sleep**. The reference screen sequence is retained for navigation, while its note explicitly distinguishes that ordering from the order of actual practice.

## Screen-by-screen comparison

`reference-comparison.csv` and `reference-screen-map.json` contain the same complete 66-screen record, with source links, mapping and pending classifications. All rows remain pending **qualified final proofreading**, even where a source check admits a development entry.

| Category / screen | Reference item | Decision | Reader IDs | Source check / correction |
|---|---|---|---|---|
| morning 1 | آية الكرسي | corrected | morning_kursi | Complete Quran verse retained. Timed protection claim withheld owing to differing grading/wording; do not import the bedtime Bukhari benefit into morning/evening. Sources: https://tanzil.net/#2:255; https://dorar.net/h/UA2ZPwXk; https://dorar.net/h/iyqeplK5?osoul=1 |
| morning 2 | سورة الإخلاص | admitted | morning_ikhlas | Separate surahs, each three repetitions, matching screens. Explicit Sahih grading recorded alongside Hasan/Hasan-Sahih differences; proofreading pending. Sources: https://dorar.net/h/4HhZknUQ |
| morning 3 | سورة الفلق | admitted | morning_falaq | Separate surahs, each three repetitions, matching screens. Explicit Sahih grading recorded alongside Hasan/Hasan-Sahih differences; proofreading pending. Sources: https://dorar.net/h/4HhZknUQ |
| morning 4 | سورة الناس | admitted | morning_nas | Separate surahs, each three repetitions, matching screens. Explicit Sahih grading recorded alongside Hasan/Hasan-Sahih differences; proofreading pending. Sources: https://dorar.net/h/4HhZknUQ |
| morning 5 | أصبحنا وأصبح الملك لله | admitted | morning_kingdom | Reference order retained. Sources: https://sunnah.com/muslim:2723b |
| morning 6 | اللهم بك أصبحنا | admitted | morning_bika | Reference order retained. Sources: https://sunnah.com/abudawud:5068 |
| morning 7 | سيد الاستغفار | admitted | morning_sayyid | Reference order retained. Sources: https://sunnah.com/bukhari:6306 |
| morning 8 | أشهدك وأشهد حملة عرشك | pending | withheld | The fourfold emancipation claim is graded Daif by Al-Albani in Abu Dawud 5069; no Sahih count-four practice admitted. Sources: https://sunnah.com/abudawud:5069 |
| morning 9 | ما أصبح / أمسى بي من نعمة | pending | withheld | Abu Dawud 5073 is graded Daif. The screenshot also adds أو بأحد من خلقك beyond the displayed matn. Withheld, not reconstructed. Sources: https://sunnah.com/abudawud:5073 |
| morning 10 | العافية في البدن والسمع والبصر | pending | withheld | Abu Dawud 5090 is Hasan in chain, not Sahih under this product policy. Count three retained only in the review queue. Sources: https://sunnah.com/abudawud:5090 |
| morning 11 | الاستعاذة من الهم والحزن | corrected | morning_worry | Bukhari wording ضلع الدين وغلبة الرجال replaces the screenshot غلبة الدين وقهر الرجال. General occasion explicitly labelled. Sources: https://sunnah.com/bukhari:6369 |
| morning 12 | حسبي الله لا إله إلا هو | pending | withheld | Screenshot authenticity caution preserved: disputed attribution, sevenfold morning/evening specification and promised sufficiency are NOT approved. Quran 9:129 is authentic scripture; this does not authenticate the sevenfold practice. Abu Dawud 5081 is a companion report with the wording صادقا كان بها أو كاذبا and is labelled Mawdu by Al-Albani on the cited page. This is a judgement on that report, not on the Quranic words. Qualified scholarly review is mandatory. Sources: https://sunnah.com/abudawud:5081 |
| morning 13 | العفو والعافية | variant | morning_wellbeing | Correct existing Abu Dawud 5074 opening العافية retained, without inserting the screenshot extra العفو in the first clause. Sources: https://sunnah.com/abudawud:5074 |
| morning 14 | فاطر السماوات والأرض | partial | morning_creator | Full Sahih Abu Dawud 5067 matn used. Different ordering and extra وأن أقترف... clause of Hasan Tirmidhi 3529 are not blended; extension pending. Sources: https://sunnah.com/abudawud:5067; https://sunnah.com/tirmidhi:3529 |
| morning 15 | بسم الله الذي لا يضر | admitted | morning_protection | Reference order retained. Sources: https://sunnah.com/abudawud:5088 |
| morning 16 | رضيت بالله ربًا | pending | withheld | Ibn Majah 3870 is Hasan; Abu Dawud 5072 is Daif. No Sahih evidence for the screenshot threefold timed practice established. Do not transfer the different context of Muslim 34. Sources: https://sunnah.com/ibnmajah:3870 |
| morning 17 | يا حي يا قيوم برحمتك أستغيث | pending | withheld | The morning/evening matn is graded Hasan in Al-Albani, Sahih al-Jami 5820; a book title containing صحيح does not make every entry Sahih. Withheld under the strict policy. Sources: https://dorar.net/h/YsQbIip8 |
| morning 18 | أصبح / أمسى الملك لله رب العالمين | pending | withheld | Abu Dawud 5084 is Daif. Do not conflate its conquest/light/blessing clauses with the distinct Sahih Muslim 2723 kingdom supplication. Sources: https://sunnah.com/abudawud:5084 |
| morning 19 | أصبحنا على فطرة الإسلام | admitted | morning_fitrah | Reference order retained. Sources: https://dorar.net/h/GLuDBTFW |
| morning 20 | لا إله إلا الله وحده | corrected | morning_tahlil | One selectable entry, three valid alternatives 1/10/100 with separate evidence and timing. No three duplicates, no mandatory combined targets. Evening 100 is general daily recitation; the promise is not changed to protection until morning. Sources: https://sunnah.com/bukhari:3293; https://sunnah.com/abudawud:5077; https://sunnah.com/muslim:2693 |
| morning 21 | سبحان الله وبحمده | admitted | morning_tasbih | Reference order retained. Sources: https://sunnah.com/muslim:2692 |
| morning 22 | عدد خلقه ورضا نفسه | admitted | morning_creation | Reference order retained. Sources: https://sunnah.com/muslim:2726a |
| morning 23 | العلم النافع والرزق الطيب | admitted | morning_knowledge | Timing restored: after the salam of Fajr, not an unspecified morning count. Sources: https://sunnah.com/ibnmajah:925 |
| morning 24 | الاستغفار والتوبة | corrected | morning_istighfar | Corrected the screenshot Bukhari attribution for 100: Bukhari 6307 says more than 70; Muslim 2702 supports daily 100. Display is an invocation, not a quote claiming this exact combined phrase is mandated 100 every morning. Sources: https://sunnah.com/muslim:2702a; https://sunnah.com/bukhari:6307; https://sunnah.com/muslim:2702b |
| morning 25 | الصلاة على النبي ﷺ | corrected | morning_salawat | General Salawat kept using a complete explicitly narrated Bukhari formula. Screenshot short صيغة is not falsely quoted as a verbatim Sahih hadith. Timed tenfold specification withheld; target 1 is labelled tracking only. General Muslim 408 one-for-ten benefit retained. Sources: https://sunnah.com/bukhari:3370; https://sunnah.com/muslim:408; https://dorar.net/h/Zx6Sk8ey |
| evening 1 | آية الكرسي | corrected | evening_kursi | Complete Quran verse retained. Timed protection claim withheld owing to differing grading/wording; do not import the bedtime Bukhari benefit into morning/evening. Sources: https://tanzil.net/#2:255; https://dorar.net/h/UA2ZPwXk; https://dorar.net/h/iyqeplK5?osoul=1 |
| evening 2 | سورة الإخلاص | admitted | evening_ikhlas | Separate surahs, each three repetitions, matching screens. Explicit Sahih grading recorded alongside Hasan/Hasan-Sahih differences; proofreading pending. Sources: https://dorar.net/h/4HhZknUQ |
| evening 3 | سورة الفلق | admitted | evening_falaq | Separate surahs, each three repetitions, matching screens. Explicit Sahih grading recorded alongside Hasan/Hasan-Sahih differences; proofreading pending. Sources: https://dorar.net/h/4HhZknUQ |
| evening 4 | سورة الناس | admitted | evening_nas | Separate surahs, each three repetitions, matching screens. Explicit Sahih grading recorded alongside Hasan/Hasan-Sahih differences; proofreading pending. Sources: https://dorar.net/h/4HhZknUQ |
| evening 5 | أمسينا وأمسى الملك لله | variant | evening_kingdom | Correct existing Muslim 2723a wording retained, rather than blending the screenshot b-variant into it. Sources: https://sunnah.com/muslim:2723a |
| evening 6 | اللهم بك أمسينا | admitted | evening_bika | Evening المصير independently verified in Ibn Majah 3868; morning النشور retained from Abu Dawud 5068. Variants are not silently blended. Sources: https://sunnah.com/ibnmajah:3868 |
| evening 7 | سيد الاستغفار | admitted | evening_sayyid | Reference order retained. Sources: https://sunnah.com/bukhari:6306 |
| evening 8 | أشهدك وأشهد حملة عرشك | pending | withheld | The fourfold emancipation claim is graded Daif by Al-Albani in Abu Dawud 5069; no Sahih count-four practice admitted. Sources: https://sunnah.com/abudawud:5069 |
| evening 9 | ما أصبح / أمسى بي من نعمة | pending | withheld | Abu Dawud 5073 is graded Daif. The screenshot also adds أو بأحد من خلقك beyond the displayed matn. Withheld, not reconstructed. Sources: https://sunnah.com/abudawud:5073 |
| evening 10 | العافية في البدن والسمع والبصر | pending | withheld | Abu Dawud 5090 is Hasan in chain, not Sahih under this product policy. Count three retained only in the review queue. Sources: https://sunnah.com/abudawud:5090 |
| evening 11 | الاستعاذة من الهم والحزن | corrected | evening_worry | Bukhari wording ضلع الدين وغلبة الرجال replaces the screenshot غلبة الدين وقهر الرجال. General occasion explicitly labelled. Sources: https://sunnah.com/bukhari:6369 |
| evening 12 | حسبي الله لا إله إلا هو | pending | withheld | Screenshot authenticity caution preserved: disputed attribution, sevenfold morning/evening specification and promised sufficiency are NOT approved. Quran 9:129 is authentic scripture; this does not authenticate the sevenfold practice. Abu Dawud 5081 is a companion report with the wording صادقا كان بها أو كاذبا and is labelled Mawdu by Al-Albani on the cited page. This is a judgement on that report, not on the Quranic words. Qualified scholarly review is mandatory. Sources: https://sunnah.com/abudawud:5081 |
| evening 13 | العفو والعافية | variant | evening_wellbeing | Correct existing Abu Dawud 5074 opening العافية retained, without inserting the screenshot extra العفو in the first clause. Sources: https://sunnah.com/abudawud:5074 |
| evening 14 | فاطر السماوات والأرض | partial | evening_creator | Full Sahih Abu Dawud 5067 matn used. Different ordering and extra وأن أقترف... clause of Hasan Tirmidhi 3529 are not blended; extension pending. Sources: https://sunnah.com/abudawud:5067; https://sunnah.com/tirmidhi:3529 |
| evening 15 | بسم الله الذي لا يضر | admitted | evening_protection | Reference order retained. Sources: https://sunnah.com/abudawud:5088 |
| evening 16 | رضيت بالله ربًا | pending | withheld | Ibn Majah 3870 is Hasan; Abu Dawud 5072 is Daif. No Sahih evidence for the screenshot threefold timed practice established. Do not transfer the different context of Muslim 34. Sources: https://sunnah.com/ibnmajah:3870 |
| evening 17 | يا حي يا قيوم برحمتك أستغيث | pending | withheld | The morning/evening matn is graded Hasan in Al-Albani, Sahih al-Jami 5820; a book title containing صحيح does not make every entry Sahih. Withheld under the strict policy. Sources: https://dorar.net/h/YsQbIip8 |
| evening 18 | أصبح / أمسى الملك لله رب العالمين | pending | withheld | Abu Dawud 5084 is Daif. Do not conflate its conquest/light/blessing clauses with the distinct Sahih Muslim 2723 kingdom supplication. Sources: https://sunnah.com/abudawud:5084 |
| evening 19 | أمسينا على فطرة الإسلام | pending | withheld | The Sahih al-Jami 4674 source has morning words أصبحنا in the displayed matn even when noting evening use. Ahmad variants differ. Exact أمسينا wording is not reconstructed; qualified wording review required. Morning wording is admitted separately. Sources: https://dorar.net/h/GLuDBTFW |
| evening 20 | لا إله إلا الله وحده | corrected | evening_tahlil | One selectable entry, three valid alternatives 1/10/100 with separate evidence and timing. No three duplicates, no mandatory combined targets. Evening 100 is general daily recitation; the promise is not changed to protection until morning. Sources: https://sunnah.com/bukhari:3293; https://sunnah.com/abudawud:5077; https://sunnah.com/muslim:2693 |
| evening 21 | سبحان الله وبحمده | admitted | evening_tasbih | Reference order retained. Sources: https://sunnah.com/muslim:2692 |
| evening 22 | أعوذ بكلمات الله التامات | admitted | evening_perfect_words | Three repetitions with explicit Sahih Darussalam grading; original Tirmidhi Hasan classification recorded. Muslim is not cited as prescribing three. Sources: https://sunnah.com/tirmidhi:3604b |
| evening 23 | الصلاة على النبي ﷺ | corrected | evening_salawat | General Salawat kept using a complete explicitly narrated Bukhari formula. Screenshot short صيغة is not falsely quoted as a verbatim Sahih hadith. Timed tenfold specification withheld; target 1 is labelled tracking only. General Muslim 408 one-for-ten benefit retained. Sources: https://sunnah.com/bukhari:3370; https://sunnah.com/muslim:408; https://dorar.net/h/Zx6Sk8ey |
| sleep 1 | آية الكرسي | admitted | sleep_kursi | Complete Quran text standardized to verbatim Tanzil. Correct bedtime Bukhari 2311 benefit preserved; screenshot generic morning/evening note not imported. Sources: https://sunnah.com/bukhari:2311 |
| sleep 2 | خواتيم سورة البقرة | admitted | sleep_baqarah_end | Reference sequence retained. Sources: https://sunnah.com/bukhari:5009 |
| sleep 3 | سورة الكافرون | admitted | sleep_kafirun | Reference sequence retained. Sources: https://sunnah.com/abudawud:5055 |
| sleep 4 | الإخلاص والفلق والناس | grouped | sleep_ikhlas_falaq_nas | Screens 4–6 map to the existing complete three-surah/blowing/wiping routine repeated three times. No duplicate separate triple counters added, and old favorite ID preserved. Sources: https://sunnah.com/bukhari:5017 |
| sleep 5 | الإخلاص والفلق والناس | grouped | sleep_ikhlas_falaq_nas | Continuation of the complete routine mapped to screen 4; not a new unique entry. Sources: https://sunnah.com/bukhari:5017 |
| sleep 6 | الإخلاص والفلق والناس | grouped | sleep_ikhlas_falaq_nas | Continuation of the complete routine mapped to screen 4; not a new unique entry. Sources: https://sunnah.com/bukhari:5017 |
| sleep 7 | باسمك ربي وضعت جنبي | admitted | sleep_bismika | Reference sequence retained. Sources: https://sunnah.com/bukhari:6320 |
| sleep 8 | اللهم قني عذابك | corrected | sleep_protect_punishment | Sahih wording retained. Screenshot count 3 rejected explicitly because the cited grade excludes that addition. Target 1 is tracking, not a new prescribed numerical claim. Sources: https://sunnah.com/abudawud:5045 |
| sleep 9 | باسمك أموت وأحيا | variant | sleep_life | Correct existing Bukhari 6312 باسمك أموت وأحيا preserved. Screenshot extra اللهم not blended into the selected source. Sources: https://sunnah.com/bukhari:6312 |
| sleep 10 | الحمد لله الذي أطعمنا | admitted | sleep_gratitude | Reference sequence retained. Sources: https://sunnah.com/muslim:2715 |
| sleep 11 | اللهم خلقت نفسي | corrected | sleep_soul | Exact Muslim wording خلقت نفسي retained without adding screenshot إنك. Sources: https://sunnah.com/muslim:2712 |
| sleep 12 | اللهم رب السماوات | variant | sleep_lord | Exact Muslim 2713a رب الأرض and وأغننا retained; screenshot رب العرش without الأرض and أغننا altered only to the cited complete source. Sources: https://sunnah.com/muslim:2713a |
| sleep 13 | اللهم أسلمت وجهي إليك | variant | sleep_surrender | Complete single Sahih 6311 variant used, not the screenshot composite أسلمت نفسي + وجهت وجهي. آخر ما تقول guidance kept despite reference placing Mulk later. Sources: https://sunnah.com/bukhari:6311 |
| sleep 14 | سورة الملك — كاملة | completed | sleep_mulk | All 30 verses sourced verbatim with numbered boundaries, including cropped remainder. Basmala is present in the publisher first-verse record and is not assigned its own verse number. Tirmidhi 2892 timing/virtue claim is Daif in Darussalam and remains pending; Quran text itself admitted. Sources: https://tanzil.net/#67:1; https://sunnah.com/tirmidhi:2892 |
| sleep 15 | التسبيح والتحميد والتكبير | split | sleep_tasbih, sleep_tahmid, sleep_takbir | Reference screen is one routine with three distinct counters: 33,33,34. All three old IDs preserved. Not three new unique screenshot items. Sources: https://sunnah.com/muslim:2727a |
| sleep 16 | لا إله إلا الله الواحد القهار | pending | withheld | Screenshot Bukhari attribution is not supported by the retrieved reference. Ibn Hibban 5530 is graded sound in chain by Shuayb al-Arnaut; Ibn Hajar labels the narration معلول in Ithaf al-Mahara 17/320. Matn and attribution require qualified conflict review; do not assert consensus Sahih. Sources: https://dorar.net/hadith/sharh/112428 |
| sleep 17 | دعاء الفزع في النوم | pending | withheld | Abu Dawud 3893 is Hasan excluding the later companion practice. Screenshot adds وعقابه absent in that matn. Do not guess an exact composite or treat Hasan as Sahih. Sources: https://sunnah.com/abudawud:3893 |
| sleep 18 | ما يفعل من رأى حلمًا يكرهه | completed | sleep_bad_dream | Cropped screen reconstructed only from Muslim 2262/2263a/2261a, with independent passages labelled. Three leftward spits/blows, refuge, turn side, prayer, do not relate. Counter 1 acknowledges reading guidance, not performing a threefold bedtime recitation. Sources: https://sunnah.com/muslim:2262; https://sunnah.com/muslim:2263a; https://sunnah.com/muslim:2261a |

## Technical verification record

Executed locally on 14 October 2026:
- Standalone Dart content integrity check, under network-blocking seccomp and a clean environment: PASS, 49 admitted entries.
- Offline Python source/asset/native-project structural check: PASS, exact original logo hash, ten theme definitions and default, Quran/corpus change detectors, 66-screen mapping and audio licensing gate.
- Dart formatter parses the modified files. Local full Flutter dependencies are unavailable; package-resolution warning for flutter_lints is not described as a passed Flutter analysis.

Added Flutter regression tests for exact order/counts, all 66 decisions, pending exclusions, 54 exact Quran records, all 30 Mulk verse boundaries, count alternatives/persistence/midnight/history, large RTL readers in Arabic/English, and full Mulk under all ten themes. Existing tests remain. Full Flutter dependency resolution, analysis, automated tests, Android build and supported iOS build **must be evidenced by the new CI run before reported as passed**.

The CI verification script bundles the catalog, this report, the full comparison and source/audit files with actual build logs. `wird-debug-apk` must contain `app-debug.apk`. The new content requires a fresh build; reusing the earlier redesigned APK is not evidence for these additions.

No redesign, no logo change, no lost favorites/feature IDs, no new backend/account/database, no audio recordings, no store publication and no main merge. Production remains blocked on qualified Quran/Hadith/Arabic proofreading, resolution of pending material or deliberate final exclusions, signing credentials and physical-device QA.

## Subsequent CI and display verification

Fresh run 42 passed dependency resolution, analysis, all 36 tests, Android APK packaging, Android 36 offline installation/interactive-home checks, and unsigned iOS device/simulator compilation with native launch. Later isolated-reader image review exposed reversed numeric fractions under RTL; a minimal numeric-label direction correction and icon-font test-fixture load were added. Fresh run 44 successfully passed all 36 tests and zero-issue analysis on both hosts, Android APK build/offline native checks, and unsigned iOS device/simulator builds with native launch for that final revision. See `BUILD_STATUS_CONTENT_2026-10-14.md` for its actual final results, artifact names/digests and all fixed failure records. Source catalog/Quran text, logo, themes and religious decisions were unchanged by this display correction.
