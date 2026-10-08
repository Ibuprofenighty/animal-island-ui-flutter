import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion configuration owned by one Animal Island theme.
///
/// These values configure component transitions. Scheduling, lifecycle and
/// reduced-motion policy remain owned by their existing runtime modules.
@immutable
class AnimalThemeMotion {
  /// Curve for ordinary enter, exit and state transitions.
  final Curve ease;

  /// Overshooting curve for springy motion such as toggles and panels opening.
  final Curve spring;

  /// Duration of short transitions such as hover and press feedback.
  final Duration fast;

  /// Duration of standard transitions.
  final Duration normal;

  /// Duration of longer transitions such as progress and loading animations.
  final Duration slow;

  /// Creates a motion configuration.
  ///
  /// Throws an [ArgumentError] if any duration is negative.
  AnimalThemeMotion({
    required this.ease,
    required this.spring,
    required this.fast,
    required this.normal,
    required this.slow,
  }) {
    for (final entry in <String, Duration>{
      'fast': fast,
      'normal': normal,
      'slow': slow,
    }.entries) {
      if (entry.value.isNegative) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'duration must be non-negative',
        );
      }
    }
  }

  /// Default motion: a standard ease curve, [Curves.easeOutBack] as the spring
  /// and 150, 250 and 350 ms durations.
  static final AnimalThemeMotion standard = AnimalThemeMotion(
    ease: Cubic(0.4, 0.0, 0.2, 1.0),
    spring: Curves.easeOutBack,
    fast: Duration(milliseconds: 150),
    normal: Duration(milliseconds: 250),
    slow: Duration(milliseconds: 350),
  );

  /// Returns a copy of this motion with the given fields replaced.
  AnimalThemeMotion copyWith({
    Curve? ease,
    Curve? spring,
    Duration? fast,
    Duration? normal,
    Duration? slow,
  }) => AnimalThemeMotion(
    ease: ease ?? this.ease,
    spring: spring ?? this.spring,
    fast: fast ?? this.fast,
    normal: normal ?? this.normal,
    slow: slow ?? this.slow,
  );

  /// Linearly interpolates between this motion and [other].
  ///
  /// Durations interpolate; curves switch at `t == 0.5`.
  AnimalThemeMotion lerp(AnimalThemeMotion other, double t) {
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalThemeMotion(
      ease: t < 0.5 ? ease : other.ease,
      spring: t < 0.5 ? spring : other.spring,
      fast: lerpAnimalDuration(fast, other.fast, t),
      normal: lerpAnimalDuration(normal, other.normal, t),
      slow: lerpAnimalDuration(slow, other.slow, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalThemeMotion &&
          ease == other.ease &&
          spring == other.spring &&
          fast == other.fast &&
          normal == other.normal &&
          slow == other.slow;

  @override
  int get hashCode => Object.hash(ease, spring, fast, normal, slow);
}

/// Linearly interpolates between two durations. Package-internal: the theme
/// motion tokens and the component styles share this one interpolation.
Duration lerpAnimalDuration(Duration a, Duration b, double t) => Duration(
  microseconds: (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t)
      .round(),
);
