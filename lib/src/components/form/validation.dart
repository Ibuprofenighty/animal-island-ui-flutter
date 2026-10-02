import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_validation_issue.dart';

/// Category of validation rule for [AnimalRule].
enum AnimalRuleType {
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
  final AnimalRuleType type;

  /// Optional caller-owned literal copy for this rule's failure.
  ///
  /// When omitted, evaluation returns a locale-neutral built-in issue that is
  /// formatted at the point of presentation.
  final String? message;

  /// Numeric minimum bound for [AnimalRuleType.min].
  final num? min;

  /// Numeric maximum bound for [AnimalRuleType.max].
  final num? max;

  /// Character/collection length minimum for [AnimalRuleType.length].
  final int? minLength;

  /// Character/collection length maximum for [AnimalRuleType.length].
  final int? maxLength;

  /// Regular expression pattern for [AnimalRuleType.pattern].
  final RegExp? pattern;

  /// Custom validation function for [AnimalRuleType.custom].
  final FutureOr<String?> Function(T? value)? customValidator;

  const AnimalRule._({
    required this.type,
    this.message,
    this.min,
    this.max,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.customValidator,
  });

  /// Creates a rule requiring a non-null, non-empty value.
  factory AnimalRule.required({String? message}) =>
      AnimalRule._(type: AnimalRuleType.required, message: message);

  /// Creates a rule validating standard email syntax.
  factory AnimalRule.email({String? message}) => AnimalRule._(
    type: AnimalRuleType.email,
    message: message,
    pattern: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
  );

  /// Creates a rule validating standard HTTP/HTTPS URL syntax.
  factory AnimalRule.url({String? message}) => AnimalRule._(
    type: AnimalRuleType.url,
    message: message,
    pattern: RegExp(r'^(https?:\/\/)[^\s/$.?#].[^\s]*$', caseSensitive: false),
  );

  /// Creates a rule matching string representations against [pattern].
  factory AnimalRule.pattern(RegExp pattern, {String? message}) => AnimalRule._(
    type: AnimalRuleType.pattern,
    message: message,
    pattern: pattern,
  );

  /// Creates a numeric rule requiring value >= [min].
  factory AnimalRule.min(num min, {String? message}) =>
      AnimalRule._(type: AnimalRuleType.min, message: message, min: min);

  /// Creates a numeric rule requiring value <= [max].
  factory AnimalRule.max(num max, {String? message}) =>
      AnimalRule._(type: AnimalRuleType.max, message: message, max: max);

  /// Creates a length rule requiring character or item length within [[min], [max]].
  factory AnimalRule.length({int? min, int? max, String? message}) {
    if (min == null && max == null) {
      throw ArgumentError('At least one of min or max must be provided.');
    }
    return AnimalRule._(
      type: AnimalRuleType.length,
      message: message,
      minLength: min,
      maxLength: max,
    );
  }

  /// Creates a custom rule evaluated via [validator].
  factory AnimalRule.custom(FutureOr<String?> Function(T? value) validator) =>
      AnimalRule._(type: AnimalRuleType.custom, customValidator: validator);

  /// Evaluates this rule against [value].
  ///
  /// Returns a locale-neutral issue when invalid. Caller-provided custom
  /// messages are represented as literal issues; default copy is resolved later.
  FutureOr<AnimalValidationIssue?> evaluate(T? value) {
    try {
      switch (type) {
        case AnimalRuleType.required:
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

        case AnimalRuleType.email:
        case AnimalRuleType.url:
        case AnimalRuleType.pattern:
          if (value == null || (value is String && value.isEmpty)) return null;
          final str = value.toString();
          if (pattern != null && !pattern!.hasMatch(str)) {
            return _issue(switch (type) {
              AnimalRuleType.email => const AnimalValidationIssue.email(),
              AnimalRuleType.url => const AnimalValidationIssue.url(),
              _ => const AnimalValidationIssue.pattern(),
            });
          }
          return null;

        case AnimalRuleType.min:
          if (value == null) return null;
          if (value is num && min != null && value < min!) {
            return _issue(AnimalValidationIssue.minimum(min!));
          }
          return null;

        case AnimalRuleType.max:
          if (value == null) return null;
          if (value is num && max != null && value > max!) {
            return _issue(AnimalValidationIssue.maximum(max!));
          }
          return null;

        case AnimalRuleType.length:
          if (value == null) return null;
          int len = 0;
          if (value is String) {
            len = value.characters.length;
          } else if (value is Iterable) {
            len = value.length;
          } else if (value is Map) {
            len = value.length;
          }
          if (minLength != null && maxLength != null) {
            if (len < minLength! || len > maxLength!) {
              return _issue(
                AnimalValidationIssue.lengthRange(minLength!, maxLength!),
              );
            }
          } else if (minLength != null && len < minLength!) {
            return _issue(AnimalValidationIssue.minimumLength(minLength!));
          } else if (maxLength != null && len > maxLength!) {
            return _issue(AnimalValidationIssue.maximumLength(maxLength!));
          }
          return null;

        case AnimalRuleType.custom:
          if (customValidator == null) return null;
          final res = customValidator!(value);
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
      message == null ? builtIn : AnimalValidationIssue.literal(message!);

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
