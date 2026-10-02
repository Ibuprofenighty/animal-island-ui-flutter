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
  final T? value;
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
    required this.value,
    required this.error,
    required this.status,
    required this.dirty,
    required this.touched,
    required this.onChanged,
    required this.onBlur,
    required this.focusNode,
  });

  bool get hasError => error != null;

  bool get isValidating => status == AnimalValidationStatus.validating;

  bool get isValid => status == AnimalValidationStatus.valid && error == null;
}
