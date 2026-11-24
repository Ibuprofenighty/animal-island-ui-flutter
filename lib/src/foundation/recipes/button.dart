import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../reference_palette.dart';
import '../theme.dart';

/// Button colour recipe: fills, boundaries and depth shadows not carried by
/// [IslandTokens]. Theme/brightness/reference decisions are resolved here.
abstract final class ButtonColors {
  /// Text variant pressed/hover fill on a light host; dark hosts blend ink.
  static Color textPressed(Brightness brightness, IslandTokens tokens) =>
      brightness == Brightness.light
      ? Primitive.sand901
      : Color.alphaBlend(tokens.ink.withValues(alpha: .08), tokens.paper);
  static Color textHover(Brightness brightness, IslandTokens tokens) =>
      brightness == Brightness.light
      ? Primitive.sand933
      : Color.alphaBlend(tokens.ink.withValues(alpha: .04), tokens.paper);

  /// Danger default/dashed boundary. Reference palette: error #e05a5a, hover
  /// #e87878 deepened in hue to #dd6e6f (2.7:1 on the fill), active #c94444;
  /// other palettes keep [IslandTokens.dangerText].
  static Color dangerBoundary(
    BuildContext context,
    IslandTokens tokens, {
    required bool pressed,
    required bool hover,
  }) => usesReferencePalette(context)
      ? (pressed
            ? Primitive.red574
            : hover
            ? Primitive.red668
            : Primitive.red641)
      : tokens.dangerText;

  /// Busy is a Button-owned fixed surface, separate from the brand leaf.
  static const busyFill = Primitive.teal739;

  /// Busy donut contour: the icon's own drawing ink, not the button foreground
  /// or caller style (6.6:1 on [busyFill]).
  static const busyGlyphInk = Primitive.neutral285;
  static const depthShadow = Primitive.brown760;
  static const dangerDepthShadow = Primitive.red574;
  static const restShadow = Primitive.brown331A6;
  static const raisedShadow = Primitive.brown331A10;
}
