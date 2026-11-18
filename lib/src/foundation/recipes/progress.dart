import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../reference_palette.dart';
import '../theme.dart';

/// Progress colour recipe.
abstract final class ProgressColors {
  static const track = Primitive.neutral977;
  static const trackDot = Primitive.sand786A10;

  /// In-progress fill gradient (stops 0, .6, 1) and the complete gradient.
  static const fillTop = Primitive.teal790;
  static const fillMiddle = Primitive.teal750;
  static const fillBottom = Primitive.teal699;
  static const completeTop = Primitive.teal844;
  static const completeBottom = Primitive.teal790;
  static const highlight = Primitive.neutral1000A45;

  /// The reference fill (#19c8b9, 1.9:1 on the track) needs a 3:1 edge:
  /// the same hue, OKLCH-deepened.
  static const fillEdge = Primitive.teal626;

  /// Sheen over a caller fill colour (reference stops 0, .6, .6, 1: white .24
  /// fading out, then warm shade .08 fading in).
  static const customSheen = [
    Primitive.neutral1000A24,
    Primitive.neutral1000A0,
    Primitive.brown331A0,
    Primitive.brown331A8,
  ];

  /// Ocean wave inside the fill.
  static const wave = Primitive.neutral1000;

  /// Track boundary. The reference `@track-border` #e2d6bd is 1.3–1.4:1
  /// against the #f8f8f0 track and the light papers, and the boundary alone
  /// shows the track extent (the 100% end): the same hue, OKLCH-deepened to
  /// #9a8e77 (3.0:1 on the track, 3.2:1 on white).
  static const trackBorder = Primitive.sand651;

  /// Percentage ink beside the track: the reference `.info` #725d42 (5.9:1+
  /// on the light papers) under the reference palette; dark or customized
  /// token sets keep their `ink` role.
  static Color info(BuildContext context) => usesReferencePalette(context)
      ? Primitive.brown492
      : IslandTheme.of(context).ink;
}
