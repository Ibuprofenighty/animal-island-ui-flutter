import '../palette.dart';

/// CountUp celebration colour recipe.
abstract final class CountUpColors {
  static const badgeTop = Primitive.yellow914;
  static const badgeBottom = Primitive.yellow865;
  static const badgeBorder = Primitive.yellow795;
  static const badgeShadow = Primitive.brown331A18;

  /// Expanding rings (the second is the reference rgba(255,204,0,.7)).
  static const ringFirst = Primitive.yellow865A85;
  static const ringSecond = Primitive.yellow866A70;

  /// Sparkle fill; its alpha follows the keyframes.
  static const sparkle = Primitive.yellow865;
}
