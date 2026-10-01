import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/time.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'wheel_model.dart';

/// Standalone visual wheel panel for AnimalTimePicker.
class AnimalTimePickerPanel extends StatefulWidget {
  final AnimalTimeValue? value;
  final ValueChanged<AnimalTimeValue?>? onChanged;
  final String format;
  final int hourStep;
  final int minuteStep;
  final int secondStep;
  final bool showNow;
  final bool allowClear;
  final bool disabled;
  final FocusNode? focusNode;

  AnimalTimePickerPanel({
    super.key,
    this.value,
    this.onChanged,
    this.format = 'HH:mm',
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.showNow = true,
    this.allowClear = true,
    this.disabled = false,
    this.focusNode,
  }) {
    TimeWheelModel.validateStep(hourStep, 'hourStep');
    TimeWheelModel.validateStep(minuteStep, 'minuteStep');
    TimeWheelModel.validateStep(secondStep, 'secondStep');
  }

  @override
  State<AnimalTimePickerPanel> createState() => _AnimalTimePickerPanelState();
}

class _AnimalTimePickerPanelState extends State<AnimalTimePickerPanel> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;

  bool _isProgrammaticScroll = false;

  bool get _hasSeconds => widget.format.contains('ss');

  List<int> get _hours => TimeWheelModel.generateItems(24, widget.hourStep);
  List<int> get _minutes => TimeWheelModel.generateItems(60, widget.minuteStep);
  List<int> get _seconds => TimeWheelModel.generateItems(60, widget.secondStep);

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _initFromValue(widget.value);
    _hourController = FixedExtentScrollController(
      initialItem: _hours.indexOf(_selectedHour).clamp(0, _hours.length - 1),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes
          .indexOf(_selectedMinute)
          .clamp(0, _minutes.length - 1),
    );
    _secondController = FixedExtentScrollController(
      initialItem: _seconds
          .indexOf(_selectedSecond)
          .clamp(0, _seconds.length - 1),
    );
  }

  void _initFromValue(AnimalTimeValue? val) {
    if (val != null) {
      _selectedHour = TimeWheelModel.snapToStep(val.hour, _hours);
      _selectedMinute = TimeWheelModel.snapToStep(val.minute, _minutes);
      _selectedSecond = TimeWheelModel.snapToStep(val.second, _seconds);
    } else {
      _selectedHour = _hours.first;
      _selectedMinute = _minutes.first;
      _selectedSecond = _seconds.first;
    }
  }

  @override
  void didUpdateWidget(covariant AnimalTimePickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hourStep != widget.hourStep ||
        oldWidget.minuteStep != widget.minuteStep ||
        oldWidget.secondStep != widget.secondStep ||
        oldWidget.value != widget.value) {
      _syncExternalValue(widget.value);
    }
  }

  void _syncExternalValue(AnimalTimeValue? val) {
    if (val == null) {
      _isProgrammaticScroll = true;
      _selectedHour = _hours.first;
      _selectedMinute = _minutes.first;
      _selectedSecond = _seconds.first;
      if (_hourController.hasClients) _hourController.jumpToItem(0);
      if (_minuteController.hasClients) _minuteController.jumpToItem(0);
      if (_secondController.hasClients) _secondController.jumpToItem(0);
      _isProgrammaticScroll = false;
      return;
    }

    final snappedH = TimeWheelModel.snapToStep(val.hour, _hours);
    final snappedM = TimeWheelModel.snapToStep(val.minute, _minutes);
    final snappedS = TimeWheelModel.snapToStep(val.second, _seconds);

    _isProgrammaticScroll = true;
    _selectedHour = snappedH;
    _selectedMinute = snappedM;
    _selectedSecond = snappedS;

    final hIdx = _hours.indexOf(snappedH);
    if (hIdx >= 0 &&
        _hourController.hasClients &&
        _hourController.selectedItem != hIdx) {
      _hourController.jumpToItem(hIdx);
    }
    final mIdx = _minutes.indexOf(snappedM);
    if (mIdx >= 0 &&
        _minuteController.hasClients &&
        _minuteController.selectedItem != mIdx) {
      _minuteController.jumpToItem(mIdx);
    }
    final sIdx = _seconds.indexOf(snappedS);
    if (sIdx >= 0 &&
        _secondController.hasClients &&
        _secondController.selectedItem != sIdx) {
      _secondController.jumpToItem(sIdx);
    }
    _isProgrammaticScroll = false;
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    if (_isProgrammaticScroll) return;
    final time = AnimalTimeValue(
      hour: _selectedHour,
      minute: _selectedMinute,
      second: _selectedSecond,
    );
    widget.onChanged?.call(time);
  }

  void _handleNow() {
    if (widget.disabled) return;
    final motion = AnimalIslandTheme.of(context).motion;
    final now = AnimalTimeValue.now();
    final snapped = TimeWheelModel.snapTimeToSteps(
      time: now,
      hourStep: widget.hourStep,
      minuteStep: widget.minuteStep,
      secondStep: widget.secondStep,
    );

    _isProgrammaticScroll = true;
    _selectedHour = snapped.hour;
    _selectedMinute = snapped.minute;
    _selectedSecond = snapped.second;

    final hIdx = _hours.indexOf(snapped.hour);
    final mIdx = _minutes.indexOf(snapped.minute);
    final sIdx = _seconds.indexOf(snapped.second);

    if (hIdx >= 0 && _hourController.hasClients) {
      _hourController.animateToItem(
        hIdx,
        duration: motion.fast,
        curve: motion.ease,
      );
    }
    if (mIdx >= 0 && _minuteController.hasClients) {
      _minuteController.animateToItem(
        mIdx,
        duration: motion.fast,
        curve: motion.ease,
      );
    }
    if (sIdx >= 0 && _hasSeconds && _secondController.hasClients) {
      _secondController.animateToItem(
        sIdx,
        duration: motion.fast,
        curve: motion.ease,
      );
    }
    _isProgrammaticScroll = false;

    setState(() {});
    widget.onChanged?.call(snapped);
  }

  void _handleClear() {
    if (widget.disabled) return;
    _isProgrammaticScroll = true;
    _selectedHour = _hours.first;
    _selectedMinute = _minutes.first;
    _selectedSecond = _seconds.first;
    if (_hourController.hasClients) {
      _hourController.jumpToItem(0);
    }
    if (_minuteController.hasClients) {
      _minuteController.jumpToItem(0);
    }
    if (_secondController.hasClients && _hasSeconds) {
      _secondController.jumpToItem(0);
    }
    _isProgrammaticScroll = false;

    setState(() {});
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final borderColor = (theme.colors.brightness == Brightness.dark)
        ? theme.colors.border
        : theme.colors.borderLight;

    return Focus(
      focusNode: _effectiveFocusNode,
      child: Container(
        width: _hasSeconds ? 300.0 : 250.0,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        decoration: BoxDecoration(
          color: theme.colors.bgContent,
          borderRadius: theme.radii.cardBorder,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimalIcon(
                  data: AnimalIcons.clock,
                  size: 18,
                  color: theme.colors.primaryText,
                ),
                SizedBox(width: theme.spacing.sm),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      localizations.timePickerTitle,
                      maxLines: 1,
                      softWrap: false,
                      style: theme.typography.heading.copyWith(
                        color: widget.disabled
                            ? theme.colors.textDisabled
                            : theme.colors.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: theme.spacing.md),
            SizedBox(
              height: 160.0,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 36.0,
                      margin: EdgeInsets.symmetric(
                        horizontal: theme.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.15),
                        borderRadius: theme.radii.pillBorder,
                        border: Border.all(
                          color: theme.colors.primaryActive.withValues(
                            alpha: 0.4,
                          ),
                          width: 1.2,
                        ),
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
                          localizations: localizations,
                          theme: theme,
                        ),
                      ),
                      Text(
                        ':',
                        style: theme.typography.heading.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colors.text,
                        ),
                      ),
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
                          localizations: localizations,
                          theme: theme,
                        ),
                      ),
                      if (_hasSeconds) ...[
                        Text(
                          ':',
                          style: theme.typography.heading.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.text,
                          ),
                        ),
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
                            localizations: localizations,
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
              SizedBox(height: theme.spacing.sm),
              Divider(height: 1, color: borderColor),
              SizedBox(height: theme.spacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showNow)
                    InteractiveRegion(
                      onPressed: widget.disabled ? null : _handleNow,
                      enableHaptics: false,
                      disabled: widget.disabled,
                      semanticLabel: localizations.now,
                      surfaceColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing.sm,
                      ),
                      child: Text(
                        localizations.now,
                        style: theme.typography.caption.copyWith(
                          color: widget.disabled
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
                      semanticLabel: localizations.clearTime,
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

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required List<int> items,
    required int selectedVal,
    required String unitLabel,
    required ValueChanged<int> onSelectedItemChanged,
    required AnimalLocalizations localizations,
    required AnimalIslandTheme theme,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 36.0,
      physics: widget.disabled
          ? const NeverScrollableScrollPhysics()
          : const FixedExtentScrollPhysics(),
      perspective: 0.003,
      diameterRatio: 1.2,
      onSelectedItemChanged: widget.disabled ? null : onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (context, index) {
          final val = items[index];
          final isSelected = val == selectedVal;
          return Center(
            child: Semantics(
              label: localizations.timePickerWheelValue(val, unitLabel),
              selected: isSelected,
              child: Text(
                val.toString().padLeft(2, '0'),
                style:
                    (isSelected
                            ? theme.typography.subheading
                            : theme.typography.body)
                        .copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: widget.disabled
                              ? theme.colors.textDisabled
                              : (isSelected
                                    ? theme.colors.text
                                    : theme.colors.textSecondary),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
