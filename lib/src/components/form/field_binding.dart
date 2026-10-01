import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_validation_issue.dart';
import 'validation.dart';

/// Typed, fine-grained reactive binding contract passed to field widget builders.
///
/// Ensures only the specific [AnimalFormItem] whose field state changed is rebuilt,
/// preventing full-form layout invalidation (satisfies FOR05).
@immutable
class AnimalFieldBinding<T> {
  /// The field's unique name identifier.
  final String name;

  /// Current strongly typed value of the field.
  final T? value;

  /// The current locale-neutral validation issue, or null if valid/unvalidated.
  final AnimalValidationIssue? error;

  /// Current validation lifecycle status of the field.
  final AnimalValidationStatus status;

  /// Whether the field has been modified from its initial baseline.
  final bool dirty;

  /// Whether the field has received and lost focus (blur).
  final bool touched;

  /// Callback to update the field value.
  final ValueChanged<T?> onChanged;

  /// Callback to notify the form controller that the field was blurred.
  final VoidCallback onBlur;

  /// Focus node assigned to this field for keyboard navigation and focus-first-error.
  final FocusNode focusNode;

  const AnimalFieldBinding({
    required this.name,
    required this.value,
    required this.error,
    required this.status,
    required this.dirty,
    required this.touched,
    required this.onChanged,
    required this.onBlur,
    required this.focusNode,
  });

  /// Whether the field currently has a validation error.
  bool get hasError => error != null;

  /// Whether asynchronous validation is actively running for this field.
  bool get isValidating => status == AnimalValidationStatus.validating;

  /// Whether the field is validated and error-free.
  bool get isValid => status == AnimalValidationStatus.valid && error == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalFieldBinding<T> &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value &&
          error == other.error &&
          status == other.status &&
          dirty == other.dirty &&
          touched == other.touched &&
          focusNode == other.focusNode;

  @override
  int get hashCode =>
      Object.hash(name, value, error, status, dirty, touched, focusNode);
}
