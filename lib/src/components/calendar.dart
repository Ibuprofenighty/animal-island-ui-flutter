import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/dashed_border.dart';
import '../foundation/icon.dart';
import '../foundation/localizations.dart';
import '../foundation/recipes/calendar.dart';
import '../foundation/theme.dart';
import '../foundation/time_value.dart';
import '../internal/action_surface.dart';
import '../internal/dot_pattern.dart';
import '../internal/focus_outline.dart';

/// Palette of an [IslandCalendarEvent] bar.
enum IslandCalendarColor {
  /// Default warm orange set (the reference keeps the name `teal`); it reads
  /// close to [coral], so prefer [green] or [purple] beside it.
  teal,

  /// Amber set.
  amber,

  /// Coral set.
  coral,

  /// Green set.
  green,

  /// Purple set.
  purple,
}

/// One calendar entry. Same-day entries share a date; a multi-day entry sets
/// a later [end] and renders as one continuous bar per week.
@immutable
class IslandCalendarEvent {
  const IslandCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.color = IslandCalendarColor.teal,
    this.showTime = false,
  });

  /// Stable identity, unique within [IslandCalendar.events]; a bar keeps its
  /// state when other entries are inserted or reordered.
  final Object id;

  /// Bar text and the entry's name in its day cells' accessible labels.
  final String title;

  /// Start: its date is the first day, and its time the optional `HH:mm`
  /// prefix (see [showTime]).
  ///
  /// Days are read from the value's own calendar fields, like every date of
  /// the library: a UTC value lands on its UTC date and shows its UTC time.
  /// Pass `toLocal()` to place an instant on the local calendar.
  final DateTime start;

  /// Last day, inclusive, read from its own calendar fields like [start];
  /// its time of day is ignored. Null, or a day before [start], makes a
  /// one-day entry.
  final DateTime? end;

  /// Bar palette.
  final IslandCalendarColor color;

  /// Prefixes the first bar with [start] as `HH:mm`, when
  /// [IslandCalendar.showEventTime] is also set. Continuation bars after a
  /// week break show the title only.
  final bool showTime;

  @override
  bool operator ==(Object other) =>
      other is IslandCalendarEvent &&
      other.id == id &&
      other.title == title &&
      other.start == start &&
      other.end == end &&
      other.color == color &&
      other.showTime == showTime;

  @override
  int get hashCode => Object.hash(id, title, start, end, color, showTime);
}

/// An always-visible month panel: a 6 × 7 day grid with month and year
/// navigation, a today (今天) shortcut, event bars and optional
/// drag-to-create. Chrome text comes from [IslandLocalizations].
///
/// The selected day and the panel month are controlled independently. Days
/// are reported as local midnight and months as their first day. The panel
/// fills the available width (750 when unbounded); its rhythm scales with
/// width / 750, clamped to 0.6–2.
class IslandCalendar extends StatefulWidget {
  /// Controlled selection: [value] is the selected day (null selects none)
  /// and [onChanged] only requests a change.
  const IslandCalendar({
    super.key,
    required this.value,
    required this.onChanged,
    this.month,
    this.initialMonth,
    this.onMonthChanged,
    this.events = const [],
    this.showEventTime = true,
    this.onCreateEvent,
    this.semanticLabel,
    this.now,
  }) : _controlled = true,
       initialValue = null;

  /// Component-owned selection starting at [initialValue], or today.
  const IslandCalendar.uncontrolled({
    super.key,
    this.initialValue,
    this.onChanged,
    this.month,
    this.initialMonth,
    this.onMonthChanged,
    this.events = const [],
    this.showEventTime = true,
    this.onCreateEvent,
    this.semanticLabel,
    this.now,
  }) : _controlled = false,
       value = null;

  final bool _controlled;

  /// Selected day of the controlled constructor.
  final DateTime? value;

  /// First selected day of [IslandCalendar.uncontrolled]; null selects today.
  final DateTime? initialValue;

  /// Selection request from a day cell, Enter/Space or the today action.
  final ValueChanged<DateTime>? onChanged;

  /// Controlled panel month when non-null; the panel then changes only when
  /// the parent passes the month reported by [onMonthChanged].
  final DateTime? month;

