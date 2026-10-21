import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/content.dart';
import 'package:wird/main.dart';
import 'package:wird/ui_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'language preference survives reopening and rejects unsupported codes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final state = WirdState();
      await state.initialize();
      expect(state.languageCode, 'ar');
      state.changeLanguage('en');
      await state.pendingWrites;
      final reopened = WirdState();
      await reopened.initialize();
      expect(reopened.languageCode, 'en');
      reopened.changeLanguage('unknown');
      expect(reopened.languageCode, 'ar');
      await reopened.pendingWrites;
      state.dispose();
      reopened.dispose();
    },
  );
  testWidgets(
    'English reader keeps religious text RTL and clamps invalid index',
    (tester) async {
      SharedPreferences.setMockInitialValues({'haptics': false});
      final state = WirdState();
      await state.initialize();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: ReaderPage(
            store: state,
            section: DhikrSection.morning,
            initialIndex: -9,
          ),
        ),
      );
      expect(find.text('Morning Athkar'), findsOneWidget);
      expect(find.byTooltip('Favorites'), findsOneWidget);
      final text = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(text.data, inSection(DhikrSection.morning).first.arabic);
      expect(text.textDirection, TextDirection.rtl);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    },
  );
  testWidgets(
    'both premium themes load the original asset and English home labels',
    (tester) async {
      SharedPreferences.setMockInitialValues({'language': 'en'});
      final state = WirdState();
      await state.initialize();
      for (var i = 0; i < themes.length; i++) {
        state.changeTheme(i);
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: wirdTheme(state.palette),
            home: Scaffold(body: HomePage(store: state)),
          ),
        );
        await tester.pump();
        expect(find.text('Morning Athkar'), findsOneWidget);
        final logo = tester.widget<Image>(find.descendant(
          of: find.byKey(const Key('home-wordmark')), matching: find.byType(Image))); 
        expect(
          (logo.image as AssetImage).assetName,
          'assets/brand/wird_wordmark.png',
        );
        expect(logo.fit, BoxFit.contain);
        expect(tester.takeException(), isNull);
      }
      await state.pendingWrites;
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    },
  );
  test('UI translation never rewrites religious text', () {
    for (final entry in entries) {
      expect(uiString(entry.arabic, 'en'), entry.arabic);
    }
    expect(uiString('2 / 6 مكتمل', 'en'), '2 / 6 complete');
  });
}

