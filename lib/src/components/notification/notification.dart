import 'package:flutter/material.dart';

import 'notification_queue.dart';

export 'notification_card.dart';
export 'notification_queue.dart';

/// Scoped Overlay Notification Portal for Animal Island UI (C30).
///
/// Features:
/// - Scoped to the nearest [Overlay] / host (F07 fix: multi-app isolation, zero static queue sharing)
/// - 6 directional anchor placements with smooth queue stacking
/// - Hover / focus to pause auto-dismiss timer
/// - Horizontal swipe-to-dismiss gesture
/// - Full theme-aware styling (Parchment & Campfire Night)
/// - Exactly-once onClose invocation and programmatic [destroy]
class AnimalNotification {
  static final Expando<AnimalNotificationHostManager> _managers = Expando();
  static final Set<AnimalNotificationHostManager> _activeManagers = {};

  static AnimalNotificationHostManager _managerFor(BuildContext context) {
    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);
    var manager = _managers[overlay];
    if (manager == null || manager.isDisposed) {
      manager = AnimalNotificationHostManager(overlay);
      _managers[overlay] = manager;
      _activeManagers.add(manager);
    }
    return manager;
  }

  /// Cleans all queues across all active overlay hosts (useful for test teardown / reset).
  static void reset() {
    for (final manager in _activeManagers.toList()) {
      manager.dispose();
    }
    _activeManagers.clear();
  }

  /// Dismisses all notifications across all active hosts, or a specific notification by [key].
  static void destroy([String? key]) {
    for (final manager in _activeManagers.toList()) {
      manager.dismiss(key);
    }
  }

  /// Opens a notification with full configuration options.
  static void open(
    BuildContext context, {
    required Widget message,
    Widget? description,
    AnimalNotificationType type = AnimalNotificationType.info,
    Duration duration = const Duration(milliseconds: 4500),
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
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

    final manager = _managerFor(context);
    manager.dispatch(config);
  }

  /// Convenience method to show a Success notification.
  static void success(
    BuildContext context, {
    required String message,
    String? description,
    Duration duration = const Duration(milliseconds: 4500),
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
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
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
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
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
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
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
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
}
