import 'package:flutter/widgets.dart';

import '../../foundation/models/option.dart';
import '../../foundation/theme/theme.dart';
import 'checkbox.dart';

/// Group wrapper for multiple [AnimalCheckbox] controls sharing a single multi-value list (C14).
class AnimalCheckboxGroup<T> extends StatelessWidget {
  final List<T> value;
  final List<AnimalOption<T>> options;
  final ValueChanged<List<T>>? onChanged;
  final bool disabled;
  final AnimalCheckboxSize size;
  final Axis direction;
  final FocusNode? focusNode;

  const AnimalCheckboxGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.disabled = false,
    this.size = AnimalCheckboxSize.middle,
    this.direction = Axis.horizontal,
    this.focusNode,
  });

  void _handleOptionToggled(T optionVal, bool isChecked) {
    if (disabled || onChanged == null) return;
    final nextList = List<T>.from(value);
    if (isChecked) {
      if (!nextList.contains(optionVal)) {
        nextList.add(optionVal);
      }
    } else {
      nextList.remove(optionVal);
    }
    onChanged!(nextList);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AnimalIslandTheme.of(context).spacing;
    final children = <Widget>[];

    for (int i = 0; i < options.length; i++) {
      final opt = options[i];
      final isSelected = value.contains(opt.value);
      final isOptionDisabled = disabled || opt.disabled;

      children.add(
        AnimalCheckbox(
          value: isSelected,
          disabled: isOptionDisabled,
          size: size,
          label: Text(opt.label),
          onChanged: isOptionDisabled
              ? null
              : (checked) => _handleOptionToggled(opt.value, checked),
        ),
      );

      if (i < options.length - 1) {
        children.add(
          direction == Axis.horizontal
              ? SizedBox(width: spacing.lg)
              : SizedBox(height: spacing.sm),
        );
      }
    }

    Widget content = direction == Axis.horizontal
        ? Wrap(spacing: spacing.lg, runSpacing: spacing.sm, children: children)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          );

    if (focusNode != null) {
      return Focus(
        focusNode: focusNode,
        skipTraversal: true,
        canRequestFocus: true,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            focusNode!.nextFocus();
          }
        },
        child: content,
      );
    }

    return content;
  }
}
