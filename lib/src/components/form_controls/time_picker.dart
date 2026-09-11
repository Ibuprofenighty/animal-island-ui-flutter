import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';
import '../form/form.dart';
import 'input.dart';

/// Animal Island time picker card with 3-column scroll wheels.
///
/// Features:
/// - Three smooth scroll columns for hours, minutes, and optional seconds
/// - Supports [hourStep], [minuteStep], and [secondStep]
/// - Supports [format] masks (e.g. 'HH:mm' or 'HH:mm:ss')
/// - Inline panel or Popover trigger with [AnimalTimePicker.popover]
/// - Automatic binding with [AnimalFormItem]
class AnimalTimePicker extends StatefulWidget {
  final TimeOfDay? value;
  final int? second;
  final ValueChanged<TimeOfDay?>? onChanged;
  final void Function(int? hour, int? minute, int? second)? onFullTimeChanged;
  final String format;
  final int hourStep;
  final int minuteStep;
  final int secondStep;
  final bool showNow;
  final bool allowClear;
  final bool disabled;
  final FocusNode? focusNode;

  const AnimalTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.second,
    this.onFullTimeChanged,
    this.format = 'HH:mm',
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.showNow = true,
    this.allowClear = true,
    this.disabled = false,
    this.focusNode,
  })  : assert(hourStep >= 1, 'hourStep must be >= 1'),
        assert(minuteStep >= 1, 'minuteStep must be >= 1'),
        assert(secondStep >= 1, 'secondStep must be >= 1');

  /// Factory launcher to build an interactive popover input field.
  static Widget popover({
    Key? key,
    TimeOfDay? value,
    int? second,
    ValueChanged<TimeOfDay?>? onChanged,
    void Function(int? hour, int? minute, int? second)? onFullTimeChanged,
    String format = 'HH:mm',
    int hourStep = 1,
    int minuteStep = 1,
    int secondStep = 1,
    String? placeholder,
    bool showNow = true,
    bool allowClear = true,
    bool disabled = false,
    AnimalInputStatus status = AnimalInputStatus.normal,
    FocusNode? focusNode,
  }) {
    assert(hourStep >= 1, 'hourStep must be >= 1');
    assert(minuteStep >= 1, 'minuteStep must be >= 1');
    assert(secondStep >= 1, 'secondStep must be >= 1');
    return _AnimalTimePickerPopover(
      key: key,
      value: value,
      second: second,
      onChanged: onChanged,
      onFullTimeChanged: onFullTimeChanged,
      format: format,
      hourStep: hourStep,
      minuteStep: minuteStep,
      secondStep: secondStep,
      placeholder: placeholder,
      showNow: showNow,
      allowClear: allowClear,
      disabled: disabled,
      status: status,
      focusNode: focusNode,
    );
  }

  @override
  State<AnimalTimePicker> createState() => _AnimalTimePickerState();
}

