import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'focus_ring.dart';

/// One keyboard entry point for an overflowing horizontal viewport.
/// The builder attaches the supplied controller to its sole scroll position.
/// Descendant editors retain their own keys; only this region's primary focus
/// scrolls. Borrowed controllers remain with the caller.
class HorizontalScrollRegion extends StatefulWidget {
  /// Borrowed controller, or null to let this region own one.
  final ScrollController? controller;

  /// Builds the sole viewport attached to the effective controller.
  final Widget Function(ScrollController controller) builder;

  /// Surface shape used by the shared focus ring.
  final BorderRadius borderRadius;

  /// Creates the package-internal keyboard boundary of one horizontal viewport.
  const HorizontalScrollRegion({
    super.key,
    required this.controller,
    required this.builder,
    required this.borderRadius,
  });

  @override
  State<HorizontalScrollRegion> createState() => _HorizontalScrollRegionState();
}

class _HorizontalScrollRegionState extends State<HorizontalScrollRegion> {
  ScrollController? _ownedController;
  bool _focused = false;

  ScrollController get _controller =>
      widget.controller ?? (_ownedController ??= ScrollController());

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!node.hasPrimaryFocus ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.arrowLeft &&
        key != LogicalKeyboardKey.arrowRight &&
        key != LogicalKeyboardKey.home &&
        key != LogicalKeyboardKey.end &&
        key != LogicalKeyboardKey.pageUp &&
        key != LogicalKeyboardKey.pageDown) {
      return KeyEventResult.ignored;
    }
    final controller = _controller;
    if (!controller.hasClients) return KeyEventResult.ignored;
    final position = controller.position;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final double target;
    if (key == LogicalKeyboardKey.home) {
      target = position.minScrollExtent;
    } else if (key == LogicalKeyboardKey.end) {
      target = position.maxScrollExtent;
    } else if (key == LogicalKeyboardKey.pageUp) {
      target = position.pixels - position.viewportDimension;
    } else if (key == LogicalKeyboardKey.pageDown) {
      target = position.pixels + position.viewportDimension;
    } else {
      // Flutter's default line-scroll increment, in logical pixels.
      final forward = (key == LogicalKeyboardKey.arrowRight) != rtl;
      target = position.pixels + (forward ? 50 : -50);
    }
    // Immediate input response introduces no decorative animation owner.
    controller.jumpTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    onKeyEvent: _onKey,
    onFocusChange: (focused) => setState(() => _focused = focused),
    child: AnimalFocusRing(
      focused: _focused,
      borderRadius: widget.borderRadius,
      child: widget.builder(_controller),
    ),
  );
}
