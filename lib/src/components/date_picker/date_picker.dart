import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/models/date.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../input/input.dart';
import 'calendar_model.dart';
import 'date_picker_panel.dart';

/// Controlled civil-date selection with one inline or popover calendar panel.
class AnimalDatePicker extends StatelessWidget {
  final AnimalDateSelection? selection;
  final AnimalDatePickerMode mode;
  final ValueChanged<AnimalDateSelection?>? onChanged;
  final AnimalDate? firstDate;
  final AnimalDate? lastDate;
  final bool Function(AnimalDate date)? disabledDate;
  final bool showToday;
  final bool allowClear;
  final bool disabled;
  final FocusNode? focusNode;
  final AnimalClock clock;

  AnimalDatePicker({
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
  }) {
    CalendarModel.validateInputs(
      mode: mode,
      selection: selection,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  /// Builds the same controlled panel inside an input-style popover.
  static Widget popover({
    Key? key,
    AnimalDateSelection? selection,
    AnimalDatePickerMode mode = AnimalDatePickerMode.date,
    ValueChanged<AnimalDateSelection?>? onChanged,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
    String? placeholder,
    bool showToday = true,
    bool allowClear = true,
    bool disabled = false,
    AnimalInputStatus status = AnimalInputStatus.normal,
    FocusNode? focusNode,
    AnimalClock clock = const SystemClock(),
  }) {
    return _AnimalDatePickerPopover(
      key: key,
      selection: selection,
      mode: mode,
      onChanged: onChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDate: disabledDate,
      placeholder: placeholder,
      showToday: showToday,
      allowClear: allowClear,
      disabled: disabled,
      status: status,
      focusNode: focusNode,
      clock: clock,
    );
  }

  @override
  Widget build(BuildContext context) => AnimalDatePickerPanel(
    selection: selection,
    mode: mode,
    onChanged: onChanged,
    firstDate: firstDate,
    lastDate: lastDate,
    disabledDate: disabledDate,
    showToday: showToday,
    allowClear: allowClear,
    disabled: disabled,
    focusNode: focusNode,
    clock: clock,
  );
}

class _AnimalDatePickerPopover extends StatefulWidget {
  final AnimalDateSelection? selection;
  final AnimalDatePickerMode mode;
  final ValueChanged<AnimalDateSelection?>? onChanged;
  final AnimalDate? firstDate;
  final AnimalDate? lastDate;
  final bool Function(AnimalDate date)? disabledDate;
  final String? placeholder;
  final bool showToday;
  final bool allowClear;
  final bool disabled;
  final AnimalInputStatus status;
  final FocusNode? focusNode;
  final AnimalClock clock;

  _AnimalDatePickerPopover({
    super.key,
    this.selection,
    this.mode = AnimalDatePickerMode.date,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.disabledDate,
    this.placeholder,
    this.showToday = true,
    this.allowClear = true,
    this.disabled = false,
    this.status = AnimalInputStatus.normal,
    this.focusNode,
    this.clock = const SystemClock(),
  }) {
    CalendarModel.validateInputs(
      mode: mode,
      selection: selection,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  @override
  State<_AnimalDatePickerPopover> createState() =>
      _AnimalDatePickerPopoverState();
}

class _AnimalDatePickerPopoverState extends State<_AnimalDatePickerPopover> {
  final MenuController _menuController = MenuController();
  FocusNode? _internalTriggerFocusNode;
  bool _isFocused = false;

  FocusNode get _triggerFocusNode =>
      widget.focusNode ?? (_internalTriggerFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalTriggerFocusNode?.dispose();
    super.dispose();
  }

  void _restoreTriggerFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _triggerFocusNode.requestFocus();
    });
  }

  String _displayText(
    AnimalLocalizations localizations,
    MaterialLocalizations materialLocalizations,
  ) {
    final placeholder =
        widget.placeholder ??
        (widget.mode == AnimalDatePickerMode.range
            ? localizations.datePickerRangePlaceholder
            : localizations.datePickerSinglePlaceholder);
    return switch (widget.selection) {
      AnimalDateSingleSelection(:final date) =>
        widget.mode == AnimalDatePickerMode.month
            ? materialLocalizations.formatMonthYear(date.toDateTime())
            : materialLocalizations.formatMediumDate(date.toDateTime()),
      AnimalDateRangeSelection(:final start, :final end) =>
        end == null
            ? '${materialLocalizations.formatMediumDate(start.toDateTime())} – …'
            : '${materialLocalizations.formatMediumDate(start.toDateTime())} – ${materialLocalizations.formatMediumDate(end.toDateTime())}',
      null => placeholder,
    };
  }

  bool get _hasValue => widget.selection != null;

  void _handlePanelChange(AnimalDateSelection? selection) {
    widget.onChanged?.call(selection);
    final shouldClose =
        selection == null ||
        widget.mode != AnimalDatePickerMode.range ||
        (selection is AnimalDateRangeSelection && selection.end != null);
    if (shouldClose) _menuController.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final displayText = _displayText(localizations, materialLocalizations);
    final inputBackground = widget.disabled
        ? (theme.colors.brightness == Brightness.dark
              ? theme.colors.surfaceHeader
              : theme.colors.bgInputDisabled)
        : theme.colors.bgInput;
    final defaultBorderColor = theme.colors.brightness == Brightness.dark
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

    return MenuAnchor(
      controller: _menuController,
      childFocusNode: _triggerFocusNode,
      onClose: _restoreTriggerFocus,
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
          selection: widget.selection,
          mode: widget.mode,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          disabledDate: widget.disabledDate,
          showToday: widget.showToday,
          allowClear: widget.allowClear,
          disabled: widget.disabled,
          clock: widget.clock,
          onChanged: _handlePanelChange,
        ),
      ],
      builder: (context, controller, child) {
        final hasClear = widget.allowClear && _hasValue && canInteract;

        Widget buildTrigger({required bool constrainText}) => InteractiveRegion(
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
          focusNode: _triggerFocusNode,
          semanticLabel: displayText,
          borderRadius: theme.radii.pillBorder,
          surfaceColor: inputBackground,
          border: Border.all(color: borderColor, width: 1.5),
          extraShadows: glowColor == null
              ? null
              : <BoxShadow>[
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
              if (constrainText)
                Flexible(
                  child: Text(
                    displayText,
                    softWrap: true,
                    style: theme.typography.body.copyWith(
                      color: _hasValue
                          ? (widget.disabled
                                ? theme.colors.textDisabled
                                : theme.colors.text)
                          : theme.colors.textSecondary,
                    ),
                  ),
                )
              else
                Text(
                  displayText,
                  style: theme.typography.body.copyWith(
                    color: _hasValue
                        ? (widget.disabled
                              ? theme.colors.textDisabled
                              : theme.colors.text)
                        : theme.colors.textSecondary,
                  ),
                ),
            ],
          ),
        );

        Widget buildClearButton() => SizedBox.square(
          dimension: 48,
          child: InteractiveRegion(
            onPressed: () {
              widget.onChanged?.call(null);
              _menuController.close();
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
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWidthBounded =
                constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
            final trigger = buildTrigger(constrainText: isWidthBounded);
            if (!isWidthBounded) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [trigger, if (hasClear) buildClearButton()],
              );
            }

            final clearWidth = hasClear ? 48.0 : 0.0;
            final availableTriggerWidth = constraints.maxWidth - clearWidth;
            final triggerMaxWidth = availableTriggerWidth < 48.0
                ? 48.0
                : availableTriggerWidth;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: triggerMaxWidth),
                  child: trigger,
                ),
                if (hasClear) buildClearButton(),
              ],
            );
          },
        );
      },
    );
  }
}
