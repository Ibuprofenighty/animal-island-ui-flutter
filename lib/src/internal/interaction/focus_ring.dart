import 'package:flutter/widgets.dart';

import '../../foundation/theme/components/focus_ring_theme.dart';
import '../../foundation/theme/theme.dart';

/// The focus indicator every component uses, resolved once from the theme.
///
/// `AnimalIslandTheme.components.focusRing` overrides the default width,
/// offset and color; components that draw their own focused border use
/// [color] so the whole library shows one focus color.
({double width, double offset, Color color, BorderRadius borderRadius})
resolveFocusRing(AnimalIslandTheme theme) {
  final AnimalFocusRingStyle? style = theme.components.focusRing;
  return (
    width: style?.width ?? 2.5,
    offset: style?.offset ?? 2.0,
    color: style?.color ?? theme.colors.focusYellow,
    // A component passes its own shape; a bare ring is a pill.
    borderRadius: theme.radii.pillBorder,
  );
}

/// Cozy rounded focus ring for Animal Island UI.
///
/// Wraps [child] and renders a playful, high-visibility focus outline
/// in the active theme's focus color when [focused] is true, eliminating
/// platform-default blue focus rectangles.
class AnimalFocusRing extends StatelessWidget {
  final Widget child;
  final bool focused;
  final BorderRadius? borderRadius;

  const AnimalFocusRing({
    super.key,
    required this.child,
    required this.focused,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!focused) return child;

    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final ring = resolveFocusRing(theme);
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? ring.borderRadius;
    return CustomPaint(
      foregroundPainter: _FocusRingPainter(
        color: ring.color,
        borderRadius: effectiveBorderRadius,
        ringWidth: ring.width,
        ringOffset: ring.offset,
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
