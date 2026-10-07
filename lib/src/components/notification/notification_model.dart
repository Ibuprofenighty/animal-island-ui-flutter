import 'package:flutter/widgets.dart';

import '../../foundation/theme/components/notification_theme.dart';

/// Semantic types for notifications.
enum AnimalNotificationType { info, success, warning, error }

/// Screen placement of a notification stack inside its host.
enum AnimalNotificationPlacement {
  topRight,
  topLeft,
  top,
  bottomRight,
  bottomLeft,
  bottom,
}

/// Layout of a placement stack inside its host. Package-internal: the root
/// library exports only the enum.
extension AnimalNotificationPlacementLayout on AnimalNotificationPlacement {
  /// Whether the stack grows downward from the top edge.
  bool get isTop =>
      this == AnimalNotificationPlacement.topRight ||
      this == AnimalNotificationPlacement.topLeft ||
      this == AnimalNotificationPlacement.top;

  /// Where the stack sits in its host.
  Alignment get alignment => switch (this) {
    AnimalNotificationPlacement.topRight => Alignment.topRight,
    AnimalNotificationPlacement.topLeft => Alignment.topLeft,
    AnimalNotificationPlacement.top => Alignment.topCenter,
    AnimalNotificationPlacement.bottomRight => Alignment.bottomRight,
    AnimalNotificationPlacement.bottomLeft => Alignment.bottomLeft,
    AnimalNotificationPlacement.bottom => Alignment.bottomCenter,
  };

  /// How cards of different widths line up in the stack.
  CrossAxisAlignment get crossAxisAlignment => switch (this) {
    AnimalNotificationPlacement.topRight ||
    AnimalNotificationPlacement.bottomRight => CrossAxisAlignment.end,
    AnimalNotificationPlacement.topLeft ||
    AnimalNotificationPlacement.bottomLeft => CrossAxisAlignment.start,
    AnimalNotificationPlacement.top ||
    AnimalNotificationPlacement.bottom => CrossAxisAlignment.center,
  };
}

/// Where one notification occurrence is in its placement queue.
///
/// An occurrence moves forward only: `waiting` → `active` → `closed`, or
/// directly `active` → `closed`. `rejected` is terminal and means the
/// placement queue was full, so the notification was never shown.
enum AnimalNotificationStatus {
  /// Shown in its placement stack; its duration timer is running.
  active,

  /// Queued behind the shown notifications of its placement.
  waiting,

  /// Not queued because its placement already held the maximum number of
  /// shown and waiting notifications. Its `onClose` never runs.
  rejected,

  /// Closed by any reason; its `onClose` has run once.
  closed,
}

/// Handle to one notification occurrence returned by `AnimalNotification.open`.
///
/// The occurrence belongs to the `AnimalOverlayHost` it was opened in.
/// [close] is idempotent; closing a waiting occurrence removes it from the
/// queue, and closing a rejected occurrence does nothing.
abstract base class AnimalNotificationHandle {
  const AnimalNotificationHandle();

  /// Current position of the occurrence in its queue.
  AnimalNotificationStatus get status;

  /// Closes the occurrence. Repeated calls are ignored.
  void close();
}

/// The content and timing of one notification occurrence.
///
/// A same-key update replaces the whole configuration of the live occurrence.
@immutable
class AnimalNotificationConfig {
  final Widget message;
  final Widget? description;
  final AnimalNotificationType type;

  /// Time the notification stays shown; null keeps it until it is closed.
  final Duration? duration;
  final AnimalNotificationPlacement placement;
  final Widget? icon;
  final VoidCallback? onClick;
  final AnimalNotificationStyle? style;

  /// Throws an [ArgumentError] for a [duration] that is not positive.
  AnimalNotificationConfig({
    required this.message,
    this.description,
    this.type = AnimalNotificationType.info,
    this.duration,
    this.placement = AnimalNotificationPlacement.topRight,
    this.icon,
    this.onClick,
    this.style,
  }) {
    final Duration? value = duration;
    if (value != null && value <= Duration.zero) {
      throw ArgumentError.value(value, 'duration', 'must be positive');
    }
  }
}
