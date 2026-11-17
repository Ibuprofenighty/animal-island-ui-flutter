import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Reports whether the state's box intersects the screen and every ancestor
/// scroll viewport, so an endless decoration can stop while it is not shown.
///
/// While watched, the box is measured after each produced frame. This follows
/// scrolling, layout and ancestor paint transforms alike, and never schedules
/// a frame itself.
mixin ViewportPresence<T extends StatefulWidget> on State<T> {
  bool _watched = false, _pending = false, _present = false;

  /// Whether some of the box was visible at the last measured frame.
  bool get inViewport => _present;

  /// Called after a frame when [inViewport] changed.
  void viewportPresenceChanged();

  /// Starts or stops measuring. A newly watched box counts as shown until its
  /// first measured frame, so its motion starts without a frame of delay; an
  /// unwatched box is not in the viewport.
  void watchViewport(bool watch) {
    if (watch == _watched) return;
    _watched = _present = watch;
    if (watch && !_pending) _measureAfterFrame();
  }

  void _measureAfterFrame() {
    _pending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      if (!mounted || !_watched) return;
      final next = _measure();
      if (next != _present) {
        _present = next;
        viewportPresenceChanged();
      }
      if (mounted && _watched) _measureAfterFrame();
    });
  }

  bool _measure() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return false;
    final view = View.of(context);
    var rect = MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    ).intersect(Offset.zero & view.physicalSize / view.devicePixelRatio);
    for (
      var scrollable = Scrollable.maybeOf(context);
      scrollable != null;
      scrollable = Scrollable.maybeOf(scrollable.context)
    ) {
      final viewport = scrollable.context.findRenderObject() as RenderBox?;
      if (viewport == null || !viewport.hasSize) continue;
      rect = rect.intersect(
        MatrixUtils.transformRect(
          viewport.getTransformTo(null),
          Offset.zero & viewport.size,
        ),
      );
    }
    return rect.width > 0 && rect.height > 0;
  }
}
