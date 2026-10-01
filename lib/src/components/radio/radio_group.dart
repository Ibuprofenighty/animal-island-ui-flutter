import 'package:flutter/widgets.dart';

import '../../foundation/models/option.dart';
import '../../foundation/theme/theme.dart';
import 'radio.dart';

/// Group wrapper for mutually exclusive [AnimalRadio] controls (C15).
class AnimalRadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<AnimalOption<T>> options;
  final ValueChanged<T>? onChanged;
  final bool disabled;
  final AnimalRadioSize size;
  final Axis direction;
  final FocusNode? focusNode;
  final Color? activeColor;

  const AnimalRadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.disabled = false,
    this.size = AnimalRadioSize.middle,
    this.direction = Axis.horizontal,
    this.focusNode,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = AnimalIslandTheme.of(context).spacing;
    final children = <Widget>[];

    for (int i = 0; i < options.length; i++) {
      final opt = options[i];
      final isOptionDisabled = disabled || opt.disabled;

      children.add(
        AnimalRadio<T>(
          value: opt.value,
          groupValue: value,
          disabled: isOptionDisabled,
          size: size,
          activeColor: activeColor,
          label: Text(opt.label),
          onChanged: isOptionDisabled ? null : onChanged,
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
