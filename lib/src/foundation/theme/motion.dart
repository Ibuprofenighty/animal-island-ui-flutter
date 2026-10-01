import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion configuration owned by one Animal Island theme.
///
/// These values configure component transitions. Scheduling, lifecycle and
/// reduced-motion policy remain owned by their existing runtime modules.
@immutable
class AnimalThemeMotion {
  final Curve ease;
  final Curve spring;
  final Duration fast;
  final Duration normal;
  final Duration slow;

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

  static final AnimalThemeMotion standard = AnimalThemeMotion(
    ease: Cubic(0.4, 0.0, 0.2, 1.0),
    spring: Curves.easeOutBack,
    fast: Duration(milliseconds: 150),
    normal: Duration(milliseconds: 250),
    slow: Duration(milliseconds: 350),
  );

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

  AnimalThemeMotion lerp(AnimalThemeMotion other, double t) {
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalThemeMotion(
      ease: t < 0.5 ? ease : other.ease,
      spring: t < 0.5 ? spring : other.spring,
      fast: _lerpDuration(fast, other.fast, t),
      normal: _lerpDuration(normal, other.normal, t),
      slow: _lerpDuration(slow, other.slow, t),
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) => Duration(
    microseconds: (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t)
        .round(),
  );

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
