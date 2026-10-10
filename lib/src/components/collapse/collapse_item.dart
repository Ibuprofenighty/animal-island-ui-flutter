import 'package:flutter/widgets.dart';

/// Specification for each item in [AnimalCollapse].
///
/// Addresses defect F27: supports stable [id] to preserve expansion states
/// across dynamic list reordering, insertion, and filtering.
final class AnimalCollapseItem {
  /// Nonempty stable identifier, unique within the collapse.
  final String id;

  /// Header title or question widget.
  final Widget title;

  /// Expandable body content or answer widget.
  final Widget content;

  /// Whether this specific item is disabled.
  final bool disabled;

  /// Optional trailing widget in the header (e.g. badge, tag, extra action).
  final Widget? extra;

  /// Creates an item; an empty ID throws ArgumentError in every build mode.
  AnimalCollapseItem({
    required this.id,
    required this.title,
    required this.content,
    this.disabled = false,
    this.extra,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must be nonempty');
  }
}
