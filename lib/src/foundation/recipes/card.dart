import '../palette.dart';

/// Card default recipe for neutral surfaces; colorway accents and papers come
/// from IslandColorway data. Instance/theme styles override every role.
abstract final class CardColors {
  static const neutral = Primitive.sand962;
  static const neutralDashed = Primitive.neutral979;
  static const border = Primitive.sand899;
  static const divider = Primitive.sand899;

  /// Dashed hover border and the neutral pattern contour.
  static const accentBorder = Primitive.sand826;

  /// Neutral pattern large dot base (alpha applied by the component).
  static const neutralDot = Primitive.sand786;
}
