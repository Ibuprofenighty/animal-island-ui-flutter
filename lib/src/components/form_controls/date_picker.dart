import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';
import '../form/form.dart';
import 'input.dart';

enum AnimalDatePickerMode {
  date,
  month,
}

/// Animal Island calendar card date picker.
///
/// Features:
/// - Single date or [range] selection mode with continuous citrus ribbon strip
/// - Date or [month] picker mode
/// - Custom [disabledDate] predicate
/// - Bottom quick [showToday] and [allowClear] buttons
/// - Inline panel or Popover trigger with [AnimalDatePicker.popover]
class AnimalDatePicker extends StatefulWidget {
  final DateTime? value;
  final DateTimeRange? rangeValue;
  final bool range;
  final AnimalDatePickerMode picker;
  final ValueChanged<DateTime?>? onChanged;
  final ValueChanged<DateTimeRange?>? onRangeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime date)? disabledDate;
  final bool showToday;
  final bool allowClear;
  final bool disabled;
  final FocusNode? focusNode;

  const AnimalDatePicker({
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

  /// Factory launcher to build an interactive popover input field.
  static Widget popover({
    Key? key,
    DateTime? value,
    DateTimeRange? rangeValue,
    bool range = false,
    AnimalDatePickerMode picker = AnimalDatePickerMode.date,
    ValueChanged<DateTime?>? onChanged,
    ValueChanged<DateTimeRange?>? onRangeChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime date)? disabledDate,
    String? placeholder,
    bool showToday = true,
    bool allowClear = true,
    bool disabled = false,
    AnimalInputStatus status = AnimalInputStatus.normal,
    FocusNode? focusNode,
  }) {
    return _AnimalDatePickerPopover(
      key: key,
      value: value,
      rangeValue: rangeValue,
      range: range,
      picker: picker,
      onChanged: onChanged,
      onRangeChanged: onRangeChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDate: disabledDate,
      placeholder: placeholder,
      showToday: showToday,
      allowClear: allowClear,
      disabled: disabled,
      status: status,
      focusNode: focusNode,
    );
  }

  @override
  State<AnimalDatePicker> createState() => _AnimalDatePickerState();
}

