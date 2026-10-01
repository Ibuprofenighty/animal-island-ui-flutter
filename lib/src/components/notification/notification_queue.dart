import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';
import 'notification_card.dart';

/// Semantic types for notifications matching animal-island-ui.
enum AnimalNotificationType { info, success, warning, error }

/// Screen placement positions for notifications.
enum AnimalNotificationPlacement {
  topRight,
  topLeft,
  top,
  bottomRight,
  bottomLeft,
  bottom;

  bool get isTop =>
      this == AnimalNotificationPlacement.topRight ||
      this == AnimalNotificationPlacement.topLeft ||
      this == AnimalNotificationPlacement.top;

  Alignment get alignment {
    switch (this) {
      case AnimalNotificationPlacement.topRight:
        return Alignment.topRight;
      case AnimalNotificationPlacement.topLeft:
        return Alignment.topLeft;
      case AnimalNotificationPlacement.top:
        return Alignment.topCenter;
      case AnimalNotificationPlacement.bottomRight:
        return Alignment.bottomRight;
      case AnimalNotificationPlacement.bottomLeft:
        return Alignment.bottomLeft;
      case AnimalNotificationPlacement.bottom:
        return Alignment.bottomCenter;
    }
  }
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

/// Internal queue container rendered into an [OverlayEntry] for a specific placement.
class AnimalNotificationQueueContainer extends StatefulWidget {
  final AnimalNotificationPlacement placement;
  final ValueChanged<AnimalNotificationQueueState> onStateReady;
  final VoidCallback onEmpty;

  const AnimalNotificationQueueContainer({
    super.key,
    required this.placement,
    required this.onStateReady,
    required this.onEmpty,
  });

  @override
  State<AnimalNotificationQueueContainer> createState() =>
      AnimalNotificationQueueState();
}

class AnimalNotificationQueueState
    extends State<AnimalNotificationQueueContainer> {
  final List<AnimalNotificationConfig> _items = [];
  final Map<String, GlobalKey<AnimalNotificationCardState>> _cardKeys = {};
  final Set<String> _closedKeys = {};

  @override
  void initState() {
    super.initState();
    widget.onStateReady(this);
  }

  void add(AnimalNotificationConfig config) {
    if (!mounted) return;
    setState(() {
      final existingIndex = _items.indexWhere((item) => item.key == config.key);
      if (existingIndex != -1) {
        // In-place update without reshuffling or re-animating entrance
        _items[existingIndex] = config;
      } else {
        _cardKeys[config.key] = GlobalKey<AnimalNotificationCardState>();
        _items.add(config);
        // Bounded limit: max 5 notifications per placement stack
        if (_items.length > 5) {
          final removed = _items.removeAt(0);
          _cardKeys.remove(removed.key);
          _triggerOnClose(removed);
        }
      }
    });
  }

  void dismiss(String? key) {
    if (!mounted) return;
    if (key == null) {
      for (final cardKey in _cardKeys.values) {
        cardKey.currentState?.close();
      }
    } else {
      final cardKey = _cardKeys[key];
      cardKey?.currentState?.close();
    }
  }

  void remove(String key) {
    if (!mounted) return;
    final index = _items.indexWhere((item) => item.key == key);
    if (index != -1) {
      final removed = _items.removeAt(index);
      _cardKeys.remove(key);
      _triggerOnClose(removed);
      setState(() {});
      if (_items.isEmpty) {
        widget.onEmpty();
      }
    }
  }

  void _triggerOnClose(AnimalNotificationConfig config) {
    if (!_closedKeys.contains(config.key)) {
      _closedKeys.add(config.key);
      config.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final mq = MediaQuery.maybeOf(context);
    final topPadding = (mq?.padding.top ?? 0) + theme.spacing.lg;
    final bottomPadding = (mq?.padding.bottom ?? 0) + theme.spacing.lg;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Align(
          alignment: widget.placement.alignment,
          child: Padding(
            padding: EdgeInsets.only(
              top: widget.placement.isTop ? topPadding : 0.0,
              bottom: !widget.placement.isTop ? bottomPadding : 0.0,
              left: theme.spacing.lg,
              right: theme.spacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                reverse: !widget.placement.isTop,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in _items)
                      Padding(
                        key: ValueKey(item.key),
                        padding: EdgeInsets.only(
                          bottom: theme.spacing.sm + theme.spacing.xxs / 2,
                        ),
                        child: AnimalNotificationCard(
                          key: _cardKeys[item.key],
                          config: item,
                          onDismiss: () => remove(item.key),
                          onTimeout: () => remove(item.key),
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
}

/// Host-scoped notification manager bound to an [OverlayState].
///
/// Defect F07 resolution: Each overlay / host maintains its own isolated queues.
/// No global static maps or cross-host contamination.
class AnimalNotificationHostManager {
  final OverlayState overlayState;
  final Map<AnimalNotificationPlacement, AnimalNotificationQueueState>
  _activeQueues = {};
  final Map<AnimalNotificationPlacement, OverlayEntry> _activeEntries = {};
  bool _disposed = false;

  AnimalNotificationHostManager(this.overlayState);

  bool get isDisposed => _disposed;

  void dispatch(AnimalNotificationConfig config) {
    if (_disposed) return;
    final placement = config.placement;

    final existingQueue = _activeQueues[placement];
    if (existingQueue != null && existingQueue.mounted) {
      existingQueue.add(config);
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        return AnimalNotificationQueueContainer(
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
    overlayState.insert(entry);
  }

  void dismiss([String? key]) {
    if (_disposed) return;
    final queues = _activeQueues.values.toList();
    for (final queue in queues) {
      queue.dismiss(key);
    }
  }

  void dispose() {
    _disposed = true;
    for (final entry in _activeEntries.values) {
      entry.remove();
    }
    _activeEntries.clear();
    _activeQueues.clear();
  }
}
