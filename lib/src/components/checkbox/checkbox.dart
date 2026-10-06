import 'package:flutter/material.dart';

import '../../foundation/theme/components/checkbox_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/focus_ring.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/option_group_focus.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';

/// Size presets for [AnimalCheckbox].
///
/// A preset names a step; its metrics come from the active theme. See
/// [AnimalCheckboxStyle] for the values a theme or a single checkbox can
/// override.
enum AnimalCheckboxSize { small, middle, large }

/// Animal Island rounded Checkbox component (C14).
///
/// Visual overrides come from [style] and
/// `AnimalIslandTheme.components.checkbox`.
class AnimalCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final bool disabled;
  final bool readOnly;
  final bool indeterminate;

  /// Visual size tier.
  final AnimalCheckboxSize size;

  /// Overrides for this checkbox, taking precedence over the theme.
  final AnimalCheckboxStyle? style;

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
    this.style,
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
    final isChecked = widget.value;
    final isIndeterminate = widget.indeterminate && !isChecked;
    final _ResolvedCheckboxStyle resolved = _ResolvedCheckboxStyle.resolve(
      theme: theme,
      size: widget.size,
      style: widget.style,
      selected: isChecked || isIndeterminate,
      disabled: _isDisabled,
      focused: _isFocused,
    );

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
            width: resolved.boxSize,
            height: resolved.boxSize,
            decoration: BoxDecoration(
              color: resolved.fillColor,
              borderRadius: resolved.borderRadius,
              border: Border.all(
                color: resolved.borderColor,
                width: resolved.borderWidth,
              ),
              boxShadow: [
                if (!_isDisabled) resolved.shadow,
                if (_isFocused)
                  BoxShadow(
                    color: resolved.borderColor.withValues(alpha: 0.45),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: isChecked
                ? AnimalIcon(
                    data: AnimalIcons.check,
                    size: resolved.iconSize,
                    color: resolved.checkColor,
                  )
                : (isIndeterminate
                      ? Container(
                          width: resolved.iconSize * 0.7,
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: resolved.checkColor,
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                        )
                      : null),
          ),
          if (widget.label != null) ...[
            SizedBox(width: resolved.labelGap),
            Flexible(
              child: DefaultTextStyle(
                style: resolved.labelTextStyle,
                child: widget.label!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The single resolution path for checkbox visuals.
///
/// Precedence: the checkbox's own style, then the theme's size-specific style,
/// then the theme's general style, then defaults derived from theme tokens.
class _ResolvedCheckboxStyle {
  final double boxSize;
  final double iconSize;
  final double borderWidth;
  final double labelGap;
  final BorderRadius borderRadius;
  final TextStyle labelTextStyle;
  final Color fillColor;
  final Color borderColor;
  final Color checkColor;
  final BoxShadow shadow;

  const _ResolvedCheckboxStyle._({
    required this.boxSize,
    required this.iconSize,
    required this.borderWidth,
    required this.labelGap,
    required this.borderRadius,
    required this.labelTextStyle,
    required this.fillColor,
    required this.borderColor,
    required this.checkColor,
    required this.shadow,
  });

  /// Default metrics per size. Label font sizes scale `typography.body` by
  /// these registered ratios, so the standard 14 logical-pixel body gives
  /// 13/14/16.
  static ({double box, double icon, double radius, double factor}) _metrics(
    AnimalCheckboxSize size,
  ) => switch (size) {
    AnimalCheckboxSize.small => (box: 18, icon: 12, radius: 5, factor: 13 / 14),
    AnimalCheckboxSize.middle => (box: 22, icon: 14, radius: 6, factor: 1),
    AnimalCheckboxSize.large => (box: 26, icon: 18, radius: 7, factor: 16 / 14),
  };

  static _ResolvedCheckboxStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalCheckboxSize size,
    required AnimalCheckboxStyle? style,
    required bool selected,
    required bool disabled,
    required bool focused,
  }) {
    final AnimalCheckboxThemeData? themed = theme.components.checkbox;
    final AnimalCheckboxStyle? sized = switch (size) {
      AnimalCheckboxSize.small => themed?.smallStyle,
      AnimalCheckboxSize.middle => themed?.middleStyle,
      AnimalCheckboxSize.large => themed?.largeStyle,
    };
    final AnimalCheckboxStyle merged = (style ?? AnimalCheckboxStyle())
        .merge(sized)
        .merge(themed?.style);

    final colors = theme.colors;
    final bool dark = colors.brightness == Brightness.dark;
    final Set<WidgetState> states = <WidgetState>{
      if (selected) WidgetState.selected,
      if (disabled) WidgetState.disabled,
      if (focused) WidgetState.focused,
    };
    final metrics = _metrics(size);

    Color defaultFill() {
      if (disabled) return dark ? colors.surfaceAlt : colors.bgDisabled;
      if (selected) return colors.success;
      return dark ? colors.surfaceHeader : colors.bgInput;
    }

    Color defaultBorder() {
      if (focused) return resolveFocusRing(theme).color;
      if (disabled) {
        return dark ? colors.border.withValues(alpha: 0.3) : colors.borderLight;
      }
      if (selected) return colors.success;
      return colors.border;
    }

    final TextStyle labelTextStyle = theme.typography
        .resolve(
          theme.typography.body
              .apply(fontSizeFactor: metrics.factor)
              .merge(merged.labelTextStyle),
        )
        .copyWith(
          color:
              merged.labelTextColor?.resolve(states) ??
              (disabled ? colors.textDisabled : colors.text),
        );

    return _ResolvedCheckboxStyle._(
      boxSize: merged.boxSize ?? metrics.box,
      iconSize: merged.iconSize ?? metrics.icon,
      borderWidth: merged.borderWidth ?? 1.8,
      labelGap: merged.labelGap ?? theme.spacing.sm,
      borderRadius:
          merged.borderRadius ??
          BorderRadius.all(Radius.circular(metrics.radius)),
      labelTextStyle: labelTextStyle,
      fillColor: merged.fillColor?.resolve(states) ?? defaultFill(),
      borderColor: merged.borderColor?.resolve(states) ?? defaultBorder(),
      checkColor: merged.checkColor?.resolve(states) ?? colors.onSuccess,
      shadow: merged.shadow ?? theme.shadows.softElevation,
    );
  }
}

/// Item gaps of an `AnimalCheckboxGroup`, resolved over the same layers as its
/// items: the group's `style`, the size theme, the general theme, then
/// `spacing.lg` along a horizontal group or `spacing.sm` along a vertical
/// one, with `spacing.sm` between runs.
({double gap, double runGap}) resolveCheckboxGroupGaps({
  required AnimalIslandTheme theme,
  required AnimalCheckboxSize size,
  required AnimalCheckboxStyle? style,
  required Axis direction,
}) {
  final AnimalCheckboxThemeData? themed = theme.components.checkbox;
  final AnimalCheckboxStyle? sized = switch (size) {
    AnimalCheckboxSize.small => themed?.smallStyle,
    AnimalCheckboxSize.middle => themed?.middleStyle,
    AnimalCheckboxSize.large => themed?.largeStyle,
  };
  final AnimalCheckboxStyle merged = (style ?? AnimalCheckboxStyle())
      .merge(sized)
      .merge(themed?.style);
  return (
    gap:
        merged.groupGap ??
        (direction == Axis.horizontal ? theme.spacing.lg : theme.spacing.sm),
    runGap: merged.groupRunGap ?? theme.spacing.sm,
  );
}
