import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';
import '../form/form.dart';

/// Standard option model for options-based components (CheckboxGroup, RadioGroup, Select).
class AnimalOption<T> {
  final T value;
  final String label;
  final bool disabled;
  final Widget? icon;

  const AnimalOption({
    required this.value,
    required this.label,
    this.disabled = false,
    this.icon,
  });
}

/// Checkbox sizing scale matching animal-island-ui.
enum AnimalCheckboxSize {
  small(boxSize: 18.0, iconSize: 12.0, fontSize: 13.0, borderRadius: 5.0),
  middle(boxSize: 22.0, iconSize: 14.0, fontSize: 14.0, borderRadius: 6.0),
  large(boxSize: 26.0, iconSize: 18.0, fontSize: 16.0, borderRadius: 7.0);

  final double boxSize;
  final double iconSize;
  final double fontSize;
  final double borderRadius;

  const AnimalCheckboxSize({
    required this.boxSize,
    required this.iconSize,
    required this.fontSize,
    this.borderRadius = 6.0,
  });
}

/// Animal Island rounded Checkbox component.
class AnimalCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final bool disabled;
  final AnimalCheckboxSize size;
  final FocusNode? focusNode;

  const AnimalCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.disabled = false,
    this.size = AnimalCheckboxSize.middle,
    this.focusNode,
  });

  @override
  State<AnimalCheckbox> createState() => _AnimalCheckboxState();
}

class _AnimalCheckboxGroupScope extends InheritedWidget {
  const _AnimalCheckboxGroupScope({required super.child});

  static bool isInGroup(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AnimalCheckboxGroupScope>() != null;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class _AnimalCheckboxState extends State<AnimalCheckbox> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode {
    if (_AnimalCheckboxGroupScope.isInGroup(context)) {
      return widget.focusNode ?? (_internalFocusNode ??= FocusNode());
    }
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  bool get _effectiveValue {
    if (!_AnimalCheckboxGroupScope.isInGroup(context)) {
      final formItem = AnimalFormItemScope.of(context);
      if (formItem != null && formItem.name != null) {
        if (formItem.currentValue is bool) {
          return formItem.currentValue as bool;
        } else if (formItem.currentValue == null) {
          return false;
        }
      }
    }
    return widget.value;
  }

  bool get _canInteract => !widget.disabled && widget.onChanged != null;

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!_canInteract) return;
    HapticFeedback.lightImpact();
    final nextVal = !_effectiveValue;
    final inGroup = _AnimalCheckboxGroupScope.isInGroup(context);
    if (!inGroup) {
      final formItem = AnimalFormItemScope.of(context);
      formItem?.onChanged?.call(nextVal);
    }
    widget.onChanged?.call(nextVal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formItem = AnimalFormItemScope.of(context);
    final size = widget.size;
    final effectiveChecked = _effectiveValue;

    final Color bgColor = widget.disabled
        ? (theme.isDark ? theme.surfaceAlt : AnimalColors.bgDisabled)
        : (effectiveChecked ? theme.primary : theme.bgInput);

    final Color borderColor = widget.disabled
        ? (theme.isDark ? theme.border : AnimalColors.borderLight)
        : (effectiveChecked ? theme.primaryActive : theme.border);

    Widget box = AnimatedContainer(
      duration: AnimalMotion.fast,
      curve: AnimalMotion.ease,
      width: size.boxSize,
      height: size.boxSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size.borderRadius),
        border: Border.all(
          color: _isFocused ? theme.focusYellow : borderColor,
          width: 1.5,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: theme.focusYellow.withValues(alpha: 0.55),
              blurRadius: 4,
              spreadRadius: 2,
            )
          else if (!widget.disabled)
            BoxShadow(
              color: AnimalColors.shadowBtn.withValues(alpha: theme.isDark ? 0.2 : 0.08),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: effectiveChecked ? 1.0 : 0.0,
        duration: AnimalMotion.fast,
        curve: AnimalMotion.spring,
        child: CheckIcon(
          size: size.iconSize,
          color: Colors.white,
          strokeWidth: 4.0,
        ),
      ),
    );

    Widget content;
    if (widget.label == null) {
      content = box;
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(width: 8.0),
          DefaultTextStyle(
            style: AnimalTypography.body.copyWith(
              color: widget.disabled ? theme.textDisabled : theme.text,
              fontSize: size.fontSize,
            ),
            child: widget.label!,
          ),
        ],
      );
    }

    return Semantics(
      container: true,
      checked: effectiveChecked,
      enabled: _canInteract,
      onTap: _canInteract ? _handleToggle : null,
      child: FocusableActionDetector(
        focusNode: _effectiveFocusNode,
        enabled: _canInteract,
        mouseCursor: _canInteract ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onFocusChange: (val) {
          if (!val) formItem?.onBlur?.call();
        },
        onShowFocusHighlight: (val) => setState(() => _isFocused = val),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _handleToggle(),
          ),
        },
        child: GestureDetector(
          onTap: _handleToggle,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      ),
    );
  }
}

/// Animal Island Checkbox Group component.
///
/// Features:
/// - Group-first declarative management
/// - Supports [Axis.horizontal] and [Axis.vertical] layouts
/// - Item-level and group-level disabled control
/// - Seamless automatic binding when wrapped in [AnimalFormItem]
class AnimalCheckboxGroup<T> extends StatelessWidget {
  final List<AnimalOption<T>> options;
  final List<T> value;
  final ValueChanged<List<T>>? onChanged;
  final Axis direction;
  final bool disabled;
  final AnimalCheckboxSize size;
  final double spacing;
  final FocusNode? focusNode;

  const AnimalCheckboxGroup({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.direction = Axis.horizontal,
    this.disabled = false,
    this.size = AnimalCheckboxSize.middle,
    this.spacing = 16.0,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final formItem = AnimalFormItemScope.of(context);
    final effectiveGroupValue = (formItem != null && formItem.name != null && formItem.currentValue is List)
        ? List<T>.from(formItem.currentValue as Iterable)
        : value;

    final children = options.map((option) {
      final isSelected = effectiveGroupValue.contains(option.value);
      final isItemDisabled = disabled || option.disabled;

      Widget labelWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (option.icon != null) ...[
            option.icon!,
            const SizedBox(width: 6.0),
          ],
          Text(option.label),
        ],
      );

      return AnimalCheckbox(
        value: isSelected,
        disabled: isItemDisabled,
        size: size,
        label: labelWidget,
        onChanged: isItemDisabled
            ? null
            : (checked) {
                final updated = List<T>.from(effectiveGroupValue);
                if (checked) {
                  updated.add(option.value);
                } else {
                  updated.remove(option.value);
                }
                formItem?.onChanged?.call(updated);
                onChanged?.call(updated);
              },
      );
    }).toList();

    Widget groupContent;
    if (direction == Axis.horizontal) {
      groupContent = Wrap(
        spacing: spacing,
        runSpacing: spacing * 0.6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    } else {
      groupContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children.map((c) => Padding(
          padding: EdgeInsets.only(bottom: spacing * 0.6),
          child: c,
        )).toList(),
      );
    }

    final groupFocusNode = focusNode ?? formItem?.focusNode;

    return Focus(
      focusNode: groupFocusNode,
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          final target = groupFocusNode?.traversalChildren.firstOrNull ??
              groupFocusNode?.children.firstOrNull;
          if (target != null && !target.hasFocus) {
            target.requestFocus();
          }
        }
      },
      child: _AnimalCheckboxGroupScope(child: groupContent),
    );
  }
}
