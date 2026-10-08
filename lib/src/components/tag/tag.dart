import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/colors.dart';
import '../../foundation/theme/spacing.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';

/// Presentation variants for [AnimalTag].
enum AnimalTagVariant {
  /// Primary accent colors.
  primary,

  /// Success colors.
  success,

  /// Warning colors.
  warning,

  /// Error colors.
  error,

  /// Neutral content surface with the body text color.
  neutral,
}

/// Size of an [AnimalTag].
enum AnimalTagSize {
  /// Compact tag: caption text at 10/12 and a 10 logical-pixel remove icon.
  small,

  /// Default tag: caption text and a 12 logical-pixel remove icon.
  middle,

  /// Large tag: caption text at 14/12 and a 14 logical-pixel remove icon.
  large,
}

/// Metrics of each [AnimalTagSize]. Package-internal: the root library
/// exports the enum without this extension.
extension AnimalTagSizeMetrics on AnimalTagSize {
  /// Size of the remove icon.
  double get iconSize => switch (this) {
    AnimalTagSize.small => 10,
    AnimalTagSize.middle => 12,
    AnimalTagSize.large => 14,
  };

  /// Scale of the caption typography for the label.
  double get fontSizeFactor => switch (this) {
    AnimalTagSize.small => 10 / 12,
    AnimalTagSize.middle => 1,
    AnimalTagSize.large => 14 / 12,
  };

  /// Padding inside the tag, from the theme spacing.
  EdgeInsets padding(AnimalThemeSpacing spacing) => switch (this) {
    AnimalTagSize.small => EdgeInsets.symmetric(
      horizontal: spacing.sm,
      vertical: spacing.xxs,
    ),
    AnimalTagSize.middle => EdgeInsets.symmetric(
      horizontal: spacing.md,
      vertical: spacing.xs,
    ),
    AnimalTagSize.large => EdgeInsets.symmetric(
      horizontal: spacing.lg,
      vertical: spacing.xs + spacing.xxs,
    ),
  };
}

/// Animal Island Pill Tag component.
///
/// Features:
/// - 5 Semantic status variants ([AnimalTagVariant])
/// - 13 Island pastel palette themes ([AnimalTileColor])
/// - 3 Ergonomic sizes: [AnimalTagSize.small], [AnimalTagSize.middle], [AnimalTagSize.large]
/// - Independent focus trees and hit targets for main tag and close button (TAG01)
/// - Strict [disabled] state locking with zero accidental trigger
/// - Accessible semantics: static tags do not impersonate buttons (TAG02)
class AnimalTag extends StatelessWidget {
  /// Content widget displayed inside the tag.
  final Widget child;

  /// Semantic visual styling variant.
  final AnimalTagVariant variant;

  /// Optional island pastel color override.
  final AnimalTileColor? color;

  /// Sizing configuration for height, typography, and padding.
  final AnimalTagSize size;

  /// Whether all interactions on this tag are disabled.
  final bool disabled;

  /// Optional leading icon.
  final Widget? icon;

  /// Callback invoked when the user dismisses the tag via the close button.
  final VoidCallback? onClose;

  /// Callback invoked when the user taps or activates the main tag body.
  final VoidCallback? onTap;

  /// Focus node for the primary tag action.
  final FocusNode? focusNode;

  /// Creates a tag showing [child].
  const AnimalTag({
    super.key,
    required this.child,
    this.variant = AnimalTagVariant.neutral,
    this.color,
    this.size = AnimalTagSize.middle,
    this.disabled = false,
    this.icon,
    this.onClose,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    Color bg;
    Color text;
    Color border;

    if (color != null) {
      final tile = theme.colors.tile(color!);
      bg = theme.colors.brightness == Brightness.dark
          ? tile.background.withValues(alpha: 0.35)
          : tile.background;
      text = tile.foreground;
      border = tile.background.withValues(alpha: 0.8);
    } else {
      switch (variant) {
        case AnimalTagVariant.primary:
          bg = theme.colors.brightness == Brightness.dark
              ? theme.colors.primaryBg.withValues(alpha: 0.25)
              : theme.colors.primaryBg;
          text = theme.colors.primaryText;
          border = theme.colors.brightness == Brightness.dark
              ? theme.colors.primary.withValues(alpha: 0.6)
              : theme.colors.primary;
        case AnimalTagVariant.success:
          bg = theme.colors.brightness == Brightness.dark
              ? theme.colors.successBg.withValues(alpha: 0.25)
              : theme.colors.successBg;
          text = theme.colors.successText;
          border = theme.colors.brightness == Brightness.dark
              ? theme.colors.success.withValues(alpha: 0.6)
              : theme.colors.success;
        case AnimalTagVariant.warning:
          bg = theme.colors.brightness == Brightness.dark
              ? theme.colors.warningBg.withValues(alpha: 0.25)
              : theme.colors.warningBg;
          text = theme.colors.warningText;
          border = theme.colors.brightness == Brightness.dark
              ? theme.colors.warning.withValues(alpha: 0.6)
              : theme.colors.warning;
        case AnimalTagVariant.error:
          bg = theme.colors.brightness == Brightness.dark
              ? theme.colors.errorBg.withValues(alpha: 0.25)
              : theme.colors.errorBg;
          text = theme.colors.errorText;
          border = theme.colors.brightness == Brightness.dark
              ? theme.colors.error.withValues(alpha: 0.6)
              : theme.colors.error;
        case AnimalTagVariant.neutral:
          bg = theme.colors.bgContent;
          text = theme.colors.text;
          border = theme.colors.brightness == Brightness.dark
              ? theme.colors.border
              : theme.colors.borderLight;
      }
    }

    if (disabled) {
      text = theme.colors.textDisabled;
      bg = bg.withValues(alpha: 0.45);
      border = border.withValues(alpha: 0.3);
    }

    // Main tag label & icon
    Widget bodyContent = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, SizedBox(width: theme.spacing.xs)],
        DefaultTextStyle(
          style: theme.typography.caption
              .apply(fontSizeFactor: size.fontSizeFactor)
              .copyWith(color: text, fontWeight: FontWeight.w700),
          child: child,
        ),
      ],
    );

    // If interactive via onTap, wrap body in its own focus and tap target
    final Widget interactiveBody;
    if (onTap != null && !disabled) {
      interactiveBody = InteractiveRegion(
        onPressed: onTap,
        enableHaptics: false,
        focusNode: focusNode,
        surfaceColor: Colors.transparent,
        child: bodyContent,
      );
    } else {
      interactiveBody = bodyContent;
    }

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: Container(
        padding: size.padding(theme.spacing),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: theme.radii.pillBorder,
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            interactiveBody,
            if (onClose != null && !disabled) ...[
              SizedBox(width: theme.spacing.xs),
              AnimalIconAction(
                onPressed: onClose!,
                semanticLabel: AnimalLocalizations.of(context)!.tagRemoveLabel,
                padding: EdgeInsets.zero,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                backgroundColor: resolveIconActionBackground(
                  null,
                  idle: Colors.transparent,
                  hovered: Colors.transparent,
                ),
                icon: AnimalIcon(
                  data: AnimalIcons.close,
                  size: size.iconSize,
                  color: text,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
