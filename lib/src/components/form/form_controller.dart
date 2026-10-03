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

  /// The submit handler returned false to reject this snapshot.
  static const AnimalSubmitResult rejected = AnimalSubmitResult._(
    AnimalSubmitStatus.rejected,
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
  rejected,
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

abstract class _FieldRecord extends ChangeNotifier {
  final AnimalFieldKey<dynamic> key;
  final int generation;
  Object? baseline;
  int valueRevision = 0;
  int validationRequestId = 0;
  bool registrationActive = true;
  bool dirty = false;
  bool touched = false;
  AnimalValidationStatus status = AnimalValidationStatus.idle;
  AnimalValidationIssue? error;
  int rulesRevision = 0;
  List<AnimalRule<dynamic>> rules;
  FocusNode? focusNode;

  _FieldRecord({
    required this.key,
    required this.generation,
    required this.baseline,
    required this.rules,
    required this.focusNode,
  });

  Object? get value;

  set value(Object? value);

  void setFormValue(Object? value, {required bool validate}) {
    this.value = value;
  }
}

class _ScalarFieldRecord extends _FieldRecord {
  Object? _value;

  _ScalarFieldRecord({
    required super.key,
    required super.generation,
    required this._value,
    required super.baseline,
    required super.rules,
    required super.focusNode,
  });

  @override
  Object? get value => _value;

  @override
  set value(Object? value) => _value = value;
}

class _TextWritePolicy {
  final String targetText;
  final bool validate;

  const _TextWritePolicy({required this.targetText, required this.validate});
}

class _PendingTextChange {
  final String? previousValue;
  bool validate;

  _PendingTextChange({required this.previousValue, required this.validate});
}

class _TextFieldRecord extends _FieldRecord {
  final TextEditingController controller;
  final void Function(
    _TextFieldRecord record,
    String? previousText,
    bool validate,
    bool allowInactive,
  )
  onTextChanged;
  late final VoidCallback _controllerListener = _handleControllerChange;
  // This is only event history for detecting text edits. Current text always
  // comes from controller.text through the record and its typed binding.
  TextEditingValue _previousObservedEditingValue;
  final List<_TextWritePolicy> _formWritePolicies = <_TextWritePolicy>[];
  bool _listening = true;

  _TextFieldRecord({
    required super.key,
    required super.generation,
    required super.baseline,
    required super.rules,
    required super.focusNode,
    required this.controller,
    required this.onTextChanged,
  }) : _previousObservedEditingValue = controller.value {
    controller.addListener(_controllerListener);
  }

  @override
  Object? get value => projectAnimalTextFieldValue(controller.text);

  @override
  set value(Object? value) => setFormValue(value, validate: true);

  @override
  void setFormValue(Object? value, {required bool validate}) {
    if (value != null && value is! String) {
      throw ArgumentError.value(value, 'value', 'Text fields require String.');
    }
    final String nextText = value as String? ?? '';
    if (controller.text == nextText) return;

    final String? previousText = projectAnimalTextFieldValue(controller.text);
    final _TextWritePolicy policy = _TextWritePolicy(
      targetText: nextText,
      validate: validate,
    );
    _formWritePolicies.add(policy);
    try {
      controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
        composing: TextRange.empty,
      );
    } finally {
      _formWritePolicies.remove(policy);
    }
    if (!_listening) {
      final TextEditingValue current = controller.value;
      _previousObservedEditingValue = current;
      final String? currentText = projectAnimalTextFieldValue(current.text);
      if (previousText != currentText) {
        onTextChanged(
          this,
          previousText,
          current.text == nextText ? validate : true,
          true,
        );
      }
    }
  }

  void deactivateListener() {
    if (!_listening) return;
    controller.removeListener(_controllerListener);
    _listening = false;
  }

  void activateListener() {
    if (_listening) return;
    _listening = true;
    controller.addListener(_controllerListener);
    _handleControllerChange(validateOverride: false);
  }

  void _handleControllerChange({bool? validateOverride}) {
    final TextEditingValue previous = _previousObservedEditingValue;
    final TextEditingValue current = controller.value;
    _previousObservedEditingValue = current;
    if (!registrationActive || previous.text == current.text) return;
    bool shouldValidate = true;
    if (_formWritePolicies.isNotEmpty) {
      final _TextWritePolicy policy = _formWritePolicies.removeLast();
      if (policy.targetText == current.text) {
        shouldValidate = policy.validate;
      }
    }
    onTextChanged(
      this,
      projectAnimalTextFieldValue(previous.text),
      validateOverride ?? shouldValidate,
      false,
    );
  }

  @override
  void dispose() {
    deactivateListener();
    super.dispose();
  }
}

