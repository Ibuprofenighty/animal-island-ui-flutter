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
  /// Outcome of the submission.
  final AnimalSubmitStatus status;

  /// Error thrown by the submit handler when [status] is
  /// [AnimalSubmitStatus.error]; null for every other status.
  final Object? error;

  const AnimalSubmitResult._(this.status, [this.error]);

  /// Every field validated and the handler accepted the snapshot, or no
  /// handler was installed.
  static const AnimalSubmitResult success = AnimalSubmitResult._(
    AnimalSubmitStatus.success,
  );

  /// At least one field failed validation.
  static const AnimalSubmitResult invalid = AnimalSubmitResult._(
    AnimalSubmitStatus.invalid,
  );

  /// The submit handler returned false to reject this snapshot.
  static const AnimalSubmitResult rejected = AnimalSubmitResult._(
    AnimalSubmitStatus.rejected,
  );

  /// Another submission was already in progress; nothing was validated.
  static const AnimalSubmitResult busy = AnimalSubmitResult._(
    AnimalSubmitStatus.busy,
  );

  /// The form changed before the submission finished, so its snapshot is
  /// stale.
  static const AnimalSubmitResult changedDuringValidation =
      AnimalSubmitResult._(AnimalSubmitStatus.changedDuringValidation);

  /// Creates a result carrying the [error] thrown by the submit handler.
  factory AnimalSubmitResult.error(Object error) =>
      AnimalSubmitResult._(AnimalSubmitStatus.error, error);

  @override
  String toString() =>
      'AnimalSubmitResult($status${error == null ? '' : ', error: $error'})';
}

/// Outcome of validating and submitting a form.
enum AnimalSubmitStatus {
  /// Validation passed and the handler accepted the snapshot, or no handler
  /// was installed.
  success,

  /// At least one field failed validation.
  invalid,

  /// The submit handler returned false.
  rejected,

  /// Another submission was already in progress.
  busy,

  /// A value, rule, registration or the form's handler changed, a new
  /// validation started (including a field's validation on focus loss), or the
  /// form was reset, cleared or disposed, before the submission finished.
  changedDuringValidation,

  /// The submit handler threw; see [AnimalSubmitResult.error].
  error,
}

/// Unique capability for one registration of a field with one controller.
///
/// The generation advances on every registration, including registrations that
/// reuse an earlier key after it has been unregistered. The token also listens
/// only to its own field record.
class AnimalFieldRegistration<T> implements Listenable {
  /// Field identity this registration was created for.
  final AnimalFieldKey<T> key;

  final AnimalFormController _owner;
  final _FieldRecord _record;

  AnimalFieldRegistration._(this._owner, this.key, this._record);

  /// Controller-wide registration counter value assigned to this token.
  int get generation => _record.generation;

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

sealed class _FieldRecord extends ChangeNotifier {
  // Lets the controller and its registration protocol notify this field's
  // listeners without calling the protected ChangeNotifier member.
  void notifyChanged() => notifyListeners();

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

  void setFormValue(Object? value, {required bool validate}) {
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
    if (previous.text == current.text) return;
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
) => AnimalFieldRegistration<T>._(owner, key, record);

AnimalFieldValue<dynamic> _fieldValue(_FieldRecord record) =>
    AnimalFieldValue<dynamic>(record.key, record.value);

void _checkRegistrationReplacement(_FieldRecord? existing) {
  if (existing != null && existing.registrationActive) {
    throw StateError('The field identity is already registered.');
  }
}

class _SubmitFieldSnapshot {
  final _FieldRecord record;
  final int valueRevision;
  final int rulesRevision;

  const _SubmitFieldSnapshot({
    required this.record,
    required this.valueRevision,
    required this.rulesRevision,
  });
}

class _SubmitOperation {
  final int formEpoch;
  final AnimalFormValues values;
  final FutureOr<bool> Function(AnimalFormValues values)? handler;
  final Map<AnimalFieldKey<dynamic>, _SubmitFieldSnapshot> fields;
  final Map<AnimalFieldKey<dynamic>, int> validationRequestIds = {};
  final Completer<AnimalSubmitResult> cancellation =
      Completer<AnimalSubmitResult>();

