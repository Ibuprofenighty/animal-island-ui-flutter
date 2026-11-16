import '../palette.dart';

/// Notification colour recipe: per-type fill / border / icon disc, plus the
/// shared message ink, hover shadow and close control. Icon ink uses the
/// light semantic roles.
abstract final class NotificationColors {
  static const successFill = Primitive.green977;
  static const successBorder = Primitive.green713;
  static const successIconFill = Primitive.green923;
  static const infoFill = Primitive.teal972;
  static const infoBorder = Primitive.teal750;
  static const infoIconFill = Primitive.teal912;
  static const warningFill = Primitive.sand971;
  static const warningBorder = Primitive.yellow838;
  static const warningIconFill = Primitive.yellow934;
  static const errorFill = Primitive.red948;
  static const errorBorder = Primitive.red641;
  static const errorIconFill = Primitive.red874;

  static const hoverShadow = Primitive.brown331A18;
  static const message = Primitive.brown466;

  /// Close disc fades between these (reference `.close` 150ms).
  static const closeFill = Primitive.brown492A0;
  static const closeHoverFill = Primitive.brown492A12;
  static const closeHover = Primitive.brown492;
}
