import 'package:flutter/material.dart';

import 'colors.dart';
import 'component_themes.dart';
import 'motion.dart';
import 'radii.dart';
import 'shadows.dart';
import 'spacing.dart';
import 'typography.dart';

/// The single immutable theme value consumed by Animal Island components.
@immutable
class AnimalIslandTheme extends ThemeExtension<AnimalIslandTheme> {
  final AnimalThemeColors colors;
  final AnimalThemeTypography typography;
  final AnimalThemeRadii radii;
  final AnimalThemeSpacing spacing;
  final AnimalThemeShadows shadows;
  final AnimalThemeMotion motion;

  /// Component-level overrides; empty in the presets.
  final AnimalComponentThemes components;

  const AnimalIslandTheme({
    required this.colors,
    required this.typography,
    required this.radii,
    required this.spacing,
    required this.shadows,
    required this.motion,
    this.components = const AnimalComponentThemes(),
  });

  /// Canonical light preset assembled from each token family's single owner.
  static final AnimalIslandTheme light = AnimalIslandTheme(
    colors: AnimalThemeColors.light,
    typography: AnimalThemeTypography.standard,
    radii: AnimalThemeRadii.standard,
    spacing: AnimalThemeSpacing.standard,
    shadows: AnimalThemeShadows.light,
    motion: AnimalThemeMotion.standard,
  );

  /// Canonical dark preset assembled from each token family's single owner.
  static final AnimalIslandTheme dark = AnimalIslandTheme(
    colors: AnimalThemeColors.dark,
    typography: AnimalThemeTypography.standard,
    radii: AnimalThemeRadii.standard,
    spacing: AnimalThemeSpacing.standard,
    shadows: AnimalThemeShadows.dark,
    motion: AnimalThemeMotion.standard,
  );

  /// Reads the only active Animal Island theme from the enclosing ThemeData.
  ///
  /// A missing extension is an application configuration error; the package
  /// does not create a second fallback theme from host brightness.
  static AnimalIslandTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<AnimalIslandTheme>();
    if (theme == null) {
      throw StateError(
        'AnimalIslandTheme is missing. Install it with '
        'AnimalIslandTheme.light.toThemeData() or a custom theme.',
      );
    }
    return theme;
  }

  /// The sole bridge from token families to Flutter's ThemeData.
  ThemeData toThemeData() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: colors.brightness,
        ).copyWith(
          primary: colors.primary,
          onPrimary: colors.onPrimary,
          primaryContainer: colors.primaryBg,
          onPrimaryContainer: colors.text,
          error: colors.error,
          onError: colors.onError,
          errorContainer: colors.errorBg,
          onErrorContainer: colors.text,
          surface: colors.bgContent,
          onSurface: colors.text,
        );
    final textTheme = TextTheme(
      displayLarge: typography.resolve(
        typography.title.copyWith(color: colors.text),
      ),
      displayMedium: typography.resolve(
        typography.heading.copyWith(color: colors.text),
      ),
      displaySmall: typography.resolve(
        typography.heading.copyWith(color: colors.text),
      ),
      headlineLarge: typography.resolve(
        typography.heading.copyWith(color: colors.text),
      ),
      headlineMedium: typography.resolve(
        typography.subheading.copyWith(color: colors.text),
      ),
      headlineSmall: typography.resolve(
        typography.subheading.copyWith(color: colors.text),
      ),
      titleLarge: typography.resolve(
        typography.subheading.copyWith(color: colors.text),
      ),
      titleMedium: typography.resolve(
        typography.body.copyWith(color: colors.textBody),
      ),
      titleSmall: typography.resolve(
        typography.secondary.copyWith(color: colors.textSecondary),
      ),
      bodyLarge: typography.resolve(
        typography.body.copyWith(color: colors.textBody),
      ),
      bodyMedium: typography.resolve(
        typography.body.copyWith(color: colors.textBody),
      ),
      bodySmall: typography.resolve(
        typography.caption.copyWith(color: colors.textSecondary),
      ),
      labelLarge: typography.resolve(
        typography.button.copyWith(color: colors.text),
      ),
      labelMedium: typography.resolve(
        typography.secondary.copyWith(color: colors.textSecondary),
      ),
      labelSmall: typography.resolve(
        typography.caption.copyWith(color: colors.textSecondary),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.bg,
      canvasColor: colors.bg,
      cardColor: colors.bgContent,
      fontFamily: typography.fontFamily,
      fontFamilyFallback: typography.fontFamilyFallback,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[this],
    );
  }

  @override
  AnimalIslandTheme copyWith({
    AnimalThemeColors? colors,
    AnimalThemeTypography? typography,
    AnimalThemeRadii? radii,
    AnimalThemeSpacing? spacing,
    AnimalThemeShadows? shadows,
    AnimalThemeMotion? motion,
    AnimalComponentThemes? components,
  }) => AnimalIslandTheme(
    colors: colors ?? this.colors,
    typography: typography ?? this.typography,
    radii: radii ?? this.radii,
    spacing: spacing ?? this.spacing,
    shadows: shadows ?? this.shadows,
    motion: motion ?? this.motion,
    components: components ?? this.components,
  );

  @override
  AnimalIslandTheme lerp(ThemeExtension<AnimalIslandTheme>? other, double t) {
    if (other is! AnimalIslandTheme) return this;
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalIslandTheme(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      radii: radii.lerp(other.radii, t),
      spacing: spacing.lerp(other.spacing, t),
      shadows: shadows.lerp(other.shadows, t),
      motion: motion.lerp(other.motion, t),
      components: components.lerp(other.components, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalIslandTheme &&
          colors == other.colors &&
          typography == other.typography &&
          radii == other.radii &&
          spacing == other.spacing &&
          shadows == other.shadows &&
          motion == other.motion &&
          components == other.components;

  @override
  int get hashCode => Object.hash(
    colors,
    typography,
    radii,
    spacing,
    shadows,
    motion,
    components,
  );
}
