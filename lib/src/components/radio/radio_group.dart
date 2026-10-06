import 'package:flutter/widgets.dart';

import '../../foundation/models/option.dart';
import '../../foundation/theme/components/radio_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/option_group_focus.dart';
import 'radio.dart';

/// Controlled, mutually exclusive radio options with one group tab stop.
class AnimalRadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<AnimalOption<T>> options;
  final ValueChanged<T>? onChanged;
  final bool disabled;
  final bool readOnly;
  final AnimalRadioSize size;

  /// Overrides forwarded to every radio in the group.
  final AnimalRadioStyle? style;

  final Axis direction;
  final FocusNode? focusNode;
  final Color? activeColor;

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
          label: Text(option.label),
          onChanged: optionDisabled || onChanged == null
              ? null
              : (T selected) => onChanged?.call(selected),
        );
      },
    );
  }
}
