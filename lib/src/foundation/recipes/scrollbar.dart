import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../reference_palette.dart';
import '../theme.dart';

/// Scrollbar colour recipe.
abstract final class ScrollbarColors {
  /// Thumb at rest. The reference `--animal-scrollbar-thumb` #9f927d is
  /// 2.5–3.05:1 on the light papers and on its own track, and the thumb is
  /// the only mark of the scroll position: the `outline` role, the same sand
  /// hue OKLCH-deepened (#8f8474, 3.0:1 on the track, 3.4:1 or more on the
  /// light papers).
  static Color thumb(BuildContext context) => IslandTheme.of(context).outline;

  /// Thumb under the pointer and while dragged: the reference
  /// `--animal-text-color` #794f27 under the reference palette; dark or
  /// customized token sets keep their `ink` role.
  static Color thumbHover(BuildContext context) => usesReferencePalette(context)
      ? Primitive.brown466
      : IslandTheme.of(context).ink;

  /// Track fill when shown: the reference `--animal-bg-color-secondary`
  /// #f0e8d8 under the reference palette; dark or customized token sets use
  /// their `canvas` role.
  static Color track(BuildContext context) => usesReferencePalette(context)
      ? Primitive.sand933
      : IslandTheme.of(context).canvas;
}
