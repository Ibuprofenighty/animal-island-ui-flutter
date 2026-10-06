import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/models/time.dart';
import '../../foundation/theme/colors.dart';
import '../../foundation/theme/components/time_picker_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/focus_ring.dart';
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

  /// Overrides for this panel, taking precedence over the theme.
  final AnimalTimePickerStyle? style;

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
    this.style,
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

  /// The wheel item extent of the last build. Wheel offsets are in pixels, so
  /// a new extent (larger type or text scale) re-centers the shown items.
  double? _itemExtent;

  /// Wheels the user is dragging or flinging. A re-centre never jumps them;
  /// they are re-centred when their scroll ends ([_recenterPending]).
  final Set<_TimeColumn> _userScrolling = <_TimeColumn>{};

  /// User-scrolled wheels whose re-centre waits for the end of their scroll.
  final Set<_TimeColumn> _recenterPending = <_TimeColumn>{};

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
      if (!_hasSeconds) {
        // A removed seconds wheel never sends its scroll end.
        _userScrolling.remove(_TimeColumn.second);
        _recenterPending.remove(_TimeColumn.second);
      }
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
  ///
  /// [recenter] jumps a wheel even when it already reports its item, which
  /// re-centers it after the item extent changed. A re-centre skips a wheel
  /// the user is scrolling and re-centres it when that scroll ends.
  void _moveWheels(
    AnimalTimeValue? target, {
    required bool animate,
    bool recenter = false,
  }) {
    final bool interrupting = _isProgrammaticScroll;
    final int batch = ++_batch;
    _isProgrammaticScroll = true;
    _select(target);
    final motion = animate ? AnimalIslandTheme.of(context).motion : null;
    final List<Future<void>> animations = <Future<void>>[];
    for (final (
          _TimeColumn column,
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
          if (_hasSeconds)
            (
              _TimeColumn.second,
              _secondController,
              _seconds.indexOf(_selectedSecond),
            ),
        ]) {
      if (!controller.hasClients) continue;
      if (recenter && _userScrolling.contains(column)) {
        _recenterPending.add(column);
        continue;
      }
      if (motion != null) {
        animations.add(
          controller.animateToItem(
            index,
            duration: motion.fast,
            curve: motion.ease,
          ),
        );
      } else if (recenter || interrupting || controller.selectedItem != index) {
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
      if (!mounted || _isProgrammaticScroll || _userScrolling.isNotEmpty) {
        return;
      }
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

  /// Re-centres the wheels on the shown time after the item extent changed,
  /// as a jump-only programmatic batch that proposes nothing. A wheel the
  /// user is scrolling keeps its offset until that scroll ends.
  void _recenterAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _moveWheels(_shownValue, animate: false, recenter: true);
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
    final ResolvedTimePickerStyle resolved = ResolvedTimePickerStyle.resolve(
      theme: theme,
      style: widget.style,
      disabled: widget.disabled,
    );
    final double itemExtent = resolved.itemExtent(
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
    );
    if (_itemExtent != null && _itemExtent != itemExtent) {
      _recenterAfterFrame();
    }
    _itemExtent = itemExtent;
    final double wheelHeight = math.max(resolved.wheelHeight, itemExtent * 3);
    final Text separator = Text(':', style: resolved.separatorStyle);

    return Focus(
      focusNode: _effectiveFocusNode,
      child: Container(
        width: _hasSeconds ? resolved.widthWithSeconds : resolved.width,
        padding: resolved.padding,
        decoration: BoxDecoration(
          color: resolved.backgroundColor,
          borderRadius: resolved.borderRadius,
          border: Border.all(
            color: resolved.borderColor,
            width: resolved.borderWidth,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimalIcon(
                  data: AnimalIcons.clock,
                  size: resolved.headerIconSize,
                  color: resolved.headerIconColor,
                ),
                SizedBox(width: resolved.headerGap),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      localizations.timePickerTitle,
                      maxLines: 1,
                      softWrap: false,
                      style: resolved.titleTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: resolved.wheelGap),
            SizedBox(
              height: wheelHeight,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: itemExtent,
                      margin: EdgeInsets.symmetric(
                        horizontal: resolved.selectionInset,
                      ),
                      decoration: BoxDecoration(
                        color: resolved.selectionBackgroundColor,
                        borderRadius: resolved.selectionBorderRadius,
                        border: Border.all(
                          color: resolved.selectionBorderColor,
                          width: resolved.selectionBorderWidth,
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
                          resolved: resolved,
                          itemExtent: itemExtent,
                        ),
                      ),
                      separator,
                      Expanded(
                        child: _buildWheel(
                          controller: _minuteController,
                          items: _minutes,
                          selectedVal: _selectedMinute,
                          unitLabel: 'minutes',
                          column: _TimeColumn.minute,
                          localizations: localizations,
                          resolved: resolved,
                          itemExtent: itemExtent,
                        ),
                      ),
                      if (_hasSeconds) ...[
                        separator,
                        Expanded(
                          child: _buildWheel(
                            controller: _secondController,
                            items: _seconds,
                            selectedVal: _selectedSecond,
                            unitLabel: 'seconds',
                            column: _TimeColumn.second,
                            localizations: localizations,
                            resolved: resolved,
                            itemExtent: itemExtent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (widget.showNow || widget.allowClear) ...[
              Padding(
                padding: resolved.dividerPadding,
                child: Divider(
                  height: resolved.dividerThickness,
                  thickness: resolved.dividerThickness,
                  color: resolved.dividerColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showNow)
                    Flexible(
                      child: InteractiveRegion(
                        onPressed: widget.disabled ? null : _handleNow,
                        enableHaptics: false,
                        disabled: widget.disabled,
                        semanticLabel: localizations.now,
                        surfaceColor: Colors.transparent,
                        padding: resolved.actionPadding,
                        child: _FooterLabel(
                          localizations.now,
                          style: resolved.nowStyle,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (widget.allowClear)
                    Flexible(
                      child: InteractiveRegion(
                        onPressed: widget.disabled ? null : _handleClear,
                        enableHaptics: false,
                        disabled: widget.disabled,
                        semanticLabel: localizations.clearTime,
                        surfaceColor: Colors.transparent,
                        padding: resolved.actionPadding,
                        child: _FooterLabel(
                          localizations.clear,
                          style: resolved.clearStyle,
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
    required ResolvedTimePickerStyle resolved,
    required double itemExtent,
  }) {
    final Widget wheel = ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: itemExtent,
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  val.toString().padLeft(2, '0'),
                  maxLines: 1,
                  softWrap: false,
                  style: resolved.itemStyle(selected: isSelected),
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
          _userScrolling.add(column);
          _handleDragStart(column);
        } else if (notification is ScrollEndNotification) {
          _userScrolling.remove(column);
          if (_recenterPending.remove(column)) _recenterAfterFrame();
          if (!_isProgrammaticScroll) _reconcileAfterFrame();
        }
        return false;
      },
      child: wheel,
    );
  }
}

/// A footer action label that scales down instead of overflowing when large
/// type or a narrow panel leaves less room than the label needs.
class _FooterLabel extends StatelessWidget {
  const _FooterLabel(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false, style: style),
  );
}

/// The one resolution path for [AnimalTimePickerStyle], shared by the panel
/// and the popover trigger.
///
/// Precedence: the instance `style`, then
/// `AnimalIslandTheme.components.timePicker`, then defaults derived from the
/// theme tokens. Text styles merge field by field across the layers.
class ResolvedTimePickerStyle {
  ResolvedTimePickerStyle._(this._theme, this._style, this._disabled);

  /// Merges [style] over the theme's time picker style for [theme].
  factory ResolvedTimePickerStyle.resolve({
    required AnimalIslandTheme theme,
    required AnimalTimePickerStyle? style,
    required bool disabled,
  }) => ResolvedTimePickerStyle._(
    theme,
    (style ?? AnimalTimePickerStyle()).merge(theme.components.timePicker),
    disabled,
  );

  final AnimalIslandTheme _theme;
  final AnimalTimePickerStyle _style;
  final bool _disabled;

  AnimalThemeColors get _colors => _theme.colors;
  bool get _dark => _colors.brightness == Brightness.dark;
  Set<WidgetState> get _states => <WidgetState>{
    if (_disabled) WidgetState.disabled,
  };

  /// Default panel and trigger border: the light border token in the light
  /// palette and the standard border token in the dark palette.
  Color get _defaultBorder => _dark ? _colors.border : _colors.borderLight;

  TextStyle _text(TextStyle base, TextStyle? override, Color color) =>
      _theme.typography.resolve(base.merge(override)).copyWith(color: color);

  // Panel.

  double get width => _style.width ?? 250;
  double get widthWithSeconds => _style.widthWithSeconds ?? 300;
  EdgeInsetsGeometry get padding =>
      _style.padding ??
      EdgeInsets.symmetric(
        horizontal: _theme.spacing.lg,
        vertical: _theme.spacing.md,
      );
  Color get backgroundColor => _style.backgroundColor ?? _colors.bgContent;
  Color get borderColor => _style.borderColor ?? _defaultBorder;
  double get borderWidth => _style.borderWidth ?? 1.5;
  BorderRadius get borderRadius =>
      _style.borderRadius ?? _theme.radii.cardBorder;
  double get headerIconSize => _style.headerIconSize ?? 18;
  Color get headerIconColor => _style.headerIconColor ?? _colors.primaryText;
  double get headerGap => _style.headerGap ?? _theme.spacing.sm;
  TextStyle get titleTextStyle => _text(
    _theme.typography.heading,
    _style.titleTextStyle,
    _style.titleTextColor?.resolve(_states) ??
        (_disabled ? _colors.textDisabled : _colors.text),
  );
  double get wheelGap => _style.wheelGap ?? _theme.spacing.md;
  double get wheelHeight => _style.wheelHeight ?? 160;
  double get minItemExtent => _style.minItemExtent ?? 36;

  /// Wheel label style; the selected label uses `typography.subheading` at
  /// weight 800 and the others `typography.body` at weight 500.
  TextStyle itemStyle({required bool selected}) {
    final Set<WidgetState> states = <WidgetState>{
      ..._states,
      if (selected) WidgetState.selected,
    };
    return _text(
      selected
          ? _theme.typography.subheading.copyWith(fontWeight: FontWeight.w800)
          : _theme.typography.body.copyWith(fontWeight: FontWeight.w500),
      selected ? _style.selectedItemTextStyle : _style.itemTextStyle,
      _style.itemTextColor?.resolve(states) ??
          (_disabled
              ? _colors.textDisabled
              : (selected ? _colors.text : _colors.textSecondary)),
    );
  }

  /// Height of one wheel item: at least [minItemExtent], and never less than
  /// the rendered height of the larger wheel label under [textScaler].
  double itemExtent({
    required TextScaler textScaler,
    required TextDirection textDirection,
  }) {
    double labelHeight = 0;
    for (final bool selected in <bool>[false, true]) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: '00',
          style: itemStyle(selected: selected),
        ),
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      labelHeight = math.max(labelHeight, painter.height);
      painter.dispose();
    }
    return math.max(minItemExtent, labelHeight);
  }

  TextStyle get separatorStyle => _text(
    _theme.typography.heading.copyWith(fontWeight: FontWeight.bold),
    _style.separatorTextStyle,
    _style.separatorTextColor ?? _colors.text,
  );
  Color get selectionBackgroundColor =>
      _style.selectionBackgroundColor ??
      _colors.primary.withValues(alpha: 0.15);
  Color get selectionBorderColor =>
      _style.selectionBorderColor ??
      _colors.primaryActive.withValues(alpha: 0.4);
  double get selectionBorderWidth => _style.selectionBorderWidth ?? 1.2;
  BorderRadius get selectionBorderRadius =>
      _style.selectionBorderRadius ?? _theme.radii.pillBorder;
  double get selectionInset => _style.selectionInset ?? _theme.spacing.xs;
  Color get dividerColor => _style.dividerColor ?? _defaultBorder;
  double get dividerThickness => _style.dividerThickness ?? 1;
  EdgeInsetsGeometry get dividerPadding =>
      _style.dividerPadding ??
      EdgeInsets.only(top: _theme.spacing.sm, bottom: _theme.spacing.xs);
  EdgeInsetsGeometry get actionPadding =>
      _style.actionPadding ??
      EdgeInsets.symmetric(horizontal: _theme.spacing.sm);
  TextStyle get nowStyle => _text(
    _theme.typography.caption.copyWith(fontWeight: FontWeight.w700),
    _style.nowTextStyle,
    _style.nowTextColor?.resolve(_states) ??
        (_disabled ? _colors.textDisabled : _colors.primaryText),
  );
  TextStyle get clearStyle => _text(
    _theme.typography.caption.copyWith(fontWeight: FontWeight.w600),
    _style.clearTextStyle,
    _style.clearTextColor?.resolve(_states) ??
        (_disabled ? _colors.textDisabled : _colors.textSecondary),
  );

  // Popover trigger.

  /// Trigger border color for the current interaction state.
  ///
  /// Error and warning take precedence over focus; the focused default is the
  /// library focus color.
  Color triggerBorderColor({
    required bool focused,
    required bool error,
    required bool warning,
  }) {
    if (warning) return _style.warningColor ?? _colors.warning;
    final Set<WidgetState> states = <WidgetState>{
      ..._states,
      if (focused) WidgetState.focused,
      if (error) WidgetState.error,
    };
    final Color? themed = _style.triggerBorderColor?.resolve(states);
    if (themed != null) return themed;
    if (error) return _colors.error;
    if (focused) return resolveFocusRing(_theme).color;
    return _defaultBorder;
  }

  Color get triggerBackgroundColor =>
      _style.triggerBackgroundColor?.resolve(_states) ??
      (_disabled
          ? (_dark ? _colors.surfaceHeader : _colors.bgInputDisabled)
          : _colors.bgInput);
  double get triggerBorderWidth => _style.triggerBorderWidth ?? 1.5;
  BorderRadius get triggerBorderRadius =>
      _style.triggerBorderRadius ?? _theme.radii.pillBorder;
  EdgeInsetsGeometry get triggerPadding =>
      _style.triggerPadding ??
      EdgeInsets.symmetric(horizontal: _theme.spacing.md);

  /// Trigger text style for a shown time ([hasValue]) or the placeholder.
  TextStyle triggerTextStyle({required bool hasValue}) => _text(
    _theme.typography.body,
    _style.triggerTextStyle,
    hasValue
        ? _style.triggerTextColor?.resolve(_states) ??
              (_disabled ? _colors.textDisabled : _colors.text)
        : _style.placeholderTextColor ?? _colors.textSecondary,
  );
  double get triggerIconSize => _style.triggerIconSize ?? 16;

  /// Color of the trigger clock icon, or of the clear icon when
  /// [clearIcon] is set (the clear icon is only shown while enabled).
  Color triggerIconColor({bool clearIcon = false}) {
    final Set<WidgetState> states = clearIcon ? <WidgetState>{} : _states;
    return _style.triggerIconColor?.resolve(states) ??
        (states.contains(WidgetState.disabled)
            ? _colors.textDisabled
            : _colors.textSecondary);
  }

  double get triggerIconGap => _style.triggerIconGap ?? _theme.spacing.sm;
}
