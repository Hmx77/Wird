import 'dart:convert';
import 'dart:io';
import 'package:wird/content.dart';

void main() {
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'reviewDate': '2026-10-09',
      'reviewLevel': 'source-checked; independent release proofreading pending',
      'entries': entries
          .map(
            (e) => {
              'id': e.id,
              'section': e.section.name,
              'arabic': e.arabic,
              'count': e.count,
              'countDescription': e.countDescription,
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
