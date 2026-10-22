import '../foundation/theme.dart';
import '../internal/focus_outline.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/size.dart';
import '../foundation/field_status.dart';
import '../internal/action_surface.dart';
import '../internal/anchored_panel.dart';
import '../internal/picker_trigger.dart';
import '../internal/picker_panel.dart';

enum IslandDatePickerMode { date, month }

enum _CalendarView { date, month, year }

/// Calendar dates are normalized to local midnight. Values are committed only
/// by confirmation or clear; open is independently controlled when non-null.
class IslandDatePicker extends StatefulWidget {
  const IslandDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.mode = IslandDatePickerMode.date,
    this.placeholder = '请选择日期',
    this.label = '选择日期',
    this.disabled = false,
    this.allowClear = false,
    this.size = IslandSize.middle,
    this.status = IslandFieldStatus.normal,
    this.format = 'YYYY-MM-DD',
    this.disabledDate,
    this.open,
    this.onOpenChanged,
    this.showToday = true,
    this.focusNode,
    this.now,
  }) : _range = false,
       controlled = true,
       initialValue = null,
       _rangeValue = null,
       _initialRange = null,
       _onRangeChanged = null;
  const IslandDatePicker.uncontrolled({
    super.key,
    this.initialValue,
    this.onChanged,
    this.mode = IslandDatePickerMode.date,
    this.placeholder = '请选择日期',
    this.label = '选择日期',
    this.disabled = false,
    this.allowClear = false,
    this.size = IslandSize.middle,
    this.status = IslandFieldStatus.normal,
    this.format = 'YYYY-MM-DD',
    this.disabledDate,
    this.open,
    this.onOpenChanged,
    this.showToday = true,
    this.focusNode,
    this.now,
  }) : _range = false,
       controlled = false,
       value = null,
       _rangeValue = null,
       _initialRange = null,
       _onRangeChanged = null;
  const IslandDatePicker.range({
    super.key,
    required DateTimeRange? value,
    required ValueChanged<DateTimeRange?>? onChanged,
    this.placeholder = '请选择日期',
    this.label = '选择日期',
    this.disabled = false,
    this.allowClear = false,
    this.size = IslandSize.middle,
    this.status = IslandFieldStatus.normal,
    this.format = 'YYYY-MM-DD',
    this.disabledDate,
    this.open,
    this.onOpenChanged,
    this.showToday = true,
    this.focusNode,
    this.now,
  }) : _range = true,
       controlled = true,
       value = null,
       initialValue = null,
       onChanged = null,
       mode = IslandDatePickerMode.date,
       _rangeValue = value,
       _initialRange = null,
       _onRangeChanged = onChanged;
  const IslandDatePicker.rangeUncontrolled({
    super.key,
    DateTimeRange? initialValue,
    ValueChanged<DateTimeRange?>? onChanged,
    this.placeholder = '请选择日期',
    this.label = '选择日期',
    this.disabled = false,
    this.allowClear = false,
    this.size = IslandSize.middle,
    this.status = IslandFieldStatus.normal,
    this.format = 'YYYY-MM-DD',
    this.disabledDate,
    this.open,
    this.onOpenChanged,
    this.showToday = true,
    this.focusNode,
    this.now,
  }) : _range = true,
       controlled = false,
       value = null,
       initialValue = null,
       onChanged = null,
       mode = IslandDatePickerMode.date,
       _rangeValue = null,
       _initialRange = initialValue,
       _onRangeChanged = onChanged;
  final DateTime? value, initialValue;
  final ValueChanged<DateTime?>? onChanged;
  final DateTimeRange? _rangeValue, _initialRange;
  final ValueChanged<DateTimeRange?>? _onRangeChanged;
  final bool _range, controlled, disabled, allowClear, showToday;
  final IslandDatePickerMode mode;
  final String placeholder, label, format;
  final IslandSize size;
  final IslandFieldStatus status;
  final bool Function(DateTime)? disabledDate;
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;
  final FocusNode? focusNode;
  final DateTime Function()? now;
  @override
  State<IslandDatePicker> createState() => _IslandDatePickerState();
}

