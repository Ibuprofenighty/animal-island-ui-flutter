import 'package:flutter/widgets.dart';

import 'animal_field_key.dart';
import 'animal_validation_issue.dart';

/// Current validation lifecycle for one registered form field.
enum AnimalValidationStatus { idle, validating, valid, invalid }

/// Immutable, typed view of a registered field and its owner operations.
@immutable
class AnimalFieldBinding<T> {
  final AnimalFieldKey<T> key;
  final int generation;
  final T? _snapshotValue;
  final TextEditingController? _textController;
  final AnimalValidationIssue? error;
  final AnimalValidationStatus status;
  final bool dirty;
  final bool touched;
  final ValueChanged<T?> onChanged;
  final VoidCallback onBlur;
  final FocusNode focusNode;

  const AnimalFieldBinding({
    required this.key,
    required this.generation,
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
    required this.generation,
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

  bool get hasError => error != null;

  bool get isValidating => status == AnimalValidationStatus.validating;

  bool get isValid => status == AnimalValidationStatus.valid && error == null;
}

/// Package-internal constructor for the live binding of an explicit text field.
AnimalFieldBinding<String> createAnimalTextFieldBinding({
  required AnimalFieldKey<String> key,
  required int generation,
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
  generation: generation,
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
