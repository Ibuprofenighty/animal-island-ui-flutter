import 'package:flutter/foundation.dart';

/// Stable value identity; labels are presentation and may change or repeat.
@immutable
class IslandOption<T> {
  const IslandOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });
  final T value;
  final String label;
  final bool disabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IslandOption<T> &&
          value == other.value &&
          label == other.label &&
          disabled == other.disabled;

  @override
  int get hashCode => Object.hash(value, label, disabled);
}
