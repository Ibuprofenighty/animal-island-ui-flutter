import '../foundation/theme.dart';
import '../internal/focus_outline.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/time_value.dart';
import '../foundation/size.dart';
import '../foundation/field_status.dart';
import '../internal/action_surface.dart';
import '../internal/anchored_panel.dart';
import '../internal/picker_panel.dart';
import '../internal/picker_trigger.dart';

class IslandTimePicker extends StatefulWidget {
  const IslandTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = '请选择时间',
    this.label = '选择时间',
    this.disabled = false,
    this.allowClear = false,
    this.size = IslandSize.middle,
    this.status = IslandFieldStatus.normal,
    this.format = 'HH:mm:ss',
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.open,
    this.onOpenChanged,
    this.focusNode,
    this.now,
  }) : initialValue = null,
       controlled = true,
       assert(hourStep > 0 && minuteStep > 0 && secondStep > 0);
  const IslandTimePicker.uncontrolled({
    super.key,
    this.initialValue,
    this.onChanged,
    this.placeholder = '请选择时间',
    this.label = '选择时间',
    this.disabled = false,
    this.allowClear = false,
    this.size = IslandSize.middle,
    this.status = IslandFieldStatus.normal,
    this.format = 'HH:mm:ss',
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.open,
    this.onOpenChanged,
    this.focusNode,
    this.now,
  }) : value = null,
       controlled = false,
       assert(hourStep > 0 && minuteStep > 0 && secondStep > 0);
  final IslandTimeValue? value, initialValue;
  final ValueChanged<IslandTimeValue?>? onChanged;
  final bool controlled, disabled, allowClear;
  final String placeholder, label, format;
  final IslandSize size;
  final IslandFieldStatus status;
  final int hourStep, minuteStep, secondStep;
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;
  final FocusNode? focusNode;
  final DateTime Function()? now;
  @override
  State<IslandTimePicker> createState() => _IslandTimePickerState();
}

class _IslandTimePickerState extends State<IslandTimePicker> {
  late IslandTimeValue? inner = widget.initialValue;
  late IslandTimeValue pending = current ?? const IslandTimeValue(0, 0);
  bool innerOpen = false;
  final ownedFocus = FocusNode();
  FocusNode get focus => widget.focusNode ?? ownedFocus;
  IslandTimeValue? get current => widget.controlled ? widget.value : inner;
  bool get open => !widget.disabled && (widget.open ?? innerOpen);
  final scrolls = List.generate(3, (_) => ScrollController());
  @override
  void initState() {
    super.initState();
    if (open) prepare();
  }

  @override
  void didUpdateWidget(IslandTimePicker old) {
    super.didUpdateWidget(old);
    final wasOpen = !old.disabled && (old.open ?? innerOpen);
    if (open &&
        (!wasOpen ||
            old.format != widget.format ||
            old.hourStep != widget.hourStep ||
            old.minuteStep != widget.minuteStep ||
            old.secondStep != widget.secondStep))
      prepare();
  }

