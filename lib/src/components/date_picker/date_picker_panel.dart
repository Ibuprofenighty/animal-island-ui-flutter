import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/models/date.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import 'calendar_model.dart';

/// The shared calendar surface used by inline and popover date pickers.
class AnimalDatePickerPanel extends StatefulWidget {
  final AnimalDateSelection? selection;
  final AnimalDatePickerMode mode;
  final ValueChanged<AnimalDateSelection?>? onChanged;
  final AnimalDate? firstDate;
  final AnimalDate? lastDate;
  final bool Function(AnimalDate date)? disabledDate;
  final bool showToday;
  final bool allowClear;
  final bool disabled;
  final FocusNode? focusNode;
  final AnimalClock clock;

  AnimalDatePickerPanel({
    super.key,
    this.selection,
    this.mode = AnimalDatePickerMode.date,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.disabledDate,
    this.showToday = true,
    this.allowClear = true,
    this.disabled = false,
    this.focusNode,
    this.clock = const SystemClock(),
  }) {
    CalendarModel.validateInputs(
      mode: mode,
      selection: selection,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  @override
  State<AnimalDatePickerPanel> createState() => _AnimalDatePickerPanelState();
}

class _AnimalDatePickerPanelState extends State<AnimalDatePickerPanel> {
  static const int _monthColumnCount = 3;
  static const double _monthBorderWidth = 1.0;

  late int _viewYear;
  late int _viewMonth;
  AnimalDate? _focusedDate;
  int? _focusedMonth;
  AnimalDate? _lastNullSelectionToday;
  FocusNode? _internalRootFocusNode;
  final ScrollController _horizontalScrollController = ScrollController();
  final Map<AnimalDate, FocusNode> _dateFocusNodes = <AnimalDate, FocusNode>{};
  final Map<int, FocusNode> _monthFocusNodes = <int, FocusNode>{};

  FocusNode get _rootFocusNode =>
      widget.focusNode ?? (_internalRootFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _syncViewFromSelection();
  }

  @override
  void didUpdateWidget(covariant AnimalDatePickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    CalendarModel.validateInputs(
      mode: widget.mode,
      selection: widget.selection,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    final todayChangedWithoutSelection =
        oldWidget.selection == null &&
        widget.selection == null &&
        _lastNullSelectionToday != AnimalDate.today(clock: widget.clock);
    if (oldWidget.selection != widget.selection ||
        oldWidget.mode != widget.mode ||
        oldWidget.clock != widget.clock ||
        todayChangedWithoutSelection) {
      _syncViewFromSelection();
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _internalRootFocusNode?.dispose();
    for (final node in _dateFocusNodes.values) {
      node.dispose();
    }
    for (final node in _monthFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncViewFromSelection() {
    final today = AnimalDate.today(clock: widget.clock);
    final anchor = switch (widget.selection) {
      AnimalDateSingleSelection(:final date) => date,
      AnimalDateRangeSelection(:final start) => start,
      null => today,
    };
    _lastNullSelectionToday = widget.selection == null ? today : null;
    _viewYear = anchor.year;
    _viewMonth = anchor.month;
    _focusedDate = anchor;
    _focusedMonth = anchor.month;
  }

  bool _isDateDisabled(AnimalDate date) => CalendarModel.isDateDisabled(
    date: date,
    firstDate: widget.firstDate,
    lastDate: widget.lastDate,
    disabledDate: widget.disabledDate,
  );

  bool _isMonthDisabled(int year, int month) => CalendarModel.isMonthDisabled(
    year: year,
    month: month,
    firstDate: widget.firstDate,
    lastDate: widget.lastDate,
    disabledDate: widget.disabledDate,
  );

  (int, int)? _monthAfter(int year, int month, int delta) {
    final index = year * 12 + month - 1 + delta;
    final targetYear = index ~/ 12;
    final targetMonth = index % 12 + 1;
    if (targetYear < AnimalDate.minimumYear ||
        targetYear > AnimalDate.maximumYear) {
      return null;
    }
    return (targetYear, targetMonth);
  }

  bool _canNavigateByMonths(int delta) {
    final target = _monthAfter(_viewYear, _viewMonth, delta);
    return target != null &&
        CalendarModel.canNavigateToMonth(
          year: target.$1,
          month: target.$2,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        );
  }

  void _changeViewByMonths(int delta) {
    if (!_canNavigateByMonths(delta)) return;
    final target = _monthAfter(_viewYear, _viewMonth, delta)!;
    setState(() {
      _viewYear = target.$1;
      _viewMonth = target.$2;
      final anchor = _focusedDate;
      if (widget.mode != AnimalDatePickerMode.month && anchor != null) {
        final day = anchor.day
            .clamp(1, AnimalDate.daysInMonth(target.$1, target.$2))
            .toInt();
        _focusedDate = AnimalDate(target.$1, target.$2, day);
      }
    });
  }

  void _prevYear() {
    if (widget.disabled) return;
    _changeViewByYears(-1);
  }

  void _nextYear() {
    if (widget.disabled) return;
    _changeViewByYears(1);
  }

  bool _canNavigateByYears(int delta) {
    final targetYear = _viewYear + delta;
    if (targetYear < AnimalDate.minimumYear ||
        targetYear > AnimalDate.maximumYear) {
      return false;
    }
    if (widget.mode != AnimalDatePickerMode.month) {
      return _canNavigateByMonths(delta * 12);
    }
    return _nearestEnabledMonth(targetYear, _focusedMonth ?? _viewMonth) !=
        null;
  }

  void _changeViewByYears(int delta) {
    if (!_canNavigateByYears(delta)) return;
    if (widget.mode != AnimalDatePickerMode.month) {
      _changeViewByMonths(delta * 12);
      return;
    }

    final targetYear = _viewYear + delta;
    final targetMonth = _nearestEnabledMonth(
      targetYear,
      _focusedMonth ?? _viewMonth,
    );
    if (targetMonth == null) return;
    setState(() {
      _viewYear = targetYear;
      _viewMonth = targetMonth;
    });
    _focusMonth(targetMonth);
  }

  void _prevMonth() {
    if (widget.disabled) return;
    _changeViewByMonths(-1);
  }

  void _nextMonth() {
    if (widget.disabled) return;
    _changeViewByMonths(1);
  }

  bool get _canPreviousYear => _canNavigateByYears(-1);
  bool get _canNextYear => _canNavigateByYears(1);
  bool get _canPreviousMonth => _canNavigateByMonths(-1);
  bool get _canNextMonth => _canNavigateByMonths(1);

  void _propose(AnimalDateSelection? selection) {
    if (widget.disabled) return;
    if (selection == null && widget.selection == null) return;
    widget.onChanged?.call(selection);
  }

  void _handleDateTap(AnimalDate date) {
    if (widget.disabled || _isDateDisabled(date)) return;
    if (widget.mode == AnimalDatePickerMode.date) {
      _propose(AnimalDateSelection.date(date));
      return;
    }
    if (widget.mode == AnimalDatePickerMode.month) {
      return;
    }

    final currentRange = widget.selection;
    if (currentRange is! AnimalDateRangeSelection || currentRange.end != null) {
      _propose(AnimalDateSelection.range(start: date));
      return;
    }

    final start = currentRange.start.isBefore(date) ? currentRange.start : date;
    final end = currentRange.start.isBefore(date) ? date : currentRange.start;
    if (CalendarModel.isRangeDisabled(
      start: start,
      end: end,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      disabledDate: widget.disabledDate,
    )) {
      return;
    }
    _propose(AnimalDateSelection.range(start: start, end: end));
  }

  void _handleMonthTap(int month) {
    if (widget.disabled) return;
    if (_isMonthDisabled(_viewYear, month)) return;
    _propose(AnimalDateSelection.date(AnimalDate(_viewYear, month, 1)));
  }

  AnimalDateSelection? _todaySelection(AnimalDate today) =>
      switch (widget.mode) {
        AnimalDatePickerMode.date => AnimalDateSelection.date(today),
        AnimalDatePickerMode.range => AnimalDateSelection.range(start: today),
        AnimalDatePickerMode.month => AnimalDateSelection.date(
          AnimalDate(today.year, today.month, 1),
        ),
      };

  AnimalDate _todayTarget(AnimalDate today) =>
      widget.mode == AnimalDatePickerMode.month
      ? AnimalDate(today.year, today.month, 1)
      : today;

  void _handleToday() {
    if (widget.disabled) return;
    final today = AnimalDate.today(clock: widget.clock);
    final target = _todayTarget(today);
    if (_isDateDisabled(target)) return;
    setState(() {
      _viewYear = target.year;
      _viewMonth = target.month;
    });
    _propose(_todaySelection(today));
  }

  void _handleClear() {
    if (widget.disabled || widget.selection == null) return;
    _propose(null);
  }

  AnimalDate _keyboardAnchor() =>
      _focusedDate ??
      switch (widget.selection) {
        AnimalDateSingleSelection(:final date) => date,
        AnimalDateRangeSelection(:final start) => start,
        null => AnimalDate.today(clock: widget.clock),
      };

  AnimalDate? _shiftMonth(AnimalDate date, int delta) {
    final target = _monthAfter(date.year, date.month, delta);
    if (target == null) return null;
    final day = date.day
        .clamp(1, AnimalDate.daysInMonth(target.$1, target.$2))
        .toInt();
    return AnimalDate(target.$1, target.$2, day);
  }

  AnimalDate? _findEnabledDate(AnimalDate target, int direction) {
    final targetMonth = CalendarModel.buildMonthGrid(
      year: target.year,
      month: target.month,
      today: AnimalDate.today(clock: widget.clock),
      mode: widget.mode,
      selection: widget.selection,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      disabledDate: widget.disabledDate,
    ).map((cell) => cell.date).whereType<AnimalDate>().toList(growable: false);
    final targetIndex = targetMonth.indexOf(target);
    if (targetIndex < 0) return null;

    if (direction > 0) {
      for (var index = targetIndex; index < targetMonth.length; index++) {
        final candidate = targetMonth[index];
        if (!_isDateDisabled(candidate)) return candidate;
      }
    } else {
      for (var index = targetIndex; index >= 0; index--) {
        final candidate = targetMonth[index];
        if (!_isDateDisabled(candidate)) return candidate;
      }
    }
    return null;
  }

  AnimalDate? _dateKeyTarget(AnimalDate current, LogicalKeyboardKey key) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      final left = key == LogicalKeyboardKey.arrowLeft;
      final delta = left == rtl ? 1 : -1;
      try {
        final raw = current.addDays(delta);
        return _findEnabledDate(raw, delta);
      } on RangeError {
        return null;
      }
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      final delta = key == LogicalKeyboardKey.arrowUp ? -7 : 7;
      try {
        final raw = current.addDays(delta);
        return _findEnabledDate(raw, delta);
      } on RangeError {
        return null;
      }
    }
    if (key == LogicalKeyboardKey.home || key == LogicalKeyboardKey.end) {
      final startOfWeek = current.weekday % 7;
      try {
        final raw = key == LogicalKeyboardKey.home
            ? current.subtractDays(startOfWeek)
            : current.addDays(6 - startOfWeek);
        return _findEnabledDate(raw, key == LogicalKeyboardKey.home ? 1 : -1);
      } on RangeError {
        final boundary = key == LogicalKeyboardKey.home
            ? AnimalDate(AnimalDate.minimumYear, 1, 1)
            : AnimalDate(AnimalDate.maximumYear, 12, 31);
        return _findEnabledDate(
          boundary,
          key == LogicalKeyboardKey.home ? 1 : -1,
        );
      }
    }
    if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown) {
      final direction = key == LogicalKeyboardKey.pageUp ? -1 : 1;
      final monthDelta = HardwareKeyboard.instance.isShiftPressed
          ? direction * 12
          : direction;
      final raw = _shiftMonth(current, monthDelta);
      if (raw == null) return null;
      return _findEnabledDate(raw, direction);
    }
    return null;
  }

  int? _monthKeyTarget(int current, LogicalKeyboardKey key) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    if (key == LogicalKeyboardKey.home) {
      return _nearestEnabledMonth(_viewYear, 1);
    }
    if (key == LogicalKeyboardKey.end) {
      return _nearestEnabledMonth(_viewYear, 12);
    }
    if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown) {
      final yearDelta = key == LogicalKeyboardKey.pageUp ? -1 : 1;
      final targetYear = _viewYear + yearDelta;
      if (targetYear < AnimalDate.minimumYear ||
          targetYear > AnimalDate.maximumYear) {
        return null;
      }
      final targetMonth = _nearestEnabledMonth(targetYear, current);
      if (targetMonth == null) return null;
      setState(() => _viewYear = targetYear);
      return targetMonth;
    }

    final delta = switch (key) {
      LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowUp => -_monthColumnCount,
      LogicalKeyboardKey.arrowDown => _monthColumnCount,
      _ => 0,
    };
    if (delta == 0) return null;
    var month = current + delta;
    for (var attempt = 0; attempt < 12; attempt++) {
      if (month < 1 || month > 12) return null;
      if (!_isMonthDisabled(_viewYear, month)) return month;
      month += delta < 0 ? -1 : 1;
    }
    return null;
  }

  int? _nearestEnabledMonth(int year, int preferredMonth) {
    for (var distance = 0; distance < 12; distance++) {
      final earlier = preferredMonth - distance;
      if (earlier >= 1 && !_isMonthDisabled(year, earlier)) return earlier;
      if (distance == 0) continue;
      final later = preferredMonth + distance;
      if (later <= 12 && !_isMonthDisabled(year, later)) return later;
    }
    return null;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.disabled ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    if (!_isNavigationKey(event.logicalKey)) return KeyEventResult.ignored;

    if (widget.mode == AnimalDatePickerMode.month) {
      final current = _focusedMonth ?? _viewMonth;
      final target = _monthKeyTarget(current, event.logicalKey);
      if (target != null) _focusMonth(target);
      return KeyEventResult.handled;
    }

    final current = _keyboardAnchor();
    final target = _dateKeyTarget(current, event.logicalKey);
    if (target != null) _focusDate(target);
    return KeyEventResult.handled;
  }

  bool _isNavigationKey(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.arrowRight ||
      key == LogicalKeyboardKey.arrowUp ||
      key == LogicalKeyboardKey.arrowDown ||
      key == LogicalKeyboardKey.home ||
      key == LogicalKeyboardKey.end ||
      key == LogicalKeyboardKey.pageUp ||
      key == LogicalKeyboardKey.pageDown;

  void _focusDate(AnimalDate date) {
    if (!mounted || widget.disabled) return;
    setState(() {
      _focusedDate = date;
      _viewYear = date.year;
      _viewMonth = date.month;
    });
    _scheduleDateFocusReveal(date, requestFocus: true);
  }

  void _focusMonth(int month) {
    if (!mounted || widget.disabled) return;
    setState(() => _focusedMonth = month);
    _scheduleMonthFocusReveal(month, requestFocus: true);
  }

  void _rememberDateFocus(AnimalDate date, bool focused) {
    if (!focused || !mounted) return;
    if (date != _focusedDate) setState(() => _focusedDate = date);
    _scheduleDateFocusReveal(date);
  }

  void _rememberMonthFocus(int month, bool focused) {
    if (!focused || !mounted) return;
    if (month != _focusedMonth) setState(() => _focusedMonth = month);
    _scheduleMonthFocusReveal(month);
  }

  void _scheduleDateFocusReveal(AnimalDate date, {bool requestFocus = false}) {
    final expectedViewYear = _viewYear;
    final expectedViewMonth = _viewMonth;
    _scheduleFocusReveal(
      resolveFocusNode: () => _dateFocusNodes[date],
      requestFocus: requestFocus,
      isCurrentTarget: (node) =>
          widget.mode != AnimalDatePickerMode.month &&
          _focusedDate == date &&
          _viewYear == expectedViewYear &&
          _viewMonth == expectedViewMonth &&
          identical(_dateFocusNodes[date], node),
    );
  }

  void _scheduleMonthFocusReveal(int month, {bool requestFocus = false}) {
    final expectedViewYear = _viewYear;
    final expectedViewMonth = _viewMonth;
    _scheduleFocusReveal(
      resolveFocusNode: () => _monthFocusNodes[month],
      requestFocus: requestFocus,
      isCurrentTarget: (node) =>
          widget.mode == AnimalDatePickerMode.month &&
          _focusedMonth == month &&
          _viewYear == expectedViewYear &&
          _viewMonth == expectedViewMonth &&
          identical(_monthFocusNodes[month], node),
    );
  }

  void _scheduleFocusReveal({
    required FocusNode? Function() resolveFocusNode,
    required bool Function(FocusNode node) isCurrentTarget,
    bool requestFocus = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.disabled) return;
      final focusNode = resolveFocusNode();
      if (focusNode == null || !isCurrentTarget(focusNode)) return;
      var targetContext = focusNode.context;
      if (targetContext == null || !targetContext.mounted) return;
      if (requestFocus) focusNode.requestFocus();
      if (!mounted ||
          widget.disabled ||
          !isCurrentTarget(focusNode) ||
          !focusNode.hasFocus) {
        return;
      }
      targetContext = focusNode.context;
      if (targetContext == null || !targetContext.mounted) return;
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.5,
        duration: Duration.zero,
      );
    });
  }

  void _scheduleDateFocusPrune(Set<AnimalDate> visibleDates) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final staleDates = _dateFocusNodes.keys
          .where((date) => !visibleDates.contains(date))
          .toList(growable: false);
      for (final date in staleDates) {
        _dateFocusNodes.remove(date)?.dispose();
      }
    });
  }

  void _scheduleMonthFocusPrune(Set<int> visibleMonths) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final staleMonths = _monthFocusNodes.keys
          .where((month) => !visibleMonths.contains(month))
          .toList(growable: false);
      for (final month in staleMonths) {
        _monthFocusNodes.remove(month)?.dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final borderColor = theme.colors.brightness == Brightness.dark
        ? theme.colors.border
        : theme.colors.borderLight;
    final today = AnimalDate.today(clock: widget.clock);
    final todayTarget = _todayTarget(today);
    final todayDisabled = widget.disabled || _isDateDisabled(todayTarget);
    final clearDisabled = widget.disabled || widget.selection == null;

    return Focus(
      focusNode: _rootFocusNode,
      canRequestFocus: !widget.disabled,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        width: 300.0,
        padding: EdgeInsets.all(theme.spacing.md),
        decoration: BoxDecoration(
          color: theme.colors.bgContent,
          borderRadius: theme.radii.cardBorder,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme, localizations, materialLocalizations),
            SizedBox(height: theme.spacing.sm),
            if (widget.mode == AnimalDatePickerMode.month)
              _buildMonthGrid(theme, materialLocalizations)
            else
              _buildDateGrid(theme, today, materialLocalizations),
            if (widget.showToday || widget.allowClear) ...[
              SizedBox(height: theme.spacing.sm),
              Divider(height: 1, color: borderColor),
              SizedBox(height: theme.spacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showToday)
                    InteractiveRegion(
                      onPressed: _handleToday,
                      enableHaptics: false,
                      disabled: todayDisabled,
                      semanticLabel: localizations.today,
                      surfaceColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing.sm,
                      ),
                      child: Text(
                        localizations.today,
                        style: theme.typography.caption.copyWith(
                          color: todayDisabled
                              ? theme.colors.textDisabled
                              : theme.colors.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (widget.allowClear)
                    InteractiveRegion(
                      onPressed: _handleClear,
                      enableHaptics: false,
                      disabled: clearDisabled,
                      semanticLabel: localizations.clearDate,
                      surfaceColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing.sm,
                      ),
                      child: Text(
                        localizations.clear,
                        style: theme.typography.caption.copyWith(
                          color: clearDisabled
                              ? theme.colors.textDisabled
                              : theme.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    AnimalIslandTheme theme,
    AnimalLocalizations localizations,
    MaterialLocalizations materialLocalizations,
  ) {
    final isMonthMode = widget.mode == AnimalDatePickerMode.month;
    final canPrevYear = !widget.disabled && _canPreviousYear;
    final canPrevMonth = !widget.disabled && _canPreviousMonth;
    final canNextMonth = !widget.disabled && _canNextMonth;
    final canNextYear = !widget.disabled && _canNextYear;
    final headerLabel = isMonthMode
        ? materialLocalizations.formatYear(
            AnimalDate(_viewYear, 1, 1).toDateTime(),
          )
        : materialLocalizations.formatMonthYear(
            AnimalDate(_viewYear, _viewMonth, 1).toDateTime(),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InteractiveRegion(
              onPressed: _prevYear,
              enableHaptics: false,
              disabled: !canPrevYear,
              semanticLabel: localizations.datePickerPreviousYear,
              surfaceColor: Colors.transparent,
              child: Icon(
                Icons.keyboard_double_arrow_left_rounded,
                size: 18,
                color: canPrevYear
                    ? theme.colors.text
                    : theme.colors.textDisabled,
              ),
            ),
            if (!isMonthMode)
              InteractiveRegion(
                onPressed: _prevMonth,
                enableHaptics: false,
                disabled: !canPrevMonth,
                semanticLabel: materialLocalizations.previousMonthTooltip,
                surfaceColor: Colors.transparent,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: canPrevMonth
                      ? theme.colors.text
                      : theme.colors.textDisabled,
                ),
              ),
          ],
        ),
        Flexible(
          child: Text(
            headerLabel,
            textAlign: TextAlign.center,
            style: theme.typography.heading.copyWith(
              fontSize: 15.0,
              color: widget.disabled
                  ? theme.colors.textDisabled
                  : theme.colors.text,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMonthMode)
              InteractiveRegion(
                onPressed: _nextMonth,
                enableHaptics: false,
                disabled: !canNextMonth,
                semanticLabel: materialLocalizations.nextMonthTooltip,
                surfaceColor: Colors.transparent,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: canNextMonth
                      ? theme.colors.text
                      : theme.colors.textDisabled,
                ),
              ),
            InteractiveRegion(
              onPressed: _nextYear,
              enableHaptics: false,
              disabled: !canNextYear,
              semanticLabel: localizations.datePickerNextYear,
              surfaceColor: Colors.transparent,
              child: Icon(
                Icons.keyboard_double_arrow_right_rounded,
                size: 18,
                color: canNextYear
                    ? theme.colors.text
                    : theme.colors.textDisabled,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthGrid(
    AnimalIslandTheme theme,
    MaterialLocalizations materialLocalizations,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final months = List<String>.generate(
      12,
      (index) =>
          intl.DateFormat.MMM(locale).format(DateTime.utc(2020, index + 1)),
      growable: false,
    );
    final selected = widget.selection;
    final selectedDate = selected is AnimalDateSingleSelection
        ? selected.date
        : null;
    final visibleMonths = <int>{
      ...List<int>.generate(12, (index) => index + 1),
    };
    _scheduleMonthFocusPrune(visibleMonths);

    final monthSpacing = theme.spacing.xs;
    final monthStyle = theme.typography.body.copyWith(
      fontSize: 13.0,
      fontWeight: FontWeight.w700,
    );
    final monthMetrics = _measureTextMetrics(months, monthStyle);
    final monthItemWidth = _atLeast(86.0, monthMetrics.width + 12.0);
    final monthItemHeight = _atLeast(
      48.0,
      monthMetrics.height + 2 * _monthBorderWidth,
    );
    final monthGridWidth =
        monthItemWidth * _monthColumnCount +
        monthSpacing * (_monthColumnCount - 1);
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: monthGridWidth,
          child: Wrap(
            spacing: monthSpacing,
            runSpacing: monthSpacing,
            children: List<Widget>.generate(12, (index) {
              final month = index + 1;
              final isMonthDisabled =
                  widget.disabled || _isMonthDisabled(_viewYear, month);
              final isSelected =
                  selectedDate != null &&
                  selectedDate.year == _viewYear &&
                  selectedDate.month == month;
              final focusNode = _monthFocusNodes.putIfAbsent(
                month,
                FocusNode.new,
              );
              return SizedBox(
                width: monthItemWidth,
                height: monthItemHeight,
                child: InteractiveRegion(
                  key: ValueKey<String>('month-$_viewYear-$month'),
                  onPressed: () => _handleMonthTap(month),
                  enableHaptics: false,
                  disabled: isMonthDisabled,
                  focusNode: focusNode,
                  onFocusChanged: (focused) =>
                      _rememberMonthFocus(month, focused),
                  semanticLabel: materialLocalizations.formatMonthYear(
                    DateTime.utc(_viewYear, month),
                  ),
                  selected: isSelected,
                  surfaceColor: Colors.transparent,
                  borderRadius: theme.radii.pillBorder,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colors.primary
                          : Colors.transparent,
                      borderRadius: theme.radii.pillBorder,
                      border: Border.all(
                        width: _monthBorderWidth,
                        color: isSelected
                            ? theme.colors.primaryActive
                            : theme.colors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: theme.typography.body.copyWith(
                        fontSize: 13.0,
                        color: isMonthDisabled
                            ? theme.colors.textDisabled
                            : (isSelected
                                  ? theme.colors.onPrimary
                                  : theme.colors.text),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }, growable: false),
          ),
        ),
      ),
    );
  }

  Widget _buildDateGrid(
    AnimalIslandTheme theme,
    AnimalDate today,
    MaterialLocalizations materialLocalizations,
  ) {
    final cells = CalendarModel.buildMonthGrid(
      year: _viewYear,
      month: _viewMonth,
      today: today,
      mode: widget.mode,
      selection: widget.selection,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      disabledDate: widget.disabledDate,
    );
    final visibleDates = cells
        .map((cell) => cell.date)
        .whereType<AnimalDate>()
        .toSet();
    _scheduleDateFocusPrune(visibleDates);

    final weekdays = materialLocalizations.narrowWeekdays;
    final weekdayStyle = theme.typography.caption.copyWith(
      fontWeight: FontWeight.w700,
    );
    final dayStyle = theme.typography.body.copyWith(
      fontSize: 13.0,
      fontWeight: FontWeight.w700,
    );
    final weekdayMetrics = _measureTextMetrics(weekdays, weekdayStyle);
    final dayMetrics = _measureTextMetrics(
      List<String>.generate(31, (index) => '${index + 1}', growable: false),
      dayStyle,
    );
    final columnWidth = _atLeast(
      48.0,
      _atLeast(dayMetrics.width + 12.0, weekdayMetrics.width),
    );
    final dayCellHeight = _atLeast(48.0, dayMetrics.height + 12.0);
    final weekdayRowHeight = _atLeast(24.0, weekdayMetrics.height);

    Widget buildDateCell(CalendarDayCell cell) {
      final date = cell.date;
      if (date == null) {
        return SizedBox(width: columnWidth, height: dayCellHeight);
      }

      final disabled = widget.disabled || cell.isDisabled;
      final isSelected =
          cell.isSelected || cell.isRangeStart || cell.isRangeEnd;
      final isRangeMode = widget.mode == AnimalDatePickerMode.range;
      final background = isSelected
          ? (isRangeMode ? theme.colors.warning : theme.colors.primary)
          : (cell.isInRange
                ? theme.colors.warning.withValues(alpha: 0.18)
                : Colors.transparent);
      final textColor = disabled
          ? theme.colors.textDisabled
          : isSelected
          ? (isRangeMode ? theme.colors.onWarning : theme.colors.onPrimary)
          : (!cell.isCurrentMonth
                ? theme.colors.textSecondary
                : theme.colors.text);
      final focusNode = _dateFocusNodes.putIfAbsent(date, FocusNode.new);

      return SizedBox(
        width: columnWidth,
        height: dayCellHeight,
        child: InteractiveRegion(
          key: ValueKey<String>('date-${date.toIso8601String()}'),
          onPressed: () => _handleDateTap(date),
          enableHaptics: false,
          disabled: disabled,
          selected: isSelected,
          focusNode: focusNode,
          onFocusChanged: (focused) => _rememberDateFocus(date, focused),
          semanticLabel: materialLocalizations.formatFullDate(
            date.toDateTime(),
          ),
          surfaceColor: Colors.transparent,
          minimumHitSize: 48,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              decoration: BoxDecoration(
                color: background,
                shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: cell.isInRange && !isSelected
                    ? BorderRadius.circular(4)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: theme.typography.body.copyWith(
                  fontSize: 13,
                  fontWeight: isSelected || cell.isToday
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: textColor,
                  decoration: cell.isToday && !isSelected
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                weekdays.length,
                (index) => SizedBox(
                  width: columnWidth,
                  height: weekdayRowHeight,
                  child: Center(
                    child: Text(
                      weekdays[index],
                      textAlign: TextAlign.center,
                      style: theme.typography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                growable: false,
              ),
            ),
            SizedBox(height: theme.spacing.xs),
            for (var week = 0; week < 6; week++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: week == 5 ? 0 : theme.spacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: cells
                      .skip(week * 7)
                      .take(7)
                      .map(buildDateCell)
                      .toList(growable: false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Size _measureTextMetrics(Iterable<String> values, TextStyle style) {
    var maxWidth = 0.0;
    var maxHeight = 0.0;
    final defaults = DefaultTextStyle.of(context);
    final effectiveStyle = defaults.style.merge(style);
    for (final value in values) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: effectiveStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        locale: Localizations.localeOf(context),
        textWidthBasis: defaults.textWidthBasis,
        textHeightBehavior: defaults.textHeightBehavior,
        maxLines: 1,
      )..layout();
      final paragraphCenterX = painter.width / 2;
      final paragraphCenterY = painter.height / 2;
      var measuredWidth = painter.width;
      var measuredHeight = painter.height;
      final boxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: value.length),
      );
      for (final box in boxes) {
        final horizontalExtent =
            (2 *
                    math.max(
                      paragraphCenterX - box.left,
                      box.right - paragraphCenterX,
                    ))
                .toDouble();
        final verticalExtent =
            (2 *
                    math.max(
                      paragraphCenterY - box.top,
                      box.bottom - paragraphCenterY,
                    ))
                .toDouble();
        measuredWidth = math.max(measuredWidth, horizontalExtent).toDouble();
        measuredHeight = math.max(measuredHeight, verticalExtent).toDouble();
      }
      if (measuredWidth > maxWidth) maxWidth = measuredWidth;
      if (measuredHeight > maxHeight) maxHeight = measuredHeight;
      painter.dispose();
    }
    return Size(maxWidth, maxHeight);
  }

  double _atLeast(double minimum, double value) =>
      value > minimum ? value : minimum;
}
