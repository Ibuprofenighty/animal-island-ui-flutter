import '../palette.dart';

/// Upload colour recipe (fixed light surfaces over arbitrary thumbnails).
abstract final class UploadColors {
  static const previewBarrier = Primitive.neutral157A82;

  /// Drop zone, list rows, cards and the action discs share one paper and
  /// one hover/active tint. Card drop zones fade from a transparent tint.
  static const surface = Primitive.neutral994;
  static const hoverFill = Primitive.teal967;
  static const cardZoneRest = Primitive.teal967A0;
  static const border = Primitive.sand899;
  static const errorRowFill = Primitive.red961;
  static const fileName = Primitive.brown466;

  /// Opaque status backing over a card thumbnail.
  static const cardOverlay = Primitive.neutral157A55;

  // Raised upload button.
  static const button = Primitive.neutral977;
  static const buttonLabel = Primitive.brown466;
  static const buttonDepth = Primitive.brown760;
  static const buttonDepthDisabled = Primitive.brown839;

  static const progressTrack = Primitive.teal967;
}
