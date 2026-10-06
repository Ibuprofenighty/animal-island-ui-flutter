import 'package:flutter/widgets.dart';

import '../../foundation/models/option.dart';
import '../../foundation/theme/components/checkbox_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/option_group_focus.dart';
import 'checkbox.dart';

/// Controlled group of independently focusable checkboxes.
class AnimalCheckboxGroup<T> extends StatelessWidget {
  final List<T> value;
  final List<AnimalOption<T>> options;
  final ValueChanged<List<T>>? onChanged;
  final bool disabled;
  final bool readOnly;
  final AnimalCheckboxSize size;

  /// Overrides forwarded to every checkbox in the group.
  final AnimalCheckboxStyle? style;

  final Axis direction;
  final FocusNode? focusNode;

  AnimalCheckboxGroup({
    super.key,
    required List<T> value,
    required List<AnimalOption<T>> options,
    required this.onChanged,
    this.disabled = false,
    this.readOnly = false,
    this.size = AnimalCheckboxSize.middle,
    this.style,
    this.direction = Axis.horizontal,
    this.focusNode,
  }) : value = List<T>.unmodifiable(value),
       options = snapshotUniqueOptions<T>(
         options,
         owner: 'AnimalCheckboxGroup',
       );

  void _handleOptionToggled(T optionValue, bool isChecked) {
    if (disabled || readOnly || onChanged == null) return;
    final List<T> next = List<T>.of(value);
    if (isChecked) {
      if (!next.contains(optionValue)) next.add(optionValue);
    } else {
      next.removeWhere((T value) => value == optionValue);
    }
    onChanged!(List<T>.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    final gaps = resolveCheckboxGroupGaps(
      theme: AnimalIslandTheme.of(context),
      size: size,
      style: style,
      direction: direction,
    );
    return OptionGroupFocus<T>(
      options: options,
      direction: direction,
      roving: false,
      selectedValue: null,
      disabled: disabled || (onChanged == null && !readOnly),
      spacing: gaps.gap,
      runSpacing: gaps.runGap,
      focusNode: focusNode,
      itemBuilder: (context, option, node) {
        final bool optionDisabled = disabled || option.disabled;
        return AnimalCheckbox(
          key: ValueKey<T>(option.value),
          value: value.contains(option.value),
          disabled: optionDisabled,
          readOnly: readOnly,
          size: size,
          style: style,
          focusNode: node,
          label: Text(option.label),
          onChanged: optionDisabled || onChanged == null
              ? null
              : (bool checked) => _handleOptionToggled(option.value, checked),
        );
      },
    );
  }
}
