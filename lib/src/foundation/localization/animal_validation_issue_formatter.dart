import '../forms/animal_validation_issue.dart';
import 'generated/animal_localizations.g.dart';

/// Converts one locale-neutral validation issue into text for the active locale.
class AnimalValidationIssueFormatter {
  const AnimalValidationIssueFormatter._();

  static String format(
    AnimalValidationIssue issue,
    AnimalLocalizations localizations,
  ) => switch (issue.kind) {
    AnimalValidationIssueKind.requiredField => localizations.requiredField,
    AnimalValidationIssueKind.email => localizations.validationEmail,
    AnimalValidationIssueKind.url => localizations.validationUrl,
    AnimalValidationIssueKind.pattern => localizations.validationPattern,
    AnimalValidationIssueKind.minimum => localizations.validationMinimum(
      issue.number!,
    ),
    AnimalValidationIssueKind.maximum => localizations.validationMaximum(
      issue.number!,
    ),
    AnimalValidationIssueKind.minimumLength =>
      localizations.validationLengthMinimum(issue.lowerLength!),
    AnimalValidationIssueKind.maximumLength =>
      localizations.validationLengthMaximum(issue.upperLength!),
    AnimalValidationIssueKind.lengthRange =>
      localizations.validationLengthRange(
        issue.lowerLength!,
        issue.upperLength!,
      ),
    AnimalValidationIssueKind.literal => issue.literalText!,
    AnimalValidationIssueKind.validationFailure =>
      localizations.validationFailure,
  };
}
