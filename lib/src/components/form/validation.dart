import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_validation_issue.dart';

// Category of a validation rule.
enum _AnimalRuleType {
  /// Checks that the field has a non-null, non-empty value.
  required,

  /// Validates standard email address syntax.
  email,

  /// Validates standard HTTP/HTTPS URL syntax.
  url,

  /// Validates value against a custom [RegExp].
  pattern,

  /// Validates numeric lower bound (value >= min).
  min,

  /// Validates numeric upper bound (value <= max).
  max,

  /// Validates string or collection length (character count or item count).
  length,

  /// Custom synchronous or asynchronous validation logic.
  custom,
}

/// An immutable validation rule definition for form fields.
@immutable
class AnimalRule<T> {
  /// The category of this rule.
  final _AnimalRuleType _type;

  /// Optional caller-owned literal copy for this rule's failure.
  ///
  /// When omitted, evaluation returns a locale-neutral built-in issue that is
  /// formatted at the point of presentation.
  final String? _message;

  /// Numeric minimum bound for `min`.
  final num? _min;

  /// Numeric maximum bound for `max`.
  final num? _max;

  /// Character/collection length minimum for `length`.
  final int? _minLength;

  /// Character/collection length maximum for `length`.
  final int? _maxLength;

  /// Regular expression pattern for `pattern`.
  final RegExp? _pattern;

  /// Custom validation function for `custom`.
  final FutureOr<String?> Function(T? value)? _customValidator;

  const AnimalRule._({
    required this._type,
    this._message,
    this._min,
    this._max,
    this._minLength,
    this._maxLength,
    this._pattern,
    this._customValidator,
  });

