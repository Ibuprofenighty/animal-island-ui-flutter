import '../palette.dart';

/// Time (clock card and game HUD) colour recipe.
abstract final class TimeColors {
  static const surface = Primitive.neutral977;
  static const shadow = Primitive.brown331A6;

  /// Reference `--animal-time-color` #8b7355, the clock of both variants.
  static const digits = Primitive.brown571;
  static const datePill = Primitive.teal967;

  /// Game variant month-day and weekday ink (reference literal #8b7355).
  static const gameText = Primitive.brown571;

  /// Game variant weekday capsule (reference #fffbe7).
  static const gameWeekdayPill = Primitive.sand986;

  /// Game variant decorative rule (reference rgba(159, 146, 125, .35)).
  static const gameDivider = Primitive.sand666A35;
}
