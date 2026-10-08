import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';

/// Animated 3D sliding pill indicator for [AnimalTabs].
///
/// Addresses defect F26: dynamic geometry updates driven by actual layout Rects,
/// smoothly tracking tab position across text changes, window resize, and font scaling.
class AnimalTabIndicator extends StatelessWidget {
  /// Bounds of the selected tab within the tab stack; null hides the
  /// indicator.
  final Rect? targetRect;

  /// Theme that supplies the indicator color, radius, shadow and motion.
  final AnimalIslandTheme theme;

  /// Duration of the slide; null uses the theme normal motion duration.
  final Duration? duration;

  /// Curve of the slide; null uses the theme spring curve.
  final Curve? curve;

  /// Creates an indicator that slides to [targetRect].
  const AnimalTabIndicator({
    super.key,
    required this.targetRect,
    required this.theme,
    this.duration,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    if (targetRect == null) {
      return const SizedBox.shrink();
    }

    final rect = targetRect!;
    return AnimatedPositioned(
      duration: duration ?? theme.motion.normal,
      curve: curve ?? theme.motion.spring,
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.primary,
          borderRadius: theme.radii.pillBorder,
          boxShadow: [theme.shadows.button3d],
        ),
      ),
    );
  }
}
