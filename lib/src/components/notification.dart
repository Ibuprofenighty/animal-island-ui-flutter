import '../internal/light_surface_scope.dart';
import '../foundation/theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../internal/action_surface.dart';
import '../internal/content_scope.dart';
import '../internal/focus_outline.dart';
import '../internal/surface_motion.dart';
import '../internal/viewport_overlay.dart';
import '../foundation/recipes/notification.dart';

enum IslandNotificationType { success, info, warning, error }

enum IslandNotificationPosition {
  top,
  topLeft,
  topRight,
  bottom,
  bottomLeft,
  bottomRight,
}

@immutable
class IslandNotification {
  const IslandNotification({
    required this.message,
    this.description,
    this.icon,
    this.action,
    this.closeIcon,
    this.type = IslandNotificationType.info,
    this.position = IslandNotificationPosition.top,
    this.duration = const Duration(milliseconds: 4500),
    this.onPressed,
    this.onDismiss,
    this.onClose,
    this.closeLabel = '关闭',
  });
  final Widget message;
  final Widget? description, icon, action, closeIcon;
  final IslandNotificationType type;
  final IslandNotificationPosition position;

  /// Zero keeps the notification until explicit dismissal.
  final Duration duration;
  final VoidCallback? onPressed, onDismiss, onClose;
  final String closeLabel;
}

class IslandNotificationHandle {
  IslandNotificationHandle._(this._owner, this._entry);
  final IslandNotificationsController _owner;
  final _Entry _entry;
  bool get isOpen =>
      !_owner._disposed &&
      !_entry.leaving &&
      identical(_owner._entries[_entry.id], _entry);
  bool update(IslandNotification notification) =>
      _owner._update(_entry, notification);
  void close() => _owner._close(_entry);
}

class _Entry {
  _Entry(this.id, this.notification);
  final Object id;
  IslandNotification notification;
  Timer? expiry, removal;
  bool leaving = false;
  VoidCallback? closed;
  void cancel() {
    expiry?.cancel();
    removal?.cancel();
  }
}

/// One host per controller; the creator owns its lifetime.
class IslandNotificationsController extends ChangeNotifier {
  final _entries = <Object, _Entry>{};
  Object? _host;
  bool _disposed = false, _reduced = false;
  IslandNotificationHandle show(IslandNotification notification, {Object? id}) {
    if (_disposed) throw StateError('Notification controller is disposed.');
    final key = id ?? Object();
    final old = _entries[key];
    if (old != null) {
      _update(old, notification);
      return IslandNotificationHandle._(this, old);
    }
    final entry = _Entry(key, notification);
    _entries[key] = entry;
    _schedule(entry);
    notifyListeners();
    return IslandNotificationHandle._(this, entry);
  }

  bool _update(_Entry entry, IslandNotification notification) {
    if (_disposed || entry.leaving || !identical(_entries[entry.id], entry))
      return false;
    entry.notification = notification;
    _schedule(entry);
    notifyListeners();
    return true;
  }

  void _schedule(_Entry entry) {
    entry.expiry?.cancel();
    if (entry.notification.duration > Duration.zero) {
      entry.expiry = Timer(entry.notification.duration, () => _close(entry));
    }
  }

  void _close(_Entry entry) {
    if (_disposed || entry.leaving || !identical(_entries[entry.id], entry))
      return;
    entry.leaving = true;
    entry.expiry?.cancel();
    entry.closed = entry.notification.onClose;
    final onDismiss = entry.notification.onDismiss;
    if (_reduced) {
      scheduleMicrotask(() => _completeClose(entry));
    } else {
      entry.removal = Timer(
        const Duration(milliseconds: 250),
        () => _completeClose(entry),
      );
    }
    notifyListeners();
    onDismiss?.call();
  }

  void _completeClose(_Entry entry) {
    if (_disposed || !entry.leaving || !identical(_entries[entry.id], entry))
      return;
    entry.cancel();
    final closed = entry.closed;
    entry.closed = null;
    _entries.remove(entry.id);
    notifyListeners();
    closed?.call();
  }

  void _setReduced(Object host, bool value) {
    if (!identical(_host, host) || _reduced == value) return;
    _reduced = value;
    if (value) {
      final closing = _entries.values.where((e) => e.leaving).toList();
      scheduleMicrotask(() {
        for (final entry in closing) {
          _completeClose(entry);
        }
      });
    }
  }

  /// Reference destroy: removes the current matching entries at once, with no
  /// exit motion. Each entry's onDismiss (if not already leaving) and frozen
  /// onClose then fire once, synchronously; reentrant additions survive.
  void dismiss([Object? id]) {
    if (_disposed) return;
    final removed = [
      for (final entry in _entries.values)
        if (id == null || entry.id == id) entry,
    ];
    if (removed.isEmpty) return;
    final dismissals = <VoidCallback>[];
    for (final entry in removed) {
      if (!entry.leaving) {
        entry.leaving = true;
        entry.closed = entry.notification.onClose;
        if (entry.notification.onDismiss case final onDismiss?) {
          dismissals.add(onDismiss);
        }
      }
      entry.cancel();
      _entries.remove(entry.id);
    }
    final closes = [
      for (final entry in removed)
        if (entry.closed case final closed?) closed,
    ];
    for (final entry in removed) {
      entry.closed = null;
    }
    notifyListeners();
    for (final onDismiss in dismissals) {
      onDismiss();
    }
    for (final closed in closes) {
      closed();
    }
  }

