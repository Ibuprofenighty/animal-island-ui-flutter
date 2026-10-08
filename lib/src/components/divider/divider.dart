import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'divider_painter.dart';

export 'divider_painter.dart';

enum _PresetType { none, leaf, star, flower }

/// Animal Island stylized divider with optional leaf/flower ornament or title (C07).
///
/// Features:
/// - Supports [AnimalDividerType.solid], [dashed], [dotted], and [wavy] lines
/// - Built-in presets for cozy island motifs (leaf, star, flower) using [AnimalIcons]
/// - RTL-aware start/end indents
/// - Decorative semantics filtering (suppresses meaningless reader output unless child text is present)
class AnimalDivider extends StatelessWidget {
  /// Line style. Defaults to [AnimalDividerType.dashed].
  final AnimalDividerType type;

  /// Color of the line; null uses a subtle theme border color.
  final Color? color;

  /// Stroke width of the line; must be non-negative. Defaults to 2.
  final double thickness;

  /// Ornament shown in the middle of the line when [child] is null.
  final Widget? icon;

  /// Text or content shown in the middle of the line, styled as a caption.
  ///
  /// Takes precedence over [icon]. A divider with neither is excluded from
  /// semantics.
  final Widget? child;

  /// Space before the line at the start edge; must be non-negative.
  /// Defaults to 0.
  final double indent;

  /// Space after the line at the end edge; must be non-negative.
  /// Defaults to 0.
  final double endIndent;
  final _PresetType _preset;

  /// Creates a divider with an optional [child] or [icon] in the middle.
  const AnimalDivider({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.icon,
    this.child,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : assert(thickness >= 0, 'AnimalDivider thickness must be non-negative.'),
       assert(
         indent >= 0 && endIndent >= 0,
         'AnimalDivider indents must be non-negative.',
       ),
       _preset = _PresetType.none;

  /// Preset for a clean divider line without ornaments.
  const AnimalDivider.plain({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : assert(thickness >= 0, 'AnimalDivider thickness must be non-negative.'),
       assert(
         indent >= 0 && endIndent >= 0,
         'AnimalDivider indents must be non-negative.',
       ),
       icon = null,
       child = null,
       _preset = _PresetType.none;

  /// Preset divider featuring a cute center Leaf icon adapting to theme primary.
  const AnimalDivider.leaf({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : assert(thickness >= 0, 'AnimalDivider thickness must be non-negative.'),
       assert(
         indent >= 0 && endIndent >= 0,
         'AnimalDivider indents must be non-negative.',
       ),
       icon = null,
       child = null,
       _preset = _PresetType.leaf;

  /// Preset divider featuring a cute center Star icon.
  const AnimalDivider.star({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : assert(thickness >= 0, 'AnimalDivider thickness must be non-negative.'),
       assert(
         indent >= 0 && endIndent >= 0,
         'AnimalDivider indents must be non-negative.',
       ),
       icon = null,
       child = null,
       _preset = _PresetType.star;

  /// Preset divider featuring a cute center Flower icon.
  const AnimalDivider.flower({
    super.key,
    this.type = AnimalDividerType.dashed,
    this.color,
    this.thickness = 2.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
  }) : assert(thickness >= 0, 'AnimalDivider thickness must be non-negative.'),
       assert(
         indent >= 0 && endIndent >= 0,
         'AnimalDivider indents must be non-negative.',
       ),
       icon = null,
       child = null,
       _preset = _PresetType.flower;

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveColor =
        color ??
        ((theme.colors.brightness == Brightness.dark)
            ? theme.colors.border.withValues(alpha: 0.5)
            : theme.colors.borderLight);

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final leftIndent = isRtl ? endIndent : indent;
    final rightIndent = isRtl ? indent : endIndent;

    Widget? centerContent;

    switch (_preset) {
      case _PresetType.leaf:
        centerContent = AnimalIcon(
          data: AnimalIcons.leaf,
          size: 18,
          color: theme.colors.primary,
        );
      case _PresetType.star:
        centerContent = AnimalIcon(
          data: AnimalIcons.star,
          size: 18,
          color: theme.colors.warning,
        );
      case _PresetType.flower:
        centerContent = AnimalIcon(
          data: AnimalIcons.flower,
          size: 18,
          color: theme.colors.error,
        );
      case _PresetType.none:
        if (child != null) {
          centerContent = DefaultTextStyle(
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            child: child!,
          );
        } else if (icon != null) {
          centerContent = icon;
        }
    }

    final dividerHeight = type == AnimalDividerType.wavy
        ? 16.0
        : (thickness < 16.0 ? 16.0 : thickness);

    Widget lineWidget = CustomPaint(
      size: Size(double.infinity, dividerHeight),
      painter: AnimalDividerLinePainter(
        type: type,
        color: effectiveColor,
        thickness: thickness,
      ),
    );

    Widget result;
    if (centerContent == null) {
      result = Padding(
        padding: EdgeInsets.only(left: leftIndent, right: rightIndent),
        child: SizedBox(
          height: dividerHeight,
          child: Center(child: lineWidget),
        ),
      );
      // Suppress decorative divider from screen readers (DIV03)
      return ExcludeSemantics(child: result);
    }

    result = Padding(
      padding: EdgeInsets.only(left: leftIndent, right: rightIndent),
      child: Row(
        children: [
          Expanded(child: lineWidget),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing.md),
            child: centerContent,
          ),
          Expanded(child: lineWidget),
        ],
      ),
    );

    // If child is present, preserve semantics of the child
    return result;
  }
}
