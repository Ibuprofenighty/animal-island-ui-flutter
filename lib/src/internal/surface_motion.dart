import 'package:flutter/widgets.dart';

/// Moves one readable surface. Never fades, clones, or inspects its contents.
/// The caller owns visibility, timers, focus, and the animation timeline.
class SurfaceMotion extends StatelessWidget {
  const SurfaceMotion({
    super.key,
    required this.progress,
    required this.child,
    this.offset = Offset.zero,
    this.beginScale = 1,
    this.pulse = false,
    this.alignment = Alignment.center,
  });
  final double progress, beginScale;
  final Offset offset;
  final bool pulse;
  final Alignment alignment;
  final Widget child;
  static double bounce(double progress) {
    final t = progress.clamp(0.0, 1.0);
    return t < .6
        ? 1 + .08 * Curves.easeOut.transform(t / .6)
        : 1.08 - .08 * Curves.easeInOut.transform((t - .6) / .4);
  }

  @override
  Widget build(BuildContext context) {
    final t = MediaQuery.disableAnimationsOf(context) ? 1.0 : progress;
    final scale = pulse ? bounce(t) : beginScale + (1 - beginScale) * t;
    final translation = offset * (1 - t);
    return Transform(
      transform: Matrix4.translationValues(translation.dx, translation.dy, 0)
        ..scaleByDouble(scale, scale, 1, 1),
      alignment: alignment,
      filterQuality: FilterQuality.low,
      child: child,
    );
  }
}
