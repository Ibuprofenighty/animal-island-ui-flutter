import '../palette.dart';

/// Shared Countdown/CountUp numeric surface and plate recipe; `island`
/// selects the island variant.
abstract final class NumberColors {
  static const surface = Primitive.neutral977;
  static const islandSurface = Primitive.sand962;
  static const islandSurfaceBorder = Primitive.sand826;
  static const surfaceShadow = Primitive.brown331A6;

  /// Plate gradient top (per variant) to the shared bottom.
  static const plateTop = Primitive.neutral1000;
  static const islandPlateTop = Primitive.sand993;
  static const plateBottom = Primitive.neutral977;
  static const plateBorder = Primitive.sand839;
  static const islandPlateBorder = Primitive.sand826;

  /// Countdown default reminders: reference 60-second orange `#c77c34` and
  /// 10-second error red `#e05a5a`.
  static const reminderWarm = Primitive.orange653;
  static const reminderUrgent = Primitive.red641;
}
