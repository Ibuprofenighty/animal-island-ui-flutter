import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG parsing/cache stays in flutter_svg. This changes only numeric stroke widths.
class IslandSvgLoader extends SvgAssetLoader {
  const IslandSvgLoader(
    super.assetName, {
    required this.strokeWidth,
    required super.theme,
  }) : super(packageName: 'animal_island_ui');
  final double strokeWidth;
  @override
  String provideSvg(ByteData? message) {
    final source = super.provideSvg(message);
    if (strokeWidth == 3.5) return source;
    return source.replaceAllMapped(RegExp(r'stroke-width="([0-9.]+)"'), (
      match,
    ) {
      final value =
          (double.parse(match[1]!) * strokeWidth / 3.5 * 100).round() / 100;
      return 'stroke-width="$value"';
    });
  }

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    final base = super.cacheKey(context);
    return SvgCacheKey(
      keyData: (base.keyData, strokeWidth),
      theme: base.theme,
      colorMapper: base.colorMapper,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is IslandSvgLoader &&
      super == other &&
      strokeWidth == other.strokeWidth;
  @override
  int get hashCode => Object.hash(super.hashCode, strokeWidth);
}
