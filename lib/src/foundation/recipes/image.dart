import '../palette.dart';

/// Image colour recipe: frames, preview chrome and shadows.
abstract final class ImageColors {
  static const previewBarrier = Primitive.neutral0A55;
  static const previewShadow = Primitive.brown257A55;

  /// Preview close control, its hover fill and focus backing.
  static const closeFill = Primitive.neutral893;
  static const closeHoverFill = Primitive.neutral834;
  static const closeBorder = Primitive.neutral1000A75;

  static const stampPaper = Primitive.neutral984;

  /// Polaroid frame without a colorway.
  static const framePaper = Primitive.neutral1000;

  /// Stamp year: reference white .88 and its rgba(0,0,0,.55) text shadow,
  /// over a glyph backing at the least alpha (.58) that keeps 4.5:1 over any
  /// photo pixel.
  static const stampYear = Primitive.neutral1000A88;
  static const stampYearBacking = Primitive.neutral0A58;
  static const stampYearShadow = Primitive.neutral0A55;

  // Normal-variant layered shadow, then the framed-variant shadow.
  static const normalShadowKey = Primitive.violet340A25;
  static const normalShadowAmbient = Primitive.neutral0A30;
  static const normalShadowTop = Primitive.neutral0A3;
  static const frameShadow = Primitive.neutral0A8;

  static const halftoneDot = Primitive.violet187A8;
}
