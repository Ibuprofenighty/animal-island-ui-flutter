import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/notification_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icon_data.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/timing/motion_policy.dart';
import 'notification_model.dart';

/// Presentation of one notification occurrence.
///
/// The card owns only its entrance animation and the hover/focus signal; the
/// queue owns status and timing. [onPausedChanged] reports whether a pointer
/// hovers the card or focus is inside it. With reduced motion the card
/// appears in place without sliding or fading.
class AnimalNotificationCard extends StatefulWidget {
  final AnimalNotificationConfig config;
  final VoidCallback onClose;
  final ValueChanged<bool> onPausedChanged;

  const AnimalNotificationCard({
    super.key,
    required this.config,
    required this.onClose,
    required this.onPausedChanged,
  });

  @override
  State<AnimalNotificationCard> createState() => _AnimalNotificationCardState();
}

class _AnimalNotificationCardState extends State<AnimalNotificationCard>
    with SingleTickerProviderStateMixin {
  // Entrance slide distance, as a fraction of the card height.
  static const double _slideFraction = 0.4;

  final Key _dismissKey = UniqueKey();
  AnimationController? _entrance;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  bool _hovered = false;
  bool _focused = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = AnimalIslandTheme.of(context).motion;
    AnimationController? entrance = _entrance;
    final bool firstRun = entrance == null;
    if (entrance == null) {
      entrance = AnimationController(vsync: this, duration: motion.normal);
      _entrance = entrance;
    } else {
      entrance.duration = motion.normal;
    }
    final Offset begin = Offset(
      0,
      widget.config.placement.isTop ? -_slideFraction : _slideFraction,
    );
    _slide = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: entrance, curve: motion.spring));
    _fade = CurvedAnimation(parent: entrance, curve: motion.ease);
    if (!firstRun) return;
    if (AnimalMotionPolicy.shouldAnimate(context)) {
      entrance.forward();
    } else {
      entrance.value = 1;
    }
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    _hovered = value;
    widget.onPausedChanged(_hovered || _focused);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    _focused = value;
    widget.onPausedChanged(_hovered || _focused);
  }

  @override
  void dispose() {
    _entrance?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimalNotificationConfig config = widget.config;
    final _ResolvedNotificationStyle resolved =
        _ResolvedNotificationStyle.resolve(
          theme: AnimalIslandTheme.of(context),
          type: config.type,
          style: config.style,
        );

    final Widget icon =
        config.icon ??
        AnimalIcon(
          data: _iconFor(config.type),
          size: resolved.iconSize,
          color: resolved.iconColor,
        );

    final Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: resolved.iconPadding, child: icon),
        SizedBox(width: resolved.iconGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: resolved.textStyle,
                child: config.message,
              ),
              if (config.description case final Widget description) ...[
                SizedBox(height: resolved.descriptionGap),
                DefaultTextStyle(
                  style: resolved.descriptionTextStyle,
                  child: description,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final VoidCallback? onClick = config.onClick;
    final Widget body = onClick == null
        ? Padding(padding: resolved.padding, child: content)
        : InteractiveRegion(
            onPressed: onClick,
            semanticContainer: true,
            enableHaptics: false,
            surfaceColor: Colors.transparent,
            borderRadius: resolved.borderRadius,
            padding: resolved.padding,
            child: content,
          );

    return Padding(
      padding: EdgeInsets.only(bottom: resolved.gap),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          // Keep the live region in the tree from the first frame so it is
          // announced once, not when the fade crosses zero.
          alwaysIncludeSemantics: true,
          child: MouseRegion(
            onEnter: (_) => _setHovered(true),
            onExit: (_) => _setHovered(false),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: _setFocused,
              child: Dismissible(
                key: _dismissKey,
                direction: DismissDirection.horizontal,
                onDismissed: (_) => widget.onClose(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: resolved.maxWidth),
                  // One live region per card: assistive technology announces
                  // the notification when it appears or its content changes,
                  // not on every animation frame.
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    child: Container(
                      decoration: BoxDecoration(
                        color: resolved.backgroundColor,
                        borderRadius: resolved.borderRadius,
                        border: Border.all(
                          color: resolved.borderColor,
                          width: resolved.borderWidth,
                        ),
                        boxShadow: [resolved.shadow],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: body),
                          SizedBox(width: resolved.closeButtonGap),
                          Padding(
                            padding: resolved.closeButtonMargin,
                            child: AnimalIconAction(
                              onPressed: widget.onClose,
                              semanticLabel: AnimalLocalizations.of(context)!
                                  .notificationDismissLabel,
                              padding: resolved.closeButtonPadding,
                              borderRadius: resolved.closeButtonBorderRadius,
                              backgroundColor:
                                  resolved.closeButtonBackgroundColor,
                              icon: AnimalIcon(
                                data: AnimalIcons.close,
                                size: resolved.closeIconSize,
                                color: resolved.closeIconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static AnimalIconData _iconFor(AnimalNotificationType type) => switch (type) {
    AnimalNotificationType.info => AnimalIcons.leaf,
    AnimalNotificationType.success => AnimalIcons.check,
    AnimalNotificationType.warning => AnimalIcons.bell,
    AnimalNotificationType.error => AnimalIcons.close,
  };
}

/// The single resolution of a notification card's visuals.
///
/// Precedence: the notification's own style, then
/// `AnimalIslandTheme.components.notification`, then defaults derived from
/// the theme tokens and the notification type.
class _ResolvedNotificationStyle {
  final double maxWidth;
  final double gap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry iconPadding;
  final double iconSize;
  final double iconGap;
  final double descriptionGap;
  final double closeButtonGap;
  final EdgeInsetsGeometry closeButtonMargin;
  final EdgeInsetsGeometry closeButtonPadding;
  final double closeIconSize;
  final BorderRadius closeButtonBorderRadius;
  final TextStyle textStyle;
  final TextStyle descriptionTextStyle;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color closeIconColor;
  final WidgetStateProperty<Color> closeButtonBackgroundColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final BoxShadow shadow;

  const _ResolvedNotificationStyle._({
    required this.maxWidth,
    required this.gap,
    required this.padding,
    required this.iconPadding,
    required this.iconSize,
    required this.iconGap,
    required this.descriptionGap,
    required this.closeButtonGap,
    required this.closeButtonMargin,
    required this.closeButtonPadding,
    required this.closeIconSize,
    required this.closeButtonBorderRadius,
    required this.textStyle,
    required this.descriptionTextStyle,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.closeIconColor,
    required this.closeButtonBackgroundColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.shadow,
  });

  // Registered default invariants.
  static const double _defaultMaxWidth = 380;
  static const double _defaultIconSize = 22;
  static const double _defaultCloseIconSize = 14;
  static const double _defaultBorderWidth = 2;
  static const BorderRadius _defaultCloseButtonBorderRadius = BorderRadius.all(
    Radius.circular(24),
  );
  static const double _messageScale = 0.75;
  static const double _descriptionScale = 13 / 14;
  static const double _closeIconAlpha = 0.8;
  static const double _shadowAlphaLight = 0.20;
  static const double _shadowAlphaDark = 0.35;
  static const double _shadowBlurScale = 3.5;
  static const double _shadowOffsetScale = 3;

  static _ResolvedNotificationStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalNotificationType type,
    required AnimalNotificationStyle? style,
  }) {
    final AnimalNotificationStyle merged = (style ?? AnimalNotificationStyle())
        .merge(theme.components.notification);
    final colors = theme.colors;
    final spacing = theme.spacing;

    final ({Color text, Color accent, Color background}) palette =
        switch (type) {
          AnimalNotificationType.info => (
            text: colors.infoText,
            accent: colors.info,
            background: colors.infoBg,
          ),
          AnimalNotificationType.success => (
            text: colors.successText,
            accent: colors.success,
            background: colors.successBg,
          ),
          AnimalNotificationType.warning => (
            text: colors.warningText,
            accent: colors.warning,
            background: colors.warningBg,
          ),
          AnimalNotificationType.error => (
            text: colors.errorText,
            accent: colors.error,
            background: colors.errorBg,
          ),
        };

    final Color textColor = merged.textColor ?? palette.text;
    final Color borderColor = merged.borderColor ?? palette.accent;
    final BoxShadow soft = theme.shadows.softElevation;
    final BoxShadow defaultShadow = BoxShadow(
      color: palette.accent.withValues(
        alpha: colors.brightness == Brightness.dark
            ? _shadowAlphaDark
            : _shadowAlphaLight,
      ),
      blurRadius: soft.blurRadius * _shadowBlurScale,
      offset: soft.offset * _shadowOffsetScale,
    );

    final TextStyle message = theme.typography.resolve(
      theme.typography.heading
          .apply(fontSizeFactor: _messageScale)
          .copyWith(fontWeight: FontWeight.w800)
          .merge(merged.textStyle)
          .copyWith(color: textColor),
    );
    final TextStyle description = theme.typography.resolve(
      theme.typography.body
          .apply(fontSizeFactor: _descriptionScale)
          .merge(merged.descriptionTextStyle)
          .copyWith(color: merged.descriptionTextColor ?? colors.textBody),
    );

    return _ResolvedNotificationStyle._(
      maxWidth: merged.maxWidth ?? _defaultMaxWidth,
      gap: merged.gap ?? spacing.sm + spacing.xxs / 2,
      padding:
          merged.padding ??
          EdgeInsets.only(
            left: spacing.lg + spacing.xs,
            top: spacing.lg - spacing.xxs,
            bottom: spacing.lg - spacing.xxs,
          ),
      iconPadding: merged.iconPadding ?? EdgeInsets.only(top: spacing.xxs),
      iconSize: merged.iconSize ?? _defaultIconSize,
      iconGap: merged.iconGap ?? spacing.lg - spacing.xxs,
      descriptionGap: merged.descriptionGap ?? spacing.xs,
      closeButtonGap: merged.closeButtonGap ?? spacing.sm,
      closeButtonMargin:
          merged.closeButtonMargin ??
          EdgeInsets.only(right: spacing.lg + spacing.xs),
      closeButtonPadding:
          merged.closeButtonPadding ?? EdgeInsets.all(spacing.xs),
      closeIconSize: merged.closeIconSize ?? _defaultCloseIconSize,
      closeButtonBorderRadius:
          merged.closeButtonBorderRadius ?? _defaultCloseButtonBorderRadius,
      textStyle: message,
      descriptionTextStyle: description,
      backgroundColor: merged.backgroundColor ?? palette.background,
      borderColor: borderColor,
      iconColor: merged.iconColor ?? palette.text,
      closeIconColor:
          merged.closeIconColor ??
          colors.textSecondary.withValues(alpha: _closeIconAlpha),
      closeButtonBackgroundColor: resolveIconActionBackground(
        merged.closeButtonBackgroundColor,
        idle: Colors.transparent,
        hovered: colors.surfaceAlt,
      ),
      borderWidth: merged.borderWidth ?? _defaultBorderWidth,
      borderRadius: merged.borderRadius ?? theme.radii.cardBorder,
      shadow: merged.shadow ?? defaultShadow,
    );
  }
}
