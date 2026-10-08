import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/models/date.dart';
import '../../foundation/theme/components/date_picker_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/field_status.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/interaction/interactive_region.dart';
import 'calendar_model.dart';

/// The shared calendar surface used by inline and popover date pickers.
class AnimalDatePickerPanel extends StatefulWidget {
  /// Current controlled selection, or null when nothing is selected.
  ///
  /// It must be compatible with [mode]; the constructor throws an
  /// [ArgumentError] otherwise.
  final AnimalDateSelection? selection;

  /// Whether the panel picks a single date, a date range, or a month.
  ///
  /// Defaults to [AnimalDatePickerMode.date]. In month mode a selection is the
  /// first day of the chosen month.
  final AnimalDatePickerMode mode;

  /// Called with the proposed selection, or null when the user clears it.
  ///
  /// The panel does not store the value; rebuild with the new [selection].
  /// In range mode the first tap proposes an open range and the second tap
  /// proposes the completed range.
  final ValueChanged<AnimalDateSelection?>? onChanged;

  /// Earliest selectable date, inclusive, or null for no lower bound.
  ///
  /// The constructor throws an [ArgumentError] when it is after [lastDate].
  final AnimalDate? firstDate;

  /// Latest selectable date, inclusive, or null for no upper bound.
  final AnimalDate? lastDate;

  /// Returns true for additional dates that cannot be selected.
  ///
  /// A range that contains a disabled date cannot be completed.
  final bool Function(AnimalDate date)? disabledDate;

  /// Whether the footer shows a button that selects today. Defaults to true.
  final bool showToday;

  /// Whether the footer shows a button that clears the selection. Defaults to
  /// true.
  final bool allowClear;

  /// Whether every control is inert and no change is proposed. Defaults to
  /// false.
  final bool disabled;

  /// Focus node for the calendar's root, or null to use an internal one.
  ///
  /// The caller owns and disposes a supplied node.
  final FocusNode? focusNode;

  /// Source of the current instant used to determine today. Defaults to
  /// [SystemClock].
  final AnimalClock clock;

  /// Visual overrides; see [AnimalDatePickerStyle].
  final AnimalDatePickerStyle? style;

  /// Creates a controlled calendar panel.
  ///
  /// Throws an [ArgumentError] when [firstDate] is after [lastDate] or
  /// [selection] does not match [mode].
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
    this.style,
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

  /// Registered layout floors besides the shared interactive target: the
  /// narrowest month cell and the weekday header row.
  static const double _monthMinimumWidth = 86.0;
  static const double _weekdayMinimumHeight = 24.0;

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
    final resolved = ResolvedDatePickerStyle.resolve(
      theme: theme,
      style: widget.style,
      disabled: widget.disabled,
    );
    final borderColor = resolved.panelBorderColor;
    final today = AnimalDate.today(clock: widget.clock);
    final todayTarget = _todayTarget(today);
    final todayDisabled = widget.disabled || _isDateDisabled(todayTarget);
    final clearDisabled = widget.disabled || widget.selection == null;

