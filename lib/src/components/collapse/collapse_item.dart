import 'package:flutter/widgets.dart';

/// Specification for each item in [AnimalCollapse].
///
/// Addresses defect F27: supports stable [id] to preserve expansion states
/// across dynamic list reordering, insertion, and filtering.
class AnimalCollapseItem {
  /// Unique identifier for this collapse item.
  ///
  /// If omitted or empty, [AnimalCollapse] will derive a deterministic fallback
  /// from the item's index.
  final String id;

  /// Header title or question widget.
  final Widget title;

  /// Expandable body content or answer widget.
  final Widget content;

  /// Whether this specific item is disabled.
  final bool disabled;

  /// Optional trailing widget in the header (e.g. badge, tag, extra action).
  final Widget? extra;

  /// Creates an item; a null [id] is stored as the empty string.
  const AnimalCollapseItem({
    String? id,
    required this.title,
    required this.content,
    this.disabled = false,
    this.extra,
  }) : id = id ?? '';
}
