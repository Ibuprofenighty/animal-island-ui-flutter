import 'dart:math' as math;

import 'package:flutter/material.dart';

enum PanelPlacement { below, above, beside }

/// Owns only overlay placement and outside dismissal. The component owns selection,
/// keyboard behavior and focus. Anchor and panel share one tap-region boundary.
class AnchoredPanel extends StatefulWidget {
  const AnchoredPanel({
    super.key,
    required this.open,
    required this.onDismiss,
    required this.anchor,
    required this.panel,
    required this.width,
    required this.estimatedHeight,
    this.placement = PanelPlacement.below,
    this.gap = 6,
    this.attachment,
    this.transitionDuration = Duration.zero,
    this.reverseTransitionDuration,
    this.transitionCurve = const Cubic(.4, 0, .2, 1),
    this.transitionOffset = const Offset(0, -6),
  });
  final bool open;
  final Duration transitionDuration;
  final Duration? reverseTransitionDuration;
  final Curve transitionCurve;
  final Offset transitionOffset;
  final VoidCallback onDismiss;
  final Widget anchor, panel;
  final double? width;
  final double estimatedHeight;
  final ({Alignment target, Alignment follower, Offset offset})? attachment;
  final PanelPlacement placement;
  final double gap;
  @override
  State<AnchoredPanel> createState() => _AnchoredPanelState();
}

