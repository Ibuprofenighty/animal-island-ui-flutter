import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../foundation/theme/theme.dart';

/// Sizing scales for [AnimalSwitch].
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

/// Animal Island Switch component (C13).
///
/// Features:
/// - Smooth spring physics with tactile haptic feedback
/// - Keyboard accessibility (Tab to focus, Space / Enter to toggle)
/// - Embedded children [checkedChildren] and [unCheckedChildren] inside the track
/// - Asynchronous [loading] indicator inside the thumb
/// - Full theme-aware styling with sunken track
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

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get _canInteract =>
      !widget.disabled && !widget.loading && widget.onChanged != null;

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
    final effectiveChecked = widget.value;

    final Color trackColor = widget.disabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.surfaceAlt
              : theme.colors.bgDisabled)
        : (effectiveChecked ? theme.colors.success : theme.colors.bgSecondary);

    final Color thumbBorderColor = widget.disabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.border
              : theme.colors.borderLight)
        : (effectiveChecked
              ? theme.colors.success
              : ((theme.colors.brightness == Brightness.dark)
                    ? theme.colors.border
                    : theme.colors.borderLight));

    final double padding = (size.height - size.thumbSize) / 2;
    final double activeLeft = size.width - size.thumbSize - padding;
    final double inactiveLeft = padding;

    return InteractiveRegion(
      onPressed: _handleToggle,
      disabled: !_canInteract,
      focusNode: _effectiveFocusNode,
      onFocusChanged: (focused) => setState(() => _isFocused = focused),
      semanticButton: false,
      semanticLabel: AnimalLocalizations.of(context)!.switchSemanticLabel,
      toggled: effectiveChecked,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.height / 2),
          border: _isFocused
              ? Border.all(color: theme.colors.focusYellow, width: 2.0)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sunken track
            AnimatedContainer(
              duration: theme.motion.normal,
              curve: theme.motion.ease,
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(size.height / 2),
                border: Border.all(
                  color: widget.disabled
                      ? ((theme.colors.brightness == Brightness.dark)
                            ? theme.colors.border
                            : theme.colors.borderLight)
                      : (effectiveChecked
                            ? theme.colors.success
                            : ((theme.colors.brightness == Brightness.dark)
                                  ? theme.colors.border
                                  : theme.colors.borderLight)),
                  width: 1.5,
                ),
              ),
            ),

            // In-track children
            if (widget.checkedChildren != null && effectiveChecked)
              Positioned(
                left: theme.spacing.sm,
                child: DefaultTextStyle(
                  style: theme.typography.body.copyWith(
                    color: theme.colors.onSuccess,
                    fontSize: size.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  child: widget.checkedChildren!,
                ),
              ),
            if (widget.unCheckedChildren != null && !effectiveChecked)
              Positioned(
                right: theme.spacing.sm,
                child: DefaultTextStyle(
                  style: theme.typography.body.copyWith(
                    color: theme.colors.textSecondary,
                    fontSize: size.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  child: widget.unCheckedChildren!,
                ),
              ),

            // Thumb
            AnimatedPositioned(
              duration: theme.motion.normal,
              curve: theme.motion.spring,
              left: effectiveChecked ? activeLeft : inactiveLeft,
              child: Container(
                width: size.thumbSize,
                height: size.thumbSize,
                decoration: BoxDecoration(
                  color: widget.disabled
                      ? theme.colors.surfaceHeader
                      : theme.colors.bgContent,
                  shape: BoxShape.circle,
                  border: Border.all(color: thumbBorderColor, width: 1.2),
                  boxShadow: [theme.shadows.softElevation],
                ),
                alignment: Alignment.center,
                child: widget.loading
                    ? SizedBox(
                        width: size.thumbSize * 0.6,
                        height: size.thumbSize * 0.6,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveChecked
                                ? theme.colors.onSuccess
                                : theme.colors.textSecondary,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
