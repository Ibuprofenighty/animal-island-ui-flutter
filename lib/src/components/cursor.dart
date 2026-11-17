import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../internal/viewport_overlay.dart';
import '../foundation/recipes/cursor.dart';

enum IslandCursorVariant { arrow, raindrop }

/// MouseTracker owns cursor selection; this widget only paints the chosen shape.
/// Scoped children retain their native MouseCursor contracts.
///
/// The arrow variant also sets the warm text-selection highlight for its
/// subtree; the raindrop variant restores the selection colour that applies
/// outside every enclosing cursor, so the innermost cursor decides.
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
    final ambient = DefaultSelectionStyle.of(context);
    final parent = context.dependOnInheritedWidgetOfExactType<_CursorScope>();
    final hostSelection = parent == null
        ? ambient.selectionColor
        : parent.hostSelection;
    return _CursorScope(
      owner: owner,
      hostSelection: hostSelection,
      child: Stack(
        children: [
          _CursorRegion(
            owner: owner,
            forceAll: widget.forceAll,
            child: DefaultSelectionStyle(
              selectionColor: drop ? hostSelection : CursorColors.selection,
              cursorColor: ambient.cursorColor,
              mouseCursor: ambient.mouseCursor,
              child: widget.child,
            ),
          ),
          ViewportOverlay(
            decorative: true,
            visible: owner.selected.isNotEmpty,
            builder: (context) => Stack(
              children: [
                for (final device in owner.selected)
                  if (owner.positions[device] case final point?)
                    Positioned(
                      left: point.dx - (drop ? 16 : 8),
                      top: point.dy - (drop ? 6 : 5),
                      child: CustomPaint(
                        size: const Size.square(32),
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
  const _CursorScope({
    required this.owner,
    required this.hostSelection,
    required super.child,
  });
  final _CursorOwner owner;

  /// Selection colour outside the outermost cursor.
  final Color? hostSelection;
  @override
  bool updateShouldNotify(_CursorScope old) =>
      old.owner != owner || old.hostSelection != hostSelection;
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
        ..moveTo(8.5, 7.9)
        ..lineTo(9.7, 21.1)
        ..quadraticBezierTo(10.0, 23.8, 11.6, 21.6)
        ..lineTo(13.1, 19.8)
        ..quadraticBezierTo(13.8, 18.8, 14.4, 19.9)
        ..lineTo(17.0, 24.7)
        ..quadraticBezierTo(17.8, 26.1, 19.2, 25.3)
        ..lineTo(19.6, 25.1)
        ..quadraticBezierTo(21.0, 24.3, 20.2, 22.9)
        ..lineTo(17.6, 18.1)
        ..quadraticBezierTo(17.0, 17.1, 18.2, 17.0)
        ..lineTo(20.5, 16.7)
        ..quadraticBezierTo(23.3, 16.5, 21.1, 14.8)
        ..lineTo(10.6, 6.7)
        ..quadraticBezierTo(8.2, 4.8, 8.5, 7.9)
        ..close();
      canvas.drawPath(path, Paint()..color = CursorColors.arrowFill);
      canvas.drawPath(
        path,
        Paint()
          ..color = CursorColors.arrowStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.75
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
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
      canvas.drawPath(path, Paint()..color = CursorColors.raindropFill);
      canvas.drawPath(
        path,
        Paint()
          ..color = CursorColors.raindropStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.save();
      canvas.translate(12.5, 19);
      canvas.rotate(-18 * math.pi / 180);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 4, height: 6.4),
        Paint()..color = CursorColors.raindropHighlight,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CursorPainter old) => old.variant != variant;
}
