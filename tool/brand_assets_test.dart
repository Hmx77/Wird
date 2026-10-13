// Reproducible Flutter rendering of the immutable original + vector kasra.
// Run before native builds: flutter test tool/brand_assets_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/main.dart';

void main() {
  testWidgets('render owned brand assets, safe-zone icons and opening', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final font = FontLoader('NotoSansArabic');
      font.addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'));
      await font.load();
    });
    Future<void> render(
      String path,
      Size size,
      Widget child, {
      double ratio = 1,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: ThemeData(fontFamily: 'NotoSansArabic'),
            home: Scaffold(
              backgroundColor: const Color(0xFF0B3437),
              body: child,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: ratio);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(path);
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      debugPrint('Rendered $path');
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final item in {
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    }.entries) {
      await render(
        'android/app/src/main/res/mipmap-${item.key}/ic_launcher.png',
        const Size(108, 108),
        const Center(child: WirdMark(size: 108)),
        ratio: item.value / 108,
      );
    }
    await render(
      'android/app/src/main/res/drawable-nodpi/wird_logo.png',
      const Size(108, 108),
      const Center(child: WirdMark(size: 108)),
      ratio: 4,
    );
    await render(
      'android/app/src/main/res/drawable-nodpi/wird_adaptive_foreground.png',
      const Size(108, 108),
      const Center(child: WirdMark(size: 94)),
      ratio: 4,
    );
    final icons = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
    final manifest =
        jsonDecode(File('${icons.path}/Contents.json').readAsStringSync())
            as Map<String, dynamic>;
    for (final icon in manifest['images'] as List) {
      final dimension =
          double.parse((icon['size'] as String).split('x').first) *
          double.parse((icon['scale'] as String).replaceAll('x', ''));
      await render(
        '${icons.path}/${icon['filename']}',
        const Size(108, 108),
        const Center(child: WirdMark(size: 108)),
        ratio: dimension / 108,
      );
    }
    for (final scale in [1, 2, 3]) {
      final suffix = scale == 1 ? '' : '@${scale}x';
      await render(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage$suffix.png',
        const Size(360, 640),
        const WirdOpening(),
        ratio: scale.toDouble(),
      );
    }
    await render(
      'verification/screenshots/brand-kasra.png',
      const Size(108, 108),
      const Center(child: WirdMark(size: 108)),
      ratio: 4,
    );
    await render(
      'verification/screenshots/opening.png',
      const Size(430, 932),
      const WirdOpening(),
      ratio: 2,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