AnimalFieldRegistration<T> _registrationFor<T>(
  AnimalFormController owner,
  AnimalFieldKey<T> key,
  _FieldRecord record,
) => AnimalFieldRegistration<T>._(owner, key, record.generation, record);

AnimalFieldValue<dynamic> _fieldValue(_FieldRecord record) =>
    AnimalFieldValue<dynamic>(record.key, record.value);

void _checkRegistrationReplacement<T>(
  AnimalFieldKey<T> key,
  _FieldRecord? existing,
) {
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
}

class _SubmitFieldSnapshot {
  final AnimalFieldKey<dynamic> key;
  final _FieldRecord record;
  final int generation;
  final int valueRevision;
  final int rulesRevision;

  const _SubmitFieldSnapshot({
    required this.key,
    required this.record,
    required this.generation,
    required this.valueRevision,
    required this.rulesRevision,
  });
}

class _SubmitOperation {
  final int id;
  final int formEpoch;
  final AnimalFormValues values;
  final FutureOr<bool> Function(AnimalFormValues values)? handler;
  final Map<AnimalFieldKey<dynamic>, _SubmitFieldSnapshot> fields;
  final Map<AnimalFieldKey<dynamic>, int> validationRequestIds = {};
  final Completer<AnimalSubmitResult> cancellation =
      Completer<AnimalSubmitResult>();
  bool invalidated = false;

  _SubmitOperation({
    required this.id,
    required this.formEpoch,
    required this.values,
    required this.handler,
    required this.fields,
  });
}

class _ValidationAttempt {
  final _FieldRecord record;
  final AnimalFieldKey<dynamic> key;
  final int generation;
  final int valueRevision;
  final int rulesRevision;
  final int formEpoch;
  final int requestId;
  final Object? value;
  final List<AnimalRule<dynamic>> rules;

  const _ValidationAttempt({
    required this.record,
    required this.key,
    required this.generation,
    required this.valueRevision,
    required this.rulesRevision,
    required this.formEpoch,
    required this.requestId,
    required this.value,
    required this.rules,
  });
}

class _ValidationCompletion {
  final _ValidationAttempt attempt;
  final AnimalValidationIssue? issue;
  final bool applied;

  const _ValidationCompletion({
    required this.attempt,
    required this.issue,
    required this.applied,
  });
}

class _ValidationTask {
  final _ValidationAttempt attempt;
  final Future<_ValidationCompletion> future;

  const _ValidationTask(this.attempt, this.future);
}

/// Coordinates field registration, validation state and submission.
///
/// Scalar values are held by their field records. Text field values are read
/// from the caller-owned controller registered for that field.
class AnimalFormController extends ChangeNotifier {
  final Map<AnimalFieldKey<dynamic>, _FieldRecord> _fields = {};
  Map<_TextFieldRecord, _PendingTextChange>? _pendingTextChanges;
  int _textChangeBatchDepth = 0;
  int _formEpoch = 0;
  int _nextGeneration = 0;
  int _nextSubmitOperationId = 0;
  bool _isSubmitting = false;
  bool _isDisposed = false;
  _SubmitOperation? _activeSubmit;
  FutureOr<bool> Function(AnimalFormValues values)? _defaultSubmitHandler;

  /// Optional bool submission handler supplied by the surrounding [AnimalForm].
  ///
  /// Returning true accepts the immutable snapshot; false reports rejection.
  /// Leaving the handler unset preserves validation-only successful submits.
  FutureOr<bool> Function(AnimalFormValues values)? get defaultSubmitHandler =>
      _defaultSubmitHandler;

  set defaultSubmitHandler(
    FutureOr<bool> Function(AnimalFormValues values)? handler,
  ) {
    if (identical(_defaultSubmitHandler, handler)) return;
    _defaultSubmitHandler = handler;
    _invalidateActiveSubmit();
  }

  int get epoch => _formEpoch;
  bool get isSubmitting => _isSubmitting;
  bool get isDisposed => _isDisposed;

