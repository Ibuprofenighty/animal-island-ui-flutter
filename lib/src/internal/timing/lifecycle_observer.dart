import 'package:flutter/widgets.dart';

/// Single unified lifecycle observer hook for timing and animation components.
class AnimalLifecycleObserver with WidgetsBindingObserver {
  /// Called when the app lifecycle state changes to a different value.
  final ValueChanged<AppLifecycleState>? onStateChanged;
  AppLifecycleState? _state;
  bool _attached = false;

  /// Creates an observer seeded with the binding's current lifecycle state.
  /// It receives no changes until [attach] is called.
  AnimalLifecycleObserver({this.onStateChanged})
    : _state = WidgetsBinding.instance.lifecycleState;

  /// Whether the app is resumed, or its lifecycle state is not yet known.
  bool get isForeground =>
      _state == null || _state == AppLifecycleState.resumed;

  /// Registers this observer with the widgets binding. Repeated calls do
  /// nothing.
  void attach() {
    if (_attached) return;
    WidgetsBinding.instance.addObserver(this);
    _attached = true;
  }

  /// Unregisters this observer from the widgets binding. Calls while
  /// detached do nothing.
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
