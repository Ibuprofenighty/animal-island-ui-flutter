import 'package:flutter/widgets.dart';

import '../../internal/overlay/overlay_callback.dart';

part 'overlay_controller.dart';

/// Scope provider for [AnimalOverlayController].
class _AnimalOverlayHostScope extends InheritedWidget {
  final AnimalOverlayController controller;

  const _AnimalOverlayHostScope({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AnimalOverlayHostScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// The unique scoped owner of notification and loading overlays.
///
/// Overlays shown through [of] live in this host's own [Overlay], so two hosts
/// under one Navigator never share occurrences. There is no root-overlay or
/// global fallback: a context without a host is a configuration error.
///
/// Without a [controller] the host creates and disposes its own. A supplied
/// controller remains owned by the caller; the host only binds it while
/// mounted and closes its live occurrences when it unbinds.
///
/// Unbinding happens when the host is removed or its [controller] changes.
/// In the latter case the old controller's `onClose` callbacks run during the
/// host's rebuild, so they must not synchronously rebuild an ancestor.
class AnimalOverlayHost extends StatefulWidget {
  /// Subtree that can show overlays in this host.
  final Widget child;

  /// Controller bound while the host is mounted; null makes the host create
  /// and dispose its own.
  final AnimalOverlayController? controller;

  /// Creates an overlay host around [child].
  const AnimalOverlayHost({super.key, required this.child, this.controller});

  /// Returns the controller of the nearest [AnimalOverlayHost].
  ///
  /// Throws a [FlutterError] when [context] has no host.
  static AnimalOverlayController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError(
        'AnimalOverlayHost.of() was called with a context that does not '
        'contain an AnimalOverlayHost.\n'
        'Wrap your screen or MaterialApp in AnimalOverlayHost.',
      );
    }
    return controller;
  }

  /// Returns the controller of the nearest [AnimalOverlayHost], or null.
  static AnimalOverlayController? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AnimalOverlayHostScope>();
    return scope?.controller;
  }

  @override
  State<AnimalOverlayHost> createState() => _AnimalOverlayHostState();
}

class _AnimalOverlayHostState extends State<AnimalOverlayHost> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();
  AnimalOverlayController? _ownedController;
  // The controller and overlay attached together by _bind.
  (AnimalOverlayController, OverlayState)? _binding;

  AnimalOverlayController get _controller =>
      widget.controller ?? (_ownedController ??= AnimalOverlayController());

  @override
  void initState() {
    super.initState();
    // The Overlay exists after the first build; occurrences shown earlier stay
    // created and are inserted when the host binds.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
  }

  @override
  void didUpdateWidget(covariant AnimalOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == oldWidget.controller) return;
    _unbind();
    if (widget.controller != null) {
      // A caller now supplies the controller; release the one this host made.
      _ownedController?.dispose();
      _ownedController = null;
    }
    _bind();
  }

  void _bind() {
    if (!mounted) return;
    final OverlayState? overlay = _overlayKey.currentState;
    if (overlay == null) return;
    final AnimalOverlayController controller = _controller;
    controller._attach(overlay);
    _binding = (controller, overlay);
  }

  void _unbind() {
    final (AnimalOverlayController, OverlayState)? binding = _binding;
    _binding = null;
    if (binding == null) return;
    final (AnimalOverlayController controller, OverlayState overlay) = binding;
    controller._detach(overlay);
  }

  @override
  void dispose() {
    _unbind();
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimalOverlayHostScope(
      controller: _controller,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Overlay(key: _overlayKey),
        ],
      ),
    );
  }
}
