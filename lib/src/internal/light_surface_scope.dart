import 'package:flutter/material.dart';

import '../foundation/reference_palette.dart';
import '../foundation/theme.dart';
import 'content_scope.dart';

/// Defaults for an owned surface. The known-light pair remains the default;
/// an explicit surfaceTheme declares control semantics independently of passive
/// content ink. This existing scope never infers colors or inspects a slot.
class LightSurfaceScope extends StatelessWidget {
  const LightSurfaceScope({
    super.key,
    required this.child,
    this.onSurface,
    this.surfaceTheme,
    this.enabled = true,
    this.referencePaper = false,
  });
  final Widget child;
  final Color? onSurface;
  final IslandSurfaceTheme? surfaceTheme;
  final bool enabled;

  /// Declared by the surface owner (Card pattern/neutral papers): the surface
  /// is one of the product's light papers, so nested controls keep the
  /// reference recipe (see [usesReferencePalette]) although [onSurface]
  /// rewrites passive ink. Never inferred from a color.
  final bool referencePaper;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = onSurface;
    final tokens =
        surfaceTheme?.tokens ??
        (foreground == null
            ? IslandTokens.light
            : IslandTokens.light.copyWith(
                ink: foreground,
                muted: foreground,
                link: foreground,
                linkHover: foreground,
                linkPressed: foreground,
                focus: foreground,
                outline: foreground,
                dangerText: IslandTokens.light.onDanger,
              ));
    // Keep this topology when a surface becomes transparent so state/focus
    // remain with the same opaque child. Empty defaults inherit the host.
    Widget body = ContentScope(
      textStyle: TextStyle(color: enabled ? foreground ?? tokens.ink : null),
      iconColor: enabled ? foreground ?? tokens.ink : null,
      child: child,
    );
    body = ReferencePaperScope(
      tokens: enabled && referencePaper && surfaceTheme == null ? tokens : null,
      child: body,
    );
    return Theme(
      data: !enabled
          ? theme
          : theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                brightness: surfaceTheme?.brightness ?? Brightness.light,
                surface: tokens.paper,
                onSurface: tokens.ink,
                onSurfaceVariant: tokens.muted,
                primary: tokens.link,
                onPrimary: tokens.paper,
                error: tokens.dangerText,
              ),
              textTheme: theme.textTheme.apply(
                bodyColor: tokens.ink,
                displayColor: tokens.ink,
              ),
              extensions: [
                for (final extension in theme.extensions.values)
                  if (extension is! IslandTokens) extension,
                tokens,
              ],
            ),
      child: body,
    );
  }
}
