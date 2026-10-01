import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/date.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../input/input.dart';
import 'date_picker_panel.dart';

export 'calendar_model.dart';
export 'date_picker_panel.dart';

/// Animal Island calendar card date picker.
///
/// Features:
/// - Single date or [range] selection mode with continuous citrus ribbon strip
/// - Date or [month] picker mode
/// - Custom [disabledDate] predicate
/// - Bottom quick [showToday] and [allowClear] buttons
/// - Inline panel or Popover trigger with [AnimalDatePicker.popover]
class AnimalDatePicker extends StatelessWidget {
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
    AnimalDate? value,
    AnimalDateRange? rangeValue,
    bool range = false,
    AnimalDatePickerMode picker = AnimalDatePickerMode.date,
    ValueChanged<AnimalDate?>? onChanged,
    ValueChanged<AnimalDateRange?>? onRangeChanged,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
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
  Widget build(BuildContext context) {
    return AnimalDatePickerPanel(
      value: value,
      rangeValue: rangeValue,
      range: range,
      picker: picker,
      onChanged: onChanged,
      onRangeChanged: onRangeChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDate: disabledDate,
      showToday: showToday,
      allowClear: allowClear,
      disabled: disabled,
      focusNode: focusNode,
    );
  }
}

class _AnimalDatePickerPopover extends StatefulWidget {
  final AnimalDate? value;
  final AnimalDateRange? rangeValue;
  final bool range;
  final AnimalDatePickerMode picker;
  final ValueChanged<AnimalDate?>? onChanged;
  final ValueChanged<AnimalDateRange?>? onRangeChanged;
  final AnimalDate? firstDate;
  final AnimalDate? lastDate;
  final bool Function(AnimalDate date)? disabledDate;
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
  State<_AnimalDatePickerPopover> createState() =>
      _AnimalDatePickerPopoverState();
}

class _AnimalDatePickerPopoverState extends State<_AnimalDatePickerPopover> {
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

  String _displayText(
    AnimalLocalizations localizations,
    MaterialLocalizations materialLocalizations,
  ) {
    if (widget.range) {
      if (widget.rangeValue != null) {
        return '${materialLocalizations.formatMediumDate(widget.rangeValue!.start.toDateTime())} – ${materialLocalizations.formatMediumDate(widget.rangeValue!.end.toDateTime())}';
      }
      return widget.placeholder ?? localizations.datePickerRangePlaceholder;
    } else {
      if (widget.value != null) {
        return materialLocalizations.formatMediumDate(
          widget.value!.toDateTime(),
        );
      }
      return widget.placeholder ?? localizations.datePickerSinglePlaceholder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final hasValue = widget.range
        ? widget.rangeValue != null
        : widget.value != null;

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

    final displayText = _displayText(localizations, materialLocalizations);

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
        AnimalDatePickerPanel(
          value: widget.value,
          rangeValue: widget.rangeValue,
          range: widget.range,
          picker: widget.picker,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          disabledDate: widget.disabledDate,
          showToday: widget.showToday,
          allowClear: widget.allowClear,
          disabled: widget.disabled,
          onChanged: (d) {
            widget.onChanged?.call(d);
            if (!widget.range) {
              _menuController.close();
            }
          },
          onRangeChanged: (r) {
            widget.onRangeChanged?.call(r);
            _menuController.close();
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
                    Icons.calendar_today_rounded,
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
                onPressed: () {
                  widget.onChanged?.call(null);
                  widget.onRangeChanged?.call(null);
                },
                enableHaptics: false,
                semanticLabel: localizations.clearDate,
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
