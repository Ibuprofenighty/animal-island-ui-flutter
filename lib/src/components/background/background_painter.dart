import 'package:flutter/widgets.dart';

/// Background pattern types for [AnimalBackground].
enum AnimalBackgroundType {
  /// Plain fill with no pattern.
  parchment,

  /// Staggered dots on a 24 logical-pixel step.
  dots,

  /// Square grid lines on a 24 logical-pixel step.
  grid,
}

/// Unified painter for Animal Island container wallpapers and background textures.
class AnimalBackgroundPainter extends CustomPainter {
  /// Pattern drawn over the fill.
  final AnimalBackgroundType type;

  /// Fill of the whole canvas.
  final Color bgColor;

  /// Color of the dots or grid lines.
  final Color patternColor;

  /// Creates a painter that fills with [bgColor] and draws [type].
  const AnimalBackgroundPainter({
    required this.type,
    required this.bgColor,
    required this.patternColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fill base background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    if (type == AnimalBackgroundType.parchment) return;

    final patternPaint = Paint()
      ..color = patternColor
      ..strokeWidth = 1.0;

    switch (type) {
      case AnimalBackgroundType.dots:
        const double step = 24.0;
        const double radius = 1.5;
        patternPaint.style = PaintingStyle.fill;
        for (double y = step / 2; y < size.height; y += step) {
          final isOffset = ((y ~/ step) % 2) == 1;
          for (
            double x = isOffset ? step : step / 2;
            x < size.width;
            x += step
          ) {
            canvas.drawCircle(Offset(x, y), radius, patternPaint);
          }
        }

      case AnimalBackgroundType.grid:
        const double step = 24.0;
        patternPaint.style = PaintingStyle.stroke;
        for (double x = 0; x <= size.width; x += step) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), patternPaint);
        }
        for (double y = 0; y <= size.height; y += step) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), patternPaint);
        }

      case AnimalBackgroundType.parchment:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant AnimalBackgroundPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.bgColor != bgColor ||
      oldDelegate.patternColor != patternColor;
}
