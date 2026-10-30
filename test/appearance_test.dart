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

  testWidgets('settings omit software licenses while preserving privacy and local erase', (t) async {
    SharedPreferences.setMockInitialValues({appearancePreference: appearanceIds[1]});
    final s = WirdState();
    await s.initialize();
    await t.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: wirdTheme(s.palette),
      home: Scaffold(body: SettingsPage(store: s)),
    ));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('settings-licenses')), findsNothing);
    expect(find.text('تراخيص البرمجيات'), findsNothing);
    expect(find.byKey(const Key('privacy-details')), findsOneWidget);
    expect(find.byKey(const Key('settings-erase')), findsOneWidget);
    await t.pumpWidget(const SizedBox.shrink());
    s.dispose();
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
        const AssetImage('assets/home/botanical-serenity.webp'),
        const AssetImage('assets/appearance/ivory-home-header-v2.webp'),
        const AssetImage('assets/appearance/ivory-home-feature-v2.webp'),
        const AssetImage('assets/appearance/ivory-morning-v3.webp'),
        const AssetImage('assets/appearance/ivory-evening-v3.webp'),
        const AssetImage('assets/appearance/ivory-morning-v4.webp'),
        const AssetImage('assets/appearance/ivory-evening-v4.webp')]
        .map((image) => precacheImage(image, context)));
    });
    await t.pumpAndSettle();
    if (page is HomePage && s.themeIndex == 1 &&
        Platform.environment['WIRD_BASELINE_RENDER'] != '1') {
      for (final section in ['morning', 'evening']) {
        final art = find.byKey(ValueKey('ivory-day-artwork-$section'));
        final image = t.widget<Image>(art);
        expect(image.color, isNull);
        expect(image.opacity, isNull);
        expect(image.fit, BoxFit.cover);
        expect(image.alignment, Alignment.center);
        final layers = t.widgetList<Stack>(find.ancestor(of: art,
          matching: find.byType(Stack))).singleWhere((stack) =>
            stack.children.whereType<Positioned>().any((layer) => identical(layer.child, image)));
        expect(layers.children.length, 2,
          reason: 'Only full scenic artwork and real controls; no wash layer');
        expect((layers.children.first as Positioned).child, same(image));
        final label = find.byKey(ValueKey('category-label-$section-1-${s.languageCode}'));
        final texts = t.widgetList<Text>(find.descendant(of: label, matching: find.byType(Text)));
        expect(texts.length, 2);
        for (final text in texts) {
          expect(text.style!.color, const Color(0xFFFAF6E9));
          expect(text.style!.backgroundColor, isNull);
          expect(text.style!.background, isNull);
          expect(text.style!.shadows, isNotEmpty);
        }
      }
    }
  }
  Future<void> capture(WidgetTester t, String name) async {
    if (Platform.environment['WIRD_REVIEW_IMAGES'] != '1') return;
    await t.runAsync(() async {
      final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(const Key('appearance-capture')));
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final output = Directory('verification/screenshots')..createSync(recursive: true);
      File('${output.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      final cardBounds = <String, List<double>>{};
      if (name.contains('home')) {
        for (final section in ['morning', 'evening', 'sleep']) {
          final card = find.byKey(Key('home-$section'));
          if (card.evaluate().length != 1) continue;
          final rect = t.getRect(card);
          cardBounds[section] = [rect.left, rect.top, rect.right, rect.bottom];
        }
        final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        File('${output.path}/$name.rgba').writeAsBytesSync(raw!.buffer.asUint8List());
      }
      final badges = <String, List<double>>{};
      if (name.contains('home')) {
        for (final section in ['morning', 'evening', 'sleep']) {
          final card = find.byKey(Key('home-$section'));
          final icons = find.descendant(of: card, matching: find.byWidgetPredicate((w) =>
            w is Icon && [Icons.wb_sunny_outlined, Icons.nightlight_outlined,
              Icons.nightlight_round, Icons.bedtime_outlined].contains(w.icon)));
          if (icons.evaluate().length != 1) continue;
          Element? badge;
          icons.evaluate().single.visitAncestorElements((e) {
            if (e.widget is Container) { badge = e; return false; }
            return true;
          });
          if (badge != null) {
            final box = badge!.findRenderObject()! as RenderBox;
            final rect = box.localToGlobal(Offset.zero) & box.size;
            badges[section] = [rect.left, rect.top, rect.right, rect.bottom];
          }
        }
      }
      final text = <Map<String, Object?>>[];
      for (final e in find.byType(Text).evaluate()) {
        final render = e.findRenderObject();
        if (render is! RenderParagraph || !render.attached) continue;
        final origin = render.localToGlobal(Offset.zero);
        final color = render.text.style?.color;
        if (color == null) continue;
        final card = e.findAncestorWidgetOfExactType<InkWell>()?.key;
        text.add({'text': render.text.toPlainText(), 'argb': color.toARGB32(),
          'card': card is ValueKey<String> ? card.value : null,
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
          if (item['card'] == 'home-morning' || item['card'] == 'home-evening') {
            // These captions now use cream glyphs and a localized dark halo.
            // Probe actual glyph edges, not an empty row above the caption.
            final section = (item['card'] as String).substring(5);
            final label = t.renderObject<RenderRepaintBoundary>(find.byKey(
              ValueKey('category-label-$section-1-ar')));
            final maskImage = await label.toImage(pixelRatio: 2);
            final mask = (await maskImage.toByteData(format: ui.ImageByteFormat.rawRgba))!;
            final origin = label.localToGlobal(Offset.zero) * 2;
            bool glyph(int x, int y) {
              if (x < 0 || y < 0 || x >= maskImage.width || y >= maskImage.height) return false;
              final i = (y * maskImage.width + x) * 4;
              return mask.getUint8(i + 3) > 230 && mask.getUint8(i) > 235 &&
                mask.getUint8(i + 1) > 230 && mask.getUint8(i + 2) > 218;
            }
            var edges = 0, readable = 0;
            final foreground = Color(item['argb'] as int).computeLuminance();
            for (var y = 0; y < maskImage.height; y++) {
              for (var x = 0; x < maskImage.width; x++) {
                if (!glyph(x, y) || (glyph(x-1, y) && glyph(x+1, y) &&
                    glyph(x, y-1) && glyph(x, y+1))) continue;
                edges++;
                var best = 1.0;
                for (var dy = -4; dy <= 4; dy++) {
                  for (var dx = -4; dx <= 4; dx++) {
                    if (glyph(x+dx, y+dy)) continue;
                    final px = origin.dx.round() + x + dx;
                    final py = origin.dy.round() + y + dy;
                    if (px < 0 || py < 0 || px >= image.width || py >= image.height) continue;
                    final i = (py * image.width + px) * 4;
                    final background = Color.fromARGB(raw.getUint8(i+3), raw.getUint8(i),
                      raw.getUint8(i+1), raw.getUint8(i+2)).computeLuminance();
                    final ratio = (foreground + .05) / (background + .05);
                    if (ratio > best) best = ratio;
                  }
                }
                if (best >= 4.5) readable++;
              }
            }
            expect(edges, greaterThan(100));
            expect(readable / edges, greaterThanOrEqualTo(.95),
              reason: '${item['text']}: rendered glyph/halo contrast');
            checked.add({'text': item['text'], 'readableGlyphEdgeFraction': readable / edges});
            maskImage.dispose();
            continue;
          }
          final y = ((item['top'] as double) * 2).floor() + 1;
          if (y < 0 || y >= image.height) continue;
          final left = ((item['left'] as double) * 2).floor().clamp(0, image.width - 1).toInt();
          final end = (((item['left'] as double) + (item['width'] as double)) * 2)
              .floor().clamp(0, image.width).toInt();
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
        {'pixelRatio': 2, 'width': image.width, 'height': image.height,
         'cards': cardBounds, 'badges': badges, 'text': text}));
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
        expect(find.byKey(const Key('settings-theme-0')), findsOneWidget);
        expect(find.byKey(const Key('settings-theme-1')), findsOneWidget);
        expect(find.descendant(of: find.byKey(const Key('settings-theme-0')), matching: find.text('Midnight Teal')), findsOneWidget);
        expect(find.descendant(of: find.byKey(const Key('settings-theme-1')), matching: find.text('Ivory Serenity')), findsOneWidget);
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
  for (final language in ['ar', 'en']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Ivory Home 320dp $language text $scale', (t) async {
        t.view.physicalSize = const Size(320, 700); t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize); addTearDown(t.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({appearancePreference: appearanceIds[1],
          'language': language, 'haptics': false});
        final s = WirdState(); await s.initialize();
        await mount(t, s, HomePage(store: s), scale: scale);
        expect(t.takeException(), isNull);
        await capture(t, 'ivory-home-320-$language-${scale.toInt()}-top');
        for (final key in ['home-morning', 'home-evening', 'home-sleep', 'home-all',
            'home-nawafil', 'home-tasbih', 'home-favorites']) {
          await t.ensureVisible(find.byKey(Key(key))); await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: key);
        }
        await capture(t, 'ivory-home-320-$language-${scale.toInt()}-bottom');
        await t.pumpWidget(const SizedBox.shrink()); s.dispose();
      });
    }
  }

  testWidgets('Ivory shell keeps all navigation destinations readable at 320dp and 200% text', (t) async {
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({appearancePreference: appearanceIds[1], 'haptics': false});
    final s = WirdState();
    await s.initialize();
    await mount(t, s, WirdShell(store: s), scale: 2);
    final home = find.byKey(const Key('nav-home'));
    final library = find.byKey(const Key('nav-library'));
    final nawafil = find.byKey(const Key('nav-nawafil'));
    final settings = find.byKey(const Key('nav-settings'));
    for (final item in [home, library, nawafil, settings]) {
      expect(item.hitTestable(), findsOneWidget);
      expect(t.getSize(item).width, greaterThan(130));
    }
    expect(t.getTopLeft(home).dy, t.getTopLeft(library).dy);
    expect(t.getTopLeft(nawafil).dy, t.getTopLeft(settings).dy);
    expect(t.getTopLeft(nawafil).dy, greaterThan(t.getTopLeft(home).dy));
    expect(t.takeException(), isNull);
    await capture(t, 'ivory-shell-320-ar-text200');
    await t.tap(library);
    await t.pumpAndSettle();
    expect(find.byType(LibraryPage), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
    s.dispose();
  });

}




