import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../reference_palette.dart';
import '../theme.dart';

/// Input colour recipe resolved for one build context.
///
/// On the reference palette the status colours are the reference
/// `.wrapper-error` #c94444 (4.7:1 on the field fill) and the 3:1 same-hue
/// deepening of `.wrapper-warning` #dba90e (#af8600, 3.3:1); the decorative
/// shadow bar keeps #d4c9b4 / hover #c4b89e because the 1px outline carries
/// the boundary. Other palettes keep their token roles.
@immutable
final class InputColors {
  const InputColors._({
    required this.error,
    required this.warning,
    required this.bar,
    required this.barHover,
  });

  factory InputColors.of(BuildContext context, IslandTokens tokens) {
    final reference = usesReferencePalette(context);
    return InputColors._(
      error: reference ? Primitive.red574 : tokens.dangerText,
      warning: reference ? Primitive.yellow642 : tokens.warning,
      bar: reference ? Primitive.sand839 : tokens.outline,
      barHover: reference ? Primitive.sand786 : tokens.muted,
    );
  }

  final Color error, warning;

  /// Decorative `shadow` bar at rest and on hover.
  final Color bar, barHover;

  /// Reference `.wrapper-disabled .input` and placeholder; disabled controls
  /// are exempt from the text contrast budget.
  static const disabledText = Primitive.sand786;
  static const disabledFill = Primitive.sand931;
}

/// Switch colour recipe (fixed reference light control in every theme).
abstract final class SwitchColors {
  /// Busy base under the dimmed track/thumb so in-track text stays opaque.
  static const busyBase = Primitive.neutral977;

  static const trackOn = Primitive.green803;
  static const trackOnHover = Primitive.green772;
  static const trackOff = Primitive.sand839;

  /// Unchecked rest boundary: reference #c4b89e (1.8:1) deepened in hue to
  /// the 3:1 boundary. Hover uses the light muted role; checked keeps onLeaf.
  static const trackOffBorder = Primitive.sand641;

  static const textShadow = Primitive.neutral0A10;
  static const thumb = Primitive.sand962;

  /// Reference `.handle` #c4b89e / checked #6fba2c, each deepened in hue to
  /// 3:1 on the [thumb] fill.
  static const thumbBorderOff = Primitive.sand641;
  static const thumbBorderOn = Primitive.green625;

  /// Reference `.spinner` unchecked #a89878 / checked #6fba2c, deepened in
  /// hue to 3:1 against the busy (0.7) thumb.
  static const spinnerOff = Primitive.sand503;
  static const spinnerOn = Primitive.green495;
}