    // The preferred width yields to a narrower parent: Container tightens
    // within the incoming constraints.
    return Focus(
      focusNode: _rootFocusNode,
      canRequestFocus: !widget.disabled,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        width: resolved.width,
        padding: resolved.padding,
        decoration: BoxDecoration(
          color: resolved.backgroundColor,
          borderRadius: resolved.borderRadius,
          border: Border.all(color: borderColor, width: resolved.borderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(resolved, localizations, materialLocalizations),
            SizedBox(height: resolved.sectionGap),
            if (widget.mode == AnimalDatePickerMode.month)
              _buildMonthGrid(resolved, materialLocalizations)
            else
              _buildDateGrid(resolved, today, materialLocalizations),
            if (widget.showToday || widget.allowClear) ...[
              SizedBox(height: resolved.sectionGap),
              Divider(height: 1, color: borderColor),
              SizedBox(height: resolved.footerGap),
              // A Wrap keeps both actions on one line when they fit and moves
              // Clear to its own line when large text would overflow.
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (widget.showToday)
                      InteractiveRegion(
                        onPressed: _handleToday,
                        enableHaptics: false,
                        disabled: todayDisabled,
                        semanticLabel: localizations.today,
                        surfaceColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: resolved.actionHorizontalPadding,
                        ),
                        child: Text(
                          localizations.today,
                          style: resolved.todayTextStyle.copyWith(
                            color: resolved.todayTextColor(
                              disabled: todayDisabled,
                            ),
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
                          horizontal: resolved.actionHorizontalPadding,
                        ),
                        child: Text(
                          localizations.clear,
                          style: resolved.clearTextStyle.copyWith(
                            color: resolved.clearTextColor(
                              disabled: clearDisabled,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ResolvedDatePickerStyle resolved,
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

    final List<Widget> startButtons = <Widget>[
      InteractiveRegion(
        onPressed: _prevYear,
        enableHaptics: false,
        disabled: !canPrevYear,
        semanticLabel: localizations.datePickerPreviousYear,
        surfaceColor: Colors.transparent,
        child: Icon(
          Icons.keyboard_double_arrow_left_rounded,
          size: resolved.yearIconSize,
          color: resolved.headerTextColor(enabled: canPrevYear),
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
            size: resolved.navigationIconSize,
            color: resolved.headerTextColor(enabled: canPrevMonth),
          ),
        ),
    ];
    final Widget label = Text(
      headerLabel,
      textAlign: TextAlign.center,
      style: resolved.headerTextStyle.copyWith(
        color: resolved.headerTextColor(enabled: !widget.disabled),
      ),
    );
    final List<Widget> endButtons = <Widget>[
      if (!isMonthMode)
        InteractiveRegion(
          onPressed: _nextMonth,
          enableHaptics: false,
          disabled: !canNextMonth,
          semanticLabel: materialLocalizations.nextMonthTooltip,
          surfaceColor: Colors.transparent,
          child: Icon(
            Icons.chevron_right_rounded,
            size: resolved.navigationIconSize,
            color: resolved.headerTextColor(enabled: canNextMonth),
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
          size: resolved.yearIconSize,
          color: resolved.headerTextColor(enabled: canNextYear),
        ),
      ),
    ];

    // Navigation targets keep 48dp. When the panel is too narrow for them and
    // a 48dp label slot on one line, the label moves above the navigation.
    return _DatePickerHeaderLayout(
      minimumLabelWidth: kAnimalMinimumTarget,
      start: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: startButtons,
      ),
      label: label,
      end: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: endButtons,
      ),
    );
  }

  Widget _buildMonthGrid(
    ResolvedDatePickerStyle resolved,
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

    final monthSpacing = resolved.cellGap;
    final monthBorderWidth = resolved.monthBorderWidth;
    final monthStyle = resolved.cellTextStyle.copyWith(
      fontWeight: FontWeight.w700,
    );
    final monthMetrics = _measureTextMetrics(months, monthStyle);
    final monthItemWidth = _atLeast(
      _monthMinimumWidth,
      monthMetrics.width + 2 * resolved.cellInset,
    );
    final monthItemHeight = _atLeast(
      kAnimalMinimumTarget,
      monthMetrics.height + 2 * monthBorderWidth,
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
                  borderRadius: resolved.monthBorderRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? resolved.selectedBackgroundColor
                          : Colors.transparent,
                      borderRadius: resolved.monthBorderRadius,
                      border: Border.all(
                        width: monthBorderWidth,
                        color: resolved.monthBorderColor(selected: isSelected),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: (isSelected ? monthStyle : resolved.cellTextStyle)
                          .copyWith(
                            color: resolved.cellTextColor(
                              selected: isSelected,
                              disabled: isMonthDisabled,
                            ),
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
    ResolvedDatePickerStyle resolved,
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
    final weekdayStyle = resolved.weekdayTextStyle;
    final dayStyle = resolved.cellTextStyle;
    final emphasizedDayStyle = dayStyle.copyWith(fontWeight: FontWeight.bold);
    final cellInset = resolved.cellInset;
    final weekdayMetrics = _measureTextMetrics(weekdays, weekdayStyle);
    final dayMetrics = _measureTextMetrics(
      List<String>.generate(31, (index) => '${index + 1}', growable: false),
      emphasizedDayStyle,
    );
    final columnWidth = _atLeast(
      kAnimalMinimumTarget,
      _atLeast(dayMetrics.width + 2 * cellInset, weekdayMetrics.width),
    );
    final dayCellHeight = _atLeast(
      kAnimalMinimumTarget,
      dayMetrics.height + 2 * cellInset,
    );
    final weekdayRowHeight = _atLeast(
      _weekdayMinimumHeight,
      weekdayMetrics.height,
    );

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
          ? (isRangeMode
                ? resolved.rangeBackgroundColor
                : resolved.selectedBackgroundColor)
          : (cell.isInRange ? resolved.rangeFillColor : Colors.transparent);
      final textColor = resolved.cellTextColor(
        selected: isSelected,
        disabled: disabled,
        rangeEndpoint: isRangeMode,
        outsideMonth: !cell.isCurrentMonth,
      );
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
          child: Padding(
            padding: EdgeInsets.all(cellInset),
            child: Container(
              decoration: BoxDecoration(
                color: background,
                shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: cell.isInRange && !isSelected
                    ? resolved.rangeBorderRadius
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style:
                    (isSelected || cell.isToday ? emphasizedDayStyle : dayStyle)
                        .copyWith(
                          color: textColor,
                          // Today keeps an underline so it is not color-only.
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
                      style: weekdayStyle,
                    ),
                  ),
                ),
                growable: false,
              ),
            ),
            SizedBox(height: resolved.cellGap),
            for (var week = 0; week < 6; week++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: week == 5 ? 0 : resolved.cellGap,
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

/// Header layout: navigation at both ends with the label between them, like a
/// space-between row, while the navigation and a [minimumLabelWidth] label
/// slot fit on one line; otherwise the label sits above centered navigation.
///
/// Unlike a `LayoutBuilder`, it reports intrinsic sizes, which the popover
/// menu queries.
class _DatePickerHeaderLayout extends MultiChildRenderObjectWidget {
  _DatePickerHeaderLayout({
    required this.minimumLabelWidth,
    required Widget start,
    required Widget label,
    required Widget end,
  }) : super(children: <Widget>[start, label, end]);

  final double minimumLabelWidth;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderDatePickerHeader(minimumLabelWidth, Directionality.of(context));

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderDatePickerHeader renderObject,
  ) {
    renderObject
      ..minimumLabelWidth = minimumLabelWidth
      ..textDirection = Directionality.of(context);
  }
}

class _DatePickerHeaderParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderDatePickerHeader extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _DatePickerHeaderParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _DatePickerHeaderParentData
        > {
  _RenderDatePickerHeader(this._minimumLabelWidth, this._textDirection);

  double _minimumLabelWidth;
  set minimumLabelWidth(double value) {
    if (value == _minimumLabelWidth) return;
    _minimumLabelWidth = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox get _start => firstChild!;
  RenderBox get _label => childAfter(_start)!;
  RenderBox get _end => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _DatePickerHeaderParentData) {
      child.parentData = _DatePickerHeaderParentData();
    }
  }

  bool _fitsOneLine(double width, double startWidth, double endWidth) =>
      startWidth + endWidth + _minimumLabelWidth <= width;

  @override
  double computeMinIntrinsicWidth(double height) => math.max(
    _label.getMinIntrinsicWidth(height),
    math.max(
      _start.getMinIntrinsicWidth(height),
      _end.getMinIntrinsicWidth(height),
    ),
  );

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _start.getMaxIntrinsicWidth(height) +
      _label.getMaxIntrinsicWidth(height) +
      _end.getMaxIntrinsicWidth(height);

  double _intrinsicHeight(double width) {
    final double startWidth = math.min(
      width,
      _start.getMaxIntrinsicWidth(double.infinity),
    );
    final double endWidth = math.min(
      width,
      _end.getMaxIntrinsicWidth(double.infinity),
    );
    if (!width.isFinite || _fitsOneLine(width, startWidth, endWidth)) {
      return math.max(
        _label.getMaxIntrinsicHeight(
          width.isFinite ? width - startWidth - endWidth : double.infinity,
        ),
        math.max(
          _start.getMaxIntrinsicHeight(startWidth),
          _end.getMaxIntrinsicHeight(endWidth),
        ),
      );
    }
    final double navigation = startWidth + endWidth <= width
        ? math.max(
            _start.getMaxIntrinsicHeight(startWidth),
            _end.getMaxIntrinsicHeight(endWidth),
          )
        : _start.getMaxIntrinsicHeight(width) +
              _end.getMaxIntrinsicHeight(width);
    return _label.getMaxIntrinsicHeight(width) + navigation;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      _layout(constraints, ChildLayoutHelper.dryLayoutChild, position: false);

  @override
  void performLayout() {
    size = _layout(constraints, ChildLayoutHelper.layoutChild, position: true);
  }

  Size _layout(
    BoxConstraints constraints,
    ChildLayouter layoutChild, {
    required bool position,
  }) {
    final BoxConstraints loose = BoxConstraints(maxWidth: constraints.maxWidth);
    final Size start = layoutChild(_start, loose);
    final Size end = layoutChild(_end, loose);
    final bool rtl = _textDirection == TextDirection.rtl;
    void place(RenderBox child, double x, double y) {
      if (!position) return;
      (child.parentData! as _DatePickerHeaderParentData).offset = Offset(x, y);
    }

    final bool bounded = constraints.hasBoundedWidth;
    if (!bounded ||
        _fitsOneLine(constraints.maxWidth, start.width, end.width)) {
      final Size label = layoutChild(
        _label,
        BoxConstraints(
          maxWidth: bounded
              ? constraints.maxWidth - start.width - end.width
              : double.infinity,
        ),
      );
      final double width = bounded
          ? constraints.maxWidth
          : start.width + label.width + end.width;
      final double height = math.max(
        label.height,
        math.max(start.height, end.height),
      );
      final double gap = (width - start.width - label.width - end.width) / 2;
      place(_start, rtl ? width - start.width : 0, (height - start.height) / 2);
      place(
        _label,
        rtl ? end.width + gap : start.width + gap,
        (height - label.height) / 2,
      );
      place(_end, rtl ? 0 : width - end.width, (height - end.height) / 2);
      return constraints.constrain(Size(width, height));
    }

    final double width = constraints.maxWidth;
    final Size label = layoutChild(_label, loose);
    place(_label, (width - label.width) / 2, 0);
    double height = label.height;
    if (start.width + end.width <= width) {
      final double row = math.max(start.height, end.height);
      final double left = (width - start.width - end.width) / 2;
      final RenderBox first = rtl ? _end : _start;
      final Size firstSize = rtl ? end : start;
      final RenderBox second = rtl ? _start : _end;
      final Size secondSize = rtl ? start : end;
      place(first, left, height + (row - firstSize.height) / 2);
      place(
        second,
        left + firstSize.width,
        height + (row - secondSize.height) / 2,
      );
      height += row;
    } else {
      place(_start, (width - start.width) / 2, height);
      height += start.height;
      place(_end, (width - end.width) / 2, height);
      height += end.height;
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}

/// The one place the date picker turns its style layers into concrete values.
///
/// Precedence: the picker's own style, then the theme's date picker style,
/// then defaults derived from theme tokens. The panel and the popover trigger
/// both read from this resolver.
class ResolvedDatePickerStyle {
  /// Registered ratio of the heading to `typography.heading` (15 of 20).
  static const double headerFontRatio = 15 / 20;

  /// Registered ratio of day and month labels to `typography.body` (13 of 14).
  static const double cellFontRatio = 13 / 14;

  /// Registered ratio of the year icons to the month icons (18 of 20).
  static const double yearIconRatio = 18 / 20;

  /// Theme whose tokens supply every default.
  final AnimalIslandTheme theme;

  /// Widget style merged over the theme's date picker style.
  final AnimalDatePickerStyle style;

  /// Preferred panel width. Defaults to 300.
  final double width;

  /// Padding inside the panel border. Defaults to `spacing.md` on every side.
  final EdgeInsetsGeometry padding;

  /// Width of the panel, menu and trigger borders. Defaults to 1.5.
  final double borderWidth;

  /// Corner radius of the panel and popover menu. Defaults to
  /// `radii.cardBorder`.
  final BorderRadius borderRadius;

  /// Inset between a date cell's target and its selection fill. Defaults to 6.
  final double cellInset;

  /// Corner radius of the fill behind days inside a range. Defaults to 4.
  final BorderRadius rangeBorderRadius;

  /// Border width of month-mode cells. Defaults to 1.
  final double monthBorderWidth;

  /// Corner radius of month-mode cells. Defaults to `radii.pillBorder`.
  final BorderRadius monthBorderRadius;

  /// Size of the previous/next month icons. Defaults to 20.
  final double navigationIconSize;

  /// Size of the trigger's calendar and clear icons. Defaults to 16.
  final double triggerIconSize;

  /// Corner radius of the popover trigger. Defaults to `radii.pillBorder`.
  final BorderRadius triggerBorderRadius;

  /// Horizontal padding inside the popover trigger. Defaults to `spacing.md`.
  final double triggerHorizontalPadding;

  /// Gap between the trigger icon and its text. Defaults to `spacing.sm`.
  final double triggerIconGap;

  /// Padding around the clear icon inside its target. Defaults to zero.
  final EdgeInsetsGeometry triggerClearButtonPadding;

  /// Corner radius of the clear control. Defaults to `radii.pillBorder`.
  final BorderRadius triggerClearButtonBorderRadius;

  /// Fill behind the clear icon; transparent unless the style resolves a color.
  final WidgetStateProperty<Color> triggerClearButtonBackgroundColor;

  /// Gap between the header, the grid and the footer divider. Defaults to
  /// `spacing.sm`.
  final double sectionGap;

  /// Gap between the footer divider and its actions. Defaults to `spacing.xs`.
  final double footerGap;

  /// Gap between month cells, date rows and below the weekdays. Defaults to
  /// `spacing.xs`.
  final double cellGap;

  /// Horizontal padding inside the Today and Clear actions. Defaults to
  /// `spacing.sm`.
  final double actionHorizontalPadding;

  /// Heading, without its color.
  final TextStyle headerTextStyle;

  /// Weekday labels, with their color.
  final TextStyle weekdayTextStyle;

  /// Regular-weight day and month labels, without their color.
  final TextStyle cellTextStyle;

  /// Today action, without its color.
  final TextStyle todayTextStyle;

  /// Clear action, without its color.
  final TextStyle clearTextStyle;

  /// Trigger text, without its color.
  final TextStyle triggerTextStyle;

  /// Panel and popover menu surface. Defaults to `colors.bgContent`.
  final Color backgroundColor;

  /// Panel and divider border, resolved for the disabled state.
  final Color panelBorderColor;

  ResolvedDatePickerStyle._({
    required this.theme,
    required this.style,
    required this.width,
    required this.padding,
    required this.borderWidth,
    required this.borderRadius,
    required this.cellInset,
    required this.rangeBorderRadius,
    required this.monthBorderWidth,
    required this.monthBorderRadius,
    required this.navigationIconSize,
    required this.triggerIconSize,
    required this.triggerBorderRadius,
    required this.triggerHorizontalPadding,
    required this.triggerIconGap,
    required this.triggerClearButtonPadding,
    required this.triggerClearButtonBorderRadius,
    required this.triggerClearButtonBackgroundColor,
    required this.sectionGap,
    required this.footerGap,
    required this.cellGap,
    required this.actionHorizontalPadding,
    required this.headerTextStyle,
    required this.weekdayTextStyle,
    required this.cellTextStyle,
    required this.todayTextStyle,
    required this.clearTextStyle,
    required this.triggerTextStyle,
    required this.backgroundColor,
    required this.panelBorderColor,
  });

  /// Returns the concrete values for [style] layered over [theme].
  ///
  /// [disabled] selects the state [panelBorderColor] is resolved against.
  static ResolvedDatePickerStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalDatePickerStyle? style,
    required bool disabled,
  }) {
    final AnimalDatePickerStyle merged = (style ?? AnimalDatePickerStyle())
        .merge(theme.components.datePicker);
    final colors = theme.colors;
    final typography = theme.typography;
    final Color defaultBorder = colors.brightness == Brightness.dark
        ? colors.border
        : colors.borderLight;
    final TextStyle caption = typography.caption;

    return ResolvedDatePickerStyle._(
      theme: theme,
      style: merged,
      width: merged.width ?? 300.0,
      padding: merged.padding ?? EdgeInsets.all(theme.spacing.md),
      borderWidth: merged.borderWidth ?? 1.5,
      borderRadius: merged.borderRadius ?? theme.radii.cardBorder,
      cellInset: merged.cellInset ?? 6.0,
      rangeBorderRadius: merged.rangeBorderRadius ?? BorderRadius.circular(4),
      monthBorderWidth: merged.monthBorderWidth ?? 1.0,
      monthBorderRadius: merged.monthBorderRadius ?? theme.radii.pillBorder,
      navigationIconSize: merged.navigationIconSize ?? 20.0,
      triggerIconSize: merged.triggerIconSize ?? 16.0,
      triggerBorderRadius: merged.triggerBorderRadius ?? theme.radii.pillBorder,
      triggerHorizontalPadding:
          merged.triggerHorizontalPadding ?? theme.spacing.md,
      triggerIconGap: merged.triggerIconGap ?? theme.spacing.sm,
      triggerClearButtonPadding:
          merged.triggerClearButtonPadding ?? EdgeInsets.zero,
      triggerClearButtonBorderRadius:
          merged.triggerClearButtonBorderRadius ?? theme.radii.pillBorder,
      triggerClearButtonBackgroundColor: resolveIconActionBackground(
        merged.triggerClearButtonBackgroundColor,
        idle: const Color(0x00000000),
        hovered: const Color(0x00000000),
      ),
      sectionGap: merged.sectionGap ?? theme.spacing.sm,
      footerGap: merged.footerGap ?? theme.spacing.xs,
      cellGap: merged.cellGap ?? theme.spacing.xs,
      actionHorizontalPadding:
          merged.actionHorizontalPadding ?? theme.spacing.sm,
      headerTextStyle: typography.resolve(
        typography.heading
            .apply(fontSizeFactor: headerFontRatio)
            .merge(merged.headerTextStyle),
      ),
      weekdayTextStyle: typography
          .resolve(
            caption
                .copyWith(fontWeight: FontWeight.w700)
                .merge(merged.weekdayTextStyle),
          )
          .copyWith(color: merged.weekdayTextColor ?? colors.textSecondary),
      cellTextStyle: typography.resolve(
        typography.body
            .apply(fontSizeFactor: cellFontRatio)
            .copyWith(fontWeight: FontWeight.w500)
            .merge(merged.cellTextStyle),
      ),
      todayTextStyle: typography.resolve(
        caption
            .copyWith(fontWeight: FontWeight.w700)
            .merge(merged.actionTextStyle),
      ),
      clearTextStyle: typography.resolve(
        caption
            .copyWith(fontWeight: FontWeight.w600)
            .merge(merged.actionTextStyle),
      ),
      triggerTextStyle: typography.resolve(
        typography.body.merge(merged.triggerTextStyle),
      ),
      backgroundColor: merged.backgroundColor ?? colors.bgContent,
      panelBorderColor:
          merged.borderColor?.resolve(<WidgetState>{
            if (disabled) WidgetState.disabled,
          }) ??
          defaultBorder,
    );
  }

  Set<WidgetState> _states({bool disabled = false, bool selected = false}) =>
      <WidgetState>{
        if (disabled) WidgetState.disabled,
        if (selected) WidgetState.selected,
      };

  /// Size of the previous/next year icons.
  double get yearIconSize => navigationIconSize * yearIconRatio;

  /// Heading text or a navigation icon; [enabled] false renders it inert.
  Color headerTextColor({required bool enabled}) =>
      style.headerTextColor?.resolve(_states(disabled: !enabled)) ??
      (enabled ? theme.colors.text : theme.colors.textDisabled);

  /// Label of a day or month cell.
  Color cellTextColor({
    required bool selected,
    required bool disabled,
    bool rangeEndpoint = false,
    bool outsideMonth = false,
  }) {
    final colors = theme.colors;
    if (!disabled && selected && rangeEndpoint) {
      return style.rangeTextColor ?? colors.onWarning;
    }
    if (!disabled && !selected && outsideMonth) {
      return style.outsideMonthTextColor ?? colors.textSecondary;
    }
    return style.cellTextColor?.resolve(
          _states(disabled: disabled, selected: selected),
        ) ??
        (disabled
            ? colors.textDisabled
            : selected
            ? colors.onPrimary
            : colors.text);
  }

  /// Fill of the selected day or month.
  Color get selectedBackgroundColor =>
      style.selectedBackgroundColor ?? theme.colors.primary;

  /// Fill of range endpoints.
  Color get rangeBackgroundColor =>
      style.rangeBackgroundColor ?? theme.colors.warning;

  /// Fill of days inside a range: [rangeBackgroundColor] at a registered 18% opacity.
  Color get rangeFillColor => rangeBackgroundColor.withValues(alpha: 0.18);

  /// Border of a month cell.
  Color monthBorderColor({required bool selected}) =>
      style.monthBorderColor?.resolve(_states(selected: selected)) ??
      (selected
          ? theme.colors.primaryActive
          : theme.colors.border.withValues(alpha: 0.5));

  /// Label color of the Today action.
  Color todayTextColor({required bool disabled}) =>
      style.todayTextColor?.resolve(_states(disabled: disabled)) ??
      (disabled ? theme.colors.textDisabled : theme.colors.primaryText);

  /// Label color of the Clear action.
  Color clearTextColor({required bool disabled}) =>
      style.clearTextColor?.resolve(_states(disabled: disabled)) ??
      (disabled ? theme.colors.textDisabled : theme.colors.textSecondary);

  /// Surface of the popover trigger.
  Color triggerBackgroundColor({required bool disabled}) {
    final colors = theme.colors;
    return style.triggerBackgroundColor?.resolve(_states(disabled: disabled)) ??
        (disabled
            ? (colors.brightness == Brightness.dark
                  ? colors.surfaceHeader
                  : colors.bgInputDisabled)
            : colors.bgInput);
  }

  /// Trigger text: the selected value or the placeholder.
  Color triggerTextColor({required bool disabled, required bool hasValue}) {
    if (!hasValue) {
      return style.placeholderTextColor ?? theme.colors.textSecondary;
    }
    return style.triggerTextColor?.resolve(_states(disabled: disabled)) ??
        (disabled ? theme.colors.textDisabled : theme.colors.text);
  }

  /// Color of the trigger's calendar and clear icons.
  Color triggerIconColor({required bool disabled}) =>
      style.triggerIconColor?.resolve(_states(disabled: disabled)) ??
      (disabled ? theme.colors.textDisabled : theme.colors.textSecondary);

  /// Trigger border and glow; see [resolveFieldTriggerStatus].
  AnimalFieldTriggerStatus trigger({
    required bool disabled,
    required bool focused,
    required bool error,
    required bool warning,
  }) => resolveFieldTriggerStatus(
    theme: theme,
    states: <WidgetState>{
      if (disabled) WidgetState.disabled,
      if (focused) WidgetState.focused,
      if (error) WidgetState.error,
    },
    warning: warning,
    borderColor: style.borderColor,
    warningColor: style.warningColor,
    glowColor: style.glowColor,
  );
}
