import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/option_group_focus.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';

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

/// Animal Island rounded Checkbox component (C14).
class AnimalCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final bool disabled;
  final bool readOnly;
  final bool indeterminate;
  final AnimalCheckboxSize size;
  final FocusNode? focusNode;

  const AnimalCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.disabled = false,
    this.readOnly = false,
    this.indeterminate = false,
    this.size = AnimalCheckboxSize.middle,
    this.focusNode,
  });

  @override
  State<AnimalCheckbox> createState() => _AnimalCheckboxState();
}

class _AnimalCheckboxState extends State<AnimalCheckbox> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get _isDisabled =>
      widget.disabled || (widget.onChanged == null && !widget.readOnly);

  bool get _canInteract => !_isDisabled && !widget.readOnly;

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!_canInteract) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final size = widget.size;
    final isChecked = widget.value;
    final isIndeterminate = widget.indeterminate && !isChecked;

    final Color bgColor = _isDisabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.surfaceAlt
              : theme.colors.bgDisabled)
        : (isChecked || isIndeterminate
              ? theme.colors.success
              : ((theme.colors.brightness == Brightness.dark)
                    ? theme.colors.surfaceHeader
                    : theme.colors.bgInput));

    final Color borderColor = _isDisabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.border.withValues(alpha: 0.3)
              : theme.colors.borderLight)
        : (isChecked || isIndeterminate
              ? theme.colors.success
              : theme.colors.border);

    return InteractiveRegion(
      onPressed: _handleToggle,
      disabled: _isDisabled,
      readOnly: widget.readOnly,
      focusNode: _effectiveFocusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) =>
          optionGroupKeyEvent(node, event),
      onFocusChanged: (focused) => setState(() => _isFocused = focused),
      semanticButton: false,
      checked: isChecked,
      mixed: isIndeterminate,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: theme.motion.fast,
            curve: theme.motion.ease,
            width: size.boxSize,
            height: size.boxSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(size.borderRadius),
              border: Border.all(
                color: _isFocused ? theme.colors.focusYellow : borderColor,
                width: 1.8,
              ),
              boxShadow: [
                if (!_isDisabled) theme.shadows.softElevation,
                if (_isFocused)
                  BoxShadow(
                    color: theme.colors.focusYellow.withValues(alpha: 0.45),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: isChecked
                ? AnimalIcon(
                    data: AnimalIcons.check,
                    size: size.iconSize,
                    color: theme.colors.onSuccess,
                  )
                : (isIndeterminate
                      ? Container(
                          width: size.iconSize * 0.7,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: theme.colors.onSuccess,
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                        )
                      : null),
          ),
          if (widget.label != null) ...[
            SizedBox(width: theme.spacing.sm),
            Flexible(
              child: DefaultTextStyle(
                style: theme.typography.body.copyWith(
                  fontSize: size.fontSize,
                  color: _isDisabled
                      ? theme.colors.textDisabled
                      : theme.colors.text,
                ),
                child: widget.label!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
