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
import 'package:wird/share_card.dart';
import 'package:wird/ui_strings.dart';
import 'fixtures/library_before.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('NotoSansArabic')
      ..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  Future<WirdState> state({int theme = 0, String language = 'ar'}) async {
    SharedPreferences.setMockInitialValues({
      'haptics': false,
      appearancePreference: appearanceIds[theme],
      'language': language,
    });
    final s = WirdState();
    await s.initialize();
    return s;
  }

  Widget app(
    WirdState s,
    Widget page, {
    double scale = 1,
    GlobalKey? capture,
  }) => RepaintBoundary(
    key: capture,
    child: AnimatedBuilder(
      animation: s,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(s.languageCode),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: wirdTheme(s.palette),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: page),
      ),
    ),
  );
  Future<void> reveal(WidgetTester t, Finder target) async {
    final viewport = find.byType(Scrollable).first;
    final position = t.state<ScrollableState>(viewport).position;
    position.jumpTo(position.minScrollExtent);
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      target,
      250,
      scrollable: viewport,
      maxScrolls: 300,
    );
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String key) async {
    final f = find.byKey(Key(key));
    await reveal(t, f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> close(WidgetTester t, WirdState s) async {
    await s.pendingWrites;
    await t.pumpWidget(const SizedBox.shrink());
    s.dispose();
  }

  for (final lang in ['ar', 'en']) {
    for (var theme = 0; theme < themes.length; theme++) {
      testWidgets(
        'Premium library and reader $lang theme $theme 320px 200% text',
        (t) async {
          t.view.physicalSize = const Size(320, 700);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);
          final s = await state(theme: theme, language: lang);
          await t.pumpWidget(app(s, LibraryPage(store: s), scale: 2));
          await t.pumpAndSettle();
          expect(
            Directionality.of(t.element(find.byType(LibraryPage))),
            lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          );
          await reveal(t, find.byKey(Key('library-entry-${entries.first.id}')));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          await t.pumpWidget(
            app(
              s,
              ReaderPage(store: s, section: DhikrSection.morning),
              scale: 2,
            ),
          );
          await t.pumpAndSettle();
          await tap(t, 'reader-evidence-toggle');
          for (final key in [
            'reader-font-increase',
            'reader-counter',
            'reader-next',
          ]) {
            await reveal(t, find.byKey(Key(key)));
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
          }
          await close(t, s);
        },
      );
    }
  }
  testWidgets(
    'Arabic search, English category search, bookmark filtering and reader route preserve IDs',
    (t) async {
      final s = await state();
      await t.pumpWidget(app(s, HomePage(store: s)));
      await t.pumpAndSettle();
      await tap(t, 'home-favorites');
      expect(
        t.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        s.palette.homeBackground,
      );
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
      await t.pumpWidget(app(s, LibraryPage(store: s)));
      await t.pumpAndSettle();
      expect(find.text('66 ذكر'), findsOneWidget);
      await t.enterText(find.byKey(const Key('library-search')), 'اللَّه');
      await t.pumpAndSettle();
      expect(find.byType(DevotionCard), findsWidgets);
      await t.enterText(find.byKey(const Key('library-search')), 'Evening');
      await t.pumpAndSettle();
      expect(find.text('23 ذكر'), findsOneWidget);
      await t.enterText(find.byKey(const Key('library-search')), 'zzzz');
      await t.pumpAndSettle();
      expect(find.text('لا توجد نتائج'), findsOneWidget);
      await t.enterText(find.byKey(const Key('library-search')), '');
      await t.pumpAndSettle();
      final e = entries.first;
      await tap(t, 'library-bookmark-${e.id}');
      expect(find.byType(ReaderPage), findsNothing);
      expect(s.favorites, contains(e.id));
      await tap(t, 'library-favorites');
      expect(find.text('1 ذكر'), findsOneWidget);
      final selectedChip = t.widget<FilterChip>(
        find.byKey(const Key('library-favorites')),
      );
      final selectedBackground = selectedChip.color!.resolve({
        WidgetState.selected,
      })!;
      final selectedForeground = (selectedChip.label as UiText).style!.color!;
      final light = selectedBackground.computeLuminance();
      final dark = selectedForeground.computeLuminance();
      expect(
        (light + .05) / (dark + .05),
        greaterThanOrEqualTo(4.5),
        reason:
            'Selected favorites must remain readable independently of the light Material chip theme',
      );
      await tap(t, 'library-entry-${e.id}');
      expect(find.byType(ReaderPage), findsOneWidget);
      expect(
        t.widget<SelectableText>(find.byKey(const Key('reader-arabic'))).data,
        e.arabic,
      );
      await s.pendingWrites;
      final restored = WirdState();
      await restored.initialize();
      expect(restored.favorites, contains(e.id));
      restored.dispose();
      await close(t, s);
    },
  );
  testWidgets(
    'Reader count Undo target alternatives navigation fonts and restart persistence',
    (t) async {
      final s = await state();
      final group = inSection(DhikrSection.morning);
      final e = group.first;
      await t.pumpWidget(app(s, ReaderPage(store: s, section: e.section)));
      await t.pumpAndSettle();
      await reveal(t, find.byKey(const Key('reader-previous')));
      expect(
        t
            .widget<OutlinedButton>(find.byKey(const Key('reader-previous')))
            .onPressed,
        isNull,
      );
      await tap(t, 'reader-counter');
      expect(s.count(e), 1);
      await tap(t, 'reader-undo');
      expect(s.count(e), 0);
      await tap(t, 'reader-counter');
      await s.pendingWrites;
      final restored = WirdState();
      await restored.initialize();
      expect(restored.count(e), 1);
      restored.dispose();
      await tap(t, 'reader-next');
      expect(
        t.widget<SelectableText>(find.byKey(const Key('reader-arabic'))).data,
        group[1].arabic,
      );
      await tap(t, 'reader-previous');
      expect(s.count(e), 1);
      await tap(t, 'reader-font-increase');
      expect(s.fontSize, 27);
      await tap(t, 'reader-evidence-toggle');
      expect(find.text(e.evidence), findsOneWidget);
      final alt = group.firstWhere((e) => e.countAlternatives.isNotEmpty);
      await t.pumpWidget(
        app(
          s,
          ReaderPage(
            key: const ValueKey('alternate'),
            store: s,
            section: alt.section,
            initialIndex: group.indexOf(alt),
          ),
        ),
      );
      await t.pumpAndSettle();
      final f = find.byKey(const Key('reader-count-choice'));
      await reveal(t, f);
      await t.pumpAndSettle();
      expect(
        t.widget<DropdownButton<int>>(f).items!.map((x) => x.value),
        alt.allowedCounts,
      );
      await t.tap(f);
      await t.pumpAndSettle();
      final alternative = alt.allowedCounts.last;
      await t.tap(find.text('عدد التكرار: $alternative').last);
      await t.pumpAndSettle();
      expect(s.target(alt), alternative);
      expect(s.count(alt), 0);
      await s.pendingWrites;
      final restoredTarget = WirdState();
      await restoredTarget.initialize();
      expect(restoredTarget.target(alt), alternative);
      restoredTarget.dispose();
      s.autoAdvance = true;
      await t.pumpWidget(
        app(
          s,
          ReaderPage(
            key: const ValueKey('automatic'),
            store: s,
            section: e.section,
          ),
        ),
      );
      await t.pumpAndSettle();
      s.setCount(e, 0);
      await t.pumpAndSettle();
      for (var i = 0; i < s.target(e); i++) {
        await tap(t, 'reader-counter');
      }
      expect(
        t.widget<SelectableText>(find.byKey(const Key('reader-arabic'))).data,
        group[1].arabic,
      );
      await close(t, s);
    },
  );
  for (final theme in [0, 1]) {
    testWidgets('Reference warnings and controls at 320dp and 200% theme $theme', (t) async {
      t.view.physicalSize = const Size(320, 700);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final s = await state(theme: theme);
      for (final e in referenceReviewEntries) {
        await t.pumpWidget(app(s, ReaderPage(key: ValueKey(e.id), store: s,
          section: e.section, initialIndex: inSection(e.section).indexOf(e)), scale: 2));
        await t.pumpAndSettle();
        final warning = find.textContaining('تنبيه مهم:');
        expect(warning, findsOneWidget);
        await reveal(t, warning);
        expect(t.widget<Text>(warning).data, contains(e.authenticity));
        expect(find.byKey(const Key('reader-counter')), findsNothing);
        await reveal(t, find.byKey(const Key('reader-next')));
        expect(t.takeException(), isNull, reason: e.id);
      }
      await close(t, s);
    });
  }
  testWidgets(
    'All 66 reader entries expose the exact complete source text and large Mulk scrolls',
    (t) async {
      final s = await state();
      for (final e in displayedEntries) {
        await t.pumpWidget(
          app(
            s,
            ReaderPage(
              key: ValueKey(e.id),
              store: s,
              section: e.section,
              initialIndex: inSection(e.section).indexOf(e),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(
          t.widget<SelectableText>(find.byKey(const Key('reader-arabic'))).data,
          e.arabic,
        );
        if (e.reviewOnly) {
          expect(find.textContaining('تنبيه مهم:'), findsOneWidget);
          expect(find.byKey(const Key('reader-counter')), findsNothing);
          expect(find.byKey(const Key('reader-undo')), findsNothing);
          final share = t.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.ios_share));
          expect(share.onPressed, isNull);
          await expectLater(shareDhikrCard(t.element(find.byType(ReaderPage)), e, s.palette.homeBackground, s.palette.ink), throwsStateError);
        }
        expect(t.takeException(), isNull);
      }
      final mulk = entries.firstWhere((e) => e.id == 'sleep_mulk');
      s.changeFont(38);
      await t.pumpWidget(
        app(
          s,
          ReaderPage(
            key: const ValueKey('long-mulk'),
            store: s,
            section: mulk.section,
            initialIndex: inSection(mulk.section).indexOf(mulk),
          ),
          scale: 2,
        ),
      );
      await t.pumpAndSettle();
      await reveal(t, find.byKey(const Key('reader-counter')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await close(t, s);
    },
  );
  testWidgets(
    'Premium rendered library, reader evidence and large Quran captures',
    (t) async {
      if (Platform.environment['WIRD_REVIEW_IMAGES'] != '1') return;
      t.view.physicalSize = const Size(430, 932);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final s = await state();
      final boundary = GlobalKey();
      Future<void> capture(String name) async {
        await t.pumpAndSettle();
        final r =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        r.markNeedsPaint();
        await t.pump();
        await t.pumpAndSettle();
        await t.runAsync(() async {
          final image = await r.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          Directory('verification/screenshots').createSync(recursive: true);
          File(
            'verification/screenshots/$name.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await t.pumpWidget(
        app(s, BaselineLibraryPage(store: s), capture: boundary),
      );
      await capture('library-before-build16');
      await t.pumpWidget(app(s, LibraryPage(store: s), capture: boundary));
      await capture('library-premium-ar');
      await tap(t, 'library-bookmark-${entries.first.id}');
      await tap(t, 'library-favorites');
      await capture('library-premium-favorites');
      await t.pumpWidget(
        app(
          s,
          ReaderPage(store: s, section: DhikrSection.evening),
          capture: boundary,
        ),
      );
      await capture('reader-premium-main');
      await tap(t, 'reader-evidence-toggle');
      await reveal(t, find.text(inSection(DhikrSection.evening).first.meaning));
      await capture('reader-premium-evidence');
      await reveal(t, find.byKey(const Key('reader-next')));
      await capture('reader-premium-counter');
      final e = entries.firstWhere((e) => e.id == 'sleep_mulk');
      s.changeFont(38);
      await t.pumpWidget(
        app(
          s,
          ReaderPage(
            key: const ValueKey('mulk-capture'),
            store: s,
            section: e.section,
            initialIndex: inSection(e.section).indexOf(e),
          ),
          capture: boundary,
          scale: 1.5,
        ),
      );
      await capture('reader-premium-mulk-large');
      await close(t, s);
    },
  );
}
