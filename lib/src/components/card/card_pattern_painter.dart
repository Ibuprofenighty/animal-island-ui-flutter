import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'card_style.dart';

/// Painter for organic decorative patterns on [AnimalCard].
class AnimalCardPatternPainter extends CustomPainter {
  final AnimalCardPattern pattern;
  final Color patternColor;
  final double radius;

  const AnimalCardPatternPainter({
    required this.pattern,
    required this.patternColor,
    this.radius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern == AnimalCardPattern.none) return;

    final paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.fill;

    // Clip to card rounded border
    final clipRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipRRect(clipRRect);

    switch (pattern) {
      case AnimalCardPattern.dots:
        const step = 20.0;
        const dotRadius = 1.8;
        for (double y = step / 2; y < size.height; y += step) {
          final isOffset = ((y ~/ step) % 2) == 1;
          for (
            double x = isOffset ? step : step / 2;
            x < size.width;
            x += step
          ) {
            canvas.drawCircle(Offset(x, y), dotRadius, paint);
          }
        }

      case AnimalCardPattern.sprinkles:
        const step = 28.0;
        final strokePaint = Paint()
          ..color = patternColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        for (double y = 14.0; y < size.height; y += step) {
          final row = (y ~/ step);
          for (double x = 14.0; x < size.width; x += step) {
            final col = (x ~/ step);
            final angle = ((row * 3 + col * 7) % 8) * (math.pi / 4);
            canvas.save();
            canvas.translate(x, y);
            canvas.rotate(angle);
            canvas.drawLine(
              const Offset(-3.5, 0),
              const Offset(3.5, 0),
              strokePaint,
            );
            canvas.restore();
          }
        }

      case AnimalCardPattern.stripes:
        final stripePaint = Paint()
          ..color = patternColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        const step = 24.0;
        final diag = size.width + size.height;
        for (double offset = -size.height; offset < diag; offset += step) {
          canvas.drawLine(
            Offset(offset, 0),
            Offset(offset + size.height, size.height),
            stripePaint,
          );
        }

      case AnimalCardPattern.none:
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnimalCardPatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern ||
      oldDelegate.patternColor != patternColor ||
      oldDelegate.radius != radius;
}

/// Dashed border painter for [AnimalCardType.dashed].
class AnimalCardDashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  const AnimalCardDashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.8,
    this.radius = 20.0,
    this.dashLength = 7.0,
    this.gapLength = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strokeWidth / 2,
            strokeWidth / 2,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(radius - strokeWidth / 2),
        ),
      );

    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimalCardDashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.gapLength != gapLength;
}
