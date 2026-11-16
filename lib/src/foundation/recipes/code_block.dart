import '../palette.dart';

/// CodeBlock default recipe, used when neither the instance nor
/// IslandCodeBlockTheme supplies a role.
abstract final class CodeBlockColors {
  static const background = Primitive.brown257;
  static const foreground = Primitive.brown882;
  static const border = Primitive.brown321;

  // Syntax roles, keyed by IslandCodeToken in the component.
  static const comment = Primitive.brown658;
  static const literal = Primitive.green825;
  static const command = Primitive.orange789;
  static const keyword = Primitive.violet775;
  static const type = Primitive.blue776;
  static const function = Primitive.blue730;
  static const punctuation = Primitive.brown798;

  // Copy action.
  static const copyForeground = foreground;
  static const copyBackground = Primitive.brown321A94;
  static const copyBackgroundHover = Primitive.brown367;
  static const copyBorder = Primitive.brown882A30;
  static const copyFocusRing = Primitive.teal750;
}
