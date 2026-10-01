import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';

/// Visual style variants for [AnimalButton].
enum AnimalButtonVariant {
  /// Filled solid background. Primary and Danger tones feature a 3D tactile depth shadow.
  filled,

  /// Outlined border with transparent surface.
  outlined,

  /// Dashed border with transparent surface.
  dashed,

  /// Text-only button without borders or background.
  text,

  /// Link-styled button with underline text decoration.
  link,
}

/// Semantic color tones for [AnimalButton].
enum AnimalButtonTone {
  /// Primary theme accent.
  primary,

  /// Neutral background surface with dark text.
  neutral,

  /// Warning amber tone.
  warning,

  /// Success green tone.
  success,

  /// Danger/error coral red tone.
  danger,
}

/// Standard button dimensions and metrics.
enum AnimalButtonSize {
  small(height: 34.0, fontSize: 13.0, horizontalPadding: 16.0, iconSize: 16.0),
  middle(height: 44.0, fontSize: 15.0, horizontalPadding: 22.0, iconSize: 20.0),
  large(height: 52.0, fontSize: 17.0, horizontalPadding: 28.0, iconSize: 24.0);

  final double height;
  final double fontSize;
  final double horizontalPadding;
  final double iconSize;

  const AnimalButtonSize({
    required this.height,
    required this.fontSize,
    required this.horizontalPadding,
    required this.iconSize,
  });
}

/// Resolved visual style attributes for [AnimalButton].
@immutable
class ResolvedAnimalButtonStyle {
  final Color surfaceColor;
  final BoxShadow? depthShadow;
  final Color textColor;
  final double depth;
  final Border? border;
  final List<BoxShadow>? extraShadows;
  final TextStyle textStyle;

  const ResolvedAnimalButtonStyle({
    required this.surfaceColor,
    this.depthShadow,
    required this.textColor,
    required this.depth,
    this.border,
    this.extraShadows,
    required this.textStyle,
  });

  /// Resolves button styling based on variant, tone, size, theme, and state.
  static ResolvedAnimalButtonStyle resolve({
    required BuildContext context,
    required AnimalButtonVariant variant,
    required AnimalButtonTone tone,
    required AnimalButtonSize size,
    required bool disabled,
    required bool loading,
  }) {
    final theme = AnimalIslandTheme.of(context);

    if (disabled) {
      final surface = (theme.colors.brightness == Brightness.dark)
          ? theme.colors.surfaceAlt
          : theme.colors.bgDisabled;
      final text = theme.colors.textDisabled;
      final borderColor = (theme.colors.brightness == Brightness.dark)
          ? theme.colors.border
          : theme.colors.borderLight;

      return ResolvedAnimalButtonStyle(
        surfaceColor:
            variant == AnimalButtonVariant.text ||
                variant == AnimalButtonVariant.link
            ? Colors.transparent
            : surface,
        depthShadow: null,
        textColor: text,
        depth: 0.0,
        border:
            variant == AnimalButtonVariant.outlined ||
                variant == AnimalButtonVariant.filled
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        textStyle: theme.typography.button.copyWith(
          fontSize: size.fontSize,
          color: text,
        ),
      );
    }

    Color surfaceColor;
    BoxShadow? depthShadow;
    Color textColor;
    double depth = 0.0;
    Border? border;
    List<BoxShadow>? extraShadows;

    // Tone colors
    final Color toneColor = switch (tone) {
      AnimalButtonTone.primary => theme.colors.primary,
      AnimalButtonTone.neutral => theme.colors.text,
      AnimalButtonTone.danger => theme.colors.error,
      AnimalButtonTone.success => theme.colors.success,
      AnimalButtonTone.warning => theme.colors.warning,
    };

    final Color toneForeground = switch (tone) {
      AnimalButtonTone.primary => theme.colors.onPrimary,
      AnimalButtonTone.neutral => theme.colors.text,
      AnimalButtonTone.danger => theme.colors.onError,
      AnimalButtonTone.success => theme.colors.onSuccess,
      AnimalButtonTone.warning => theme.colors.onWarning,
    };
    final Color surfaceToneForeground = switch (tone) {
      AnimalButtonTone.primary => theme.colors.primaryText,
      AnimalButtonTone.neutral => theme.colors.text,
      AnimalButtonTone.danger => theme.colors.errorText,
      AnimalButtonTone.success => theme.colors.successText,
      AnimalButtonTone.warning => theme.colors.warningText,
    };

    switch (variant) {
      case AnimalButtonVariant.filled:
        if (tone == AnimalButtonTone.neutral) {
          surfaceColor = theme.colors.bgContent;
          depthShadow = null;
          textColor = theme.colors.text;
          depth = 0.0;
          extraShadows = [theme.shadows.softElevation];
          border = Border.all(
            color: (theme.colors.brightness == Brightness.dark)
                ? theme.colors.border
                : theme.colors.borderLight,
            width: 1.5,
          );
        } else {
          surfaceColor = toneColor;
          // Four-pixel press travel is the frozen button geometry. The
          // theme-owned BoxShadow supplies the unpressed depth shadow.
          if (tone == AnimalButtonTone.primary ||
              tone == AnimalButtonTone.danger) {
            depth = 4.0;
            depthShadow = theme.shadows.button3d;
          } else {
            depth = 0.0;
            depthShadow = null;
          }
          textColor = toneForeground;
        }

      case AnimalButtonVariant.outlined:
        surfaceColor = Colors.transparent;
        depthShadow = null;
        depth = 0.0;
        textColor = surfaceToneForeground;
        border = Border.all(color: textColor, width: 1.8);

      case AnimalButtonVariant.dashed:
        surfaceColor = Colors.transparent;
        depthShadow = null;
        depth = 0.0;
        textColor = surfaceToneForeground;
        // Border handled via dashed custom painting if needed, or subtle border
        border = Border.all(color: textColor, width: 1.5);

      case AnimalButtonVariant.text:
        surfaceColor = Colors.transparent;
        depthShadow = null;
        depth = 0.0;
        textColor = surfaceToneForeground;

      case AnimalButtonVariant.link:
        surfaceColor = Colors.transparent;
        depthShadow = null;
        depth = 0.0;
        textColor = tone == AnimalButtonTone.neutral
            ? theme.colors.primaryText
            : surfaceToneForeground;
    }

    return ResolvedAnimalButtonStyle(
      surfaceColor: surfaceColor,
      depthShadow: depthShadow,
      textColor: textColor,
      depth: depth,
      border: border,
      extraShadows: extraShadows,
      textStyle: theme.typography.button.copyWith(
        fontSize: size.fontSize,
        color: textColor,
        decoration: variant == AnimalButtonVariant.link
            ? TextDecoration.underline
            : TextDecoration.none,
      ),
    );
  }
}
