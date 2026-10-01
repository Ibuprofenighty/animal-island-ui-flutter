import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/date.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import 'calendar_model.dart';

enum AnimalDatePickerMode { date, month }

/// The standalone visual calendar panel for AnimalDatePicker.
class AnimalDatePickerPanel extends StatefulWidget {
  final AnimalDate? value;
  final AnimalDateRange? rangeValue;
  final bool range;
  final AnimalDatePickerMode picker;
  final ValueChanged<AnimalDate?>? onChanged;
  final ValueChanged<AnimalDateRange?>? onRangeChanged;
  final AnimalDate? firstDate;
  final AnimalDate? lastDate;
  final bool Function(AnimalDate date)? disabledDate;
  final bool showToday;
  final bool allowClear;
  final bool disabled;
  final FocusNode? focusNode;

  const AnimalDatePickerPanel({
    super.key,
    this.value,
    this.rangeValue,
    this.range = false,
    this.picker = AnimalDatePickerMode.date,
    this.onChanged,
    this.onRangeChanged,
    this.firstDate,
    this.lastDate,
    this.disabledDate,
    this.showToday = true,
    this.allowClear = true,
    this.disabled = false,
    this.focusNode,
  });

  @override
  State<AnimalDatePickerPanel> createState() => _AnimalDatePickerPanelState();
}

