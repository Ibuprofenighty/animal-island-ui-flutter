import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_validation_issue.dart';
import 'field_key.dart';
import 'validation.dart';

/// Result type returned by [AnimalFormController.submit].
@immutable
class AnimalSubmitResult {
  /// Outcome status of the submission.
  final AnimalSubmitStatus status;

  /// Error object if submission callback failed with an exception.
  final Object? error;

  const AnimalSubmitResult._(this.status, [this.error]);

  /// Form validated and submission callback completed successfully.
  static const AnimalSubmitResult success = AnimalSubmitResult._(
    AnimalSubmitStatus.success,
  );

  /// Validation failed on one or more fields.
  static const AnimalSubmitResult invalid = AnimalSubmitResult._(
    AnimalSubmitStatus.invalid,
  );

  /// Another submission is currently in-flight.
  static const AnimalSubmitResult busy = AnimalSubmitResult._(
    AnimalSubmitStatus.busy,
  );

  /// One or more form fields changed while submission validation was running.
  static const AnimalSubmitResult changedDuringValidation =
      AnimalSubmitResult._(AnimalSubmitStatus.changedDuringValidation);

  /// The submission callback threw an unhandled exception.
  factory AnimalSubmitResult.error(Object error) =>
      AnimalSubmitResult._(AnimalSubmitStatus.error, error);

  /// Whether the submission was successful.
  bool get isSuccess => status == AnimalSubmitStatus.success;

  @override
  String toString() =>
      'AnimalSubmitResult($status${error != null ? ', error: $error' : ''})';
}

/// Status enum for [AnimalSubmitResult].
enum AnimalSubmitStatus {
  success,
  invalid,
  busy,
  changedDuringValidation,
  error,
}

/// Internal mutable record holding field metadata, latest values, and revision counters.
class _FieldRecord extends ChangeNotifier {
  final String name;
  dynamic value;
  dynamic initialBaseline;
  int valueRevision = 0;
  int validationRequestId = 0;
  bool dirty = false;
  bool touched = false;
  AnimalValidationStatus status = AnimalValidationStatus.idle;
  AnimalValidationIssue? error;
  List<AnimalRule<dynamic>> rules;
  FocusNode? focusNode;

  _FieldRecord({
    required this.name,
    this.value,
    this.initialBaseline,
    this.rules = const [],
    this.focusNode,
  });

  void notifyBinding() {
    notifyListeners();
  }
}

/// State-machine driven, type-safe form controller (C19).
///
/// Features:
/// - **Defect F06 Resolved**: Monotonic `valueRevision`, `epoch`, and `validationRequestId`
///   prevent stale, delayed asynchronous validation results from overwriting newer user inputs (latest-wins).
/// - **Atomic Concurrency Protection**: Rejects overlapping concurrent submissions with [AnimalSubmitResult.busy],
///   and aborts submissions if fields are modified during async validation ([AnimalSubmitResult.changedDuringValidation]).
/// - **Fine-Grained Reactivity**: Field updates only trigger localized rebuilding of the affected [AnimalFormItem].
/// - **Initial Baseline Protection**: Rebuilding widgets never overwrites or re-seeds the initial baseline.
/// - **Accessible Focus Navigation**: Automatically shifts keyboard focus to the first invalid field upon validation failure.
class AnimalFormController extends ChangeNotifier {
  final Map<String, _FieldRecord> _fields = {};
  int _epoch = 0;
  bool _isSubmitting = false;
  bool _isDisposed = false;

  /// Optional default submission handler registered by [AnimalForm].
  FutureOr<void> Function(Map<String, dynamic> values)? defaultSubmitHandler;

  /// Current代数 (epoch) of this form controller, incremented on reset/clear.
  int get epoch => _epoch;

  /// Whether a form submission is currently in-flight.
  bool get isSubmitting => _isSubmitting;

  /// Whether this controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// Map snapshot of all current form values keyed by field name.
  Map<String, dynamic> get values {
    return {for (final entry in _fields.entries) entry.key: entry.value.value};
  }

  /// Whether any field in the form has been modified from its initial baseline.
  bool get isDirty => _fields.values.any((f) => f.dirty);

