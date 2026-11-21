import 'dart:ui';

import '../palette.dart';
import '../theme.dart';

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
/// fixed light panel in every theme, measured per docs/DESIGN.md (measured
/// colour differences). In the panel the weekday header (#a09080), the
/// neighbouring-month digits (#c4b89e), today (#19c8b9), the selected digit
/// (white), +N and the focus ring take the DatePicker roles
/// [IslandTokens.light] `muted`, `link`, `onLeaf` and `focus`; the selected
/// disc, its cell tint and the month icon keep the reference accent set.
/// The header sits on the host paper and resolves per brightness.
abstract final class CalendarColors {
  static const accent = Primitive.teal750;
  static const accentSoft = Primitive.teal750A14;
  static const accentTint = Primitive.teal967;

  // Header on the host paper.

  /// Reference #a0936e: kept on dark papers (3.9:1); 2.7–3.0:1 on light
  /// papers, so light hosts take the DatePicker chevron role `muted`.
  static Color arrow(Brightness brightness) => brightness == Brightness.dark
      ? Primitive.sand665
      : IslandTokens.light.muted;

  /// Reference hover accent #19c8b9: kept on dark papers (5.4:1 on the hover
  /// fill); 1.7–1.8:1 on light hover fills, so light hosts take `link`.
  static Color arrowHover(Brightness brightness) =>
      brightness == Brightness.dark ? accent : IslandTokens.light.link;

  /// Reference focus ring #19c8b9: kept on dark papers (5.7:1); light hosts
  /// take the `focus` role (2.1:1 otherwise).
  static Color headerFocus(Brightness brightness) =>
      brightness == Brightness.dark ? accent : IslandTokens.light.focus;

  /// Reference 今天 #8a7b66: 3.7–4.1:1 on light papers, so light hosts take
  /// `muted`; 2.9:1 on dark papers, lightened in hue to 4.5:1.
  static Color todayAction(Brightness brightness) =>
      brightness == Brightness.dark
      ? Primitive.sand706
      : IslandTokens.light.muted;

  /// Reference hover #725d42: kept on light hover fills (4.9:1); 1.8:1 on
  /// dark hover fills, lightened in hue to 4.5:1.
  static Color todayActionHover(Brightness brightness) =>
      brightness == Brightness.dark ? Primitive.brown722 : Primitive.brown492;

  static const controlHoverFill = Primitive.brown492A10;
  static const monthChipFill = Primitive.sand986;
  static const monthChipInk = Primitive.brown492;

  // Panel.
  static const panelFill = Primitive.neutral994;
  static const panelBorder = Primitive.sand899;
  static const panelShadow = Primitive.brown331A12;
  static const panelLargeDot = Primitive.sand786A15;
  static const panelSmallDot = Primitive.sand786A10;

  // Grid.
  static const cellHoverFill = Primitive.sand955;
  static const day = Primitive.brown492;
  static const dayHover = Primitive.brown407;

  /// Event start time: reference #9f927d (2.5–2.8:1 on the five fills)
  /// deepened in hue to 4.5:1 on every fill.
  static const eventTime = Primitive.sand520;

  /// Event bars; `teal` is the reference warm orange set, whose title ink
  /// #b04a1f (4.48:1 on #ffe4cc) is deepened in hue to 4.5:1.
  static const teal = CalendarEventColors(
    border: Primitive.orange754A50,
    fill: Primitive.brown935,
    ink: Primitive.red535,
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
