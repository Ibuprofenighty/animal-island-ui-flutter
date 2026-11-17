import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../theme.dart';

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

/// The resolved paint and spacing roles of one Time: an explicit caller
/// value wins over the recipe default of the variant and host brightness.
///
/// The card is a fixed light surface (reference `.time`): clock
/// [TimeColors.digits], weekday `--animal-primary-color` as the light `link`
/// role, month-day and dot `--animal-text-color-secondary` as the light
/// `muted` role, the teal capsule, 20/32/15 padding and the 20px soft-shadow
/// surface. The game HUD has no surface and 50px padding; its clock and
/// month-day read on the host paper ([TimeColors.gameText]), its weekday
/// sits on the cream capsule in [TimeColors.digits].
final class TimeRoles {
  const TimeRoles._({
    required this.clock,
    required this.weekday,
    required this.date,
    required this.separator,
    required this.capsule,
    required this.decoration,
    required this.padding,
    required this.capsuleFontSize,
  });

  factory TimeRoles.resolve({
    required bool game,
    required Brightness brightness,
    Color? clock,
    Color? weekday,
    Color? date,
    Color? separator,
    Color? capsule,
    Decoration? decoration,
    EdgeInsetsGeometry? padding,
    double? capsuleFontSize,
  }) {
    if (game) {
      final hud = TimeColors.gameText(brightness);
      return TimeRoles._(
        clock: clock ?? hud,
        weekday: weekday ?? TimeColors.digits,
        date: date ?? hud,
        separator: separator ?? TimeColors.gameDivider,
        capsule: capsule ?? TimeColors.gameWeekdayPill,
        decoration: decoration,
        padding: padding ?? const EdgeInsets.all(50),
        capsuleFontSize: capsuleFontSize ?? 15,
      );
    }
    return TimeRoles._(
      clock: clock ?? TimeColors.digits,
      weekday: weekday ?? IslandTokens.light.link,
      date: date ?? IslandTokens.light.muted,
      separator: separator ?? IslandTokens.light.muted,
      capsule: capsule ?? TimeColors.datePill,
      decoration:
          decoration ??
          BoxDecoration(
            color: TimeColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: TimeColors.shadow,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
      padding: padding ?? const EdgeInsets.fromLTRB(32, 20, 32, 15),
      capsuleFontSize: capsuleFontSize ?? 12,
    );
  }

  /// Digits and blinking colon.
  final Color clock;

  /// Weekday text.
  final Color weekday;

  /// Month-day text.
  final Color date;

  /// Card `·` between weekday and month-day; game rule under the clock.
  final Color separator;

  /// Card date capsule; game weekday capsule.
  final Color capsule;

  /// Surface behind the content; null paints none.
  final Decoration? decoration;
  final EdgeInsetsGeometry padding;

  /// Card weekday · month-day; game weekday.
  final double capsuleFontSize;
}
