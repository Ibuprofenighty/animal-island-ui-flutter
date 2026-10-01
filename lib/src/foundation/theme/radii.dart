import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Corner radii owned by one Animal Island theme.
@immutable
class AnimalThemeRadii {
  final double pill;
  final double card;
  final double tooltip;
  final double sm;

  AnimalThemeRadii({
    required this.pill,
    required this.card,
    required this.tooltip,
    required this.sm,
  }) {
    for (final entry in <String, double>{
      'pill': pill,
      'card': card,
      'tooltip': tooltip,
      'sm': sm,
    }.entries) {
      if (!entry.value.isFinite || entry.value < 0) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'radius must be finite and non-negative',
        );
      }
    }
  }

  static final AnimalThemeRadii standard = AnimalThemeRadii(
    pill: 50,
    card: 20,
    tooltip: 16,
    sm: 12,
  );

  BorderRadius get pillBorder => BorderRadius.all(Radius.circular(pill));
  BorderRadius get cardBorder => BorderRadius.all(Radius.circular(card));
  BorderRadius get tooltipBorder => BorderRadius.all(Radius.circular(tooltip));
  BorderRadius get smBorder => BorderRadius.all(Radius.circular(sm));

  AnimalThemeRadii copyWith({
    double? pill,
    double? card,
    double? tooltip,
    double? sm,
  }) => AnimalThemeRadii(
    pill: pill ?? this.pill,
    card: card ?? this.card,
    tooltip: tooltip ?? this.tooltip,
    sm: sm ?? this.sm,
  );

  AnimalThemeRadii lerp(AnimalThemeRadii other, double t) {
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalThemeRadii(
      pill: pill + (other.pill - pill) * t,
      card: card + (other.card - card) * t,
      tooltip: tooltip + (other.tooltip - tooltip) * t,
      sm: sm + (other.sm - sm) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalThemeRadii &&
          pill == other.pill &&
          card == other.card &&
          tooltip == other.tooltip &&
          sm == other.sm;

  @override
  int get hashCode => Object.hash(pill, card, tooltip, sm);
}