  /// Immutable snapshot with typed reads through each field's identity.
  AnimalFormValues get values =>
      AnimalFormValues.fromEntries(_fields.values.map(_fieldValue));

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
    _checkRegistrationReplacement(key, existing);

    _assertValueType<T>(key, initialValue);
    final frozenInitialValue = key.snapshotValue(initialValue);
    final generation = ++_nextGeneration;
    final record = _ScalarFieldRecord(
      key: key,
      generation: generation,
      value: frozenInitialValue,
      baseline: frozenInitialValue,
      rules: _freezeRules(rules),
      focusNode: focusNode,
    );
    return _installRegistration<T>(key, record, existing);
  }

  /// Registers a text field whose current value lives only in [textController].
  ///
  /// The controller is borrowed. Empty text is exposed as null, while every
  /// non-text String field continues to use [registerField].
  AnimalFieldRegistration<String> registerTextField({
    required AnimalFieldKey<String> key,
    required TextEditingController textController,
    List<AnimalRule<String>>? rules,
    FocusNode? focusNode,
  }) {
    _throwIfDisposed('register a text field');
    key.requireRequestedType(String);
    final _FieldRecord? existing = _fields[key];
    _checkRegistrationReplacement(key, existing);
    for (final _FieldRecord record in _fields.values) {
      if (record is _TextFieldRecord &&
          identical(record.controller, textController) &&
          !identical(record, existing)) {
        throw ArgumentError(
          'A TextEditingController can back only one text field in a form.',
        );
      }
    }

    final int generation = ++_nextGeneration;
    final _TextFieldRecord record = _TextFieldRecord(
      key: key,
      generation: generation,
      baseline: projectAnimalTextFieldValue(textController.text),
      rules: _freezeRules(rules),
      focusNode: focusNode,
      controller: textController,
      onTextChanged: _handleTextControllerChange,
    );
    return _installRegistration<String>(key, record, existing);
  }

  AnimalFieldRegistration<T> _installRegistration<T>(
    AnimalFieldKey<T> key,
    _FieldRecord record,
    _FieldRecord? existing,
  ) {
    _fields[key] = record;
    _invalidateActiveSubmit();
    existing?.dispose();
    return _registrationFor<T>(this, key, record);
  }

  void _deactivateRegistration<T>(AnimalFieldRegistration<T> registration) {
    if (_isDisposed) return;
    registration.key.requireRequestedType(T);
    final current = _fields[registration.key];
    if (identical(current, registration._record) &&
        current?.generation == registration.generation &&
        current?.registrationActive == true) {
      current!.registrationActive = false;
      current.validationRequestId++;
      current.status = AnimalValidationStatus.idle;
      current.error = null;
      if (current is _TextFieldRecord) current.deactivateListener();
      _invalidateActiveSubmit(notify: false);
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
    if (current!.registrationActive) return true;
    current.registrationActive = true;
    if (current is _TextFieldRecord) current.activateListener();
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
    _invalidateActiveSubmit(notify: false);
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
    final nextRules = _freezeRules(rules);
    final rulesChanged = !_sameRules(record.rules, nextRules);
    record.focusNode = focusNode;
    if (rulesChanged) {
      record.rules = nextRules;
      record.rulesRevision++;
      record.status = AnimalValidationStatus.idle;
      record.error = null;
      _invalidateActiveSubmit(notify: false);
      final rulesRevision = record.rulesRevision;
      scheduleMicrotask(() {
        if (_isDisposed ||
            !identical(_fields[registration.key], record) ||
            record.rulesRevision != rulesRevision) {
          return;
        }
        record.notifyListeners();
        if (_isDisposed ||
            !identical(_fields[registration.key], record) ||
            record.rulesRevision != rulesRevision) {
          return;
        }
        notifyListeners();
      });
    }
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
    Object? frozenValue = key.snapshotValue(value);
    if (record is _TextFieldRecord) {
      frozenValue = projectAnimalTextFieldValue(frozenValue as String? ?? '');
    }
    final Object? previousValue = record.value;
    if (_formValuesEqual(previousValue, frozenValue)) return;

    if (record is _TextFieldRecord) {
      record.setFormValue(frozenValue, validate: validate);
      return;
    }
    record.value = frozenValue;
    _applyRecordValueChange(
      record,
      previousValue,
      frozenValue,
      validate: validate,
    );
  }

  void _handleTextControllerChange(
    _TextFieldRecord record,
    String? previousText,
    bool validate,
    bool allowInactive,
  ) {
    if (_isDisposed ||
        !identical(_fields[record.key], record) ||
        (!record.registrationActive && !allowInactive)) {
      return;
    }
    final Map<_TextFieldRecord, _PendingTextChange>? pendingChanges =
        _pendingTextChanges;
    if (_textChangeBatchDepth > 0 && pendingChanges != null) {
      final _PendingTextChange? pending = pendingChanges[record];
      if (pending == null) {
        pendingChanges[record] = _PendingTextChange(
          previousValue: previousText,
          validate: validate,
        );
      } else {
        pending.validate = validate;
      }
      return;
    }
    _applyRecordValueChange(
      record,
      previousText,
      record.value,
      validate: validate,
    );
  }

  void _beginTextChangeBatch() {
    if (_textChangeBatchDepth++ == 0) {
      _pendingTextChanges = <_TextFieldRecord, _PendingTextChange>{};
    }
  }

  void _endTextChangeBatch() {
    if (_textChangeBatchDepth == 0) return;
    if (--_textChangeBatchDepth > 0) return;
    final pendingChanges = _pendingTextChanges;
    _pendingTextChanges = null;
    if (pendingChanges == null || _isDisposed) return;
    for (final MapEntry<_TextFieldRecord, _PendingTextChange> entry
        in pendingChanges.entries) {
      final _TextFieldRecord record = entry.key;
      if (!identical(_fields[record.key], record)) {
        continue;
      }
      _applyRecordValueChange(
        record,
        entry.value.previousValue,
        record.value,
        validate: entry.value.validate,
        notify: false,
      );
      record.dirty = !_formValuesEqual(record.value, record.baseline);
    }
    for (final _FieldRecord record in _fields.values) {
      if (record is _TextFieldRecord) {
        record.dirty = !_formValuesEqual(record.value, record.baseline);
      }
    }
  }

  void _applyRecordValueChange(
    _FieldRecord record,
    Object? previousValue,
    Object? currentValue, {
    required bool validate,
    bool notify = true,
  }) {
    if (_formValuesEqual(previousValue, currentValue)) return;

    record.dirty = !_formValuesEqual(currentValue, record.baseline);
    record.valueRevision++;
    record.status = AnimalValidationStatus.idle;
    record.error = null;
    final submitCancelled = _invalidateActiveSubmit(notify: false);
    final valueRevision = record.valueRevision;
    final formEpoch = _formEpoch;
    if (!notify) {
      if (validate) {
        final validationRequestId = record.validationRequestId;
        scheduleMicrotask(() {
          if (_isDisposed ||
              !identical(_fields[record.key], record) ||
              record.valueRevision != valueRevision ||
              record.validationRequestId != validationRequestId ||
              record.status != AnimalValidationStatus.idle ||
              _formEpoch != formEpoch) {
            return;
          }
          unawaited(_validateRecord(record));
        });
      }
      return;
    }
    record.notifyListeners();
    if (_isDisposed ||
        !identical(_fields[record.key], record) ||
        record.valueRevision != valueRevision ||
        _formEpoch != formEpoch) {
      return;
    }

    if (validate) {
      if (submitCancelled) {
        notifyListeners();
        if (_isDisposed ||
            !identical(_fields[record.key], record) ||
            record.valueRevision != valueRevision ||
            _formEpoch != formEpoch) {
          return;
        }
      }
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
      final formEpoch = _formEpoch;
      record.notifyListeners();
      if (_isDisposed ||
          !identical(_fields[record.key], record) ||
          _formEpoch != formEpoch) {
        return;
      }
      notifyListeners();
    }
    if (validate && !_isDisposed && identical(_fields[record.key], record)) {
      unawaited(_validateRecord(record));
    }
  }

  /// Creates the immutable binding snapshot for one live registration.
  AnimalFieldBinding<T> bindingFor<T>(AnimalFieldRegistration<T> registration) {
    final record = _recordForRegistration(registration);
    final focusNode = record.focusNode;
    if (focusNode == null) {
      throw StateError('A bound field requires a focus node.');
    }
    if (record is _TextFieldRecord) {
      if (T != String) {
        throw StateError('A text registration requires a String binding.');
      }
      final stringRegistration =
          registration as AnimalFieldRegistration<String>;
      final AnimalFieldBinding<String> textBinding =
          createAnimalTextFieldBinding(
            key: stringRegistration.key,
            generation: stringRegistration.generation,
            textController: record.controller,
            error: record.error,
            status: record.status,
            dirty: record.dirty,
            touched: record.touched,
            onChanged: (value) =>
                setRegistrationValue<String>(stringRegistration, value),
            onBlur: () => touchRegistration<String>(stringRegistration),
            focusNode: focusNode,
          );
      return textBinding as AnimalFieldBinding<T>;
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
    final completion = await _startValidation(record).future;
    return completion.applied &&
        completion.issue == null &&
        _isValidationCurrent(completion.attempt);
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
    final formEpoch = _formEpoch;
    final tasks = <_ValidationTask>[];
    for (final record in records) {
      if (_isDisposed || _formEpoch != formEpoch) break;
      tasks.add(_startValidation(record));
      if (_isDisposed || _formEpoch != formEpoch) break;
    }
    final results = await Future.wait(tasks.map((task) => task.future));
    final allValid =
        !_isDisposed &&
        _formEpoch == formEpoch &&
        results.every(
          (result) =>
              result.applied &&
              result.issue == null &&
              _isValidationCurrent(result.attempt),
        );
    if (!allValid && autoFocus && !_isDisposed) focusFirstError();
    return allValid;
  }

  _ValidationTask _startValidation(
    _FieldRecord record, {
    _SubmitOperation? submitOperation,
  }) {
    if (_isDisposed ||
        !identical(_fields[record.key], record) ||
        !record.registrationActive) {
      final attempt = _ValidationAttempt(
        record: record,
        key: record.key,
        generation: record.generation,
        valueRevision: record.valueRevision,
        rulesRevision: record.rulesRevision,
        formEpoch: _formEpoch,
        requestId: record.validationRequestId,
        value: record.value,
        rules: record.rules,
      );
      return _ValidationTask(
        attempt,
        Future<_ValidationCompletion>.value(
          _ValidationCompletion(
            attempt: attempt,
            issue: record.error,
            applied: false,
          ),
        ),
      );
    }
    var submitCancelled = false;
    if (submitOperation == null) {
      submitCancelled = _invalidateActiveSubmit(notify: false);
    }
    final attempt = _ValidationAttempt(
      record: record,
      key: record.key,
      generation: record.generation,
      valueRevision: record.valueRevision,
      rulesRevision: record.rulesRevision,
      formEpoch: _formEpoch,
      requestId: ++record.validationRequestId,
      value: record.value,
      rules: record.rules,
    );
    record.status = AnimalValidationStatus.validating;
    record.notifyListeners();
    if (!_isValidationCurrent(attempt) ||
        (submitOperation != null && !_isSubmissionCurrent(submitOperation))) {
      if (submitCancelled && !_isDisposed) notifyListeners();
      return _unappliedValidation(attempt);
    }
    if (submitCancelled) {
      notifyListeners();
      if (!_isValidationCurrent(attempt) ||
          (submitOperation != null && !_isSubmissionCurrent(submitOperation))) {
        return _unappliedValidation(attempt);
      }
    }
    return _ValidationTask(attempt, _evaluateValidation(attempt));
  }

  _ValidationTask _unappliedValidation(_ValidationAttempt attempt) =>
      _ValidationTask(
        attempt,
        Future<_ValidationCompletion>.value(
          _ValidationCompletion(attempt: attempt, issue: null, applied: false),
        ),
      );

  Future<void> _validateRecord(_FieldRecord record) async {
    await _startValidation(record).future;
  }

  Future<_ValidationCompletion> _evaluateValidation(
    _ValidationAttempt attempt,
  ) async {
    AnimalValidationIssue? foundError;
    for (final rule in attempt.rules) {
      if (!_isValidationCurrent(attempt)) {
        return _ValidationCompletion(
          attempt: attempt,
          issue: null,
          applied: false,
        );
      }
      AnimalValidationIssue? result;
      try {
        result = await rule.evaluate(attempt.value);
      } catch (_) {
        result = const AnimalValidationIssue.validationFailure();
      }
      if (!_isValidationCurrent(attempt)) {
        return _ValidationCompletion(
          attempt: attempt,
          issue: null,
          applied: false,
        );
      }
      if (result != null) {
        foundError = result;
        break;
      }
    }

    if (!_isValidationCurrent(attempt)) {
      return _ValidationCompletion(
        attempt: attempt,
        issue: null,
        applied: false,
      );
    }

    final record = attempt.record;
    record.error = foundError;
    record.status = foundError == null
        ? AnimalValidationStatus.valid
        : AnimalValidationStatus.invalid;
    record.notifyListeners();
    if (!_isValidationCurrent(attempt)) {
      return _ValidationCompletion(
        attempt: attempt,
        issue: null,
        applied: false,
      );
    }
    notifyListeners();
    if (!_isValidationCurrent(attempt)) {
      return _ValidationCompletion(
        attempt: attempt,
        issue: null,
        applied: false,
      );
    }
    return _ValidationCompletion(
      attempt: attempt,
      issue: foundError,
      applied: true,
    );
  }

  bool _isValidationCurrent(_ValidationAttempt attempt) {
    final record = attempt.record;
    if (_isDisposed ||
        !identical(_fields[attempt.key], record) ||
        !record.registrationActive ||
        record.generation != attempt.generation ||
        _formEpoch != attempt.formEpoch ||
        record.valueRevision != attempt.valueRevision ||
        record.rulesRevision != attempt.rulesRevision ||
        record.validationRequestId != attempt.requestId) {
      return false;
    }
    return true;
  }

  /// Submits one immutable value snapshot after validation succeeds.
  ///
  /// A handler returning false produces [AnimalSubmitStatus.rejected]. A
  /// thrown handler error is retained in [AnimalSubmitResult.error]. When no
  /// handler is installed, a valid snapshot succeeds after validation only.
  Future<AnimalSubmitResult> submit({
    FutureOr<bool> Function(AnimalFormValues values)? onSubmit,
  }) async {
    if (_isDisposed) return AnimalSubmitResult.invalid;
    if (_isSubmitting) return AnimalSubmitResult.busy;

    final fields = <AnimalFieldKey<dynamic>, _SubmitFieldSnapshot>{
      for (final entry in _fields.entries)
        entry.key: _SubmitFieldSnapshot(
          key: entry.key,
          record: entry.value,
          generation: entry.value.generation,
          valueRevision: entry.value.valueRevision,
          rulesRevision: entry.value.rulesRevision,
        ),
    };
    final operation = _SubmitOperation(
      id: ++_nextSubmitOperationId,
      formEpoch: _formEpoch,
      values: values,
      handler: onSubmit ?? _defaultSubmitHandler,
      fields: fields,
    );
    _activeSubmit = operation;
    _isSubmitting = true;
    notifyListeners();

    return await Future.any(<Future<AnimalSubmitResult>>[
      _runSubmission(operation),
      operation.cancellation.future,
    ]);
  }

  Future<AnimalSubmitResult> _runSubmission(_SubmitOperation operation) async {
    try {
      if (!_isSubmissionCurrent(operation)) {
        return AnimalSubmitResult.changedDuringValidation;
      }
      final tasks = <_ValidationTask>[];
      for (final field in operation.fields.values) {
        if (!_isSubmissionCurrent(operation)) {
          return AnimalSubmitResult.changedDuringValidation;
        }
        final task = _startValidation(field.record, submitOperation: operation);
        operation.validationRequestIds[field.key] = task.attempt.requestId;
        tasks.add(task);
        if (!_isSubmissionCurrent(operation)) {
          return AnimalSubmitResult.changedDuringValidation;
        }
      }
      final completions = await Future.wait(tasks.map((task) => task.future));
      if (!_isSubmissionCurrent(operation) ||
          completions.any(
            (completion) =>
                !completion.applied ||
                !_isValidationCurrent(completion.attempt),
          )) {
        return AnimalSubmitResult.changedDuringValidation;
      }
      if (completions.any((completion) => completion.issue != null)) {
        focusFirstError();
        return _isSubmissionCurrent(operation)
            ? AnimalSubmitResult.invalid
            : AnimalSubmitResult.changedDuringValidation;
      }

      final handler = operation.handler;
      if (handler == null) return AnimalSubmitResult.success;
      final accepted = await handler(operation.values);
      if (!_isSubmissionCurrent(operation)) {
        return AnimalSubmitResult.changedDuringValidation;
      }
      return accepted
          ? AnimalSubmitResult.success
          : AnimalSubmitResult.rejected;
    } catch (error) {
      return _isSubmissionCurrent(operation)
          ? AnimalSubmitResult.error(error)
          : AnimalSubmitResult.changedDuringValidation;
    } finally {
      _finishSubmit(operation);
    }
  }

  bool _isSubmissionCurrent(_SubmitOperation operation) {
    if (_isDisposed ||
        !identical(_activeSubmit, operation) ||
        _activeSubmit?.id != operation.id ||
        operation.invalidated ||
        _formEpoch != operation.formEpoch ||
        _fields.length != operation.fields.length) {
      return false;
    }
    for (final field in operation.fields.values) {
      final current = _fields[field.key];
      if (!identical(current, field.record) ||
          !current!.registrationActive ||
          current.generation != field.generation ||
          current.valueRevision != field.valueRevision ||
          current.rulesRevision != field.rulesRevision) {
        return false;
      }
      final requestId = operation.validationRequestIds[field.key];
      if (requestId != null && current.validationRequestId != requestId) {
        return false;
      }
    }
    return true;
  }

  bool _invalidateActiveSubmit({bool notify = true}) {
    final operation = _activeSubmit;
    if (operation == null) return false;
    operation.invalidated = true;
    _activeSubmit = null;
    _isSubmitting = false;
    if (!operation.cancellation.isCompleted) {
      operation.cancellation.complete(
        AnimalSubmitResult.changedDuringValidation,
      );
    }
    if (notify && !_isDisposed) notifyListeners();
    return true;
  }

  void _finishSubmit(_SubmitOperation operation) {
    if (!identical(_activeSubmit, operation)) return;
    _activeSubmit = null;
    _isSubmitting = false;
    if (!_isDisposed) notifyListeners();
  }

  /// Focuses the first invalid field in registration order.
  bool focusFirstError() {
    for (final record in _fields.values) {
      if (record.registrationActive &&
          record.status == AnimalValidationStatus.invalid &&
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
    _invalidateActiveSubmit(notify: false);
    final records = _fields.values.toList(growable: false);
    _beginTextChangeBatch();
    try {
      for (final record in records) {
        if (record is _TextFieldRecord) {
          record.setFormValue(record.baseline, validate: false);
        } else {
          if (!_formValuesEqual(record.value, record.baseline)) {
            record.valueRevision++;
          }
          record.value = record.baseline;
        }
        record.dirty = false;
        record.touched = false;
        record.status = AnimalValidationStatus.idle;
        record.error = null;
      }
    } finally {
      _formEpoch++;
      _endTextChangeBatch();
    }
    final formEpoch = _formEpoch;
    for (final record in records) {
      if (_isDisposed || _formEpoch != formEpoch) return;
      if (identical(_fields[record.key], record)) record.notifyListeners();
      if (_isDisposed || _formEpoch != formEpoch) return;
    }
    notifyListeners();
  }

  /// Sets every registered value to null while retaining its original baseline.
  void clear() {
    if (_isDisposed) return;
    _invalidateActiveSubmit(notify: false);
    final records = _fields.values.toList(growable: false);
    _beginTextChangeBatch();
    try {
      for (final record in records) {
        if (record is _TextFieldRecord) {
          record.setFormValue(null, validate: false);
        } else {
          if (!_formValuesEqual(record.value, null)) record.valueRevision++;
          record.value = null;
        }
        record.dirty = !_formValuesEqual(null, record.baseline);
        record.status = AnimalValidationStatus.idle;
        record.error = null;
      }
    } finally {
      _formEpoch++;
      _endTextChangeBatch();
    }
    final formEpoch = _formEpoch;
    for (final record in records) {
      if (_isDisposed || _formEpoch != formEpoch) return;
      if (identical(_fields[record.key], record)) record.notifyListeners();
      if (_isDisposed || _formEpoch != formEpoch) return;
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

  bool _sameRules(
    List<AnimalRule<dynamic>> left,
    List<AnimalRule<dynamic>> right,
  ) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

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
    _formEpoch++;
    _invalidateActiveSubmit(notify: false);
    for (final record in _fields.values) {
      record.dispose();
    }
    _fields.clear();
    super.dispose();
  }
}
