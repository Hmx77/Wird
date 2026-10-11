import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/content.dart';
import 'package:wird/main.dart';

void main() {
  testWidgets('reader reflects counter and favorite changes immediately', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'haptics': false});
    final store = WirdState();
    await store.initialize();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: ReaderPage(store: store, section: DhikrSection.morning),
        ),
  );
  await tester.pumpAndSettle();
  expect(find.text('0 / 1'), findsOneWidget);
    await tester.ensureVisible(find.text('اضغط للعدّ'));
    await tester.tap(find.text('اضغط للعدّ'));
    await tester.pump();
    expect(find.text('1 / 1'), findsOneWidget);
    await tester.tap(find.byTooltip('المفضلة'));
    await tester.pump();
    expect(store.favorites, contains(inSection(DhikrSection.morning).first.id));
    await store.pendingWrites;
    await tester.pumpWidget(const SizedBox());
    store.dispose();
  });
}
