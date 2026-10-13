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

    final firstEntry = inSection(DhikrSection.morning).first;
    final initialCounter = find.text('0 / ${firstEntry.count}');

    // Scroll to the counter before checking it.
    await tester.scrollUntilVisible(
      initialCounter,
      200,
      scrollable: find.byType(Scrollable).last,
    );

    expect(initialCounter, findsOneWidget);

    // Tap the repetition counter once.
    final countButton = find.text('اضغط للعدّ');

    await tester.scrollUntilVisible(
      countButton,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(countButton);
    await tester.pump();

    expect(store.count(firstEntry), 1);
    expect(find.text('1 / ${firstEntry.count}'), findsOneWidget);

    // Verify the favorite button updates state.
    await tester.tap(find.byTooltip('المفضلة'));
    await tester.pump();

    expect(store.favorites, contains(firstEntry.id));

    await store.pendingWrites;
    await tester.pumpWidget(const SizedBox());
    store.dispose();
  });
}
