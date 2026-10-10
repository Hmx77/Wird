/// Source-checked Arabic corpus. See docs/CONTENT_REVIEW.md.
/// All timing/count/reward claims must pass an editorial Sahih-only gate.
enum DhikrSection { morning, evening, sleep }

class DhikrEntry {
  const DhikrEntry({
    required this.id,
    required this.section,
    required this.title,
    required this.arabic,
    required this.count,
    required this.source,
    required this.evidence,
    required this.meaning,
    required this.benefit,
    required this.isQuran,
    this.countDescription = '',
    required this.sourceUrl,
    required this.timing,
    this.reviewed = false,
  });

  final String id;
  final DhikrSection section;
  final String title;
  final String arabic;
  final int count;
  final String source;
  final String evidence;
  final String meaning;
  final String benefit;
  final bool isQuran;
  final String countDescription;
  final String sourceUrl, timing;
  final bool reviewed;
}

const contentCatalog = <DhikrEntry>[
  DhikrEntry(
    id: 'morning_sayyid',
    sourceUrl: 'https://sunnah.com/bukhari:6306',
    timing: 'في النهار؛ لا يحدد الحديث ساعة بعينها.',
    reviewed: true,
    section: DhikrSection.morning,
    title: 'سيد الاستغفار',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي، فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
    count: 1,
    countDescription:
        'قراءة واحدة في هذا العرض؛ ليس في الحديث عدد تكرار مفروض.',
    source: 'صحيح البخاري (6306)',
    evidence:
        'ورد قول هذا الدعاء في النهار والليل مع اليقين به في صحيح البخاري (6306).',
    meaning: 'إقرار بربوبية الله ونعمه، والاعتراف بالذنب وطلب المغفرة.',
    benefit:
        'من قاله موقنًا به نهارًا ثم مات قبل المساء، أو ليلًا ثم مات قبل الصباح، فهو من أهل الجنة كما في الحديث.',
    isQuran: false,
  ),
  DhikrEntry(
    id: 'morning_tasbih',
    sourceUrl: 'https://sunnah.com/muslim:2692',
    timing: 'حين يصبح.',
    reviewed: true,
    section: DhikrSection.morning,
    title: 'سبحان الله وبحمده',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    count: 100,
    source: 'صحيح مسلم (2692)',
    evidence:
        'قال ﷺ: «مَنْ قَالَ حِينَ يُصْبِحُ وَحِينَ يُمْسِي سُبْحَانَ اللَّهِ وَبِحَمْدِهِ مِائَةَ مَرَّةٍ ...» (مسلم 2692).',
    meaning: 'تنزيه الله عن النقص مع الثناء عليه.',
    benefit:
        'لا يأتي أحد يوم القيامة بأفضل مما جاء به إلا من قال مثل ذلك أو زاد عليه، كما في الحديث.',
    isQuran: false,
  ),
  DhikrEntry(
    id: 'evening_sayyid',
    sourceUrl: 'https://sunnah.com/bukhari:6306',
    timing: 'في الليل؛ لا يحدد الحديث ساعة بعينها.',
    reviewed: true,
    section: DhikrSection.evening,
    title: 'سيد الاستغفار',
    arabic:
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي، فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
    count: 1,
    countDescription:
        'قراءة واحدة في هذا العرض؛ ليس في الحديث عدد تكرار مفروض.',
    source: 'صحيح البخاري (6306)',
    evidence:
        'ورد قول هذا الدعاء في النهار والليل مع اليقين به في صحيح البخاري (6306).',
    meaning: 'إقرار بربوبية الله ونعمه، والاعتراف بالذنب وطلب المغفرة.',
    benefit:
        'من قاله موقنًا به نهارًا ثم مات قبل المساء، أو ليلًا ثم مات قبل الصباح، فهو من أهل الجنة كما في الحديث.',
    isQuran: false,
  ),
  DhikrEntry(
    id: 'evening_tasbih',
    sourceUrl: 'https://sunnah.com/muslim:2692',
    timing: 'حين يمسي.',
    reviewed: true,
    section: DhikrSection.evening,
    title: 'سبحان الله وبحمده',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    count: 100,
    source: 'صحيح مسلم (2692)',
    evidence:
        'قال ﷺ: «مَنْ قَالَ حِينَ يُصْبِحُ وَحِينَ يُمْسِي سُبْحَانَ اللَّهِ وَبِحَمْدِهِ مِائَةَ مَرَّةٍ ...» (مسلم 2692).',
    meaning: 'تنزيه الله عن النقص مع الثناء عليه.',
    benefit:
        'لا يأتي أحد يوم القيامة بأفضل مما جاء به إلا من قال مثل ذلك أو زاد عليه، كما في الحديث.',
    isQuran: false,
  ),
  DhikrEntry(
    id: 'sleep_bismika',
    sourceUrl: 'https://sunnah.com/bukhari:6320',
    timing: 'عند الاضطجاع بعد نفض الفراش؛ لا عدد للنفض في هذه الرواية.',
    reviewed: true,
    section: DhikrSection.sleep,
    title: 'باسمك ربي وضعت جنبي',
    arabic:
        'بِاسْمِكَ رَبِّ وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ.',
    count: 1,
    countDescription: 'يقال عند النوم؛ لم يرد في المصدر عدد تكرار مخصوص.',
    source: 'صحيح البخاري (6320)',
    evidence:
        'أمر النبي ﷺ بنفض الفراش قبل النوم ثم الدعاء بهذا الذكر، في صحيح البخاري (6320).',
    meaning: 'تفويض أمر النفس إلى الله وسؤاله الرحمة والحفظ.',
    benefit: 'دعاء مأثور عند الاضطجاع، من غير نسبة ثواب خاص غير ثابت.',
    isQuran: false,
  ),
  DhikrEntry(
    id: 'sleep_ikhlas_falaq_nas',
    sourceUrl: 'https://sunnah.com/bukhari:5017',
    timing:
        'عند النوم؛ تجمع الكفين وتنفث وتقرأ ثم تمسح ما استطعت من جسدك، ثلاث مرات.',
    reviewed: true,
    section: DhikrSection.sleep,
    title: 'الإخلاص والفلق والناس',
    arabic:
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ\n\nبِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِنْ شَرِّ مَا خَلَقَ ۝ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ\n\nبِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    count: 3,
    source: 'القرآن: 112، 113، 114 • صحيح البخاري (5017)',
    evidence:
        'عن عائشة رضي الله عنها: كان النبي ﷺ إذا أوى إلى فراشه جمع كفيه ونفث فيهما وقرأ السور الثلاث، ثم مسح ما استطاع من جسده، يفعل ذلك ثلاث مرات (البخاري 5017).',
    meaning: 'التوحيد والاستعاذة بالله من الشرور الظاهرة والخفية.',
    benefit: 'سنة ثابتة قبل النوم بقراءة السور الثلاث والنفث والمسح ثلاثًا.',
    isQuran: true,
  ),
  DhikrEntry(
    id: "morning_creation",
    section: DhikrSection.morning,
    title: "عدد خلقه ورضا نفسه",
    arabic:
        "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ",
    count: 3,
    source: "صحيح مسلم (2726a)",
    sourceUrl: "https://sunnah.com/muslim:2726a",
    timing: "أول النهار؛ في قصة جويرية رضي الله عنها.",
    evidence: "أخبر النبي ﷺ أنه قال هذه الكلمات ثلاث مرات بعد خروجه صباحًا.",
    benefit:
        "ذكر عظيم؛ أخبر النبي ﷺ أنها لو وزنت بما قالت جويرية منذ الصباح لوزنته.",
    meaning: "تنزيه الله والثناء عليه بألفاظ تدل على كثرة الحمد وعظمته.",
    countDescription: "",
    isQuran: false,
    reviewed: true,
  ),
  DhikrEntry(
    id: "sleep_life",
    section: DhikrSection.sleep,
    title: "باسمك أموت وأحيا",
    arabic: "بِاسْمِكَ أَمُوتُ وَأَحْيَا",
    count: 1,
    source: "صحيح البخاري (6312)",
    sourceUrl: "https://sunnah.com/bukhari:6312",
    timing: "عند النوم.",
    evidence: "كان النبي ﷺ يقوله إذا أوى إلى فراشه.",
    benefit: "اتباع الذكر الثابت عند النوم؛ لا ثواب عددي خاص منسوب هنا.",
    meaning: "تفويض الحياة والموت إلى الله.",
    countDescription: "قراءة للتتبع؛ لا تكرار مخصوص في هذا الحديث.",
    isQuran: false,
    reviewed: true,
  ),
  DhikrEntry(
    id: "sleep_tasbih",
    section: DhikrSection.sleep,
    title: "التسبيح عند النوم",
    arabic: "سُبْحَانَ اللَّهِ",
    count: 33,
    source: "صحيح مسلم (2727a)",
    sourceUrl: "https://sunnah.com/muslim:2727a",
    timing: "عند أخذ المضجع؛ ضمن التسبيح والتحميد والتكبير معًا.",
    evidence:
        "أرشد النبي ﷺ عليًا وفاطمة إلى التكبير ٣٤ والتسبيح ٣٣ والتحميد ٣٣ عند النوم.",
    benefit:
        "أخبر النبي ﷺ أن مجموع هذا الذكر خير لهما من خادم؛ الفضل للمجموع الوارد.",
    meaning: "ذكر لله وتنزيه وثناء وتعظيم.",
    countDescription:
        "جزء من مجموعة النوم: ٣٣ تسبيحًا، ٣٣ تحميدًا، ٣٤ تكبيرًا.",
    isQuran: false,
    reviewed: true,
  ),
  DhikrEntry(
    id: "sleep_tahmid",
    section: DhikrSection.sleep,
    title: "التحميد عند النوم",
    arabic: "الْحَمْدُ لِلَّهِ",
    count: 33,
    source: "صحيح مسلم (2727a)",
    sourceUrl: "https://sunnah.com/muslim:2727a",
    timing: "عند أخذ المضجع؛ ضمن التسبيح والتحميد والتكبير معًا.",
    evidence:
        "أرشد النبي ﷺ عليًا وفاطمة إلى التكبير ٣٤ والتسبيح ٣٣ والتحميد ٣٣ عند النوم.",
    benefit:
        "أخبر النبي ﷺ أن مجموع هذا الذكر خير لهما من خادم؛ الفضل للمجموع الوارد.",
    meaning: "ذكر لله وتنزيه وثناء وتعظيم.",
    countDescription:
        "جزء من مجموعة النوم: ٣٣ تسبيحًا، ٣٣ تحميدًا، ٣٤ تكبيرًا.",
    isQuran: false,
    reviewed: true,
  ),
  DhikrEntry(
    id: "sleep_takbir",
    section: DhikrSection.sleep,
    title: "التكبير عند النوم",
    arabic: "اللَّهُ أَكْبَرُ",
    count: 34,
    source: "صحيح مسلم (2727a)",
    sourceUrl: "https://sunnah.com/muslim:2727a",
    timing: "عند أخذ المضجع؛ ضمن التسبيح والتحميد والتكبير معًا.",
    evidence:
        "أرشد النبي ﷺ عليًا وفاطمة إلى التكبير ٣٤ والتسبيح ٣٣ والتحميد ٣٣ عند النوم.",
    benefit:
        "أخبر النبي ﷺ أن مجموع هذا الذكر خير لهما من خادم؛ الفضل للمجموع الوارد.",
    meaning: "ذكر لله وتنزيه وثناء وتعظيم.",
    countDescription:
        "جزء من مجموعة النوم: ٣٣ تسبيحًا، ٣٣ تحميدًا، ٣٤ تكبيرًا.",
    isQuran: false,
    reviewed: true,
  ),
  DhikrEntry(
    id: "evening_kingdom",
    section: DhikrSection.evening,
    title: "أمسينا وأمسى الملك لله",
    arabic:
        "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ أَسْأَلُكَ خَيْرَ هَذِهِ اللَّيْلَةِ وَأَعُوذُ بِكَ مِنْ شَرِّ هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.",
    source: "صحيح مسلم (2723a)",
    sourceUrl: "https://sunnah.com/muslim:2723a",
    timing: "حين يمسي؛ لفظ رواية مسلم 2723a دون دمج ألفاظ الروايات الأخرى.",
    evidence: "روى ابن مسعود أن رسول الله ﷺ كان يقول هذا الدعاء إذا أمسى.",
    meaning:
        "الثناء على الله وطلب الخير والاستعاذة من الشر والكسل وسوء الكبر والعذاب.",
    benefit: "دعاء مسائي ثابت؛ لا يُنسب إليه ثواب خاص غير وارد في الرواية.",
    isQuran: false,
    count: 1,
    reviewed: true,
    countDescription: "قراءة كاملة للتتبع؛ لا تكرار مخصوص في هذه الرواية.",
  ),
  DhikrEntry(
    id: "sleep_gratitude",
    section: DhikrSection.sleep,
    title: "الحمد لله الذي أطعمنا",
    arabic:
        "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا فَكَمْ مِمَّنْ لَا كَافِيَ لَهُ وَلَا مُئْوِيَ.",
    source: "صحيح مسلم (2715)",
    sourceUrl: "https://sunnah.com/muslim:2715",
    timing: "عند الإيواء إلى الفراش.",
    evidence: "روى أنس رضي الله عنه أن النبي ﷺ كان يقوله إذا أوى إلى فراشه.",
    meaning: "شكر الله على الطعام والشراب والكفاية والمأوى.",
    benefit: "اتباع الذكر الثابت عند النوم؛ لا ثواب عددي خاص منسوب هنا.",
    isQuran: false,
    count: 1,
    reviewed: true,
    countDescription: "قراءة كاملة للتتبع؛ لا تكرار مخصوص في هذه الرواية.",
  ),
  DhikrEntry(
    id: "sleep_kursi",
    section: DhikrSection.sleep,
    title: "آية الكرسي",
    arabic:
        "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
    source: "القرآن: البقرة 255 • صحيح البخاري (2311)",
    sourceUrl: "https://sunnah.com/bukhari:2311",
    timing: "تقرأ كاملة عند الإيواء إلى الفراش.",
    evidence:
        "أقر النبي ﷺ في حديث أبي هريرة خبر قراءة آية الكرسي عند النوم وفضلها.",
    meaning: "آية في توحيد الله وكمال حياته وقيوميته وعلمه وقدرته.",
    benefit:
        "ورد أن على قارئها عند النوم حافظًا من الله ولا يقربه شيطان حتى يصبح.",
    isQuran: true,
    count: 1,
    reviewed: true,
    countDescription: "قراءة كاملة للتتبع؛ لا تكرار مخصوص في هذه الرواية.",
  ),
  DhikrEntry(
    id: "morning_protection",
    section: DhikrSection.morning,
    title: "بسم الله الذي لا يضر",
    arabic:
        "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
    count: 3,
    source: "سنن أبي داود (5088) • صحيح: الألباني",
    sourceUrl: "https://sunnah.com/abudawud:5088",
    timing: "حين يصبح.",
    benefit:
        "ورد الحفظ من فجأة البلاء إلى الصباح أو المساء عند قوله ثلاثًا كما في الرواية.",
    meaning: "الاستعانة بالله والتوكل عليه وذكر اسمه.",
    evidence: "نص الحديث على ثلاث مرات حين يصبح وفي المساء.",
    countDescription: "",
    reviewed: true,
    isQuran: false,
  ),
  DhikrEntry(
    id: "morning_wellbeing",
    section: DhikrSection.morning,
    title: "العفو والعافية",
    arabic:
        "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي.",
    count: 1,
    source: "سنن أبي داود (5074) • صحيح: الألباني",
    sourceUrl: "https://sunnah.com/abudawud:5074",
    timing: "حين يصبح.",
    benefit:
        "دعاء ثابت حافظ عليه النبي ﷺ صباحًا ومساءً؛ لا ثواب عددي خاص منسوب هنا.",
    meaning: "سؤال العفو والعافية والستر والأمان والحفظ.",
    evidence:
        "روى ابن عمر محافظة النبي ﷺ على هذه الدعوات صباحًا ومساءً. اختير لفظ عوراتِي المذكور في طريق عثمان في المصدر.",
    countDescription: "قراءة للتتبع؛ لا يحدد الحديث عدد تكرار مخصوصًا.",
    reviewed: true,
    isQuran: false,
  ),
  DhikrEntry(
    id: "evening_protection",
    section: DhikrSection.evening,
    title: "بسم الله الذي لا يضر",
    arabic:
        "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
    count: 3,
    source: "سنن أبي داود (5088) • صحيح: الألباني",
    sourceUrl: "https://sunnah.com/abudawud:5088",
    timing: "حين يمسي.",
    benefit:
        "ورد الحفظ من فجأة البلاء إلى الصباح أو المساء عند قوله ثلاثًا كما في الرواية.",
    meaning: "الاستعانة بالله والتوكل عليه وذكر اسمه.",
    evidence: "نص الحديث على ثلاث مرات حين يصبح وفي المساء.",
    countDescription: "",
    reviewed: true,
    isQuran: false,
  ),
  DhikrEntry(
    id: "evening_wellbeing",
    section: DhikrSection.evening,
    title: "العفو والعافية",
    arabic:
        "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي.",
    count: 1,
    source: "سنن أبي داود (5074) • صحيح: الألباني",
    sourceUrl: "https://sunnah.com/abudawud:5074",
    timing: "حين يمسي.",
    benefit:
        "دعاء ثابت حافظ عليه النبي ﷺ صباحًا ومساءً؛ لا ثواب عددي خاص منسوب هنا.",
    meaning: "سؤال العفو والعافية والستر والأمان والحفظ.",
    evidence:
        "روى ابن عمر محافظة النبي ﷺ على هذه الدعوات صباحًا ومساءً. اختير لفظ عوراتِي المذكور في طريق عثمان في المصدر.",
    countDescription: "قراءة للتتبع؛ لا يحدد الحديث عدد تكرار مخصوصًا.",
    reviewed: true,
    isQuran: false,
  ),
  DhikrEntry(
    id: "morning_bika",
    section: DhikrSection.morning,
    title: "اللهم بك أصبحنا",
    arabic:
        "اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
    count: 1,
    source: "سنن أبي داود (5068) • صحيح: الألباني",
    sourceUrl: "https://sunnah.com/abudawud:5068",
    timing: "حين يصبح.",
    benefit: "اتباع دعاء الصباح الثابت؛ لا ثواب عددي خاص منسوب هنا.",
    meaning: "إقرار بأن الحياة والموت والبعث إلى الله.",
    evidence: "روى أبو هريرة هذا اللفظ عن النبي ﷺ إذا أصبح.",
    countDescription: "قراءة للتتبع؛ لا عدد تكرار مخصوص في الرواية.",
    reviewed: true,
    isQuran: false,
  ),
];

String sectionLabel(DhikrSection section) => switch (section) {
  DhikrSection.morning => 'أذكار الصباح',
  DhikrSection.evening => 'أذكار المساء',
  DhikrSection.sleep => 'أذكار النوم',
};

List<DhikrEntry> inSection(DhikrSection section) =>
    entries.where((entry) => entry.section == section).toList();

// Fail closed: unreviewed items cannot reach reading, search or sharing.
final entries = List<DhikrEntry>.unmodifiable(
  contentCatalog.where((e) => e.reviewed),
);

String normalizeArabic(String value) => value
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ى', 'ي')
    .trim();
