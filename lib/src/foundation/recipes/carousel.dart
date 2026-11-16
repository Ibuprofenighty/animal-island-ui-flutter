import '../palette.dart';

/// Carousel colour recipe: the fixed pale slide backplane and white controls.
abstract final class CarouselColors {
  static const slideBackplane = Primitive.sand962;

  /// Arrow, indicator pill and play/pause control fill; also the opaque
  /// backing behind a focused control's outline.
  static const control = Primitive.neutral1000;
  static const controlBorder = Primitive.brown466A16;
  static const controlShadow = Primitive.brown331A6;

  /// Control glyph/label ink at rest; it tints to the light link on hover.
  static const controlInk = Primitive.brown466;
}
