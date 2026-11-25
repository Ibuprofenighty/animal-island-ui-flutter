import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/recipes/scrollbar.dart';
import '../foundation/theme.dart';
import '../internal/focus_outline.dart';

/// Which axes of an [IslandScrollbar] scroll.
enum IslandScrollbarDirection {
  /// Scrolls vertically; the horizontal axis is laid out by the parent width.
  vertical,

  /// Scrolls horizontally; the vertical axis takes the child's height.
  horizontal,

  /// Scrolls on both axes.
  both,
}

/// A scroll area with the island thumb: a pill that is always shown while the
/// content overflows, darkens under the pointer and can be dragged.
///
/// Scrolling stays the platform's own (wheel, touch, drag, keyboard); only
/// the thumb and the optional track are drawn by this widget. The area is a
/// focus stop, so the arrow, page, Home and End keys scroll it. A wheel event
/// that reaches the end of the area is not passed to an outer scrollable.
///
/// The thumb takes its thickness out of the content while that axis
/// overflows, as a classic scrollbar does, so it never covers the child.
class IslandScrollbar extends StatefulWidget {
  const IslandScrollbar({
    super.key,
    this.height,
    this.maxHeight,
    this.width,
    this.maxWidth,
    this.direction = IslandScrollbarDirection.vertical,
    this.thumbColor,
    this.thumbSize = 8,
    this.showTrack = false,
    this.padding = EdgeInsets.zero,
    this.verticalController,
    this.horizontalController,
    required this.child,
  }) : assert(thumbSize > 0, 'thumbSize must be positive');

  /// Fixed height of the area. Null takes the child's height, limited by
  /// [maxHeight] and the parent.
  final double? height;

  /// Largest height of the area.
  final double? maxHeight;

  /// Fixed width of the area. Null follows the parent's constraints.
  final double? width;

  /// Largest width of the area.
  final double? maxWidth;

  /// The axes that scroll. The other axis is not scrollable and has no thumb.
  final IslandScrollbarDirection direction;

  /// Thumb colour at rest. Null uses the theme's outline colour. The colour
  /// under the pointer stays the theme's.
  final Color? thumbColor;

  /// Thumb and track thickness in logical pixels.
  final double thumbSize;

  /// Whether the track behind the thumb is filled.
  final bool showTrack;

  /// Space around [child] inside the scrolling content. The thumb sits
  /// outside it, at the edge of the area.
  final EdgeInsetsGeometry padding;

  /// Controls the vertical offset. Borrowed, never disposed here; null
  /// creates an internal one. Unused when [direction] is horizontal.
  final ScrollController? verticalController;

  /// Controls the horizontal offset. Borrowed, never disposed here; null
  /// creates an internal one. Unused when [direction] is vertical.
  final ScrollController? horizontalController;

  /// The scrolling content.
  final Widget child;

  @override
  State<IslandScrollbar> createState() => _IslandScrollbarState();
}

class _IslandScrollbarState extends State<IslandScrollbar> {
  final focus = FocusNode(debugLabel: 'IslandScrollbar');
  ScrollController? ownedVertical, ownedHorizontal;
  // Whether each axis overflows, so its thumb exists and takes its gutter.
  bool verticalOverflow = false, horizontalOverflow = false;
  // Set once removing a gutter brought the overflow back: the gutter stays
  // until the configuration changes instead of flipping every frame.
  bool verticalKept = false, horizontalKept = false;
  bool verticalDropped = false, horizontalDropped = false;
  bool focusRing = false;
  // Focus taken by a pointer shows no ring until a key is used, as
  // `:focus-visible` on the reference's scrolling root.
  bool pointerFocus = false;

  bool get vertical => widget.direction != IslandScrollbarDirection.horizontal;
  bool get horizontal => widget.direction != IslandScrollbarDirection.vertical;

  ScrollController get verticalController =>
      widget.verticalController ?? (ownedVertical ??= ScrollController());
  ScrollController get horizontalController =>
      widget.horizontalController ?? (ownedHorizontal ??= ScrollController());

  @override
  void initState() {
    super.initState();
    focus.addListener(focusChanged);
  }

  @override
  void didUpdateWidget(IslandScrollbar old) {
    super.didUpdateWidget(old);
    verticalKept = horizontalKept = false;
    verticalDropped = horizontalDropped = false;
    if (!vertical) verticalOverflow = false;
    if (!horizontal) horizontalOverflow = false;
  }

  @override
  void dispose() {
    focus.dispose();
    ownedVertical?.dispose();
    ownedHorizontal?.dispose();
    super.dispose();
  }

  void focusChanged() {
    if (!focus.hasFocus) pointerFocus = false;
    final ring = focus.hasPrimaryFocus && !pointerFocus;
    if (ring != focusRing && mounted) setState(() => focusRing = ring);
  }

  KeyEventResult keyUsed(FocusNode node, KeyEvent event) {
    if (pointerFocus) {
      pointerFocus = false;
      focusChanged();
    }
    return KeyEventResult.ignored;
  }

