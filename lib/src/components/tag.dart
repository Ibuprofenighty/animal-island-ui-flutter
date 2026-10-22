import '../foundation/theme.dart';

import 'package:flutter/material.dart';

import '../foundation/colorway.dart';
import '../foundation/size.dart';
import '../internal/action_surface.dart';
import '../internal/content_scope.dart';
import '../internal/light_surface_scope.dart';
import '../internal/focus_outline.dart';
import '../internal/dashed_border.dart';

enum IslandTagVariant { solid, outlined, soft, dashed }

/// Closing requests removal; only the host decides whether the tag disappears.
/// The close action is a separate keyboard target and never activates the tag.
/// Its pale hover fill and colorway ink switch together, independent of ambient
/// ink on the transparent variants. Explicit child styles remain authoritative.
class IslandTag extends StatelessWidget {
  const IslandTag({
    super.key,
    required this.child,
    this.colorway = IslandColorway.neutral,
    this.variant = IslandTagVariant.soft,
    this.size = IslandSize.middle,
    this.onPressed,
    this.onClose,
    this.disabled = false,
    this.closeLabel = 'close',
  });
  final Widget child;
  final IslandColorway colorway;
  final IslandTagVariant variant;
  final IslandSize size;
  final VoidCallback? onPressed, onClose;
  final bool disabled;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final solid = variant == IslandTagVariant.solid;
    final soft = variant == IslandTagVariant.soft;
    final neutral = colorway == IslandColorway.neutral;
    final color = !solid && !soft
        ? IslandTheme.of(context).ink
        : solid && !neutral
        ? colorway.onAccent
        : colorway.ink;
    final background = soft
        ? colorway.soft
        : solid
        ? neutral
              ? const Color(0xfff7f3df)
              : colorway.accent
        : Colors.transparent;
    final borderWidth = IslandTheme.borderWidth(context, 1.5);
    final side = BorderSide(
      width: borderWidth,
      color: soft ? Colors.transparent : color,
    );
    final (height, font, pad) = switch (size) {
      IslandSize.small => (24.0, 12.0, 10.0),
      IslandSize.middle => (32.0, 14.0, 12.0),
      IslandSize.large => (40.0, 16.0, 16.0),
    };
    const shape = StadiumBorder();
    Widget visual(Set<WidgetState> states) => Opacity(
      opacity: disabled ? .5 : 1,
      child: TweenAnimationBuilder<Matrix4>(
        tween: Matrix4Tween(
          end: Matrix4.translationValues(
            0,
            states.contains(WidgetState.hovered) &&
                    !states.contains(WidgetState.pressed)
                ? -1
                : 0,
            0,
          ),
        ),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.ease,
        builder: (_, matrix, child) => Transform(
          transform: matrix,
          filterQuality: FilterQuality.low,

          child: child,
        ),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.ease,
          decoration: ShapeDecoration(
            shape: shape,
            shadows: states.contains(WidgetState.hovered)
                ? const [
                    BoxShadow(
                      color: Color(0x1f3d3428),
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Container(
            foregroundDecoration: FocusOutline(
              shape,
              states.contains(WidgetState.focused)
                  ? IslandTokens.light.onLeaf
                  : Colors.transparent,
              width: 2,
              offset: 2,
              backingColor: states.contains(WidgetState.focused)
                  ? IslandTokens.light.paper
                  : null,
            ),
            decoration: ShapeDecoration(
              color: background,
              shape: shape.copyWith(
                side: variant == IslandTagVariant.dashed
                    ? BorderSide.none
                    : side,
              ),
            ),
            child: CustomPaint(
              foregroundPainter: variant == IslandTagVariant.dashed
                  ? DashedBorderPainter(shape, side)
                  : null,
              child: Container(
                constraints: BoxConstraints(
                  minHeight:
                      height -
                      (variant == IslandTagVariant.dashed
                          ? 0
                          : borderWidth * 2),
                ),
                padding: EdgeInsetsDirectional.only(
                  start:
                      pad +
                      (variant == IslandTagVariant.dashed ? borderWidth : 0),
                  end:
                      pad +
                      (variant == IslandTagVariant.dashed ? borderWidth : 0) -
                      (onClose != null ? 4 : 0),
                ),
                child: LightSurfaceScope(
                  enabled: solid || soft,
                  onSurface: colorway.onAccent,
                  child: ContentScope(
                    textStyle: TextStyle(
                      color: color,
                      fontSize: font,
                      letterSpacing: 0,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                    iconColor: color,
                    iconSize: 18,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        child,
                        if (onClose != null) ...[
                          const SizedBox(width: 6),
                          ActionSurface(
                            label: closeLabel,
                            onActivate: disabled ? null : onClose,
                            builder: (_, closeStates) => Container(
                              width: 16,
                              height: 16,
                              foregroundDecoration: FocusOutline(
                                const CircleBorder(),
                                closeStates.contains(WidgetState.focused)
                                    ? IslandTokens.light.onLeaf
                                    : Colors.transparent,
                                width: 2,
                                offset: 0,
                                backingColor:
                                    closeStates.contains(WidgetState.focused)
                                    ? IslandTokens.light.paper
                                    : null,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: closeStates.contains(WidgetState.hovered)
                                    ? colorway.soft
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: ExcludeSemantics(
                                  child: Text(
                                    '×',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          closeStates.contains(
                                            WidgetState.hovered,
                                          )
                                          ? colorway.ink
                                          : color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return ActionSurface(
      button: onPressed != null,
      isolateChildFocus: true,
      mouseCursor: onPressed == null ? MouseCursor.defer : null,
      onActivate: disabled ? null : onPressed,
      builder: (_, states) => visual(states),
    );
  }
}
