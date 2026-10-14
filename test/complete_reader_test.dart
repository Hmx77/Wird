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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('NotoSansArabic')
      ..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'));
    await font.load();
  });
  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    if (Platform.environment['WIRD_REVIEW_IMAGES'] != '1') return;
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.5);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory('verification/screenshots').createSync(recursive: true);
      File(
        'verification/screenshots/$name.png',
      ).writeAsBytesSync(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  for (final language in ['ar', 'en']) {
    for (final id in ['sleep_mulk', 'sleep_bad_dream', 'morning_tahlil']) {
      testWidgets(
        'complete offline reader $id $language with large Arabic text',
        (tester) async {
          tester.view.physicalSize = const Size(430, 932);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          SharedPreferences.setMockInitialValues({
            'haptics': false,
            'language': language,
            'font': 38.0,
          });
          final state = WirdState();
          await state.initialize();
          final entry = entries.singleWhere((e) => e.id == id);
          final index = inSection(entry.section).indexOf(entry);
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
                  scaffoldBackgroundColor: state.palette.background,
                ),
                home: ReaderPage(
                  store: state,
                  section: entry.section,
                  initialIndex: index,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final text = tester.widget<SelectableText>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is SelectableText && widget.data == entry.arabic,
            ),
          );
          expect(text.maxLines, isNull);
          expect(text.textDirection, TextDirection.rtl);
          expect(tester.takeException(), isNull);
          await capture(tester, key, 'complete-$id-$language-top');
          if (id == 'morning_tahlil') {
            await tester.scrollUntilVisible(
              find.byType(DropdownButton<int>),
              300,
              scrollable: find.byType(Scrollable).last,
            );
            await tester.tap(find.byType(DropdownButton<int>));
            await tester.pumpAndSettle();
            final label = language == 'ar'
                ? 'عدد التكرار: 10'
                : 'Repetition count: 10';
            await tester.tap(find.text(label).last);
            await tester.pumpAndSettle();
            expect(state.target(entry), 10);
            await tester.scrollUntilVisible(
              find.text('0 / 10'),
              200,
              scrollable: find.byType(Scrollable).last,
            );
            final countButton = find.text(
              language == 'ar' ? 'اضغط للعدّ' : 'Tap to count',
            );
            await tester.scrollUntilVisible(
              countButton,
              200,
              scrollable: find.byType(Scrollable).last,
            );
            await tester.pumpAndSettle();
            await tester.tap(countButton);
            await tester.pump();
            expect(find.text('1 / 10'), findsOneWidget);
            expect(state.count(entry), 1);
          } else {
            await tester.scrollUntilVisible(
              find.text('0 / 1'),
              600,
              scrollable: find.byType(Scrollable).last,
              maxScrolls: 100,
            );
          }
          await tester.pumpAndSettle();
          await capture(tester, key, 'complete-$id-$language-counter');
          expect(tester.takeException(), isNull);
          await state.pendingWrites;
          await tester.pumpWidget(const SizedBox.shrink());
          state.dispose();
        },
      );
    }
  }
  testWidgets('full Mulk renders without overflow in all ten existing themes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'haptics': false});
    final state = WirdState();
    await state.initialize();
    final mulk = entries.singleWhere((e) => e.id == 'sleep_mulk');
    for (var i = 0; i < themes.length; i++) {
      state.changeTheme(i);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'NotoSansArabic',
            scaffoldBackgroundColor: state.palette.background,
          ),
          home: ReaderPage(
            key: ValueKey(i),
            store: state,
            section: DhikrSection.sleep,
            initialIndex: inSection(DhikrSection.sleep).indexOf(mulk),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(mulk.arabic), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await state.pendingWrites;
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
