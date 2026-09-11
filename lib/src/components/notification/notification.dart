import 'dart:async';
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';

/// Semantic types for notifications matching animal-island-ui.
enum AnimalNotificationType {
  info(Color(0xFFE6F7F5), AnimalColors.primary, AnimalColors.primary),
  success(Color(0xFFEDF8E5), AnimalColors.successActive, AnimalColors.success),
  warning(Color(0xFFFFF9E5), AnimalColors.warningActive, AnimalColors.warning),
  error(Color(0xFFFFECEC), AnimalColors.errorActive, AnimalColors.error);

  final Color bg;
  final Color text;
  final Color iconColor;

  const AnimalNotificationType(this.bg, this.text, this.iconColor);
}

/// Screen placement positions matching animal-island-ui.
enum AnimalNotificationPlacement {
  topRight,
  topLeft,
  top,
  bottomRight,
  bottomLeft,
  bottom,
}

/// Configuration data model for an individual notification.
class AnimalNotificationConfig {
  final String key;
  final Widget message;
  final Widget? description;
  final AnimalNotificationType type;
  final Duration duration;
  final AnimalNotificationPlacement placement;
  final Widget? icon;
  final VoidCallback? onClose;
  final VoidCallback? onClick;

  AnimalNotificationConfig({
    String? key,
    required this.message,
    this.description,
    this.type = AnimalNotificationType.info,
    this.duration = const Duration(milliseconds: 4500),
    this.placement = AnimalNotificationPlacement.topRight,
    this.icon,
    this.onClose,
    this.onClick,
  }) : key = key ?? UniqueKey().toString();
}

/// SOTA Global Overlay Notification Portal for Animal Island UI.
///
/// Features:
/// - Zero dependency on [ScaffoldMessenger] or [Scaffold]
/// - Operates directly on the root [Overlay]
/// - 6 directional anchor placements with smooth queue stacking
/// - Hover-to-pause countdown timer
/// - Horizontal swipe-to-dismiss gesture
/// - Full theme-aware styling (Parchment & Campfire Night)
/// - Race-condition safe lifecycle & setState protection
class AnimalNotification {
  static final Map<AnimalNotificationPlacement, _NotificationQueueState> _activeQueues = {};
  static final Map<AnimalNotificationPlacement, OverlayEntry> _activeEntries = {};

  /// Cleans all queues and overlays, useful for test teardown or hot reload reset.
  static void reset() {
    for (final entry in _activeEntries.values) {
      entry.remove();
    }
    _activeEntries.clear();
    _activeQueues.clear();
  }

  /// Opens a notification with full configuration options.
  static void open(
    BuildContext context, {
    required Widget message,
    Widget? description,
    AnimalNotificationType type = AnimalNotificationType.info,
    Duration duration = const Duration(milliseconds: 4500),
    AnimalNotificationPlacement placement = AnimalNotificationPlacement.topRight,
    Widget? icon,
    String? key,
    VoidCallback? onClose,
    VoidCallback? onClick,
  }) {
    final config = AnimalNotificationConfig(
      key: key,
      message: message,
      description: description,
      type: type,
      duration: duration,
      placement: placement,
      icon: icon,
      onClose: onClose,
      onClick: onClick,
    );

    _dispatch(context, config);
  }

  /// Convenience method to show a Success notification.
  static void success(
    BuildContext context, {
    required String message,
    String? description,
    Duration duration = const Duration(milliseconds: 4500),
    AnimalNotificationPlacement placement = AnimalNotificationPlacement.topRight,
    VoidCallback? onClose,
    VoidCallback? onClick,
  }) {
    open(
      context,
      message: Text(message),
      description: description != null ? Text(description) : null,
      type: AnimalNotificationType.success,
      duration: duration,
      placement: placement,
      onClose: onClose,
      onClick: onClick,
    );
  }

  /// Convenience method to show an Error notification.
  static void error(
    BuildContext context, {
    required String message,
    String? description,
    Duration duration = const Duration(milliseconds: 4500),
    AnimalNotificationPlacement placement = AnimalNotificationPlacement.topRight,
    VoidCallback? onClose,
    VoidCallback? onClick,
  }) {
    open(
      context,
      message: Text(message),
      description: description != null ? Text(description) : null,
      type: AnimalNotificationType.error,
      duration: duration,
      placement: placement,
      onClose: onClose,
      onClick: onClick,
    );
  }

