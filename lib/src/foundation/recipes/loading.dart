import '../palette.dart';

/// Loading (night snow / circle reveal) colour recipe.
abstract final class LoadingColors {
  static const night = Primitive.blue173;
  static const text = Primitive.neutral977;
  static const textShadow = Primitive.neutral0A60;

  /// Snowflake base; its alpha follows the fade motion.
  static const snow = Primitive.neutral1000;
  static const vignetteInner = Primitive.blue144A0;
  static const vignetteOuter = Primitive.blue144A60;

  /// Circle-form sailboat outline (reference root stroke `#2A2A2A`); the
  /// sails, hull and water keep the glyph's own artwork colours.
  static const boatInk = Primitive.neutral285;

  /// Sailboat water line (reference `Sailboat.tsx` wave stroke `#2A9D8F`,
  /// decorative).
  static const water = Primitive.teal630;
}
