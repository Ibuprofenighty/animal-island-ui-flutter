import 'package:flutter/rendering.dart' show OverflowBoxFit;

import '../foundation/theme.dart';

import 'dart:ui' show SemanticsRole;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/size.dart';
import '../internal/action_surface.dart';
import '../internal/focus_outline.dart';
import '../internal/six_dot_splash.dart';

/// Controlled when [value] is supplied; otherwise owns [initialValue].
class IslandRate extends StatefulWidget {
  const IslandRate({
    super.key,
    this.value,
    this.initialValue = 0,
    this.count = 5,
    this.size = IslandSize.middle,
    this.readOnly = false,
    this.allowClear = true,
    this.onChanged,
    this.semanticLabel = '评分',
  }) : assert(count > 0),
       assert(initialValue >= 0 && initialValue <= count),
       assert(value == null || value >= 0 && value <= count);
  final int? value;
  final int initialValue, count;
  final IslandSize size;
  final bool readOnly, allowClear;
  final ValueChanged<int>? onChanged;
  final String semanticLabel;
  @override
  State<IslandRate> createState() => _IslandRateState();
}

class _IslandRateState extends State<IslandRate>
    with SingleTickerProviderStateMixin {
  late int _local = widget.initialValue;
  int? _preview;
  int _burstFrom = 0, _burstTo = 0;
  int get value => (widget.value ?? _local).clamp(0, widget.count);
  late final _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: 1,
  );
  final _nodes = <FocusNode>[];
  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  void _syncNodes() {
    while (_nodes.length < widget.count) {
      _nodes.add(FocusNode());
    }
    while (_nodes.length > widget.count) {
      _nodes.removeLast().dispose();
    }
  }

  @override
  void didUpdateWidget(IslandRate old) {
    super.didUpdateWidget(old);
    final previous = (old.value ?? _local).clamp(0, old.count);
    _syncNodes();
    if (old.value != null && widget.value == null)
      _local = old.value!.clamp(0, widget.count);
    if (previous != value) animateChange(previous, value);
    if (widget.readOnly) _preview = null;
    if (_preview != null && _preview! > widget.count) _preview = widget.count;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _pop.value = 1;
  }

  void _request(int proposed, {bool clear = false}) {
    if (widget.readOnly) return;
    final previous = value;
    final next = clear && widget.allowClear && proposed == previous
        ? 0
        : proposed;
    if (next == previous) return;
    if (widget.value == null) {
      setState(() {
        _local = next;
        if (next == 0) _preview = null;
      });
      animateChange(previous, next);
    }
    widget.onChanged?.call(next);
  }

  void animateChange(int previous, int next) {
    _burstFrom = previous;
    _burstTo = next;
    if (next > previous && !MediaQuery.disableAnimationsOf(context)) {
      _pop.duration = Duration(
        milliseconds: math.max(600, (next - previous - 1) * 60 + 350),
      );
      _pop.forward(from: 0);
    } else {
      _pop.value = 1;
    }
  }

  KeyEventResult _key(KeyEvent event) {
    if (event is! KeyDownEvent || widget.readOnly)
      return KeyEventResult.ignored;
    final key = event.logicalKey;
    int? next;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp)
      next = math.min(widget.count, value + 1);
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowDown)
      next = math.max(1, value - 1);
    if (key == LogicalKeyboardKey.home) next = 1;
    if (key == LogicalKeyboardKey.end) next = widget.count;
    if (next == null) return KeyEventResult.ignored;
    setState(() => _preview = null);
    _nodes[next - 1].requestFocus();
    _request(next);
    return KeyEventResult.handled;
  }

  double _scale(int index) {
    if (_pop.value == 1 || index < _burstFrom || index >= _burstTo) return 1;
    final elapsed = _pop.value * _pop.duration!.inMilliseconds;
    final progress = ((elapsed - (index - _burstFrom) * 60) / 350).clamp(
      0.0,
      1.0,
    );
    const curve = Cubic(.4, 0, .2, 1);
    return progress < .6
        ? 1 + .15 * curve.transform(progress / .6)
        : 1.15 - .15 * curve.transform((progress - .6) / .4);
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (size, gap) = switch (widget.size) {
      IslandSize.small => (20.0, 4.0),
      IslandSize.middle => (26.0, 6.0),
      IslandSize.large => (34.0, 8.0),
    };
    for (var i = 0; i < _nodes.length; i++) {
      _nodes[i].skipTraversal = widget.readOnly || i != math.max(0, value - 1);
    }
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 250);
    return Semantics(
      label: widget.semanticLabel,
      role: SemanticsRole.radioGroup,
      container: true,
      explicitChildNodes: true,
      child: MouseRegion(
        onExit: (_) => setState(() => _preview = null),
        child: OverflowBox(
          minWidth: 0,
          maxWidth: double.infinity,
          fit: OverflowBoxFit.deferToChild,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.count; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Focus(
                  onKeyEvent: (_, event) => _key(event),
                  canRequestFocus: false,
                  child: MouseRegion(
                    onEnter: widget.readOnly
                        ? null
                        : (_) => setState(() => _preview = i + 1),
                    child: ActionSurface(
                      inMutuallyExclusiveGroup: true,
                      button: false,
                      checked: value == i + 1,
                      label: '${i + 1} 星',
                      focusNode: _nodes[i],
                      onActivate: widget.readOnly
                          ? null
                          : () => _request(i + 1, clear: true),
                      builder: (_, states) => AnimatedContainer(
                        duration: duration,
                        curve: const Cubic(.4, 0, .2, 1),
                        transform: Matrix4.translationValues(
                          0,
                          states.contains(WidgetState.hovered) ? -1 : 0,
                          0,
                        ),
                        child: AnimatedBuilder(
                          animation: _pop,
                          builder: (_, _) => CustomPaint(
                            painter: _RateSplash(
                              progress:
                                  i == _burstTo - 1 &&
                                      _burstTo > _burstFrom &&
                                      !reduced
                                  ? (_pop.value *
                                            _pop.duration!.inMilliseconds /
                                            600)
                                        .clamp(0.0, 1.0)
                                  : 1,
                              scale: switch (widget.size) {
                                IslandSize.small => .91,
                                IslandSize.middle => 1.18,
                                IslandSize.large => 1.55,
                              },
                            ),
                            child: Transform.scale(
                              scale: _scale(i),
                              child: DecoratedBox(
                                decoration: FocusOutline(
                                  const CircleBorder(),
                                  states.contains(WidgetState.focused)
                                      ? IslandTheme.of(context).focus
                                      : Colors.transparent,
                                  width: 2,
                                  offset: 1,
                                ),
                                child: CustomPaint(
                                  size: Size.square(size),
                                  painter: _StarPainter(
                                    i < (_preview ?? value),
                                    i < (_preview ?? value)
                                        ? IslandTheme.of(context).onSun
                                        : IslandTheme.of(context).ink,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _RateSplash extends CustomPainter {
  const _RateSplash({required this.progress, required this.scale});
  final double progress, scale;
  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    paintSixDotSplash(
      canvas,
      Offset.zero,
      22,
      const Color(0xfff5c31c),
      progress,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RateSplash old) =>
      old.progress != progress || old.scale != scale;
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.fill, this.outline);
  final bool fill;
  final Color outline;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48);
    final path = Path()
      ..moveTo(24, 6)
      ..lineTo(29, 18)
      ..lineTo(42, 19)
      ..lineTo(32, 28)
      ..lineTo(35, 41)
      ..lineTo(24, 34)
      ..lineTo(13, 41)
      ..lineTo(16, 28)
      ..lineTo(6, 19)
      ..lineTo(19, 18)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = fill ? const Color(0xfff5c31c) : Colors.transparent,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = outline,
    );
    if (fill) {
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = outline;
      canvas.drawCircle(const Offset(20, 22), 1.3, stroke);
      canvas.drawCircle(const Offset(28, 22), 1.3, stroke);
      final eyes = Paint()..color = outline;
      canvas.drawCircle(const Offset(20, 22), 1.3, eyes);
      canvas.drawCircle(const Offset(28, 22), 1.3, eyes);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.fill != fill || old.outline != outline;
}
