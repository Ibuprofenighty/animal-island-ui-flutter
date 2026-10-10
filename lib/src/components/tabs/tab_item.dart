import 'package:flutter/widgets.dart';

/// Specification for each tab in [AnimalTabs].
final class AnimalTabItem {
  /// Stable nonempty identity preserved through reordering and label changes.
  final String id;

  /// Label string displayed on the tab.
  final String label;

  /// Optional leading or trailing icon widget.
  final Widget? icon;

  /// Whether this specific tab is disabled.
  final bool disabled;

  /// Creates a tab specification labeled [label].
  AnimalTabItem({
    required this.id,
    required this.label,
    this.icon,
    this.disabled = false,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must be nonempty');
  }
}
