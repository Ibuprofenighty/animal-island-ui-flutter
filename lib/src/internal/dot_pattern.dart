import 'package:flutter/rendering.dart';

/// Shared two-layer dot geometry. Each surface supplies its own color contract.
class DotPatternPainter extends CustomPainter {
  const DotPatternPainter({required this.largeDot, required this.smallDot});
  final Color largeDot, smallDot;
  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in [(14.0, 1.0, smallDot), (28.0, 1.4, largeDot)]) {
      final brush = Paint()..color = layer.$3;
      for (double x = 14; x < size.width; x += layer.$1) {
        for (double y = 14; y < size.height; y += layer.$1) {
          canvas.drawCircle(Offset(x, y), layer.$2, brush);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DotPatternPainter old) =>
      old.largeDot != largeDot || old.smallDot != smallDot;
}
