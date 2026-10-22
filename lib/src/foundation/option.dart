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
}
