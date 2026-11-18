import '../palette.dart';

/// Drawer colour recipe (fixed light panel).
abstract final class DrawerColors {
  /// IslandDrawerHost default backplane exposed when the page recedes.
  static const hostBackplane = Primitive.neutral1000;
  static const panel = Primitive.sand962;
  static const panelShadow = Primitive.brown331A18;
  static const title = Primitive.brown492;

  /// Close glyph at rest: reference rgba(114, 93, 66, .6), #a79981 on the
  /// panel (2.5:1), deepened in hue to 3:1; hover darkens to [closeHover].
  static const close = Primitive.sand642;
  static const closeHover = Primitive.brown492;
  static const closeHoverFill = Primitive.brown492A10;

  /// Mask base; its alpha follows the mask motion (reference .18).
  static const mask = Primitive.neutral0;
}
