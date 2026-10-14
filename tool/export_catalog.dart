import 'dart:convert';
import 'dart:io';
import '../lib/content.dart';

void main() {
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'reviewDate': '2026-10-14',
      'reviewLevel': 'source-checked; independent release proofreading pending',
      'entries': entries
          .map(
            (e) => {
              'id': e.id,
              'section': e.section.name,
              'arabic': e.arabic,
              'count': e.count,
              'countDescription': e.countDescription,
              'countAlternatives': e.countAlternatives,
              'referenceScreens': e.referenceScreens,
              'quranSourceUrl': e.quranSourceUrl,
              'source': e.source,
              'sourceUrl': e.sourceUrl,
              'timing': e.timing,
              'benefit': e.benefit,
              'meaning': e.meaning,
              'reviewed': e.reviewed,
            },
          )
          .toList(),
    }),
  );
}
