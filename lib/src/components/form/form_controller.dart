import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_field_binding.dart';
import '../../foundation/forms/animal_field_key.dart';
import '../../foundation/forms/animal_form_values.dart';
import '../../foundation/forms/animal_validation_issue.dart';
import 'validation.dart';

/// Result type returned by [AnimalFormController.submit].
@immutable
class AnimalSubmitResult {
  final AnimalSubmitStatus status;
  final Object? error;

  const AnimalSubmitResult._(this.status, [this.error]);

  static const AnimalSubmitResult success = AnimalSubmitResult._(
    AnimalSubmitStatus.success,
  );
  static const AnimalSubmitResult invalid = AnimalSubmitResult._(
    AnimalSubmitStatus.invalid,
  );
  static const AnimalSubmitResult busy = AnimalSubmitResult._(
    AnimalSubmitStatus.busy,
  );
  static const AnimalSubmitResult changedDuringValidation =
      AnimalSubmitResult._(AnimalSubmitStatus.changedDuringValidation);

  factory AnimalSubmitResult.error(Object error) =>
      AnimalSubmitResult._(AnimalSubmitStatus.error, error);

  bool get isSuccess => status == AnimalSubmitStatus.success;

  @override
  String toString() =>
      'AnimalSubmitResult($status${error == null ? '' : ', error: $error'})';
}

/// Outcome of validating and submitting a form.
enum AnimalSubmitStatus {
  success,
  invalid,
  busy,
  changedDuringValidation,
  error,
}

/// Unique capability for one registration of a field with one controller.
///
/// The generation advances on every registration, including registrations that
/// reuse an earlier key after it has been unregistered. The token also listens
/// only to its own field record.
class AnimalFieldRegistration<T> implements Listenable {
  final AnimalFieldKey<T> key;
  final int generation;
  final AnimalFormController _owner;
  final _FieldRecord _record;

  AnimalFieldRegistration._(
    this._owner,
    this.key,
    this.generation,
    this._record,
  );

  @override
  void addListener(VoidCallback listener) {
    _owner._assertCurrentRegistration(this);
    _record.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _record.removeListener(listener);
  }

  /// Marks this token's field inactive while its owning element is deactivated.
  /// The controller retains the value and baseline in case the same State is
  /// reinserted with a GlobalKey later in the frame.
  void deactivate() => _owner._deactivateRegistration<T>(this);

  /// Reactivates this exact token after the same State is reinserted.
  /// Returns false if a different registration has already replaced it.
  bool activate() => _owner._activateRegistration<T>(this);
}

class _FieldRecord extends ChangeNotifier {
  final AnimalFieldKey<dynamic> key;
  final int generation;
  Object? value;
  Object? baseline;
  int valueRevision = 0;
  int validationRequestId = 0;
  bool registrationActive = true;
  bool dirty = false;
  bool touched = false;
  AnimalValidationStatus status = AnimalValidationStatus.idle;
  AnimalValidationIssue? error;
  List<AnimalRule<dynamic>> rules;
  FocusNode? focusNode;

  _FieldRecord({
    required this.key,
    required this.generation,
    required this.value,
    required this.baseline,
    required this.rules,
    required this.focusNode,
  });
}

/// The sole owner of registered field values, validation state and submission.
class AnimalFormController extends ChangeNotifier {
  final Map<AnimalFieldKey<dynamic>, _FieldRecord> _fields = {};
  int _epoch = 0;
  int _nextGeneration = 0;
  bool _isSubmitting = false;
  bool _isDisposed = false;

  /// Optional submission handler supplied by the surrounding [AnimalForm].
  FutureOr<void> Function(AnimalFormValues values)? defaultSubmitHandler;

  int get epoch => _epoch;
  bool get isSubmitting => _isSubmitting;
  bool get isDisposed => _isDisposed;

  /// Immutable snapshot with typed reads through each field's identity.
  AnimalFormValues get values => AnimalFormValues.fromEntries(
    _fields.values.map(
      (record) => AnimalFieldValue<dynamic>(record.key, record.value),
    ),
  );

  bool get isDirty => _fields.values.any((record) => record.dirty);

  bool get isValid => _fields.values.every((record) => record.error == null);

  /// Returns the current value for [key], or null when it is not registered.
  T? valueFor<T>(AnimalFieldKey<T> key) {
    key.requireRequestedType(T);
    final record = _recordForKey(key, required: false);
    return record?.value as T?;
  }

