import 'package:flutter/material.dart';

import '../../foundation/theme/components/radio_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/focus_ring.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/option_group_focus.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';

/// Size presets for [AnimalRadio].
///
/// A preset names a step; its metrics come from the active theme. See
/// [AnimalRadioStyle] for the values a theme or a single radio can override.
enum AnimalRadioSize {
  /// Smallest step: an 18 logical-pixel box by default.
  small,

  /// Default step: a 22 logical-pixel box by default.
  middle,

  /// Largest step: a 26 logical-pixel box by default.
  large,
}

/// Animal Island Kawaii Radio component (C15).
///
/// Uses the current compact 12/14/16 corner-radius contract and a check glyph.
/// Visual overrides come from [style] and `AnimalIslandTheme.components.radio`.
class AnimalRadio<T> extends StatefulWidget {
  /// Value this radio represents.
  final T value;

  /// Currently selected value; the radio is selected when it equals [value].
  final T? groupValue;

  /// Called with [value] when the user activates the radio.
  ///
  /// Null disables the radio unless [readOnly] is true.
  final ValueChanged<T>? onChanged;

  /// Content shown after the box, styled with the label text style.
  final Widget? label;

  /// Whether the radio is disabled and unfocusable. Defaults to false.
  final bool disabled;

  /// Whether the radio stays focusable but ignores activation.
  /// Defaults to false.
  final bool readOnly;

  /// Visual size tier.
  final AnimalRadioSize size;

  /// Overrides for this radio, taking precedence over the theme.
  final AnimalRadioStyle? style;

  /// Focus node owned by the caller; null uses an internal node that the
  /// radio creates and disposes.
  final FocusNode? focusNode;

  /// Selected fill and border tone for this radio, drawn with a white check.
  ///
  /// It belongs to the instance layer: the matching [style] fields win over
  /// it, and it wins over the component theme.
  final Color? activeColor;

  /// Creates a controlled radio for [value] within [groupValue].
  const AnimalRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.disabled = false,
    this.readOnly = false,
    this.size = AnimalRadioSize.middle,
    this.style,
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
    final isSelected = _isSelected;
    final _ResolvedRadioStyle resolved = _ResolvedRadioStyle.resolve(
      theme: theme,
      size: widget.size,
      style: widget.style,
      activeColor: widget.activeColor,
      selected: isSelected,
      disabled: _isDisabled,
      focused: _isFocused,
    );

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
            child: isSelected
                ? AnimalIcon(
                    data: AnimalIcons.check,
                    size: resolved.iconSize,
                    color: resolved.checkColor,
                  )
                : null,
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

/// The single resolution path for radio visuals.
///
/// Precedence: the radio's own style, then its `activeColor`, then the
/// theme's size-specific style, then the theme's general style, then defaults
/// derived from theme tokens.
class _ResolvedRadioStyle {
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

  const _ResolvedRadioStyle._({
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
  /// 13/14/16. The 12/14/16 radii keep the DD-01 near-round silhouette.
  static ({double box, double icon, double radius, double factor}) _metrics(
    AnimalRadioSize size,
  ) => switch (size) {
    AnimalRadioSize.small => (box: 18, icon: 12, radius: 12, factor: 13 / 14),
    AnimalRadioSize.middle => (box: 22, icon: 14, radius: 14, factor: 1),
    AnimalRadioSize.large => (box: 26, icon: 18, radius: 16, factor: 16 / 14),
  };

  /// Check glyph color on a caller-provided [AnimalRadio.activeColor].
  ///
  /// A registered invariant: the theme has no on-color for an arbitrary
  /// caller tone, and the RAD03 golden (`goldens/animal_radio_n15.png`) pins
  /// this white check. `checkColor` in the instance style still overrides it.
  static const Color _activeCheckColor = Color(0xFFFFFFFF);

  static _ResolvedRadioStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalRadioSize size,
    required AnimalRadioStyle? style,
    required Color? activeColor,
    required bool selected,
    required bool disabled,
    required bool focused,
  }) {
    final AnimalRadioStyle merged = _mergedRadioStyle(theme, size, style);

    final colors = theme.colors;
    final bool dark = colors.brightness == Brightness.dark;
    final Set<WidgetState> states = <WidgetState>{
      if (selected) WidgetState.selected,
      if (disabled) WidgetState.disabled,
      if (focused) WidgetState.focused,
    };
    final metrics = _metrics(size);

    // The instance activeColor applies to the enabled selected surface,
    // below the instance style and above the theme layers.
    final bool activeSurface = activeColor != null && selected && !disabled;
    final Color? activeFill = activeSurface ? activeColor : null;
    final Color? activeBorder = activeSurface && !focused ? activeColor : null;
    final Color? activeCheck = activeColor == null ? null : _activeCheckColor;

    Color defaultFill() {
      if (disabled) return dark ? colors.surfaceAlt : colors.bgDisabled;
      if (selected) return colors.primary;
      return dark ? colors.surfaceHeader : colors.bgInput;
    }

    Color defaultBorder() {
      if (focused) return resolveFocusRing(theme).color;
      if (disabled) {
        return dark ? colors.border.withValues(alpha: 0.3) : colors.borderLight;
      }
      if (selected) return colors.primary;
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

    return _ResolvedRadioStyle._(
      boxSize: merged.boxSize ?? metrics.box,
      iconSize: merged.iconSize ?? metrics.icon,
      borderWidth: merged.borderWidth ?? 1.8,
      labelGap: merged.labelGap ?? theme.spacing.sm,
      borderRadius:
          merged.borderRadius ??
          BorderRadius.all(Radius.circular(metrics.radius)),
      labelTextStyle: labelTextStyle,
      fillColor:
          style?.fillColor?.resolve(states) ??
          activeFill ??
          merged.fillColor?.resolve(states) ??
          defaultFill(),
      borderColor:
          style?.borderColor?.resolve(states) ??
          activeBorder ??
          merged.borderColor?.resolve(states) ??
          defaultBorder(),
      checkColor:
          style?.checkColor?.resolve(states) ??
          activeCheck ??
          merged.checkColor?.resolve(states) ??
          colors.onPrimary,
      shadow: merged.shadow ?? theme.shadows.softElevation,
    );
  }
}

/// Item gaps of an `AnimalRadioGroup`, resolved over the same layers as its
/// items: the group's `style`, the size theme, the general theme, then
/// `spacing.lg` along a horizontal group or `spacing.sm` along a vertical
/// one, with `spacing.sm` between runs.
({double gap, double runGap}) resolveRadioGroupGaps({
  required AnimalIslandTheme theme,
  required AnimalRadioSize size,
  required AnimalRadioStyle? style,
  required Axis direction,
}) {
  final AnimalRadioStyle merged = _mergedRadioStyle(theme, size, style);
  return (
    gap:
        merged.groupGap ??
        (direction == Axis.horizontal ? theme.spacing.lg : theme.spacing.sm),
    runGap: merged.groupRunGap ?? theme.spacing.sm,
  );
}

// The single layering of radio styles: the instance style, then the theme's
// size-specific style, then its general style.
AnimalRadioStyle _mergedRadioStyle(
  AnimalIslandTheme theme,
  AnimalRadioSize size,
  AnimalRadioStyle? style,
) {
  final AnimalRadioThemeData? themed = theme.components.radio;
  final AnimalRadioStyle? sized = switch (size) {
    AnimalRadioSize.small => themed?.smallStyle,
    AnimalRadioSize.middle => themed?.middleStyle,
    AnimalRadioSize.large => themed?.largeStyle,
  };
  return (style ?? AnimalRadioStyle()).merge(sized).merge(themed?.style);
}