  void _attach(Object host) {
    if (_disposed) throw StateError('Notification controller is disposed.');
    if (_host != null && !identical(_host, host))
      throw StateError('A notification controller requires exactly one host.');
    _host = host;
  }

  void _detach(Object host) {
    if (identical(_host, host)) {
      _host = null;
      _reduced = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final entry in _entries.values) {
      entry.cancel();
    }
    _entries.clear();
    super.dispose();
  }
}

class IslandNotifications extends StatefulWidget {
  const IslandNotifications({
    super.key,
    required this.controller,
    required this.child,
  });
  final IslandNotificationsController controller;
  final Widget child;
  @override
  State<IslandNotifications> createState() => _IslandNotificationsState();
}

class _IslandNotificationsState extends State<IslandNotifications> {
  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    widget.controller.addListener(changed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller._setReduced(
      this,
      MediaQuery.disableAnimationsOf(context),
    );
  }

  @override
  void didUpdateWidget(IslandNotifications old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(changed);
      old.controller._detach(this);
      widget.controller._attach(this);
      widget.controller.addListener(changed);
      widget.controller._setReduced(
        this,
        MediaQuery.disableAnimationsOf(context),
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(changed);
    widget.controller._detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      ViewportOverlay(
        visible: widget.controller._entries.isNotEmpty,
        builder: (context) => Stack(
          children: [
            for (final position in IslandNotificationPosition.values)
              if (widget.controller._entries.values.any(
                (e) => e.notification.position == position,
              ))
                Positioned.fill(
                  // 24px viewport inset = 20 outside the scroll view + 4
                  // inside it, so the outside focus outline is not clipped.
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: switch (position) {
                        IslandNotificationPosition.top => Alignment.topCenter,
                        IslandNotificationPosition.topLeft => Alignment.topLeft,
                        IslandNotificationPosition.topRight =>
                          Alignment.topRight,
                        IslandNotificationPosition.bottom =>
                          Alignment.bottomCenter,
                        IslandNotificationPosition.bottomLeft =>
                          Alignment.bottomLeft,
                        IslandNotificationPosition.bottomRight =>
                          Alignment.bottomRight,
                      },
                      child: SingleChildScrollView(
                        reverse: position.index >= 3,
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,
                          verticalDirection: position.index >= 3
                              ? VerticalDirection.up
                              : VerticalDirection.down,
                          children: [
                            for (final entry
                                in widget.controller._entries.values.where(
                                  (e) => e.notification.position == position,
                                ))
                              _NotificationCard(
                                key: ObjectKey(entry),
                                entry: entry,
                                onClose: () => widget.controller._close(entry),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    ],
  );
}

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    super.key,
    required this.entry,
    required this.onClose,
  });
  final _Entry entry;
  final VoidCallback onClose;
  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late final motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sync();
  }

  @override
  void didUpdateWidget(_NotificationCard old) {
    super.didUpdateWidget(old);
    sync();
  }

  void sync() {
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.value = widget.entry.leaving ? 0 : 1;
    } else if (widget.entry.leaving) {
      motion.reverse();
    } else {
      motion.forward();
    }
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  static (Color, Color, Color, Color) _palette(IslandNotificationType type) =>
      switch (type) {
        IslandNotificationType.success => (
          NotificationColors.successFill,
          NotificationColors.successBorder,
          NotificationColors.successIconFill,
          IslandTokens.light.onLeaf,
        ),
        IslandNotificationType.info => (
          NotificationColors.infoFill,
          NotificationColors.infoBorder,
          NotificationColors.infoIconFill,
          IslandTokens.light.link,
        ),
        IslandNotificationType.warning => (
          NotificationColors.warningFill,
          NotificationColors.warningBorder,
          NotificationColors.warningIconFill,
          IslandTokens.light.warning,
        ),
        IslandNotificationType.error => (
          NotificationColors.errorFill,
          NotificationColors.errorBorder,
          NotificationColors.errorIconFill,
          IslandTokens.light.dangerText,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final n = widget.entry.notification;
    final reduced = MediaQuery.disableAnimationsOf(context);
    Widget surface(BuildContext context, Set<WidgetState> states) {
      final hover = n.onPressed != null && states.contains(WidgetState.hovered);
      // Reference .clickable: hover lifts 1px and deepens the shadow over
      // 0.2s ease; focus-visible is a 2px outline offset 2px outside.
      const hoverMotion = Duration(milliseconds: 200);
      return LightSurfaceScope(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: hover ? -1 : 0),
          duration: reduced ? Duration.zero : hoverMotion,
          curve: Curves.ease,
          builder: (_, lift, child) =>
              Transform.translate(offset: Offset(0, lift), child: child),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: FocusOutline(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
              states.contains(WidgetState.focused)
                  ? IslandTokens.light.focus
                  : Colors.transparent,
              width: 2,
              offset: 2,
            ),
            child: surfaceBody(states, hover, hoverMotion),
          ),
        ),
      );
    }

    return IgnorePointer(
      ignoring: widget.entry.leaving,
      child: ExcludeFocus(
        excluding: widget.entry.leaving,
        child: ExcludeSemantics(
          excluding: widget.entry.leaving,
          child: AnimatedBuilder(
            animation: motion,
            builder: (context, child) {
              final t = const Cubic(.4, 0, .2, 1).transform(motion.value);
              return Transform.translate(
                offset: snapToDevicePixels(
                  Offset(0, (n.position.index < 3 ? -16 : 16) * (1 - t)),
                  MediaQuery.devicePixelRatioOf(context),
                ),
                child: child,
              );
            },
            child: Semantics(
              liveRegion: true,
              container: true,
              child: ActionSurface(
                onActivate: n.onPressed,
                button: n.onPressed != null,
                builder: surface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget surfaceBody(
    Set<WidgetState> states,
    bool hover,
    Duration hoverMotion,
  ) {
    final n = widget.entry.notification;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final (fill, border, iconFill, iconInk) = _palette(n.type);
    return AnimatedContainer(
      duration: reduced ? Duration.zero : hoverMotion,
      curve: Curves.ease,
      width: 384,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: hover
                ? NotificationColors.hoverShadow
                : border.withValues(
                    alpha: n.type == IslandNotificationType.warning ? .2 : .18,
                  ),
            offset: Offset(0, hover ? 10 : 6),
            blurRadius: hover ? 26 : 18,
          ),
        ],
      ),
      child: Row(
        spacing: 12,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconFill,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: ContentScope(
                iconColor: iconInk,
                iconSize: 18,
                child:
                    n.icon ??
                    CustomPaint(
                      size: const Size.square(18),
                      painter: _NotificationIcon(n.type, iconInk),
                    ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                ContentScope(
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    letterSpacing: .15,
                    color: NotificationColors.message,
                  ),
                  child: n.message,
                ),
                if (n.description != null)
                  ContentScope(
                    textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                      letterSpacing: .13,
                      color: IslandTokens.light.muted,
                    ),
                    child: n.description!,
                  ),
              ],
            ),
          ),
          if (n.action != null)
            Padding(padding: const EdgeInsets.only(left: 4), child: n.action!),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ActionSurface(
              label: n.closeLabel,
              onActivate: widget.onClose,
              // Reference .close: `transition: all .15s ease` for the
              // hover disc; focus-visible outline 2px offset 2px.
              builder: (context, states) => DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: FocusOutline(
                  const CircleBorder(),
                  states.contains(WidgetState.focused)
                      ? IslandTokens.light.focus
                      : Colors.transparent,
                  width: 2,
                  offset: 2,
                ),
                child: AnimatedContainer(
                  duration: reduced
                      ? Duration.zero
                      : const Duration(milliseconds: 150),
                  curve: Curves.ease,
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: states.contains(WidgetState.hovered)
                        ? NotificationColors.closeHoverFill
                        : NotificationColors.closeFill,
                  ),
                  child: ContentScope(
                    textStyle: TextStyle(
                      fontSize: 18,
                      height: 1,
                      color: states.contains(WidgetState.hovered)
                          ? NotificationColors.closeHover
                          : IslandTokens.light.ink,
                    ),
                    // The action owns a 22px hit area. Visual close content
                    // uses its intrinsic width, centered like the reference.
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: double.infinity,
                      child: n.closeIcon ?? const Text('×'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends CustomPainter {
  const _NotificationIcon(this.type, this.color);
  final IslandNotificationType type;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    switch (type) {
      case IslandNotificationType.success:
        path
          ..moveTo(5, 12.5)
          ..lineTo(9.5, 17)
          ..lineTo(19, 7.5);
      case IslandNotificationType.info:
        canvas.drawCircle(const Offset(12, 7), 1.6, Paint()..color = color);
        path
          ..moveTo(12, 11)
          ..lineTo(12, 18);
      case IslandNotificationType.warning:
        paint.strokeWidth = 2.5;
        path
          ..moveTo(12, 4)
          ..lineTo(21.5, 20.5)
          ..lineTo(2.5, 20.5)
          ..close()
          ..moveTo(12, 10)
          ..lineTo(12, 14)
          ..moveTo(12, 16.5)
          ..lineTo(12, 16.51);
      case IslandNotificationType.error:
        path
          ..moveTo(6.5, 6.5)
          ..lineTo(17.5, 17.5)
          ..moveTo(17.5, 6.5)
          ..lineTo(6.5, 17.5);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NotificationIcon old) =>
      old.type != type || old.color != color;
}
