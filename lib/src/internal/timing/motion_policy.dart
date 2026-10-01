import 'package:flutter/widgets.dart';

/// Policy governing motion, reduced motion, and ticker suppression for Animal Island UI.
abstract final class AnimalMotionPolicy {
  /// Checks whether visual motion and spring physics should animate in the given [context].
  ///
  /// Returns `false` if the host platform requests reduced motion or if [TickerMode] is disabled.
  static bool shouldAnimate(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) return false;
    return TickerMode.valuesOf(context).enabled;
  }

  /// Resolves the effective animation duration respecting reduced motion settings.
  static Duration effectiveDuration(
    BuildContext context,
    Duration naturalDuration,
  ) {
    if (!shouldAnimate(context)) {
      return Duration.zero;
    }
    return naturalDuration;
  }
}
