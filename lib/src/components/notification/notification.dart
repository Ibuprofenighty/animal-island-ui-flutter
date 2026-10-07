import 'package:flutter/material.dart';

import '../../foundation/theme/components/notification_theme.dart';
import '../../foundation/theme/theme.dart';
import '../overlay_host/overlay_host.dart';
import 'notification_card.dart';
import 'notification_model.dart';
import 'notification_queue.dart';

export 'notification_model.dart';

/// Notifications shown in the nearest `AnimalOverlayHost` (C30).
///
/// Each host keeps one synchronous queue per [AnimalNotificationPlacement]:
/// at most three notifications are shown and fifty wait behind them; a
/// notification beyond that is rejected and its handle reports
/// [AnimalNotificationStatus.rejected]. Hovering or focusing a notification
/// pauses its timer. Every occurrence runs its `onClose` exactly once, however
/// it closes: its close button, a swipe, [AnimalNotificationHandle.close],
/// [closeAll], its timeout, or the removal of its host. A rejected occurrence
/// never opened, so its `onClose` never runs.
abstract final class AnimalNotification {
  /// Time a notification stays shown when no duration is given.
  static const Duration defaultDuration = Duration(milliseconds: 4500);

  /// Opens a notification in the nearest `AnimalOverlayHost` of [context].
  ///
  /// [duration] null keeps the notification until it is closed. A [key]
  /// identifies a business update: while an occurrence with this key is
  /// queued in the same placement of the same host, `open` replaces its whole
  /// configuration in place, including [onClick] and [onClose], restarts its
  /// duration from now, keeps its queue position, and returns its handle.
  /// After that occurrence closes, the key opens a new occurrence.
  ///
  /// Throws a [FlutterError] when [context] has no host and an
  /// [ArgumentError] for a [duration] that is not positive, before anything
  /// is queued.
  static AnimalNotificationHandle open(
    BuildContext context, {
    required Widget message,
    Widget? description,
    AnimalNotificationType type = AnimalNotificationType.info,
    Duration? duration = defaultDuration,
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
    Widget? icon,
    String? key,
    VoidCallback? onClose,
    VoidCallback? onClick,
    AnimalNotificationStyle? style,
  }) {
    final AnimalNotificationConfig config = AnimalNotificationConfig(
      message: message,
      description: description,
      type: type,
      duration: duration,
      placement: placement,
      icon: icon,
      onClick: onClick,
      style: style,
    );
    return _queueOf(context).open(config, key: key, onClose: onClose);
  }

  /// Closes every notification of the nearest host, or only those of
  /// [placement]. Notifications opened by an `onClose` during this call stay.
  static void closeAll(
    BuildContext context, {
    AnimalNotificationPlacement? placement,
  }) => _queueOf(context).closeAll(placement: placement);

  /// Opens a success notification; see [open].
  static AnimalNotificationHandle success(
    BuildContext context, {
    required String message,
    String? description,
    Duration? duration = defaultDuration,
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
    String? key,
    VoidCallback? onClose,
    VoidCallback? onClick,
    AnimalNotificationStyle? style,
  }) => _typed(
    context,
    AnimalNotificationType.success,
    message,
    description,
    duration,
    placement,
    key,
    onClose,
    onClick,
    style,
  );

  /// Opens an error notification; see [open].
  static AnimalNotificationHandle error(
    BuildContext context, {
    required String message,
    String? description,
    Duration? duration = defaultDuration,
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
    String? key,
    VoidCallback? onClose,
    VoidCallback? onClick,
    AnimalNotificationStyle? style,
  }) => _typed(
    context,
    AnimalNotificationType.error,
    message,
    description,
    duration,
    placement,
    key,
    onClose,
    onClick,
    style,
  );

