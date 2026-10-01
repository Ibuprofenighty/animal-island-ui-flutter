import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Style variants for [AnimalDivider].
enum AnimalDividerType {
  /// Solid continuous line.
  solid,

  /// Dashed line with rounded pill segments.
  dashed,

  /// Fine dotted line.
  dotted,

  /// Playful sinusoidal wavy line.
  wavy,
}

/// Unified painter for all [AnimalDivider] line types.
class AnimalDividerLinePainter extends CustomPainter {
  final AnimalDividerType type;
  final Color color;
  final double thickness;

  const AnimalDividerLinePainter({
    required this.type,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (thickness <= 0 || size.width <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;

    switch (type) {
      case AnimalDividerType.solid:
        paint.strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(0, midY), Offset(size.width, midY), paint);

      case AnimalDividerType.dashed:
        paint.strokeCap = StrokeCap.round;
        const dash = 6.0;
        const gap = 5.0;
        double currentX = 0;
        while (currentX < size.width) {
          final nextX = math.min(currentX + dash, size.width);
          canvas.drawLine(Offset(currentX, midY), Offset(nextX, midY), paint);
          currentX += dash + gap;
        }

      case AnimalDividerType.dotted:
        paint.strokeCap = StrokeCap.round;
        paint.style = PaintingStyle.fill;
        final dotRadius = thickness / 1.5;
        const gap = 6.0;
        double currentX = dotRadius;
        while (currentX < size.width) {
          canvas.drawCircle(Offset(currentX, midY), dotRadius, paint);
          currentX += (dotRadius * 2) + gap;
        }

      case AnimalDividerType.wavy:
        paint.strokeCap = StrokeCap.round;
        final path = Path();
        const wavelength = 12.0;
        final amplitude = math.min(size.height / 2 - 1, 3.0);

        path.moveTo(0, midY);
        for (double x = 0; x < size.width; x += wavelength) {
          path.relativeQuadraticBezierTo(
            wavelength / 4,
            -amplitude,
            wavelength / 2,
            0,
          );
          path.relativeQuadraticBezierTo(
            wavelength / 4,
            amplitude,
            wavelength / 2,
            0,
          );
        }
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimalDividerLinePainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.thickness != thickness;
}