  /// Home and End reach the ends of the vertical axis, or of the horizontal
  /// one when it is the only axis. The framework binds them on some
  /// platforms only; the reference's native scrolling has them everywhere.
  void toBoundary({required bool end}) {
    final position =
        (vertical ? verticalController : horizontalController).position;
    position.moveTo(
      end ? position.maxScrollExtent : position.minScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  bool metricsChanged(ScrollMetricsNotification notification) {
    final isVertical = notification.metrics.axis == Axis.vertical;
    // The content may hold scrollables of its own; theirs arrive deeper.
    final depth = isVertical ? 0 : (vertical ? 1 : 0);
    if (notification.depth != depth) return false;
    if (isVertical ? !vertical : !horizontal) return false;
    final overflow = notification.metrics.maxScrollExtent > 0;
    if (isVertical) {
      if (overflow == verticalOverflow || (!overflow && verticalKept)) {
        return false;
      }
      setState(() {
        if (overflow && verticalDropped) verticalKept = true;
        if (!overflow) verticalDropped = true;
        verticalOverflow = overflow;
      });
    } else {
      if (overflow == horizontalOverflow || (!overflow && horizontalKept)) {
        return false;
      }
      setState(() {
        if (overflow && horizontalDropped) horizontalKept = true;
        if (!overflow) horizontalDropped = true;
        horizontalOverflow = overflow;
      });
    }
    return false;
  }

  void containWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    // The inner scrollables are asked first; when none of them can move,
    // this claim keeps the event from an outer scrollable.
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {});
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.thumbSize;
    final thumb = widget.thumbColor ?? ScrollbarColors.thumb(context);
    final hover = ScrollbarColors.thumbHover(context);
    final track = widget.showTrack ? ScrollbarColors.track(context) : null;
    final verticalGutter = vertical && verticalOverflow ? size : 0.0;
    final horizontalGutter = horizontal && horizontalOverflow ? size : 0.0;

    Widget area = Focus(
      focusNode: focus,
      onKeyEvent: keyUsed,
      child: Padding(padding: widget.padding, child: widget.child),
    );
    if (horizontal) {
      area = SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        child: area,
      );
    }
    if (vertical) {
      area = SingleChildScrollView(
        controller: verticalController,
        child: Padding(
          padding: EdgeInsetsDirectional.only(end: verticalGutter),
          child: area,
        ),
      );
    }
    area = Padding(
      padding: EdgeInsets.only(bottom: horizontalGutter),
      child: area,
    );
    if (horizontal) {
      area = _IslandThumb(
        controller: horizontalController,
        orientation: ScrollbarOrientation.bottom,
        depth: vertical ? 1 : 0,
        size: size,
        color: thumb,
        hoverColor: hover,
        trackColor: track,
        inset: EdgeInsetsDirectional.only(end: verticalGutter)
            .resolve(Directionality.of(context)),
        child: area,
      );
    }
    if (vertical) {
      area = _IslandThumb(
        controller: verticalController,
        orientation: null,
        depth: 0,
        size: size,
        color: thumb,
        hoverColor: hover,
        trackColor: track,
        inset: EdgeInsets.only(bottom: horizontalGutter),
        child: area,
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth ?? double.infinity,
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: FocusOutline(
            const RoundedRectangleBorder(),
            focusRing ? IslandTheme.of(context).focus : Colors.transparent,
            width: 2,
            offset: -2,
          ),
          child: Listener(
            onPointerSignal: containWheel,
            onPointerDown: (_) {
              pointerFocus = true;
              if (focus.hasFocus) {
                focusChanged();
              } else {
                focus.requestFocus();
              }
            },
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.home): () =>
                    toBoundary(end: false),
                const SingleActivator(LogicalKeyboardKey.end): () =>
                    toBoundary(end: true),
              },
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: metricsChanged,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: area,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One island thumb over [child]: always shown while its axis overflows.
class _IslandThumb extends RawScrollbar {
  _IslandThumb({
    required ScrollController super.controller,
    required ScrollbarOrientation? orientation,
    required int depth,
    required double size,
    required Color color,
    required this.hoverColor,
    required Color? trackColor,
    required EdgeInsets inset,
    required super.child,
  }) : super(
         thumbVisibility: true,
         trackVisibility: trackColor != null,
         thickness: size,
         radius: Radius.circular(size / 2),
         trackRadius: Radius.circular(size / 2),
         thumbColor: color,
         trackColor: trackColor,
         trackBorderColor: Colors.transparent,
         crossAxisMargin: 0,
         mainAxisMargin: 0,
         padding: inset,
         scrollbarOrientation: orientation,
         // Shown at full colour at once, as a classic scrollbar.
         fadeDuration: Duration.zero,
         notificationPredicate: (notification) => notification.depth == depth,
       );

  final Color hoverColor;

  @override
  RawScrollbarState<_IslandThumb> createState() => _IslandThumbState();
}

class _IslandThumbState extends RawScrollbarState<_IslandThumb> {
  // Reference thumb: `background-color 0.2s cubic-bezier(0.4, 0, 0.2, 1)`.
  late final AnimationController hover = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(updateScrollbarPainter);
  late final CurvedAnimation eased = CurvedAnimation(
    parent: hover,
    curve: const Cubic(0.4, 0, 0.2, 1),
  );
  bool over = false, held = false;

  void settle() => over || held ? hover.forward() : hover.reverse();

  @override
  void updateScrollbarPainter() {
    super.updateScrollbarPainter();
    scrollbarPainter.color = Color.lerp(
      widget.thumbColor,
      widget.hoverColor,
      eased.value,
    )!;
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);
    over = isPointerOverThumb(event.position, event.kind);
    settle();
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    over = false;
    settle();
  }

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    held = true;
    settle();
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);
    held = false;
    settle();
  }

  @override
  void dispose() {
    eased.dispose();
    hover.dispose();
    super.dispose();
  }
}