  void prepare() {
    pending = current ?? const IslandTimeValue(0, 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !open) return;
        // The reference scrolls with a 38px nominal stride despite 30px actual rows.
        for (var i = 0; i < 3; i++) {
          if (!scrolls[i].hasClients) continue;
          final value = [pending.hour, pending.minute, pending.second][i];
          final step = [
            widget.hourStep,
            widget.minuteStep,
            widget.secondStep,
          ][i];
          final target = (value ~/ step) * 38 - 116 + 19;
          scrolls[i].jumpTo(
            target.toDouble().clamp(0, scrolls[i].position.maxScrollExtent),
          );
        }
      });
    });
  }

  void requestOpen(bool next, {bool restore = false}) {
    if (widget.disabled || open == next) return;
    if (widget.open == null) {
      setState(() {
        innerOpen = next;
        if (next) prepare();
      });
    }
    widget.onOpenChanged?.call(next);
    if (mounted && restore) focus.requestFocus();
  }

  void commit(IslandTimeValue? value) {
    if (widget.disabled) return;
    if (!widget.controlled) setState(() => inner = value);
    widget.onChanged?.call(value);
  }

  void confirm() {
    if (pending != current) commit(pending);
    if (mounted) requestOpen(false, restore: true);
  }

  KeyEventResult key(KeyEvent event) {
    if (event is! KeyDownEvent || widget.disabled)
      return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape && open) {
      requestOpen(false, restore: true);
      return KeyEventResult.handled;
    }
    if (!open &&
        [
          LogicalKeyboardKey.arrowDown,
          LogicalKeyboardKey.arrowUp,
        ].contains(event.logicalKey)) {
      requestOpen(true);
      return KeyEventResult.handled;
    }
    if (open &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        focus.hasPrimaryFocus) {
      confirm();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    ownedFocus.dispose();
    for (final c in scrolls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = open ? pending : current;
    final seconds = widget.format.contains('ss');
    return PickerFocusBoundary(
      onKeyEvent: (_, event) => key(event),
      onFocusExit: () => requestOpen(false),
      child: AnchoredPanel(
        open: open,
        transitionDuration: const Duration(milliseconds: 200),
        width: seconds ? 248 : 172,
        estimatedHeight: 336,
        onDismiss: () => requestOpen(false),
        anchor: PickerTrigger(
          text: shown?.format(widget.format) ?? widget.placeholder,
          label: widget.label,
          hasValue: current != null,
          open: open,
          disabled: widget.disabled,
          size: widget.size,
          status: widget.status,
          icon: const CustomPaint(size: Size(14, 14), painter: _ClockPainter()),
          focusNode: focus,
          onKeyboardActivate: () => open ? confirm() : requestOpen(true),
          onActivate: () {
            if (open && focus.hasPrimaryFocus) {
              requestOpen(false);
            } else {
              requestOpen(true);
            }
          },
          clearLabel: '清除时间',
          onClear: widget.allowClear && current != null
              ? () {
                  commit(null);
                  if (mounted) focus.requestFocus();
                }
              : null,
        ),
        panel: SingleChildScrollView(
          child: Semantics(
            label: widget.label,
            scopesRoute: true,
            explicitChildNodes: true,
            child: Focus(
              canRequestFocus: false,
              onKeyEvent: (_, event) => key(event),
              child: PickerPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: column(0, '时', 24, widget.hourStep, pending.hour),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: column(
                        1,
                        '分',
                        60,
                        widget.minuteStep,
                        pending.minute,
                      ),
                    ),
                    if (seconds) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: column(
                          2,
                          '秒',
                          60,
                          widget.secondStep,
                          pending.second,
                        ),
                      ),
                    ],
                  ],
                ),
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PickerFooterAction(
                      '此刻',
                      onPressed: () {
                        final now = widget.now?.call() ?? DateTime.now();
                        setState(
                          () => pending = IslandTimeValue(
                            now.hour,
                            now.minute,
                            now.second,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    PickerFooterAction('确定', primary: true, onPressed: confirm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget column(int column, String unit, int count, int step, int selected) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              letterSpacing: 1,
              color: IslandTokens.light.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 232,
            child: ListView(
              controller: scrolls[column],
              padding: const EdgeInsets.all(2),
              children: [
                for (var value = 0; value < count; value += step)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: ActionSurface(
                      key: ValueKey((column, value)),
                      label: '$value $unit',
                      selected: selected == value,
                      onActivate: () => setState(
                        () => pending = pending.copyWith(
                          hour: column == 0 ? value : null,
                          minute: column == 1 ? value : null,
                          second: column == 2 ? value : null,
                        ),
                      ),
                      builder: (_, states) => Container(
                        height: 28,
                        foregroundDecoration: FocusOutline(
                          const StadiumBorder(),
                          states.contains(WidgetState.focused)
                              ? IslandTokens.light.focus
                              : Colors.transparent,
                          width: 2,
                          offset: 0,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: selected == value
                              ? const Color(0xffffb400)
                              : states.contains(WidgetState.hovered) ||
                                    states.contains(WidgetState.focused)
                              ? const Color(0xffffd54f)
                              : null,
                        ),
                        child: ExcludeSemantics(
                          child: Text(
                            value.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: selected == value
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected == value
                                  ? IslandTokens.light.onSun
                                  : const Color(0xff725d42),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
}

class _ClockPainter extends CustomPainter {
  const _ClockPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = IslandTokens.light.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(7, 7), 5.5, p);
    canvas.drawPath(
      Path()
        ..moveTo(7, 4.2)
        ..lineTo(7, 7)
        ..lineTo(9, 8.2),
      p,
    );
  }

  @override
  bool shouldRepaint(_ClockPainter old) => false;
}