class _AnchoredPanelState extends State<AnchoredPanel>
    with SingleTickerProviderStateMixin {
  late final motion =
      AnimationController(
        vsync: this,
        duration: widget.transitionDuration,
      )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && !widget.open) portal.hide();
      });
  final portal = OverlayPortalController();
  final group = Object();
  @override
  void initState() {
    super.initState();
    syncVisibility();
  }

  @override
  void didUpdateWidget(AnchoredPanel old) {
    super.didUpdateWidget(old);
    if (old.open != widget.open ||
        old.transitionDuration != widget.transitionDuration ||
        old.reverseTransitionDuration != widget.reverseTransitionDuration)
      syncVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncVisibility();
  }

  bool syncPending = false;
  void syncVisibility() {
    if (syncPending) return;
    syncPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncPending = false;
      if (!mounted) return;
      final reduced = MediaQuery.disableAnimationsOf(context);
      motion.duration = widget.transitionDuration;
      motion.reverseDuration = widget.reverseTransitionDuration;
      if (widget.open) {
        portal.show();
        if (reduced || widget.transitionDuration == Duration.zero) {
          motion.value = 1;
        } else {
          motion.forward();
        }
      } else if (reduced ||
          (widget.reverseTransitionDuration ?? widget.transitionDuration) ==
              Duration.zero) {
        motion.value = 0;
        portal.hide();
      } else {
        motion.reverse();
      }
    });
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  Widget overlay(BuildContext context, OverlayChildLayoutInfo info) {
    final rect = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        CustomSingleChildLayout(
          delegate: _AnchoredPanelLayout(rect, widget),
          child: TapRegion(
            groupId: group,
            child: Material(
              type: MaterialType.transparency,
              animationDuration: Duration.zero,
              child: IgnorePointer(
                ignoring: !widget.open,
                child: ExcludeFocus(
                  excluding: !widget.open,
                  child: ExcludeSemantics(
                    excluding: !widget.open,
                    child: AnimatedBuilder(
                      animation: motion,
                      child: widget.panel,
                      builder: (context, child) {
                        final t = widget.transitionCurve.transform(
                          motion.value,
                        );
                        return Transform.translate(
                          filterQuality:
                              widget.transitionDuration == Duration.zero ||
                                  widget.transitionOffset == Offset.zero
                              ? null
                              : FilterQuality.low,
                          offset: widget.transitionDuration == Duration.zero
                              ? Offset.zero
                              : widget.transitionOffset * (1 - t),
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => TapRegion(
    groupId: group,
    onTapOutside: widget.open ? (_) => widget.onDismiss() : null,
    child: OverlayPortal.overlayChildLayoutBuilder(
      controller: portal,
      overlayChildBuilder: overlay,
      child: widget.anchor,
    ),
  );
}

// Layout implementation of the existing owner. The real child supplies its
// height and intrinsic width; no post-frame guesses or duplicate child tree.
class _AnchoredPanelLayout extends SingleChildLayoutDelegate {
  _AnchoredPanelLayout(this.rect, this.panel);
  final Rect rect;
  final AnchoredPanel panel;

  bool opensAbove(Size size) {
    final above = rect.top;
    final below = size.height - rect.bottom;
    return panel.placement == PanelPlacement.above
        ? above >= panel.estimatedHeight || above > below
        : below < panel.estimatedHeight && above > below;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final availableWidth = math.max(0.0, constraints.maxWidth - 16);
    final width = panel.width == null
        ? null
        : math.min(panel.width!, availableWidth);
    final size = constraints.biggest;
    var height = math.max(0.0, size.height - 16);
    final attachment = panel.attachment;
    final vertical = attachment == null
        ? panel.placement != PanelPlacement.beside
        : attachment.offset.dy != 0 && attachment.offset.dx == 0;
    final gap = attachment?.offset.dy.abs() ?? panel.gap;
    final above = math.max(0.0, rect.top - gap);
    final below = math.max(0.0, size.height - rect.bottom - gap);
    if (vertical) {
      final up = attachment == null
          ? opensAbove(size)
          : attachment.offset.dy < 0;
      height = math.min(height, up ? above : below);
    } else if (attachment == null &&
        width != null &&
        width > rect.left - 6 &&
        width > size.width - rect.right - 6) {
      height = math.min(height, math.max(above, below));
    }
    return BoxConstraints(
      minWidth: width ?? 0,
      maxWidth: width ?? availableWidth,
      maxHeight: height,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final below = size.height - rect.bottom;
    final above = rect.top;
    Alignment anchor, follower;
    Offset gap;
    if (panel.attachment case final geometry?) {
      anchor = geometry.target;
      follower = geometry.follower;
      gap = geometry.offset;
    } else if (panel.placement == PanelPlacement.beside) {
      // Keep the reference's preferred side and vertical attachment whenever
      // that actual result fits. Only an overflowing result changes below.
      final left = rect.right + 200 > size.width;
      final x = left ? -1.0 : 1.0;
      if (below < panel.estimatedHeight && above > below) {
        anchor = Alignment(x, -1);
        follower = Alignment(-x, 1);
        gap = Offset(left ? -6 : 6, -6);
      } else if (below < panel.estimatedHeight ||
          rect.top < panel.estimatedHeight) {
        anchor = Alignment(x, 1);
        follower = Alignment(-x, -1);
        gap = Offset(left ? -6 : 6, 6);
      } else {
        anchor = Alignment(x, 0);
        follower = Alignment(-x, 0);
        gap = Offset(left ? -6 : 6, 0);
      }
    } else {
      final up = opensAbove(size);
      final right = rect.left + childSize.width > size.width - 8;
      anchor = Alignment(right ? 1 : -1, up ? -1 : 1);
      follower = Alignment(right ? 1 : -1, up ? 1 : -1);
      gap = Offset(0, up ? -panel.gap : panel.gap);
    }
    var position =
        rect.topLeft +
        anchor.alongSize(rect.size) -
        follower.alongSize(childSize) +
        gap;
    if (panel.placement == PanelPlacement.beside &&
        panel.attachment == null &&
        (position.dx < 0 || position.dx + childSize.width > size.width)) {
      final alternate =
          rect.topLeft +
          Alignment(-anchor.x, anchor.y).alongSize(rect.size) -
          Alignment(-follower.x, follower.y).alongSize(childSize) +
          Offset(-gap.dx, gap.dy);
      if (alternate.dx >= 0 && alternate.dx + childSize.width <= size.width) {
        position = alternate;
      } else {
        final below = rect.bottom + panel.gap;
        final above = rect.top - panel.gap - childSize.height;
        position = Offset(
          position.dx,
          below + childSize.height <= size.height ? below : above,
        );
      }
    }
    return Offset(
      position.dx < 0 || position.dx + childSize.width > size.width
          ? position.dx
                .clamp(8.0, math.max(8.0, size.width - childSize.width - 8))
                .toDouble()
          : position.dx,
      position.dy < 0 || position.dy + childSize.height > size.height
          ? position.dy
                .clamp(8.0, math.max(8.0, size.height - childSize.height - 8))
                .toDouble()
          : position.dy,
    );
  }

  @override
  bool shouldRelayout(_AnchoredPanelLayout oldDelegate) =>
      rect != oldDelegate.rect || panel != oldDelegate.panel;
}
