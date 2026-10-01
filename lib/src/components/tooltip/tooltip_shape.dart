import 'package:flutter/material.dart';

/// Organic speech bubble shape border with a pointing beak arrow for [AnimalTooltip].
class AnimalIslandBubbleShapeBorder extends ShapeBorder {
  /// Color of the outline border.
  final Color borderColor;

  /// Width of the outline stroke.
  final double borderWidth;

  /// Corner radius of the rounded rectangle bubble body.
  final double radius;

  /// Height / size of the arrow beak.
  final double arrowSize;

  const AnimalIslandBubbleShapeBorder({
    required this.borderColor,
    this.borderWidth = 1.5,
    required this.radius,
    this.arrowSize = 6.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowSize);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(borderWidth), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final bubbleRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width,
      rect.height - arrowSize,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(bubbleRect, Radius.circular(radius)));

    final arrowCenterX = rect.center.dx;
    final arrowTop = bubbleRect.bottom;
    final arrowBottom = rect.bottom;

    final arrowPath = Path()
      ..moveTo(arrowCenterX - arrowSize * 1.2, arrowTop)
      ..lineTo(arrowCenterX, arrowBottom)
      ..lineTo(arrowCenterX + arrowSize * 1.2, arrowTop)
      ..close();

    return Path.combine(PathOperation.union, path, arrowPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderWidth <= 0 || borderColor == Colors.transparent) return;
    final path = getOuterPath(rect, textDirection: textDirection);
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) => AnimalIslandBubbleShapeBorder(
    borderColor: borderColor,
    borderWidth: borderWidth * t,
    radius: radius * t,
    arrowSize: arrowSize * t,
  );
}
