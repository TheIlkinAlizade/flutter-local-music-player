import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class PaletteExtractor {
  static final Map<String, List<Color>> _cache = {};

  static const List<Color> fallback = [
    Color(0xFF3D8BFF),
    Color(0xFFFF4D5E),
    Color(0xFFFFC94D),
  ];

  static Future<List<Color>> extract(String? artPath) async {
    if (artPath == null) return fallback;
    if (_cache.containsKey(artPath)) return _cache[artPath]!;

    try {
      final bytes = await File(artPath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return fallback;

      final small = img.copyResize(decoded, width: 16, height: 16);
      final pixels = <Color>[];
      for (var y = 0; y < small.height; y++) {
        for (var x = 0; x < small.width; x++) {
          final p = small.getPixel(x, y);
          pixels.add(Color.fromARGB(255, p.r.toInt(), p.g.toInt(), p.b.toInt()));
        }
      }

      if (pixels.isEmpty) return fallback;

      final base = _tunedForGlow(_average(pixels));
      final second = _tunedForGlow(_farthestFrom(pixels, [base]));
      final third = _tunedForGlow(_farthestFrom(pixels, [base, second]));

      final colors = [base, second, third];
      _cache[artPath] = colors;
      return colors;
    } catch (_) {
      return fallback;
    }
  }

  static Color _average(List<Color> colors) {
    var r = 0, g = 0, b = 0;
    for (final c in colors) {
      r += (c.r * 255).round();
      g += (c.g * 255).round();
      b += (c.b * 255).round();
    }
    final n = colors.length;
    return Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
  }

  static Color _farthestFrom(List<Color> pixels, List<Color> existing) {
    var best = pixels.first;
    var bestDist = -1.0;
    for (final p in pixels) {
      final dist = existing.map((e) => _distance(p, e)).reduce((a, b) => a < b ? a : b);
      if (dist > bestDist) {
        bestDist = dist;
        best = p;
      }
    }
    return best;
  }

  static double _distance(Color a, Color b) {
    final dr = (a.r - b.r) * 255;
    final dg = (a.g - b.g) * 255;
    final db = (a.b - b.b) * 255;
    return dr * dr + dg * dg + db * db;
  }

  static Color _tunedForGlow(Color color) {
    final hsl = HSLColor.fromColor(color);
    final sat = hsl.saturation.clamp(0.45, 1.0);
    final light = hsl.lightness.clamp(0.28, 0.55);
    return hsl.withSaturation(sat).withLightness(light).toColor();
  }
}