  /// First panel month while [month] is null; defaults to the selected day's
  /// month, else today's.
  final DateTime? initialMonth;

  /// Panel month request from the arrows, PageUp/PageDown, a keyboard move
  /// out of the month, or selecting a day of another month.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Entries drawn as bars, two rows per week; further entries of a day fold
  /// into `+N`. Entries entirely outside the 42 visible days are ignored.
  final List<IslandCalendarEvent> events;

  /// Allows the `HH:mm` prefix of [IslandCalendarEvent.showTime] entries.
  final bool showEventTime;

  /// Enables drag-to-create: a primary-button mouse drag across days shows
  /// a dashed preview and, released inside the panel, reports the ordered
  /// day range: `start` is the first and `end` the last day, inclusive, both
  /// at local midnight. A press and release on one day only selects it; a
  /// release outside the panel or a cancelled pointer reports nothing.
  final ValueChanged<DateTimeRange>? onCreateEvent;

  /// Accessible name of the day grid when no visible title names it.
  final String? semanticLabel;

  /// Source of today; defaults to the local clock.
  final DateTime Function()? now;

  @override
  State<IslandCalendar> createState() => _IslandCalendarState();
}

const _cells = 42, _cols = 7;

/// Reference `LAYOUT_BASE`: metrics at the 750px baseline width. Two event
/// rows must fit under the number band (42 + 2 × 22 ≤ 104) or a busy week
/// covers the next week's digits.
const _baseWidth = 750.0,
    _baseHeader = 32.0,
    _baseCell = 104.0,
    _baseNumberBand = 42.0,
    _baseEventRow = 22.0,
    _baseBar = 17.0,
    _baseNumber = 28.0,
    _baseEventFont = 11.0;
