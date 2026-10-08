import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/models/date.dart';
import '../../foundation/theme/components/date_picker_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/interaction/interactive_region.dart';
import '../input/input.dart';
import 'calendar_model.dart';
import 'date_picker_panel.dart';

/// Controlled civil-date selection with one inline or popover calendar panel.
class AnimalDatePicker extends StatelessWidget {
  /// Current controlled selection, or null when nothing is selected.
  ///
  /// It must be compatible with [mode]; the constructor throws an
  /// [ArgumentError] otherwise.
  final AnimalDateSelection? selection;

  /// Whether the panel picks a single date, a date range, or a month.
  ///
  /// Defaults to [AnimalDatePickerMode.date]. In month mode a selection is the
  /// first day of the chosen month.
  final AnimalDatePickerMode mode;

  /// Called with the proposed selection, or null when the user clears it.
  ///
  /// The panel does not store the value; rebuild with the new [selection].
  /// In range mode the first tap proposes an open range and the second tap
  /// proposes the completed range.
  final ValueChanged<AnimalDateSelection?>? onChanged;

  /// Earliest selectable date, inclusive, or null for no lower bound.
  ///
  /// The constructor throws an [ArgumentError] when it is after [lastDate].
  final AnimalDate? firstDate;

  /// Latest selectable date, inclusive, or null for no upper bound.
  final AnimalDate? lastDate;

  /// Returns true for additional dates that cannot be selected.
  ///
  /// A range that contains a disabled date cannot be completed.
  final bool Function(AnimalDate date)? disabledDate;

  /// Whether the footer shows a button that selects today. Defaults to true.
  final bool showToday;

  /// Whether the footer shows a button that clears the selection. Defaults to
  /// true.
  final bool allowClear;

  /// Whether every control is inert and no change is proposed. Defaults to
  /// false.
  final bool disabled;

  /// Focus node for the calendar's root, or null to use an internal one.
  ///
  /// The caller owns and disposes a supplied node.
  final FocusNode? focusNode;

  /// Source of the current instant used to determine today. Defaults to
  /// [SystemClock].
  final AnimalClock clock;

  /// Visual overrides; precedence is this style, then
  /// `AnimalIslandTheme.components.datePicker`, then token defaults.
  final AnimalDatePickerStyle? style;

  /// Creates a controlled inline date picker.
  ///
  /// Throws an [ArgumentError] when [firstDate] is after [lastDate] or
  /// [selection] does not match [mode].
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
    this.style,
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
    AnimalDatePickerStyle? style,
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
      style: style,
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
    style: style,
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
  final AnimalDatePickerStyle? style;

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
    this.style,
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
    final resolved = ResolvedDatePickerStyle.resolve(
      theme: theme,
      style: widget.style,
      disabled: widget.disabled,
    );
    final inputBackground = resolved.triggerBackgroundColor(
      disabled: widget.disabled,
    );
    final canInteract = !widget.disabled;
    final trigger = resolved.trigger(
      disabled: widget.disabled,
      focused: _menuController.isOpen || _isFocused,
      error: widget.status == AnimalInputStatus.error,
      warning: widget.status == AnimalInputStatus.warning,
    );
    final Color iconColor = resolved.triggerIconColor(
      disabled: widget.disabled,
    );
    final TextStyle triggerTextStyle = resolved.triggerTextStyle.copyWith(
      color: resolved.triggerTextColor(
        disabled: widget.disabled,
        hasValue: _hasValue,
      ),
    );

    return MenuAnchor(
      controller: _menuController,
      childFocusNode: _triggerFocusNode,
      onClose: _restoreTriggerFocus,
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
          style: widget.style,
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
          borderRadius: resolved.triggerBorderRadius,
          surfaceColor: inputBackground,
          border: Border.all(
            color: trigger.border,
            width: resolved.borderWidth,
          ),
          extraShadows: switch (trigger.glow) {
            final BoxShadow glow => <BoxShadow>[glow],
            null => null,
          },
          padding: EdgeInsets.symmetric(
            horizontal: resolved.triggerHorizontalPadding,
          ),
          onFocusChanged: (focused) => setState(() => _isFocused = focused),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: resolved.triggerIconSize,
                color: iconColor,
              ),
              SizedBox(width: resolved.triggerIconGap),
              if (constrainText)
                Flexible(
                  child: Text(
                    displayText,
                    softWrap: true,
                    style: triggerTextStyle,
                  ),
                )
              else
                Text(displayText, style: triggerTextStyle),
            ],
          ),
        );

        Widget buildClearButton() => AnimalIconAction(
          onPressed: () {
            widget.onChanged?.call(null);
            _menuController.close();
          },
          semanticLabel: localizations.clearDate,
          padding: resolved.triggerClearButtonPadding,
          borderRadius: resolved.triggerClearButtonBorderRadius,
          backgroundColor: resolved.triggerClearButtonBackgroundColor,
          icon: AnimalIcon(
            data: AnimalIcons.close,
            size: resolved.triggerIconSize,
            color: iconColor,
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

            final double clearWidth = hasClear
                ? animalIconActionWidth(
                    iconSize: resolved.triggerIconSize,
                    padding: resolved.triggerClearButtonPadding,
                    textDirection: Directionality.of(context),
                  )
                : 0.0;
            final availableTriggerWidth = constraints.maxWidth - clearWidth;
            final triggerMaxWidth = availableTriggerWidth < kAnimalMinimumTarget
                ? kAnimalMinimumTarget
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
