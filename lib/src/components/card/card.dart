import 'package:flutter/material.dart';

import '../../foundation/theme/colors.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import 'card_pattern_painter.dart';
import 'card_style.dart';

export 'card_style.dart';

/// Animal Island themed-radius Card (C05).
///
/// Strictly adheres to canonical design laws and decisions:
/// - Theme-owned card border radius
/// - Hard rule 8: Card has NO default box-shadow; lifts with translateY(-2px) when [hoverable] is true
/// - Supports 13 Island app-tile color themes or custom background/border
/// - Supports dashed border and organic patterns (dots, sprinkles, stripes)
/// - Eliminated [patterned] boolean redundancy (pattern = [AnimalCardPattern.none] turns it off)
/// - Single layout pipeline for all variations; separate header/footer dividers
/// - Full keyboard accessibility when interactive (Tab to focus, Space / Enter to activate when [onTap] is provided)
/// - No button semantics if non-interactive
class AnimalCard extends StatefulWidget {
  /// Body content of the card.
  final Widget child;

  /// Optional header widget rendered above [child], separated by a subtle divider.
  final Widget? header;

  /// Optional footer widget rendered below [child], separated by a subtle divider.
  final Widget? footer;

  /// Card border style. Default is [AnimalCardType.defaultCard].
  final AnimalCardType type;

  /// Island app-tile color theme. Default is [AnimalTileColor.def].
  final AnimalTileColor color;

  /// Background decorative pattern. Default is [AnimalCardPattern.none].
  final AnimalCardPattern pattern;

  /// Custom background color override.
  final Color? customBackgroundColor;

  /// Custom border color override.
  final Color? customBorderColor;

  /// Inner padding override for content. Defaults to the active theme spacing.
  final EdgeInsetsGeometry? padding;

  /// Tap callback making the card interactive.
  final VoidCallback? onTap;

  /// Whether the card performs an elevation lift on hover. Default is false.
  final bool hoverable;

  /// Optional custom border radius overriding default card radius.
  final BorderRadius? borderRadius;

  /// Outer margin surrounding the card.
  final EdgeInsetsGeometry? margin;

  /// Optional accessible label for screen readers.
  final String? semanticLabel;

  /// Creates a card around [child].
  const AnimalCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.type = AnimalCardType.defaultCard,
    this.color = AnimalTileColor.def,
    this.pattern = AnimalCardPattern.none,
    this.customBackgroundColor,
    this.customBorderColor,
    this.padding,
    this.onTap,
    this.hoverable = false,
    this.borderRadius,
    this.margin,
    this.semanticLabel,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final padding =
        widget.padding ?? EdgeInsets.all(theme.spacing.lg + theme.spacing.xs);
    final isDefault = widget.color == AnimalTileColor.def;
    final tile = theme.colors.tile(widget.color);
    final bgColor =
        widget.customBackgroundColor ??
        (isDefault ? theme.colors.bgContent : tile.background);
    final defaultTextColor = isDefault
        ? theme.colors.textBody
        : tile.foreground;
    final hasPattern = widget.pattern != AnimalCardPattern.none;

    final borderColor =
        widget.customBorderColor ??
        (hasPattern
            ? defaultTextColor.withValues(alpha: 0.25)
            : ((theme.colors.brightness == Brightness.dark)
                  ? theme.colors.border.withValues(alpha: 0.4)
                  : theme.colors.borderLight.withValues(alpha: 0.6)));

    final isInteractive = widget.hoverable || widget.onTap != null;
    final double offsetY = (_isHovered && isInteractive) ? -2.0 : 0.0;

    Widget coreContent = DefaultTextStyle(
      style: theme.typography.body.copyWith(color: defaultTextColor),
      child: widget.child,
    );

    // Assemble header, content, and footer
    if (widget.header != null || widget.footer != null) {
      final dividerColor = defaultTextColor.withValues(alpha: 0.12);
      coreContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) ...[
            Padding(
              padding: padding,
              child: DefaultTextStyle(
                style: theme.typography.heading.copyWith(
                  color: defaultTextColor,
                ),
                child: widget.header!,
              ),
            ),
            Container(height: 1.0, color: dividerColor),
          ],
          Padding(padding: padding, child: coreContent),
          if (widget.footer != null) ...[
            Container(height: 1.0, color: dividerColor),
            Padding(
              padding: padding,
              child: DefaultTextStyle(
                style: theme.typography.caption.copyWith(
                  color: defaultTextColor,
                ),
                child: widget.footer!,
              ),
            ),
          ],
        ],
      );
    } else {
      coreContent = Padding(padding: padding, child: coreContent);
    }

    // Pattern painter overlay
    Widget decoratedCard = CustomPaint(
      painter: AnimalCardPatternPainter(
        pattern: widget.pattern,
        patternColor: defaultTextColor.withValues(alpha: 0.12),
        radius: widget.borderRadius?.topLeft.x ?? theme.radii.card,
      ),
      child: coreContent,
    );

    // Dashed border overlay if requested
    if (widget.type == AnimalCardType.dashed) {
      decoratedCard = CustomPaint(
        foregroundPainter: AnimalCardDashedBorderPainter(
          color: borderColor,
          strokeWidth: 1.8,
          radius: widget.borderRadius?.topLeft.x ?? theme.radii.card,
        ),
        child: decoratedCard,
      );
    }

    final effectiveRadius = widget.borderRadius ?? theme.radii.cardBorder;

    // Build container box with no default box-shadow (Rule 8)
    Widget cardBox = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveRadius,
        border: widget.type == AnimalCardType.defaultCard
            ? Border.all(color: borderColor, width: 1.5)
            : null,
      ),
      child: ClipRRect(borderRadius: effectiveRadius, child: decoratedCard),
    );

    // Hover translation
    cardBox = AnimatedContainer(
      duration: theme.motion.fast,
      curve: theme.motion.ease,
      transform: Matrix4.translationValues(0, offsetY, 0),
      child: cardBox,
    );

    if (widget.onTap != null) {
      return InteractiveRegion(
        onPressed: widget.onTap,
        enableHaptics: false,
        semanticLabel: widget.semanticLabel,
        semanticContainer: true,
        borderRadius: effectiveRadius,
        child: MouseRegion(
          onEnter: (_) {
            if (isInteractive) setState(() => _isHovered = true);
          },
          onExit: (_) {
            if (isInteractive) setState(() => _isHovered = false);
          },
          child: cardBox,
        ),
      );
    }

    if (widget.hoverable) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: cardBox,
      );
    }

    return cardBox;
  }
}
