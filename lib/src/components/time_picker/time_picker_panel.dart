import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/models/time.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'wheel_model.dart';

/// Standalone visual wheel panel for AnimalTimePicker.
///
/// The panel is controlled: [value] is the only committed time and every user
/// change is proposed through [onChanged]. Programmatic wheel moves (an
/// external value, Now, Clear or a reset) run as one batch that never reports
/// its intermediate items; a newer batch or a user drag supersedes an older
/// one, and a value the parent does not accept is not kept on the wheels.
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

  /// Canonical clock for Now; tests and hosts inject a deterministic clock.
  final AnimalClock clock;

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
    this.clock = const SystemClock(),
  }) {
    TimeWheelModel.validateStep(hourStep, 'hourStep');
    TimeWheelModel.validateStep(minuteStep, 'minuteStep');
    TimeWheelModel.validateStep(secondStep, 'secondStep');
  }

  @override
  State<AnimalTimePickerPanel> createState() => _AnimalTimePickerPanelState();
}

enum _TimeColumn { hour, minute, second }

class _AnimalTimePickerPanelState extends State<AnimalTimePickerPanel> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;

  /// Whether the wheels show a selection; false shows the first items for a
  /// null value.
  late bool _hasSelection;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;

  /// True while a programmatic batch moves the wheels. Wheel notifications in
  /// a batch are not user input and never reach [AnimalTimePickerPanel.onChanged].
  bool _isProgrammaticScroll = false;

  /// The newest programmatic batch. A batch releases [_isProgrammaticScroll]
  /// only when all of its animations finished and it is still the newest.
  int _batch = 0;

  bool get _hasSeconds => widget.format.contains('ss');

  List<int> get _hours => TimeWheelModel.generateItems(24, widget.hourStep);
  List<int> get _minutes => TimeWheelModel.generateItems(60, widget.minuteStep);
  List<int> get _seconds => TimeWheelModel.generateItems(60, widget.secondStep);

  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  /// The time the wheels currently show, or null for no selection.
  AnimalTimeValue? get _shownValue => _hasSelection
      ? AnimalTimeValue(
          hour: _selectedHour,
          minute: _selectedMinute,
          second: _selectedSecond,
        )
      : null;

  @override
  void initState() {
    super.initState();
    _select(widget.value);
    _hourController = FixedExtentScrollController(
      initialItem: _hours.indexOf(_selectedHour),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes.indexOf(_selectedMinute),
    );
    _secondController = FixedExtentScrollController(
      initialItem: _seconds.indexOf(_selectedSecond),
    );
  }

  /// Shows [value] on the configured steps (an off-step value snaps to the
  /// nearest item), or the first items for null.
  void _select(AnimalTimeValue? value) {
    _hasSelection = value != null;
    _selectedHour = value == null
        ? _hours.first
        : TimeWheelModel.snapToStep(value.hour, _hours);
    _selectedMinute = value == null
        ? _minutes.first
        : TimeWheelModel.snapToStep(value.minute, _minutes);
    _selectedSecond = value == null
        ? _seconds.first
        : TimeWheelModel.snapToStep(value.second, _seconds);
  }

  @override
  void didUpdateWidget(covariant AnimalTimePickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.format != widget.format) {
      // A newly shown seconds wheel attaches after this build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _moveWheels(widget.value, animate: false);
      });
    }
    if (oldWidget.hourStep != widget.hourStep ||
        oldWidget.minuteStep != widget.minuteStep ||
        oldWidget.secondStep != widget.secondStep ||
        oldWidget.value != widget.value) {
      _moveWheels(widget.value, animate: false);
    }
  }

  /// Starts one programmatic batch that shows [target] (first items for null)
  /// and supersedes any older batch. Jumps finish synchronously; animations
  /// keep the batch open until every one of them completes.
  void _moveWheels(AnimalTimeValue? target, {required bool animate}) {
    final bool interrupting = _isProgrammaticScroll;
    final int batch = ++_batch;
    _isProgrammaticScroll = true;
    _select(target);
    final motion = animate ? AnimalIslandTheme.of(context).motion : null;
    final List<Future<void>> animations = <Future<void>>[];
    for (final (FixedExtentScrollController controller, int index)
        in <(FixedExtentScrollController, int)>[
          (_hourController, _hours.indexOf(_selectedHour)),
          (_minuteController, _minutes.indexOf(_selectedMinute)),
          if (_hasSeconds)
            (_secondController, _seconds.indexOf(_selectedSecond)),
        ]) {
      if (!controller.hasClients) continue;
      if (motion != null) {
        animations.add(
          controller.animateToItem(
            index,
            duration: motion.fast,
            curve: motion.ease,
          ),
        );
      } else if (interrupting || controller.selectedItem != index) {
        // A jump also stops an older batch's animation on this wheel.
        controller.jumpToItem(index);
      }
    }
    if (animations.isEmpty) {
      _endBatch(batch);
    } else {
      Future.wait(animations).whenComplete(() => _endBatch(batch));
    }
  }

  /// Releases suppression only for the newest batch; the wheels then return to
  /// [AnimalTimePickerPanel.value] if the parent did not accept what the batch
  /// proposed (for example a rejected Now).
  void _endBatch(int batch) {
    if (batch != _batch) return;
    _isProgrammaticScroll = false;
    if (mounted) _reconcileAfterFrame();
  }

  /// A user drag on [column] supersedes the running batch: the other wheels
  /// finish at their targets without reporting, then the user owns input.
  void _handleDragStart(_TimeColumn column) {
    if (!_isProgrammaticScroll) return;
    _batch++;
    for (final (
          _TimeColumn wheel,
          FixedExtentScrollController controller,
          int index,
        )
        in <(_TimeColumn, FixedExtentScrollController, int)>[
          (_TimeColumn.hour, _hourController, _hours.indexOf(_selectedHour)),
          (
            _TimeColumn.minute,
            _minuteController,
            _minutes.indexOf(_selectedMinute),
          ),
          (
            _TimeColumn.second,
            _secondController,
            _seconds.indexOf(_selectedSecond),
          ),
        ]) {
      if (wheel != column && controller.hasClients) {
        controller.jumpToItem(index);
      }
    }
    _isProgrammaticScroll = false;
  }

  void _onWheelChanged(_TimeColumn column, int idx) {
    if (_isProgrammaticScroll) return;
    switch (column) {
      case _TimeColumn.hour:
        setState(() => _selectedHour = _hours[idx]);
      case _TimeColumn.minute:
        setState(() => _selectedMinute = _minutes[idx]);
      case _TimeColumn.second:
        setState(() => _selectedSecond = _seconds[idx]);
    }
    _hasSelection = true;
    widget.onChanged?.call(_shownValue);
  }

  /// After a proposal, the wheels return to [AnimalTimePickerPanel.value] when
  /// the parent did not accept it.
  void _reconcileAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isProgrammaticScroll) return;
      final AnimalTimeValue? value = widget.value;
      final AnimalTimeValue? onSteps = value == null
          ? null
          : TimeWheelModel.snapTimeToSteps(
              time: value,
              hourStep: widget.hourStep,
              minuteStep: widget.minuteStep,
              secondStep: widget.secondStep,
            );
      if (_shownValue != onSteps) {
        setState(() => _moveWheels(widget.value, animate: false));
      }
    });
  }

  @override
  void dispose() {
    _batch++;
    _internalFocusNode?.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _handleNow() {
    if (widget.disabled) return;
    final AnimalTimeValue now = TimeWheelModel.snapTimeToSteps(
      time: AnimalTimeValue.now(clock: widget.clock),
      hourStep: widget.hourStep,
      minuteStep: widget.minuteStep,
      secondStep: widget.secondStep,
    );
    setState(() => _moveWheels(now, animate: true));
    widget.onChanged?.call(now);
    _reconcileAfterFrame();
  }

  void _handleClear() {
    if (widget.disabled) return;
    setState(() => _moveWheels(null, animate: false));
    widget.onChanged?.call(null);
    _reconcileAfterFrame();
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
                          column: _TimeColumn.hour,
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
                          column: _TimeColumn.minute,
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
                            column: _TimeColumn.second,
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
    required _TimeColumn column,
    required List<int> items,
    required int selectedVal,
    required String unitLabel,
    required AnimalLocalizations localizations,
    required AnimalIslandTheme theme,
  }) {
    final Widget wheel = ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 36.0,
      physics: widget.disabled
          ? const NeverScrollableScrollPhysics()
          : const FixedExtentScrollPhysics(),
      perspective: 0.003,
      diameterRatio: 1.2,
      onSelectedItemChanged: widget.disabled
          ? null
          : (int idx) => _onWheelChanged(column, idx),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          _handleDragStart(column);
        } else if (notification is ScrollEndNotification &&
            !_isProgrammaticScroll) {
          _reconcileAfterFrame();
        }
        return false;
      },
      child: wheel,
    );
  }
}
