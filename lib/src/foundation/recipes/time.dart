import 'dart:ui';

import '../palette.dart';

/// Time (clock card and game HUD) colour recipe.
abstract final class TimeColors {
  static const surface = Primitive.neutral977;
  static const shadow = Primitive.brown331A6;

  /// Reference `--animal-time-color` #8b7355 (4.0–4.5:1 on the light papers,
  /// the card and the capsule) deepened in hue to 4.5:1: the card clock and
  /// the game weekday on its capsule.
  static const digits = Primitive.brown544;
  static const datePill = Primitive.teal967;

  /// Game clock and month-day on the host paper: [digits] on light papers;
  /// on dark papers the reference (2.7–3.3:1) lightens in hue to 4.5:1.
  static Color gameText(Brightness brightness) =>
      brightness == Brightness.dark ? Primitive.brown707 : digits;

  /// Game variant weekday capsule (reference #fffbe7).
  static const gameWeekdayPill = Primitive.sand986;

  /// Game variant decorative rule (reference rgba(159, 146, 125, .35)).
  static const gameDivider = Primitive.sand666A35;
}
