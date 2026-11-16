import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../theme.dart';

/// Tabs colour recipe; the selected fill is [IslandTokens.leafSelected].
abstract final class TabsColors {
  static const frame = Primitive.sand914;
  static const headerRule = Primitive.sand914;
  static const selectedShadow = Primitive.brown331A8;

  /// Header band: translucent white on light hosts, paper on dark ones.
  static Color header(Brightness brightness, IslandTokens tokens) =>
      brightness == Brightness.dark ? tokens.paper : Primitive.neutral1000A60;
}
