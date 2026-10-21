import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/main.dart';
import 'fixtures/tasbih_before.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'NotoSansArabic',
    )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  Future<WirdState> state({
    int theme = 0,
    String language = 'ar',
    int count = 6,
    bool haptics = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      appearancePreference: appearanceIds[theme],
      'language': language,
      'tasbih': count,
      'haptics': haptics,
    });
    final s = WirdState();
    await s.initialize();
    return s;
  }

  Widget app(
    WirdState s, {
    double scale = 1,
    bool still = false,
    GlobalKey? capture,
    bool before = false,
  }) => RepaintBoundary(
    key: capture,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(s.languageCode),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: wirdTheme(s.palette),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: still,
        ),
        child: child!,
      ),
      home: before ? TasbihBefore(store: s) : PersonalTasbihPage(store: s),
    ),
  );
  Future<void> press(WidgetTester t, String key) async {
    final f = find.byKey(Key(key));
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> close(WidgetTester t, WirdState s) async {
    await s.pendingWrites;
    await t.pumpWidget(const SizedBox.shrink());
    s.dispose();
  }

  for (final language in ['ar', 'en']) {
    for (var theme = 0; theme < themes.length; theme++) {
      testWidgets('Tasbih $language theme $theme small phone 200% text', (
        t,
      ) async {
        t.view.physicalSize = const Size(320, 568);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final s = await state(theme: theme, language: language);
        await t.pumpWidget(app(s, scale: 2, still: true));
        await t.pumpAndSettle();
        expect(
          Directionality.of(t.element(find.byType(PersonalTasbihPage))),
          language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        await press(t, 'home-tasbih-add');
        expect(s.tasbih, 7);
        await press(t, 'tasbih-reset');
        expect(s.tasbih, 0);
        expect(t.takeException(), isNull);
        await close(t, s);
      });
    }
  }
  testWidgets(
    '100 rapid taps increment once, survive reinitialization, reset isolates other data',
    (t) async {
      final s = await state(count: 6);
      s.favorites.add('preserved');
      s.counts['preserved'] = 2;
      s.prayers.add('preserved');
      await t.pumpWidget(app(s));
      await t.pumpAndSettle();
      final button = find.byKey(const Key('home-tasbih-add'));
      await t.ensureVisible(button);
      await t.pumpAndSettle();
      for (var i = 0; i < 100; i++) {
        await t.tap(button);
      }
      expect(s.tasbih, 106);
      await t.pumpAndSettle();
      await s.pendingWrites;
      expect((await SharedPreferences.getInstance()).getInt('tasbih'), 106);
      await press(t, 'tasbih-reset');
      await press(t, 'tasbih-reset-cancel');
      expect(s.tasbih, 106);
      await press(t, 'tasbih-reset');
      await press(t, 'tasbih-reset-confirm');
      expect(s.tasbih, 0);
      expect(s.favorites, contains('preserved'));
      expect(s.counts['preserved'], 2);
      expect(s.prayers, contains('preserved'));
      await close(t, s);
      final restored = WirdState();
      await restored.initialize();
      expect(restored.tasbih, 0);
      restored.dispose();
    },
  );
  for (final enabled in [true, false]) {
    testWidgets('Haptics preference $enabled and reduced motion', (t) async {
      final s = await state(haptics: enabled);
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            calls.add(call);
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await t.pumpWidget(app(s, still: true));
      await t.pumpAndSettle();
      await press(t, 'home-tasbih-add');
      expect(s.tasbih, 7);
      expect(
        calls.where((c) => c.method == 'HapticFeedback.vibrate').length,
        enabled ? 1 : 0,
      );
      expect(t.binding.hasScheduledFrame, isFalse);
      await close(t, s);
    });
  }
  testWidgets('Existing large saved number fits circle', (t) async {
    final s = await state(count: 1000000000);
    await t.pumpWidget(app(s));
    await t.pumpAndSettle();
    expect(find.text('1000000000'), findsOneWidget);
    expect(t.takeException(), isNull);
    await close(t, s);
  });
  testWidgets('Before and after actual Flutter renders', (t) async {
    if (Platform.environment['WIRD_REVIEW_IMAGES'] != '1') return;
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final s = await state();
    for (final before in [true, false]) {
      final key = GlobalKey();
      await t.pumpWidget(app(s, capture: key, before: before));
      await t.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      boundary.markNeedsPaint();
      await t.pump();
      await t.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final f = File(
          'verification/screenshots/tasbih-${before ? 'before' : 'premium'}-ar.png',
        );
        await f.parent.create(recursive: true);
        await f.writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await close(t, s);
  });
}
