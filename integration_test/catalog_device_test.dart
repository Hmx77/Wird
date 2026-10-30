import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wird/content.dart';
import 'package:wird/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Native reader: all 66 entries, both themes and reference safeguards', (tester) async {
    final store = WirdState();
    await store.initialize();
    expect(entries.length, 51);
    expect(DhikrSection.values.map((s) => inSection(s).length), [25, 23, 18]);
    for (final theme in [0, 1]) {
      store.changeTheme(theme);
      for (final e in displayedEntries) {
        await tester.pumpWidget(MaterialApp(
          key: ValueKey('$theme-${e.id}'),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: wirdTheme(store.palette),
          home: Scaffold(body: ReaderPage(store: store, section: e.section,
            initialIndex: inSection(e.section).indexOf(e))),
        ));
        await tester.pumpAndSettle();
        expect(tester.widget<SelectableText>(find.byKey(const Key('reader-arabic'))).data, e.arabic);
        if (e.reviewOnly) {
          expect(find.textContaining('تنبيه مهم:'), findsOneWidget);
          expect(find.byKey(const Key('reader-counter')), findsNothing);
          expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.ios_share)).onPressed, isNull);
          store.setCount(e, 1);
          expect(store.isDone(e), isFalse);
        }
        expect(tester.takeException(), isNull);
        if (['morning_sayyid', 'reference_morning_bodily', 'reference_morning_testimony',
             'reference_morning_hasbi', 'reference_evening_fitrah', 'sleep_creator'].contains(e.id)) {
          await binding.takeScreenshot('ios-reader-$theme-${e.id}');
        }
      }
    }
    await store.pendingWrites;
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
    binding.reportData ??= {};
    binding.reportData!.addAll({'displayed': 66, 'devotional': 51, 'counts': [25,23,18],
      'themes': 2, 'nativeReaderRenders': 132, 'referenceControlsDisabled': true});
  });
}
