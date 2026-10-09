import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Cursor style variants matching upstream animal-island-ui.
enum AnimalCursorType {
  /// Cozy animal paw pointing cursor.
  defaultCursor,

  /// Playful blue raindrop cursor.
  raindrop,

  /// System pointer/click cursor.
  pointer,

  /// System text cursor.
  text,

  /// System forbidden/not-allowed cursor.
  notAllowed,
}

/// Animal Island cursor region with device-aware rendering (C04).
///
/// Over [child], a mouse shows the cursor of [type], or [customCursor] when
/// given. Art cursors ([AnimalCursorType.defaultCursor],
/// [AnimalCursorType.raindrop] and [customCursor]) hide the system pointer
/// and draw the art at the mouse position; the other types use a system
/// cursor. Exactly one cursor is visible at a time: the art is drawn only
/// where this region decides the cursor, so a nested region or a descendant
/// with its own cursor shows that cursor alone.
///
/// The region never takes pointer events, taps or hover from [child] or from
/// regions behind it, and touch or stylus input never shows the art.
class AnimalCursor extends StatefulWidget {
  /// Content over which the cursor is shown.
  final Widget child;

  /// The cursor style variant. Default is [AnimalCursorType.defaultCursor].
  final AnimalCursorType type;

  /// Whether this cursor also replaces the cursors of descendants, including
  /// nested [AnimalCursor] regions and text fields. Default is true.
  ///
  /// When false, a descendant with its own cursor shows that cursor, and this
  /// cursor applies only where descendants have none.
  final bool forceAll;

  /// Art drawn at the mouse position instead of the art of [type].
  final Widget? customCursor;

  /// Creates a cursor region around [child].
  const AnimalCursor({
    super.key,
    required this.child,
    this.type = AnimalCursorType.defaultCursor,
    this.forceAll = true,
    this.customCursor,
  });

  @override
  State<AnimalCursor> createState() => _AnimalCursorState();
}

/// Offset from the mouse position to the top-left corner of the art.
const Offset _artHotspot = Offset(6, 6);

class _AnimalCursorState extends State<AnimalCursor> {
  final GlobalKey _regionKey = GlobalKey();
  final GlobalKey _forcingKey = GlobalKey();

  /// Local mouse position while the art is drawn; null hides it.
  final ValueNotifier<Offset?> _artPosition = ValueNotifier<Offset?>(null);

  bool get _hasArt =>
      widget.customCursor != null ||
      widget.type == AnimalCursorType.defaultCursor ||
      widget.type == AnimalCursorType.raindrop;

  MouseCursor get _systemCursor => widget.customCursor != null
      ? SystemMouseCursors.none
      : switch (widget.type) {
          AnimalCursorType.pointer => SystemMouseCursors.click,
          AnimalCursorType.text => SystemMouseCursors.text,
          AnimalCursorType.notAllowed => SystemMouseCursors.forbidden,
          AnimalCursorType.defaultCursor ||
          AnimalCursorType.raindrop => SystemMouseCursors.none,
        };

  @override
  void didUpdateWidget(AnimalCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The next mouse move draws the art again if it still applies.
    if (!_hasArt) _artPosition.value = null;
  }

  @override
  void dispose() {
    _artPosition.dispose();
    super.dispose();
  }

  void _track(PointerEvent event) {
    _artPosition.value =
        _hasArt &&
            event.kind == PointerDeviceKind.mouse &&
            _decidesCursorAt(event.position)
        ? event.localPosition
        : null;
  }

  /// Whether this region provides the cursor the mouse shows at [position]:
  /// the first region under it whose cursor does not defer is one of ours.
  bool _decidesCursorAt(Offset position) {
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(
      result,
      position,
      View.of(context).viewId,
    );
    final RenderObject? region = _regionKey.currentContext?.findRenderObject();
    final RenderObject? forcing = _forcingKey.currentContext
        ?.findRenderObject();
    for (final HitTestEntry entry in result.path) {
      final Object target = entry.target;
      if (target is MouseTrackerAnnotation &&
          target.validForMouseTracker &&
          target.cursor != MouseCursor.defer) {
        return identical(target, region) || identical(target, forcing);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final MouseCursor cursor = _systemCursor;
    final Widget art =
        widget.customCursor ??
        (widget.type == AnimalCursorType.raindrop
            ? const _RaindropCursor()
            : const _AnimalPawCursor());

    // The tree shape never changes, so switching cursors keeps the state of
    // [child].
    return Stack(
      clipBehavior: Clip.none,
      children: [
        MouseRegion(
          key: _regionKey,
          opaque: false,
          cursor: cursor,
          onEnter: _track,
          onHover: _track,
          onExit: (_) => _artPosition.value = null,
          child: widget.child,
        ),
        // Above the child, so its cursor wins over descendant cursors. It
        // is translucent: hit testing continues to the child below.
        Positioned.fill(
          child: MouseRegion(
            key: _forcingKey,
            opaque: false,
            hitTestBehavior: HitTestBehavior.translucent,
            cursor: widget.forceAll ? cursor : MouseCursor.defer,
          ),
        ),
        ValueListenableBuilder<Offset?>(
          valueListenable: _artPosition,
          builder: (context, position, _) {
            if (position == null) return const SizedBox.shrink();
            final Offset topLeft = position - _artHotspot;
            return Positioned(
              left: topLeft.dx,
              top: topLeft.dy,
              child: IgnorePointer(child: art),
            );
          },
        ),
      ],
    );
  }
}

class _RaindropCursor extends StatelessWidget {
  const _RaindropCursor();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFF60A5FA),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x663B82F6),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _AnimalPawCursor extends StatelessWidget {
  const _AnimalPawCursor();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.25,
      child: SizedBox(
        width: 26,
        height: 26,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Toe beans
            Positioned(
              top: 0,
              left: 3,
              child: Container(
                width: 5,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4A6A4),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF2A2A2A),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 10,
              child: Container(
                width: 5,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4A6A4),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF2A2A2A),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 1,
              right: 3,
              child: Container(
                width: 5,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4A6A4),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF2A2A2A),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            // Main palm pad
            Positioned(
              bottom: 2,
              child: Container(
                width: 18,
                height: 15,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAEDCD),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  border: Border.all(
                    color: const Color(0xFF2A2A2A),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 9,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4A6A4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
