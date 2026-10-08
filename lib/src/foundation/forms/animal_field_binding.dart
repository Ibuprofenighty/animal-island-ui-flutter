import 'package:flutter/widgets.dart';

import 'animal_field_key.dart';
import 'animal_validation_issue.dart';

/// Current validation lifecycle for one registered form field.
enum AnimalValidationStatus {
  /// Not validated since the last change, reset or rule update.
  idle,

  /// Validation has started and its result is not applied yet.
  validating,

  /// Every rule passed.
  valid,

  /// A rule failed; the binding's `error` describes it.
  invalid,
}

/// Immutable, typed view of a registered field and its owner operations.
///
/// `AnimalFormItem` hands the binding of its live registration to its
/// builder; there is no other way to obtain one.
@immutable
class AnimalFieldBinding<T> {
  /// Identity of the field this binding belongs to.
  final AnimalFieldKey<T> key;
  final T? _snapshotValue;
  final TextEditingController? _textController;

  /// Current validation issue, or null while the field is valid or unchecked.
  final AnimalValidationIssue? error;

  /// Validation lifecycle of the field.
  final AnimalValidationStatus status;

  /// Whether the value differs from the field's baseline.
  final bool dirty;

  /// Whether the field has lost focus at least once since its baseline.
  final bool touched;

  /// Proposes a new value for the field.
  final ValueChanged<T?> onChanged;

  /// Reports that the field lost focus.
  final VoidCallback onBlur;

  /// Focus node the field's control must use.
  final FocusNode focusNode;

  const AnimalFieldBinding._value({
    required this.key,
    required T? value,
    required this.error,
    required this.status,
    required this.dirty,
    required this.touched,
    required this.onChanged,
    required this.onBlur,
    required this.focusNode,
  }) : _snapshotValue = value,
       _textController = null;

  const AnimalFieldBinding._text({
    required this.key,
    required this._textController,
    required this.error,
    required this.status,
    required this.dirty,
    required this.touched,
    required this.onChanged,
    required this.onBlur,
    required this.focusNode,
  }) : _snapshotValue = null;

  /// Reads the registration's current value; text bindings read their buffer.
  T? get value {
    final TextEditingController? controller = _textController;
    if (controller == null) return _snapshotValue;
    return projectAnimalTextFieldValue(controller.text) as T?;
  }
}

/// Package-internal constructor for the live binding of a value field.
AnimalFieldBinding<T> createAnimalFieldBinding<T>({
  required AnimalFieldKey<T> key,
  required T? value,
  required AnimalValidationIssue? error,
  required AnimalValidationStatus status,
  required bool dirty,
  required bool touched,
  required ValueChanged<T?> onChanged,
  required VoidCallback onBlur,
  required FocusNode focusNode,
}) => AnimalFieldBinding<T>._value(
  key: key,
  value: value,
  error: error,
  status: status,
  dirty: dirty,
  touched: touched,
  onChanged: onChanged,
  onBlur: onBlur,
  focusNode: focusNode,
);

/// Package-internal constructor for the live binding of an explicit text field.
AnimalFieldBinding<String> createAnimalTextFieldBinding({
  required AnimalFieldKey<String> key,
  required TextEditingController textController,
  required AnimalValidationIssue? error,
  required AnimalValidationStatus status,
  required bool dirty,
  required bool touched,
  required ValueChanged<String?> onChanged,
  required VoidCallback onBlur,
  required FocusNode focusNode,
}) => AnimalFieldBinding<String>._text(
  key: key,
  textController: textController,
  error: error,
  status: status,
  dirty: dirty,
  touched: touched,
  onChanged: onChanged,
  onBlur: onBlur,
  focusNode: focusNode,
);

/// Canonical value projection for explicit text fields: empty text is null.
String? projectAnimalTextFieldValue(String text) => text.isEmpty ? null : text;
