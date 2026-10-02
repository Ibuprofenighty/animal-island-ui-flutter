import 'package:flutter/widgets.dart';

/// Single unified lifecycle observer hook for timing and animation components.
class AnimalLifecycleObserver with WidgetsBindingObserver {
  final ValueChanged<AppLifecycleState>? onStateChanged;
  AppLifecycleState? _state;
  bool _attached = false;

  AnimalLifecycleObserver({this.onStateChanged})
    : _state = WidgetsBinding.instance.lifecycleState;

  bool get isForeground =>
      _state == null || _state == AppLifecycleState.resumed;

  void attach() {
    if (_attached) return;
    WidgetsBinding.instance.addObserver(this);
    _attached = true;
  }

  void detach() {
    if (!_attached) return;
    WidgetsBinding.instance.removeObserver(this);
    _attached = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_state == state) return;
    _state = state;
    onStateChanged?.call(state);
  }
}
