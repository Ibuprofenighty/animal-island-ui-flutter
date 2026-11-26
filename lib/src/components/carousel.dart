import '../foundation/theme.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../internal/action_surface.dart';
import '../internal/active_stack.dart';
import '../internal/light_surface_scope.dart';
import '../internal/focus_outline.dart';
import '../foundation/localizations.dart';
import '../foundation/recipes/carousel.dart';

@immutable
class IslandSlide<T extends Object> {
  const IslandSlide({required this.value, required this.child});
  final T value;
  final Widget child;
}

class IslandCarousel<T extends Object> extends StatefulWidget {
  const IslandCarousel({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.autoplay = false,
    this.interval = const Duration(seconds: 3),
    this.loop = true,
    this.showArrows = true,
    this.showDots = true,
    this.pauseOnHover = true,
    this.semanticLabel,
    this.focusNode,
  }) : initialValue = null,
       controlled = true;
  const IslandCarousel.uncontrolled({
    super.key,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.autoplay = false,
    this.interval = const Duration(seconds: 3),
    this.loop = true,
    this.showArrows = true,
    this.showDots = true,
    this.pauseOnHover = true,
    this.semanticLabel,
    this.focusNode,
  }) : value = null,
       controlled = false;
  final List<IslandSlide<T>> items;
  final T? value, initialValue;
  final ValueChanged<T>? onChanged;
  final bool controlled, autoplay, loop, showArrows, showDots, pauseOnHover;
  final Duration interval;
  final String? semanticLabel;
  final FocusNode? focusNode;
  @override
  State<IslandCarousel<T>> createState() => _IslandCarouselState<T>();
}

class _IslandCarouselState<T extends Object> extends State<IslandCarousel<T>> {
  late T? inner = widget.initialValue ?? widget.items.firstOrNull?.value;
  Timer? timer;
  bool hoverPaused = false, focusPaused = false, rotationPaused = false;
  bool withinFocus = false;
  final _slides = GlobalKey();

  bool _focusInSlides() {
    final focus = FocusManager.instance.primaryFocus?.context;
    final slides = _slides.currentContext;
    if (focus == null || slides == null) return false;
    var inside = false;
    focus.visitAncestorElements((element) {
      inside = element == slides;
      return !inside;
    });
    return inside;
  }

  bool get paused => hoverPaused || focusPaused || rotationPaused;
  int get index {
    final value = widget.controlled ? widget.value : inner;
    final index = widget.items.indexWhere((e) => e.value == value);
    return index < 0 ? (widget.items.isEmpty ? -1 : 0) : index;
  }

  @override
  void initState() {
    super.initState();
    schedule();
  }

  @override
  void didUpdateWidget(IslandCarousel<T> old) {
    super.didUpdateWidget(old);
    assert(
      old.controlled == widget.controlled,
      'Carousel ownership cannot change in place.',
    );
    if (!widget.controlled && !widget.items.any((e) => e.value == inner))
      inner = widget.items.firstOrNull?.value;
    if (!widget.pauseOnHover) hoverPaused = false;
    schedule();
  }

