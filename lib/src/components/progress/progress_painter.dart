import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Custom painter for signature 45° diagonal candy-cane stripes on [AnimalProgress].
class AnimalCandyStripePainter extends CustomPainter {
  /// Fill of the progress bar.
  final Color fillColor;

  /// Color of the diagonal stripes drawn over the fill; null draws none.
  final Color? stripeColor;

  /// Stripe offset as a fraction of one stripe period, from 0 to 1. The
  /// painter repaints whenever it changes.
  final Animation<double> phase;

  /// Corner radius of the clipped bar.
  final double radius;

  /// Creates a painter for a filled, optionally striped bar.
  AnimalCandyStripePainter({
    required this.fillColor,
    required this.stripeColor,
    required this.phase,
    required this.radius,
  }) : super(repaint: phase);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Clip to rounded pill
    canvas.save();
    canvas.clipRRect(rrect);

    // 1. Draw solid background
    final bgPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, bgPaint);

    // 2. Draw 45-degree candy-cane stripes if enabled
    final Color? stripeColor = this.stripeColor;
    if (stripeColor != null) {
      final stripePaint = Paint()
        ..color = stripeColor
        ..style = PaintingStyle.fill;

      const stripeWidth = 14.0;
      final period = stripeWidth * 2;
      final shift = phase.value * period;

      final path = Path();
      // Draw diagonal parallel quadrilaterals spanning from -height to width + height
      for (
        double x = -size.height - period + shift;
        x < size.width + period;
        x += period
      ) {
        path.moveTo(x, size.height);
        path.lineTo(x + stripeWidth, size.height);
        path.lineTo(x + stripeWidth + size.height, 0);
        path.lineTo(x + size.height, 0);
        path.close();
      }

      canvas.drawPath(path, stripePaint);
    }

    // 3. Subtle glossy top highlight
    final highlightPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.4),
      highlightPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnimalCandyStripePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.stripeColor != stripeColor ||
        oldDelegate.radius != radius ||
        oldDelegate.phase != phase;
  }
}

/// Custom painter for circular progress ring on [AnimalProgress.circle].
class AnimalCircularProgressPainter extends CustomPainter {
  /// Completed fraction of the ring, where 1 is a full circle.
  final double percent;

  /// Stroke width of the track and the arc.
  final double strokeWidth;

  /// Color of the progress arc.
  final Color fillColor;

  /// Color of the full background ring.
  final Color trackColor;

  /// Creates a painter for a circular progress ring.
  const AnimalCircularProgressPainter({
    required this.percent,
    required this.strokeWidth,
    required this.fillColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    if (radius <= 0) return;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (percent > 0) {
      final progressPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * percent;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimalCircularProgressPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor;
  }
}
