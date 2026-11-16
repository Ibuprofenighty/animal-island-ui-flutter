import '../palette.dart';

/// Tag colour recipe for the neutral solid variant and shared states; per-hue
/// roles come from IslandColorway data (outlineInk/outlineBorder).
abstract final class TagColors {
  static const neutralSolidFill = Primitive.sand962;
  static const neutralSolidBorder = Primitive.sand826;
  static const hoverShadow = Primitive.brown331A12;

  /// Reference resting close disc rgb(149 143 143 / 8%).
  static const closeDisc = Primitive.neutral655A8;
}
