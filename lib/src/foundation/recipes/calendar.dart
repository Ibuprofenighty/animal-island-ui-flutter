import 'dart:ui';

import '../palette.dart';

/// Border, fill and ink of one event bar palette.
final class CalendarEventColors {
  const CalendarEventColors({
    required this.border,
    required this.fill,
    required this.ink,
  });
  final Color border, fill, ink;
}

/// Calendar recipe: the reference 4.0.0 `calendar.module.less` values on a
/// fixed light panel in every theme. Values below the contrast budget are
/// kept as the reference pending an owner decision (DESIGN.md measured colour
/// differences): weekday #a09080 (3.0:1), neighbouring-month digits #c4b89e
/// (1.9:1), accent digit/ring/focus #19c8b9 (2.1:1), white selected digit
/// (2.1:1), +N (1.9:1), event time #9f927d (2.5–2.8:1), teal-set title
/// #b04a1f (4.48:1), arrows #a0936e (2.9:1 on #faf8f3) and 今天 #8a7b66
/// (3.9:1 on #faf8f3).
abstract final class CalendarColors {
  static const accent = Primitive.teal750;
  static const accentSoft = Primitive.teal750A14;
  static const accentTint = Primitive.teal967;

  // Header.
  static const arrow = Primitive.sand665;
  static const controlHoverFill = Primitive.brown492A10;
  static const todayAction = Primitive.sand591;
  static const todayActionHover = Primitive.brown492;
  static const monthChipFill = Primitive.sand986;
  static const monthChipInk = Primitive.brown492;

  // Panel.
  static const panelFill = Primitive.neutral994;
  static const panelBorder = Primitive.sand899;
  static const panelShadow = Primitive.brown331A12;
  static const panelLargeDot = Primitive.sand786A15;
  static const panelSmallDot = Primitive.sand786A10;

  // Grid.
  static const weekday = Primitive.brown663;
  static const cellHoverFill = Primitive.sand955;
  static const day = Primitive.brown492;
  static const dayHover = Primitive.brown407;
  static const dayOutside = Primitive.sand786;
  static const daySelected = Primitive.neutral1000;

  // Event bars; `teal` is the reference warm orange set.
  static const eventTime = Primitive.sand666;
  static const teal = CalendarEventColors(
    border: Primitive.orange754A50,
    fill: Primitive.brown935,
    ink: Primitive.red537,
  );
  static const amber = CalendarEventColors(
    border: Primitive.yellow844A50,
    fill: Primitive.sand965,
    ink: Primitive.yellow541,
  );
  static const coral = CalendarEventColors(
    border: Primitive.red755A50,
    fill: Primitive.red945,
    ink: Primitive.red522,
  );
  static const green = CalendarEventColors(
    border: Primitive.green713A50,
    fill: Primitive.green957,
    ink: Primitive.green526,
  );
  static const purple = CalendarEventColors(
    border: Primitive.violet663A50,
    fill: Primitive.violet947,
    ink: Primitive.violet498,
  );
}
