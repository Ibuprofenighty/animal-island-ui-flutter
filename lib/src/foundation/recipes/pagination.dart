import '../palette.dart';

/// Pagination colour recipe: teal/sun item fills, jumper and size menu.
abstract final class PaginationColors {
  static const text = Primitive.brown492;

  // Page items: selected rest/hover fills and the unselected hover tint.
  static const tealSelected = Primitive.teal750;
  static const tealSelectedHover = Primitive.teal790;
  static const tealHover = Primitive.teal967;
  static const sunSelected = Primitive.yellow844;
  static const sunSelectedHover = Primitive.yellow820;
  static const sunHover = Primitive.yellow886;
  static const disabledInk = Primitive.sand839;

  // Quick jumper field.
  static const jumperFill = Primitive.sand986;
  static const jumperFillDisabled = Primitive.sand931;

  // Size trigger (lerps rest → hover) and its yellow menu.
  static const sizeTrigger = Primitive.neutral1000;
  static const sizeTriggerHover = Primitive.neutral994;
  static const sizeTriggerDisabled = Primitive.neutral969;
  static const sizeMenu = Primitive.yellow945;
  static const sizeMenuShadow = Primitive.brown331A12;
  static const sizeSelectedPill = Primitive.yellow866A30;
}
