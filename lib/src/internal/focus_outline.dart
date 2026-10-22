import 'package:flutter/painting.dart';

/// A component-owned outline policy paints without contributing layout padding.
class FocusOutline extends Decoration {
  const FocusOutline(
    this.shape,
    this.color, {
    required this.width,
    required this.offset,
    this.backingColor,
  });
  final OutlinedBorder shape;
  final Color color;
  final Color? backingColor;
  final double width, offset;
  @override
  Decoration? lerpFrom(Decoration? a, double t) => a is FocusOutline
      ? FocusOutline(
          OutlinedBorder.lerp(a.shape, shape, t)!,
          Color.lerp(a.color, color, t)!,
          backingColor: Color.lerp(a.backingColor, backingColor, t),
          width: a.width + (width - a.width) * t,
          offset: a.offset + (offset - a.offset) * t,
        )
      : super.lerpFrom(a, t);
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _FocusOutlinePainter(this);
}

class _FocusOutlinePainter extends BoxPainter {
  _FocusOutlinePainter(this.decoration);
  final FocusOutline decoration;
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final path = decoration.shape.getOuterPath(
      (offset & configuration.size!).inflate(
        decoration.offset + decoration.width / 2,
      ),
      textDirection: configuration.textDirection,
    );
    if (decoration.backingColor case final backing?) {
      canvas.drawPath(
        path,
        Paint()
          ..color = backing
          ..style = PaintingStyle.stroke
          ..strokeWidth = decoration.width + 2,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = decoration.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = decoration.width,
    );
  }
}
