import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Declaration installed by a surface owner (LightSurfaceScope for Card
/// pattern/neutral papers): the surface is one of the product's light papers.
/// Component recipes read it through [usesReferencePalette]; it is never
/// inferred from a color.
class ReferencePaperScope extends InheritedWidget {
  const ReferencePaperScope({
    super.key,
    required this.tokens,
    required super.child,
  });

  /// The token set the declaring scope installed, or null for no declaration.
  final IslandTokens? tokens;
  @override
  bool updateShouldNotify(ReferencePaperScope old) =>
      !identical(old.tokens, tokens);
}

/// Whether component recipes at [context] use the reference light colors
/// (each measured against every light product paper): the default light
/// palette itself, or a light paper declared by its surface owner whose
/// tokens are still the ones in effect. Dark, customized or accent-filled
/// surfaces keep their token roles. Only component recipes call this; the
/// decision never lives in a widget build method.
bool usesReferencePalette(BuildContext context) {
  final tokens = IslandTheme.of(context);
  if (identical(tokens, IslandTokens.light)) return true;
  final declared = context
      .dependOnInheritedWidgetOfExactType<ReferencePaperScope>()
      ?.tokens;
  return declared != null && identical(declared, tokens);
}
