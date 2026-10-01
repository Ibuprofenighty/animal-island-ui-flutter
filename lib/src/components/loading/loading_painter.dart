import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Particle model representing a single snowflake.
class SnowflakeParticle {
  final double x;
  final double y;
  final double speed;
  final double radius;
  final double swayAmplitude;
  final double swayFrequency;
  final double swayPhase;
  final double opacity;

  const SnowflakeParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.swayPhase,
    required this.opacity,
  });

  /// Factory creating a list of particles with an optional deterministic seed for tests/goldens.
  static List<SnowflakeParticle> generate(int count, {int? seed}) {
    final rand = seed != null ? math.Random(seed) : math.Random();
    return List.generate(count, (_) {
      return SnowflakeParticle(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        speed: 0.15 + rand.nextDouble() * 0.45,
        radius: 2.0 + rand.nextDouble() * 4.5,
        swayAmplitude: 0.02 + rand.nextDouble() * 0.05,
        swayFrequency: 2.0 + rand.nextDouble() * 4.0,
        swayPhase: rand.nextDouble() * math.pi * 2,
        opacity: 0.35 + rand.nextDouble() * 0.55,
      );
    });
  }
}

/// Fullscreen or local snowflake particle system painter.
class SnowflakeOverlayPainter extends CustomPainter {
  final List<SnowflakeParticle> snowflakes;
  final double progress;
  final Color color;

  const SnowflakeOverlayPainter({
    required this.snowflakes,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final flake in snowflakes) {
      final currentY = (flake.y + progress * flake.speed) % 1.0;
      final sway =
          math.sin(
            progress * flake.swayFrequency * 2 * math.pi + flake.swayPhase,
          ) *
          flake.swayAmplitude;
      final currentX = (flake.x + sway) % 1.0;

      final paint = Paint()
        ..color = color.withValues(alpha: flake.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height),
        flake.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SnowflakeOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Custom painter for spinning leaf or circular arc.
class SpinnerArcPainter extends CustomPainter {
  final Color color;
  final double progress;

  const SpinnerArcPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = progress * math.pi * 2;
    const sweepAngle = math.pi * 1.3;
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant SpinnerArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
