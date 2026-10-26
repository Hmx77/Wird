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
    expect(inSection(DhikrSection.morning), hasLength(18));
    expect(inSection(DhikrSection.evening), hasLength(15));
    expect(inSection(DhikrSection.sleep), hasLength(18));
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
