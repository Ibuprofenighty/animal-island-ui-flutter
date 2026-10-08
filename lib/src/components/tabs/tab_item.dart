import 'package:flutter/widgets.dart';

/// Specification for each tab in [AnimalTabs].
class AnimalTabItem {
  /// Label string displayed on the tab.
  final String label;

  /// Optional leading or trailing icon widget.
  final Widget? icon;

  /// Whether this specific tab is disabled.
  final bool disabled;

  /// Creates a tab specification labeled [label].
  const AnimalTabItem({required this.label, this.icon, this.disabled = false});
}
