import 'package:flutter/rendering.dart';

class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter(
    this.shape,
    this.side, {
    this.dash = 4,
    this.gap = 4,
  });
  final OutlinedBorder shape;
  final BorderSide side;
  final double dash, gap;
  @override
  void paint(Canvas canvas, Size size) {
    final path = shape.getOuterPath(
      (Offset.zero & size).deflate(side.width / 2),
    );
    final paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = side.width;
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += dash + gap) {
        canvas.drawPath(
          metric.extractPath(d, (d + dash).clamp(0, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.shape != shape ||
      old.side != side ||
      old.dash != dash ||
      old.gap != gap;
}
