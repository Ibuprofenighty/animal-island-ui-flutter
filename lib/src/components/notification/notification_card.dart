import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'notification_queue.dart';

/// Individual notification card widget rendering inside a placement queue.
class AnimalNotificationCard extends StatefulWidget {
  final AnimalNotificationConfig config;
  final VoidCallback onDismiss;
  final VoidCallback onTimeout;

  const AnimalNotificationCard({
    super.key,
    required this.config,
    required this.onDismiss,
    required this.onTimeout,
  });

  @override
  State<AnimalNotificationCard> createState() => AnimalNotificationCardState();
}

class AnimalNotificationCardState extends State<AnimalNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _isPaused = false;
  int _remainingMs = 0;
  DateTime? _lastResumeTime;
  bool _animationInitialized = false;

  bool get isPaused => _isPaused;

  @override
  void initState() {
    super.initState();
    _remainingMs = widget.config.duration.inMilliseconds;
    _startCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = AnimalIslandTheme.of(context);
    final initializeEntrance = !_animationInitialized;
    if (_animationInitialized) {
      _animController.duration = theme.motion.normal;
    } else {
      _animController = AnimationController(
        vsync: this,
        duration: theme.motion.normal,
      );
      _animationInitialized = true;
    }

    final isTop = widget.config.placement.isTop;
    final beginOffset = isTop ? const Offset(0, -0.4) : const Offset(0, 0.4);
    _slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: theme.motion.spring),
        );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: theme.motion.ease,
    );
    if (initializeEntrance) _animController.forward();
  }

  void _startCountdown() {
    _timer?.cancel();
    if (_remainingMs <= 0) return;
    _lastResumeTime = DateTime.now();
    _timer = Timer(Duration(milliseconds: _remainingMs), () {
      if (mounted && !_isPaused) {
        _handleTimeout();
      }
    });
  }

  void pauseTimer() {
    if (_isPaused) return;
    _isPaused = true;
    _timer?.cancel();
    _timer = null;
    if (_lastResumeTime != null) {
      final elapsed = DateTime.now()
          .difference(_lastResumeTime!)
          .inMilliseconds;
      _remainingMs = (_remainingMs - elapsed).clamp(0, 600000);
    }
  }

  void resumeTimer() {
    if (!_isPaused) return;
    _isPaused = false;
    _startCountdown();
  }

  void _handleTimeout() {
    if (!mounted) return;
    _timer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) widget.onTimeout();
    });
  }

  /// Programmatically triggers exit animation and dismissal.
  void close() {
    _handleTimeout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final type = widget.config.type;

    final Color iconColor;
    final Color accentColor;
    final Color cardBg;
    final Color headingColor;
    switch (type) {
      case AnimalNotificationType.info:
        iconColor = theme.colors.infoText;
        accentColor = theme.colors.info;
        cardBg = theme.colors.infoBg;
        headingColor = theme.colors.infoText;
      case AnimalNotificationType.success:
        iconColor = theme.colors.successText;
        accentColor = theme.colors.success;
        cardBg = theme.colors.successBg;
        headingColor = theme.colors.successText;
      case AnimalNotificationType.warning:
        iconColor = theme.colors.warningText;
        accentColor = theme.colors.warning;
        cardBg = theme.colors.warningBg;
        headingColor = theme.colors.warningText;
      case AnimalNotificationType.error:
        iconColor = theme.colors.errorText;
        accentColor = theme.colors.error;
        cardBg = theme.colors.errorBg;
        headingColor = theme.colors.errorText;
    }

    Widget iconWidget;
    if (widget.config.icon != null) {
      iconWidget = widget.config.icon!;
    } else {
      switch (type) {
        case AnimalNotificationType.info:
          iconWidget = AnimalIcon(
            data: AnimalIcons.leaf,
            size: 22,
            color: iconColor,
          );
        case AnimalNotificationType.success:
          iconWidget = AnimalIcon(
            data: AnimalIcons.check,
            size: 22,
            color: iconColor,
          );
        case AnimalNotificationType.warning:
          iconWidget = AnimalIcon(
            data: AnimalIcons.bell,
            size: 22,
            color: iconColor,
          );
        case AnimalNotificationType.error:
          iconWidget = AnimalIcon(
            data: AnimalIcons.close,
            size: 22,
            color: iconColor,
          );
      }
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MouseRegion(
          onEnter: (_) => pauseTimer(),
          onExit: (_) => resumeTimer(),
          child: Focus(
            onFocusChange: (focused) {
              if (focused) {
                pauseTimer();
              } else {
                resumeTimer();
              }
            },
            child: Dismissible(
              key: ValueKey(widget.config.key),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => widget.onDismiss(),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: theme.radii.cardBorder,
                  border: Border.all(color: accentColor, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(
                        alpha: theme.colors.brightness == Brightness.dark
                            ? 0.35
                            : 0.20,
                      ),
                      blurRadius: theme.shadows.softElevation.blurRadius * 3.5,
                      offset: Offset(
                        theme.shadows.softElevation.offset.dx * 3,
                        theme.shadows.softElevation.offset.dy * 3,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildNotificationBody(
                        theme,
                        iconWidget,
                        headingColor,
                      ),
                    ),
                    SizedBox(width: theme.spacing.sm),
                    Padding(
                      padding: EdgeInsets.only(
                        right: theme.spacing.lg + theme.spacing.xs,
                      ),
                      child: _NotificationCloseButton(
                        onClose: _handleTimeout,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBody(
    AnimalIslandTheme theme,
    Widget iconWidget,
    Color headingColor,
  ) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: theme.spacing.xxs),
          child: iconWidget,
        ),
        SizedBox(width: theme.spacing.lg - theme.spacing.xxs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: theme.typography.heading.copyWith(
                  fontSize: theme.typography.heading.fontSize! * 0.75,
                  color: headingColor,
                  fontWeight: FontWeight.w800,
                ),
                child: widget.config.message,
              ),
              if (widget.config.description != null) ...[
                SizedBox(height: theme.spacing.xs),
                DefaultTextStyle(
                  style: theme.typography.body.copyWith(
                    fontSize: theme.typography.body.fontSize! * (13 / 14),
                    color: theme.colors.textBody,
                  ),
                  child: widget.config.description!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
    final padding = EdgeInsets.only(
      left: theme.spacing.lg + theme.spacing.xs,
      top: theme.spacing.lg - theme.spacing.xxs,
      bottom: theme.spacing.lg - theme.spacing.xxs,
    );
    if (widget.config.onClick == null) {
      return Padding(padding: padding, child: content);
    }
    return InteractiveRegion(
      onPressed: widget.config.onClick,
      semanticContainer: true,
      enableHaptics: false,
      surfaceColor: Colors.transparent,
      borderRadius: theme.radii.cardBorder,
      padding: padding,
      child: content,
    );
  }
}

class _NotificationCloseButton extends StatefulWidget {
  final VoidCallback onClose;
  final AnimalIslandTheme theme;

  const _NotificationCloseButton({required this.onClose, required this.theme});

  @override
  State<_NotificationCloseButton> createState() =>
      _NotificationCloseButtonState();
}

class _NotificationCloseButtonState extends State<_NotificationCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InteractiveRegion(
      onPressed: widget.onClose,
      semanticContainer: true,
      enableHaptics: false,
      semanticLabel: AnimalLocalizations.of(context)!.notificationDismissLabel,
      surfaceColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: widget.theme.motion.fast,
          padding: EdgeInsets.all(widget.theme.spacing.xs),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? widget.theme.colors.surfaceAlt
                : Colors.transparent,
          ),
          child: AnimalIcon(
            data: AnimalIcons.close,
            size: 14,
            color: widget.theme.colors.textSecondary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
