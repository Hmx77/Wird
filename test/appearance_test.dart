import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/main.dart';
import 'package:wird/content.dart';

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

  for (var legacy = 0; legacy < 10; legacy++) {
    test('legacy palette $legacy migrates without touching worship data', () async {
      final original = <String, Object>{
        'theme': legacy, 'tasbih': 37, 'favorites': <String>['morning_sayyid'],
        'counts': '{"2026-10-20|morning_sayyid":1}',
        'prayers': <String>['2026-10-20|fajr_before'],
        'font': 29.0, 'language': 'en', 'haptics': false, 'advance': true,
        'reminder.morning.hour': 9, 'reminder.morning.enabled': true,
      };
      SharedPreferences.setMockInitialValues(original);
      final s = WirdState(); await s.initialize(); await s.pendingWrites;
      expect(s.themeIndex, [0, 1, 2, 3, 4, 7, 9].contains(legacy) ? 1 : 0);
      expect(s.tasbih, 37); expect(s.fontSize, 29); expect(s.languageCode, 'en');
      final prefs = await SharedPreferences.getInstance();
      for (final key in original.keys) {
        expect(prefs.get(key), original[key], reason: key);
      }
      expect(prefs.getString(appearancePreference), appearanceIds[s.themeIndex]);
      final reopened = WirdState(); await reopened.initialize();
      expect(reopened.themeIndex, s.themeIndex);
      s.dispose(); reopened.dispose();
    });
  }
  test('new users default dark; rapid appearance writes save the final choice', () async {
    SharedPreferences.setMockInitialValues({'tasbih': 11});
    final s = WirdState(); await s.initialize(); expect(s.themeIndex, 0);
    for (var i = 0; i < 21; i++) { s.changeTheme(i % 2); }
    s.changeTheme(1); await s.pendingWrites;
    final reopened = WirdState(); await reopened.initialize();
    expect(reopened.themeIndex, 1); expect(reopened.tasbih, 11);
    expect(themes.length, 2); s.dispose(); reopened.dispose();
  });
  test('saved stable appearance overrides legacy value; invalid IDs recover safely', () async {
    SharedPreferences.setMockInitialValues({'theme': 9, appearancePreference: 'midnight-teal'});
    var s = WirdState(); await s.initialize(); expect(s.themeIndex, 0); s.dispose();
    SharedPreferences.setMockInitialValues({'theme': 6, appearancePreference: 'unknown'});
    s = WirdState(); await s.initialize(); await s.pendingWrites;
    expect(s.themeIndex, 0); s.dispose();
  });
  test('primary reading text meets WCAG AA in both coordinated palettes', () {
    for (final p in themes) {
      final a = AppAppearance(p);
      for (final ink in [a.ink, a.muted, a.gold]) {
        final x = ink.computeLuminance(), y = p.homeSurface.computeLuminance();
        final ratio = ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
        expect(ratio, greaterThanOrEqualTo(4.5), reason: '${p.name} $ink');
      }
    }
  });

  Future<void> mount(WidgetTester t, WirdState s, Widget page, {double scale = 1}) async {
    await t.pumpWidget(AnimatedBuilder(animation: s, builder: (context, _) => MaterialApp(
      locale: Locale(s.languageCode), supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: wirdTheme(s.palette),
      builder: (context, child) => RepaintBoundary(key: const Key('appearance-capture'),
        child: MediaQuery(data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale)), child: child!)),
      home: Scaffold(body: page),
    )));
    await t.pumpAndSettle();
    await t.runAsync(() async {
      final context = t.element(find.byKey(const Key('appearance-capture')));
      await Future.wait([wirdWordmark, ivorySanctuary, ...homeArt.values,
        const AssetImage('assets/home/botanical-serenity.webp')]
        .map((image) => precacheImage(image, context)));
    });
    await t.pumpAndSettle();
  }
  Future<void> capture(WidgetTester t, String name) async {
    if (Platform.environment['WIRD_REVIEW_IMAGES'] != '1') return;
    await t.runAsync(() async {
      final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(const Key('appearance-capture')));
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final output = Directory('verification/screenshots')..createSync(recursive: true);
      File('${output.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      final text = <Map<String, Object?>>[];
      for (final e in find.byType(Text).evaluate()) {
        final render = e.findRenderObject();
        if (render is! RenderParagraph || !render.attached) continue;
        final origin = render.localToGlobal(Offset.zero);
        final color = render.text.style?.color;
        if (color == null) continue;
        text.add({'text': render.text.toPlainText(), 'argb': color.toARGB32(),
          'left': origin.dx, 'top': origin.dy,
          'width': render.size.width, 'height': render.size.height});
      }
      if (name == 'appearance-1-ar-home' &&
          Platform.environment['WIRD_BASELINE_RENDER'] != '1') {
        final raw = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        final checked = <Map<String, Object?>>[];
        const labels = ['وردك اليومي', 'ذِكْرٌ يُرَافِقُ يَوْمَكَ',
          'لحظات من السكينة', 'اختر وردك وابدأ القراءة', 'متابعة القراءة',
          'أذكار الصباح', 'أذكار المساء', 'أذكار النوم'];
        for (final item in text.where((item) => labels.contains(item['text']))) {
          final y = ((item['top'] as double) * 2).floor() + 1;
          if (y < 0 || y >= image.height) continue;
          final left = ((item['left'] as double) * 2).floor().clamp(0, image.width - 1);
          final end = (((item['left'] as double) + (item['width'] as double)) * 2)
              .floor().clamp(0, image.width);
          final foreground = Color(item['argb'] as int).computeLuminance();
          var minimum = 100.0;
          for (var x = left; x < end; x++) {
            final i = (y * image.width + x) * 4;
            final background = Color.fromARGB(raw.getUint8(i + 3), raw.getUint8(i),
              raw.getUint8(i + 1), raw.getUint8(i + 2)).computeLuminance();
            final ratio = ((foreground > background ? foreground : background) + .05) /
                ((foreground < background ? foreground : background) + .05);
            if (ratio < minimum) minimum = ratio;
          }
          checked.add({'text': item['text'], 'adjacentBackgroundMinRatio': minimum});
          expect(minimum, greaterThanOrEqualTo(4.5),
            reason: '${item['text']}: actual rendered background row must support the text');
        }
        expect(checked.length, labels.length);
        File('${output.path}/$name-contrast.json').writeAsStringSync(jsonEncode(checked));
      }
      File('${output.path}/$name-text.json').writeAsStringSync(jsonEncode(
        {'pixelRatio': 2, 'text': text}));
      image.dispose();
    });
  }
  for (var mode = 0; mode < 2; mode++) {
    for (final language in ['ar', 'en']) {
      testWidgets('appearance $mode $language all major screens render and preserve data', (t) async {
        t.view.physicalSize = const Size(430, 932); t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize); addTearDown(t.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({appearancePreference: appearanceIds[mode],
          'language': language, 'tasbih': 6, 'haptics': false,
          'favorites': <String>['morning_sayyid']});
        final s = WirdState(); await s.initialize();
        final pages = <String, Widget>{
          'home': HomePage(store: s), 'library': LibraryPage(store: s),
          'reader': ReaderPage(store: s, section: DhikrSection.morning),
          'nawafil': NawafilPage(store: s), 'tasbih': PersonalTasbihPage(store: s),
          'settings': SettingsPage(store: s),
        };
        for (final entry in pages.entries) {
          await t.pumpWidget(const SizedBox.shrink());
          await mount(t, s, entry.value);
          expect(t.takeException(), isNull, reason: entry.key);
          expect(Directionality.of(t.element(find.byKey(const Key('appearance-capture')))),
            language == 'ar' ? TextDirection.rtl : TextDirection.ltr);
          if (entry.key == 'home') {
            final label = find.byKey(ValueKey('category-label-sleep-$mode-$language'));
            expect(label, findsOneWidget);
            await t.ensureVisible(label); await t.pumpAndSettle();
            final boundary = t.renderObject<RenderRepaintBoundary>(label);
            await t.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 2);
              final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
              var visible = 0;
              for (var i = 0; i < pixels!.lengthInBytes; i += 4) {
                if (pixels.getUint8(i + 3) > 180 && pixels.getUint8(i) > 170 &&
                    pixels.getUint8(i + 1) > 150 && pixels.getUint8(i + 2) > 100) visible++;
              }
              image.dispose();
              expect(visible, greaterThan(100), reason: 'Bedtime title/count must actually paint');
            });
          }
          await capture(t, 'appearance-$mode-$language-${entry.key}');
        }
        await t.ensureVisible(find.byKey(const Key('appearance-picker')));
        await t.tap(find.byKey(const Key('appearance-picker'))); await t.pumpAndSettle();
        expect(find.byType(RadioListTile<int>), findsNWidgets(2));
        await capture(t, 'appearance-$mode-$language-selector');
        await t.tap(find.byKey(Key('settings-theme-${1-mode}'))); await t.pumpAndSettle();
        expect(s.themeIndex, 1-mode); expect(s.tasbih, 6);
        expect(s.favorites, contains('morning_sayyid'));
        await s.pendingWrites;
        final reopened = WirdState(); await reopened.initialize();
        expect(reopened.themeIndex, 1-mode); expect(reopened.tasbih, 6);
        await t.pumpWidget(const SizedBox.shrink()); s.dispose(); reopened.dispose();
      });
    }
  }
}

