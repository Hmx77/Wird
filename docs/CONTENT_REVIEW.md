# Current review

Superseded by [the complete 66-screen verification report](CONTENT_VERIFICATION_2026-10-14.md). Current source-checked development catalog: 49 category entries; 17 reference screens pending. Qualified approval remains absent.

---

# Wird content review — 9 October 2026

Status: source-checked development corpus, not a claim to contain every authentic morning/evening remembrance. Automated tests check data integrity, not religious authenticity. A qualified independent Arabic/religious review remains a release gate for this religious product. No unreviewed candidate is displayed as a verified entry.

## Admission policy

Only Quran text, narrations in Sahih al-Bukhari/Sahih Muslim, or an explicitly recorded Sahih grading are admitted. `DhikrEntry.reviewed` defaults to false. Reading, home suggestions, search and sharing use the filtered `entries` collection. Meaning and benefit fields are editorial paraphrases, visibly separate from the Arabic recitation. Quran is displayed in readable Arabic spelling, not represented as a typeset Uthmani mushaf.

A count of one with no numerical prescription is labelled as a tracking action, never a mandatory religious repetition. Reminders are personal clock preferences, not fatwas about the boundaries of morning/evening. Prayer checkboxes measure recorded activity, not acceptance or reward.

## Sources checked

| Entries | Arabic/count/timing evidence | Review notes |
|---|---|---|
| morning_sayyid, evening_sayyid | https://sunnah.com/bukhari:6306 | Day/night, certainty and death before the corresponding evening/morning are retained in the benefit. No prescribed repetition count. |
| morning_tasbih, evening_tasbih | https://sunnah.com/muslim:2692 | 100 morning and evening; benefit retains the exception for equal/more remembrance. |
| morning_creation | https://sunnah.com/muslim:2726a | Three recitations; morning narrative. No invented evening counterpart. |
| morning_protection, evening_protection | https://sunnah.com/abudawud:5088 | Explicit Sahih (Al-Albani), three repetitions; benefit is sudden affliction as stated, not a general medical guarantee. |
| morning_wellbeing, evening_wellbeing | https://sunnah.com/abudawud:5074 | Explicit Sahih (Al-Albani). First clause is العافية, not an inserted العفو. Uses the reported plural عوراتي variant. No numerical repetition. |
| morning_bika | https://sunnah.com/abudawud:5068 | Explicit Sahih (Al-Albani); exact morning wording. Evening variants withheld pending further comparison. |
| evening_kingdom | https://sunnah.com/muslim:2723a | Exact a-variant: اللهم أسألك خير هذه الليلة. Not blended with the رب أسألك خير ما في variant. |
| sleep_bismika | https://sunnah.com/bukhari:6320 | Exact رب wording. Dust/shake bedding before lying down. No number of dustings attributed to this narration. |
| sleep_ikhlas_falaq_nas | https://sunnah.com/bukhari:5017 | Entire three-surah + blowing/wiping practice repeated three times. |
| sleep_life | https://sunnah.com/bukhari:6312 | باسمك أموت وأحيا as cited, without importing a different narration's extra word. |
| sleep_tasbih, sleep_tahmid, sleep_takbir | https://sunnah.com/muslim:2727a | 33, 33, 34; collective benefit, not separate rewards. Bukhari 6318 has another count variant and is not used for these counters. |
| sleep_gratitude | https://sunnah.com/muslim:2715 | Exact bedtime text; no numerical repetition. |
| sleep_kursi | https://sunnah.com/bukhari:2311 | Bedtime recitation of the complete verse; protection until morning. |

Quran text compared with:
- https://quran.com/112 — all four verses
- https://quran.com/113 — all five verses
- https://quran.com/114 — all six verses
- https://quran.com/2/255 — complete Ayat al-Kursi

No copyrighted English translations or audio were imported. Arabic scripture and classical narrations are the underlying historical text. Explanatory Arabic summaries were written for this project.

## Sunnah and Nawafil

- Four before Dhuhr and two before Fajr: https://sunnah.com/bukhari:1182
- Two after Dhuhr, Maghrib and Isha: https://sunnah.com/bukhari:1180 (combined 1180–1181).
- General merit of twelve voluntary rak'ahs in day/night: https://sunnah.com/muslim:728a.
- The displayed twelve-rak'ah table combines these references; it is not falsely attributed in full to Bukhari 1182. Bukhari 1180's ten-rak'ah narration is also valid, and the app says other authentic forms exist.
- Duha two rak'ahs and the joint-charity benefit: https://sunnah.com/muslim:720.
- Night prayer in pairs and one rak'ah of witr when fearing dawn: https://sunnah.com/bukhari:990. This is a reported form, not an exclusive fiqh ruling.

## Withheld / review queue — not in the reader

1. The sevenfold حسبي الله practice: expressly excluded by the user's requirement; do not reintroduce a disputed/weak count.
2. A larger 19+ morning reference list was described by the starter but no complete item list was supplied. It has NOT been reconstructed from assumptions.
3. Evening بك أمسينا variants: compare exact narrator wording/endings before admitting another version.
4. Any Hassan-only, disputed or weak narration: do not admit under this project's Sahih-only policy.
5. Broader occasion-based duas, detailed prayer-time boundaries, Hijri calendar observance and any extra reward claims: require a specified source review before publication.
6. Final independent proofreading of Arabic vocalization, Quran orthography, benefit paraphrases and grading attributions before a public store release.

The machine-readable `content-audit.json` records every displayed entry and a SHA-256 of the corpus. The static check rejects subsequent corpus edits until the audit is consciously regenerated after review. A hash is a change detector, never proof of authenticity.
