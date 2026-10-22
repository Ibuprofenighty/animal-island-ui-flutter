import '../internal/light_surface_scope.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../internal/anchored_panel.dart';
import '../internal/content_scope.dart';
import '../internal/organic_bubble.dart';

enum IslandTooltipPlacement {
  top,
  topStart,
  topEnd,
  bottom,
  bottomStart,
  bottomEnd,
  left,
  leftStart,
  leftEnd,
  right,
  rightStart,
  rightEnd,
}

enum IslandTooltipTrigger { hover, focus }

enum IslandTooltipVariant { normal, island }

/// A noninteractive description. The child remains the owner of its action.
/// For click activation, explicitly compose [IslandTooltip.click]'s toggle
/// into the trigger's callback; no descendant inspection or event interception.
class IslandTooltip extends StatefulWidget {
  const IslandTooltip({
    super.key,
    required this.message,
    required Widget this.child,
    this.content,
    this.placement = IslandTooltipPlacement.top,
    this.trigger = IslandTooltipTrigger.hover,
    this.variant = IslandTooltipVariant.normal,
    this.bordered = true,
    this.excludeFromSemantics = false,
  }) : builder = null;
  const IslandTooltip.click({
    super.key,
    required this.message,
    required Widget Function(BuildContext, VoidCallback) this.builder,
    this.content,
    this.placement = IslandTooltipPlacement.top,
    this.variant = IslandTooltipVariant.normal,
    this.bordered = true,
    this.excludeFromSemantics = false,
  }) : child = null,
       trigger = IslandTooltipTrigger.hover;
  final String message;
  final Widget? child, content;
  final Widget Function(BuildContext, VoidCallback)? builder;
  final IslandTooltipPlacement placement;
  final IslandTooltipTrigger trigger;
  final IslandTooltipVariant variant;
  final bool bordered, excludeFromSemantics;
  @override
  State<IslandTooltip> createState() => _IslandTooltipState();
}

