import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';
import 'focus_ring.dart';

/// Opacity of the default glow of a focused field, relative to its border.
const double _focusGlowAlpha = 0.45;

/// Opacity of the default glow of an error or warning field. The status
/// border is already colored, so its glow is softer than the focus glow.
const double _statusGlowAlpha = 0.35;

const double _glowBlurRadius = 4;
const double _glowSpreadRadius = 2;

/// Border and glow of one field trigger.
typedef AnimalFieldTriggerStatus = ({Color border, BoxShadow? glow});

/// The single border and glow rule of every field trigger: Input, Select,
/// DatePicker and TimePicker.
///
/// [states] holds the trigger's [WidgetState.disabled],
/// [WidgetState.focused] and [WidgetState.error] states, plus any other state
/// its styled colors resolve against. [warning] is the warning status, which
/// has no widget state; an error wins over it.
///
/// Precedence of the border:
///
/// 1. a disabled trigger: the styled [borderColor], otherwise the theme's
///    disabled border;
/// 2. the warning status: [warningColor], otherwise `warningText`;
/// 3. the styled [borderColor];
/// 4. `errorText` for an error, the focus-ring color when focused, otherwise
///    the theme's border.
///
/// A disabled trigger and an idle trigger without a status have no glow. The
/// styled [glowColor] resolves against the same [states]; otherwise the glow
/// follows the border.
AnimalFieldTriggerStatus resolveFieldTriggerStatus({
  required AnimalIslandTheme theme,
  required Set<WidgetState> states,
  required bool warning,
  required WidgetStateProperty<Color?>? borderColor,
  required Color? warningColor,
  required WidgetStateProperty<Color?>? glowColor,
}) {
  final colors = theme.colors;
  final Color? styled = borderColor?.resolve(states);
  if (states.contains(WidgetState.disabled)) {
    return (
      border:
          styled ??
          (colors.brightness == Brightness.dark
              ? colors.border.withValues(alpha: 0.3)
              : colors.borderLight),
      glow: null,
    );
  }
  final bool error = states.contains(WidgetState.error);
  final bool focused = states.contains(WidgetState.focused);
  final bool warns = warning && !error;
  final Color border = warns
      ? warningColor ?? colors.warningText
      : styled ??
            (error
                ? colors.errorText
                : focused
                ? resolveFocusRing(theme).color
                : colors.border);
  final bool status = error || warns;
  if (!focused && !status) return (border: border, glow: null);
  return (
    border: border,
    glow: BoxShadow(
      color:
          glowColor?.resolve(states) ??
          border.withValues(alpha: status ? _statusGlowAlpha : _focusGlowAlpha),
      blurRadius: _glowBlurRadius,
      spreadRadius: _glowSpreadRadius,
    ),
  );
}
