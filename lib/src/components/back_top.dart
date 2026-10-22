import '../foundation/theme.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../foundation/icon.dart';
import '../internal/action_surface.dart';
import '../internal/focus_outline.dart';
import '../internal/viewport_overlay.dart';

/// Borrows one scroll controller (or the nearest PrimaryScrollController).
/// Container selection belongs to the host, never to a global DOM-style lookup.
class IslandBackTop extends StatefulWidget {
  const IslandBackTop({
    super.key,
    this.controller,
    this.visibilityHeight = 400,
    this.duration = const Duration(milliseconds: 300),
    this.onPressed,
    this.focusNode,
    this.semanticLabel = '返回顶部',
    this.right = 24,
    this.bottom = 32,
  }) : assert(visibilityHeight >= 0);
  final ScrollController? controller;
  final FocusNode? focusNode;
  final double visibilityHeight, right, bottom;
  final Duration duration;
  final VoidCallback? onPressed;
  final String semanticLabel;
  @override
  State<IslandBackTop> createState() => _IslandBackTopState();
}

class _IslandBackTopState extends State<IslandBackTop> {
  ScrollController? controller;
  bool visible = false;
  ScrollPosition? get position =>
      controller?.positions.length == 1 ? controller!.position : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bind();
  }

  @override
  void didUpdateWidget(IslandBackTop old) {
    super.didUpdateWidget(old);
    bind();
  }

  void bind() {
    final next = widget.controller ?? PrimaryScrollController.maybeOf(context);
    if (next != controller) {
      controller?.removeListener(changed);
      controller = next;
      controller?.addListener(changed);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      changed();
    });
  }

  void changed() {
    final next = (position?.pixels ?? 0) > widget.visibilityHeight;
    if (next != visible && mounted) setState(() => visible = next);
  }

  void scrollToTop() {
    final target = position;
    if (target == null || !visible) return;
    if (MediaQuery.disableAnimationsOf(context) ||
        widget.duration <= Duration.zero) {
      target.jumpTo(target.minScrollExtent);
    } else {
      target.animateTo(
        target.minScrollExtent,
        duration: widget.duration,
        curve: Curves.easeInOutQuad,
      );
    }
    widget.onPressed?.call();
  }

  @override
  void dispose() {
    controller?.removeListener(changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    return ViewportOverlay(
      visible: true,
      builder: (_) => Positioned(
        right: widget.right,
        bottom: widget.bottom,
        child: ExcludeSemantics(
          excluding: !visible,
          child: ExcludeFocus(
            excluding: !visible,
            child: IgnorePointer(
              ignoring: !visible,
              child: Opacity(
                opacity: visible ? 1 : 0,
                child: ActionSurface(
                  label: widget.semanticLabel,
                  focusNode: widget.focusNode,
                  onActivate: visible ? scrollToTop : null,
                  builder: (_, states) {
                    final hover = states.contains(WidgetState.hovered);
                    final pressed = states.contains(WidgetState.pressed);
                    return AnimatedContainer(
                      duration: duration,
                      curve: const Cubic(.4, 0, .2, 1),
                      transformAlignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translateByDouble(
                          0,
                          visible ? (pressed ? 2 : 0) : 10,
                          0,
                          1,
                        )
                        ..scaleByDouble(
                          pressed
                              ? .96
                              : hover
                              ? 1.08
                              : 1,
                          pressed
                              ? .96
                              : hover
                              ? 1.08
                              : 1,
                          1,
                          1,
                        ),
                      child: DecoratedBox(
                        position: DecorationPosition.foreground,
                        decoration: FocusOutline(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          states.contains(WidgetState.focused)
                              ? IslandTheme.of(context).focus
                              : Colors.transparent,
                          width: 2,
                          offset: 2,
                        ),
                        child: ExcludeSemantics(
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  top: 4,
                                  bottom: -4,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(end: hover ? 1 : 0),
                                    duration: duration,
                                    curve: const Cubic(.4, 0, .2, 1),
                                    builder: (_, value, child) => ImageFiltered(
                                      imageFilter: ui.ImageFilter.blur(
                                        sigmaX: 5 + 2 * value,
                                        sigmaY: 5 + 2 * value,
                                      ),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          Color.lerp(
                                            const Color(0x385b4e1e),
                                            const Color(0x525b4e1e),
                                            value,
                                          )!,
                                          BlendMode.srcIn,
                                        ),
                                        child: child,
                                      ),
                                    ),
                                    child: const IslandIcon(
                                      IslandGlyph.rocket,
                                      size: 64,
                                    ),
                                  ),
                                ),
                                const IslandIcon(IslandGlyph.rocket, size: 64),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
