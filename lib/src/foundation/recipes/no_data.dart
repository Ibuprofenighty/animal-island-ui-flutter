import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../reference_palette.dart';
import '../theme.dart';

/// NoData colour recipe resolved for one build context.
///
/// The reference palette (default light tokens, or a light Card paper
/// declared by its surface owner) uses the reference theme variables:
/// title `--animal-text-color` #794f27 (6.4:1+ on every light paper),
/// bordered fill `--animal-bg-color` #f8f8f0 and decorative dashed outline
/// `--animal-border-color-light` #e8e2d6. The description
/// `--animal-text-color-secondary` #9f927d (2.7–3.1:1) deepens in its own
/// OKLCH hue to #7a6d59 (4.5:1+ on every light paper). Dark or customized
/// token sets keep their roles: ink, muted, paper and outline.
@immutable
final class NoDataColors {
  const NoDataColors._({
    required this.title,
    required this.description,
    required this.fill,
    required this.border,
  });

  factory NoDataColors.of(BuildContext context, IslandTokens tokens) {
    final reference = usesReferencePalette(context);
    return NoDataColors._(
      title: reference ? Primitive.brown466 : tokens.ink,
      description: reference ? Primitive.sand541 : tokens.muted,
      fill: reference ? Primitive.neutral977 : tokens.paper,
      border: reference ? Primitive.sand914 : tokens.outline,
    );
  }

  /// Title ink, also the default colour of a custom icon.
  final Color title;
  final Color description;

  /// Bordered surface fill and dashed outline.
  final Color fill, border;

  /// Native drawing ink of the built-in artwork (the icon library default
  /// `currentColor`); the component never recolours the artwork.
  static const artworkInk = Primitive.neutral285;
}