  /// Convenience method to show a Warning notification.
  static void warning(
    BuildContext context, {
    required String message,
    String? description,
    Duration duration = const Duration(milliseconds: 4500),
    AnimalNotificationPlacement placement = AnimalNotificationPlacement.topRight,
    VoidCallback? onClose,
    VoidCallback? onClick,
  }) {
    open(
      context,
      message: Text(message),
      description: description != null ? Text(description) : null,
      type: AnimalNotificationType.warning,
      duration: duration,
      placement: placement,
      onClose: onClose,
      onClick: onClick,
    );
  }

  /// Convenience method to show an Info notification.
  static void info(
    BuildContext context, {
    required String message,
    String? description,
    Duration duration = const Duration(milliseconds: 4500),
    AnimalNotificationPlacement placement = AnimalNotificationPlacement.topRight,
    VoidCallback? onClose,
    VoidCallback? onClick,
  }) {
    open(
      context,
      message: Text(message),
      description: description != null ? Text(description) : null,
      type: AnimalNotificationType.info,
      duration: duration,
      placement: placement,
      onClose: onClose,
      onClick: onClick,
    );
  }

  /// Dismisses all notifications, or a specific notification by [key].
  static void destroy([String? key]) {
    final queues = _activeQueues.values.toList();
    for (final queue in queues) {
      queue.dismiss(key);
    }
  }

  static void _dispatch(BuildContext context, AnimalNotificationConfig config) {
    final placement = config.placement;

    final existingQueue = _activeQueues[placement];
    if (existingQueue != null && existingQueue.mounted) {
      existingQueue.add(config);
      return;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        return _NotificationQueueContainer(
          placement: placement,
          onStateReady: (state) {
            _activeQueues[placement] = state;
            state.add(config);
          },
          onEmpty: () {
            _activeQueues.remove(placement);
            final activeEntry = _activeEntries.remove(placement);
            activeEntry?.remove();
          },
        );
      },
    );

    _activeEntries[placement] = entry;
    overlay.insert(entry);
  }
}

class _NotificationQueueContainer extends StatefulWidget {
  final AnimalNotificationPlacement placement;
  final ValueChanged<_NotificationQueueState> onStateReady;
  final VoidCallback onEmpty;

  const _NotificationQueueContainer({
    required this.placement,
    required this.onStateReady,
    required this.onEmpty,
  });

  @override
  State<_NotificationQueueContainer> createState() => _NotificationQueueState();
}

