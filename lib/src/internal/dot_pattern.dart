import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/rendering.dart';

/// Shared two-layer dot geometry. Each surface supplies its own color contract.
class DotPatternPainter extends CustomPainter {
  const DotPatternPainter({required this.largeDot, required this.smallDot});
  final Color largeDot, smallDot;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 14 || size.height <= 14) return;
    for (final (step, radius, color) in [
      (14.0, 1.0, smallDot),
      (28.0, 1.4, largeDot),
    ]) {
      final cols = ((size.width - 14) / step).ceil();
      final rows = ((size.height - 14) / step).ceil();
      if (cols <= 0 || rows <= 0) continue;
      final points = Float32List(cols * rows * 2);
      var i = 0;
      for (var c = 0; c < cols; c++) {
        final x = 14.0 + c * step;
        for (var r = 0; r < rows; r++) {
          points[i++] = x;
          points[i++] = 14.0 + r * step;
        }
      }
      final brush = Paint()
        ..color = color
        ..strokeWidth = radius * 2
        ..strokeCap = StrokeCap.round;
      canvas.drawRawPoints(PointMode.points, points, brush);
    }
  }

  @override
  bool shouldRepaint(DotPatternPainter old) =>
      old.largeDot != largeDot || old.smallDot != smallDot;
}
