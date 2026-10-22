import 'package:flutter/material.dart';

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
  });
  final Widget child;
  final Color? onSurface;
  final IslandSurfaceTheme? surfaceTheme;
  final bool enabled;
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
      // Keep this topology when a surface becomes transparent so state/focus
      // remain with the same opaque child. Empty defaults inherit the host.
      child: ContentScope(
        textStyle: TextStyle(color: enabled ? foreground ?? tokens.ink : null),
        iconColor: enabled ? foreground ?? tokens.ink : null,
        child: child,
      ),
    );
  }
}
