import 'package:flutter/widgets.dart';

/// Specification for each tab in [AnimalTabs].
class AnimalTabItem {
  /// Optional unique identifier for this tab item.
  final String? id;

  /// Label string displayed on the tab.
  final String label;

  /// Optional leading or trailing icon widget.
  final Widget? icon;

  /// Whether this specific tab is disabled.
  final bool disabled;

  const AnimalTabItem({
    this.id,
    required this.label,
    this.icon,
    this.disabled = false,
  });
}