  /// Opens a warning notification; see [open].
  static AnimalNotificationHandle warning(
    BuildContext context, {
    required String message,
    String? description,
    Duration? duration = defaultDuration,
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
    String? key,
    VoidCallback? onClose,
    VoidCallback? onClick,
    AnimalNotificationStyle? style,
  }) => _typed(
    context,
    AnimalNotificationType.warning,
    message,
    description,
    duration,
    placement,
    key,
    onClose,
    onClick,
    style,
  );

  /// Opens an info notification; see [open].
  static AnimalNotificationHandle info(
    BuildContext context, {
    required String message,
    String? description,
    Duration? duration = defaultDuration,
    AnimalNotificationPlacement placement =
        AnimalNotificationPlacement.topRight,
    String? key,
    VoidCallback? onClose,
    VoidCallback? onClick,
    AnimalNotificationStyle? style,
  }) => _typed(
    context,
    AnimalNotificationType.info,
    message,
    description,
    duration,
    placement,
    key,
    onClose,
    onClick,
    style,
  );

  static AnimalNotificationHandle _typed(
    BuildContext context,
    AnimalNotificationType type,
    String message,
    String? description,
    Duration? duration,
    AnimalNotificationPlacement placement,
    String? key,
    VoidCallback? onClose,
    VoidCallback? onClick,
    AnimalNotificationStyle? style,
  ) => open(
    context,
    message: Text(message),
    description: description == null ? null : Text(description),
    type: type,
    duration: duration,
    placement: placement,
    key: key,
    onClose: onClose,
    onClick: onClick,
    style: style,
  );

  // The queue is a resource of the nearest host, created on first use.
  static AnimalNotificationQueue _queueOf(BuildContext context) {
    final AnimalOverlayController controller = AnimalOverlayHost.of(context);
    return animalOverlayHostResource<AnimalNotificationQueue>(
      controller,
      AnimalNotificationQueue,
      create: () => AnimalNotificationQueue(
        controller,
        (lane) => _AnimalNotificationLaneView(lane: lane),
      ),
      release: (queue) => queue.closeAll(),
    );
  }
}

/// Renders the shown occurrences of one placement lane.
class _AnimalNotificationLaneView extends StatefulWidget {
  final AnimalNotificationLane lane;

  const _AnimalNotificationLaneView({required this.lane});

  @override
  State<_AnimalNotificationLaneView> createState() =>
      _AnimalNotificationLaneViewState();
}

class _AnimalNotificationLaneViewState
    extends State<_AnimalNotificationLaneView> {
  @override
  void initState() {
    super.initState();
    widget.lane.addListener(_changed);
  }

  @override
  void didUpdateWidget(_AnimalNotificationLaneView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.lane, widget.lane)) return;
    oldWidget.lane.removeListener(_changed);
    widget.lane.addListener(_changed);
  }

  @override
  void dispose() {
    widget.lane.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  // The stack keeps this token margin from the host edges it is anchored to,
  // plus the safe area on its vertical edge. It lays out the whole placement,
  // so it is not a per-notification style field.
  static double _laneMargin(AnimalIslandTheme theme) => theme.spacing.lg;

  @override
  Widget build(BuildContext context) {
    final AnimalNotificationLane lane = widget.lane;
    final AnimalNotificationPlacement placement = lane.placement;
    final EdgeInsets safeArea =
        MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    final double margin = _laneMargin(AnimalIslandTheme.of(context));

    return Positioned.fill(
      child: Align(
        alignment: placement.alignment,
        child: Padding(
          padding: EdgeInsets.only(
            top: placement.isTop ? safeArea.top + margin : 0.0,
            bottom: placement.isTop ? 0.0 : safeArea.bottom + margin,
            left: margin,
            right: margin,
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            reverse: !placement.isTop,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: placement.crossAxisAlignment,
              children: [
                for (final AnimalNotificationOccurrence occurrence
                    in lane.active)
                  AnimalNotificationCard(
                    key: ObjectKey(occurrence),
                    config: occurrence.config,
                    onClose: occurrence.close,
                    onPausedChanged: occurrence.setPaused,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
