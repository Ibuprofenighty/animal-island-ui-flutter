import 'package:flutter/widgets.dart';
import 'colors.dart';
import 'theme.dart';

/// Typography tokens for Animal Island UI.
///
/// Strictly adheres to the canonical design rules:
/// - Nunito (Latin) & Noto Sans SC (CJK) rounded typography
/// - Body weight: 500 (never light)
/// - Buttons and headings: 600–700
/// - Countdown digits and Title ribbons: 900
/// - Never below 400 anywhere
abstract final class AnimalTypography {
  static const String fontFamily = 'Nunito';
  static const List<String> fontFamilyFallback = ['Noto Sans SC', 'sans-serif'];

  /// Large title ribbon style (weight 900)
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AnimalColors.text,
    height: 1.2,
  );

  /// Standard section header (weight 700)
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AnimalColors.text,
    height: 1.3,
  );

  /// Subheading (weight 600)
  static const TextStyle subheading = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AnimalColors.text,
    height: 1.4,
  );

  /// Button label typography (weight 700)
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.2,
  );

  /// Regular body text (weight 500)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AnimalColors.textBody,
    height: 1.5,
  );

  /// Small caption / secondary text (weight 500)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AnimalColors.textSecondary,
    height: 1.4,
  );

  /// Big Countdown digit style (weight 900)
  static const TextStyle countdown = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AnimalColors.text,
    height: 1.0,
  );

  /// Button typography with theme awareness
  static TextStyle buttonFor(BuildContext context) =>
      button.copyWith(color: AnimalIslandTheme.of(context).text);

  /// Countdown typography with theme awareness
  static TextStyle countdownFor(BuildContext context) =>
      countdown.copyWith(color: AnimalIslandTheme.of(context).text);

  /// Theme-aware typography helpers
  static TextStyle titleFor(BuildContext context) =>
      title.copyWith(color: AnimalIslandTheme.of(context).text);

  static TextStyle headingFor(BuildContext context) =>
      heading.copyWith(color: AnimalIslandTheme.of(context).text);

  static TextStyle subheadingFor(BuildContext context) =>
      subheading.copyWith(color: AnimalIslandTheme.of(context).text);

  static TextStyle bodyFor(BuildContext context) =>
      body.copyWith(color: AnimalIslandTheme.of(context).textBody);

  static TextStyle captionFor(BuildContext context) =>
      caption.copyWith(color: AnimalIslandTheme.of(context).textSecondary);
}
