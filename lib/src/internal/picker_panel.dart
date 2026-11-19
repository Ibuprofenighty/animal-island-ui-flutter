import 'focus_outline.dart';
import '../foundation/recipes/picker.dart';
import '../foundation/theme.dart';

import 'package:flutter/material.dart';

import 'action_surface.dart';

class PickerPanel extends StatelessWidget {
  const PickerPanel({
    super.key,
    required this.child,
    required this.footer,
    this.borderWidth = 1,
  });
  final Widget child;

  /// Null draws the panel without the footer and its divider.
  final Widget? footer;
  final double borderWidth;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: PickerColors.panelFill,
      border: Border.all(
        color: PickerColors.panelBorder,
        width: IslandTheme.borderWidth(context, borderWidth),
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: PickerColors.panelShadow,
          offset: Offset(0, 6),
          blurRadius: 18,
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        if (footer != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: PickerColors.footerDivider),
              ),
            ),
            child: footer,
          ),
      ],
    ),
  );
}

class PickerFooterAction extends StatelessWidget {
  const PickerFooterAction(
    this.label, {
    super.key,
    required this.onPressed,
    this.primary = false,
    this.padding,
    this.fontSize = 12,
    this.primaryHoverColor,
  });
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final EdgeInsets? padding;
  final double fontSize;
  final Color? primaryHoverColor;
  @override
  Widget build(BuildContext context) => ActionSurface(
    onActivate: onPressed,
    builder: (_, states) {
      final hover =
          states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused);
      return Container(
        foregroundDecoration: FocusOutline(
          const StadiumBorder(),
          states.contains(WidgetState.focused)
              ? IslandTokens.light.focus
              : Colors.transparent,
          width: 2,
          offset: 0,
        ),
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: primary ? 16 : 14, vertical: 6),
        decoration: BoxDecoration(
          color: primary && hover
              ? (primaryHoverColor ?? IslandTokens.light.ink)
              : primary || hover
              ? PickerColors.footerActionFill
              : null,
          borderRadius: BorderRadius.circular(primary ? 12 : 10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            height: 1.5,
            color: primary && hover
                ? PickerColors.footerPrimaryHoverInk
                : IslandTokens.light.ink,
          ),
        ),
      );
    },
  );
}