  AnimalValidationIssue? getFieldError<T>(AnimalFieldKey<T> key) =>
      _recordForKey(key, required: false)?.error;

  AnimalValidationStatus getFieldStatus<T>(AnimalFieldKey<T> key) =>
      _recordForKey(key, required: false)?.status ??
      AnimalValidationStatus.idle;

  /// Registers one field and returns the unique token for this occurrence.
  AnimalFieldRegistration<T> registerField<T>({
    required AnimalFieldKey<T> key,
    T? initialValue,
    List<AnimalRule<T>>? rules,
    FocusNode? focusNode,
  }) {
    _throwIfDisposed('register a field');

    final existing = _fields[key];
    if (existing != null) {
      if (existing.key.runtimeType != key.runtimeType) {
        throw StateError(
          'A registered field identity was reused with a different value type.',
        );
      }
      if (existing.registrationActive) {
        throw StateError('The field identity is already registered.');
      }
    }

    _assertValueType<T>(key, initialValue);
    final frozenInitialValue = key.snapshotValue(initialValue);
    final generation = ++_nextGeneration;
    final record = _FieldRecord(
      key: key,
      generation: generation,
      value: frozenInitialValue,
      baseline: frozenInitialValue,
      rules: _freezeRules(rules),
      focusNode: focusNode,
    );
    final registration = AnimalFieldRegistration<T>._(
      this,
      key,
      generation,
      record,
    );
    _fields[key] = record;
    existing?.dispose();
    return registration;
  }

  void _deactivateRegistration<T>(AnimalFieldRegistration<T> registration) {
    if (_isDisposed) return;
    registration.key.requireRequestedType(T);
    final current = _fields[registration.key];
    if (identical(current, registration._record) &&
        current?.generation == registration.generation) {
      current!.registrationActive = false;
    }
  }

  bool _activateRegistration<T>(AnimalFieldRegistration<T> registration) {
    if (_isDisposed) return false;
    registration.key.requireRequestedType(T);
    final current = _fields[registration.key];
    if (!identical(current, registration._record) ||
        current?.generation != registration.generation) {
      return false;
    }
    current!.registrationActive = true;
    return true;
  }

  /// Removes only the record created by [registration].
  ///
  /// A stale token is harmless after a later registration reused its key.
  void unregisterField<T>(AnimalFieldRegistration<T> registration) {
    if (_isDisposed) return;
    registration.key.requireRequestedType(T);
    if (!identical(registration._owner, this)) {
      throw StateError('The field registration belongs to another controller.');
    }
    final current = _fields[registration.key];
    if (!identical(current, registration._record) ||
        current?.generation != registration.generation) {
      return;
    }
    _fields.remove(registration.key);
    current!.dispose();
    notifyListeners();
  }

  /// Updates rules and borrowed focus for the same registration.
  ///
  /// Updating configuration never changes the field's value or baseline.
  void updateFieldRegistration<T>(
    AnimalFieldRegistration<T> registration, {
    required List<AnimalRule<T>> rules,
    required FocusNode focusNode,
  }) {
    final record = _recordForRegistration(registration);
    record.rules = _freezeRules(rules);
    record.focusNode = focusNode;
  }

  /// Updates a registered value through its typed identity.
  void setValue<T>(AnimalFieldKey<T> key, T? value, {bool validate = true}) {
    final record = _recordForKey(key)!;
    _setRecordValue(record, key, value, validate: validate);
  }

  /// Updates a value through its registration, preserving generation ownership.
  void setRegistrationValue<T>(
    AnimalFieldRegistration<T> registration,
    T? value, {
    bool validate = true,
  }) {
    final record = _recordForRegistration(registration);
    _setRecordValue(record, registration.key, value, validate: validate);
  }

  void _setRecordValue<T>(
    _FieldRecord record,
    AnimalFieldKey<T> key,
    T? value, {
    required bool validate,
  }) {
    _assertValueType<T>(key, value);
    final frozenValue = key.snapshotValue(value);
    if (_formValuesEqual(record.value, frozenValue)) return;

    record.value = frozenValue;
    record.dirty = !_formValuesEqual(frozenValue, record.baseline);
    record.valueRevision++;
    record.notifyListeners();

    if (validate) {
      unawaited(_validateRecord(record));
    } else {
      notifyListeners();
    }
  }

