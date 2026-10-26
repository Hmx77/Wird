# Wird reference-only Athkar entries — implementation review

**Draft only, dated 26 October 2026. Not authenticated as Sahih and not approved for public distribution.**

## Collection totals

| Collection | Verified/development-admitted | Reference-only | Displayed |
|---|---:|---:|---:|
| Morning | 18 | 7 | 25 |
| Evening | 15 | 8 | 23 |
| Sleep-related | 18 | 0 | 18 |
| **Total** | **51** | **15** | **66** |

All original 51 entries remain in the verified-development catalog unchanged. Original 17 withheld source screenshots have *not* been authenticated by this change. Two sleep alternatives introduced in PR #9 remain the basis of 18 sleep entries. The original 2 withheld sleep texts remain excluded.

## Reference-only decisions

| Category | Reference screen | Caption | Cited report | Grading note |
|---|---:|---|---|---|
| morning | 8 | أشهدك وأشهد حملة عرشك | Abu Dawud 5069 | Daif per al-Albani; Hasan chain per Ibn Baz |
| morning | 9 | ما أصبح بي من نعمة | Abu Dawud 5073 | Daif per al-Albani; Hasan chain per Ibn Baz |
| morning | 10 | العافية في البدن والسمع والبصر | Abu Dawud 5090 | Hasan, not Sahih |
| morning | 12 | حسبي الله لا إله إلا هو | Quran 9:129; Abu Dawud 5081 | Quran genuine; sevenfold report called Mawdu by al-Albani |
| morning | 16 | رضيت بالله ربًا | Ibn Majah 3870; Abu Dawud 5072 | Hasan / Daif across the cited routes |
| morning | 17 | يا حي يا قيوم | Sahih al-Jami 5820 | Hasan per al-Albani |
| morning | 18 | أصبحنا وأصبح الملك لله رب العالمين | Abu Dawud 5084 | Daif per al-Albani |
| evening | 8 | أشهدك وأشهد حملة عرشك | Abu Dawud 5069 | Daif per al-Albani; Hasan chain per Ibn Baz |
| evening | 9 | ما أصبح بي من نعمة | Abu Dawud 5073 | Daif per al-Albani; Hasan chain per Ibn Baz |
| evening | 10 | العافية في البدن والسمع والبصر | Abu Dawud 5090 | Hasan, not Sahih |
| evening | 12 | حسبي الله لا إله إلا هو | Quran 9:129; Abu Dawud 5081 | Quran genuine; sevenfold report called Mawdu by al-Albani |
| evening | 16 | رضيت بالله ربًا | Ibn Majah 3870; Abu Dawud 5072 | Hasan / Daif across the cited routes |
| evening | 17 | يا حي يا قيوم | Sahih al-Jami 5820 | Hasan per al-Albani |
| evening | 18 | أصبحنا وأصبح الملك لله رب العالمين | Abu Dawud 5084 | Daif per al-Albani |
| evening | 19 | أمسينا على فطرة الإسلام | Ahmad 21144 | Disputed Sahih vs very weak route |

## Required presentation separation

- The library and reader must visibly say a passage is **not established as Sahih**; cite the attributed grading, not a universal consensus.
- Neither a weak nor a disputed count/benefit may appear as an authenticated devotional instruction.
- The fifteen reference-only entries are excluded from daily progress, completed worship counts, share cards, and prescribed repetition-counter behavior.
- For sevenfold حسبي الله, the Quran verse is authentic but the specific claimed routine is disputed and graded Mawdu in the cited Abu Dawud source.
- Some evening display excerpts use an identical morning-language matn because the cited route does not supply a word-for-word evening variant. They are **not certified transcriptions** of the original screenshots. The precise evening wording and all diacritics require qualified comparison against primary text before any release.
- The Arabic text here is a *provisional cited excerpt or adaptation*, not an independently approved new Sunnah formula. A credible editorial reviewer must verify verbatim source text, variants, reference-specific grade, translations, and context.

**Do not publish or merge** until source-level review resolves these issues and native screenshots and tests pass. Only the display/reference count, not the Sahih count, meets 25/23/18.

## PR #10 source comparison corrections

On 26 October 2026 the linked source pages were re-read. Abu Dawud [5069](https://sunnah.com/abudawud:5069), [5073](https://sunnah.com/abudawud:5073) and [5084](https://sunnah.com/abudawud:5084) print morning wording and refer to evening without a separately transcribed evening formula. Their evening reader warning now explicitly identifies the retained text as the source's morning-language quotation. No invented evening quotation is attributed to the Prophet.

The evening fitrah adaptation previously combined `دين نبينا` with the citation to Ahmad 21144. That cited [primary transcription](https://dorar.net/h/pqQlwee2?osoul=1) has `سنة نبينا`; this reference-only passage was corrected to that wording. Its opening remains an explicitly disclosed evening adaptation, and the grading dispute remains unresolved. No original development-admitted entry was edited.

[Abu Dawud 5090](https://sunnah.com/abudawud:5090) displays Hasan in chain; the excerpt is the bodily-health supplication, with its omitted additional supplication disclosed. [Ibn Majah 3870](https://sunnah.com/ibnmajah:3870) displays Hasan (Darussalam). [Al-Jami 5820](https://dorar.net/h/YsQbIip8) displays Hasan despite the book title. [Abu Dawud 5081](https://sunnah.com/abudawud:5081) attributes the report to Abu al-Darda and displays Mawdu (al-Albani). That ruling concerns the sevenfold claim, not Quran 9:129. These are source comparisons, not new scholarly adjudications or independent qualified proofreading.

The immutable 51-entry source payload and its existing audit are protected separately from the reference-only file. Runtime tests compare all 51 payloads field by field. All 66 displayed entries are exported with `reviewOnly`, grading, evidence and devotional/display totals; the reference display must never be described as 66 Sahih entries.
