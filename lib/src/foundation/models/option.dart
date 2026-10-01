import 'package:flutter/widgets.dart';

/// An immutable, generic option descriptor used across Animal Island UI controls
/// (such as Select, CheckboxGroup, and RadioGroup).
@immutable
class AnimalOption<T> {
  /// The underlying value represented by this option.
  final T value;

  /// The human-readable label displayed in menus, badges, or item rows.
  final String label;

  /// Whether this option is disabled and non-selectable.
  final bool disabled;

  /// Optional accessibility label announced by screen readers.
  final String? semanticLabel;

  /// Optional icon widget displayed alongside the label.
  final Widget? icon;

  /// Creates an immutable [AnimalOption].
  const AnimalOption({
    required this.value,
    required this.label,
    this.disabled = false,
    this.semanticLabel,
    this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalOption<T> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          label == other.label &&
          disabled == other.disabled &&
          semanticLabel == other.semanticLabel &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(value, label, disabled, semanticLabel, icon);

  @override
  String toString() =>
      'AnimalOption(value: $value, label: $label, disabled: $disabled)';
}