class _AnimalTimePickerState extends State<AnimalTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;

  bool get _hasSeconds => widget.format.contains('ss');

  int get _stepH => widget.hourStep >= 1 ? widget.hourStep : 1;
  int get _stepM => widget.minuteStep >= 1 ? widget.minuteStep : 1;
  int get _stepS => widget.secondStep >= 1 ? widget.secondStep : 1;

  List<int> get _hours => [for (int i = 0; i < 24; i += _stepH) i];
  List<int> get _minutes => [for (int i = 0; i < 60; i += _stepM) i];
  List<int> get _seconds => [for (int i = 0; i < 60; i += _stepS) i];

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode {
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  static int _snapToStep(int val, List<int> items) {
    if (items.isEmpty) return val;
    if (items.contains(val)) return val;
    return items.reduce((a, b) => (val - a).abs() < (val - b).abs() ? a : b);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final rawHour = widget.value?.hour ?? now.hour;
    final rawMinute = widget.value?.minute ?? now.minute;
    final rawSecond = widget.second ?? now.second;
    _selectedHour = _snapToStep(rawHour, _hours);
    _selectedMinute = _snapToStep(rawMinute, _minutes);
    _selectedSecond = _snapToStep(rawSecond, _seconds);

    _hourController = FixedExtentScrollController(
      initialItem: _hours.indexOf(_selectedHour).clamp(0, _hours.length - 1),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes.indexOf(_selectedMinute).clamp(0, _minutes.length - 1),
    );
    _secondController = FixedExtentScrollController(
      initialItem: _seconds.indexOf(_selectedSecond).clamp(0, _seconds.length - 1),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final formItem = AnimalFormItemScope.of(context);
    if (formItem != null && formItem.name != null && formItem.currentValue is TimeOfDay) {
      final t = formItem.currentValue as TimeOfDay;
      _syncExternalTime(t.hour, t.minute, null);
    }
  }

  @override
  void didUpdateWidget(covariant AnimalTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.second != widget.second) {
      if (widget.value == null && oldWidget.value != null && !_isClearing) {
        _selectedHour = _hours.first;
        _selectedMinute = _minutes.first;
        _selectedSecond = _seconds.first;
        if (_hourController.hasClients && _hourController.selectedItem != 0) {
          _hourController.jumpToItem(0);
        }
        if (_minuteController.hasClients && _minuteController.selectedItem != 0) {
          _minuteController.jumpToItem(0);
        }
        if (_secondController.hasClients && _hasSeconds && _secondController.selectedItem != 0) {
          _secondController.jumpToItem(0);
        }
      } else if (widget.value != null) {
        _syncExternalTime(widget.value!.hour, widget.value!.minute, widget.second);
      } else if (widget.second != null && widget.second != _selectedSecond) {
        _syncExternalTime(null, null, widget.second);
      }
    }
  }

  void _syncExternalTime(int? externalHour, int? externalMinute, int? externalSecond) {
    if (externalHour != null) {
      final snappedH = _snapToStep(externalHour, _hours);
      if (snappedH != _selectedHour) {
        _selectedHour = snappedH;
        final hIdx = _hours.indexOf(snappedH);
        if (hIdx >= 0 && _hourController.hasClients && _hourController.selectedItem != hIdx) {
          _hourController.jumpToItem(hIdx);
        }
      }
    }

    if (externalMinute != null) {
      final snappedM = _snapToStep(externalMinute, _minutes);
      if (snappedM != _selectedMinute) {
        _selectedMinute = snappedM;
        final mIdx = _minutes.indexOf(snappedM);
        if (mIdx >= 0 && _minuteController.hasClients && _minuteController.selectedItem != mIdx) {
          _minuteController.jumpToItem(mIdx);
        }
      }
    }

    if (externalSecond != null) {
      final snappedS = _snapToStep(externalSecond, _seconds);
      if (snappedS != _selectedSecond) {
        _selectedSecond = snappedS;
        final sIdx = _seconds.indexOf(snappedS);
        if (sIdx >= 0 && _secondController.hasClients && _secondController.selectedItem != sIdx) {
          _secondController.jumpToItem(sIdx);
        }
      }
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  bool _isClearing = false;

  void _notifyChange() {
    if (_isClearing) return;
    final time = TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
    final formItem = AnimalFormItemScope.of(context);
    formItem?.onChanged?.call(time);
    widget.onChanged?.call(time);
    widget.onFullTimeChanged?.call(_selectedHour, _selectedMinute, _selectedSecond);
  }

  void _handleNow() {
    if (widget.disabled) return;
    final now = DateTime.now();
    final h = _snapToStep(now.hour, _hours);
    final m = _snapToStep(now.minute, _minutes);
    final s = _snapToStep(now.second, _seconds);
    final hIdx = _hours.indexOf(h);
    final mIdx = _minutes.indexOf(m);
    final sIdx = _seconds.indexOf(s);
    if (hIdx >= 0 && _hourController.hasClients) {
      _hourController.animateToItem(hIdx, duration: AnimalMotion.fast, curve: Curves.ease);
    }
    if (mIdx >= 0 && _minuteController.hasClients) {
      _minuteController.animateToItem(mIdx, duration: AnimalMotion.fast, curve: Curves.ease);
    }
    if (sIdx >= 0 && _hasSeconds && _secondController.hasClients) {
      _secondController.animateToItem(sIdx, duration: AnimalMotion.fast, curve: Curves.ease);
    }
    setState(() {
      _selectedHour = h;
      _selectedMinute = m;
      _selectedSecond = s;
    });
    _notifyChange();
  }

  void _handleClear() {
    if (widget.disabled) return;
    _isClearing = true;
    final firstH = _hours.first;
    final firstM = _minutes.first;
    final firstS = _seconds.first;
    if (_hourController.hasClients) {
      _hourController.jumpToItem(0);
    }
    if (_minuteController.hasClients) {
      _minuteController.jumpToItem(0);
    }
    if (_secondController.hasClients && _hasSeconds) {
      _secondController.jumpToItem(0);
    }
    setState(() {
      _selectedHour = firstH;
      _selectedMinute = firstM;
      _selectedSecond = firstS;
    });
    final formItem = AnimalFormItemScope.of(context);
    formItem?.onChanged?.call(null);
    widget.onChanged?.call(null);
    widget.onFullTimeChanged?.call(null, null, null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isClearing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final borderColor = theme.isDark ? theme.border : AnimalColors.borderLight;
    final formItem = AnimalFormItemScope.of(context);

    return Focus(
      focusNode: _effectiveFocusNode,
      onFocusChange: (val) {
        if (!val) formItem?.onBlur?.call();
      },
      child: Container(
        width: _hasSeconds ? 300.0 : 250.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClockIcon(size: 18, color: theme.primary),
              const SizedBox(width: 8),
              Text(
                'Select Time',
                style: AnimalTypography.heading.copyWith(
                  fontSize: 15.0,
                  color: theme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: 160.0,
            child: Stack(
              children: [
                // Highlight active center bar
                Center(
                  child: Container(
                    height: 36.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.15),
                      borderRadius: AnimalRadii.pillBorder,
                      border: Border.all(color: theme.primaryActive.withValues(alpha: 0.4), width: 1.2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildWheel(
                        controller: _hourController,
                        items: _hours,
                        selectedVal: _selectedHour,
                        unitLabel: 'hours',
                        onSelectedItemChanged: (idx) {
                          if (_selectedHour != _hours[idx]) {
                            setState(() => _selectedHour = _hours[idx]);
                            _notifyChange();
                          }
                        },
                        theme: theme,
                      ),
                    ),
                    Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.text)),
                    Expanded(
                      child: _buildWheel(
                        controller: _minuteController,
                        items: _minutes,
                        selectedVal: _selectedMinute,
                        unitLabel: 'minutes',
                        onSelectedItemChanged: (idx) {
                          if (_selectedMinute != _minutes[idx]) {
                            setState(() => _selectedMinute = _minutes[idx]);
                            _notifyChange();
                          }
                        },
                        theme: theme,
                      ),
                    ),
                    if (_hasSeconds) ...[
                      Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.text)),
                      Expanded(
                        child: _buildWheel(
                          controller: _secondController,
                          items: _seconds,
                          selectedVal: _selectedSecond,
                          unitLabel: 'seconds',
                          onSelectedItemChanged: (idx) {
                            if (_selectedSecond != _seconds[idx]) {
                              setState(() => _selectedSecond = _seconds[idx]);
                              _notifyChange();
                            }
                          },
                          theme: theme,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (widget.showNow || widget.allowClear) ...[
            const SizedBox(height: 8.0),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 6.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.showNow)
                  Semantics(
                    button: true,
                    label: 'Select current time',
                    enabled: !widget.disabled,
                    child: TextButton(
                      onPressed: widget.disabled ? null : _handleNow,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Now',
                        style: AnimalTypography.caption.copyWith(
                          color: widget.disabled ? theme.textDisabled : theme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (widget.allowClear)
                  Semantics(
                    button: true,
                    label: 'Clear time',
                    enabled: !widget.disabled,
                    child: TextButton(
                      onPressed: widget.disabled ? null : _handleClear,
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

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required List<int> items,
    required int selectedVal,
    required String unitLabel,
    required ValueChanged<int> onSelectedItemChanged,
    required AnimalIslandTheme theme,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 36.0,
      physics: widget.disabled
          ? const NeverScrollableScrollPhysics()
          : const FixedExtentScrollPhysics(),
      onSelectedItemChanged: widget.disabled ? (_) {} : onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (context, index) {
          final val = items[index];
          final isSelected = val == selectedVal;
          return Semantics(
            label: '$val $unitLabel',
            selected: isSelected,
            child: Center(
              child: Text(
                val.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: isSelected ? 18.0 : 14.0,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? theme.text : theme.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimalTimePickerPopover extends StatefulWidget {
  final TimeOfDay? value;
  final int? second;
  final ValueChanged<TimeOfDay?>? onChanged;
  final void Function(int? hour, int? minute, int? second)? onFullTimeChanged;
  final String format;
  final int hourStep;
  final int minuteStep;
  final int secondStep;
  final String? placeholder;
  final bool showNow;
  final bool allowClear;
  final bool disabled;
  final AnimalInputStatus status;
  final FocusNode? focusNode;

  const _AnimalTimePickerPopover({
    super.key,
    this.value,
    this.second,
    this.onChanged,
    this.onFullTimeChanged,
    this.format = 'HH:mm',
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.placeholder,
    this.showNow = true,
    this.allowClear = true,
    this.disabled = false,
    this.status = AnimalInputStatus.normal,
    this.focusNode,
  });

  @override
  State<_AnimalTimePickerPopover> createState() => _AnimalTimePickerPopoverState();
}

class _AnimalTimePickerPopoverState extends State<_AnimalTimePickerPopover> {
  final MenuController _menuController = MenuController();
  FocusNode? _internalFocusNode;
  bool _isFocused = false;
  int? _internalSecond;

  FocusNode get _effectiveFocusNode {
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  @override
  void didUpdateWidget(covariant _AnimalTimePickerPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.second != widget.second) {
      _internalSecond = widget.second;
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  TimeOfDay? _getEffectiveValue(AnimalFormItemScope? formItem) {
    if (formItem != null && formItem.name != null) {
      if (formItem.currentValue is TimeOfDay) {
        return formItem.currentValue as TimeOfDay;
      } else if (formItem.currentValue == null) {
        return null;
      }
    }
    return widget.value;
  }

  String _formatTime(TimeOfDay? val) {
    if (val == null) return widget.placeholder ?? 'Select time';
    final h = val.hour.toString().padLeft(2, '0');
    final m = val.minute.toString().padLeft(2, '0');
    if (widget.format.contains('ss')) {
      final effectiveSec = widget.second ?? _internalSecond ?? 0;
      final s = effectiveSec.toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formItem = AnimalFormItemScope.of(context);
    final effectiveValue = _getEffectiveValue(formItem);
    final hasValue = effectiveValue != null;
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

    final displayText = _formatTime(effectiveValue);

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
          AnimalTimePicker(
            value: effectiveValue,
            second: widget.second ?? _internalSecond,
            format: widget.format,
            hourStep: widget.hourStep,
            minuteStep: widget.minuteStep,
            secondStep: widget.secondStep,
            showNow: widget.showNow,
            allowClear: widget.allowClear,
            disabled: widget.disabled,
            onChanged: (time) {
              widget.onChanged?.call(time);
            },
            onFullTimeChanged: (h, m, s) {
              if (s != _internalSecond) {
                setState(() => _internalSecond = s);
              }
              widget.onFullTimeChanged?.call(h, m, s);
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
                          const ClockIcon(size: 18, color: AnimalColors.textSecondary),
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
                      _TimePickerClearButton(
                        onClear: () {
                          setState(() => _internalSecond = null);
                          formItem?.onChanged?.call(null);
                          widget.onChanged?.call(null);
                          widget.onFullTimeChanged?.call(null, null, null);
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

class _TimePickerClearButton extends StatefulWidget {
  final VoidCallback onClear;

  const _TimePickerClearButton({required this.onClear});

  @override
  State<_TimePickerClearButton> createState() => _TimePickerClearButtonState();
}

class _TimePickerClearButtonState extends State<_TimePickerClearButton> {
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
        label: 'Clear time',
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

