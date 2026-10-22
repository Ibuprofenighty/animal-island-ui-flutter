import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../internal/viewport_overlay.dart';

enum IslandCursorVariant { arrow, raindrop }

/// MouseTracker owns cursor selection; this widget only paints the chosen shape.
/// Scoped children retain their native MouseCursor contracts.
class IslandCursor extends StatefulWidget {
  const IslandCursor({
    super.key,
    required this.child,
    this.variant = IslandCursorVariant.arrow,
    this.forceAll = true,
  });
  final Widget child;
  final IslandCursorVariant variant;
  final bool forceAll;
  @override
  State<IslandCursor> createState() => _IslandCursorState();
}

class _IslandCursorState extends State<IslandCursor> {
  late final owner = _CursorOwner(changed);
  bool scheduled = false;
  void changed() {
    if (scheduled || !mounted) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    owner.parent = context
        .dependOnInheritedWidgetOfExactType<_CursorScope>()
        ?.owner;
  }

  @override
  void dispose() {
    owner.disposed = true;
    owner.positions.clear();
    owner.selected.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    owner.variant = widget.variant;
    final drop = widget.variant == IslandCursorVariant.raindrop;
    return _CursorScope(
      owner: owner,
      child: Stack(
        children: [
          _CursorRegion(
            owner: owner,
            forceAll: widget.forceAll,
            child: widget.child,
          ),
          ViewportOverlay(
            decorative: true,
            visible: owner.selected.isNotEmpty,
            builder: (context) => Stack(
              children: [
                for (final device in owner.selected)
                  if (owner.positions[device] case final point?)
                    Positioned(
                      left: point.dx - (drop ? 16 : 6),
                      top: point.dy - (drop ? 6 : 4),
                      child: CustomPaint(
                        size: Size.square(drop ? 32 : 28),
                        painter: _CursorPainter(widget.variant),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CursorOwner {
  _CursorOwner(this.changed);
  final VoidCallback changed;
  _CursorOwner? parent;
  final positions = <int, Offset>{};
  final selected = <int>{};
  bool suppressed = false, disposed = false;
  IslandCursorVariant variant = IslandCursorVariant.arrow;
  late final cursor = _SoftwareCursor(this);
  void position(PointerEvent event) {
    if (disposed || event.kind != PointerDeviceKind.mouse) return;
    if (positions[event.device] != event.position) {
      positions[event.device] = event.position;
      changed();
    }
  }

  void choose(int device, bool active) {
    if (disposed) return;
    final updated = active ? selected.add(device) : selected.remove(device);
    if (updated) changed();
  }
}

class _CursorScope extends InheritedWidget {
  const _CursorScope({required this.owner, required super.child});
  final _CursorOwner owner;
  @override
  bool updateShouldNotify(_CursorScope old) => old.owner != owner;
}

class _SoftwareCursor extends MouseCursor {
  const _SoftwareCursor(this.owner);
  final _CursorOwner owner;
  @override
  String get debugDescription => 'IslandCursor.${owner.variant.name}';
  @override
  MouseCursorSession createSession(int device) =>
      _SoftwareCursorSession(this, device);
}

class _SoftwareCursorSession extends MouseCursorSession {
  _SoftwareCursorSession(_SoftwareCursor super.cursor, super.device);
  _CursorOwner get owner => (cursor as _SoftwareCursor).owner;
  @override
  Future<void> activate() {
    owner.choose(device, true);
    return SystemChannels.mouseCursor.invokeMethod<void>(
      'activateSystemCursor',
      {'device': device, 'kind': 'none'},
    );
  }

  @override
  void dispose() => owner.choose(device, false);
}

class _CursorRegion extends SingleChildRenderObjectWidget {
  const _CursorRegion({
    required this.owner,
    required this.forceAll,
    required super.child,
  });
  final _CursorOwner owner;
  final bool forceAll;
  @override
  _RenderCursorRegion createRenderObject(BuildContext context) =>
      _RenderCursorRegion(owner, forceAll);
  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCursorRegion renderObject,
  ) {
    renderObject
      ..forceAll = forceAll
      ..markNeedsPaint();
  }
}

class _RenderCursorRegion extends RenderMouseRegion {
  _RenderCursorRegion(this.cursorOwner, this.forceAll)
    : super(
        onEnter: cursorOwner.position,
        onHover: cursorOwner.position,
        onExit: (event) {
          cursorOwner.positions.remove(event.device);
          cursorOwner.changed();
        },
      );
  final _CursorOwner cursorOwner;
  bool forceAll;
  @override
  MouseCursor get cursor =>
      cursorOwner.suppressed ? MouseCursor.defer : cursorOwner.cursor;
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    cursorOwner.suppressed = false;
    for (
      var ancestor = cursorOwner.parent;
      ancestor != null;
      ancestor = ancestor.parent
    ) {
      ancestor.suppressed = true;
    }
    // Cursor priority changes; pointer events still visit the original child.
    if (forceAll) result.add(BoxHitTestEntry(this, position));
    hitTestChildren(result, position: position);
    if (!forceAll) result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    super.handleEvent(event, entry);
    if (event is PointerMoveEvent) cursorOwner.position(event);
  }
}

class _CursorPainter extends CustomPainter {
  const _CursorPainter(this.variant);
  final IslandCursorVariant variant;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (variant == IslandCursorVariant.arrow) {
      path
        ..moveTo(6, 4)
        ..lineTo(6, 21)
        ..lineTo(10.5, 16.5)
        ..lineTo(13.5, 23)
        ..lineTo(16.8, 21.5)
        ..lineTo(13.8, 15.2)
        ..lineTo(20.5, 15.2)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xfffff7e6));
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xff794f27)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeJoin = StrokeJoin.round,
      );
    } else {
      path
        ..moveTo(16, 6)
        ..cubicTo(16, 6, 7, 18, 7, 22)
        ..arcToPoint(
          const Offset(25, 22),
          radius: const Radius.circular(9),
          clockwise: false,
        )
        ..cubicTo(25, 18, 16, 6, 16, 6)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xff74ccff));
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xff2e86ab)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.save();
      canvas.translate(12.5, 19);
      canvas.rotate(-18 * math.pi / 180);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 4, height: 6.4),
        Paint()..color = const Color(0xffdff4ff),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CursorPainter old) => old.variant != variant;
}
