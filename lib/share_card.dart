import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'content.dart';

// Measure every paragraph before allocating the canvas: long verses are never clipped.
Future<void> shareDhikrCard(
  BuildContext context,
  DhikrEntry entry,
  Color background,
  Color ink, {
  int? repetitionTarget,
}) async {
  if (!entry.reviewed || entry.reviewOnly) throw StateError('Only verified devotional entries may be shared');
  final selected = repetitionTarget ?? entry.count;
  if (!entry.allowedCounts.contains(selected))
    throw ArgumentError('Invalid repetition target');
  const width = 1080.0;
  const margin = 80.0;
  final blocks = <(String, double, FontWeight)>[
    ('ورد — Wird', 38, FontWeight.bold),
    (entry.title, 38, FontWeight.bold),
    (entry.arabic, 46, FontWeight.normal),
    (entry.source, 27, FontWeight.normal),
    if (entry.quranSourceUrl.isNotEmpty)
      (entry.quranSourceUrl, 21, FontWeight.normal),
    (entry.timing, 25, FontWeight.normal),
    (
      entry.countDescription.isEmpty
          ? 'التكرار الوارد: $selected'
          : '${entry.countDescription}\nالعداد المختار: $selected',
      25,
      FontWeight.normal,
    ),
    (entry.sourceUrl, 21, FontWeight.normal),
  ];
  final painters = blocks
      .map(
        (b) => TextPainter(
          text: TextSpan(
            text: b.$1,
            style: TextStyle(
              color: ink,
              fontSize: b.$2,
              fontWeight: b.$3,
              height: 1.85,
            ),
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        )..layout(maxWidth: width - margin * 2),
      )
      .toList();
  final height = painters.fold<double>(
    margin * 2,
    (sum, p) => sum + p.height + 36,
  );
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, width, height),
    Paint()..color = background,
  );
  var y = margin;
  for (final painter in painters) {
    painter.paint(canvas, Offset((width - painter.width) / 2, y));
    y += painter.height + 36;
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(width.toInt(), height.ceil());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  for (final painter in painters) {
    painter.dispose();
  }
  if (bytes == null || !context.mounted) return;
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          bytes.buffer.asUint8List(),
          mimeType: 'image/png',
          name: 'wird-${entry.id}.png',
        ),
      ],
      fileNameOverrides: ['wird-${entry.id}.png'],
      title: entry.title,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
