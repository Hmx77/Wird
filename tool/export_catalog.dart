import 'dart:convert';
import 'dart:io';
import 'package:wird/content.dart';

void main() {
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'reviewDate': '2026-10-26',
      'reviewLevel': 'source-checked; independent release proofreading pending',
      'devotionalCount': entries.length,
      'displayedCount': displayedEntries.length,
      'entries': displayedEntries
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'reviewOnly': e.reviewOnly,
              'authenticity': e.authenticity,
              'evidence': e.evidence,
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
