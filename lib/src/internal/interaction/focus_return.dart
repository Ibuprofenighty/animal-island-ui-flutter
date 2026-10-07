import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The single focus return of the package's blocking surfaces (Modal,
/// Drawer, ImagePreview routes and the full-screen Loading).
///
/// [capture] records the control that holds focus when the surface opens;
/// [restore] gives focus back to it after the frame in which the surface
/// leaves, when that control is still mounted and focusable.
final class AnimalFocusReturn {
  AnimalFocusReturn.capture() : _target = FocusManager.instance.primaryFocus;

  FocusNode? _target;

  /// Returns focus to the captured control once. Later calls do nothing.
  void restore() {
    final FocusNode? target = _target;
    _target = null;
    if (target == null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final BuildContext? context = target.context;
      if (context != null && context.mounted && target.canRequestFocus) {
        target.requestFocus();
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }
}
