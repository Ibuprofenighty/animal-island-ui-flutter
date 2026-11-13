import '../palette.dart';

/// Progress colour recipe.
abstract final class ProgressColors {
  static const track = Primitive.neutral977;
  static const trackDot = Primitive.sand786A10;

  /// In-progress fill gradient (stops 0, .6, 1) and the complete gradient.
  static const fillTop = Primitive.teal790;
  static const fillMiddle = Primitive.teal750;
  static const fillBottom = Primitive.teal699;
  static const completeTop = Primitive.teal844;
  static const completeBottom = Primitive.teal790;
  static const highlight = Primitive.neutral1000A45;

  /// The reference fill (#19c8b9, 1.9:1 on the track) needs a 3:1 edge:
  /// the same hue, OKLCH-deepened.
  static const fillEdge = Primitive.teal626;
}
