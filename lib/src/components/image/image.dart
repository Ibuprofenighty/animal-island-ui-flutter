import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/colors.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../skeleton/skeleton.dart';
import 'image_preview.dart';

/// Presentation variants for [AnimalImage].
enum AnimalImageVariant {
  /// Default 20px card radius with soft elevation.
  standard,

  /// Bordered picture frame with 14px radius and island card tint.
  bordered,
}

/// Cozy Animal Island Image component with full-screen Lightbox preview.
///
/// Features:
/// - Standard rounded card and bordered picture frame variants
/// - Built-in [AnimalSkeleton] shimmer placeholder during network/file loading
/// - Built-in cute island error fallback graphic
/// - Full-screen interactive lightbox preview with zoom, pinch, and pan
/// - Keyboard accessibility: preview opens via Enter/Space and closes via Escape
/// - Restores focus to the triggering element upon preview dismissal
class AnimalImage extends StatelessWidget {
  /// The image provider to display.
  final ImageProvider image;

  /// Optional width in logical pixels.
  final double? width;

  /// Optional height in logical pixels.
  final double? height;

  /// How the image should be inscribed into the box. Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// Visual presentation variant. Defaults to [AnimalImageVariant.standard].
  final AnimalImageVariant variant;

  /// Optional island pastel color tint for the frame border or background.
  final AnimalTileColor? color;

  /// Custom corner radius override.
  final BorderRadius? borderRadius;

  /// Whether tapping or activating the image opens a full-screen lightbox preview.
  final bool preview;

  /// Custom widget shown while the image is loading. Defaults to [AnimalSkeleton].
  final Widget? placeholder;

  /// Custom widget shown if image loading encounters an error.
  final Widget? fallback;

  /// Accessibility description of the image content.
  final String? semanticLabel;

  /// Creates an image that displays [image].
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
    presentAnimalImagePreview(
      context,
      image: image,
      semanticLabel: semanticLabel,
      fallback: fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AnimalLocalizations.of(context)!;
    final theme = AnimalIslandTheme.of(context);
    final effectiveRadius =
        borderRadius ??
        (variant == AnimalImageVariant.standard
            ? theme.radii.cardBorder
            : theme.radii.smBorder);

    final frameColor = color == null
        ? theme.colors.bgContent
        : theme.colors.tile(color!).background;
    final borderColor = theme.colors.brightness == Brightness.dark
        ? theme.colors.border
        : theme.colors.borderLight;

    Widget imageWidget = Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            SizedBox(width: width, height: height, child: AnimalSkeleton());
      },
      errorBuilder: (context, error, stackTrace) {
        return fallback ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: theme.colors.bgContent,
                borderRadius: effectiveRadius,
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: AnimalIcon(
                data: AnimalIcons.image,
                size: 32,
                color: theme.colors.brightness == Brightness.dark
                    ? theme.colors.textDisabled
                    : theme.colors.border,
              ),
            );
      },
    );

    Widget core;
    if (variant == AnimalImageVariant.bordered) {
      core = Container(
        padding: EdgeInsets.all(theme.spacing.xs + theme.spacing.xxs),
        decoration: BoxDecoration(
          color: frameColor,
          borderRadius: effectiveRadius,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [theme.shadows.softElevation],
        ),
        child: ClipRRect(
          borderRadius: theme.radii.smBorder,
          child: imageWidget,
        ),
      );
    } else {
      core = Container(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: [theme.shadows.softElevation],
        ),
        child: ClipRRect(borderRadius: effectiveRadius, child: imageWidget),
      );
    }

    if (preview) {
      return InteractiveRegion(
        onPressed: () => _openLightbox(context),
        enableHaptics: false,
        semanticContainer: true,
        semanticLabel: semanticLabel != null
            ? localizations.imagePreviewSemanticLabel(semanticLabel!)
            : localizations.imagePreviewDefaultSemanticLabel,
        child: core,
      );
    }

    return core;
  }
}