  bool reducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = MediaQuery.disableAnimationsOf(context);
    if (next != reducedMotion) {
      reducedMotion = next;
      schedule();
    }
  }

  void schedule() {
    timer?.cancel();
    timer = null;
    if (!widget.autoplay ||
        paused ||
        reducedMotion ||
        widget.items.length < 2 ||
        (!widget.loop && index == widget.items.length - 1))
      return;
    final interval = widget.interval < const Duration(seconds: 1)
        ? const Duration(seconds: 1)
        : widget.interval;
    timer = Timer(interval, () {
      if (!mounted) return;
      go(index + 1);
      // Rejected controlled requests still wait a full interval.
      if (mounted) schedule();
    });
  }

  void go(int next) {
    if (widget.items.isEmpty) return;
    next = widget.loop
        ? next % widget.items.length
        : next.clamp(0, widget.items.length - 1);
    if (next == index) return;
    final value = widget.items[next].value;
    if (!widget.controlled) setState(() => inner = value);
    widget.onChanged?.call(value);
    if (mounted) schedule();
  }

  void pause(VoidCallback update) {
    if (!mounted) return;
    setState(update);
    schedule();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.items.map((e) => e.value).toSet().length == widget.items.length,
      'Slide identities must be unique.',
    );
    final strings = IslandLocalizations.of(context);
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 350);
    final controls = widget.items.length > 1;
    // Reference --animal-motion-duration-base .25s for arrows, dots and the
    // rotation control; slides use the slow .35s. Both ease (.4,0,.2,1).
    final controlDuration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 250);
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? strings.carousel,
      child: Focus(
        focusNode: widget.focusNode,
        onFocusChange: (v) {
          if (withinFocus == v) return;
          withinFocus = v;
          pause(() => focusPaused = v);
        },
        onKeyEvent: (node, event) {
          // The region owns its keys, also while one of its own controls
          // has focus (the reference handles them on the section); opaque
          // slide children keep theirs.
          if (!node.hasPrimaryFocus && _focusInSlides()) {
            return KeyEventResult.ignored;
          }
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.arrowRight)
            go(index + direction);
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft)
            go(index - direction);
          else if (event.logicalKey == LogicalKeyboardKey.home)
            go(0);
          else if (event.logicalKey == LogicalKeyboardKey.end)
            go(widget.items.length - 1);
          else
            return KeyEventResult.ignored;
          return KeyEventResult.handled;
        },
        child: MouseRegion(
          onEnter: (_) {
            if (widget.pauseOnHover) pause(() => hoverPaused = true);
          },
          onExit: (_) => pause(() => hoverPaused = false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = MediaQuery.sizeOf(context).width <= 480;
              final primaryFocus = Focus.of(context).hasPrimaryFocus;
              Decoration controlFocus(
                Set<WidgetState> states,
                OutlinedBorder shape,
              ) => FocusOutline(
                shape,
                states.contains(WidgetState.focused)
                    ? IslandTokens.light.focus
                    : Colors.transparent,
                width: 2,
                offset: 2,
                backingColor: states.contains(WidgetState.focused)
                    ? CarouselColors.control
                    : null,
              );
              Widget arrow(bool next) => Align(
                alignment: next ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14),
                  child: ActionSurface(
                    label: next ? strings.nextSlide : strings.previousSlide,
                    onActivate:
                        !widget.loop &&
                            (next
                                ? index == widget.items.length - 1
                                : index == 0)
                        ? null
                        : () => go(index + (next ? 1 : -1)),
                    builder: (_, states) {
                      final disabled = states.contains(WidgetState.disabled),
                          hover = states.contains(WidgetState.hovered);
                      return Opacity(
                        opacity: disabled ? .4 : 1,
                        child: _ControlMotion(
                          lifted:
                              hover && !states.contains(WidgetState.pressed),
                          tinted: hover,
                          duration: controlDuration,
                          builder: (lift, tint) => Transform.translate(
                            offset: Offset(0, -2 * lift),
                            child: Container(
                              width: compact ? 36 : 42,
                              height: compact ? 36 : 42,
                              foregroundDecoration: controlFocus(
                                states,
                                const CircleBorder(),
                              ),
                              decoration: BoxDecoration(
                                color: CarouselColors.control,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CarouselColors.controlBorder,
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: CarouselColors.controlShadow,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: _CarouselArrow(
                                  next,
                                  Color.lerp(
                                    CarouselColors.controlInk,
                                    IslandTokens.light.link,
                                    tint,
                                  )!,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
              return DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: FocusOutline(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  primaryFocus
                      ? IslandTheme.of(context).focus
                      : Colors.transparent,
                  width: 2,
                  offset: 3,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(minHeight: 180),
                      width: constraints.hasBoundedWidth
                          ? constraints.maxWidth
                          : null,
                      decoration: BoxDecoration(
                        color: CarouselColors.slideBackplane,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: LightSurfaceScope(
                        key: _slides,
                        child: ActiveStack(
                          index: index,
                          children: [
                            for (var i = 0; i < widget.items.length; i++)
                              ExcludeFocus(
                                key: ValueKey(widget.items[i].value),
                                excluding: i != index,
                                child: IgnorePointer(
                                  ignoring: i != index,
                                  child: Semantics(
                                    container: true,
                                    label: strings.slidePosition(
                                      i + 1,
                                      widget.items.length,
                                    ),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(end: i == index ? 0 : 18),
                                      duration: duration,
                                      curve: _ease,
                                      builder: (_, offset, child) =>
                                          Transform.translate(
                                            filterQuality: FilterQuality.low,
                                            offset: Offset(offset, 0),
                                            child: child,
                                          ),
                                      child: widget.items[i].child,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (controls && widget.showArrows)
                      Positioned.fill(
                        child: Stack(children: [arrow(false), arrow(true)]),
                      ),
                    if (controls && widget.showDots)
                      Positioned(
                        bottom: 14,
                        child: Semantics(
                          container: true,
                          label: strings.chooseSlide,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: CarouselColors.control,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 2,
                              children: [
                                for (var i = 0; i < widget.items.length; i++)
                                  ActionSurface(
                                    label: strings.goToSlide(i + 1),
                                    selected: i == index,
                                    onActivate: () => go(i),
                                    builder: (_, states) => Container(
                                      width: 30,
                                      height: 30,
                                      foregroundDecoration: controlFocus(
                                        states,
                                        const CircleBorder(),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: AnimatedContainer(
                                          duration: controlDuration,
                                          curve: _ease,
                                          width: i == index ? 24 : 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: i == index
                                                ? IslandTokens.light.link
                                                : IslandTokens.light.outline,
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (controls && widget.autoplay)
                      Positioned(
                        top: 14,
                        right: 14,
                        child: ActionSurface(
                          label: paused
                              ? strings.resumeAutoplay
                              : strings.pauseAutoplay,
                          onActivate: () => pause(() {
                            if (paused) {
                              hoverPaused = false;
                              focusPaused = false;
                              rotationPaused = false;
                            } else {
                              rotationPaused = true;
                            }
                          }),
                          // Reference `.rotation-control:hover`: primary-active
                          // ink (contrast-safe link role) and a 1px lift.
                          builder: (_, states) => _ControlMotion(
                            lifted: states.contains(WidgetState.hovered),
                            tinted: states.contains(WidgetState.hovered),
                            duration: controlDuration,
                            builder: (lift, tint) => Transform.translate(
                              offset: Offset(0, -lift),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 58,
                                  minHeight: 32,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                foregroundDecoration: controlFocus(
                                  states,
                                  const StadiumBorder(),
                                ),
                                decoration: BoxDecoration(
                                  color: CarouselColors.control,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: CarouselColors.controlBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: ExcludeSemantics(
                                    child: Text(
                                      paused ? strings.play : strings.pause,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color.lerp(
                                          CarouselColors.controlInk,
                                          IslandTokens.light.link,
                                          tint,
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Reference `cubic-bezier(.4,0,.2,1)` (--animal-motion-ease).
const _ease = Cubic(.4, 0, .2, 1);

/// Control hover timeline: [lifted] and [tinted] each move 0..1 along
/// [duration] with the reference ease. Both inks stay dark on the opaque white
/// control, so intermediate colours keep their contrast.
class _ControlMotion extends StatelessWidget {
  const _ControlMotion({
    required this.lifted,
    required this.tinted,
    required this.duration,
    required this.builder,
  });
  final bool lifted, tinted;
  final Duration duration;
  final Widget Function(double lift, double tint) builder;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: lifted ? 1 : 0),
    duration: duration,
    curve: _ease,
    builder: (_, lift, _) => TweenAnimationBuilder<double>(
      tween: Tween(end: tinted ? 1 : 0),
      duration: duration,
      curve: _ease,
      builder: (_, tint, _) => builder(lift, tint),
    ),
  );
}

class _CarouselArrow extends CustomPainter {
  const _CarouselArrow(this.next, this.color);
  final bool next;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2 + (next ? -1.35 : 1.35), size.height / 2);
    canvas.rotate(next ? math.pi * .75 : -math.pi / 4);
    canvas.translate(-4.5, -4.5);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(9, 0)
        ..lineTo(9, 3)
        ..lineTo(3, 3)
        ..lineTo(3, 9)
        ..lineTo(0, 9)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CarouselArrow old) =>
      old.next != next || old.color != color;
}
