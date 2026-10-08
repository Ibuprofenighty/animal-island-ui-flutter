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

/// Size of an [AnimalButton].
enum AnimalButtonSize {
  /// 34 logical pixels high.
  small,

  /// 44 logical pixels high.
  middle,

  /// 52 logical pixels high.
  large,
}

/// Metrics of each [AnimalButtonSize]. Package-internal: the root library
/// exports the enum without this extension.
extension AnimalButtonSizeMetrics on AnimalButtonSize {
  /// Height of the button.
  double get height => switch (this) {
    AnimalButtonSize.small => 34,
    AnimalButtonSize.middle => 44,
    AnimalButtonSize.large => 52,
  };

  /// Font size of the label.
  double get fontSize => switch (this) {
    AnimalButtonSize.small => 13,
    AnimalButtonSize.middle => 15,
    AnimalButtonSize.large => 17,
  };

  /// Horizontal padding inside the button.
  double get horizontalPadding => switch (this) {
    AnimalButtonSize.small => 16,
    AnimalButtonSize.middle => 22,
    AnimalButtonSize.large => 28,
  };

  /// Size of the leading icon and the loading indicator.
  double get iconSize => switch (this) {
    AnimalButtonSize.small => 16,
    AnimalButtonSize.middle => 20,
    AnimalButtonSize.large => 24,
  };
}

/// Resolved visual style attributes for [AnimalButton].
@immutable
class ResolvedAnimalButtonStyle {
  /// Fill of the button surface; transparent for surface-less variants.
  final Color surfaceColor;

  /// Shadow under the raised surface; null when the button has no depth.
  final BoxShadow? depthShadow;

  /// Color of the label and icon.
  final Color textColor;

  /// Press travel of the raised surface in logical pixels; 0 when flat.
  final double depth;

  /// Outline of the surface; null when the variant draws none.
  final Border? border;

  /// Additional shadows painted under the surface; null when none.
  final List<BoxShadow>? extraShadows;

  /// Style of the label, sized for the button size.
  final TextStyle textStyle;

  /// Creates a resolved style from already computed values.
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
