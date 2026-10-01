/// The closed set of built-in validation failures supported by Animal Island UI.
enum AnimalValidationIssueKind {
  requiredField,
  email,
  url,
  pattern,
  minimum,
  maximum,
  minimumLength,
  maximumLength,
  lengthRange,
  literal,
  validationFailure,
}

/// Locale-neutral validation result stored by forms until it is rendered.
///
/// This value deliberately contains no translated default copy. A [literal]
/// issue is reserved for caller-provided custom text; all built-in issues are
/// formatted using the active localization at presentation time.
final class AnimalValidationIssue {
  final AnimalValidationIssueKind kind;
  final num? number;
  final int? lowerLength;
  final int? upperLength;
  final String? literalText;

  const AnimalValidationIssue._(
    this.kind, {
    this.number,
    this.lowerLength,
    this.upperLength,
    this.literalText,
  });

  const AnimalValidationIssue.required()
    : this._(AnimalValidationIssueKind.requiredField);

  const AnimalValidationIssue.email() : this._(AnimalValidationIssueKind.email);

  const AnimalValidationIssue.url() : this._(AnimalValidationIssueKind.url);

  const AnimalValidationIssue.pattern()
    : this._(AnimalValidationIssueKind.pattern);

  const AnimalValidationIssue.minimum(num value)
    : this._(AnimalValidationIssueKind.minimum, number: value);

  const AnimalValidationIssue.maximum(num value)
    : this._(AnimalValidationIssueKind.maximum, number: value);

  const AnimalValidationIssue.minimumLength(int value)
    : this._(AnimalValidationIssueKind.minimumLength, lowerLength: value);

  const AnimalValidationIssue.maximumLength(int value)
    : this._(AnimalValidationIssueKind.maximumLength, upperLength: value);

  const AnimalValidationIssue.lengthRange(int minimum, int maximum)
    : this._(
        AnimalValidationIssueKind.lengthRange,
        lowerLength: minimum,
        upperLength: maximum,
      );

  const AnimalValidationIssue.literal(String text)
    : this._(AnimalValidationIssueKind.literal, literalText: text);

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
