/// The closed set of built-in validation failures supported by Animal Island UI.
enum AnimalValidationIssueKind {
  /// A required value is missing or empty.
  requiredField,

  /// The value is not a valid email address.
  email,

  /// The value is not a valid HTTP or HTTPS URL.
  url,

  /// The value does not match a required pattern.
  pattern,

  /// The value is below [AnimalValidationIssue.number].
  minimum,

  /// The value is above [AnimalValidationIssue.number].
  maximum,

  /// The value is shorter than [AnimalValidationIssue.lowerLength].
  minimumLength,

  /// The value is longer than [AnimalValidationIssue.upperLength].
  maximumLength,

  /// The value's length is outside [AnimalValidationIssue.lowerLength] to
  /// [AnimalValidationIssue.upperLength] inclusive.
  lengthRange,

  /// Caller-provided text in [AnimalValidationIssue.literalText].
  literal,

  /// A validator threw before it could produce a result.
  validationFailure,
}

/// Locale-neutral validation result stored by forms until it is rendered.
///
/// This value deliberately contains no translated default copy. A [literal]
/// issue is reserved for caller-provided custom text; all built-in issues are
/// formatted using the active localization at presentation time.
final class AnimalValidationIssue {
  /// Category of the failure, which selects the localized message.
  final AnimalValidationIssueKind kind;

  /// Numeric bound for [AnimalValidationIssueKind.minimum] and
  /// [AnimalValidationIssueKind.maximum]; null for other kinds.
  final num? number;

  /// Minimum length for [AnimalValidationIssueKind.minimumLength] and
  /// [AnimalValidationIssueKind.lengthRange]; null for other kinds.
  final int? lowerLength;

  /// Maximum length for [AnimalValidationIssueKind.maximumLength] and
  /// [AnimalValidationIssueKind.lengthRange]; null for other kinds.
  final int? upperLength;

  /// Caller-provided message for [AnimalValidationIssueKind.literal]; null for
  /// other kinds.
  final String? literalText;

  const AnimalValidationIssue._(
    this.kind, {
    this.number,
    this.lowerLength,
    this.upperLength,
    this.literalText,
  });

  /// Creates an [AnimalValidationIssueKind.requiredField] issue.
  const AnimalValidationIssue.required()
    : this._(AnimalValidationIssueKind.requiredField);

  /// Creates an [AnimalValidationIssueKind.email] issue.
  const AnimalValidationIssue.email() : this._(AnimalValidationIssueKind.email);

  /// Creates an [AnimalValidationIssueKind.url] issue.
  const AnimalValidationIssue.url() : this._(AnimalValidationIssueKind.url);

  /// Creates an [AnimalValidationIssueKind.pattern] issue.
  const AnimalValidationIssue.pattern()
    : this._(AnimalValidationIssueKind.pattern);

  /// Creates an [AnimalValidationIssueKind.minimum] issue for the bound [value].
  const AnimalValidationIssue.minimum(num value)
    : this._(AnimalValidationIssueKind.minimum, number: value);

  /// Creates an [AnimalValidationIssueKind.maximum] issue for the bound [value].
  const AnimalValidationIssue.maximum(num value)
    : this._(AnimalValidationIssueKind.maximum, number: value);

  /// Creates an [AnimalValidationIssueKind.minimumLength] issue for the
  /// minimum length [value].
  const AnimalValidationIssue.minimumLength(int value)
    : this._(AnimalValidationIssueKind.minimumLength, lowerLength: value);

  /// Creates an [AnimalValidationIssueKind.maximumLength] issue for the
  /// maximum length [value].
  const AnimalValidationIssue.maximumLength(int value)
    : this._(AnimalValidationIssueKind.maximumLength, upperLength: value);

  /// Creates an [AnimalValidationIssueKind.lengthRange] issue for the inclusive
  /// length range [minimum] to [maximum].
  const AnimalValidationIssue.lengthRange(int minimum, int maximum)
    : this._(
        AnimalValidationIssueKind.lengthRange,
        lowerLength: minimum,
        upperLength: maximum,
      );

  /// Creates an [AnimalValidationIssueKind.literal] issue that displays [text]
  /// verbatim.
  const AnimalValidationIssue.literal(String text)
    : this._(AnimalValidationIssueKind.literal, literalText: text);

  /// Creates an [AnimalValidationIssueKind.validationFailure] issue.
  const AnimalValidationIssue.validationFailure()
    : this._(AnimalValidationIssueKind.validationFailure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalValidationIssue &&
          kind == other.kind &&
          number == other.number &&
          lowerLength == other.lowerLength &&
          upperLength == other.upperLength &&
          literalText == other.literalText;

  @override
  int get hashCode =>
      Object.hash(kind, number, lowerLength, upperLength, literalText);
}
