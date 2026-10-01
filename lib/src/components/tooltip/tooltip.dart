import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';
import 'tooltip_shape.dart';

/// Style variants for [AnimalTooltip].
enum AnimalTooltipVariant {
  /// Standard cozy 16px-radius rounded rectangle tooltip.
  standard,

  /// Organic speech bubble with pointer arrow beak.
  island,
}

/// Animal Island speech bubble and hint Tooltip (C23).
///
/// Features:
/// - Single canonical payload construction (F04 fix: mutually exclusive message and richMessage)
/// - Theme-scaled rounded rectangle or organic speech bubble with pointing arrow
/// - Themed borders, shadows, and accessible touch/hover/focus activation
class AnimalTooltip extends StatelessWidget {
  /// The widget that triggers this tooltip upon hover, tap, or focus.
  final Widget child;

  /// Explanatory text displayed inside the tooltip.
  final String message;

  /// Optional header widget displayed above [message].
  final Widget? title;

  /// Visual shape variant of the tooltip bubble.
  final AnimalTooltipVariant variant;

  /// Whether to render a visible outer border.
  final bool bordered;

  /// How this tooltip is activated (tap, longPress, hover).
  final TooltipTriggerMode triggerMode;

  /// Delay duration before showing tooltip.
  final Duration waitDuration;

  /// Duration for which tooltip remains visible after trigger.
  final Duration showDuration;

  const AnimalTooltip({
    super.key,
    required this.child,
    required this.message,
    this.title,
    this.variant = AnimalTooltipVariant.standard,
    this.bordered = true,
    this.triggerMode = TooltipTriggerMode.tap,
    this.waitDuration = const Duration(milliseconds: 300),
    this.showDuration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final borderColor = theme.colors.brightness == Brightness.dark
        ? theme.colors.border
        : theme.colors.borderLight;

    final Decoration decoration = variant == AnimalTooltipVariant.island
        ? ShapeDecoration(
            color: theme.colors.bgContent,
            shadows: [theme.shadows.softElevation],
            shape: AnimalIslandBubbleShapeBorder(
              borderColor: bordered ? borderColor : Colors.transparent,
              borderWidth: bordered ? 1.5 : 0.0,
              radius: theme.radii.tooltip,
              arrowSize: 6.0,
            ),
          )
        : BoxDecoration(
            color: theme.colors.bgContent,
            borderRadius: theme.radii.tooltipBorder,
            border: bordered
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            boxShadow: [theme.shadows.softElevation],
          );

    // Defect F04 fix: Flutter's Tooltip strictly requires:
    // assert((message == null) != (richMessage == null), 'Do not supply both message and richMessage.')
    // When title is provided, message MUST be null and richMessage holds the combined span.
    final bool hasTitle = title != null;
    final String? effectiveMessage = hasTitle ? null : message;
    final InlineSpan? effectiveRichMessage = hasTitle
        ? TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: DefaultTextStyle(
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: theme.typography.caption.fontSize! * (13 / 12),
                  ),
                  child: title!,
                ),
              ),
              if (message.isNotEmpty) ...[
                const TextSpan(text: '\n'),
                TextSpan(
                  text: message,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.textBody,
                    fontWeight: FontWeight.w500,
                    fontSize: theme.typography.caption.fontSize,
                  ),
                ),
              ],
            ],
          )
        : null;

    return Tooltip(
      message: effectiveMessage,
      richMessage: effectiveRichMessage,
      triggerMode: triggerMode,
      waitDuration: waitDuration,
      showDuration: showDuration,
      padding: EdgeInsets.fromLTRB(
        theme.spacing.md + theme.spacing.xxs,
        theme.spacing.sm,
        theme.spacing.md + theme.spacing.xxs,
        variant == AnimalTooltipVariant.island
            ? theme.spacing.md + theme.spacing.xxs
            : theme.spacing.sm,
      ),
      decoration: decoration,
      textStyle: theme.typography.caption.copyWith(
        color: theme.colors.text,
        fontWeight: FontWeight.w700,
        fontSize: theme.typography.caption.fontSize! * (13 / 12),
      ),
      child: child,
    );
  }
}
