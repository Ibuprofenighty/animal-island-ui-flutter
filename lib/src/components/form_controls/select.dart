import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';
import 'checkbox.dart';
import 'input.dart';
import '../form/form.dart';

typedef AnimalSelectOption<T> = AnimalOption<T>;

/// Animal Island Pill Dropdown / Select component.
///
/// Features:
/// - Smooth MenuAnchor popover dropdown
/// - Option-level [disabled] support
/// - Quick clear button [allowClear]
/// - Automatic binding with [AnimalFormItem]
class AnimalSelect<T> extends StatefulWidget {
  final T? value;
  final List<AnimalOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String placeholder;
  final bool disabled;
  final bool allowClear;
  final AnimalInputStatus status;
  final FocusNode? focusNode;

  const AnimalSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Please select',
    this.disabled = false,
    this.allowClear = false,
    this.status = AnimalInputStatus.normal,
    this.focusNode,
  });

  @override
  State<AnimalSelect<T>> createState() => _AnimalSelectState<T>();
}

class _AnimalSelectState<T> extends State<AnimalSelect<T>> {
  final MenuController _controller = MenuController();
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode {
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formItem = AnimalFormItemScope.of(context);
    final effectiveStatus = (widget.status == AnimalInputStatus.normal && formItem?.hasError == true)
        ? AnimalInputStatus.error
        : widget.status;
    final effectiveValue = (formItem != null && formItem.name != null)
        ? formItem.currentValue as T?
        : widget.value;
    final selectedOption = widget.options.cast<AnimalOption<T>?>().firstWhere(
          (o) => o?.value == effectiveValue,
          orElse: () => null,
        );

    final inputBg = widget.disabled
        ? (theme.isDark ? theme.surfaceHeader : AnimalColors.bgInputDisabled)
        : theme.bgInput;

    final defaultBorderColor = theme.isDark ? theme.border : AnimalColors.borderLight;
    final canInteract = !widget.disabled && widget.onChanged != null;

    Color borderColor;
    Color? glowColor;

    if (effectiveStatus == AnimalInputStatus.error) {
      borderColor = theme.error;
      glowColor = theme.error.withValues(alpha: 0.35);
    } else if (effectiveStatus == AnimalInputStatus.warning) {
      borderColor = theme.warning;
      glowColor = theme.warning.withValues(alpha: 0.35);
    } else if (_controller.isOpen || _isFocused) {
      borderColor = theme.focusYellow;
      glowColor = theme.focusYellow.withValues(alpha: 0.45);
    } else {
      borderColor = defaultBorderColor;
      glowColor = null;
    }

    return MenuAnchor(
      controller: _controller,
      onClose: () {
        setState(() {});
        formItem?.onBlur?.call();
      },
      onOpen: () => setState(() {}),
      builder: (context, controller, child) {
        return Semantics(
          button: true,
          enabled: canInteract,
          label: selectedOption?.label ?? widget.placeholder,
          child: FocusableActionDetector(
            focusNode: _effectiveFocusNode,
            enabled: canInteract,
            mouseCursor: canInteract ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
            onFocusChange: (val) {
              if (!val) formItem?.onBlur?.call();
            },
            onShowFocusHighlight: (val) => setState(() => _isFocused = val),
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  if (canInteract) {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  }
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTap: () {
                if (!canInteract) return;
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: AnimatedContainer(
                duration: AnimalMotion.fast,
                curve: AnimalMotion.ease,
                height: 48.0,
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: AnimalRadii.pillBorder,
                  border: Border.all(
                    color: borderColor,
                    width: 1.8,
                  ),
                  boxShadow: glowColor != null
                      ? [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (selectedOption?.icon != null) ...[
                            selectedOption!.icon!,
                            const SizedBox(width: 8.0),
                          ],
                          Flexible(
                            child: Text(
                              selectedOption?.label ?? widget.placeholder,
                              overflow: TextOverflow.ellipsis,
                              style: AnimalTypography.body.copyWith(
                                color: selectedOption != null
                                    ? (widget.disabled ? theme.textDisabled : theme.text)
                                    : theme.textDisabled,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.allowClear && selectedOption != null && canInteract) ...[
                          _SelectClearButton(
                            onClear: () {
                              formItem?.onChanged?.call(null);
                              widget.onChanged?.call(null);
                            },
                          ),
                        ],
                        AnimatedRotation(
                          turns: controller.isOpen ? 0.5 : 0.0,
                          duration: AnimalMotion.fast,
                          child: LeafIcon(size: 16, color: theme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.bgContent),
        elevation: const WidgetStatePropertyAll(8.0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: AnimalRadii.cardBorder,
            side: BorderSide(color: defaultBorderColor, width: 1.5),
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(8.0)),
      ),
      menuChildren: widget.options.map((opt) {
        final isItemActive = opt.value == effectiveValue;
        final isOptDisabled = widget.disabled || opt.disabled;

        return MenuItemButton(
          onPressed: isOptDisabled
              ? null
              : () {
                  formItem?.onChanged?.call(opt.value);
                  widget.onChanged?.call(opt.value);
                  formItem?.onBlur?.call();
                },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              isItemActive
                  ? (theme.isDark ? theme.primary.withValues(alpha: 0.25) : AnimalColors.primaryBg)
                  : Colors.transparent,
            ),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AnimalRadii.pillBorder),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            ),
          ),
          leadingIcon: opt.icon,
          child: Text(
            opt.label,
            style: AnimalTypography.body.copyWith(
              color: isOptDisabled
                  ? theme.textDisabled
                  : (isItemActive ? theme.primaryActive : theme.text),
              fontWeight: isItemActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SelectClearButton extends StatefulWidget {
  final VoidCallback onClear;

  const _SelectClearButton({required this.onClear});

  @override
  State<_SelectClearButton> createState() => _SelectClearButtonState();
}

class _SelectClearButtonState extends State<_SelectClearButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (val) => setState(() => _isFocused = val),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onClear();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        label: 'Clear selection',
        child: GestureDetector(
          onTap: widget.onClear,
          child: Container(
            padding: const EdgeInsets.only(right: 6.0),
            decoration: _isFocused
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.focusYellow.withValues(alpha: 0.55),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            child: const CloseIcon(size: 14, color: AnimalColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
