import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/content.dart';
import 'package:wird/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('all original payloads and IDs are unchanged; additions are separate', () {
    final baseline = jsonDecode(File('docs/content-review-20261026/baseline-catalog.json').readAsStringSync()) as Map<String, dynamic>;
    final old = baseline['entries'] as List;
    expect(old, hasLength(49));
    for (final row in old) {
      final e = entries.singleWhere((e) => e.id == row['id']);
      expect(e.section.name, row['section']);
      expect(e.title, row['title']);
      expect(e.arabic, row['arabic']);
      expect(e.source, row['source']);
      expect(e.sourceUrl, row['sourceUrl']);
      expect(e.count, row['count']);
      expect(e.countAlternatives, row['countAlternatives']);
      expect(e.countDescription, row['countDescription']);
      expect(e.meaning, row['meaning']);
      expect(e.benefit, row['benefit']);
      expect(e.evidence, row['evidence']);
      expect(e.timing, row['timing']);
      expect(e.referenceScreens, row['referenceScreens']);
      expect(e.isQuran, row['isQuran']);
      expect(e.quranSourceUrl, row['quranSourceUrl']);
    }
    expect(entries.where((e) => !old.any((r) => r['id'] == e.id)).map((e) => e.id).toSet(), expandedSleepEntryIds);
    expect(inSection(DhikrSection.morning).where((e) => !e.reviewOnly), hasLength(18));
    expect(inSection(DhikrSection.morning), hasLength(25));
    expect(inSection(DhikrSection.evening).where((e) => !e.reviewOnly), hasLength(15));
    expect(inSection(DhikrSection.evening), hasLength(23));
    expect(inSection(DhikrSection.sleep), hasLength(18));
  });
  test('all 51 development-admitted payloads match the immutable audit', () {
    final audit = jsonDecode(File('docs/content-audit.json').readAsStringSync()) as Map<String, dynamic>;
    final rows = audit['entries'] as List;
    expect(rows, hasLength(51));
    expect(entries.map((e) => e.id), rows.map((e) => e['id']));
    for (final row in rows) {
      final e = entries.singleWhere((e) => e.id == row['id']);
      final actual = <String, dynamic>{
        'id': e.id, 'section': e.section.name, 'title': e.title,
        'arabic': e.arabic, 'count': e.count, 'source': e.source,
        'sourceUrl': e.sourceUrl, 'evidence': e.evidence,
        'meaning': e.meaning, 'benefit': e.benefit, 'isQuran': e.isQuran,
        'countDescription': e.countDescription, 'timing': e.timing,
        'reviewed': e.reviewed, 'referenceScreens': e.referenceScreens,
        'countAlternatives': e.countAlternatives, 'quranSourceUrl': e.quranSourceUrl,
      };
      for (final field in actual.keys) {
        expect(actual[field], row[field], reason: '${e.id}: $field');
      }
      expect(e.reviewOnly, isFalse);
    }
  });
  test('reference-only counters cannot mutate storage or worship completion', () async {
    SharedPreferences.setMockInitialValues({'haptics': false});
    final s = WirdState();
    await s.initialize(); await s.pendingWrites;
    for (final e in referenceReviewEntries) {
      s.setCount(e, 1); s.chooseCount(e, 1);
      expect(s.isDone(e), isFalse);
      expect(s.count(e), 0);
    }
    await s.pendingWrites;
    expect(s.counts, isEmpty);
    expect(s.countTargets, isEmpty);
    expect(s.countChoices, isEmpty);
    expect(DhikrSection.values.map(s.sectionTotal), [18, 15, 18]);
    expect(DhikrSection.values.map(s.completed), [0, 0, 0]);
    for (final e in entries) { s.setCount(e, s.target(e)); }
    for (final e in referenceReviewEntries) { s.toggleFavorite(e.id); }
    await s.pendingWrites;
    expect(DhikrSection.values.map(s.completed), [18, 15, 18]);
    final reopened = WirdState();
    await reopened.initialize();
    expect(reopened.favorites, containsAll(referenceReviewEntries.map((e) => e.id)));
    expect(DhikrSection.values.map(reopened.completed), [18, 15, 18]);
    expect(reopened.counts.keys.any((key) => key.contains('|reference_')), isFalse);
    await reopened.pendingWrites;
    reopened.dispose();
    s.dispose();
  });
  test('all 66 reference screens display transparently without treating weak reports as verified worship', () {
    expect(displayedEntries.length, 66);
    final pending = displayedEntries.where((entry) => entry.reviewOnly).toList();
    expect(pending, hasLength(15));
    expect(pending.map((e) => e.id).toSet(), hasLength(15));
    for (final section in [DhikrSection.morning, DhikrSection.evening]) {
      final collection = inSection(section);
      expect(collection.map((e) => e.referenceScreens.first),
          List.generate(collection.length, (index) => index + 1));
      expect(collection.where((e) => e.reviewOnly).length,
          section == DhikrSection.morning ? 7 : 8);
    }
    for (final e in pending) {
      expect(e.reviewOnly, isTrue);
      expect(e.authenticity, isNotEmpty);
      expect(e.evidence, contains('درجة الرواية:'));
      expect(e.countDescription, contains('لا تدخل في عداد'));
      expect(e.benefit, contains('للعرض والتوثيق فقط'));
    }
    expect(entries.any((e) => e.reviewOnly), isFalse);
  });
  test('alternative evidence and tracking counts cannot inherit excluded claims', () {
    final additions = jsonDecode(File('docs/content-review-20261026/additions.json').readAsStringSync()) as List;
    final sources = jsonDecode(File('docs/content-review-20261026/retrieval-check.json').readAsStringSync()) as List;
    String letters(String text) => normalizeArabic(text).replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
    for (final row in additions) {
      final e = entries.singleWhere((e) => e.id == row['id']);
      expect(e.arabic, row['arabic']);
      final primary = sources.singleWhere((source) => source['url'] == e.sourceUrl);
      for (final passage in e.arabic.split('\n\n')) {
        expect(letters(primary['arabicPrimaryText'] as String), contains(letters(passage)));
      }
      expect(e.evidence, row['evidence']);
      expect(e.sourceUrl, row['sourceUrl']);
      expect(e.timing, row['timing']);
      expect(e.benefit, row['benefit']);
      expect(e.countDescription, row['countDescription']);
      expect(e.count, 1);
      expect(e.allowedCounts, [1]);
      expect(e.referenceScreens, isEmpty);
      expect(normalizeArabic(e.title), isNotEmpty);
    }
    final waking = entries.singleWhere((e) => e.id == 'sleep_night_waking');
    expect(waking.timing, contains('أثناء الليل'));
    expect(waking.timing, contains('ليس'));
    expect(waking.benefit, contains('إذا توضأ وصلى'));
    final creator = entries.singleWhere((e) => e.id == 'sleep_creator');
    expect(creator.arabic, entries.singleWhere((e) => e.id == 'morning_creator').arabic);
    expect(creator.evidence, contains('أخذ مضجعه'));
  });
  for (final theme in [0, 1]) {
    test('legacy data and past completion survive expansion and restart theme $theme', () async {
      final baseline = jsonDecode(File('docs/content-review-20261026/baseline-catalog.json').readAsStringSync()) as Map<String, dynamic>;
      final old = (baseline['entries'] as List).where((e) => e['section'] == 'sleep');
      final counts = {for (final e in old) '2026-11-01|${e['id']}': e['count']};
      final savedCounts = jsonEncode(counts);
      SharedPreferences.setMockInitialValues({
        'counts': savedCounts, 'favorites': ['sleep_mulk', 'morning_sayyid'],
        'prayers': ['2026-11-01|fajr_before'], 'tasbih': 37, 'font': 31.0,
        'haptics': false, 'advance': false, 'language': 'ar',
        appearancePreference: appearanceIds[theme],
        'reminder.morning.hour': 8, 'reminder.morning.minute': 15,
      });
      final s = WirdState(now: () => DateTime(2026, 11, 2));
      await s.initialize(); await s.pendingWrites;
      expect(s.sectionTotal(DhikrSection.sleep, '2026-11-01'), 16);
      expect(s.completed(DhikrSection.sleep, '2026-11-01'), 16);
      expect(s.sectionTotal(DhikrSection.sleep), 18);
      expect(DhikrSection.values.expand((section) => s.progressEntries(section, '2026-11-01')), hasLength(49));
      expect(DhikrSection.values.expand((section) => s.progressEntries(section)), hasLength(51));
      expect(s.favorites, {'sleep_mulk', 'morning_sayyid'});
      expect(s.tasbih, 37); expect(s.fontSize, 31); expect(s.themeIndex, theme);
      final p = await SharedPreferences.getInstance();
      expect(p.getString('counts'), savedCounts);
      expect(p.getInt('reminder.morning.minute'), 15);
      final added = entries.singleWhere((e) => e.id == 'sleep_night_waking');
      s.setCount(added, 1); s.toggleFavorite(added.id); await s.pendingWrites;
      final reopened = WirdState(now: () => DateTime(2026, 11, 3));
      await reopened.initialize(); await reopened.pendingWrites;
      expect(reopened.contentExpandedOn, '2026-11-02');
      expect(reopened.completed(DhikrSection.sleep, '2026-11-01'), 16);
      expect(reopened.sectionTotal(DhikrSection.sleep, '2026-11-01'), 16);
      expect(reopened.count(added, '2026-11-02'), 1);
      expect(reopened.favorites, containsAll(['sleep_mulk', 'morning_sayyid', added.id]));
      expect(reopened.prayers, contains('2026-11-01|fajr_before'));
      s.dispose(); reopened.dispose();
    });
  }
}
