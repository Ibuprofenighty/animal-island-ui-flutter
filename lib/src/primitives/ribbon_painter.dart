import 'package:flutter/rendering.dart';

/// CustomPainter for the Animal Island Swallowtail Ribbon (Title component).
///
/// Features:
/// - 3-layer dimensional structure:
///   1. Back wings: left & right notched swallowtails
///   2. Folded triangle shadows underneath
///   3. Front elevated banner
class AnimalRibbonPainter extends CustomPainter {
  final Color frontColor;
  final Color backColor;
  final Color foldColor;
  final double wingWidth;
  final double foldDrop;

  const AnimalRibbonPainter({
    required this.frontColor,
    required this.backColor,
    required this.foldColor,
    this.wingWidth = 24.0,
    this.foldDrop = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final backPaint = Paint()..color = backColor;
    final foldPaint = Paint()..color = foldColor;
    final frontPaint = Paint()..color = frontColor;

    // 1. Left Swallowtail Wing
    final leftWing = Path()
      ..moveTo(0, foldDrop)
      ..lineTo(wingWidth, foldDrop)
      ..lineTo(wingWidth, h)
      ..lineTo(0, h)
      ..lineTo(wingWidth * 0.4, foldDrop + (h - foldDrop) / 2)
      ..close();
    canvas.drawPath(leftWing, backPaint);

    // 2. Right Swallowtail Wing
    final rightWing = Path()
      ..moveTo(w - wingWidth, foldDrop)
      ..lineTo(w, foldDrop)
      ..lineTo(w - wingWidth * 0.4, foldDrop + (h - foldDrop) / 2)
      ..lineTo(w, h)
      ..lineTo(w - wingWidth, h)
      ..close();
    canvas.drawPath(rightWing, backPaint);

    // 3. Left Fold Triangle Shadow
    final leftFold = Path()
      ..moveTo(wingWidth, h - foldDrop)
      ..lineTo(wingWidth, h)
      ..lineTo(wingWidth + foldDrop, h - foldDrop)
      ..close();
    canvas.drawPath(leftFold, foldPaint);

    // 4. Right Fold Triangle Shadow
    final rightFold = Path()
      ..moveTo(w - wingWidth, h - foldDrop)
      ..lineTo(w - wingWidth, h)
      ..lineTo(w - wingWidth - foldDrop, h - foldDrop)
      ..close();
    canvas.drawPath(rightFold, foldPaint);

    // 5. Front Banner Body
    final frontRect = Rect.fromLTWH(
      wingWidth,
      0,
      w - (wingWidth * 2),
      h - foldDrop,
    );
    canvas.drawRect(frontRect, frontPaint);
  }

  @override
  bool shouldRepaint(covariant AnimalRibbonPainter oldDelegate) {
    return oldDelegate.frontColor != frontColor ||
        oldDelegate.backColor != backColor ||
        oldDelegate.foldColor != foldColor ||
        oldDelegate.wingWidth != wingWidth ||
        oldDelegate.foldDrop != foldDrop;
  }
}
