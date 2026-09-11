import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';

enum AnimalTagVariant {
  primary(AnimalColors.primaryBg, AnimalColors.primaryActive, AnimalColors.primary),
  success(Color(0xFFEDF8E5), AnimalColors.successActive, AnimalColors.success),
  warning(Color(0xFFFFF9E5), AnimalColors.warningActive, AnimalColors.warning),
  error(Color(0xFFFFECEC), AnimalColors.errorActive, AnimalColors.error),
  neutral(AnimalColors.bgContent, AnimalColors.text, AnimalColors.borderLight);

  final Color background;
  final Color textColor;
  final Color borderColor;

  const AnimalTagVariant(this.background, this.textColor, this.borderColor);
}

enum AnimalTagSize {
  small(20.0, 11.0, EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0), 10.0),
  middle(24.0, 12.0, EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), 12.0),
  large(28.0, 14.0, EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0), 14.0);

  final double height;
  final double fontSize;
  final EdgeInsets padding;
  final double iconSize;

  const AnimalTagSize(this.height, this.fontSize, this.padding, this.iconSize);
}

/// Animal Island Pill Tag component.
///
/// Supports:
/// - 5 Semantic status variants ([AnimalTagVariant])
/// - 13 Island pastel palette themes ([AnimalTileColor])
/// - 3 Sizes: [AnimalTagSize.small], [AnimalTagSize.middle], [AnimalTagSize.large]
/// - [disabled] state with reduced opacity and interaction locking
/// - Custom leading [icon] and optional dismissible [onClose] button
class AnimalTag extends StatelessWidget {
  final Widget child;
  final AnimalTagVariant variant;
  final AnimalTileColor? color;
  final AnimalTagSize size;
  final bool disabled;
  final Widget? icon;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

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
      bg = theme.isDark ? color!.background.withValues(alpha: 0.35) : color!.background;
      text = color!.text;
      border = color!.background.withValues(alpha: 0.8);
    } else {
      switch (variant) {
        case AnimalTagVariant.primary:
          bg = theme.isDark ? theme.primaryBg.withValues(alpha: 0.25) : theme.primaryBg;
          text = theme.primaryActive;
          border = theme.isDark ? theme.primary.withValues(alpha: 0.6) : theme.primary;
        case AnimalTagVariant.success:
          bg = theme.isDark ? theme.successBg.withValues(alpha: 0.25) : theme.successBg;
          text = theme.successActive;
          border = theme.isDark ? theme.success.withValues(alpha: 0.6) : theme.success;
        case AnimalTagVariant.warning:
          bg = theme.isDark ? theme.warningBg.withValues(alpha: 0.25) : theme.warningBg;
          text = theme.warningActive;
          border = theme.isDark ? theme.warning.withValues(alpha: 0.6) : theme.warning;
        case AnimalTagVariant.error:
          bg = theme.isDark ? theme.errorBg.withValues(alpha: 0.25) : theme.errorBg;
          text = theme.errorActive;
          border = theme.isDark ? theme.error.withValues(alpha: 0.6) : theme.error;
        case AnimalTagVariant.neutral:
          bg = theme.bgContent;
          text = theme.text;
          border = theme.isDark ? theme.border : theme.borderLight;
      }
    }

    if (disabled) {
      text = theme.textDisabled;
      bg = bg.withValues(alpha: 0.45);
      border = border.withValues(alpha: 0.3);
    }

    Widget tag = Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: Container(
        padding: size.padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AnimalRadii.pillBorder,
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 4.0),
            ],
            DefaultTextStyle(
              style: AnimalTypography.caption.copyWith(
                color: text,
                fontSize: size.fontSize,
                fontWeight: FontWeight.w700,
              ),
              child: child,
            ),
            if (onClose != null && !disabled) ...[
              const SizedBox(width: 4.0),
              _TagCloseButton(
                onClose: onClose!,
                iconSize: size.iconSize,
                color: text,
                theme: theme,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap != null && !disabled) {
      return Semantics(
        button: true,
        enabled: true,
        child: FocusableActionDetector(
          focusNode: focusNode,
          enabled: true,
          mouseCursor: SystemMouseCursors.click,
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                onTap!();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: tag,
          ),
        ),
      );
    }
    return tag;
  }
}

class _TagCloseButton extends StatefulWidget {
  final VoidCallback onClose;
  final double iconSize;
  final Color color;
  final AnimalIslandTheme theme;

  const _TagCloseButton({
    required this.onClose,
    required this.iconSize,
    required this.color,
    required this.theme,
  });

  @override
  State<_TagCloseButton> createState() => _TagCloseButtonState();
}

class _TagCloseButtonState extends State<_TagCloseButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (f) => setState(() => _isFocused = f),
      mouseCursor: SystemMouseCursors.click,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onClose(),
        ),
      },
      child: Semantics(
        button: true,
        label: 'Remove tag',
        child: GestureDetector(
          onTap: widget.onClose,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isFocused ? widget.theme.focusYellow : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.theme.focusYellow.withValues(alpha: 0.6),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: CloseIcon(size: widget.iconSize, color: widget.color),
          ),
        ),
      ),
    );
  }
}

