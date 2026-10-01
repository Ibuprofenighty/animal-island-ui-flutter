import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';

/// Cozy rounded focus ring for Animal Island UI.
///
/// Wraps [child] and renders a playful, high-visibility focus outline
/// in the active theme's focus color when [focused] is true, eliminating
/// platform-default blue focus rectangles.
class AnimalFocusRing extends StatelessWidget {
  final Widget child;
  final bool focused;
  final BorderRadius? borderRadius;
  final double ringWidth;
  final double ringOffset;
  final Color? color;

  const AnimalFocusRing({
    super.key,
    required this.child,
    required this.focused,
    this.borderRadius,
    this.ringWidth = 2.5,
    this.ringOffset = 2.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!focused) return child;

    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final Color ringColor = color ?? theme.colors.focusYellow;
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? theme.radii.pillBorder;
    return CustomPaint(
      foregroundPainter: _FocusRingPainter(
        color: ringColor,
        borderRadius: effectiveBorderRadius,
        ringWidth: ringWidth,
        ringOffset: ringOffset,
      ),
      child: child,
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  final Color color;
  final BorderRadius borderRadius;
  final double ringWidth;
  final double ringOffset;

  _FocusRingPainter({
    required this.color,
    required this.borderRadius,
    required this.ringWidth,
    required this.ringOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;

    final outerRect = Rect.fromLTWH(
      -ringOffset,
      -ringOffset,
      size.width + (ringOffset * 2),
      size.height + (ringOffset * 2),
    );
    final rrect = borderRadius.toRRect(outerRect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.ringWidth != ringWidth ||
        oldDelegate.ringOffset != ringOffset;
  }
}
