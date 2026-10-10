import 'package:flutter_test/flutter_test.dart';
import 'package:wird/content.dart';

void main() {
  test(
    'all starter entries are categorized, sourced and uniquely identified',
    () {
      expect(entries.map((e) => e.id).toSet().length, entries.length);
      for (final e in entries) {
        expect(e.count, greaterThan(0));
        expect(e.arabic.trim(), isNotEmpty);
        expect(e.source.trim(), isNotEmpty);
        expect(e.evidence.trim(), isNotEmpty);
        expect(e.source.contains('ضعيف'), false);
      }
      expect(
        inSection(DhikrSection.sleep).any((e) => e.id == 'sleep_bismika'),
        true,
      );
    },
  );
}
