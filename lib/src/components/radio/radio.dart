import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/option_group_focus.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';

/// Radio sizing scale matching animal-island-ui.
enum AnimalRadioSize {
  small(boxSize: 18.0, iconSize: 12.0, fontSize: 13.0, borderRadius: 12.0),
  middle(boxSize: 22.0, iconSize: 14.0, fontSize: 14.0, borderRadius: 14.0),
  large(boxSize: 26.0, iconSize: 18.0, fontSize: 16.0, borderRadius: 16.0);

  final double boxSize;
  final double iconSize;
  final double fontSize;
  final double borderRadius;

  const AnimalRadioSize({
    required this.boxSize,
    required this.iconSize,
    required this.fontSize,
    this.borderRadius = 6.0,
  });
}

/// Animal Island Kawaii Radio component (C15).
///
/// Uses the current compact 12/14/16 corner-radius contract and a check glyph.
class AnimalRadio<T> extends StatefulWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final Widget? label;
  final bool disabled;
  final bool readOnly;
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
    this.readOnly = false,
    this.size = AnimalRadioSize.middle,
    this.focusNode,
    this.activeColor,
  });

  @override
  State<AnimalRadio<T>> createState() => _AnimalRadioState<T>();
}

class _AnimalRadioState<T> extends State<AnimalRadio<T>> {
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get _isSelected => widget.value == widget.groupValue;

  bool get _isDisabled =>
      widget.disabled || (widget.onChanged == null && !widget.readOnly);

  bool get _canInteract => !_isDisabled && !widget.readOnly;

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleSelect() {
    if (!_canInteract) return;
    widget.onChanged!(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final size = widget.size;
    final isSelected = _isSelected;

    final activeTone = widget.activeColor ?? theme.colors.primary;

    final Color bgColor = _isDisabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.surfaceAlt
              : theme.colors.bgDisabled)
        : (isSelected
              ? activeTone
              : ((theme.colors.brightness == Brightness.dark)
                    ? theme.colors.surfaceHeader
                    : theme.colors.bgInput));

    final Color borderColor = _isDisabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.border.withValues(alpha: 0.3)
              : theme.colors.borderLight)
        : (isSelected ? activeTone : theme.colors.border);

    return InteractiveRegion(
      onPressed: _handleSelect,
      disabled: _isDisabled,
      readOnly: widget.readOnly,
      focusNode: _effectiveFocusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) =>
          optionGroupKeyEvent(node, event),
      onFocusChanged: (focused) => setState(() => _isFocused = focused),
      semanticButton: false,
      checked: isSelected,
      inMutuallyExclusiveGroup: true,
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
            child: isSelected
                ? AnimalIcon(
                    data: AnimalIcons.check,
                    size: size.iconSize,
                    color: widget.activeColor == null
                        ? theme.colors.onPrimary
                        : Colors.white,
                  )
                : null,
          ),
          if (widget.label != null) ...[
            SizedBox(width: theme.spacing.sm),
            DefaultTextStyle(
              style: theme.typography.body.copyWith(
                fontSize: size.fontSize,
                color: _isDisabled
                    ? theme.colors.textDisabled
                    : theme.colors.text,
              ),
              child: widget.label!,
            ),
          ],
        ],
      ),
    );
  }
}