class _IslandDatePickerState extends State<IslandDatePicker> {
  late DateTime? inner = widget.initialValue;
  late DateTimeRange? innerRange = widget._initialRange;
  DateTime? pending, start, end, hover;
  late DateTime view, focused;
  _CalendarView mode = _CalendarView.date;
  bool innerOpen = false;
  final ownedFocus = FocusNode();
  FocusNode get focus => widget.focusNode ?? ownedFocus;
  DateTime? get current => widget.controlled ? widget.value : inner;
  DateTimeRange? get range =>
      widget.controlled ? widget._rangeValue : innerRange;
  bool get open => !widget.disabled && (widget.open ?? innerOpen);
  DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime get today => day((widget.now ?? DateTime.now)());
  bool same(DateTime? a, DateTime? b) =>
      a != null && b != null && DateUtils.isSameDay(a, b);
  bool blocked(DateTime d) => widget.disabledDate?.call(day(d)) ?? false;
  String format(DateTime d) {
    final template =
        widget.mode == IslandDatePickerMode.month &&
            widget.format == 'YYYY-MM-DD'
        ? 'YYYY-MM'
        : widget.format;
    return template.replaceAllMapped(
      RegExp('YYYY|MM|DD|M|D'),
      (m) => switch (m[0]) {
        'YYYY' => d.year.toString().padLeft(4, '0'),
        'MM' => d.month.toString().padLeft(2, '0'),
        'DD' => d.day.toString().padLeft(2, '0'),
        'M' => '${d.month}',
        _ => '${d.day}',
      },
    );
  }

  @override
  void initState() {
    super.initState();
    prepare();
  }

  void prepare() {
    focused = day((widget._range ? range?.start : current) ?? today);
    view = DateTime(focused.year, focused.month);
    mode = widget.mode == IslandDatePickerMode.month
        ? _CalendarView.month
        : _CalendarView.date;
    pending = start = end = hover = null;
  }

  @override
  void didUpdateWidget(IslandDatePicker old) {
    super.didUpdateWidget(old);
    final wasOpen = !old.disabled && (old.open ?? innerOpen);
    if (open &&
        (!wasOpen || old.mode != widget.mode || old._range != widget._range))
      prepare();
  }

  void request(bool next, {bool restore = false}) {
    if (widget.disabled || open == next) return;
    if (widget.open == null)
      setState(() {
        innerOpen = next;
        if (next) prepare();
      });
    widget.onOpenChanged?.call(next);
    if (mounted && restore) focus.requestFocus();
  }

  void commit({bool clear = false}) {
    if (widget.disabled) return;
    if (widget._range) {
      if (!clear &&
          (start == null || end == null || blocked(start!) || blocked(end!)))
        return;
      final next = clear ? null : DateTimeRange(start: start!, end: end!);
      if (!widget.controlled) setState(() => innerRange = next);
      widget._onRangeChanged?.call(next);
    } else {
      if (!clear && (pending == null || blocked(pending!))) return;
      final next = clear
          ? null
          : widget.mode == IslandDatePickerMode.month
          ? DateTime(pending!.year, pending!.month)
          : day(pending!);
      if (!widget.controlled) setState(() => inner = next);
      widget.onChanged?.call(next);
    }
  }

  void confirm() {
    commit();
    if (mounted) request(false, restore: true);
  }

  void select(DateTime d) {
    d = day(d);
    if (blocked(d)) return;
    setState(() {
      focused = d;
      if (!widget._range) {
        pending = d;
      } else if (start == null || d.isBefore(start!)) {
        start = d;
      } else {
        end = d;
      }
    });
    focus.requestFocus();
  }

  void chooseMonth(int month) {
    final d = DateTime(view.year, month);
    if (widget.mode == IslandDatePickerMode.month) {
      select(d);
      return;
    }
    setState(() {
      view = focused = d;
      mode = _CalendarView.date;
    });
    focus.requestFocus();
  }

  void shift(int years, int months) => setState(() {
    view = DateTime(view.year + years, view.month + months);
  });
  void keyboardSelect() {
    switch (mode) {
      case _CalendarView.date:
        select(focused);
      case _CalendarView.month:
        chooseMonth(view.month);
      case _CalendarView.year:
        setState(() => mode = _CalendarView.month);
    }
  }

