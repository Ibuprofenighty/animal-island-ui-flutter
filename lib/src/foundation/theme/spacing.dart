import 'package:flutter/foundation.dart';

/// Spacing values owned by one Animal Island theme.
///
/// The scale is ordered from `xxs` to `xxl`, so a component may derive a
/// non-negative gap from the difference of two steps.
@immutable
class AnimalThemeSpacing {
  /// Smallest spacing step.
  final double xxs;

  /// Extra-small spacing step.
  final double xs;

  /// Small spacing step.
  final double sm;

  /// Medium spacing step.
  final double md;

  /// Large spacing step.
  final double lg;

  /// Extra-large spacing step.
  final double xl;

  /// Largest spacing step.
  final double xxl;

  /// Creates a spacing scale.
  ///
  /// Throws an [ArgumentError] if any step is negative or not finite, or if
  /// the steps are not ordered from [xxs] to [xxl].
  AnimalThemeSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  }) {
    for (final entry in <String, double>{
      'xxs': xxs,
      'xs': xs,
      'sm': sm,
      'md': md,
      'lg': lg,
      'xl': xl,
      'xxl': xxl,
    }.entries) {
      if (!entry.value.isFinite || entry.value < 0) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'spacing must be finite and non-negative',
        );
      }
    }
    final ordered = <double>[xxs, xs, sm, md, lg, xl, xxl];
    for (var i = 1; i < ordered.length; i++) {
      if (ordered[i] < ordered[i - 1]) {
        throw ArgumentError(
          'Spacing must be ordered xxs <= xs <= sm <= md <= lg <= xl <= xxl.',
        );
      }
    }
  }

  /// Default scale: 2, 4, 8, 12, 16, 24 and 32 logical pixels.
  static final AnimalThemeSpacing standard = AnimalThemeSpacing(
    xxs: 2,
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
  );

  /// Returns a copy of this scale with the given fields replaced.
  AnimalThemeSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) => AnimalThemeSpacing(
    xxs: xxs ?? this.xxs,
    xs: xs ?? this.xs,
    sm: sm ?? this.sm,
    md: md ?? this.md,
    lg: lg ?? this.lg,
    xl: xl ?? this.xl,
    xxl: xxl ?? this.xxl,
  );

  /// Linearly interpolates between this scale and [other].
  AnimalThemeSpacing lerp(AnimalThemeSpacing other, double t) {
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalThemeSpacing(
      xxs: xxs + (other.xxs - xxs) * t,
      xs: xs + (other.xs - xs) * t,
      sm: sm + (other.sm - sm) * t,
      md: md + (other.md - md) * t,
      lg: lg + (other.lg - lg) * t,
      xl: xl + (other.xl - xl) * t,
      xxl: xxl + (other.xxl - xxl) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalThemeSpacing &&
          xxs == other.xxs &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl &&
          xxl == other.xxl;

  @override
  int get hashCode => Object.hash(xxs, xs, sm, md, lg, xl, xxl);
}
