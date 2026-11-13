import 'package:flutter/widgets.dart';

import '../palette.dart';
import '../reference_palette.dart';
import '../theme.dart';

/// Checkbox/Radio colour recipe resolved for one build context.
///
/// The reference palette (default light tokens, or a light Card paper
/// declared by its surface owner) restores the reference recipe: unchecked
/// rgb(247,243,223) fill and #725d42/#794f27 labels (both 5.1:1+ on every
/// light paper, so the 150ms colour change stays readable). Failing reference
/// graphics deepen in their own hue only to 3:1: unchecked ring #c4b89e →
/// #978b73 (against its own fill), checked ring #50b9ab → #259689 (every
/// light paper) and the white mark → #5f5f5f (on the #19c8b9 fill). Dark or
/// customized token sets keep their roles.
@immutable
final class ChoiceColors {
  const ChoiceColors._({
    required this.labelUnchecked,
    required this.labelChecked,
    required this.ringUnchecked,
    required this.ringChecked,
    required this.fill,
    required this.mark,
    required this.paper,
    required this.labelIdentity,
  });

  factory ChoiceColors.of(BuildContext context, IslandTokens tokens) {
    final reference = usesReferencePalette(context);
    return ChoiceColors._(
      labelUnchecked: reference ? Primitive.brown492 : tokens.ink,
      labelChecked: reference ? Primitive.brown466 : tokens.ink,
      ringUnchecked: reference ? Primitive.sand641 : tokens.outline,
      ringChecked: reference ? Primitive.teal609 : tokens.onLeaf,
      fill: tokens.leaf,
      mark: reference ? Primitive.neutral485 : tokens.onLeaf,
      paper: reference ? Primitive.sand962 : tokens.paper,
      labelIdentity: (reference, reference ? null : tokens.ink),
    );
  }

  final Color labelUnchecked, labelChecked, ringUnchecked, ringChecked;

  /// Checked fill, check mark and unchecked fill.
  final Color fill, mark, paper;

  /// Equal while the label recipe is unchanged. A changed recipe (palette or
  /// theme) switches the label colour at once instead of animating the
  /// checked pair.
  final Object labelIdentity;

  static const disabledLabel = Primitive.sand786;
  static const disabledRing = Primitive.sand839;
  static const disabledFill = Primitive.sand943;
  static const disabledMark = Primitive.sand786;
}
