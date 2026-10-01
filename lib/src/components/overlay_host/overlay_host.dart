import 'package:flutter/widgets.dart';

import 'overlay_controller.dart';
export 'overlay_controller.dart';

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

/// Host widget that provides a scoped overlay realm for Animal Island UI overlays
/// such as notifications, loading screens, and floating banners.
///
/// Ensures strict multi-app isolation and prevents cross-host state contamination (F07 / F14).
class AnimalOverlayHost extends StatefulWidget {
  final Widget child;
  final AnimalOverlayController? controller;

  const AnimalOverlayHost({super.key, required this.child, this.controller});

  /// Retrieves the nearest [AnimalOverlayController] from the widget tree.
  static AnimalOverlayController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError(
        'AnimalOverlayHost.of() was called with a context that does not contain an AnimalOverlayHost.\n'
        'Wrap your screen or MaterialApp in AnimalOverlayHost.',
      );
    }
    return controller;
  }

  /// Retrieves the nearest [AnimalOverlayController] from the widget tree, or null if not found.
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
  AnimalOverlayController? _internalController;

  AnimalOverlayController get _effectiveController =>
      widget.controller ?? (_internalController ??= AnimalOverlayController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayKey.currentState != null) {
        _effectiveController.attachOverlay(_overlayKey.currentState!);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimalOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detachOverlay();
      if (_overlayKey.currentState != null) {
        _effectiveController.attachOverlay(_overlayKey.currentState!);
      }
    }
  }

  @override
  void dispose() {
    _effectiveController.detachOverlay();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimalOverlayHostScope(
      controller: _effectiveController,
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
