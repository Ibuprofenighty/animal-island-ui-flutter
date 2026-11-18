import 'dart:ui';

import '../palette.dart';

/// Chart colour recipe, resolved by the host theme brightness.
///
/// Light is the reference 4.0.0 `chart.module.less` over the reference default
/// theme variables (`--animal-bg-color` #f8f8f0, `--animal-text-color`
/// #794f27, `--animal-text-color-secondary` #9f927d, `--animal-border-color-light`
/// #e8e2d6, `--animal-bg-color-secondary` #f0e8d8, `--animal-primary-color`
/// #19c8b9). Dark maps the same variables onto the dark product roles.
/// Values failing text 4.5:1 or necessary-graphic 3:1 on the chart surface
/// move along OKLCH lightness in their own hue only until they pass (DESIGN.md
/// measured colour differences); decorative grid, zero line, crosshair, gauge
/// ticks/track, separators and the empty map region keep the reference.
final class ChartColors {
  const ChartColors._({
    required this.surface,
    required this.border,
    required this.ink,
    required this.secondaryInk,
    required this.grid,
    required this.zero,
    required this.crosshair,
    required this.legendFill,
    required this.legendHover,
    required this.legendHiddenInk,
    required this.focus,
    required this.needle,
    required this.candleRise,
    required this.candleFall,
    required this.scrollbar,
    required this.series,
  });

  /// Container, tooltip and indicator fill (`--animal-bg-color`).
  final Color surface;

  /// Container border, grid lines and table/tooltip rules
  /// (`--animal-border-color-light`).
  final Color border;

  /// Title, legend, tooltip, value labels and data table text.
  final Color ink;

  /// Description, axis text, ring centre, summary, loading and notes. The
  /// reference #9f927d is 2.9:1 on #f8f8f0; light deepens it to #7d705c.
  final Color secondaryInk;

  /// Dashed grid (decorative).
  final Color grid;

  /// Zero baseline (`--animal-text-color-disabled`, decorative).
  final Color zero;

  /// Crosshair guide, painted at the reference 0.55 stroke opacity.
  final Color crosshair;

  /// Legend and release pill fill (`--animal-bg-color-secondary`).
  final Color legendFill;

  /// Legend and release pill hover fill.
  final Color legendHover;

  /// Hidden legend label. The reference halves the whole pill (2.2:1); the
  /// pill keeps the half opacity and the label takes this opaque ink.
  final Color legendHiddenInk;

  /// Focus outline (reference primary #19c8b9, 2.0:1 on light; deepened).
  final Color focus;

  /// Gauge needle and hub (reference #725d42, 1.9:1 on dark; lightened).
  final Color needle;

  /// Rising candle (reference coral #dc7367, 2.94:1 on light; deepened).
  final Color candleRise;

  /// Falling candle (reference mint #3b9d85).
  final Color candleFall;

  /// Plot viewport scrollbar thumb on a transparent track (reference
  /// `.viewport` `scrollbar-color: var(--animal-text-color-disabled)`,
  /// #c4b89e; a decorative scroll affordance).
  final Color scrollbar;

  /// Default series/item palette in reference order: mint, peach, green,
  /// purple, yellow, blue, pink, brown. Light deepens the seven values below
  /// 3:1 on #f8f8f0; dark keeps the reference (all ≥ 3.2:1).
  final List<Color> series;

  /// Sector, point and region separators (#fffdf7, decorative).
  static const separator = Primitive.neutral994;

  /// Arc/gauge track and regions without data (#eae2ce, decorative).
  static const track = Primitive.sand913;

  /// Gauge scale ticks (#b6a184, decorative).
  static const gaugeTick = Primitive.sand720;

  /// Tooltip shadow `0 4px 14px rgba(61,52,40,.16)`.
  static const tooltipShadow = Primitive.brown331A16;

  /// Active mark drop shadow `0 2px 3px rgba(61,52,40,.18)`.
  static const activeShadow = Primitive.brown331A18;

  static const light = ChartColors._(
    surface: Primitive.neutral977,
    border: Primitive.sand914,
    ink: Primitive.brown466,
    secondaryInk: Primitive.sand552,
    grid: Primitive.sand914,
    zero: Primitive.sand786,
    crosshair: Primitive.sand666,
    legendFill: Primitive.sand933,
    legendHover: Primitive.sand914,
    legendHiddenInk: Primitive.brown538,
    focus: Primitive.teal638,
    needle: Primitive.brown492,
    candleRise: Primitive.red667,
    candleFall: Primitive.teal632,
    scrollbar: Primitive.sand786,
    series: [
      Primitive.teal637,
      Primitive.orange661,
      Primitive.green641,
      Primitive.violet664,
      Primitive.yellow654,
      Primitive.blue650,
      Primitive.red664,
      Primitive.brown621,
    ],
  );

  static const dark = ChartColors._(
    surface: Primitive.teal333,
    border: Primitive.green730A35,
    ink: Primitive.sand956,
    secondaryInk: Primitive.green810,
    grid: Primitive.green730A35,
    zero: Primitive.green730,
    crosshair: Primitive.green810,
    legendFill: Primitive.teal270,
    legendHover: Primitive.green316,
    legendHiddenInk: Primitive.green810,
    focus: Primitive.teal750,
    needle: Primitive.brown603,
    candleRise: Primitive.red673,
    candleFall: Primitive.teal632,
    scrollbar: Primitive.green730,
    series: [
      Primitive.teal702,
      Primitive.orange736,
      Primitive.green770,
      Primitive.violet699,
      Primitive.yellow803,
      Primitive.blue691,
      Primitive.red727,
      Primitive.brown621,
    ],
  );

  static ChartColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
