import '../palette.dart';

/// Table colour recipe (fixed light surface).
abstract final class TableColors {
  static const surface = Primitive.sand962;
  static const loadingBackplane = Primitive.sand962;

  /// Loading spinner: reference `#19c8b9` (1.9:1 on the backplane) deepened
  /// in hue to 3:1, the registered Progress edge value `#039d91` (3.02:1).
  static const spinner = Primitive.teal626;
  static const text = Primitive.brown492;
  static const rowHover = Primitive.teal935;
  static const rowStripe = Primitive.neutral977A60;
  static const rowRule = Primitive.sand933;
}
