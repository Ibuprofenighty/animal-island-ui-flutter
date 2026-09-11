import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import 'checkbox.dart';
import '../form/form.dart';

/// Radio sizing scale matching animal-island-ui.
enum AnimalRadioSize {
  small(outerSize: 18.0, innerSize: 8.0, fontSize: 13.0),
  middle(outerSize: 22.0, innerSize: 10.0, fontSize: 14.0),
  large(outerSize: 26.0, innerSize: 12.0, fontSize: 16.0);

  final double outerSize;
  final double innerSize;
  final double fontSize;

  const AnimalRadioSize({
    required this.outerSize,
    required this.innerSize,
    required this.fontSize,
  });
}

/// Animal Island rounded Radio component.
class AnimalRadio<T> extends StatefulWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final Widget? label;
  final bool disabled;
  final AnimalRadioSize size;
  final FocusNode? focusNode;
  final Color? activeColor;

  const AnimalRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.disabled = false,
    this.size = AnimalRadioSize.middle,
    this.focusNode,
    this.activeColor,
  });

  @override
  State<AnimalRadio<T>> createState() => _AnimalRadioState<T>();
}

class _AnimalRadioGroupScope extends InheritedWidget {
  const _AnimalRadioGroupScope({required super.child});

  static bool isInGroup(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AnimalRadioGroupScope>() != null;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class _AnimalRadioState<T> extends State<AnimalRadio<T>> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode {
    if (_AnimalRadioGroupScope.isInGroup(context)) {
      return widget.focusNode ?? (_internalFocusNode ??= FocusNode());
    }
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  T? get _effectiveGroupValue {
    if (!_AnimalRadioGroupScope.isInGroup(context)) {
      final formItem = AnimalFormItemScope.of(context);
      if (formItem != null && formItem.name != null) {
        return formItem.currentValue as T?;
      }
    }
    return widget.groupValue;
  }

  bool get _isSelected => widget.value == _effectiveGroupValue;
  bool get _canInteract => !widget.disabled && widget.onChanged != null;

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleSelect() {
    if (!_canInteract) return;
    HapticFeedback.lightImpact();
    final inGroup = _AnimalRadioGroupScope.isInGroup(context);
    if (!inGroup) {
      final formItem = AnimalFormItemScope.of(context);
      formItem?.onChanged?.call(widget.value);
    }
    widget.onChanged?.call(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formItem = AnimalFormItemScope.of(context);
    final size = widget.size;
    final activeColor = widget.activeColor ?? theme.primary;

    final Color borderColor = widget.disabled
        ? (theme.isDark ? theme.border : AnimalColors.borderLight)
        : (_isSelected ? activeColor : theme.border);

    final Color bgColor = widget.disabled
        ? (theme.isDark ? theme.surfaceAlt : AnimalColors.bgDisabled)
        : theme.bgInput;

    Widget radioCircle = AnimatedContainer(
      duration: AnimalMotion.fast,
      curve: AnimalMotion.ease,
      width: size.outerSize,
      height: size.outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 2.2),
        boxShadow: [
          if (_isSelected && !widget.disabled)
            BoxShadow(
              color: activeColor.withValues(alpha: 0.35),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          if (_isFocused)
            BoxShadow(
              color: theme.focusYellow.withValues(alpha: 0.65),
              spreadRadius: 2.5,
              blurRadius: 4,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: _isSelected ? 1.0 : 0.0,
        duration: AnimalMotion.fast,
        curve: AnimalMotion.spring,
        child: Container(
          width: size.innerSize,
          height: size.innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.disabled ? theme.textDisabled : activeColor,
          ),
        ),
      ),
    );

    Widget content;
    if (widget.label == null) {
      content = radioCircle;
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          radioCircle,
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
      inMutuallyExclusiveGroup: true,
      selected: _isSelected,
      enabled: _canInteract,
      onTap: _canInteract ? _handleSelect : null,
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
            onInvoke: (_) => _handleSelect(),
          ),
        },
        child: GestureDetector(
          onTap: _handleSelect,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      ),
    );
  }
}

/// Animal Island Radio Group component.
///
/// Features:
/// - Single-select group controller
/// - Supports [Axis.horizontal] and [Axis.vertical]
/// - Automatic binding with [AnimalFormItem]
class AnimalRadioGroup<T> extends StatelessWidget {
  final List<AnimalOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final Axis direction;
  final bool disabled;
  final AnimalRadioSize size;
  final double spacing;
  final Color? activeColor;
  final FocusNode? focusNode;

  const AnimalRadioGroup({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.direction = Axis.horizontal,
    this.disabled = false,
    this.size = AnimalRadioSize.middle,
    this.spacing = 16.0,
    this.activeColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final formItem = AnimalFormItemScope.of(context);
    final effectiveGroupValue = (formItem != null && formItem.name != null)
        ? formItem.currentValue as T?
        : value;

    final children = options.map((option) {
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

      return AnimalRadio<T>(
        value: option.value,
        groupValue: effectiveGroupValue,
        disabled: isItemDisabled,
        size: size,
        activeColor: activeColor,
        label: labelWidget,
        onChanged: isItemDisabled
            ? null
            : (selectedVal) {
                formItem?.onChanged?.call(selectedVal);
                onChanged?.call(selectedVal);
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
      child: _AnimalRadioGroupScope(child: groupContent),
    );
  }
}
