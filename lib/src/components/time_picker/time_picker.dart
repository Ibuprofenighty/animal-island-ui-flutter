import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/time.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../input/input.dart';
import 'time_picker_panel.dart';
import 'wheel_model.dart';

export 'time_picker_panel.dart';
export 'wheel_model.dart';

/// Animal Island time picker card with 3-column scroll wheels.
///
/// Features:
/// - Three smooth scroll columns for hours, minutes, and optional seconds
/// - Supports [hourStep], [minuteStep], and [secondStep]
/// - Supports [format] masks (e.g. 'HH:mm' or 'HH:mm:ss')
/// - Inline panel or Popover trigger with [AnimalTimePicker.popover]
/// - Unified [AnimalTimeValue] model with full hour, minute, and second support
class AnimalTimePicker extends StatelessWidget {
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

    final inputBg = widget.disabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.surfaceHeader
              : theme.colors.bgInputDisabled)
        : theme.colors.bgInput;

    final defaultBorderColor = (theme.colors.brightness == Brightness.dark)
        ? theme.colors.border
        : theme.colors.borderLight;
    final canInteract = !widget.disabled;
    Color borderColor;
    Color? glowColor;

    if (widget.status == AnimalInputStatus.error) {
      borderColor = theme.colors.error;
      glowColor = theme.colors.error.withValues(alpha: 0.35);
    } else if (widget.status == AnimalInputStatus.warning) {
      borderColor = theme.colors.warning;
      glowColor = theme.colors.warning.withValues(alpha: 0.35);
    } else if (_menuController.isOpen || _isFocused) {
      borderColor = theme.colors.focusYellow;
      glowColor = theme.colors.focusYellow.withValues(alpha: 0.45);
    } else {
      borderColor = defaultBorderColor;
      glowColor = null;
    }

    final displayText = _displayText(localizations);

    return MenuAnchor(
      controller: _menuController,
      childFocusNode: _effectiveFocusNode,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.colors.bgContent),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: theme.radii.cardBorder,
            side: BorderSide(color: borderColor, width: 1.5),
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
          onChanged: (t) {
            widget.onChanged?.call(t);
          },
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
              borderRadius: theme.radii.pillBorder,
              surfaceColor: inputBg,
              border: Border.all(color: borderColor, width: 1.5),
              extraShadows: glowColor == null
                  ? null
                  : [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                      ),
                    ],
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.md),
              onFocusChanged: (focused) => setState(() => _isFocused = focused),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16.0,
                    color: widget.disabled
                        ? theme.colors.textDisabled
                        : theme.colors.textSecondary,
                  ),
                  SizedBox(width: theme.spacing.sm),
                  Text(
                    displayText,
                    style: theme.typography.body.copyWith(
                      color: hasValue
                          ? (widget.disabled
                                ? theme.colors.textDisabled
                                : theme.colors.text)
                          : theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.allowClear && hasValue && canInteract)
              InteractiveRegion(
                onPressed: () => widget.onChanged?.call(null),
                enableHaptics: false,
                semanticLabel: localizations.clearTime,
                surfaceColor: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                child: Icon(
                  Icons.cancel_rounded,
                  size: 16.0,
                  color: theme.colors.textSecondary,
                ),
              ),
          ],
        );
      },
    );
  }
}