  /// Marks [key] as touched, normally after its field loses focus.
  void touchField<T>(AnimalFieldKey<T> key, {bool validate = true}) {
    final record = _recordForKey(key)!;
    _touchRecord(record, validate: validate);
  }

  /// Marks one specific registration as touched.
  void touchRegistration<T>(
    AnimalFieldRegistration<T> registration, {
    bool validate = true,
  }) {
    final record = _recordForRegistration(registration);
    _touchRecord(record, validate: validate);
  }

  void _touchRecord(_FieldRecord record, {required bool validate}) {
    if (!record.touched) {
      record.touched = true;
      record.notifyListeners();
      notifyListeners();
    }
    if (validate) unawaited(_validateRecord(record));
  }

  /// Creates the immutable binding snapshot for one live registration.
  AnimalFieldBinding<T> bindingFor<T>(AnimalFieldRegistration<T> registration) {
    final record = _recordForRegistration(registration);
    final focusNode = record.focusNode;
    if (focusNode == null) {
      throw StateError('A bound field requires a focus node.');
    }
    return AnimalFieldBinding<T>(
      key: registration.key,
      generation: registration.generation,
      value: record.value as T?,
      error: record.error,
      status: record.status,
      dirty: record.dirty,
      touched: record.touched,
      onChanged: (value) => setRegistrationValue<T>(registration, value),
      onBlur: () => touchRegistration<T>(registration),
      focusNode: focusNode,
    );
  }

  /// Asynchronously validates one typed field using the latest-wins behavior.
  Future<bool> validateField<T>(AnimalFieldKey<T> key) async {
    if (_isDisposed) return false;
    final record = _recordForKey(key, required: false);
    if (record == null) return true;
    return _validateRecord(record);
  }

  /// Validates all registered fields or the supplied typed subset.
  Future<bool> validate([
    Iterable<AnimalFieldKey<dynamic>>? fieldKeys,
    bool autoFocus = true,
  ]) async {
    if (_isDisposed) return false;
    final records = fieldKeys == null
        ? _fields.values.toList(growable: false)
        : fieldKeys
              .map((key) => _recordForErasedKey(key, required: false))
              .whereType<_FieldRecord>()
              .toList(growable: false);
    final results = await Future.wait(records.map(_validateRecord));
    final allValid = results.every((result) => result);
    if (!allValid && autoFocus) focusFirstError();
    return allValid;
  }

  Future<bool> _validateRecord(_FieldRecord record) async {
    if (_isDisposed) return false;
    final capturedEpoch = _epoch;
    final capturedRevision = record.valueRevision;
    final capturedRequestId = ++record.validationRequestId;
    final capturedValue = record.value;

    record.status = AnimalValidationStatus.validating;
    record.notifyListeners();

    AnimalValidationIssue? foundError;
    for (final rule in record.rules) {
      final result = await rule.evaluate(capturedValue);
      if (result != null) {
        foundError = result;
        break;
      }
    }

    if (_isDisposed ||
        !identical(_fields[record.key], record) ||
        _epoch != capturedEpoch ||
        record.valueRevision != capturedRevision ||
        record.validationRequestId != capturedRequestId) {
      return record.error == null;
    }

    record.error = foundError;
    record.status = foundError == null
        ? AnimalValidationStatus.valid
        : AnimalValidationStatus.invalid;
    record.notifyListeners();
    notifyListeners();
    return foundError == null;
  }

  /// Submits one immutable value snapshot after validation succeeds.
  Future<AnimalSubmitResult> submit({
    FutureOr<void> Function(AnimalFormValues values)? onSubmit,
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
      final initialSnapshot = values;
      final allValid = await validate();

      for (final entry in initialRevisions.entries) {
        if (_fields[entry.key]?.valueRevision != entry.value) {
          _isSubmitting = false;
          notifyListeners();
          return AnimalSubmitResult.changedDuringValidation;
        }
      }

      if (!allValid) {
        _isSubmitting = false;
        focusFirstError();
        notifyListeners();
        return AnimalSubmitResult.invalid;
      }

      final handler = onSubmit ?? defaultSubmitHandler;
      if (handler != null) await handler(initialSnapshot);

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
    } catch (error) {
      _isSubmitting = false;
      notifyListeners();
      return AnimalSubmitResult.error(error);
    }
  }

