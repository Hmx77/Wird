import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/content.dart';
import 'package:wird/main.dart';
import 'package:wird/ui_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('NotoSansArabic');
    font.addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  test('all ten theme identities have Arabic and English UI names', () {
    expect(themes.length, 10);
    expect(themeArabic.length, 10);
    for (final theme in themes) {
      expect(uiString(theme.name, 'ar'), themeArabic[theme.name]);
      expect(uiString(theme.name, 'ar'), isNot(theme.name));
      expect(uiString(theme.name, 'en'), theme.name);
    }
  });
  testWidgets(
    'four tabs and sujood; stored activity survives hidden tracking',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'language': 'ar',
        'theme': 8,
        'haptics': false,
        'favorites': <String>['morning_sayyid'],
      });
      final store = WirdState();
      await store.initialize();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: WirdShell(store: store),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.text('متابعتي'), findsNothing);
      expect(find.byType(ProgressPage), findsNothing);
      expect(find.byType(SujoodIcon), findsWidgets);
      expect(store.favorites, contains('morning_sayyid'));
      await tester.tap(find.text('الإعدادات'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('زيتوني وكريمي'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('زيتوني وكريمي'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await store.pendingWrites;
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
    },
  );
  for (final language in ['ar', 'en']) {
    for (final size in [
      const Size(320, 640),
      const Size(430, 932),
      const Size(1024, 1366),
    ]) {
      testWidgets('responsive home $language ${size.width} with large text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({
          'language': language,
          'haptics': false,
        });
        final store = WirdState();
        await store.initialize();
        final boundary = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: Locale(language),
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: ThemeData(fontFamily: 'NotoSansArabic'),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              home: WirdShell(store: store),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (Platform.environment['WIRD_REVIEW_IMAGES'] == '1') {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await render.toImage(pixelRatio: 1.5);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            final dir = Directory('verification/screenshots')
              ..createSync(recursive: true);
            File(
              '${dir.path}/home-$language-${size.width.toInt()}.png',
            ).writeAsBytesSync(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        await store.pendingWrites;
        await tester.pumpWidget(const SizedBox.shrink());
        store.dispose();
      });
    }
  }
  for (final language in ['ar', 'en']) {
    testWidgets('reader favorites settings and Nawafil flow $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'language': language,
        'haptics': false,
      });
      final store = WirdState();
      await store.initialize();
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(language),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: ThemeData(
              fontFamily: 'NotoSansArabic',
              scaffoldBackgroundColor: store.palette.background,
            ),
            home: WirdShell(store: store),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        expect(tester.takeException(), isNull);
        if (Platform.environment['WIRD_REVIEW_IMAGES'] != '1') return;
        final render =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await render.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          Directory('verification/screenshots').createSync(recursive: true);
          File(
            'verification/screenshots/$name-$language.png',
          ).writeAsBytesSync(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await tester.tap(find.byKey(const Key('home-morning')));
      await tester.pumpAndSettle();
      await capture('reader');
      final countButton = find.text(uiString('اضغط للعدّ', language));
      await tester.scrollUntilVisible(
        countButton,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(countButton);
      await tester.pump();
      expect(store.counts.values, contains(1));
      await tester.tap(find.byTooltip(uiString('المفضلة', language)));
      await tester.pump();
      expect(
        store.favorites,
        contains(inSection(DhikrSection.morning).first.id),
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(uiString('النوافل', language)));
      await tester.pumpAndSettle();
      await capture('nawafil');
      await tester.tap(find.text(uiString('الإعدادات', language)));
      await tester.pumpAndSettle();
      await capture('settings');
      await tester.drag(find.byType(ListView).last, const Offset(0, -600));
      await tester.pumpAndSettle();
      await capture('themes');
      await store.pendingWrites;
      final reopened = WirdState();
      await reopened.initialize();
      expect(
        reopened.favorites,
        contains(inSection(DhikrSection.morning).first.id),
      );
      expect(reopened.counts, store.counts);
      expect(reopened.languageCode, language);
      await tester.pumpWidget(const SizedBox.shrink());
      reopened.dispose();
      store.dispose();
    });
  }
}
