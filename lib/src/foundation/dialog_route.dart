import 'package:flutter/material.dart';

import '../internal/surface_motion.dart';
import '../internal/action_surface.dart';

/// Presents caller-owned dialog content with opaque displacement, not a fade.
/// Push on Navigator.of(context, rootNavigator: true), matching captured themes.
/// The creator retains route lifetime and may remove this exact route on disposal;
/// The route owns presentation and closed-loop traversal by default. Explicit
/// traversal overrides survive; the builder owns its surface and semantics.
class IslandDialogRoute<T> extends DialogRoute<T> {
  IslandDialogRoute({
    required BuildContext context,
    required super.builder,
    super.barrierColor,
    super.barrierDismissible,
    super.barrierLabel,
    super.traversalEdgeBehavior = TraversalEdgeBehavior.closedLoop,
  }) : _reduced = MediaQuery.disableAnimationsOf(context),
       super(
         context: context,
         themes: InheritedTheme.capture(
           from: context,
           to: Navigator.of(context, rootNavigator: true).context,
         ),
       );
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => ClosedLoopTraversal(
    child: super.buildPage(context, animation, secondaryAnimation),
  );

  bool _reduced;
  @override
  Duration get transitionDuration =>
      _reduced ? Duration.zero : super.transitionDuration;

  /// Update when the owning component has a reduced-motion boundary outside the
  /// Navigator overlay. Active forward/reverse motion settles on the next frame.
  void updateReducedMotion(bool value) {
    if (_reduced == value) return;
    _reduced = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator == null) return;
      final motion = controller;
      if (_reduced && motion != null && motion.isAnimating) {
        motion.value = motion.status == AnimationStatus.reverse ? 0 : 1;
      }
      changedExternalState();
    });
  }

  bool _settling = false;
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if ((_reduced || MediaQuery.disableAnimationsOf(context)) &&
        animation.isAnimating &&
        !_settling) {
      _settling = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _settling = false;
        if (!context.mounted ||
            !(_reduced || MediaQuery.disableAnimationsOf(context)))
          return;
        final value = controller;
        if (value != null && value.isAnimating) {
          value.value = value.status == AnimationStatus.reverse ? 0 : 1;
        }
      });
    }
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => SurfaceMotion(
        progress: _reduced ? 1 : Curves.ease.transform(animation.value),
        offset: const Offset(0, 8),
        child: child!,
      ),
    );
  }
}
