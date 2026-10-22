import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../foundation/background_type.dart';
import 'sprinkle_data.dart';
import 'dot_pattern.dart';

class BackgroundPainter extends CustomPainter {
  const BackgroundPainter(this.type);
  final IslandBackgroundType type;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = type.color);
    if (type == IslandBackgroundType.grid) {
      final p = Paint()
        ..color = const Color(0xffc4b89e)
        ..strokeWidth = 1;
      for (double x = .5; x < size.width; x += 24) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      }
      for (double y = .5; y < size.height; y += 24) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      }
    } else if (type == IslandBackgroundType.sprinkles) {
      canvas.save();
      canvas.clipRect(Offset.zero & size);
      for (final layer in sprinkleLayers.reversed) {
        for (double x = layer.$3 - layer.$1; x < size.width; x += layer.$1) {
          for (double y = layer.$4 - layer.$2; y < size.height; y += layer.$2) {
            for (final shape in layer.$5) {
              canvas.save();
              canvas.translate(x + shape.$1, y + shape.$2);
              canvas.rotate(shape.$3 * math.pi / 180);
              final rect = Rect.fromLTWH(0, 0, shape.$4, shape.$5);
              final round = RRect.fromRectAndRadius(
                rect,
                Radius.circular(shape.$5 / 2),
              );
              canvas.drawRRect(round, Paint()..color = shape.$6);
              canvas.drawRRect(
                round,
                Paint()
                  ..shader = const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x8cffffff),
                      Color(0x00ffffff),
                      Color(0x40000000),
                    ],
                    stops: [0, .45, 1],
                  ).createShader(rect),
              );
              canvas.restore();
            }
          }
        }
      }
      canvas.restore();
    } else {
      DotPatternPainter(
        largeDot: type.largeDot,
        smallDot: type.smallDot,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter old) => old.type != type;
}
