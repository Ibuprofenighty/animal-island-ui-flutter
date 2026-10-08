import 'package:flutter/widgets.dart';

import '../../foundation/models/option.dart';
import '../../foundation/theme/components/radio_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/option_group_focus.dart';
import 'radio.dart';

/// Controlled, mutually exclusive radio options with one group tab stop.
class AnimalRadioGroup<T> extends StatelessWidget {
  /// Value of the selected option; null selects none.
  final T? value;

  /// Options shown in order, stored as an unmodifiable copy.
  final List<AnimalOption<T>> options;

  /// Called with the value of an option the user activates or moves to with
  /// arrow, Home or End navigation.
  ///
  /// Null disables the group unless [readOnly] is true.
  final ValueChanged<T>? onChanged;

  /// Whether every radio is disabled. Defaults to false.
  final bool disabled;

  /// Whether the radios stay focusable but ignore activation and navigation
  /// changes. Defaults to false.
  final bool readOnly;

  /// Size step of every radio. Defaults to [AnimalRadioSize.middle].
  final AnimalRadioSize size;

  /// Overrides forwarded to every radio in the group.
  final AnimalRadioStyle? style;

  /// Layout and arrow-key axis: horizontal wraps the radios, vertical stacks
  /// them. Defaults to [Axis.horizontal].
  final Axis direction;

  /// Group focus node owned by the caller; when it gains focus, focus moves
  /// to the selected or first enabled radio. Null omits the group focus.
  final FocusNode? focusNode;

  /// Selected tone forwarded to every radio as [AnimalRadio.activeColor].
  final Color? activeColor;

  /// Creates a radio group for [options] with one tab stop.
  ///
  /// Throws an [ArgumentError] when two options share a value.
  AnimalRadioGroup({
    super.key,
    required this.value,
    required List<AnimalOption<T>> options,
    required this.onChanged,
    this.disabled = false,
    this.readOnly = false,
    this.size = AnimalRadioSize.middle,
    this.style,
    this.direction = Axis.horizontal,
    this.focusNode,
    this.activeColor,
  }) : options = snapshotUniqueOptions<T>(options, owner: 'AnimalRadioGroup');

  void _proposeNavigation(T target) {
    if (!disabled && !readOnly && onChanged != null) onChanged!(target);
  }

  @override
  Widget build(BuildContext context) {
    final gaps = resolveRadioGroupGaps(
      theme: AnimalIslandTheme.of(context),
      size: size,
      style: style,
      direction: direction,
    );
    return OptionGroupFocus<T>(
      options: options,
      direction: direction,
      roving: true,
      selectedValue: value,
      disabled: disabled || (onChanged == null && !readOnly),
      spacing: gaps.gap,
      runSpacing: gaps.runGap,
      focusNode: focusNode,
      onNavigate: readOnly || onChanged == null ? null : _proposeNavigation,
      itemBuilder: (context, option, node) {
        final bool optionDisabled = disabled || option.disabled;
        return AnimalRadio<T>(
          value: option.value,
          groupValue: value,
          disabled: optionDisabled,
          readOnly: readOnly,
          size: size,
          style: style,
          activeColor: activeColor,
          focusNode: node,
          label: optionGroupLabel(
            option,
            iconGap: AnimalIslandTheme.of(context).spacing.sm,
          ),
          onChanged: optionDisabled || onChanged == null
              ? null
              : (T selected) => onChanged?.call(selected),
        );
      },
    );
  }
}