const _eventRows = 2;
const _bodyPad = 8.0;
const _curve = Cubic(0.4, 0, 0.2, 1);

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);
bool _sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;
int _daysFrom(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
int _clampIndex(DateTime d, DateTime gridStart) =>
    _daysFrom(gridStart, d).clamp(0, _cells - 1);

class _Segment {
  const _Segment(this.event, this.index, this.endIndex, this.row, this.first);

  /// Null for the drag preview.
  final IslandCalendarEvent? event;
  final int index, endIndex, row;

  /// The segment starts on the entry's own first day.
  final bool first;
}

class _Layout {
  const _Layout(this.segments, this.overflow);
  final List<_Segment> segments;
  final List<int> overflow;
}

/// Places entries in start order into the first free row of each week
/// segment. The preview takes a row but is not counted: counting it would
/// raise a `+N` while dragging over a full day.
_Layout _layout(
  List<IslandCalendarEvent> events,
  DateTime gridStart,
  DateTimeRange? preview,
) {
  final items =
      [
        for (final (order, event) in events.indexed)
          (
            event,
            event.start,
            _day(event.start),
            _day(event.end ?? event.start),
            order,
          ),
        if (preview != null)
          (null, preview.start, preview.start, preview.end, events.length),
      ]..sort((a, b) {
        final byStart = a.$2.compareTo(b.$2);
        return byStart != 0 ? byStart : a.$5.compareTo(b.$5);
      });
  final counts = List.filled(_cells, 0), drawn = List.filled(_cells, 0);
  final rows = List.generate(_cells, (_) => List.filled(_eventRows, false));
  final segments = <_Segment>[];
  for (final (event, _, first, end, _) in items) {
    final startIndex = _daysFrom(gridStart, first);
    final lastIndex = math.max(startIndex, _daysFrom(gridStart, end));
    if (lastIndex < 0 || startIndex >= _cells) continue;
    final from = startIndex.clamp(0, _cells - 1);
    final to = lastIndex.clamp(0, _cells - 1);
    if (event != null) for (var i = from; i <= to; i++) counts[i]++;
    for (var week = from ~/ _cols; week <= to ~/ _cols; week++) {
      final segFrom = math.max(from, week * _cols);
      final segTo = math.min(to, week * _cols + _cols - 1);
      final row = List.generate(_eventRows, (r) => r).firstWhere(
        (r) =>
            [for (var i = segFrom; i <= segTo; i++) rows[i][r]]
                .every((taken) => !taken),
        orElse: () => -1,
      );
      if (row < 0) continue;
      for (var i = segFrom; i <= segTo; i++) {
        rows[i][row] = true;
        drawn[i]++;
      }
      segments.add(_Segment(event, segFrom, segTo, row, segFrom == startIndex));
    }
  }
  return _Layout(segments, [
    for (var i = 0; i < _cells; i++) counts[i] - drawn[i],
  ]);
}

class _IslandCalendarState extends State<IslandCalendar> {
  final _nodes = List.generate(_cells, (_) => FocusNode());
  DateTime? _inner;
  late DateTime _innerMonth, _cursor;
  DateTime? _anchor, _head;
  bool _pendingFocus = false;

  DateTime get _today => _day((widget.now ?? DateTime.now)());
  DateTime? get _selected {
    final value = widget._controlled ? widget.value : _inner;
    return value == null ? null : _day(value);
  }

  DateTime get _viewMonth =>
      widget.month == null ? _innerMonth : _monthOf(widget.month!);
  DateTime _gridStart(DateTime month) =>
      DateTime(month.year, month.month, 1 - month.weekday % 7);
  DateTime _cellDate(DateTime gridStart, int index) =>
      DateTime(gridStart.year, gridStart.month, gridStart.day + index);

  @override
  void initState() {
    super.initState();
    if (!widget._controlled) _inner = _day(widget.initialValue ?? _today);
    _innerMonth = _monthOf(widget.initialMonth ?? _selected ?? _today);
    _cursor = _selected ?? _today;
  }

  @override
  void didUpdateWidget(IslandCalendar old) {
    super.didUpdateWidget(old);
    final next = _selected;
    final previous = old._controlled ? old.value : null;
    if (!widget._controlled ||
        next == null ||
        (previous != null && _day(previous) == next)) {
      return;
    }
    _cursor = next;
    if (widget.month == null && !_sameMonth(next, _innerMonth)) {
      _innerMonth = _monthOf(next);
    }
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _select(DateTime date) {
    final day = _day(date);
    final month = _viewMonth;
    setState(() {
      _cursor = day;
      if (!widget._controlled) _inner = day;
      if (!_sameMonth(day, month) && widget.month == null) {
        _innerMonth = _monthOf(day);
      }
    });
    widget.onChanged?.call(day);
    if (!_sameMonth(day, month)) widget.onMonthChanged?.call(_monthOf(day));
  }

  void _shift(int months) {
    final month = _viewMonth;
    final focus = _cellDate(
      _gridStart(month),
      _clampIndex(_cursor, _gridStart(month)),
    );
    final next = DateTime(month.year, month.month + months);
    setState(() {
      _cursor = DateTime(
        next.year,
        next.month,
        math.min(focus.day, DateUtils.getDaysInMonth(next.year, next.month)),
      );
      if (widget.month == null) _innerMonth = next;
    });
    widget.onMonthChanged?.call(next);
  }

  KeyEventResult _key(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown) {
      _pendingFocus = true;
      _shift(key == LogicalKeyboardKey.pageUp ? -1 : 1);
      return KeyEventResult.handled;
    }
    final delta = {
      LogicalKeyboardKey.arrowLeft: -1,
      LogicalKeyboardKey.arrowRight: 1,
      LogicalKeyboardKey.arrowUp: -_cols,
      LogicalKeyboardKey.arrowDown: _cols,
    }[key];
    if (delta == null) return KeyEventResult.ignored;
    final month = _viewMonth;
    final grid = _gridStart(month);
    final focus = _cellDate(grid, _clampIndex(_cursor, grid));
    final next = DateTime(focus.year, focus.month, focus.day + delta);
    _pendingFocus = true;
    setState(() {
      _cursor = next;
      if (!_sameMonth(next, month) && widget.month == null) {
        _innerMonth = _monthOf(next);
      }
    });
    if (!_sameMonth(next, month)) widget.onMonthChanged?.call(_monthOf(next));
    return KeyEventResult.handled;
  }

  int? _cellAt(Offset local, double columnWidth, double scale) {
    final y = local.dy - _baseHeader * scale;
    if (local.dx < 0 || y < 0) return null;
    final column = local.dx ~/ columnWidth, week = y ~/ (_baseCell * scale);
    if (column >= _cols || week >= _cells ~/ _cols) return null;
    return week * _cols + column;
  }

  void _finishDrag(bool commit) {
    final anchor = _anchor, head = _head;
    if (anchor == null || head == null) return;
    setState(() => _anchor = _head = null);
    if (!commit || anchor == head) return;
    final ordered = anchor.isBefore(head) ? (anchor, head) : (head, anchor);
    widget.onCreateEvent?.call(
      DateTimeRange(start: ordered.$1, end: ordered.$2),
    );
  }

  String _cellLabel(DateTime day, List<IslandCalendarEvent> covering) {
    final titles = {
      for (final event in covering)
        if (event.title.isNotEmpty) event.title,
    };
    return IslandLocalizations.of(context).calendarDay(
      formatDateTokens(day, 'YYYY-MM-DD'),
      covering.length,
      titles.toList(),
      more: titles.isNotEmpty && titles.length < covering.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.events.map((event) => event.id).toSet().length ==
          widget.events.length,
      'IslandCalendarEvent.id must be unique',
    );
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 150);
    final month = _viewMonth;
    final grid = _gridStart(month);
    final today = _today;
    final focusIndex = _clampIndex(_cursor, grid);
    final selected = _selected;
    final selectedIndex = selected == null ? null : _clampIndex(selected, grid);
    for (var i = 0; i < _cells; i++) {
      _nodes[i].skipTraversal = i != focusIndex;
    }
    if (_pendingFocus) {
      _pendingFocus = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = _gridStart(_viewMonth);
        _nodes[_clampIndex(_cursor, current)].requestFocus();
      });
    }
    final anchor = _anchor, head = _head;
    final preview = anchor == null || head == null
        ? null
        : anchor.isBefore(head)
        ? DateTimeRange(start: anchor, end: head)
        : DateTimeRange(start: head, end: anchor);
    final layout = _layout(widget.events, grid, preview);
    final covering = List.generate(_cells, (_) => <IslandCalendarEvent>[]);
    for (final event in widget.events) {
      final first = _daysFrom(grid, event.start);
      final last = math.max(first, _daysFrom(grid, event.end ?? event.start));
      if (last < 0 || first >= _cells) continue;
      for (var i = math.max(0, first); i <= math.min(last, _cells - 1); i++) {
        covering[i].add(event);
      }
    }
    return Listener(
      onPointerUp: (event) {
        final box = context.findRenderObject() as RenderBox?;
        _finishDrag(box?.size.contains(event.localPosition) ?? false);
      },
      onPointerCancel: (_) => _finishDrag(false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : _baseWidth;
          final scale = (width / _baseWidth).clamp(0.6, 2.0);
          final border = IslandTheme.borderWidth(context, 1.5);
          final columnWidth = (width - 2 * border - 2 * _bodyPad) / _cols;
          return SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(month, today, duration),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: CalendarColors.panelFill,
                    border: Border.all(
                      color: CalendarColors.panelBorder,
                      width: border,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: CalendarColors.panelShadow,
                        offset: Offset(0, 6),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(border),
                    child: CustomPaint(
                      painter: const DotPatternPainter(
                        largeDot: CalendarColors.panelLargeDot,
                        smallDot: CalendarColors.panelSmallDot,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          _bodyPad,
                          _bodyPad,
                          _bodyPad,
                          _baseEventRow * scale * _eventRows + 6 + _bodyPad,
                        ),
                        child: Semantics(
                          container: true,
                          label: widget.semanticLabel,
                          child: Focus(
                            canRequestFocus: false,
                            skipTraversal: true,
                            includeSemantics: false,
                            onKeyEvent: _key,
                            child: Listener(
                              onPointerDown: (event) {
                                if (widget.onCreateEvent == null ||
                                    event.kind != PointerDeviceKind.mouse ||
                                    event.buttons != kPrimaryMouseButton) {
                                  return;
                                }
                                final index = _cellAt(
                                  event.localPosition,
                                  columnWidth,
                                  scale,
                                );
                                if (index == null) return;
                                final date = _cellDate(grid, index);
                                setState(() => _anchor = _head = date);
                              },
                              onPointerMove: (event) {
                                if (_anchor == null) return;
                                final index = _cellAt(
                                  event.localPosition,
                                  columnWidth,
                                  scale,
                                );
                                if (index == null) return;
                                final date = _cellDate(grid, index);
                                if (date != _head) {
                                  setState(() => _head = date);
                                }
                              },
                              child: Stack(
                                children: [
                                  _grid(
                                    grid: grid,
                                    month: month,
                                    today: today,
                                    selectedIndex: selectedIndex,
                                    layout: layout,
                                    covering: covering,
                                    scale: scale,
                                    duration: duration,
                                  ),
                                  for (final segment in layout.segments)
                                    _bar(segment, columnWidth, scale),
                                ],
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
    );
  }

  Widget _header(DateTime month, DateTime today, Duration duration) {
    final strings = IslandLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    Widget arrow(String label, bool forward, bool year) => ActionSurface(
      label: label,
      onActivate: () => _shift((forward ? 1 : -1) * (year ? 12 : 1)),
      builder: (_, states) {
        final hover = states.contains(WidgetState.hovered);
        return AnimatedContainer(
          duration: duration,
          curve: _curve,
          width: 28,
          height: 28,
          alignment: Alignment.center,
          foregroundDecoration: FocusOutline(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            states.contains(WidgetState.focused)
                ? CalendarColors.headerFocus(brightness)
                : Colors.transparent,
            width: 2,
            offset: 1,
          ),
          decoration: BoxDecoration(
            color: hover ? CalendarColors.controlHoverFill : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IslandIcon(
            forward ? IslandGlyph.chevronRight : IslandGlyph.chevronLeft,
            size: year ? 14 : 16,
            strokeWidth: 2.6,
            color: hover
                ? CalendarColors.arrowHover(brightness)
                : CalendarColors.arrow(brightness),
          ),
        );
      },
    );
    final todayAction = ActionSurface(
      onActivate: () => _select(today),
      builder: (_, states) {
        final hover = states.contains(WidgetState.hovered);
        return AnimatedContainer(
          duration: duration,
          curve: _curve,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          foregroundDecoration: FocusOutline(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            states.contains(WidgetState.focused)
                ? CalendarColors.headerFocus(brightness)
                : Colors.transparent,
            width: 2,
            offset: 1,
          ),
          decoration: BoxDecoration(
            color: hover ? CalendarColors.controlHoverFill : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedDefaultTextStyle(
            duration: duration,
            curve: _curve,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: hover
                  ? CalendarColors.todayActionHover(brightness)
                  : CalendarColors.todayAction(brightness),
            ),
            child: Text(strings.today),
          ),
        );
      },
    );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            arrow(strings.previousYear, false, true),
            const SizedBox(width: 2),
            arrow(strings.previousMonth, false, false),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: CalendarColors.monthChipFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IslandIcon(
                IslandGlyph.calendar,
                size: 16,
                strokeWidth: 2.4,
                color: CalendarColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                strings.monthTitle(month.year, month.month),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
                  color: CalendarColors.monthChipInk,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            todayAction,
            const SizedBox(width: 4),
            arrow(strings.nextMonth, true, false),
            const SizedBox(width: 2),
            arrow(strings.nextYear, true, true),
          ],
        ),
      ],
    );
  }

  Widget _grid({
    required DateTime grid,
    required DateTime month,
    required DateTime today,
    required int? selectedIndex,
    required _Layout layout,
    required List<List<IslandCalendarEvent>> covering,
    required double scale,
    required Duration duration,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: _baseHeader * scale,
        child: Row(
          children: [
            for (final name in IslandLocalizations.of(
              context,
            ).weekdaysFromSunday)
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.48,
                      color: IslandTokens.light.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      for (var week = 0; week < _cells ~/ _cols; week++)
        SizedBox(
          height: _baseCell * scale,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var column = 0; column < _cols; column++)
                Expanded(
                  child: _cell(
                    index: week * _cols + column,
                    date: _cellDate(grid, week * _cols + column),
                    outside:
                        _cellDate(grid, week * _cols + column).month !=
                        month.month,
                    today: today,
                    selected: selectedIndex == week * _cols + column,
                    extra: layout.overflow[week * _cols + column],
                    covering: covering[week * _cols + column],
                    scale: scale,
                    duration: duration,
                  ),
                ),
            ],
          ),
        ),
    ],
  );

  Widget _cell({
    required int index,
    required DateTime date,
    required bool outside,
    required DateTime today,
    required bool selected,
    required int extra,
    required List<IslandCalendarEvent> covering,
    required double scale,
    required Duration duration,
  }) {
    final isToday = date == today;
    return ActionSurface(
      focusNode: _nodes[index],
      label: _cellLabel(date, covering),
      selected: selected,
      mouseCursor: widget.onCreateEvent == null
          ? null
          : SystemMouseCursors.precise,
      onActivate: () => _select(date),
      builder: (_, states) {
        final hover = states.contains(WidgetState.hovered);
        final ink = selected
            ? IslandTokens.light.onLeaf
            : isToday
            ? IslandTokens.light.link
            : outside
            ? IslandTokens.light.muted
            : hover
            ? CalendarColors.dayHover
            : CalendarColors.day;
        final weight = selected || isToday
            ? FontWeight.w700
            : outside
            ? FontWeight.w400
            : hover
            ? FontWeight.w700
            : FontWeight.w500;
        final number = _baseNumber * scale;
        return AnimatedContainer(
          duration: duration,
          curve: _curve,
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          foregroundDecoration: FocusOutline(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            states.contains(WidgetState.focused)
                ? IslandTokens.light.focus
                : Colors.transparent,
            width: 2,
            offset: -2,
          ),
          decoration: BoxDecoration(
            color: selected
                ? CalendarColors.accentTint
                : hover
                ? CalendarColors.cellHoverFill
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: _curve,
                    width: number,
                    height: number,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? CalendarColors.accent : null,
                      border: isToday && !selected
                          ? Border.all(
                              color: IslandTokens.light.link,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      curve: _curve,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1,
                        fontWeight: weight,
                        color: ink,
                      ),
                      child: Text('${date.day}', softWrap: false),
                    ),
                  ),
                ),
                if (extra > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 2, bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: CalendarColors.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$extra',
                      textAlign: TextAlign.center,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: IslandTokens.light.link,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bar(_Segment segment, double columnWidth, double scale) {
    final event = segment.event;
    final column = segment.index % _cols;
    final span = segment.endIndex - segment.index + 1;
    final week = segment.index ~/ _cols;
    final colors = switch (event?.color ?? IslandCalendarColor.teal) {
      IslandCalendarColor.teal => CalendarColors.teal,
      IslandCalendarColor.amber => CalendarColors.amber,
      IslandCalendarColor.coral => CalendarColors.coral,
      IslandCalendarColor.green => CalendarColors.green,
      IslandCalendarColor.purple => CalendarColors.purple,
    };
    final radius = BorderRadius.circular(span > 1 ? 6 : 10);
    final height = _baseBar * scale;
    final centre =
        (_baseHeader +
            week * _baseCell +
            _baseNumberBand +
            (segment.row + 1) * _baseEventRow) *
        scale;
    final time =
        event != null &&
        segment.first &&
        widget.showEventTime &&
        event.showTime;
    return Positioned(
      key: ValueKey((event?.id, event == null, segment.index)),
      left: columnWidth * column + 5 + (span > 1 && column != 0 ? 1 : 0),
      top: centre - height / 2,
      width: math.max(0, columnWidth * span - 10),
      height: height,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: CustomPaint(
            foregroundPainter: event == null
                ? IslandDashedBorderPainter(
                    shape: RoundedRectangleBorder(borderRadius: radius),
                    color: colors.border,
                    dash: 3,
                    gap: 3,
                  )
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: colors.fill,
                border: Border.all(
                  color: event == null ? Colors.transparent : colors.border,
                ),
                borderRadius: radius,
              ),
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                maxWidth: double.infinity,
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: _baseEventFont * scale,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (time) ...[
                        Text(
                          formatDateTokens(event.start, 'HH:mm'),
                          softWrap: false,
                          style: const TextStyle(
                            color: CalendarColors.eventTime,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (event != null) Text(event.title, softWrap: false),
                    ],
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
