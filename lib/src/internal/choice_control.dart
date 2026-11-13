import 'six_dot_splash.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/theme.dart';
import '../foundation/size.dart';
import 'action_surface.dart';
import 'focus_outline.dart';

class ChoiceControl extends StatefulWidget {
  const ChoiceControl({
    super.key,
    required this.label,
    required this.checked,
    required this.onActivate,
    this.radio = false,
    this.size = IslandSize.middle,
    this.focusNode,
  });
  final String label;
  final bool checked, radio;
  final VoidCallback? onActivate;
  final IslandSize size;
  final FocusNode? focusNode;
  @override
  State<ChoiceControl> createState() => _ChoiceControlState();
}

class _ChoiceControlState extends State<ChoiceControl>
    with SingleTickerProviderStateMixin {
  late final splash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      splash.value = 1;
    } else if (!initialized && widget.checked && widget.onActivate != null) {
      splash.forward();
    }
    initialized = true;
  }

  @override
  void didUpdateWidget(ChoiceControl old) {
    super.didUpdateWidget(old);
    if (old.checked != widget.checked) {
      if (widget.checked &&
          widget.onActivate != null &&
          !MediaQuery.disableAnimationsOf(context)) {
        splash.forward(from: 0);
      } else {
        splash.stop();
      }
    }
    if (widget.onActivate == null) splash.stop();
  }

  @override
  void dispose() {
    splash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extent = switch (widget.size) {
      IslandSize.small => 18.0,
      IslandSize.middle => 22.0,
      IslandSize.large => 28.0,
    };
    final font = switch (widget.size) {
      IslandSize.small => 12.0,
      IslandSize.middle => 14.0,
      IslandSize.large => 16.0,
    };
    final disabled = widget.onActivate == null;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final tokens = IslandTheme.of(context);
    // The default light product palette restores the reference recipe:
    // unchecked rgb(247,243,223) fill and #725d42/#794f27 labels (both 5.1:1+
    // on every light paper, so the 150ms color change stays readable).
    // Customized, dark or surface-scoped token sets keep their own ink/paper.
    final reference = identical(tokens, IslandTokens.light);
    final labelColor = disabled
        ? const Color(0xffc4b89e)
        : !reference
        ? tokens.ink
        : widget.checked
        ? const Color(0xff794f27)
        : const Color(0xff725d42);
    return ActionSurface(
      inMutuallyExclusiveGroup: widget.radio,
      button: false,
      checked: widget.checked,
      focusNode: widget.focusNode,
      onActivate: widget.onActivate,
      builder: (_, states) => Opacity(
        opacity: disabled ? .55 : 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: FocusOutline(
                const CircleBorder(),
                states.contains(WidgetState.focused)
                    ? tokens.focus
                    : Colors.transparent,
                width: 2,
                offset: 2,
              ),
              // Reference `transition: border-color .25s`; every intermediate
              // boundary stays at least as dark as `outline`. Fill and mark
              // still commit atomically in the painter.
              child: AnimatedContainer(
                duration: reduced
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                curve: Curves.ease,
                width: extent,
                height: extent,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: disabled
                        ? const Color(0xffd4c9b4)
                        : widget.checked
                        ? tokens.onLeaf
                        : tokens.outline,
                    width: 2,
                  ),
                ),
                child: CustomPaint(
                  painter: _ChoicePaint(
                    splash: splash,
                    checked: widget.checked,
                    disabled: disabled,
                    reduced: reduced,
                    extent: extent,
                    fill: tokens.leaf,
                    mark: tokens.onLeaf,
                    paper: reference ? const Color(0xfff7f3df) : tokens.paper,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              // Reference `.label { transition: color .15s }` for the checked
              // pair only; palette, theme and disabled changes switch at once.
              child: TweenAnimationBuilder<Color?>(
                key: ValueKey((
                  reference,
                  disabled,
                  reference ? null : tokens.ink,
                )),
                tween: ColorTween(end: labelColor),
                duration: reduced
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                builder: (context, color, child) => DefaultTextStyle(
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: font,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: font * .01,
                    color: color,
                  ),
                  child: child!,
                ),
                child: Text(widget.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoicePaint extends CustomPainter {
  _ChoicePaint({
    required this.splash,
    required this.checked,
    required this.disabled,
    required this.reduced,
    required this.extent,
    required this.fill,
    required this.mark,
    required this.paper,
  }) : super(repaint: splash);
  final Animation<double> splash;
  final bool checked, disabled, reduced;
  final double extent;
  final Color fill, mark, paper;

  @override
  void paint(Canvas canvas, Size size) {
    // The complete committed mark and boundary stay readable during decoration.
    final center = size.center(Offset.zero);
    final radius = extent / 2;
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = disabled
            ? const Color(0xfff0ece2)
            : checked
            ? fill
            : paper,
    );
    if (checked && !disabled && !reduced) {
      paintSixDotSplash(canvas, center, extent, fill, splash.value);
    }
    if (!checked) return;
    final (width, height) = extent == 18
        ? (10.0, 9.0)
        : extent == 22
        ? (12.0, 11.0)
        : (15.0, 14.0);
    final scale = math.min(width / 15, height / 14);
    canvas.save();
    canvas.translate(
      center.dx - 7.5 * scale,
      center.dy - .54 * height + (height - 14 * scale) / 2,
    );
    canvas.scale(scale);
    final path = Path()
      ..moveTo(2, 8.36364)
      ..lineTo(6.23077, 12)
      ..lineTo(13, 2);
    canvas.drawPath(
      path,
      Paint()
        ..color = disabled ? const Color(0xffc4b89e) : mark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChoicePaint old) =>
      old.checked != checked ||
      old.disabled != disabled ||
      old.reduced != reduced ||
      old.extent != extent ||
      old.fill != fill ||
      old.mark != mark ||
      old.paper != paper ||
      old.splash != splash;
}
