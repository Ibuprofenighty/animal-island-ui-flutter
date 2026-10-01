import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/interactive_region.dart';

/// Modal page route displaying a full-screen interactive lightbox for [AnimalImage].
class AnimalImagePreviewRoute extends ModalRoute<void> {
  final ImageProvider image;
  final String? semanticLabel;
  final Widget? fallback;
  final AnimalIslandTheme theme;

  AnimalImagePreviewRoute({
    required this.image,
    required this.theme,
    this.semanticLabel,
    this.fallback,
  });

  @override
  Duration get transitionDuration => theme.motion.normal;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => theme.colors.text.withValues(alpha: 0.85);

  @override
  String? get barrierLabel {
    final routeNavigator = navigator;
    if (routeNavigator == null) return null;
    return AnimalLocalizations.of(routeNavigator.context)?.dismiss;
  }

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final localizations = AnimalLocalizations.of(context)!;
    final closeSurface = theme.colors.surfaceHeader;
    final closeDepth = theme.shadows.button3d;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) => Navigator.of(context).pop(),
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Padding(
                      padding: EdgeInsets.all(theme.spacing.xl),
                      child: ClipRRect(
                        borderRadius: theme.radii.cardBorder,
                        child: Image(
                          image: image,
                          fit: BoxFit.contain,
                          semanticLabel: semanticLabel,
                          errorBuilder: (context, error, stackTrace) {
                            return fallback ??
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: theme.colors.bgContent,
                                    borderRadius: theme.radii.cardBorder,
                                    border: Border.all(
                                      color: theme.colors.border,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: AnimalIcon(
                                    data: AnimalIcons.image,
                                    size: 48,
                                    color: theme.colors.textDisabled,
                                  ),
                                );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(
                        theme.spacing.lg + theme.spacing.xs,
                      ),
                      child: Semantics(
                        button: true,
                        label: localizations.imagePreviewCloseLabel,
                        child: InteractiveRegion(
                          onPressed: () => Navigator.of(context).pop(),
                          depth: 2.0,
                          surfaceColor: closeSurface,
                          depthShadow: closeDepth,
                          borderRadius: BorderRadius.all(
                            Radius.circular(theme.radii.card * 1.2),
                          ),
                          padding: EdgeInsets.all(
                            theme.spacing.md - theme.spacing.xxs,
                          ),
                          child: AnimalIcon(
                            data: AnimalIcons.close,
                            size: 20,
                            color: theme.colors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: child,
    );
  }
}
