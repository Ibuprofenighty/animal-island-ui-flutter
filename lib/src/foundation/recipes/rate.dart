import 'dart:ui';

import '../palette.dart';

/// Rate colour recipe. Brightness is the host theme brightness.
abstract final class RateColors {
  /// Reference selected stroke #dba90e: kept on dark paper (5.5:1); on light
  /// papers (1.9:1) the same hue is OKLCH-deepened to 3:1.
  static Color selectedStroke(Brightness brightness) =>
      brightness == Brightness.dark ? Primitive.yellow760 : Primitive.yellow642;

  /// Reference unselected stroke #c4b89e: kept on dark paper (6.0:1); 1.8:1
  /// on light papers, deepened in hue.
  static Color idleStroke(Brightness brightness) =>
      brightness == Brightness.dark ? Primitive.sand786 : Primitive.sand641;

  static const starFill = Primitive.yellow838;
  static const splash = Primitive.yellow838;

  /// Reference `.icon circle { fill: var(--animal-text-color) }` with the
  /// inherited `.active` stroke #dba90e painted over it, so the eyes read as
  /// faint tonal dots. Decorative: they keep the reference stroke even where
  /// the star outline deepens for contrast.
  static const eyeFill = Primitive.brown466;
  static const eyeStroke = Primitive.yellow760;
}
