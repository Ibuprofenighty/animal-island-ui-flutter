import '../palette.dart';

/// Avatar colour recipe (fixed reference surface in every theme).
abstract final class AvatarColors {
  static const fill = Primitive.teal967;
  static const ring = Primitive.neutral977;
  static const text = Primitive.brown466;

  /// Reference icon artwork keeps its own near-black ink (12:1+ on [fill]).
  static const icon = Primitive.neutral285;
}
