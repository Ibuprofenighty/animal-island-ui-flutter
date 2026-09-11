import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../icons/icon_widget.dart';
import '../../primitives/pressable.dart';
import '../feedback/skeleton.dart';

/// Presentation variants for [AnimalImage].
enum AnimalImageVariant {
  /// Default 20px card radius with soft elevation.
  standard,

  /// Bordered picture frame with 14px radius and island card tint.
  bordered,
}

/// Cozy Animal Island Image component with full-screen Lightbox preview.
class AnimalImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AnimalImageVariant variant;
  final AnimalTileColor? color;
  final BorderRadius? borderRadius;
  final bool preview;
  final Widget? placeholder;
  final Widget? fallback;
  final String? semanticLabel;

  const AnimalImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.variant = AnimalImageVariant.standard,
    this.color,
    this.borderRadius,
    this.preview = false,
    this.placeholder,
    this.fallback,
    this.semanticLabel,
  });

  void _openLightbox(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final closeSurface = theme.isDark ? theme.surfaceHeader : const Color(0xFFFFFFFF);
    final closeDepth = theme.isDark ? theme.border : const Color(0xFFD4C9B4);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0xD81C1814),
        pageBuilder: (context, anim, secondaryAnim) {
          return FadeTransition(
            opacity: anim,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ClipRRect(
                          borderRadius: AnimalRadii.cardBorder,
                          child: Image(
                            image: image,
                            fit: BoxFit.contain,
                            semanticLabel: semanticLabel,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40.0,
                    right: 24.0,
                    child: Semantics(
                      button: true,
                      label: 'Close preview',
                      child: AnimalPressable(
                        onPressed: () => Navigator.of(context).pop(),
                        depth: 2.0,
                        surfaceColor: closeSurface,
                        depthColor: closeDepth,
                        borderRadius: BorderRadius.circular(24.0),
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.close_rounded, size: 20, color: theme.text),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveRadius = borderRadius ??
        (variant == AnimalImageVariant.standard
            ? AnimalRadii.cardBorder
            : BorderRadius.circular(14.0));

    final frameColor = color?.background ?? theme.bgContent;
    final borderColor = theme.isDark ? theme.border : AnimalColors.borderLight;

    Widget imageWidget = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            SizedBox(
              width: width,
              height: height,
              child: const AnimalSkeleton(),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return fallback ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: theme.bgContent,
                borderRadius: effectiveRadius,
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: AnimalImageIcon(
                size: 32,
                color: theme.isDark ? theme.textDisabled : AnimalColors.border,
              ),
            );
      },
    );

    Widget core;
    if (variant == AnimalImageVariant.bordered) {
      core = Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: frameColor,
          borderRadius: effectiveRadius,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: const [AnimalShadows.softElevation],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: imageWidget,
        ),
      );
    } else {
      core = Container(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: const [AnimalShadows.softElevation],
        ),
        child: ClipRRect(
          borderRadius: effectiveRadius,
          child: imageWidget,
        ),
      );
    }

    if (preview) {
      return Semantics(
        button: true,
        label: semanticLabel != null
            ? '$semanticLabel, click to preview'
            : 'Preview image',
        child: FocusableActionDetector(
          enabled: true,
          mouseCursor: SystemMouseCursors.zoomIn,
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _openLightbox(context);
                return null;
              },
            ),
          },
          child: GestureDetector(
            onTap: () => _openLightbox(context),
            child: core,
          ),
        ),
      );
    }

    return core;
  }
}

