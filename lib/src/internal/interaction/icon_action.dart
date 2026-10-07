import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';
import '../timing/motion_policy.dart';
import 'interactive_region.dart';

/// The single icon-only action control of the package: close, clear and
/// remove buttons of every component.
///
/// It owns the 48 logical-pixel target, activation, focus ring, accessible
/// name and the hover fill. The owning component resolves every visual value
/// through its own style resolver and passes the icon it draws.
class AnimalIconAction extends StatefulWidget {
  const AnimalIconAction({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    required this.icon,
    required this.padding,
    required this.borderRadius,
    required this.backgroundColor,
  });

  final VoidCallback onPressed;

  /// Accessible name of the action.
  final String semanticLabel;

  final Widget icon;

  /// Space between the icon and the edge of its fill.
  final EdgeInsetsGeometry padding;

  /// Corner radius of the fill and the focus ring.
  final BorderRadius borderRadius;

  /// Fill behind the icon, resolved against [WidgetState.hovered].
  final WidgetStateProperty<Color> backgroundColor;

  @override
  State<AnimalIconAction> createState() => _AnimalIconActionState();
}

class _AnimalIconActionState extends State<AnimalIconAction> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final Duration duration = AnimalMotionPolicy.shouldAnimate(context)
        ? AnimalIslandTheme.of(context).motion.fast
        : Duration.zero;
    return InteractiveRegion(
      onPressed: widget.onPressed,
      enableHaptics: false,
      semanticContainer: true,
      semanticLabel: widget.semanticLabel,
      surfaceColor: const Color(0x00000000),
      borderRadius: widget.borderRadius,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: AnimatedContainer(
          duration: duration,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: widget.backgroundColor.resolve(<WidgetState>{
              if (_hovered) WidgetState.hovered,
            }),
          ),
          child: widget.icon,
        ),
      ),
    );
  }
}

/// Resolves an icon action fill: the styled value for the current states,
/// otherwise [hovered] while hovered and [idle] at rest.
WidgetStateProperty<Color> resolveIconActionBackground(
  WidgetStateProperty<Color?>? styled, {
  required Color idle,
  required Color hovered,
}) => WidgetStateProperty.resolveWith<Color>(
  (Set<WidgetState> states) =>
      styled?.resolve(states) ??
      (states.contains(WidgetState.hovered) ? hovered : idle),
);

/// Laid-out width of an [AnimalIconAction] with an [iconSize] icon and
/// [padding]: the icon and its padding, never below the 48 logical-pixel
/// target. Layouts that reserve room for an icon action use this value.
double animalIconActionWidth({
  required double iconSize,
  required EdgeInsetsGeometry padding,
  required TextDirection textDirection,
}) => math.max(
  kAnimalMinimumTarget,
  iconSize + padding.resolve(textDirection).horizontal,
);