class _AnimalDatePickerState extends State<AnimalDatePicker> {
  late DateTime _currentMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode {
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  @override
  void didUpdateWidget(covariant AnimalDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.rangeValue != widget.rangeValue) {
      _initValues();
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _initValues() {
    _rangeStart = widget.rangeValue?.start;
    _rangeEnd = widget.rangeValue?.end;
    _currentMonth = widget.value ?? _rangeStart ?? DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _previousYear() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year - 1, _currentMonth.month);
    });
  }

  void _nextYear() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year + 1, _currentMonth.month);
    });
  }

  bool _isDateDisabled(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (widget.firstDate != null) {
      final f = DateTime(widget.firstDate!.year, widget.firstDate!.month, widget.firstDate!.day);
      if (d.isBefore(f)) return true;
    }
    if (widget.lastDate != null) {
      final l = DateTime(widget.lastDate!.year, widget.lastDate!.month, widget.lastDate!.day);
      if (d.isAfter(l)) return true;
    }
    if (widget.disabledDate != null && widget.disabledDate!(date)) return true;
    return false;
  }

  void _handleDateTap(DateTime date) {
    if (_isDateDisabled(date) || widget.disabled) return;

    final formItem = AnimalFormItemScope.of(context);

    if (!widget.range) {
      formItem?.onChanged?.call(date);
      widget.onChanged?.call(date);
      return;
    }

    // Range selection logic
    setState(() {
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = date;
        _rangeEnd = null;
      } else if (_rangeStart != null && _rangeEnd == null) {
        if (date.isBefore(_rangeStart!)) {
          _rangeStart = date;
        } else {
          _rangeEnd = date;
          final range = DateTimeRange(start: _rangeStart!, end: _rangeEnd!);
          formItem?.onChanged?.call(range);
          widget.onRangeChanged?.call(range);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final borderColor = theme.isDark ? theme.border : AnimalColors.borderLight;

    final canPrevMonth = widget.firstDate == null || DateTime(year, month, 1).isAfter(DateTime(widget.firstDate!.year, widget.firstDate!.month, 1));
    final canPrevYear = widget.firstDate == null || year > widget.firstDate!.year;
    final canNextMonth = widget.lastDate == null || DateTime(year, month, 1).isBefore(DateTime(widget.lastDate!.year, widget.lastDate!.month, 1));
    final canNextYear = widget.lastDate == null || year < widget.lastDate!.year;
    final formItem = AnimalFormItemScope.of(context);

    return Focus(
      focusNode: _effectiveFocusNode,
      onFocusChange: (val) {
        if (!val) formItem?.onBlur?.call();
      },
      child: Container(
        width: 320.0,
        padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.bgContent,
        borderRadius: AnimalRadii.cardBorder,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(61, 52, 40, 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: canPrevYear ? _previousYear : null,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.keyboard_double_arrow_left_rounded,
                        size: 16,
                        color: canPrevYear ? theme.text : theme.textDisabled,
                      ),
                    ),
                  ),
                  if (widget.picker == AnimalDatePickerMode.date)
                    GestureDetector(
                      onTap: canPrevMonth ? _previousMonth : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: canPrevMonth ? theme.text : theme.textDisabled,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                widget.picker == AnimalDatePickerMode.month
                    ? '$year'
                    : '$year / ${month.toString().padLeft(2, '0')}',
                style: AnimalTypography.heading.copyWith(
                  fontSize: 15.0,
                  color: theme.text,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.picker == AnimalDatePickerMode.date)
                    GestureDetector(
                      onTap: canNextMonth ? _nextMonth : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: canNextMonth ? theme.text : theme.textDisabled,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: canNextYear ? _nextYear : null,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        size: 16,
                        color: canNextYear ? theme.text : theme.textDisabled,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          if (widget.picker == AnimalDatePickerMode.month)
            _buildMonthGrid(theme, year)
          else
            _buildDateGrid(theme, year, month),

          // Footer: Today & Clear
          if (widget.showToday || widget.allowClear) ...[
            const SizedBox(height: 12.0),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.showToday) ...[
                  Builder(builder: (context) {
                    final now = DateTime.now();
                    final isTodayDisabled = widget.disabled || _isDateDisabled(now);
                    return Semantics(
                      button: true,
                      label: 'Today',
                      enabled: !isTodayDisabled,
                      child: TextButton(
                        onPressed: isTodayDisabled
                            ? null
                            : () {
                                if (widget.disabled || _isDateDisabled(now)) return;
                                setState(() => _currentMonth = now);
                                final formItem = AnimalFormItemScope.of(context);
                                if (widget.range) {
                                  _rangeStart = now;
                                  _rangeEnd = now;
                                  final range = DateTimeRange(start: now, end: now);
                                  formItem?.onChanged?.call(range);
                                  widget.onRangeChanged?.call(range);
                                } else {
                                  formItem?.onChanged?.call(now);
                                  widget.onChanged?.call(now);
                                }
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          'Today',
                          style: AnimalTypography.caption.copyWith(
                            color: isTodayDisabled ? theme.textDisabled : theme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ] else
                  const SizedBox.shrink(),
                if (widget.allowClear)
                  Semantics(
                    button: true,
                    label: 'Clear date',
                    enabled: !widget.disabled,
                    child: TextButton(
                      onPressed: widget.disabled
                          ? null
                          : () {
                              setState(() {
                                _rangeStart = null;
                                _rangeEnd = null;
                              });
                              final formItem = AnimalFormItemScope.of(context);
                              formItem?.onChanged?.call(null);
                              widget.onChanged?.call(null);
                              widget.onRangeChanged?.call(null);
                            },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Clear',
                        style: AnimalTypography.caption.copyWith(
                          color: widget.disabled ? theme.textDisabled : theme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildMonthGrid(AnimalIslandTheme theme, int year) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(12, (index) {
        final monthNum = index + 1;
        final formItem = AnimalFormItemScope.of(context);
        final effectiveValue = (formItem != null && formItem.name != null && formItem.currentValue is DateTime)
            ? formItem.currentValue as DateTime
            : widget.value;
        final isSelected = effectiveValue != null &&
            effectiveValue.year == year &&
            effectiveValue.month == monthNum;
        final isMonthDisabled = (widget.firstDate != null && DateTime(year, monthNum + 1, 0).isBefore(DateTime(widget.firstDate!.year, widget.firstDate!.month, widget.firstDate!.day))) ||
            (widget.lastDate != null && DateTime(year, monthNum, 1).isAfter(DateTime(widget.lastDate!.year, widget.lastDate!.month, widget.lastDate!.day)));

        final monthStr = '$year-${monthNum.toString().padLeft(2, '0')}';

        return SizedBox(
          width: 90.0,
          height: 38.0,
          child: FocusableActionDetector(
            enabled: !isMonthDisabled,
            mouseCursor: isMonthDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  if (!isMonthDisabled) {
                    final date = DateTime(year, monthNum, 1);
                    final formItem = AnimalFormItemScope.of(context);
                    formItem?.onChanged?.call(date);
                    widget.onChanged?.call(date);
                  }
                  return null;
                },
              ),
            },
            child: Semantics(
              button: true,
              label: monthStr,
              selected: isSelected,
              enabled: !isMonthDisabled,
              child: GestureDetector(
                onTap: isMonthDisabled
                    ? null
                    : () {
                        final date = DateTime(year, monthNum, 1);
                        final formItem = AnimalFormItemScope.of(context);
                        formItem?.onChanged?.call(date);
                        widget.onChanged?.call(date);
                      },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? theme.primary : Colors.transparent,
                  borderRadius: AnimalRadii.pillBorder,
                  border: Border.all(
                    color: isSelected ? theme.primaryActive : theme.border.withValues(alpha: 0.5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  months[index],
                  style: AnimalTypography.body.copyWith(
                    fontSize: 13.0,
                    color: isMonthDisabled
                        ? theme.textDisabled
                        : (isSelected ? Colors.white : theme.text),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateGrid(AnimalIslandTheme theme, int year, int month) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstDayOffset = DateTime(year, month, 1).weekday % 7;

    return Column(
      children: [
        // Weekdays
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
              .map((day) => SizedBox(
                    width: 36,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: AnimalTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.textSecondary,
                        fontSize: 12.0,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6.0),
        Wrap(
          spacing: 2.0,
          runSpacing: 4.0,
          children: List.generate(firstDayOffset + daysInMonth, (index) {
            if (index < firstDayOffset) {
              return const SizedBox(width: 39.0, height: 36.0);
            }
            final day = index - firstDayOffset + 1;
            final date = DateTime(year, month, day);
            final isDisabled = _isDateDisabled(date);

            // Selection state calculation
            final formItem = AnimalFormItemScope.of(context);
            DateTime? effectiveValue = widget.value;
            DateTime? effectiveStart = _rangeStart;
            DateTime? effectiveEnd = _rangeEnd;
            if (formItem != null && formItem.name != null) {
              if (!widget.range && formItem.currentValue is DateTime) {
                effectiveValue = formItem.currentValue as DateTime;
              } else if (widget.range && formItem.currentValue is DateTimeRange) {
                effectiveStart = (formItem.currentValue as DateTimeRange).start;
                effectiveEnd = (formItem.currentValue as DateTimeRange).end;
              } else if (formItem.currentValue == null) {
                effectiveValue = null;
                effectiveStart = null;
                effectiveEnd = null;
              }
            }

            bool isExactStart = false;
            bool isExactEnd = false;
            bool isInRange = false;

            if (!widget.range && effectiveValue != null) {
              isExactStart = DateUtils.isSameDay(effectiveValue, date);
            } else if (widget.range) {
              if (effectiveStart != null && DateUtils.isSameDay(effectiveStart, date)) {
                isExactStart = true;
              }
              if (effectiveEnd != null && DateUtils.isSameDay(effectiveEnd, date)) {
                isExactEnd = true;
              }
              if (effectiveStart != null && effectiveEnd != null) {
                isInRange = date.isAfter(effectiveStart) && date.isBefore(effectiveEnd);
              }
            }

            final isSelected = isExactStart || isExactEnd;

            Color bgColor = Colors.transparent;
            if (isSelected) {
              bgColor = widget.range ? theme.warning : theme.primary;
            } else if (isInRange) {
              bgColor = theme.warning.withValues(alpha: 0.18);
            }

            final dateStr = '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

            return SizedBox(
              width: 39.0,
              height: 36.0,
              child: FocusableActionDetector(
                enabled: !isDisabled,
                mouseCursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (_) {
                      if (!isDisabled) _handleDateTap(date);
                      return null;
                    },
                  ),
                },
                child: Semantics(
                  button: true,
                  label: dateStr,
                  selected: isSelected,
                  enabled: !isDisabled,
                  child: GestureDetector(
                    onTap: isDisabled ? null : () => _handleDateTap(date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                        borderRadius: isInRange ? BorderRadius.circular(4.0) : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: widget.range
                                      ? theme.warning
                                      : theme.primaryActive,
                                  offset: const Offset(0, 2),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: AnimalTypography.body.copyWith(
                          fontSize: 13.0,
                          color: isDisabled
                              ? theme.textDisabled
                              : (isSelected
                                  ? Colors.white
                                  : (isInRange ? theme.warning : theme.text)),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AnimalDatePickerPopover extends StatefulWidget {
  final DateTime? value;
  final DateTimeRange? rangeValue;
  final bool range;
  final AnimalDatePickerMode picker;
  final ValueChanged<DateTime?>? onChanged;
  final ValueChanged<DateTimeRange?>? onRangeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool Function(DateTime date)? disabledDate;
  final String? placeholder;
  final bool showToday;
  final bool allowClear;
  final bool disabled;
  final AnimalInputStatus status;
  final FocusNode? focusNode;

  const _AnimalDatePickerPopover({
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
    this.placeholder,
    this.showToday = true,
    this.allowClear = true,
    this.disabled = false,
    this.status = AnimalInputStatus.normal,
    this.focusNode,
  });

  @override
  State<_AnimalDatePickerPopover> createState() => _AnimalDatePickerPopoverState();
}

class _AnimalDatePickerPopoverState extends State<_AnimalDatePickerPopover> {
  final MenuController _menuController = MenuController();
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode {
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime? _getEffectiveValue(AnimalFormItemScope? formItem) {
    if (formItem != null && formItem.name != null) {
      if (formItem.currentValue is DateTime) {
        return formItem.currentValue as DateTime;
      } else if (formItem.currentValue == null) {
        return null;
      }
    }
    return widget.value;
  }

  DateTimeRange? _getEffectiveRangeValue(AnimalFormItemScope? formItem) {
    if (formItem != null && formItem.name != null) {
      if (formItem.currentValue is DateTimeRange) {
        return formItem.currentValue as DateTimeRange;
      } else if (formItem.currentValue == null) {
        return null;
      }
    }
    return widget.rangeValue;
  }

  String _displayText(DateTime? effectiveVal, DateTimeRange? effectiveRange) {
    if (widget.range) {
      if (effectiveRange != null) {
        return '${_formatDate(effectiveRange.start)} ~ ${_formatDate(effectiveRange.end)}';
      }
      return widget.placeholder ?? 'Select date range';
    } else {
      if (effectiveVal != null) {
        return _formatDate(effectiveVal);
      }
      return widget.placeholder ?? 'Select date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formItem = AnimalFormItemScope.of(context);
    final effectiveValue = _getEffectiveValue(formItem);
    final effectiveRangeValue = _getEffectiveRangeValue(formItem);
    final hasValue = widget.range ? effectiveRangeValue != null : effectiveValue != null;
    final effectiveStatus = (widget.status == AnimalInputStatus.normal && formItem?.hasError == true)
        ? AnimalInputStatus.error
        : widget.status;

    final inputBg = widget.disabled
        ? (theme.isDark ? theme.surfaceHeader : AnimalColors.bgInputDisabled)
        : theme.bgInput;

    final defaultBorderColor = theme.isDark ? theme.border : AnimalColors.borderLight;
    final canInteract = !widget.disabled;
    Color borderColor;
    Color? glowColor;

    if (effectiveStatus == AnimalInputStatus.error) {
      borderColor = theme.error;
      glowColor = theme.error.withValues(alpha: 0.35);
    } else if (effectiveStatus == AnimalInputStatus.warning) {
      borderColor = theme.warning;
      glowColor = theme.warning.withValues(alpha: 0.35);
    } else if (_menuController.isOpen || _isFocused) {
      borderColor = theme.focusYellow;
      glowColor = theme.focusYellow.withValues(alpha: 0.45);
    } else {
      borderColor = defaultBorderColor;
      glowColor = null;
    }

    final displayText = _displayText(effectiveValue, effectiveRangeValue);

    return FocusableActionDetector(
      focusNode: _effectiveFocusNode,
      enabled: canInteract,
      mouseCursor: canInteract ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onFocusChange: (val) {
        if (!val) formItem?.onBlur?.call();
      },
      onShowFocusHighlight: (val) => setState(() => _isFocused = val),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (canInteract) {
              if (_menuController.isOpen) {
                _menuController.close();
              } else {
                _menuController.open();
              }
            }
            return null;
          },
        ),
      },
      child: MenuAnchor(
        controller: _menuController,
        onClose: () {
          setState(() {});
          formItem?.onBlur?.call();
        },
        onOpen: () => setState(() {}),
        menuChildren: [
          AnimalDatePicker(
            value: effectiveValue,
            rangeValue: effectiveRangeValue,
            range: widget.range,
            picker: widget.picker,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            disabledDate: widget.disabledDate,
            showToday: widget.showToday,
            allowClear: widget.allowClear,
            disabled: widget.disabled,
            onChanged: (val) {
              widget.onChanged?.call(val);
              _menuController.close();
            },
            onRangeChanged: (range) {
              widget.onRangeChanged?.call(range);
              if (range != null) {
                _menuController.close();
              }
            },
          ),
        ],
        style: const MenuStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
        ),
        builder: (context, controller, child) {
          return Semantics(
            button: true,
            label: displayText,
            enabled: canInteract,
            child: GestureDetector(
              onTap: () {
                if (!canInteract) return;
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: AnimatedContainer(
                duration: AnimalMotion.fast,
                curve: AnimalMotion.ease,
                height: 44.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: AnimalRadii.pillBorder,
                  border: Border.all(
                    color: borderColor,
                    width: 1.8,
                  ),
                  boxShadow: glowColor != null
                      ? [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const CalendarIcon(size: 18, color: AnimalColors.textSecondary),
                          const SizedBox(width: 10.0),
                          Flexible(
                            child: Text(
                              displayText,
                              overflow: TextOverflow.ellipsis,
                              style: AnimalTypography.body.copyWith(
                                fontSize: 14.0,
                                color: hasValue
                                    ? (widget.disabled ? theme.textDisabled : theme.text)
                                    : theme.textDisabled,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.allowClear && hasValue && !widget.disabled)
                      _DatePickerClearButton(
                        onClear: () {
                          formItem?.onChanged?.call(null);
                          widget.onChanged?.call(null);
                          widget.onRangeChanged?.call(null);
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DatePickerClearButton extends StatefulWidget {
  final VoidCallback onClear;

  const _DatePickerClearButton({required this.onClear});

  @override
  State<_DatePickerClearButton> createState() => _DatePickerClearButtonState();
}

class _DatePickerClearButtonState extends State<_DatePickerClearButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (val) => setState(() => _isFocused = val),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onClear();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        label: 'Clear date',
        child: GestureDetector(
          onTap: widget.onClear,
          child: Container(
            padding: const EdgeInsets.only(left: 6.0),
            decoration: _isFocused
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.focusYellow.withValues(alpha: 0.55),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            child: const CloseIcon(size: 14, color: AnimalColors.textSecondary),
          ),
        ),
      ),
    );
  }
}


