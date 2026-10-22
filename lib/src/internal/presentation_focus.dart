import 'dart:async';

import 'package:flutter/widgets.dart';

/// Let semantic DOM moves finish before reconciling the view's saved focus.
/// An explicit control destination or an inactive browser always wins.
void settlePresentationFocus({
  required bool Function() current,
  VoidCallback? onComplete,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!current()) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleMicrotask(() {
        if (!current()) return;
        final lifecycle = WidgetsBinding.instance.lifecycleState;
        if (lifecycle == null || lifecycle == AppLifecycleState.resumed) {
          final manager = FocusManager.instance;
          if (identical(manager.primaryFocus, manager.rootScope)) {
            manager.rootScope.requestFocus();
          }
        }
        onComplete?.call();
      });
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  });
}