class _IslandTooltipState extends State<IslandTooltip>
    with SingleTickerProviderStateMixin {
  late final motion =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && mounted) setState(() {});
      });
  Timer? hide;
  bool visible = false;
  void show() {
    hide?.cancel();
    if (!mounted) return;
    setState(() => visible = true);
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.value = 1;
    } else {
      motion.forward();
    }
  }

  void close() {
    hide?.cancel();
    if (!mounted) return;
    setState(() => visible = false);
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.value = 0;
    } else {
      motion.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) motion.value = visible ? 1 : 0;
  }

  void scheduleHide() {
    hide?.cancel();
    hide = Timer(const Duration(milliseconds: 100), close);
  }

  @override
  void dispose() {
    hide?.cancel();
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final side = widget.placement.index ~/ 3;
    final align = switch (widget.placement.index % 3) {
      1 => -1.0,
      2 => 1.0,
      _ => 0.0,
    };
    final (target, follower, offset) = switch (side) {
      0 => (Alignment(align, -1), Alignment(align, 1), const Offset(0, -10)),
      1 => (Alignment(align, 1), Alignment(align, -1), const Offset(0, 10)),
      2 => (Alignment(-1, align), Alignment(1, align), const Offset(-10, 0)),
      _ => (Alignment(1, align), Alignment(-1, align), const Offset(10, 0)),
    };
    final click = widget.builder != null;
    final hover = !click && widget.trigger == IslandTooltipTrigger.hover;
    final island = widget.variant == IslandTooltipVariant.island;
    final trigger =
        widget.builder?.call(context, () => visible ? close() : show()) ??
        widget.child!;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: !click && widget.trigger == IslandTooltipTrigger.focus
          ? (value) => value ? show() : scheduleHide()
          : null,
      onKeyEvent: (_, event) {
        if (visible &&
            event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          close();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: hover ? (_) => show() : null,
        onExit: hover ? (_) => scheduleHide() : null,
        child: AnchoredPanel(
          open: visible || motion.value > 0,
          onDismiss: () {},
          width: null,
          estimatedHeight: 80,
          attachment: (target: target, follower: follower, offset: offset),
          anchor: Semantics(
            tooltip: widget.excludeFromSemantics ? null : widget.message,
            child: trigger,
          ),
          panel: SingleChildScrollView(
            child: MouseRegion(
              onEnter: hover ? (_) => show() : null,
              onExit: hover ? (_) => scheduleHide() : null,
              child: IgnorePointer(
                ignoring: !visible,
                child: ExcludeFocus(
                  child: ExcludeSemantics(
                    child: AnimatedBuilder(
                      animation: motion,
                      builder: (context, child) {
                        final t = const Cubic(
                          .4,
                          0,
                          .2,
                          1,
                        ).transform(motion.value);
                        return Transform.translate(
                          offset: offset * (-.4 * (1 - t)),
                          child: child,
                        );
                      },
                      child: IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: island ? 280 : 240,
                          ),
                          child: CustomPaint(
                            painter: _BubblePainter(
                              widget.variant,
                              widget.placement,
                              widget.bordered,
                            ),
                            child: Padding(
                              padding: island
                                  ? EdgeInsets.symmetric(
                                      horizontal: widget.bordered ? 22 : 20,
                                      vertical: widget.bordered ? 14 : 12,
                                    )
                                  : EdgeInsets.symmetric(
                                      horizontal: widget.bordered ? 14 : 12,
                                      vertical: widget.bordered ? 8 : 6,
                                    ),
                              child: LightSurfaceScope(
                                child: ContentScope(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xff725d42),
                                    fontWeight: island
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    height: island ? 1.55 : 1.5,
                                    letterSpacing: .12,
                                  ),
                                  child: DefaultTextStyle.merge(
                                    textAlign: island
                                        ? TextAlign.center
                                        : TextAlign.start,
                                    child:
                                        widget.content ?? Text(widget.message),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter(this.variant, this.placement, this.bordered);
  final IslandTooltipVariant variant;
  final IslandTooltipPlacement placement;
  final bool bordered;
  @override
  void paint(Canvas canvas, Size size) {
    const paper = Color(0xfff7f3df), border = Color(0xffc4b89e);
    final island = variant == IslandTooltipVariant.island;
    final path = island
        ? const OrganicBubbleClip().getClip(size)
        : (Path()..addRRect(
            RRect.fromRectAndRadius(
              Offset.zero & size,
              const Radius.circular(16),
            ),
          ));
    canvas.save();
    canvas.translate(0, island ? 4 : 3);
    canvas.drawPath(
      path,
      Paint()
        ..color = island ? const Color(0x24794f27) : const Color(0x1a3d3428)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, island ? 7 : 5),
    );
    canvas.restore();
    canvas.drawPath(path, Paint()..color = paper);
    if (bordered) {
      canvas.save();
      canvas.clipPath(path);
      canvas.drawPath(
        path,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      canvas.restore();
    }
    final side = placement.index ~/ 3, alignment = placement.index % 3;
    final dot = island && !bordered;
    final extent = dot
        ? 14.0
        : island
        ? 10.0
        : 8.0;
    final horizontal = side < 2;
    final length = horizontal ? size.width : size.height;
    final inset = island
        ? (horizontal ? 20.0 : 16.0)
        : (horizontal ? 16.0 : 12.0);
    final along = switch (alignment) {
      1 => inset + extent / 2,
      2 => length - inset - extent / 2,
      _ => length / 2,
    };
    final across = extent / 2 - 5;
    final center = switch (side) {
      0 => Offset(along, size.height - across),
      1 => Offset(along, across),
      2 => Offset(size.width - across, along),
      _ => Offset(across, along),
    };
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (dot) {
      canvas.drawCircle(Offset.zero, 7, Paint()..color = paper);
    } else {
      canvas.rotate(math.pi / 4);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: extent,
        height: extent,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = paper,
      );
      if (bordered) {
        final tail = Path();
        final half = extent / 2;
        switch (side) {
          case 0:
            tail
              ..moveTo(half, -half)
              ..lineTo(half, half)
              ..lineTo(-half, half);
          case 1:
            tail
              ..moveTo(half, -half)
              ..lineTo(-half, -half)
              ..lineTo(-half, half);
          case 2:
            tail
              ..moveTo(-half, -half)
              ..lineTo(half, -half)
              ..lineTo(half, half);
          default:
            tail
              ..moveTo(-half, -half)
              ..lineTo(-half, half)
              ..lineTo(half, half);
        }
        canvas.drawPath(
          tail,
          Paint()
            ..color = border
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.variant != variant ||
      old.placement != placement ||
      old.bordered != bordered;
}
