import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/overlay/animal_route.dart';
import '../../internal/timing/motion_policy.dart';

/// Presents the full-screen lightbox of an [AnimalImage] on the nearest
/// Navigator.
///
/// It is the package's one route mechanism: the close control, Escape,
/// system back and a barrier tap dismiss it, focus stays inside it and
/// returns to the opening control when it closes. With reduced motion it
/// appears without fading.
Future<void> presentAnimalImagePreview(
  BuildContext context, {
  required ImageProvider image,
  required String? semanticLabel,
  required Widget? fallback,
}) {
  final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
  final bool animate = AnimalMotionPolicy.shouldAnimate(context);
  return presentAnimalRoute<void>(
    context: context,
    maskClosable: true,
    barrierColor: theme.colors.text.withValues(alpha: 0.85),
    transitionDuration: animate ? theme.motion.normal : Duration.zero,
    routeLabel: (context) =>
        AnimalLocalizations.of(context)!.imagePreviewRouteLabel,
    builder: (context, session) => _AnimalImagePreviewPage(
      image: image,
      semanticLabel: semanticLabel,
      fallback: fallback,
      onClose: session.dismiss,
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      if (!animate) return child;
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: theme.motion.ease),
        child: child,
      );
    },
  );
}

class _AnimalImagePreviewPage extends StatelessWidget {
  const _AnimalImagePreviewPage({
    required this.image,
    required this.semanticLabel,
    required this.fallback,
    required this.onClose,
  });

  final ImageProvider image;
  final String? semanticLabel;
  final Widget? fallback;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final AnimalLocalizations localizations = AnimalLocalizations.of(context)!;
    final Color closeSurface = theme.colors.surfaceHeader;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
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
                              border: Border.all(color: theme.colors.border),
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
                padding: EdgeInsets.all(theme.spacing.lg + theme.spacing.xs),
                child: AnimalIconAction(
                  onPressed: onClose,
                  semanticLabel: localizations.imagePreviewCloseLabel,
                  padding: EdgeInsets.all(theme.spacing.md - theme.spacing.xxs),
                  borderRadius: BorderRadius.all(
                    Radius.circular(theme.radii.card * 1.2),
                  ),
                  backgroundColor: resolveIconActionBackground(
                    null,
                    idle: closeSurface,
                    hovered: theme.colors.surfaceAlt,
                  ),
                  icon: AnimalIcon(
                    data: AnimalIcons.close,
                    size: 20,
                    color: theme.colors.text,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
