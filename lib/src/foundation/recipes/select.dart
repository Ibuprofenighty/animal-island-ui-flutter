import '../palette.dart';

/// Select colour recipe: trigger, clear control and the yellow side panel.
abstract final class SelectColors {
  static const trigger = Primitive.neutral1000;
  static const triggerHover = Primitive.neutral994;
  static const triggerDisabled = Primitive.neutral969;

  /// Reference `.clear:hover` #725d42 (6.2:1); its disc fades this base to
  /// 10% alpha.
  static const clearHover = Primitive.brown492;

  static const panel = Primitive.yellow945;
  static const option = Primitive.brown492;
  static const selectedPill = Primitive.yellow866A30;
}
