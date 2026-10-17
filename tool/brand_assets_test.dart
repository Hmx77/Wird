// Reproducible rendering of supplied artwork and OS-masked native layers.
// Run before native builds: flutter test tool/brand_assets_test.dart
import 'dart:async';
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
    late ui.Image foreground;
    await tester.runAsync(() async {
      final data = await rootBundle.load(wirdArtwork.assetName);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final original = (await codec.getNextFrame()).image;
      final pixels = (await original.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
      // Mechanical colour separation, never redraw the calligraphy or leaf.
      // Supplied cream/gold RGB stays intact; teal moves to a full-bleed native
      // layer. No baked rounded tile in the adaptive foreground.
      var visible = 0;
      var kasra = false;
      for (var i = 0; i < pixels.length; i += 4) {
        final warm = ((pixels[i] - pixels[i + 1] * .86) / 24).clamp(0.0, 1.0);
        final light = ((pixels[i] - 65) / 30).clamp(0.0, 1.0);
        // PixelFormat.rgba8888 requires premultiplied RGB. Scale all four
        // channels together so removed teal pixels cannot create colour halos.
        final coverage = warm * light;
        for (var channel = 0; channel < 4; channel++) {
          pixels[i + channel] = (pixels[i + channel] * coverage).round();
        }
        if (pixels[i + 3] > 220) {
          visible++;
          final x = (i ~/ 4) % original.width;
          final y = (i ~/ 4) ~/ original.width;
          if (y > 925) kasra = true;
          final dx = (x - original.width / 2) * 82 / original.width;
          final dy = (y - original.height / 2) * 82 / original.height;
          expect(
            dx * dx + dy * dy,
            lessThanOrEqualTo(33 * 33),
            reason: 'Artwork outside Android adaptive circular safe zone',
          );
        }
      }
      var validPremultiplied = true;
      for (var i = 0; i < pixels.length; i += 4) {
        if (pixels[i] > pixels[i + 3] ||
            pixels[i + 1] > pixels[i + 3] ||
            pixels[i + 2] > pixels[i + 3])
          validPremultiplied = false;
      }
      expect(
        validPremultiplied,
        isTrue,
        reason: 'Native foreground alpha must not create halos',
      );
      expect(visible, greaterThan(110000), reason: 'Missing calligraphy/leaf');
      expect(kasra, isTrue, reason: 'Supplied kasra must remain present');
      final decoded = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        pixels,
        original.width,
        original.height,
        ui.PixelFormat.rgba8888,
        decoded.complete,
      );
      foreground = await decoded.future;
      original.dispose();
      codec.dispose();
    });
    addTearDown(foreground.dispose);
    Widget nativeMark(double size, {bool transparent = false}) =>
        SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: transparent
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF07535A), Color(0xFF001B22)],
                    ),
            ),
            child: Center(
              child: SizedBox.square(
                dimension: size * 82 / 108,
                child: RawImage(
                  image: foreground,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );
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
            home: ColoredBox(
              color: background,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontSize: 14,
                  color: Color(0xFF0B3437),
                ),
                child: child,
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(wirdArtwork, key.currentContext!),
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
        if (path.endsWith('wird_adaptive_foreground.png') ||
            path.endsWith('wird_splash_icon.png') ||
            path.endsWith('/wird_logo.png')) {
          expect(
            rgba[3],
            0,
            reason: 'No baked tile outside original artwork: $path',
          );
        }
        var unexpectedRed = false;
        for (var i = 0; i < rgba.length; i += 4) {
          if (rgba[i] > 150 && rgba[i + 1] < 60 && rgba[i + 2] < 90) {
            unexpectedRed = true;
            break;
          }
        }
        // The cinematic scene has intentional amber/red lantern pixels.
        // Keep the debug-red guard on generated brand/icon assets only.
        if (!path.endsWith('/opening.png') &&
            !path.endsWith('/wird_launch_scene.png') &&
            !path.contains('/LaunchImage.imageset/')) {
          expect(
            unexpectedRed,
            isFalse,
            reason: 'Unexpected red/debug ribbon in brand asset: $path',
          );
        }
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
        Center(child: nativeMark(108)),
        ratio: item.value / 108,
      );
    }
    // Keep the committed transparent wordmark stable while rendering both
    // native and Flutter openings. Rewriting a bundled asset mid-test would
    // make the native snapshot use a stale cached image and cause a size jump.
    await render(
      'android/app/src/main/res/drawable-nodpi/wird_logo.png',
      const Size(108, 108),
      const Center(child: WirdMark(size: 108)),
      ratio: 4,
      background: Colors.transparent,
    );
    // Android 12+ allocates a 288dp icon surface without an icon background.
    // No launcher tile: dismiss the system surface as soon as the scene draws.
    await render(
      'android/app/src/main/res/drawable-nodpi/wird_splash_icon.png',
      const Size(288, 288),
      const SizedBox.shrink(),
      ratio: 3,
      background: Colors.transparent,
    );
    await render(
      'android/app/src/main/res/drawable-nodpi/wird_adaptive_foreground.png',
      const Size(108, 108),
      Center(child: nativeMark(108, transparent: true)),
      background: Colors.transparent,
      ratio: 4,
    );
    // OS-mask previews only; no masks are baked into native foregrounds.
    for (final round in [true, false]) {
      final preview = OverflowBox(
        minWidth: 108,
        maxWidth: 108,
        minHeight: 108,
        maxHeight: 108,
        child: nativeMark(108),
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
        Center(child: nativeMark(dimension)),
      );
    }
    for (final scale in [1, 2, 3]) {
      final suffix = scale == 1 ? '' : '@${scale}x';
      await render(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage$suffix.png',
        const Size(430, 932),
        const WirdOpening(),
        background: const Color(0xFF00242C),
        ratio: scale.toDouble(),
      );
    }
    await render(
      'android/app/src/main/res/drawable-nodpi/wird_launch_scene.png',
      const Size(430, 932),
      const WirdOpening(),
      ratio: 2,
    );
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

