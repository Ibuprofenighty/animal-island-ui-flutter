import 'package:flutter/widgets.dart';

/// Single unified lifecycle observer hook for timing and animation components.
class AnimalLifecycleObserver with WidgetsBindingObserver {
  final ValueChanged<AppLifecycleState>? onStateChanged;

  AnimalLifecycleObserver({this.onStateChanged});

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onStateChanged?.call(state);
  }
}