  KeyEventResult key(KeyEvent e) {
    if (e is! KeyDownEvent || widget.disabled) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.escape && open) {
      request(false, restore: true);
      return KeyEventResult.handled;
    }
    if (!focus.hasPrimaryFocus) return KeyEventResult.ignored;
    final delta = {
      LogicalKeyboardKey.arrowLeft: -1,
      LogicalKeyboardKey.arrowRight: 1,
      LogicalKeyboardKey.arrowUp: -7,
      LogicalKeyboardKey.arrowDown: 7,
    }[k];
    if (!open && delta != null) {
      request(true);
      return KeyEventResult.handled;
    }
    if (!open) return KeyEventResult.ignored;
    if (delta != null) {
      setState(() {
        focused = switch (mode) {
          _CalendarView.date => DateTime(
            focused.year,
            focused.month,
            focused.day + delta,
          ),
          _CalendarView.month => DateTime(view.year, view.month + delta),
          _CalendarView.year => DateTime(view.year + delta, view.month),
        };
        view = DateTime(focused.year, focused.month);
      });
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.pageUp || k == LogicalKeyboardKey.pageDown) {
      final n = k == LogicalKeyboardKey.pageUp ? -1 : 1;
      shift(
        mode == _CalendarView.date
            ? 0
            : n * (mode == _CalendarView.year ? 10 : 1),
        mode == _CalendarView.date ? n : 0,
      );
      focused = DateTime(view.year, view.month, focused.day);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    ownedFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = (open ? pending : null) ?? current;
    final first = open && start != null ? start : range?.start;
    final last = open && start != null ? end : range?.end;
    return PickerFocusBoundary(
      onKeyEvent: (_, event) => key(event),
      onFocusExit: () => request(false),
      child: AnchoredPanel(
        open: open,
        transitionDuration: const Duration(milliseconds: 200),
        onDismiss: () => request(false),
        width: widget._range ? 600 : 280,
        estimatedHeight: 360,
        anchor: PickerTrigger(
          text: shown == null ? widget.placeholder : format(shown),
          valueContent: widget._range
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        first == null ? widget.placeholder : format(first),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: const Color(0xffe8dcc8),
                    ),
                    Flexible(
                      child: Text(
                        last == null ? widget.placeholder : format(last),
                        overflow: TextOverflow.ellipsis,
                        style: last == null
                            ? TextStyle(
                                color: IslandTokens.light.muted,
                                fontWeight: FontWeight.w400,
                              )
                            : null,
                      ),
                    ),
                  ],
                )
              : null,
          label: widget.label,
          hasValue: widget._range ? first != null : shown != null,
          open: open,
          disabled: widget.disabled,
          size: widget.size,
          status: widget.status,
          icon: const CustomPaint(size: Size(14, 14), painter: _CalendarIcon()),
          focusNode: focus,
          onActivate: () => request(!open),
          onKeyboardActivate: () => open ? keyboardSelect() : request(true),
          clearLabel: '清除日期',
          onClear: widget.allowClear
              ? (() {
                  commit(clear: true);
                  if (mounted) focus.requestFocus();
                })
              : null,
        ),
        panel: SingleChildScrollView(
          child: Semantics(
            label: widget._range ? '选择日期范围' : '选择日期',
            child: PickerPanel(
              borderWidth: 1.5,
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.showToday && !widget._range) ...[
                    PickerFooterAction(
                      '今天',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      fontSize: 13,
                      onPressed: () {
                        final d = today;
                        setState(() {
                          view = DateTime(d.year, d.month);
                          focused = d;
                          mode = widget.mode == IslandDatePickerMode.month
                              ? _CalendarView.month
                              : _CalendarView.date;
                          if (!blocked(d)) pending = d;
                        });
                        focus.requestFocus();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  PickerFooterAction(
                    '确定',
                    primary: true,
                    primaryHoverColor: const Color(0xff796c5a),
                    onPressed: confirm,
                  ),
                ],
              ),
              child: widget._range
                  ? LayoutBuilder(
                      builder: (context, c) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 568,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: calendar(view, index: 0)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: calendar(
                                  DateTime(view.year, view.month + 1),
                                  index: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: 249, child: calendar(view)),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget calendar(DateTime date, {int? index}) {
    final range = widget._range;
    final decade = (view.year ~/ 10) * 10;
    Widget nav(bool forward, bool year) => ActionSurface(
      label: year ? (forward ? '下一年' : '上一年') : (forward ? '下个月' : '上个月'),
      onActivate: () {
        shift(
          year ? (forward ? 1 : -1) * (mode == _CalendarView.year ? 10 : 1) : 0,
          year
              ? 0
              : forward
              ? 1
              : -1,
        );
        focus.requestFocus();
      },
      builder: (_, states) => Container(
        foregroundDecoration: FocusOutline(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          states.contains(WidgetState.focused)
              ? IslandTokens.light.focus
              : Colors.transparent,
          width: 2,
          offset: -2,
        ),
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: states.contains(WidgetState.hovered)
              ? const Color(0x1a725d42)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          size: Size.square(year ? 16 : 12),
          painter: _CalendarChevron(forward),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!range || index == 0) ...[
                    nav(false, true),
                    if (mode == _CalendarView.date) ...[
                      const SizedBox(width: 2),
                      nav(false, false),
                    ],
                  ],
                ],
              ),
              if (range || mode == _CalendarView.year)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    range
                        ? '${date.year}年${date.month}月'
                        : '${decade} - ${decade + 9}年',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff725d42),
                    ),
                  ),
                )
              else
                ActionSurface(
                  onActivate: () => setState(() => mode = _CalendarView.year),
                  builder: (_, states) => Container(
                    foregroundDecoration: FocusOutline(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      states.contains(WidgetState.focused)
                          ? IslandTokens.light.focus
                          : Colors.transparent,
                      width: 2,
                      offset: -2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: states.contains(WidgetState.hovered)
                          ? const Color(0xffe6f9f6)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      mode == _CalendarView.date
                          ? '${date.year}年${date.month}月'
                          : '${date.year}年',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: states.contains(WidgetState.hovered)
                            ? IslandTokens.light.link
                            : const Color(0xff725d42),
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!range || index == 1) ...[
                    if (mode == _CalendarView.date) ...[
                      nav(true, false),
                      const SizedBox(width: 2),
                    ],
                    nav(true, true),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (mode == _CalendarView.date || range)
          dayGrid(date)
        else
          Column(
            children: [
              for (var row = 0; row < 4; row++)
                Padding(
                  padding: EdgeInsets.only(bottom: row == 3 ? 0 : 4),
                  child: Row(
                    children: [
                      for (var col = 0; col < 3; col++) ...[
                        if (col > 0) const SizedBox(width: 4),
                        Expanded(child: periodCell(row * 3 + col, decade)),
                      ],
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget periodCell(int index, int decade) {
    final year = mode == _CalendarView.year;
    final number = year ? decade + index - 1 : index + 1;
    final selected = year
        ? current?.year == number
        : (pending ?? current)?.year == view.year &&
              (pending ?? current)?.month == number;
    return cell(
      label: year ? '${number}年' : '${number}月',
      text: year ? '${number}' : '${number}月',
      selected: selected,
      round: false,
      onPressed: () {
        if (year) {
          setState(() {
            view = focused = DateTime(number, view.month);
            mode = _CalendarView.month;
          });
          focus.requestFocus();
        } else
          chooseMonth(number);
      },
    );
  }

  Widget dayGrid(DateTime date) {
    final first = DateTime(date.year, date.month);
    final base = DateTime(date.year, date.month, 1 - first.weekday % 7);
    final r = range;
    DateTime? a = start ?? r?.start,
        b = end ?? (start == null ? r?.end : hover ?? start);
    if (a != null && b != null && b.isBefore(a)) {
      final swap = a;
      a = b;
      b = swap;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              for (final name in ['日', '一', '二', '三', '四', '五', '六'])
                Expanded(
                  child: SizedBox(
                    height: 24,
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: IslandTokens.light.muted,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (var row = 0; row < 6; row++)
          Padding(
            padding: EdgeInsets.only(bottom: row == 5 ? 0 : 2),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++) ...[
                  if (col > 0) const SizedBox(width: 2),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final d = DateTime(
                          base.year,
                          base.month,
                          base.day + row * 7 + col,
                        );
                        final selected = widget._range
                            ? a != null &&
                                  b != null &&
                                  !d.isBefore(a) &&
                                  !d.isAfter(b)
                            : same(d, pending ?? current);
                        return Center(
                          child: MouseRegion(
                            onEnter: (_) {
                              if (widget._range && start != null && end == null)
                                setState(() => hover = d);
                            },
                            onExit: (_) {
                              if (hover != null) setState(() => hover = null);
                            },
                            child: cell(
                              label: '${d.year}年${d.month}月${d.day}日',
                              text: '${d.day}',
                              selected: selected,
                              edge: widget._range && (same(d, a) || same(d, b)),
                              isToday: same(d, today),
                              outside: d.month != date.month,
                              onPressed: blocked(d) ? null : () => select(d),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget cell({
    required String label,
    required String text,
    required bool selected,
    required VoidCallback? onPressed,
    bool round = true,
    bool edge = false,
    bool isToday = false,
    bool outside = false,
  }) => ActionSurface(
    label: label,
    selected: selected,
    onActivate: onPressed,
    builder: (_, states) {
      final hover = states.contains(WidgetState.hovered);
      final disabled = onPressed == null;
      final range = widget._range && round;
      final color = disabled
          ? const Color(0xffd4c9b4)
          : selected
          ? (range ? IslandTokens.light.onSun : IslandTokens.light.onLeaf)
          : hover && range
          ? const Color(0xff725d42)
          : hover || isToday
          ? IslandTokens.light.link
          : outside
          ? IslandTokens.light.muted
          : const Color(0xff725d42);
      return Container(
        width: round ? 32 : null,
        foregroundDecoration: FocusOutline(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(round ? 16 : 12),
          ),
          states.contains(WidgetState.focused)
              ? IslandTokens.light.focus
              : Colors.transparent,
          width: 2,
          offset: 0,
        ),
        height: round ? 32 : 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(round ? 16 : 12),
          color: disabled
              ? null
              : selected
              ? (range
                    ? Color(hover ? 0xffffb400 : 0xffffc107)
                    : Color(hover ? 0xff3dd4c6 : 0xff19c8b9))
              : hover
              ? (range ? const Color(0xffffd54f) : const Color(0xffe6f9f6))
              : null,
          border: edge && !disabled
              ? Border.all(color: IslandTokens.light.onSun)
              : isToday
              ? Border.all(color: IslandTokens.light.link, width: 1.5)
              : null,
        ),
        child: ExcludeSemantics(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: color,
              fontWeight: selected || isToday
                  ? FontWeight.w700
                  : outside
                  ? FontWeight.w400
                  : FontWeight.w500,
            ),
          ),
        ),
      );
    },
  );
}

class _CalendarChevron extends CustomPainter {
  const _CalendarChevron(this.forward);
  final bool forward;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 12, size.height / 12);
    final path = Path()
      ..moveTo(forward ? 4.5 : 7.5, 2.5)
      ..lineTo(forward ? 8 : 4, 6)
      ..lineTo(forward ? 4.5 : 7.5, 9.5);
    canvas.drawPath(
      path,
      Paint()
        ..color = IslandTokens.light.muted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CalendarChevron old) => forward != old.forward;
}

class _CalendarIcon extends CustomPainter {
  const _CalendarIcon();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 16, size.height / 16);
    final paint = Paint()
      ..color = IslandTokens.light.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2.5, 3.5, 11, 10),
        const Radius.circular(1.5),
      ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(5, 2)
        ..lineTo(5, 5)
        ..moveTo(11, 2)
        ..lineTo(11, 5)
        ..moveTo(2.5, 7)
        ..lineTo(13.5, 7),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CalendarIcon old) => false;
}
