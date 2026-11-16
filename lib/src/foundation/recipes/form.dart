import 'package:flutter/material.dart';

import '../palette.dart';
import '../theme.dart';

/// Form colour recipe.
abstract final class FormColors {
  /// Reference `@label-color` / form colour `rgba(0,0,0,.85)`: a fixed
  /// near-black on light surfaces, independent of a surrounding card's
  /// passive ink. Dark surfaces (no reference counterpart) keep the theme ink.
  static Color ink(BuildContext context) =>
      Theme.of(context).colorScheme.brightness == Brightness.light
      ? Primitive.neutral0A85
      : IslandTheme.of(context).ink;
}