  /// Focuses the first invalid field in registration order.
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

  /// Restores each registration's frozen initial value and pristine state.
  void reset() {
    if (_isDisposed) return;
    _epoch++;
    for (final record in _fields.values) {
      record.value = record.baseline;
      record.dirty = false;
      record.touched = false;
      record.status = AnimalValidationStatus.idle;
      record.error = null;
      record.valueRevision++;
      record.validationRequestId++;
      record.notifyListeners();
    }
    notifyListeners();
  }

  /// Sets every registered value to null while retaining its original baseline.
  void clear() {
    if (_isDisposed) return;
    _epoch++;
    for (final record in _fields.values) {
      record.value = null;
      record.dirty = !_formValuesEqual(null, record.baseline);
      record.status = AnimalValidationStatus.idle;
      record.error = null;
      record.valueRevision++;
      record.validationRequestId++;
      record.notifyListeners();
    }
    notifyListeners();
  }

  _FieldRecord? _recordForKey<T>(
    AnimalFieldKey<T> key, {
    bool required = true,
  }) {
    key.requireRequestedType(T);
    if (_isDisposed && required) _throwIfDisposed('access a field');
    final record = _fields[key];
    if (record == null) {
      if (required) throw StateError('The field is not registered.');
      return null;
    }
    if (record.key.runtimeType != key.runtimeType) {
      throw StateError(
        'A registered field identity was accessed with a different value type.',
      );
    }
    return record;
  }

  _FieldRecord? _recordForErasedKey(
    AnimalFieldKey<dynamic> key, {
    bool required = true,
  }) {
    if (_isDisposed && required) _throwIfDisposed('access a field');
    final record = _fields[key];
    if (record == null) {
      if (required) throw StateError('The field is not registered.');
      return null;
    }
    if (record.key.valueType != key.valueType) {
      throw StateError(
        'A registered field identity was accessed with a different value type.',
      );
    }
    return record;
  }

  _FieldRecord _recordForRegistration<T>(
    AnimalFieldRegistration<T> registration,
  ) {
    _throwIfDisposed('use a field registration');
    registration.key.requireRequestedType(T);
    if (!identical(registration._owner, this)) {
      throw StateError('The field registration belongs to another controller.');
    }
    final current = _fields[registration.key];
    if (!identical(current, registration._record) ||
        current?.generation != registration.generation) {
      throw StateError('The field registration is no longer active.');
    }
    if (!current!.registrationActive) {
      throw StateError('The field registration is inactive.');
    }
    if (current.key.runtimeType != registration.key.runtimeType) {
      throw StateError('The field registration has an invalid value type.');
    }
    return current;
  }

  void _assertCurrentRegistration<T>(AnimalFieldRegistration<T> registration) {
    _recordForRegistration(registration);
  }

  void _assertValueType<T>(AnimalFieldKey<T> key, Object? value) {
    key.requireRequestedType(T);
    key.requireValueType(value);
  }

  List<AnimalRule<dynamic>> _freezeRules<T>(List<AnimalRule<T>>? rules) =>
      List<AnimalRule<dynamic>>.unmodifiable(
        (rules ?? <AnimalRule<T>>[]).cast<AnimalRule<dynamic>>(),
      );

  bool _formValuesEqual(Object? left, Object? right) {
    if (identical(left, right)) return true;
    if (left is List && right is List) {
      if (left.length != right.length) return false;
      for (var index = 0; index < left.length; index++) {
        if (!_formValuesEqual(left[index], right[index])) return false;
      }
      return true;
    }
    if (left is Set && right is Set) {
      if (left.length != right.length) return false;
      return left.every(right.contains);
    }
    if (left is Map && right is Map) {
      if (left.length != right.length) return false;
      for (final entry in left.entries) {
        if (!right.containsKey(entry.key) ||
            !_formValuesEqual(entry.value, right[entry.key])) {
          return false;
        }
      }
      return true;
    }
    return left == right;
  }

  void _throwIfDisposed(String operation) {
    if (_isDisposed) {
      throw StateError(
        'Cannot $operation after the form controller is disposed.',
      );
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    for (final record in _fields.values) {
      record.dispose();
    }
    _fields.clear();
    super.dispose();
  }
}
