import 'package:flutter/rendering.dart';

/// Paints one explicit shape with a recipe-owned dashed stroke.
///
/// Each contour starts at phase zero; a trailing dash stops at its end. Open
/// contours stay open. This painter adds no fill, clipping, layout or semantics.
/// The shape receives the bounds inset by half [strokeWidth]. Zero width uses
/// Canvas hairline behavior. Inputs and shapes must remain immutable.
///
/// [dash] must be finite and positive; [gap] and [strokeWidth] must be finite and
/// nonnegative. These caller preconditions are asserted by the constructor.
class IslandDashedBorderPainter extends CustomPainter {
  const IslandDashedBorderPainter({
    required this.shape,
    required this.color,
    this.strokeWidth = 1,
    this.dash = 4,
    this.gap = 4,
  }) : assert(dash > 0 && dash < double.infinity),
       assert(gap >= 0 && gap < double.infinity),
       assert(strokeWidth >= 0 && strokeWidth < double.infinity);

  final OutlinedBorder shape;
  final Color color;
  final double strokeWidth, dash, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final path = shape.getOuterPath(
      (Offset.zero & size).deflate(strokeWidth / 2),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      for (
        double distance = 0;
        distance < metric.length;
        distance += dash + gap
      ) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            (distance + dash).clamp(0, metric.length),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(IslandDashedBorderPainter old) =>
      old.shape != shape ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}
