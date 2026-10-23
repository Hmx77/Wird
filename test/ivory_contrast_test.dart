import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/main.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
}

void main() {
  test('Ivory reading backing protects normal text over any illustration', () {
    // Alpha blend against both luminance extremes, not only a flat mockup.
    for (final imagePixel in [Colors.black, Colors.white]) {
      final surface = Color.alphaBlend(IvoryContrast.readingBacking, imagePixel);
      for (final ink in [IvoryContrast.ink, IvoryContrast.muted, IvoryContrast.gold]) {
        expect(contrast(ink, surface), greaterThanOrEqualTo(4.5));
      }
    }
  });
  test('Ivory meaningful control outlines, progress and button icons meet AA', () {
    expect(contrast(IvoryContrast.outline, IvoryContrast.cream), greaterThanOrEqualTo(3));
    expect(contrast(IvoryContrast.accent, IvoryContrast.progressTrack), greaterThanOrEqualTo(3));
    expect(contrast(IvoryContrast.cream, IvoryContrast.ink), greaterThanOrEqualTo(4.5));
    expect(contrast(const Color(0xFF426E8A), IvoryContrast.cream), greaterThanOrEqualTo(3));
    expect(contrast(IvoryContrast.ink, IvoryContrast.sage), greaterThanOrEqualTo(4.5));
    expect(contrast(IvoryContrast.gold, IvoryContrast.selected), greaterThanOrEqualTo(4.5));
  });
  test('Midnight signature roles remain exact and only two themes exist', () {
    final a = AppAppearance(themes.first);
    expect(a.ink, homeCream); expect(a.gold, homeGold);
    expect(a.muted, const Color(0xFFCAD9D3));
    expect(a.accent, const Color(0xFF86D8C8));
    expect(themes.length, 2);
  });
}
