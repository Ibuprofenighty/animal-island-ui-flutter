import '../foundation/theme.dart';
import 'focus_outline.dart';

import 'package:flutter/material.dart';

import '../foundation/size.dart';
import '../foundation/field_status.dart';
import 'action_surface.dart';

/// Shared date/time trigger anatomy. It owns no value or open state.
class PickerTrigger extends StatelessWidget {
  const PickerTrigger({
    super.key,
    required this.text,
    required this.label,
    required this.hasValue,
    required this.open,
    required this.disabled,
    required this.size,
    required this.status,
    required this.icon,
    required this.onActivate,
    this.onClear,
    this.valueContent,
    this.onKeyboardActivate,
    this.clearLabel = '清除',
    this.focusNode,
  });
  final String text, label, clearLabel;
  final bool hasValue, open, disabled;
  final IslandSize size;
  final IslandFieldStatus status;
  final Widget icon;

  /// Opaque value display; inherits the trigger typography. No input controls.
  final Widget? valueContent;
  final VoidCallback onActivate;
  final VoidCallback? onClear, onKeyboardActivate;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    final (height, padding, font) = switch (size) {
      IslandSize.small => (32.0, 14.0, 12.0),
      IslandSize.middle => (40.0, 18.0, 14.0),
      IslandSize.large => (48.0, 22.0, 16.0),
    };
    return ActionSurface(
      expanded: open,
      focusNode: focusNode,
      onKeyboardActivate: onKeyboardActivate,
      label: label,
      onActivate: disabled ? null : onActivate,
      builder: (_, states) {
        // Reference underlines on the owned #fffbe7 fill: `.trigger-error`
        // #c94444 (4.6:1); `.trigger-warning` #dba90e fails 3:1 and deepens in
        // hue to #af8600 (3.2:1). Hover/focus #c4b89e and open #e0b800 are
        // decorative cues under the 1.5px outline, so they keep the reference.
        final Color? shadow = disabled
            ? null
            : switch (status) {
                IslandFieldStatus.error => const Color(0xffc94444),
                IslandFieldStatus.warning => const Color(0xffaf8600),
                IslandFieldStatus.normal =>
                  open
                      ? const Color(0xffe0b800)
                      : states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.focused)
                      ? const Color(0xffc4b89e)
                      : null,
              };
        // Reference `.value`/`.placeholder` are `flex: 1` inside a
        // shrink-to-fit trigger: hug content under loose constraints, and let
        // the value slot take the free width (icon at the right edge) when the
        // parent fixes the width.
        return Opacity(
          opacity: disabled ? .6 : 1,
          child: IntrinsicWidth(
            child: Container(
              constraints: BoxConstraints(minHeight: height),
              foregroundDecoration: FocusOutline(
                const StadiumBorder(),
                states.contains(WidgetState.focused)
                    ? IslandTokens.light.focus
                    : IslandTokens.light.outline,
                width: 1.5,
                offset: -1.5,
              ),
              padding: EdgeInsets.symmetric(horizontal: padding),
              decoration: BoxDecoration(
                color: Color(disabled ? 0xffece8dc : 0xfffffbe7),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  if (shadow != null)
                    BoxShadow(color: shadow, offset: const Offset(0, 3)),
                  if (open && !disabled)
                    const BoxShadow(color: Color(0x26ffcc00), spreadRadius: 3),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: DefaultTextStyle.of(context).style.merge(
                        TextStyle(
                          fontSize: font,
                          height: 1.5,
                          letterSpacing: font * .01,
                          fontWeight: hasValue
                              ? FontWeight.w500
                              : FontWeight.w400,
                          // Reference `.wrapper-disabled .value/.placeholder`
                          // #c4b89e; disabled controls are contrast-exempt.
                          color: disabled
                              ? const Color(0xffc4b89e)
                              : hasValue
                              ? IslandTokens.light.ink
                              : IslandTokens.light.muted,
                        ),
                      ),
                      child: valueContent ?? Text(text),
                    ),
                  ),
                  if (onClear != null && !disabled && hasValue)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ActionSurface(
                        label: clearLabel,
                        onActivate: onClear,
                        builder: (_, states) => Container(
                          width: 20,
                          height: 20,
                          foregroundDecoration: FocusOutline(
                            const CircleBorder(),
                            states.contains(WidgetState.focused)
                                ? IslandTokens.light.focus
                                : Colors.transparent,
                            width: 2,
                            offset: 0,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: states.contains(WidgetState.hovered)
                                ? const Color(0x1a725d42)
                                : null,
                          ),
                          child: ExcludeSemantics(
                            // Reference `.clear:hover` #725d42 (6.0:1);
                            // the failing rest #c4b89e keeps the muted role.
                            child: Text(
                              '×',
                              style: TextStyle(
                                color: states.contains(WidgetState.hovered)
                                    ? const Color(0xff725d42)
                                    : IslandTokens.light.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconTheme(
                    data: IconThemeData(
                      size: 14,
                      color: IslandTokens.light.muted,
                    ),
                    child: icon,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Date/time picker focus policy. A scope-only blur has no external control
/// target; outside pointer dismissal remains owned by AnchoredPanel.
class PickerFocusBoundary extends StatelessWidget {
  const PickerFocusBoundary({
    super.key,
    required this.onKeyEvent,
    required this.onFocusExit,
    required this.child,
  });
  final FocusOnKeyEventCallback onKeyEvent;
  final VoidCallback onFocusExit;
  final Widget child;

  @override
  Widget build(BuildContext context) => Focus(
    includeSemantics: false,
    canRequestFocus: false,
    onKeyEvent: onKeyEvent,
    onFocusChange: (inside) {
      final target = FocusManager.instance.primaryFocus;
      if (!inside && target != null && target is! FocusScopeNode) onFocusExit();
    },
    child: child,
  );
}
