import 'package:flutter/widgets.dart';

import '../../foundation/theme/components/notification_theme.dart';

/// Semantic types for notifications.
enum AnimalNotificationType {
  /// Neutral information.
  info,

  /// A completed or successful action.
  success,

  /// A condition that needs attention.
  warning,

  /// A failure.
  error,
}

/// Screen placement of a notification stack inside its host.
enum AnimalNotificationPlacement {
  /// Top-right corner; the stack grows downward.
  topRight,

  /// Top-left corner; the stack grows downward.
  topLeft,

  /// Top edge, centered; the stack grows downward.
  top,

  /// Bottom-right corner; the stack grows upward.
  bottomRight,

  /// Bottom-left corner; the stack grows upward.
  bottomLeft,

  /// Bottom edge, centered; the stack grows upward.
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
final class AnimalNotificationHandle {
  AnimalNotificationHandle._(this._status, this._close);

  final ValueGetter<AnimalNotificationStatus> _status;
  final VoidCallback _close;

  /// Current position of the occurrence in its queue.
  AnimalNotificationStatus get status => _status();

  /// Closes the occurrence. Repeated calls are ignored.
  void close() => _close();
}

/// Creates the handle of one occurrence; package-internal, not exported.
AnimalNotificationHandle createAnimalNotificationHandle({
  required ValueGetter<AnimalNotificationStatus> status,
  required VoidCallback close,
}) => AnimalNotificationHandle._(status, close);

/// The content and timing of one notification occurrence.
///
/// A same-key update replaces the whole configuration of the live occurrence.
@immutable
class AnimalNotificationConfig {
  /// Main message, styled with the notification text style.
  final Widget message;

  /// Optional secondary text below [message].
  final Widget? description;

  /// Semantic type that selects the default icon and colors. Defaults to
  /// [AnimalNotificationType.info].
  final AnimalNotificationType type;

  /// Time the notification stays shown; null keeps it until it is closed.
  final Duration? duration;

  /// Placement stack the notification joins. Defaults to
  /// [AnimalNotificationPlacement.topRight].
  final AnimalNotificationPlacement placement;

  /// Leading icon; null shows the default icon of [type].
  final Widget? icon;

  /// Called when the notification body is activated; null leaves the body
  /// inactive.
  final VoidCallback? onClick;

  /// Visual overrides for this notification; see [AnimalNotificationStyle].
  final AnimalNotificationStyle? style;

  /// Creates a notification configuration.
  ///
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
