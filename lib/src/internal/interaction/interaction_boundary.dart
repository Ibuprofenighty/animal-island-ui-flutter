import 'package:flutter/widgets.dart';

/// Observes descendant focus and pointer presence without adding a Tab stop
/// or a semantic action. Leaves still activate through InteractiveRegion.
class InteractionBoundary extends StatelessWidget {
  /// Content with independent actionable leaves.
  final Widget child;

  /// Receives whether any descendant has focus.
  final ValueChanged<bool>? onFocusChanged;

  /// Receives pointer presence within the complete region.
  final ValueChanged<bool>? onHoverChanged;

  /// Creates an observation boundary.
  const InteractionBoundary({
    super.key,
    required this.child,
    this.onFocusChanged,
    this.onHoverChanged,
  });
  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onFocusChange: onFocusChanged,
    child: MouseRegion(
      onEnter: (_) => onHoverChanged?.call(true),
      onExit: (_) => onHoverChanged?.call(false),
      child: child,
    ),
  );
}
