import 'package:flutter/widgets.dart';

import '../../foundation/theme/components/tabs_theme.dart';
import '../../internal/timing/motion_policy.dart';

/// Selected pill rendered from the same stable-ID geometry as the tab row.
class AnimalTabIndicator extends StatelessWidget {
  /// Selected tab bounds in the row's coordinate system; null hides the pill.
  final Rect? targetRect;

  /// Fully resolved visual values from the tab owner's single resolver.
  final AnimalTabsStyle style;

  /// Creates the internal pill renderer.
  const AnimalTabIndicator({
    super.key,
    required this.targetRect,
    required this.style,
  });
  @override
  Widget build(BuildContext context) {
    final rect = targetRect;
    if (rect == null) return const SizedBox.shrink();
    return AnimatedPositioned(
      duration: AnimalMotionPolicy.shouldAnimate(context)
          ? style.duration!
          : Duration.zero,
      curve: style.curve!,
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: style.indicatorColor,
            borderRadius: style.borderRadius,
            boxShadow: [style.shadow!],
          ),
        ),
      ),
    );
  }
}