  /// Whether all fields that have executed validation are currently valid.
  bool get isValid => _fields.values.every((f) => f.error == null);

  /// Retrieves the current typed value of a field via its [AnimalFieldKey] or string field name.
  T? getFieldValue<T>(dynamic keyOrName) {
    final String name = keyOrName is AnimalFieldKey
        ? keyOrName.name
        : keyOrName.toString();
    return getValue<T>(name);
  }

  /// Retrieves the current value of a field by name.
  T? getValue<T>(String name) {
    final record = _fields[name];
    if (record == null) return null;
    return record.value as T?;
  }

  /// Retrieves the current locale-neutral validation issue for a field.
  AnimalValidationIssue? getFieldError(String name) => _fields[name]?.error;

  /// Retrieves the current validation status for a field.
  AnimalValidationStatus getFieldStatus(String name) =>
      _fields[name]?.status ?? AnimalValidationStatus.idle;

  /// Registers a field with the controller.
  ///
  /// Defends against duplicate key registration within the same form (FI01).
  void registerField<T>({
    required String name,
    T? initialValue,
    List<AnimalRule<T>>? rules,
    FocusNode? focusNode,
  }) {
    if (_isDisposed) return;
    if (_fields.containsKey(name)) {
      final existing = _fields[name]!;
      // Update rules and focusNode if re-mounted with same identity
      existing.rules = (rules ?? const []).cast<AnimalRule<dynamic>>();
      existing.focusNode = focusNode ?? existing.focusNode;
      return;
    }

    final record = _FieldRecord(
      name: name,
      value: initialValue,
      initialBaseline: initialValue,
      rules: (rules ?? const []).cast<AnimalRule<dynamic>>(),
      focusNode: focusNode,
    );
    _fields[name] = record;
  }

  /// Unregisters a field from the controller.
  void unregisterField(String name) {
    if (_isDisposed) return;
    final removed = _fields.remove(name);
    removed?.dispose();
  }

  /// Returns the internal listenable field record for fine-grained binding in [AnimalFormItem].
  Listenable? getFieldListenable(String name) => _fields[name];

  /// Updates a field value using an [AnimalFieldKey] or string field name.
  void setFieldValue<T>(dynamic keyOrName, T? value, {bool validate = true}) {
    final String name = keyOrName is AnimalFieldKey
        ? keyOrName.name
        : keyOrName.toString();
    setValue<T>(name, value, validate: validate);
  }

  /// Updates a field value by name.
  ///
  /// Increments the field's monotonic [valueRevision] and validates asynchronously if requested.
  void setValue<T>(String name, T? value, {bool validate = true}) {
    if (_isDisposed) return;
    final record = _fields[name];
    if (record == null) return;

    if (record.value == value && record.dirty) {
      return;
    }

    record.value = value;
    record.dirty = true;
    record.valueRevision++;

    record.notifyBinding();

    if (validate) {
      validateField(name);
    } else {
      notifyListeners();
    }
  }

  /// Marks a field as touched (e.g. on blur).
  void touchField(String name, {bool validate = true}) {
    if (_isDisposed) return;
    final record = _fields[name];
    if (record == null) return;

    if (!record.touched) {
      record.touched = true;
      record.notifyBinding();
    }

    if (validate) {
      validateField(name);
    }
  }

  /// Asynchronously validates a single field using the latest-wins concurrency algorithm (F06).
  Future<bool> validateField(String name) async {
    if (_isDisposed) return false;
    final record = _fields[name];
    if (record == null) return true;

    final capturedEpoch = _epoch;
    final capturedRevision = record.valueRevision;
    final capturedReqId = ++record.validationRequestId;
    final capturedValue = record.value;

    record.status = AnimalValidationStatus.validating;
    record.notifyBinding();

    AnimalValidationIssue? foundError;
    for (final rule in record.rules) {
      final res = await rule.evaluate(capturedValue);
      if (res != null) {
        foundError = res;
        break;
      }
    }

    // Latest-wins check (F06): If the value changed, reset occurred, or field was unregistered,
    // discard this result silently.
    if (_isDisposed ||
        !_fields.containsKey(name) ||
        _epoch != capturedEpoch ||
        record.valueRevision != capturedRevision ||
        record.validationRequestId != capturedReqId) {
      return record.error == null;
    }

    record.error = foundError;
    record.status = foundError != null
        ? AnimalValidationStatus.invalid
        : AnimalValidationStatus.valid;

    record.notifyBinding();
    notifyListeners();

    return foundError == null;
  }