class _NotificationQueueState extends State<_NotificationQueueContainer> {
  final List<AnimalNotificationConfig> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onStateReady(this);
      }
    });
  }

  void add(AnimalNotificationConfig config) {
    if (!mounted) return;
    setState(() {
      _items.removeWhere((item) => item.key == config.key);
      _items.add(config);
    });
  }

  void dismiss([String? key]) {
    if (!mounted) return;
    setState(() {
      if (key == null) {
        _items.clear();
      } else {
        _items.removeWhere((item) => item.key == key);
      }
    });
    if (_items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _items.isEmpty) {
          widget.onEmpty();
        }
      });
    }
  }

  void _removeConfig(AnimalNotificationConfig config) {
    config.onClose?.call();
    dismiss(config.key);
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    Alignment alignment;
    EdgeInsets padding;

    switch (widget.placement) {
      case AnimalNotificationPlacement.topRight:
        alignment = Alignment.topRight;
        padding = const EdgeInsets.only(top: 24, right: 24);
      case AnimalNotificationPlacement.topLeft:
        alignment = Alignment.topLeft;
        padding = const EdgeInsets.only(top: 24, left: 24);
      case AnimalNotificationPlacement.top:
        alignment = Alignment.topCenter;
        padding = const EdgeInsets.only(top: 24);
      case AnimalNotificationPlacement.bottomRight:
        alignment = Alignment.bottomRight;
        padding = const EdgeInsets.only(bottom: 24, right: 24);
      case AnimalNotificationPlacement.bottomLeft:
        alignment = Alignment.bottomLeft;
        padding = const EdgeInsets.only(bottom: 24, left: 24);
      case AnimalNotificationPlacement.bottom:
        alignment = Alignment.bottomCenter;
        padding = const EdgeInsets.only(bottom: 24);
    }

    final isBottom = widget.placement == AnimalNotificationPlacement.bottomRight ||
        widget.placement == AnimalNotificationPlacement.bottomLeft ||
        widget.placement == AnimalNotificationPlacement.bottom;

    final displayItems = isBottom ? _items.reversed.toList() : _items;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 380,
              maxHeight: screenHeight - 64,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: displayItems.map((item) {
                  return Padding(
                    key: ValueKey(item.key),
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _AnimalNotificationCard(
                      config: item,
                      onDismiss: () => _removeConfig(item),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalNotificationCard extends StatefulWidget {
  final AnimalNotificationConfig config;
  final VoidCallback onDismiss;

  const _AnimalNotificationCard({
    required this.config,
    required this.onDismiss,
  });

  @override
  State<_AnimalNotificationCard> createState() => _AnimalNotificationCardState();
}

class _AnimalNotificationCardState extends State<_AnimalNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;
  int _remainingMs = 0;
  DateTime? _lastStartTime;

  @override
  void initState() {
    super.initState();
    _remainingMs = widget.config.duration.inMilliseconds;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));

    _animController.forward();
    _startTimer();
  }

  void _startTimer() {
    if (_remainingMs <= 0) return;
    _lastStartTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: _remainingMs), _handleTimeout);
  }

  void _pauseTimer() {
    if (_lastStartTime != null) {
      final elapsed = DateTime.now().difference(_lastStartTime!).inMilliseconds;
      _remainingMs = (_remainingMs - elapsed).clamp(0, 999999);
      _timer?.cancel();
    }
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _handleTimeout() {
    if (!mounted) return;
    _animController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final type = widget.config.type;

    Color iconColor;
    Color accentColor;
    if (theme.isDark) {
      switch (type) {
        case AnimalNotificationType.info:
          iconColor = theme.info;
          accentColor = theme.info;
        case AnimalNotificationType.success:
          iconColor = theme.success;
          accentColor = theme.success;
        case AnimalNotificationType.warning:
          iconColor = theme.warning;
          accentColor = theme.warning;
        case AnimalNotificationType.error:
          iconColor = theme.error;
          accentColor = theme.error;
      }
    } else {
      iconColor = type.iconColor;
      accentColor = type.iconColor;
    }

    final cardBg = theme.isDark ? theme.bgContent : type.bg;
    final headingColor = theme.isDark ? theme.text : type.text;

    Widget iconWidget;
    if (widget.config.icon != null) {
      iconWidget = widget.config.icon!;
    } else {
      switch (type) {
        case AnimalNotificationType.info:
          iconWidget = LeafIcon(size: 22, color: iconColor);
        case AnimalNotificationType.success:
          iconWidget = CheckIcon(size: 22, color: iconColor);
        case AnimalNotificationType.warning:
          iconWidget = BellIcon(size: 22, color: iconColor);
        case AnimalNotificationType.error:
          iconWidget = CloseIcon(size: 22, color: iconColor);
      }
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MouseRegion(
          onEnter: (_) => _pauseTimer(),
          onExit: (_) => _resumeTimer(),
          child: Dismissible(
            key: ValueKey(widget.config.key),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => widget.onDismiss(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.config.onClick,
                borderRadius: AnimalRadii.cardBorder,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AnimalRadii.cardBorder,
                    border: Border.all(color: accentColor, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: theme.isDark ? 0.35 : 0.20),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: iconWidget,
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DefaultTextStyle(
                              style: AnimalTypography.heading.copyWith(
                                fontSize: 15.0,
                                color: headingColor,
                                fontWeight: FontWeight.w800,
                              ),
                              child: widget.config.message,
                            ),
                            if (widget.config.description != null) ...[
                              const SizedBox(height: 4.0),
                              DefaultTextStyle(
                                style: AnimalTypography.body.copyWith(
                                  fontSize: 13.0,
                                  color: theme.textBody,
                                  height: 1.4,
                                ),
                                child: widget.config.description!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      _NotificationCloseButton(
                        onClose: _handleTimeout,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCloseButton extends StatefulWidget {
  final VoidCallback onClose;
  final AnimalIslandTheme theme;

  const _NotificationCloseButton({
    required this.onClose,
    required this.theme,
  });

  @override
  State<_NotificationCloseButton> createState() => _NotificationCloseButtonState();
}

class _NotificationCloseButtonState extends State<_NotificationCloseButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      enabled: true,
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (val) => setState(() => _isFocused = val),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onClose();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        label: 'Dismiss notification',
        child: GestureDetector(
          onTap: widget.onClose,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: AnimalMotion.fast,
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isHovered ? widget.theme.surfaceAlt : Colors.transparent,
                border: Border.all(
                  color: _isFocused ? widget.theme.focusYellow : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: widget.theme.focusYellow.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: CloseIcon(
                size: 14,
                color: widget.theme.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
