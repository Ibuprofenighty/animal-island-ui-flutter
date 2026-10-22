import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'icon_names.dart';
import 'theme.dart';
import '../internal/icon_loader.dart';
export 'icon_names.dart' show IslandGlyph;

/// Pinned reference SVG. Color, then IconTheme, supplies currentColor strokes.
/// Explicit multicolor artwork remains owned by the asset.
class IslandIcon extends StatelessWidget {
  const IslandIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 3.5,
    this.semanticLabel,
  });
  final IslandGlyph glyph;
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context) {
    final art = SvgPicture(
      IslandSvgLoader(
        'assets/icons/${glyph.assetName}.svg',
        strokeWidth: strokeWidth.isFinite && strokeWidth >= 0
            ? strokeWidth
            : 3.5,
        theme: SvgTheme(
          currentColor:
              color ??
              IconTheme.of(context).color ??
              IslandTheme.of(context).ink,
        ),
      ),
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: art)
        : Semantics(label: semanticLabel, image: true, child: art);
  }
}
