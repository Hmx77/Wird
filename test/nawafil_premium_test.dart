import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/main.dart';

void main() {
  test('Arabic fractions and source ranges retain logical order and exact wording', () {
    expect(nawafilDirectionalText('0 / 5 مجموعات'), '\u20660 / 5\u2069 مجموعات');
    final note = nawafilDirectionalText(rawatibSourceNote);
    expect(note, contains('\u20661180–1181\u2069'));
    expect(note.replaceAll(RegExp('[\u2066\u2069]'), ''), rawatibSourceNote);
  });
  Future<WirdState> mount(WidgetTester tester, {int theme = 8, String language = 'ar', double scale = 1}) async {
    SharedPreferences.setMockInitialValues({'haptics': false, 'theme': theme});
    final store = WirdState(now: () => DateTime(2026, 10, 18, 12));
    await store.initialize();
    await tester.pumpWidget(MaterialApp(
      locale: Locale(language), supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: wirdTheme(store.palette),
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
      home: Scaffold(body: NawafilPage(store: store)),
    ));
    await tester.pumpAndSettle();
    return store;
  }
  Future<void> finish(WidgetTester tester, WirdState store) async {
    await store.pendingWrites;
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  }
  testWidgets('rawatib group toggles derive rakahs and persist unchanged IDs', (tester) async {
    final store = await mount(tester);
    expect(find.text('0/12'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('prayer-dhuhr_before')));
    await tester.tap(find.byKey(const Key('prayer-dhuhr_before')));
    await tester.pumpAndSettle();
    expect(store.prayerDone('dhuhr_before'), isTrue);
    expect(find.text('4/12'), findsOneWidget);
    expect(find.text('\u20661 / 5\u2069 مجموعات سُجّلت اليوم'), findsOneWidget);
    await store.pendingWrites;
    final restored = WirdState(now: () => DateTime(2026, 10, 18, 12));
    await restored.initialize();
    expect(restored.prayerDone('dhuhr_before'), isTrue);
    expect(restored.prayerDone('dhuhr_before', '2026-10-19'), isFalse);
    restored.dispose();
    await tester.tap(find.byKey(const Key('prayer-dhuhr_before')));
    await tester.pumpAndSettle();
    expect(store.prayerDone('dhuhr_before'), isFalse);
    for(final id in ['duha', 'witr', 'night']) {
      await tester.ensureVisible(find.byKey(Key('prayer-$id')));
      await tester.tap(find.byKey(Key('prayer-$id')));
      await tester.pumpAndSettle();
      expect(store.prayerDone(id), isTrue);
    }
    expect(find.text('0/12'), findsOneWidget, reason: 'Other prayers do not alter rawatib progress');
    await finish(tester, store);
  });
  for(final language in ['ar', 'en']) {
    for(var index=0; index<10; index++) {
      testWidgets('botanical prayers theme $index $language small screen 200% text', (tester) async {
        tester.view.physicalSize=const Size(320, 700); tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
        final store=await mount(tester, theme:index, language:language, scale:2);
        expect(Directionality.of(tester.element(find.byType(NawafilPage))), language=='ar'?TextDirection.rtl:TextDirection.ltr);
        for(final id in ['fajr_before','isha_after','duha','witr','night']) {
          await tester.ensureVisible(find.byKey(Key('prayer-$id')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(find.text(nawafilDirectionalText(rawatibSourceNote)), findsOneWidget);
        expect(find.byType(SujoodIcon), findsNWidgets(2));
        await finish(tester, store);
      });
    }
  }
}
