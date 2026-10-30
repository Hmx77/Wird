import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/home_polish_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('NotoSansArabic')..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final platform in ['iphone', 'android', 'small']) {
    for (final mode in [0, 1]) {
      for (final scale in [1.0, 2.0]) {
        for (final language in ['ar', 'en']) {
          testWidgets('Home polish $platform theme $mode $language text $scale', (t) async {
            t.view.devicePixelRatio = 1;
            t.view.physicalSize = platform == 'iphone' ? const Size(430, 932)
              : platform == 'android' ? const Size(412, 915) : const Size(320, 700);
            final inset = platform == 'iphone' ? const FakeViewPadding(top: 59, bottom: 34)
              : const FakeViewPadding(top: 24, bottom: 24);
            t.view.padding = inset; t.view.viewPadding = inset;
            addTearDown(t.view.resetPhysicalSize); addTearDown(t.view.resetDevicePixelRatio);
            addTearDown(t.view.resetPadding); addTearDown(t.view.resetViewPadding);
            SharedPreferences.setMockInitialValues({'language': language, 'haptics': false,
              'favorites': <String>['morning_sayyid'], 'tasbih': 37, 'font': 29.0,
              'counts': '{"2026-10-20|morning_sayyid":1}',
              'prayers': <String>['2026-10-20|fajr_before'], 'reminder.morning.hour': 9});
            await verifyHomePolish(t, mode: mode, scale: scale, language: language,
              baseline: Platform.environment['WIRD_BASELINE_RENDER'] == '1',
              prefix: 'polish-$platform-$mode-$language-${scale.toInt()}', capture: (name) async {
                if (Platform.environment['WIRD_REVIEW_IMAGES'] != '1' || language != 'ar' || platform == 'small') return;
                await t.runAsync(() async {
                  final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(const Key('polish-capture')));
                  final image = await boundary.toImage(pixelRatio: 2);
                  final data = await image.toByteData(format: ui.ImageByteFormat.png);
                  Directory('verification/screenshots').createSync(recursive: true);
                  File('verification/screenshots/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
                  image.dispose();
                });
              });
          });
        }
      }
    }
  }
}
