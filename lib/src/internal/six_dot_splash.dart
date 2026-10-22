import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Reference six-dot box-shadow geometry; callers own time and center fill.
void paintSixDotSplash(
  Canvas canvas,
  Offset center,
  double extent,
  Color color,
  double value,
) {
  final first = value < .4;
  final progress = Curves.ease.transform(
    first ? value / .4 : (value - .4) / .6,
  );
  final distance = first ? progress : 1 + progress;
  final spread = first ? -8 * progress : -8 - 2 * progress;
  final paint = Paint()
    ..color = color.withValues(alpha: first ? progress : 1 - progress);
  for (final offset in const [
    Offset(0, -18),
    Offset(16, -8),
    Offset(16, 8),
    Offset(0, 18),
    Offset(-16, 8),
    Offset(-16, -8),
  ]) {
    canvas.drawCircle(
      center + offset * distance,
      math.max(0, extent / 2 + spread),
      paint,
    );
  }
}