  /// Rules compare by immutable configuration; custom validators compare by
  /// callback identity because their behavior cannot be inspected safely.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimalRule<T> || runtimeType != other.runtimeType) {
      return false;
    }
    final otherPattern = other._pattern;
    final thisPattern = _pattern;
    return _type == other._type &&
        _message == other._message &&
        _min == other._min &&
        _max == other._max &&
        _minLength == other._minLength &&
        _maxLength == other._maxLength &&
        _samePattern(thisPattern, otherPattern) &&
        identical(_customValidator, other._customValidator);
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    _type,
    _message,
    _min,
    _max,
    _minLength,
    _maxLength,
    _patternHash(_pattern),
    _customValidator == null ? 0 : identityHashCode(_customValidator),
  );

  static bool _samePattern(RegExp? left, RegExp? right) {
    if (left == null || right == null) return left == right;
    return left.pattern == right.pattern &&
        left.isCaseSensitive == right.isCaseSensitive &&
        left.isMultiLine == right.isMultiLine &&
        left.isUnicode == right.isUnicode &&
        left.isDotAll == right.isDotAll;
  }

  static int _patternHash(RegExp? value) => value == null
      ? 0
      : Object.hash(
          value.pattern,
          value.isCaseSensitive,
          value.isMultiLine,
          value.isUnicode,
          value.isDotAll,
        );

  /// Creates a rule requiring a non-null, non-empty value.
  factory AnimalRule.required({String? message}) =>
      AnimalRule._(type: _AnimalRuleType.required, message: message);

  /// Creates a rule validating standard email syntax.
  factory AnimalRule.email({String? message}) => AnimalRule._(
    type: _AnimalRuleType.email,
    message: message,
    pattern: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
  );

  /// Creates a rule validating standard HTTP/HTTPS URL syntax.
  factory AnimalRule.url({String? message}) => AnimalRule._(
    type: _AnimalRuleType.url,
    message: message,
    pattern: RegExp(r'^(https?:\/\/)[^\s/$.?#].[^\s]*$', caseSensitive: false),
  );

  /// Creates a rule matching string representations against [pattern].
  factory AnimalRule.pattern(RegExp pattern, {String? message}) => AnimalRule._(
    type: _AnimalRuleType.pattern,
    message: message,
    pattern: pattern,
  );

  /// Creates a numeric rule requiring value >= [min].
  factory AnimalRule.min(num min, {String? message}) =>
      AnimalRule._(type: _AnimalRuleType.min, message: message, min: min);

  /// Creates a numeric rule requiring value <= [max].
  factory AnimalRule.max(num max, {String? message}) =>
      AnimalRule._(type: _AnimalRuleType.max, message: message, max: max);

  /// Creates a length rule requiring character or item length within [[min], [max]].
  factory AnimalRule.length({int? min, int? max, String? message}) {
    if (min == null && max == null) {
      throw ArgumentError('At least one of min or max must be provided.');
    }
    return AnimalRule._(
      type: _AnimalRuleType.length,
      message: message,
      minLength: min,
      maxLength: max,
    );
  }

  /// Creates a custom rule evaluated via [validator].
  factory AnimalRule.custom(FutureOr<String?> Function(T? value) validator) =>
      AnimalRule._(type: _AnimalRuleType.custom, customValidator: validator);

  /// Evaluates this rule against [value].
  ///
  /// Returns a locale-neutral issue when invalid. Caller-provided custom
  /// messages are represented as literal issues; default copy is resolved later.
  FutureOr<AnimalValidationIssue?> evaluate(T? value) {
    try {
      switch (_type) {
        case _AnimalRuleType.required:
          if (value == null) return _issue(AnimalValidationIssue.required());
          if (value is String && value.trim().isEmpty) {
            return _issue(AnimalValidationIssue.required());
          }
          if (value is Iterable && value.isEmpty) {
            return _issue(AnimalValidationIssue.required());
          }
          if (value is Map && value.isEmpty) {
            return _issue(AnimalValidationIssue.required());
          }
          return null;

        case _AnimalRuleType.email:
        case _AnimalRuleType.url:
        case _AnimalRuleType.pattern:
          if (value == null || (value is String && value.isEmpty)) return null;
          final str = value.toString();
          if (_pattern != null && !_pattern.hasMatch(str)) {
            return _issue(switch (_type) {
              _AnimalRuleType.email => const AnimalValidationIssue.email(),
              _AnimalRuleType.url => const AnimalValidationIssue.url(),
              _ => const AnimalValidationIssue.pattern(),
            });
          }
          return null;

        case _AnimalRuleType.min:
          if (value == null) return null;
          // The min factory always sets _min.
          if (value is num && value < _min!) {
            return _issue(AnimalValidationIssue.minimum(_min));
          }
          return null;

        case _AnimalRuleType.max:
          if (value == null) return null;
          // The max factory always sets _max.
          if (value is num && value > _max!) {
            return _issue(AnimalValidationIssue.maximum(_max));
          }
          return null;

        case _AnimalRuleType.length:
          if (value == null) return null;
          int len = 0;
          if (value is String) {
            len = value.characters.length;
          } else if (value is Iterable) {
            len = value.length;
          } else if (value is Map) {
            len = value.length;
          }
          if (_minLength != null && _maxLength != null) {
            if (len < _minLength || len > _maxLength) {
              return _issue(
                AnimalValidationIssue.lengthRange(_minLength, _maxLength),
              );
            }
          } else if (_minLength != null && len < _minLength) {
            return _issue(AnimalValidationIssue.minimumLength(_minLength));
          } else if (_maxLength != null && len > _maxLength) {
            return _issue(AnimalValidationIssue.maximumLength(_maxLength));
          }
          return null;

        case _AnimalRuleType.custom:
          // The custom factory always sets _customValidator.
          final res = _customValidator!(value);
          if (res is Future<String?>) {
            return _mapCustomResult(res);
          }
          return res == null ? null : AnimalValidationIssue.literal(res);
      }
    } catch (_) {
      return const AnimalValidationIssue.validationFailure();
    }
  }

  AnimalValidationIssue _issue(AnimalValidationIssue builtIn) =>
      _message == null ? builtIn : AnimalValidationIssue.literal(_message);

  Future<AnimalValidationIssue?> _mapCustomResult(
    Future<String?> result,
  ) async {
    try {
      final message = await result;
      return message == null ? null : AnimalValidationIssue.literal(message);
    } catch (_) {
      return const AnimalValidationIssue.validationFailure();
    }
  }
}
