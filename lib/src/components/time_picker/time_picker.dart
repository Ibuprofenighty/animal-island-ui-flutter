import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/models/time.dart';
import '../../foundation/theme/components/time_picker_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/interaction/interactive_region.dart';
import '../input/input.dart';
import 'time_picker_panel.dart';
import 'wheel_model.dart';

/// Animal Island time picker card with one scroll wheel per field of its
/// [format].
///
/// Features:
/// - Scroll wheels for hours and minutes, plus seconds when [format] has them
/// - Supports [hourStep], [minuteStep], and [secondStep]
/// - Supports [format] masks (e.g. 'HH:mm' or 'HH:mm:ss')
/// - Inline panel or Popover trigger with [AnimalTimePicker.popover]
/// - Unified [AnimalTimeValue] model with full hour, minute, and second support
/// - Visual overrides through [style] and `AnimalIslandTheme.components.timePicker`
class AnimalTimePicker extends StatelessWidget {
  /// Current controlled time, or null when no time is selected.
  ///
  /// The wheels show it snapped to the configured steps.
  final AnimalTimeValue? value;

  /// Called with the proposed time, or null when the user clears it.
  ///
  /// The picker does not store the value; rebuild with the new [value]. A
  /// value the parent does not accept is not kept on the wheels.
  final ValueChanged<AnimalTimeValue?>? onChanged;

  /// Time mask; one containing `ss` adds the seconds wheel. Defaults to
  /// `'HH:mm'`.
  final String format;

  /// Interval between hour wheel items. Defaults to 1; must be at least 1.
  final int hourStep;

  /// Interval between minute wheel items. Defaults to 1; must be at least 1.
  final int minuteStep;

  /// Interval between second wheel items. Defaults to 1; must be at least 1.
  final int secondStep;

  /// Whether the footer shows a button that selects the current time, snapped
  /// to the steps. Defaults to true.
  final bool showNow;

  /// Whether the footer shows a button that clears the time. Defaults to true.
  final bool allowClear;

  /// Whether the wheels and actions are inert and no change is proposed.
  /// Defaults to false.
  final bool disabled;

  /// Focus node for the wheel panel, or null to use an internal one.
  ///
  /// The caller owns and disposes a supplied node.
  final FocusNode? focusNode;

  /// Overrides for this picker, taking precedence over the theme.
  final AnimalTimePickerStyle? style;

  /// Canonical clock for Now.
  final AnimalClock clock;

  /// Creates a controlled inline time picker.
  ///
  /// Throws an [ArgumentError] when [hourStep], [minuteStep] or [secondStep]
  /// is less than 1.
  AnimalTimePicker({
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

  /// Factory launcher to build an interactive popover input field.
  static Widget popover({
    Key? key,
    AnimalTimeValue? value,
    ValueChanged<AnimalTimeValue?>? onChanged,
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
    AnimalTimePickerStyle? style,
    AnimalClock clock = const SystemClock(),
  }) {
    return _AnimalTimePickerPopover(
      key: key,
      value: value,
      onChanged: onChanged,
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
      style: style,
      clock: clock,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimalTimePickerPanel(
      value: value,
      onChanged: onChanged,
      format: format,
      hourStep: hourStep,
      minuteStep: minuteStep,
      secondStep: secondStep,
      showNow: showNow,
      allowClear: allowClear,
      disabled: disabled,
      focusNode: focusNode,
      style: style,
      clock: clock,
    );
  }
}

class _AnimalTimePickerPopover extends StatefulWidget {
  final AnimalTimeValue? value;
  final ValueChanged<AnimalTimeValue?>? onChanged;
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
  final AnimalTimePickerStyle? style;
  final AnimalClock clock;

  _AnimalTimePickerPopover({
    super.key,
    this.value,
    this.onChanged,
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
    this.style,
    this.clock = const SystemClock(),
  }) {
    TimeWheelModel.validateStep(hourStep, 'hourStep');
    TimeWheelModel.validateStep(minuteStep, 'minuteStep');
    TimeWheelModel.validateStep(secondStep, 'secondStep');
  }

  @override
  State<_AnimalTimePickerPopover> createState() =>
      _AnimalTimePickerPopoverState();
}

class _AnimalTimePickerPopoverState extends State<_AnimalTimePickerPopover> {
  final MenuController _menuController = MenuController();
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  String _displayText(AnimalLocalizations localizations) {
    if (widget.value != null) {
      return widget.value!.format(includeSeconds: widget.format.contains('ss'));
    }
    return widget.placeholder ?? localizations.timePickerPlaceholder;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final hasValue = widget.value != null;
    final ResolvedTimePickerStyle resolved = ResolvedTimePickerStyle.resolve(
      theme: theme,
      style: widget.style,
      disabled: widget.disabled,
    );

    final canInteract = !widget.disabled;
    final trigger = resolved.trigger(
      focused: _menuController.isOpen || _isFocused,
      error: widget.status == AnimalInputStatus.error,
      warning: widget.status == AnimalInputStatus.warning,
    );

    final displayText = _displayText(localizations);

    return MenuAnchor(
      controller: _menuController,
      childFocusNode: _effectiveFocusNode,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(resolved.backgroundColor),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: resolved.borderRadius,
            side: BorderSide(
              color: trigger.border,
              width: resolved.borderWidth,
            ),
          ),
        ),
      ),
      menuChildren: [
        AnimalTimePickerPanel(
          value: widget.value,
          format: widget.format,
          hourStep: widget.hourStep,
          minuteStep: widget.minuteStep,
          secondStep: widget.secondStep,
          showNow: widget.showNow,
          allowClear: widget.allowClear,
          disabled: widget.disabled,
          clock: widget.clock,
          style: widget.style,
          onChanged: widget.onChanged,
        ),
      ],
      builder: (context, controller, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InteractiveRegion(
              onPressed: canInteract
                  ? () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    }
                  : null,
              enableHaptics: false,
              disabled: !canInteract,
              focusNode: _effectiveFocusNode,
              semanticLabel: displayText,
              borderRadius: resolved.triggerBorderRadius,
              surfaceColor: resolved.triggerBackgroundColor,
              border: Border.all(
                color: trigger.border,
                width: resolved.triggerBorderWidth,
              ),
              extraShadows: switch (trigger.glow) {
                final BoxShadow glow => <BoxShadow>[glow],
                null => null,
              },
              padding: resolved.triggerPadding,
              onFocusChanged: (focused) => setState(() => _isFocused = focused),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: resolved.triggerIconSize,
                    color: resolved.triggerIconColor(),
                  ),
                  SizedBox(width: resolved.triggerIconGap),
                  Text(
                    displayText,
                    style: resolved.triggerTextStyle(hasValue: hasValue),
                  ),
                ],
              ),
            ),
            if (widget.allowClear && hasValue && canInteract)
              AnimalIconAction(
                onPressed: () => widget.onChanged?.call(null),
                semanticLabel: localizations.clearTime,
                padding: resolved.triggerClearButtonPadding,
                borderRadius: resolved.triggerClearButtonBorderRadius,
                backgroundColor: resolved.triggerClearButtonBackgroundColor,
                icon: AnimalIcon(
                  data: AnimalIcons.close,
                  size: resolved.triggerIconSize,
                  color: resolved.triggerIconColor(clearIcon: true),
                ),
              ),
          ],
        );
      },
    );
  }
}