  /// Validates all registered fields (or a subset specified by [fieldNames]).
  ///
  /// If [autoFocus] is true (default), shifts keyboard focus to the first invalid field.
  Future<bool> validate([
    List<String>? fieldNames,
    bool autoFocus = true,
  ]) async {
    if (_isDisposed) return false;
    final targetNames = fieldNames ?? _fields.keys.toList();
    final results = await Future.wait(
      targetNames.map((name) => validateField(name)),
    );
    final allValid = results.every((r) => r);
    if (!allValid && autoFocus) {
      focusFirstError();
    }
    return allValid;
  }

  /// Submits the form with comprehensive concurrency locks and snapshot validation.
  Future<AnimalSubmitResult> submit({
    FutureOr<void> Function(Map<String, dynamic> values)? onSubmit,
  }) async {
    if (_isDisposed) return AnimalSubmitResult.invalid;
    if (_isSubmitting) return AnimalSubmitResult.busy;

    _isSubmitting = true;
    notifyListeners();

    try {
      final initialRevisions = {
        for (final entry in _fields.entries)
          entry.key: entry.value.valueRevision,
      };
      final initialSnapshot = Map<String, dynamic>.from(values);

      final isValid = await validate();

      // Check if values were modified during asynchronous validation
      for (final entry in initialRevisions.entries) {
        if (_fields[entry.key]?.valueRevision != entry.value) {
          _isSubmitting = false;
          notifyListeners();
          return AnimalSubmitResult.changedDuringValidation;
        }
      }

      if (!isValid) {
        _isSubmitting = false;
        focusFirstError();
        notifyListeners();
        return AnimalSubmitResult.invalid;
      }

      final handler = onSubmit ?? defaultSubmitHandler;
      if (handler != null) {
        await handler(initialSnapshot);
      }

      // Verify no changes happened during the async onSubmit callback
      if (!_isDisposed) {
        for (final entry in initialRevisions.entries) {
          if (_fields[entry.key]?.valueRevision != entry.value) {
            _isSubmitting = false;
            notifyListeners();
            return AnimalSubmitResult.changedDuringValidation;
          }
        }
      }

      _isSubmitting = false;
      notifyListeners();
      return AnimalSubmitResult.success;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return AnimalSubmitResult.error(e);
    }
  }

  /// Focuses the first field in visual registration order that failed validation.
  bool focusFirstError() {
    for (final record in _fields.values) {
      if (record.status == AnimalValidationStatus.invalid &&
          record.focusNode != null) {
        record.focusNode!.requestFocus();
        return true;
      }
    }
    return false;
  }

  /// Resets all fields to their frozen initial baseline snapshot (FOR02).
  ///
  /// Increments the global [epoch], instantly invalidating all pending asynchronous validations.
  void reset() {
    if (_isDisposed) return;
    _epoch++;

    for (final record in _fields.values) {
      record.value = record.initialBaseline;
      record.dirty = false;
      record.touched = false;
      record.status = AnimalValidationStatus.idle;
      record.error = null;
      record.valueRevision++;
      record.validationRequestId++;
      record.notifyBinding();
    }

    notifyListeners();
  }

  /// Clears all field values to null/empty without altering the initial baseline snapshot (FOR02).
  ///
  /// Increments the global [epoch], instantly invalidating all pending asynchronous validations.
  void clear() {
    if (_isDisposed) return;
    _epoch++;

    for (final record in _fields.values) {
      record.value = null;
      record.dirty = true;
      record.status = AnimalValidationStatus.idle;
      record.error = null;
      record.valueRevision++;
      record.validationRequestId++;
      record.notifyBinding();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final record in _fields.values) {
      record.dispose();
    }
    _fields.clear();
    super.dispose();
  }
}
