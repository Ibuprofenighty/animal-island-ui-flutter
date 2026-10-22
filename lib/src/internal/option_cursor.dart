import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative hover cursor; option text and its stable backing carry meaning.
class OptionCursor extends StatelessWidget {
  const OptionCursor({super.key, required this.reduced});
  final bool reduced;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: reduced ? Duration.zero : const Duration(milliseconds: 500),
    child: const CustomPaint(size: Size(10, 14), painter: _OptionTriangle()),
    builder: (_, value, child) {
      final entering = value < .6;
      final t = Curves.easeOut.transform(
        entering ? value / .6 : (value - .6) / .4,
      );
      return Opacity(
        opacity: entering ? t : 1,
        child: Transform.translate(
          offset: Offset(entering ? -20 + 25 * t : 5 * (1 - t), 0),
          child: Transform.rotate(
            angle: (entering ? -15 + 20 * t : 5 * (1 - t)) * math.pi / 180,
            child: child,
          ),
        ),
      );
    },
  );
}

class _OptionTriangle extends CustomPainter {
  const _OptionTriangle();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xfff5a623),
    );
  }

  @override
  bool shouldRepaint(_OptionTriangle oldDelegate) => false;
}
