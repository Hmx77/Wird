import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/content.dart';
import 'package:wird/quran_text.dart';

void main() {
  test('all 66 screens have one explicit ordered admission decision', () {
    final manifest =
        jsonDecode(File('docs/reference-screen-map.json').readAsStringSync())
            as Map<String, dynamic>;
    final screens = manifest['screens'] as List;
    expect(screens, hasLength(66));
    for (final pair in [('morning', 25), ('evening', 23), ('sleep', 18)]) {
      expect(
        screens.where((s) => s['section'] == pair.$1).map((s) => s['screen']),
        List.generate(pair.$2, (i) => i + 1),
      );
    }
    expect(screens.where((s) => s['decision'] == 'pending'), hasLength(17));
    final admittedIds = entries.map((e) => e.id).toSet();
    for (final screen in screens) {
      if (screen['decision'] == 'pending') {
        expect(screen['entryIds'], isEmpty);
      } else {
        expect(screen['entryIds'], isNotEmpty);
        for (final id in screen['entryIds']) {
          expect(admittedIds, contains(id));
          final entry = entries.singleWhere((e) => e.id == id);
          expect(entry.section.name, screen['section']);
          expect(entry.referenceScreens, contains(screen['screen']));
        }
      }
    }
    for (final candidate in manifest['pendingCandidates']) {
      expect(candidate['reviewed'], false);
      expect(admittedIds, isNot(contains(candidate['id'])));
    }
  });

  test('category counts and exact reading order are not screenshot totals', () {
    expect(inSection(DhikrSection.morning).where((e) => !e.reviewOnly).map((e) => e.id), [
      'morning_kursi',
      'morning_ikhlas',
      'morning_falaq',
      'morning_nas',
      'morning_kingdom',
      'morning_bika',
      'morning_sayyid',
      'morning_worry',
      'morning_wellbeing',
      'morning_creator',
      'morning_protection',
      'morning_fitrah',
      'morning_tahlil',
      'morning_tasbih',
      'morning_creation',
      'morning_knowledge',
      'morning_istighfar',
      'morning_salawat',
    ]);
    expect(inSection(DhikrSection.evening).where((e) => !e.reviewOnly).map((e) => e.id), [
      'evening_kursi',
      'evening_ikhlas',
      'evening_falaq',
      'evening_nas',
      'evening_kingdom',
      'evening_bika',
      'evening_sayyid',
      'evening_worry',
      'evening_wellbeing',
      'evening_creator',
      'evening_protection',
      'evening_tahlil',
      'evening_tasbih',
      'evening_perfect_words',
      'evening_salawat',
    ]);
    expect(inSection(DhikrSection.sleep).map((e) => e.id), [
      'sleep_kursi',
      'sleep_baqarah_end',
      'sleep_kafirun',
      'sleep_ikhlas_falaq_nas',
      'sleep_bismika',
      'sleep_protect_punishment',
      'sleep_life',
      'sleep_gratitude',
      'sleep_soul',
      'sleep_lord',
      'sleep_surrender',
      'sleep_mulk',
      'sleep_tasbih',
      'sleep_tahmid',
      'sleep_takbir',
      'sleep_bad_dream',
      'sleep_creator',
      'sleep_night_waking',
    ]);
    expect(entries, hasLength(51));
    expect(displayedEntries, hasLength(66));
    expect(inSection(DhikrSection.morning), hasLength(25));
    expect(inSection(DhikrSection.evening), hasLength(23));
    expect(inSection(DhikrSection.sleep), hasLength(18));
    expect(entries.map((e) => e.arabic).toSet(), hasLength(37));
    for (final section in DhikrSection.values) {
      expect(
        inSection(section).where((e) => !e.reviewOnly).map((e) => normalizeArabic(e.arabic)).toSet(),
        hasLength(inSection(section).where((e) => !e.reviewOnly).length),
      );
    }
  });

  test('every Quran payload contains complete verbatim publisher verses', () {
    final source =
        jsonDecode(File('docs/quran-source.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(quranVerses, Map<String, String>.from(source['verses'] as Map));
    expect(quranVerses, hasLength(54));
    const passages = {
      'morning_kursi': ['2:255'],
      'evening_kursi': ['2:255'],
      'sleep_kursi': ['2:255'],
      'morning_ikhlas': ['112:1', '112:2', '112:3', '112:4'],
      'evening_ikhlas': ['112:1', '112:2', '112:3', '112:4'],
      'sleep_baqarah_end': ['2:285', '2:286'],
      'sleep_kafirun': ['109:1', '109:2', '109:3', '109:4', '109:5', '109:6'],
    };
    for (final pair in passages.entries) {
      final entry = entries.singleWhere((e) => e.id == pair.key);
      for (final key in pair.value) {
        expect(entry.arabic, contains(quranVerses[key]!));
      }
    }
    for (final e in entries.where((e) => e.isQuran)) {
      expect(e.source, contains('Tanzil Project'));
      expect(e.quranSourceUrl, 'https://tanzil.net');
    }
    final mulk = entries.singleWhere((e) => e.id == 'sleep_mulk');
    for (var n = 1; n <= 30; n++) {
      expect(mulk.arabic, contains(quranVerses['67:$n']!));
    }
    int number(String s) =>
        int.parse(s.split('').map((c) => '٠١٢٣٤٥٦٧٨٩'.indexOf(c)).join());
    expect(
      RegExp(r'۝([٠-٩]+)').allMatches(mulk.arabic).map((m) => number(m[1]!)),
      List.generate(30, (i) => i + 1),
    );
    expect(mulk.arabic.trim().endsWith('۝٣٠'), true);
    expect(mulk.count, 1);
  });

  test('count choices, corrected counts, contextual timing and exclusions', () {
    DhikrEntry byId(String id) => entries.singleWhere((e) => e.id == id);
    for (final prefix in ['morning', 'evening']) {
      expect(byId('${prefix}_tahlil').allowedCounts, [1, 10, 100]);
      expect(byId('${prefix}_protection').count, 3);
      expect(byId('${prefix}_tasbih').count, 100);
      expect(byId('${prefix}_salawat').count, 1);
    }
    expect(byId('morning_creation').count, 3);
    expect(byId('sleep_protect_punishment').count, 1);
    expect(
      byId('sleep_protect_punishment').source,
      contains('دون قوله ثلاث مرار'),
    );
    expect(byId('sleep_tasbih').count, 33);
    expect(byId('sleep_tahmid').count, 33);
    expect(byId('sleep_takbir').count, 34);
    expect(byId('morning_knowledge').timing, contains('بعد السلام'));
    expect(byId('morning_istighfar').timing, contains('لا يخص'));
    expect(byId('morning_bika').arabic, contains('النُّشُورُ'));
    expect(byId('evening_bika').arabic, contains('الْمَصِيرُ'));
    expect(entries.any((e) => e.count == 7 || e.count == 4), false);
    expect(
      entries.any((e) => normalizeArabic(e.arabic).contains('حسبي الله')),
      false,
    );
    expect(
      byId('sleep_bad_dream').countDescription,
      contains('لا لتكرار الحديث'),
    );
    expect(
      byId('sleep_bad_dream').arabic,
      contains('وَلَا يُحَدِّثْ بِهَا النَّاسَ'),
    );
    expect(byId('sleep_bad_dream').source, contains('٢٢٦٣a'));
  });
}
