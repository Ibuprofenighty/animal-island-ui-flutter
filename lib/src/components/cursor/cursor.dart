import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

/// Animal Island custom cursor wrapper with device-aware rendering (C04).
///
/// Strictly adheres to canonical architecture:
/// - Transparent hit testing (never intercepts clicks or pointer events)
/// - Only renders custom graphics on mouse pointer devices (never dangles on touch screens)
/// - Single MouseRegion overlay without duplicating focus trees
class AnimalCursor extends StatefulWidget {
  final Widget child;

  /// The cursor style variant. Default is [AnimalCursorType.defaultCursor].
  final AnimalCursorType type;

  /// Whether to force this cursor across all descendants. Default is true.
  final bool forceAll;

  /// Custom cursor widget if custom overlay is desired.
  final Widget? customCursor;

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

class _AnimalCursorState extends State<AnimalCursor> {
  final ValueNotifier<Offset?> _mousePosNotifier = ValueNotifier<Offset?>(null);

  bool get _isCustomArtCursor =>
      widget.type == AnimalCursorType.defaultCursor ||
      widget.type == AnimalCursorType.raindrop ||
      widget.customCursor != null;

  @override
  void dispose() {
    _mousePosNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MouseCursor systemCursor;
    switch (widget.type) {
      case AnimalCursorType.defaultCursor:
      case AnimalCursorType.raindrop:
        // When using custom art cursor, hide the native system cursor while inside
        systemCursor = SystemMouseCursors.none;
      case AnimalCursorType.pointer:
        systemCursor = SystemMouseCursors.click;
      case AnimalCursorType.text:
        systemCursor = SystemMouseCursors.text;
      case AnimalCursorType.notAllowed:
        systemCursor = SystemMouseCursors.forbidden;
    }

    Widget content = MouseRegion(
      cursor: systemCursor,
      opaque: widget.forceAll,
      onEnter: (event) {
        if (_isCustomArtCursor && event.kind == PointerDeviceKind.mouse) {
          _mousePosNotifier.value = event.localPosition;
        }
      },
      onHover: (event) {
        if (_isCustomArtCursor && event.kind == PointerDeviceKind.mouse) {
          _mousePosNotifier.value = event.localPosition;
        }
      },
      onExit: (_) {
        if (_isCustomArtCursor) {
          _mousePosNotifier.value = null;
        }
      },
      child: widget.child,
    );

    if (!_isCustomArtCursor) {
      return content;
    }

    Widget cursorWidget;
    if (widget.customCursor != null) {
      cursorWidget = widget.customCursor!;
    } else if (widget.type == AnimalCursorType.raindrop) {
      cursorWidget = Container(
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
    } else {
      // Default cute animal paw pointer
      cursorWidget = const _AnimalPawCursor();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        content,
        ValueListenableBuilder<Offset?>(
          valueListenable: _mousePosNotifier,
          builder: (context, pos, _) {
            if (pos == null) return const SizedBox.shrink();
            return Positioned(
              left: pos.dx - 6,
              top: pos.dy - 6,
              child: IgnorePointer(child: cursorWidget),
            );
          },
        ),
      ],
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