  _SubmitOperation({
    required this.formEpoch,
    required this.values,
    required this.handler,
    required this.fields,
  });
}

class _ValidationAttempt {
  final _FieldRecord record;
  final int valueRevision;
  final int rulesRevision;
  final int formEpoch;
  final int requestId;
  final Object? value;
  final List<AnimalRule<dynamic>> rules;

  const _ValidationAttempt({
    required this.record,
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
  // Text changes made while reset or clear writes the fields; non-null
  // exactly during that write phase.
  Map<_TextFieldRecord, _PendingTextChange>? _pendingTextChanges;
  int _formEpoch = 0;
  int _nextGeneration = 0;
  bool _isSubmitting = false;
  bool _isDisposed = false;
  _SubmitOperation? _activeSubmit;
  FutureOr<bool> Function(AnimalFormValues values)? _defaultSubmitHandler;

  /// Whether a [submit] call is in progress.
  ///
  /// Becomes true when [submit] starts and false when it finishes or is
  /// cancelled; listeners are notified on both transitions.
  bool get isSubmitting => _isSubmitting;

  // The registration protocol extension cannot call the protected
  // notifyListeners directly.
  void _notifyFormListeners() => notifyListeners();

  /// Immutable snapshot with typed reads through each field's identity.
  ///
  /// Holds one entry per registered field, including fields whose widget is
  /// temporarily deactivated; it is empty after [dispose].
  AnimalFormValues get values =>
      AnimalFormValues.fromEntries(_fields.values.map(_fieldValue));

  /// Whether any registered field's value differs from its initial value.
  ///
  /// Returns false after [dispose].
  bool get isDirty => _fields.values.any((record) => record.dirty);

  /// Returns the current value for [key], or null when it is not registered.
  ///
  /// Text fields report empty text as null. Returns null after [dispose]
  /// instead of throwing. Throws a [StateError] when [key] is read with a type
  /// argument other than its own.
  T? valueFor<T>(AnimalFieldKey<T> key) {
    final record = _recordForKey(key, required: false);
    return record?.value as T?;
  }

  /// Returns the latest validation issue for [key], or null when the field is
  /// valid, not yet validated, or not registered.
  ///
  /// Returns null after [dispose] instead of throwing.
  AnimalValidationIssue? getFieldError<T>(AnimalFieldKey<T> key) =>
      _recordForKey(key, required: false)?.error;

  /// Returns the validation status for [key], or
  /// [AnimalValidationStatus.idle] when it is not registered.
  ///
  /// Returns [AnimalValidationStatus.idle] after [dispose] instead of throwing.
  AnimalValidationStatus getFieldStatus<T>(AnimalFieldKey<T> key) =>
      _recordForKey(key, required: false)?.status ??
      AnimalValidationStatus.idle;

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
    final current = registration._record;
    if (_isCurrent(current) && current.registrationActive) {
      current.registrationActive = false;
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
    final current = registration._record;
    if (!_isCurrent(current)) return false;
    if (current.registrationActive) return true;
    current.registrationActive = true;
    if (current is _TextFieldRecord) current.activateListener();
    return true;
  }

  /// Updates a registered value through its typed identity.
  ///
  /// Does nothing when [value] equals the current value. Otherwise the field's
  /// error is cleared, it becomes dirty unless [value] equals its initial
  /// value, and any active [submit] is cancelled. The field's listeners are
  /// notified at once. When [validate] is true the field is then validated and
  /// form listeners are notified when that result is applied (and also at once
  /// if a submission was cancelled); when false they are notified immediately.
  ///
  /// Throws a [StateError] after [dispose] or while [reset] or [clear] writes
  /// the fields, when [key] is not registered, or when [key] or [value] does
  /// not match the key's value type.
  void setValue<T>(AnimalFieldKey<T> key, T? value, {bool validate = true}) {
    final record = _recordForKey(key)!;
    _setRecordValue(record, key, value, validate: validate);
  }

  void _setRecordValue<T>(
    _FieldRecord record,
    AnimalFieldKey<T> key,
    T? value, {
    required bool validate,
  }) {
    Object? frozenValue = key.snapshotValue(value);
    if (record is _TextFieldRecord) {
      frozenValue = projectAnimalTextFieldValue(frozenValue as String? ?? '');
    }
    final Object? previousValue = record.value;
    if (_formValuesEqual(previousValue, frozenValue)) return;

    switch (record) {
      case _TextFieldRecord():
        record.setFormValue(frozenValue, validate: validate);
        return;
      case _ScalarFieldRecord():
        record.value = frozenValue;
    }
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
  ) {
    if (!_isCurrent(record)) return;
    final Map<_TextFieldRecord, _PendingTextChange>? pendingChanges =
        _pendingTextChanges;
    if (pendingChanges != null) {
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

  // A record is current while its key still maps to its generation; every
  // registration creates a record with a new generation.
  bool _isCurrent(_FieldRecord record) =>
      _fields[record.key]?.generation == record.generation;

  // Applies the text changes made while reset or clear wrote the fields.
  void _applyTextChangeBatch() {
    final pendingChanges = _pendingTextChanges!;
    _pendingTextChanges = null;
    for (final MapEntry<_TextFieldRecord, _PendingTextChange> entry
        in pendingChanges.entries) {
      final _TextFieldRecord record = entry.key;
      if (!_isCurrent(record)) {
        continue;
      }
      _applyRecordValueChange(
        record,
        entry.value.previousValue,
        record.value,
        validate: entry.value.validate,
        notify: false,
      );
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
          if (!_isCurrent(record) ||
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
    record.notifyChanged();
    if (!_isCurrent(record) ||
        record.valueRevision != valueRevision ||
        _formEpoch != formEpoch) {
      return;
    }

    if (validate) {
      if (submitCancelled) {
        notifyListeners();
        if (!_isCurrent(record) ||
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

  // Marks the field touched and validates it.
  void _touchRecord(_FieldRecord record) {
    final formEpoch = _formEpoch;
    if (!record.touched) {
      record.touched = true;
      record.notifyChanged();
      if (!_isCurrent(record) || _formEpoch != formEpoch) {
        return;
      }
      notifyListeners();
    }
    // A listener notified of the touch reset, cleared or disposed the form.
    if (_isCurrent(record) && _formEpoch == formEpoch) {
      unawaited(_validateRecord(record));
    }
  }

  /// Asynchronously validates one typed field using the latest-wins behavior.
  ///
  /// Completes with true when the field is valid or not registered, and with
  /// false when it is invalid or when a newer value, rule set or validation
  /// superseded this run. Field and form listeners are notified when the
  /// result is applied. Throws a [StateError] after [dispose] or while [reset]
  /// or [clear] writes the fields.
  Future<bool> validateField<T>(AnimalFieldKey<T> key) async {
    _throwIfUnavailable('validate a field');
    final record = _recordForKey(key, required: false);
    if (record == null) return true;
    final completion = await _startValidation(record).future;
    return completion.applied &&
        completion.issue == null &&
        _isValidationCurrent(completion.attempt);
  }

  /// Validates all registered fields or the supplied typed subset.
  ///
  /// Keys in `fieldKeys` that are not registered are skipped. Completes with
  /// true only when every validated field is valid and no newer change
  /// superseded the run. When the result is false and [autoFocus] is true,
  /// calls [focusFirstError]. Throws a [StateError] after [dispose] or while
  /// [reset] or [clear] writes the fields.
  Future<bool> validate({
    Iterable<AnimalFieldKey<dynamic>>? fieldKeys,
    bool autoFocus = true,
  }) async {
    _throwIfUnavailable('validate the form');
    final records = fieldKeys == null
        ? _fields.values.toList(growable: false)
        : fieldKeys
              .map((key) => _fields[key])
              .whereType<_FieldRecord>()
              .toList(growable: false);
    final formEpoch = _formEpoch;
    final tasks = <_ValidationTask>[];
    for (final record in records) {
      tasks.add(_startValidation(record));
      if (_formEpoch != formEpoch) break;
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
    if (!_isCurrent(record) || !record.registrationActive) {
      final attempt = _ValidationAttempt(
        record: record,
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
      valueRevision: record.valueRevision,
      rulesRevision: record.rulesRevision,
      formEpoch: _formEpoch,
      requestId: ++record.validationRequestId,
      value: record.value,
      rules: record.rules,
    );
    record.status = AnimalValidationStatus.validating;
    record.notifyChanged();
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
    record.notifyChanged();
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
    if (!_isCurrent(record) ||
        !record.registrationActive ||
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
  /// `onSubmit` takes precedence over the form's own handler.
  ///
  /// Returns [AnimalSubmitResult.busy] while another submission runs and
  /// throws a [StateError] after [dispose] or while [reset] or [clear] writes
  /// the fields. Listeners are notified when the submission starts and when it
  /// ends. A change to any value, rule,
  /// registration or the form's handler, a new validation (including the
  /// validation a field runs when it loses focus), a [reset], a [clear] or
  /// [dispose] ends the submission with
  /// [AnimalSubmitStatus.changedDuringValidation]. An invalid result also
  /// calls [focusFirstError].
  Future<AnimalSubmitResult> submit({
    FutureOr<bool> Function(AnimalFormValues values)? onSubmit,
  }) async {
    _throwIfUnavailable('submit the form');
    if (_isSubmitting) return AnimalSubmitResult.busy;

    final fields = <AnimalFieldKey<dynamic>, _SubmitFieldSnapshot>{
      for (final entry in _fields.entries)
        entry.key: _SubmitFieldSnapshot(
          record: entry.value,
          valueRevision: entry.value.valueRevision,
          rulesRevision: entry.value.rulesRevision,
        ),
    };
    final operation = _SubmitOperation(
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
        final task = _startValidation(field.record, submitOperation: operation);
        operation.validationRequestIds[field.record.key] =
            task.attempt.requestId;
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
    if (!identical(_activeSubmit, operation) ||
        _formEpoch != operation.formEpoch ||
        _fields.length != operation.fields.length) {
      return false;
    }
    for (final field in operation.fields.values) {
      final record = field.record;
      if (!_isCurrent(record) ||
          !record.registrationActive ||
          record.valueRevision != field.valueRevision ||
          record.rulesRevision != field.rulesRevision) {
        return false;
      }
      final requestId = operation.validationRequestIds[record.key];
      if (requestId != null && record.validationRequestId != requestId) {
        return false;
      }
    }
    return true;
  }

  bool _invalidateActiveSubmit({bool notify = true}) {
    final operation = _activeSubmit;
    if (operation == null) return false;
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
  ///
  /// Returns whether a field was focused. Throws a [StateError] after
  /// [dispose] or while [reset] or [clear] writes the fields.
  bool focusFirstError() {
    _throwIfUnavailable('focus the first error');
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
  ///
  /// Clears dirty, touched and validation state without validating, cancels
  /// any active [submit] and in-flight validation, then notifies each field's
  /// listeners and the form listeners once. Throws a [StateError] after
  /// [dispose].
  ///
  /// While the fields are written, a listener that starts form work gets a
  /// [StateError]. It may still unregister a field, which drops out of the
  /// write, or [dispose] the form, which ends the call without notifying.
  /// Field and form listeners are notified once after the write, see the final
  /// state and may start new work.
  void reset() {
    _throwIfUnavailable('reset the form');
    _rewriteFields((record) {
      record.dirty = false;
      record.touched = false;
      _writeFieldValue(record, record.baseline);
    });
  }

  /// Sets every registered value to null while retaining its original baseline.
  ///
  /// Fields whose initial value was non-null become dirty; touched state is
  /// kept. Clears validation state without validating, cancels any active
  /// [submit] and in-flight validation, then notifies each field's listeners
  /// and the form listeners once. Throws a [StateError] after [dispose].
  ///
  /// While the fields are written, a listener that starts form work gets a
  /// [StateError]. It may still unregister a field, which drops out of the
  /// write, or [dispose] the form, which ends the call without notifying.
  /// Field and form listeners are notified once after the write, see the final
  /// state and may start new work.
  void clear() {
    _throwIfUnavailable('clear the form');
    _rewriteFields((record) {
      record.dirty = !_formValuesEqual(null, record.baseline);
      _writeFieldValue(record, null);
    });
  }

  // Rewrites every field for reset and clear. The epoch advances first, so
  // validation in flight is discarded. While the fields are written, form
  // work started by a listener throws (see _throwIfUnavailable); a listener
  // may still unregister a field, which drops out of the write, or dispose
  // the form, which removes every remaining field. Listeners notified
  // afterwards see the final state and may start new work.
  void _rewriteFields(void Function(_FieldRecord record) rewrite) {
    _invalidateActiveSubmit(notify: false);
    final records = _fields.values.toList(growable: false);
    final formEpoch = ++_formEpoch;
    _pendingTextChanges = <_TextFieldRecord, _PendingTextChange>{};
    try {
      for (final record in records) {
        if (!_isCurrent(record)) continue;
        record.status = AnimalValidationStatus.idle;
        record.error = null;
        rewrite(record);
      }
    } finally {
      _applyTextChangeBatch();
    }
    for (final record in records) {
      if (_isCurrent(record)) record.notifyChanged();
      if (_formEpoch != formEpoch) return;
    }
    notifyListeners();
  }

  // Writes a value without validating. A text write is last because its
  // controller listeners may run.
  void _writeFieldValue(_FieldRecord record, Object? value) {
    switch (record) {
      case _TextFieldRecord():
        record.setFormValue(value, validate: false);
      case _ScalarFieldRecord():
        if (!_formValuesEqual(record.value, value)) record.valueRevision++;
        record.value = value;
    }
  }

  _FieldRecord? _recordForKey<T>(
    AnimalFieldKey<T> key, {
    bool required = true,
  }) {
    key.requireRequestedType(T);
    if (required) _throwIfUnavailable('set a field value');
    final record = _fields[key];
    if (record == null && required) {
      throw StateError('The field is not registered.');
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
    final current = registration._record;
    if (!_isCurrent(current)) {
      throw StateError('The field registration is no longer active.');
    }
    if (!current.registrationActive) {
      throw StateError('The field registration is inactive.');
    }
    return current;
  }

  void _assertCurrentRegistration<T>(AnimalFieldRegistration<T> registration) {
    _recordForRegistration(registration);
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

  // Starting form work is refused after dispose and while reset or clear
  // writes the fields, when the form is in neither its old nor its new state.
  void _throwIfUnavailable(String operation) {
    _throwIfDisposed(operation);
    if (_pendingTextChanges != null) {
      throw StateError(
        'Cannot $operation while the form is being reset or cleared.',
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

  // Updates a value through its registration, preserving generation ownership.
  void _setRegistrationValue<T>(
    AnimalFieldRegistration<T> registration,
    T? value,
  ) {
    _throwIfUnavailable('set a field value');
    final record = _recordForRegistration(registration);
    _setRecordValue(record, registration.key, value, validate: true);
  }

  // Marks one specific registration as touched.
  void _touchRegistration<T>(AnimalFieldRegistration<T> registration) {
    _throwIfUnavailable('touch a field');
    _touchRecord(_recordForRegistration(registration));
  }
}

/// The registration protocol between [AnimalFormController] and
/// `AnimalFormItem`.
///
/// Package-internal: the root library exports the controller without this
/// extension, so applications register fields only by placing an
/// `AnimalFormItem` under an `AnimalForm`.
extension AnimalFormFieldProtocol on AnimalFormController {
  /// Submission handler installed by the surrounding [AnimalForm] and used by
  /// [AnimalFormController.submit] when no `onSubmit` is given.
  ///
  /// Returning true accepts the immutable snapshot; false reports rejection.
  /// Without a handler a valid snapshot succeeds after validation only.
  /// Replacing the handler cancels an active submission.
  FutureOr<bool> Function(AnimalFormValues values)? get defaultSubmitHandler =>
      _defaultSubmitHandler;

  set defaultSubmitHandler(
    FutureOr<bool> Function(AnimalFormValues values)? handler,
  ) {
    if (identical(_defaultSubmitHandler, handler)) return;
    _defaultSubmitHandler = handler;
    _invalidateActiveSubmit();
  }

  /// Registers one field and returns the unique token for this occurrence.
  AnimalFieldRegistration<T> registerField<T>({
    required AnimalFieldKey<T> key,
    T? initialValue,
    List<AnimalRule<T>>? rules,
    FocusNode? focusNode,
  }) {
    _throwIfUnavailable('register a field');

    final existing = _fields[key];
    _checkRegistrationReplacement(existing);

    key.requireRequestedType(T);
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
    _throwIfUnavailable('register a text field');
    key.requireRequestedType(String);
    final _FieldRecord? existing = _fields[key];
    _checkRegistrationReplacement(existing);
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

  /// Removes only the record created by [registration].
  ///
  /// A stale token is harmless after a later registration reused its key.
  void unregisterField<T>(AnimalFieldRegistration<T> registration) {
    if (_isDisposed) return;
    registration.key.requireRequestedType(T);
    if (!identical(registration._owner, this)) {
      throw StateError('The field registration belongs to another controller.');
    }
    final current = registration._record;
    if (!_isCurrent(current)) return;
    _fields.remove(registration.key);
    _invalidateActiveSubmit(notify: false);
    current.dispose();
    // During a reset or clear write the form is notified once afterwards.
    if (_pendingTextChanges == null) _notifyFormListeners();
  }

  /// Updates rules and borrowed focus for the same registration.
  ///
  /// Updating configuration never changes the field's value or baseline.
  void updateFieldRegistration<T>(
    AnimalFieldRegistration<T> registration, {
    required List<AnimalRule<T>> rules,
    required FocusNode focusNode,
  }) {
    _throwIfUnavailable('update a field registration');
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
        if (!_isCurrent(record) || record.rulesRevision != rulesRevision) {
          return;
        }
        record.notifyChanged();
        if (!_isCurrent(record) || record.rulesRevision != rulesRevision) {
          return;
        }
        _notifyFormListeners();
      });
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
      final stringRegistration =
          registration as AnimalFieldRegistration<String>;
      final AnimalFieldBinding<String> textBinding =
          createAnimalTextFieldBinding(
            key: stringRegistration.key,
            textController: record.controller,
            error: record.error,
            status: record.status,
            dirty: record.dirty,
            touched: record.touched,
            onChanged: (value) =>
                _setRegistrationValue<String>(stringRegistration, value),
            onBlur: () => _touchRegistration<String>(stringRegistration),
            focusNode: focusNode,
          );
      return textBinding as AnimalFieldBinding<T>;
    }
    return createAnimalFieldBinding<T>(
      key: registration.key,
      value: record.value as T?,
      error: record.error,
      status: record.status,
      dirty: record.dirty,
      touched: record.touched,
      onChanged: (value) => _setRegistrationValue<T>(registration, value),
      onBlur: () => _touchRegistration<T>(registration),
      focusNode: focusNode,
    );
  }
}