class _AnimalDatePickerPanelState extends State<AnimalDatePickerPanel> {
  late int _viewYear;
  late int _viewMonth;
  AnimalDate? _rangeStart;
  AnimalDate? _rangeEnd;

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _initView();
  }

  @override
  void didUpdateWidget(covariant AnimalDatePickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.rangeValue != widget.rangeValue) {
      _initView();
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _initView() {
    _rangeStart = widget.rangeValue?.start;
    _rangeEnd = widget.rangeValue?.end;
    final initialDate = widget.value ?? _rangeStart ?? AnimalDate.today();
    _viewYear = initialDate.year;
    _viewMonth = initialDate.month;
  }

  void _prevYear() {
    if (widget.disabled) return;
    setState(() {
      _viewYear--;
    });
  }

  void _nextYear() {
    if (widget.disabled) return;
    setState(() {
      _viewYear++;
    });
  }

  void _prevMonth() {
    if (widget.disabled) return;
    setState(() {
      if (_viewMonth == 1) {
        _viewMonth = 12;
        _viewYear--;
      } else {
        _viewMonth--;
      }
    });
  }

  void _nextMonth() {
    if (widget.disabled) return;
    setState(() {
      if (_viewMonth == 12) {
        _viewMonth = 1;
        _viewYear++;
      } else {
        _viewMonth++;
      }
    });
  }

  bool _isDateDisabled(AnimalDate date) {
    return CalendarModel.isDateDisabled(
      date: date,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      disabledDate: widget.disabledDate,
    );
  }

  void _handleDateTap(AnimalDate date) {
    if (widget.disabled || _isDateDisabled(date)) return;

    if (!widget.range) {
      widget.onChanged?.call(date);
      return;
    }

    // Range selection state machine
    setState(() {
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = date;
        _rangeEnd = null;
      } else if (_rangeStart != null && _rangeEnd == null) {
        if (date.isBefore(_rangeStart!)) {
          _rangeStart = date;
        } else {
          // Check for disabled interior dates per Section 6.1
          final hasDisabled = CalendarModel.hasDisabledInteriorDate(
            start: _rangeStart!,
            end: date,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            disabledDate: widget.disabledDate,
          );
          if (!hasDisabled) {
            _rangeEnd = date;
            final range = AnimalDateRange(start: _rangeStart!, end: _rangeEnd!);
            widget.onRangeChanged?.call(range);
          }
        }
      }
    });
  }

  void _handleMonthTap(int monthNum) {
    if (widget.disabled) return;
    final d = AnimalDate(_viewYear, monthNum, 1);
    if (_isDateDisabled(d)) return;
    widget.onChanged?.call(d);
  }

  void _handleToday() {
    if (widget.disabled) return;
    final today = AnimalDate.today();
    if (_isDateDisabled(today)) return;

    setState(() {
      _viewYear = today.year;
      _viewMonth = today.month;
      if (widget.range) {
        _rangeStart = today;
        _rangeEnd = today;
      }
    });

    if (widget.range) {
      widget.onRangeChanged?.call(AnimalDateRange(start: today, end: today));
    } else {
      widget.onChanged?.call(today);
    }
  }

  void _handleClear() {
    if (widget.disabled) return;
    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
    });
    widget.onChanged?.call(null);
    widget.onRangeChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final borderColor = (theme.colors.brightness == Brightness.dark)
        ? theme.colors.border
        : theme.colors.borderLight;

    final canPrevYear =
        !widget.disabled &&
        (widget.firstDate == null || _viewYear > widget.firstDate!.year);
    final canPrevMonth =
        !widget.disabled &&
        (widget.firstDate == null ||
            (_viewYear > widget.firstDate!.year ||
                (_viewYear == widget.firstDate!.year &&
                    _viewMonth > widget.firstDate!.month)));
    final canNextMonth =
        !widget.disabled &&
        (widget.lastDate == null ||
            (_viewYear < widget.lastDate!.year ||
                (_viewYear == widget.lastDate!.year &&
                    _viewMonth < widget.lastDate!.month)));
    final canNextYear =
        !widget.disabled &&
        (widget.lastDate == null || _viewYear < widget.lastDate!.year);

    final today = AnimalDate.today();
    final isTodayDisabled = widget.disabled || _isDateDisabled(today);

    return Focus(
      focusNode: _effectiveFocusNode,
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
            // Header: Month / Year navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InteractiveRegion(
                      onPressed: canPrevYear ? _prevYear : null,
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
                    if (widget.picker == AnimalDatePickerMode.date)
                      InteractiveRegion(
                        onPressed: canPrevMonth ? _prevMonth : null,
                        enableHaptics: false,
                        disabled: !canPrevMonth,
                        semanticLabel:
                            materialLocalizations.previousMonthTooltip,
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
                    widget.picker == AnimalDatePickerMode.month
                        ? materialLocalizations.formatYear(
                            DateTime(_viewYear, _viewMonth),
                          )
                        : materialLocalizations.formatMonthYear(
                            DateTime(_viewYear, _viewMonth),
                          ),
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
                    if (widget.picker == AnimalDatePickerMode.date)
                      InteractiveRegion(
                        onPressed: canNextMonth ? _nextMonth : null,
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
                      onPressed: canNextYear ? _nextYear : null,
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
            ),
            SizedBox(height: theme.spacing.sm),

            if (widget.picker == AnimalDatePickerMode.month)
              _buildMonthGrid(theme)
            else
              _buildDateGrid(theme),

            // Footer: Today & Clear
            if (widget.showToday || widget.allowClear) ...[
              SizedBox(height: theme.spacing.sm),
              Divider(height: 1, color: borderColor),
              SizedBox(height: theme.spacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showToday)
                    InteractiveRegion(
                      onPressed: isTodayDisabled ? null : _handleToday,
                      enableHaptics: false,
                      disabled: isTodayDisabled,
                      semanticLabel: localizations.today,
                      surfaceColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing.sm,
                      ),
                      child: Text(
                        localizations.today,
                        style: theme.typography.caption.copyWith(
                          color: isTodayDisabled
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
                      onPressed: widget.disabled ? null : _handleClear,
                      enableHaptics: false,
                      disabled: widget.disabled,
                      semanticLabel: localizations.clearDate,
                      surfaceColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing.sm,
                      ),
                      child: Text(
                        localizations.clear,
                        style: theme.typography.caption.copyWith(
                          color: widget.disabled
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

  Widget _buildMonthGrid(AnimalIslandTheme theme) {
    final locale = Localizations.localeOf(context).toString();
    final months = List<String>.generate(
      12,
      (index) => intl.DateFormat.MMM(locale).format(DateTime(2020, index + 1)),
      growable: false,
    );

    return Wrap(
      spacing: theme.spacing.xs,
      runSpacing: theme.spacing.xs,
      children: List.generate(12, (index) {
        final monthNum = index + 1;
        final d = AnimalDate(_viewYear, monthNum, 1);
        final isMonthDisabled = widget.disabled || _isDateDisabled(d);
        final isSelected =
            widget.value != null &&
            widget.value!.year == _viewYear &&
            widget.value!.month == monthNum;

        return SizedBox(
          width: 86.0,
          height: 48.0,
          child: InteractiveRegion(
            onPressed: isMonthDisabled ? null : () => _handleMonthTap(monthNum),
            enableHaptics: false,
            disabled: isMonthDisabled,
            semanticLabel: MaterialLocalizations.of(context)
                .formatMonthYear(DateTime(_viewYear, monthNum)),
            selected: isSelected,
            surfaceColor: Colors.transparent,
            borderRadius: theme.radii.pillBorder,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? theme.colors.primary : Colors.transparent,
                borderRadius: theme.radii.pillBorder,
                border: Border.all(
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateGrid(AnimalIslandTheme theme) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final effectiveRange = widget.range
        ? (_rangeStart != null && _rangeEnd != null
              ? AnimalDateRange(start: _rangeStart!, end: _rangeEnd!)
              : widget.rangeValue)
        : null;

    final cells = CalendarModel.buildMonthGrid(
      year: _viewYear,
      month: _viewMonth,
      selectedDate: widget.value,
      selectedRange: effectiveRange,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      disabledDate: widget.disabledDate,
    );

    Widget buildDateCell(CalendarDayCell cell) {
      final isDisabled = widget.disabled || cell.isDisabled;
      final isSelected =
          cell.isSelected || cell.isRangeStart || cell.isRangeEnd;
      final bgColor = isSelected
          ? (widget.range ? theme.colors.warning : theme.colors.primary)
          : (cell.isInRange
                ? theme.colors.warning.withValues(alpha: 0.18)
                : Colors.transparent);
      final textColor = isDisabled
          ? theme.colors.textDisabled
          : isSelected
          ? (widget.range ? theme.colors.onWarning : theme.colors.onPrimary)
          : (!cell.isCurrentMonth
                ? theme.colors.textSecondary
                : theme.colors.text);

      return SizedBox(
        width: 48,
        height: 48,
        child: InteractiveRegion(
          onPressed: isDisabled ? null : () => _handleDateTap(cell.date),
          enableHaptics: false,
          disabled: isDisabled,
          selected: isSelected,
          semanticLabel: materialLocalizations.formatFullDate(
            cell.date.toDateTime(),
          ),
          surfaceColor: Colors.transparent,
          minimumHitSize: 48,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: cell.isInRange && !isSelected
                    ? BorderRadius.circular(4)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${cell.date.day}',
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                List<String>.generate(
                      7,
                      (index) => materialLocalizations.narrowWeekdays[index],
                      growable: false,
                    )
                    .map(
                      (day) => SizedBox(
                        width: 48,
                        height: 24,
                        child: Center(
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: theme.typography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
