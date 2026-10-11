import 'package:wird/content.dart';
import 'dart:io';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main() {
  check(entries.isNotEmpty, 'Empty corpus');
  check(
    entries.map((e) => e.id).toSet().length == entries.length,
    'Duplicate IDs',
  );
  for (final e in entries) {
    check(e.reviewed, 'Unreviewed entry exposed: ${e.id}');
    check(
      e.count > 0 &&
          e.arabic.isNotEmpty &&
          e.timing.isNotEmpty &&
          e.benefit.isNotEmpty,
      'Missing content ${e.id}',
    );
    check(
      Uri.parse(e.sourceUrl).host == 'sunnah.com',
      'Unexpected source ${e.id}',
    );
    check(e.source.contains('صحيح'), 'Missing Sahih reference ${e.id}');
  }
  for (final section in DhikrSection.values) {
    check(inSection(section).isNotEmpty, 'Empty section $section');
  }
  int count(String id) => entries.singleWhere((e) => e.id == id).count;
  check(
    count('morning_tasbih') == 100 && count('evening_tasbih') == 100,
    'Muslim 2692 count',
  );
  check(count('morning_creation') == 3, 'Muslim 2726a count');
  check(
    count('sleep_tasbih') == 33 &&
        count('sleep_tahmid') == 33 &&
        count('sleep_takbir') == 34,
    'Muslim 2727a counts',
  );
  check(count('sleep_ikhlas_falaq_nas') == 3, 'Bukhari 5017 count');
  check(
    normalizeArabic('أَذْكَارُ الصَّبَاحِ') == normalizeArabic('اذكار الصباح'),
    'Diacritic search',
  );
  check(
    !entries.any((e) => e.arabic.contains('حَسْبِيَ اللَّهُ') && e.count == 7),
    'Excluded disputed count',
  );
  stdout.writeln(
    'PASS: ${entries.length} entries; unique IDs, admission gate, sections, sources, prescribed counts, Arabic search.',
  );
  stdout.writeln(
    'This is a data regression check, not a scholarly authentication test.',
  );
}
