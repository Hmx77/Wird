// Reproducible Flutter rendering of the immutable original + vector kasra.
// Run before native builds: flutter test tool/brand_assets_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/main.dart';

// iOS app icons must be RGB PNGs with no alpha channel. Preserve the exact
// rendered RGB values while encoding opaque icon output without new packages.
Uint8List opaqueRgbPng(int width, int height, Uint8List rgba) {
  final rows = Uint8List((width * 3 + 1) * height);
  for (var y = 0; y < height; y++) {
    final row = y * (width * 3 + 1);
    for (var x = 0; x < width; x++) {
      final pixel = (y * width + x) * 4;
      if (rgba[pixel + 3] != 255) {
        throw StateError('iOS icon output must be fully opaque');
      }
      for (var channel = 0; channel < 3; channel++) {
        rows[row + 1 + x * 3 + channel] = rgba[pixel + channel];
      }
    }
  }
  int crc32(List<int> bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc & 1) != 0 ? 0xedb88320 ^ (crc >> 1) : crc >> 1;
      }
    }
    return crc ^ 0xffffffff;
  }

  Uint8List chunk(String type, List<int> data) {
    final body = Uint8List.fromList([...ascii.encode(type), ...data]);
    final length = ByteData(4)..setUint32(0, data.length);
    final checksum = ByteData(4)..setUint32(0, crc32(body));
    return Uint8List.fromList([
      ...length.buffer.asUint8List(),
      ...body,
      ...checksum.buffer.asUint8List(),
    ]);
  }

  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  return (BytesBuilder()
        ..add([137, 80, 78, 71, 13, 10, 26, 10])
        ..add(chunk('IHDR', header.buffer.asUint8List()))
        ..add(chunk('IDAT', ZLibEncoder().convert(rows)))
        ..add(chunk('IEND', [])))
      .takeBytes();
}

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
      Color background = const Color(0xFF0B3437),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: ThemeData(fontFamily: 'NotoSansArabic'),
            home: Scaffold(backgroundColor: background, body: child),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: ratio);
        final rgba = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!.buffer.asUint8List();
        var unexpectedRed = false;
        for (var i = 0; i < rgba.length; i += 4) {
          if (rgba[i] > 150 && rgba[i + 1] < 60 && rgba[i + 2] < 90) {
            unexpectedRed = true;
            break;
          }
        }
        expect(
          unexpectedRed,
          isFalse,
          reason: 'Unexpected red/debug ribbon in brand asset: $path',
        );
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(path);
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(
          path.contains('/AppIcon.appiconset/')
              ? opaqueRgbPng(image.width, image.height, rgba)
              : bytes!.buffer.asUint8List(),
        );
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
      const Center(child: WirdMark(size: 66)),
      ratio: 4,
    );
    // Android reserves the outer 18 dp of each 108 dp layer for masks.
    // Keep the original lettering, leaf and separate kasra inside its 66 dp
    // circular safe zone, and preserve actual circular/squircle previews.
    for (final round in [true, false]) {
      final preview = OverflowBox(
        minWidth: 108,
        maxWidth: 108,
        minHeight: 108,
        maxHeight: 108,
        child: const ColoredBox(
          color: Color(0xFF0B3437),
          child: Center(child: WirdMark(size: 66)),
        ),
      );
      await render(
        'verification/screenshots/adaptive-${round ? "circle" : "squircle"}.png',
        const Size(72, 72),
        round
            ? ClipOval(child: preview)
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: preview,
              ),
        ratio: 6,
        background: const Color(0xFFF3EEDF),
      );
    }
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
        Size(dimension, dimension),
        Center(child: WirdMark(size: dimension)),
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
