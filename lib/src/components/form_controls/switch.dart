import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../form/form.dart';

enum AnimalSwitchSize {
  small(width: 46.0, height: 26.0, thumbSize: 18.0, fontSize: 11.0),
  defaultSize(width: 58.0, height: 32.0, thumbSize: 24.0, fontSize: 13.0);

  final double width;
  final double height;
  final double thumbSize;
  final double fontSize;

  const AnimalSwitchSize({
    required this.width,
    required this.height,
    required this.thumbSize,
    required this.fontSize,
  });
}

/// Animal Island Switch component.
///
/// Features:
/// - Smooth spring physics with tactile haptic feedback
/// - Keyboard accessibility (Tab to focus, Space / Enter to toggle)
/// - Embedded children [checkedChildren] and [unCheckedChildren] inside the track
/// - Asynchronous [loading] indicator inside the thumb
/// - Full theme-aware styling (theme.success, theme.focusYellow)
class AnimalSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final AnimalSwitchSize size;
  final bool disabled;
  final bool loading;
  final Widget? checkedChildren;
  final Widget? unCheckedChildren;
  final FocusNode? focusNode;

  const AnimalSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = AnimalSwitchSize.defaultSize,
    this.disabled = false,
    this.loading = false,
    this.checkedChildren,
    this.unCheckedChildren,
    this.focusNode,
  });

  @override
  State<AnimalSwitch> createState() => _AnimalSwitchState();
}

class _AnimalSwitchState extends State<AnimalSwitch> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode {
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  bool get _effectiveValue {
    final formItem = AnimalFormItemScope.of(context);
    if (formItem != null && formItem.name != null) {
      if (formItem.currentValue is bool) {
        return formItem.currentValue as bool;
      } else if (formItem.currentValue == null) {
        return false;
      }
    }
    return widget.value;
  }

  bool get _canInteract => !widget.disabled && !widget.loading && widget.onChanged != null;

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!_canInteract) return;
    HapticFeedback.lightImpact();
    final formItem = AnimalFormItemScope.of(context);
    final nextVal = !_effectiveValue;
    formItem?.onChanged?.call(nextVal);
    widget.onChanged?.call(nextVal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formItem = AnimalFormItemScope.of(context);
    final size = widget.size;
    final effectiveChecked = _effectiveValue;

    final Color trackColor = widget.disabled
        ? (theme.isDark ? theme.surfaceAlt : AnimalColors.bgDisabled)
        : (effectiveChecked
            ? theme.success
            : (theme.isDark ? theme.surfaceAlt : const Color(0xFFDCD4C4)));

    final Color thumbBorderColor = widget.disabled
        ? (theme.isDark ? theme.border : AnimalColors.borderLight)
        : (effectiveChecked ? theme.success : theme.border);

    final double padding = (size.height - size.thumbSize) / 2;
    final double activeLeft = size.width - size.thumbSize - padding;
    final double inactiveLeft = padding;

    return Semantics(
      container: true,
      toggled: effectiveChecked,
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
          child: AnimatedContainer(
            duration: AnimalMotion.fast,
            curve: AnimalMotion.ease,
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(size.height / 2),
              border: Border.all(
                color: widget.disabled
                    ? AnimalColors.borderLight
                    : (theme.isDark ? theme.border : AnimalColors.borderHover),
                width: 1.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: theme.focusYellow.withValues(alpha: 0.65),
                        spreadRadius: 2.5,
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Embedded track text / icon
                if (widget.checkedChildren != null || widget.unCheckedChildren != null)
                  Positioned(
                    left: effectiveChecked ? (padding + 4.0) : null,
                    right: effectiveChecked ? null : (padding + 4.0),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: size.fontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      child: (effectiveChecked ? widget.checkedChildren : widget.unCheckedChildren) ??
                          const SizedBox.shrink(),
                    ),
                  ),

                // Thumb with spring animation
                AnimatedPositioned(
                  duration: AnimalMotion.fast,
                  curve: AnimalMotion.spring,
                  left: effectiveChecked ? activeLeft : inactiveLeft,
                  top: padding - 1.5,
                  child: Container(
                    width: size.thumbSize,
                    height: size.thumbSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFF8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: thumbBorderColor,
                        width: 2.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: widget.loading
                        ? SizedBox(
                            width: size.thumbSize * 0.55,
                            height: size.thumbSize * 0.55,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.value ? theme.success : theme.textSecondary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
