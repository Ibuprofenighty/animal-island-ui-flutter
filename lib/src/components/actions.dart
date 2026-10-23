import 'tooltip.dart';

import 'package:flutter/material.dart';

import '../foundation/theme.dart';
import '../foundation/icon.dart';
import '../foundation/size.dart';
import '../internal/action_surface.dart';
import '../internal/content_scope.dart';
import '../internal/light_surface_scope.dart';
import '../internal/focus_outline.dart';
import '../foundation/dashed_border.dart';

enum IslandButtonVariant { primary, normal, dashed, text, link }

@immutable
class IslandButtonTheme extends ThemeExtension<IslandButtonTheme> {
  const IslandButtonTheme({this.style = const ButtonStyle()});
  final ButtonStyle style;
  @override
  IslandButtonTheme copyWith({ButtonStyle? style}) =>
      IslandButtonTheme(style: style ?? this.style);
  @override
  IslandButtonTheme lerp(covariant IslandButtonTheme? other, double t) =>
      other == null || t < .5 ? this : other;
}

/// The host owns async work. A busy button never dispatches activation.
class IslandButton extends StatelessWidget {
  const IslandButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = IslandButtonVariant.normal,
    this.size = IslandSize.middle,
    this.icon,
    this.busy = false,
    this.danger = false,
    this.ghost = false,
    this.block = false,
    this.focusNode,
    this.autofocus = false,
    this.style,
    this.semanticLabel,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final IslandButtonVariant variant;
  final IslandSize size;
  final Widget? icon;
  final bool busy, danger, ghost, block, autofocus;
  final FocusNode? focusNode;
  final ButtonStyle? style;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context) {
    final tokens = IslandTheme.of(context);
    final themed = Theme.of(context).extension<IslandButtonTheme>()?.style;
    final primary = variant == IslandButtonVariant.primary;
    final plain =
        variant == IslandButtonVariant.text ||
        variant == IslandButtonVariant.link;
    final (height, font, padding) = switch (size) {
      IslandSize.small => (32.0, 12.0, 16.0),
      IslandSize.middle => (45.0, 14.0, 20.0),
      IslandSize.large => (48.0, 16.0, 32.0),
    };
    return ActionSurface(
      label: semanticLabel,
      onActivate: busy ? null : onPressed,
      mouseCursor: busy
          ? SystemMouseCursors.basic
          : onPressed == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (context, states) {
        final disabled = onPressed == null,
            hover = states.contains(WidgetState.hovered);
        final pressed = states.contains(WidgetState.pressed);
        final focused = states.contains(WidgetState.focused);
        // Button owns variant recipes; shared activation supplies only states.
        final activeColor = pressed ? tokens.linkPressed : tokens.linkHover;
        var ink = switch (variant) {
          IslandButtonVariant.link =>
            pressed
                ? tokens.linkPressed
                : hover
                ? tokens.linkHover
                : tokens.link,
          IslandButtonVariant.normal || IslandButtonVariant.dashed =>
            hover || pressed ? activeColor : tokens.ink,
          _ => tokens.ink,
        };
        var background = plain
            ? tokens.paper.withValues(alpha: 0)
            : tokens.paper;
        var outline = plain
            ? Colors.transparent
            : primary
            ? tokens.outline
            : hover || pressed
            ? activeColor
            : tokens.outline;
        if (variant == IslandButtonVariant.text) {
          background = pressed
              ? (Theme.of(context).brightness == Brightness.light
                    ? const Color(0xffe9ddc6)
                    : Color.alphaBlend(
                        tokens.ink.withValues(alpha: .08),
                        tokens.paper,
                      ))
              : hover
              ? (Theme.of(context).brightness == Brightness.light
                    ? const Color(0xfff0e8d8)
                    : Color.alphaBlend(
                        tokens.ink.withValues(alpha: .04),
                        tokens.paper,
                      ))
              : tokens.paper.withValues(alpha: 0);
        }
        if (danger) {
          final dangerState = pressed
              ? tokens.dangerPressed
              : hover
              ? tokens.dangerHover
              : tokens.danger;
          ink = primary ? tokens.onDanger : tokens.dangerText;
          if (!plain) outline = tokens.dangerText;
          if (primary) background = dangerState;
        }
        if (ghost) {
          background = tokens.paper.withValues(alpha: 0);
          if (primary) {
            ink = danger
                ? tokens.dangerText
                : pressed
                ? tokens.linkPressed
                : hover
                ? tokens.linkHover
                : tokens.link;
            outline = ink;
            if (hover) {
              background = tokens.leaf.withValues(alpha: .08);
            }
          }
        }
        if (busy) {
          ink = tokens.onLeaf;
          // Busy is a Button-owned fixed recipe, separate from the brand fill.
          background = const Color(0xff0ec4b6);
          outline = tokens.link;
        }
        final foreground = ActionSurface.resolveStyleValue(
          states,
          style?.foregroundColor,
          themed?.foregroundColor,
          ink,
        );
        final fill = ActionSurface.resolveStyleValue(
          states,
          style?.backgroundColor,
          themed?.backgroundColor,
          background,
        );
        final border = ActionSurface.resolveStyleValue(
          states,
          style?.side,
          themed?.side,
          BorderSide(color: outline, width: busy ? 4 : 2),
        );
        final shape = ActionSurface.resolveStyleValue<OutlinedBorder>(
          states,
          style?.shape,
          themed?.shape,
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              size == IslandSize.small
                  ? 16
                  : size == IslandSize.large
                  ? 24
                  : 50,
            ),
          ),
        );
        final text =
            TextStyle(
                  fontSize: font,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: font * 0.02,
                )
                .merge(themed?.textStyle?.resolve(states))
                .merge(style?.textStyle?.resolve(states))
                .copyWith(color: foreground);
        final depth = primary && !ghost && !busy && !disabled
            ? pressed
                  ? 1.0
                  : hover
                  ? 6.0
                  : 5.0
            : 0.0;
        final duration = MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250);
        final paddingValue =
            ActionSurface.resolveStyleValue<EdgeInsetsGeometry>(
              states,
              style?.padding,
              themed?.padding,
              EdgeInsets.symmetric(horizontal: padding),
            );
        final raisedShadow =
            variant == IslandButtonVariant.normal && hover && !pressed;
        final visual = TweenAnimationBuilder<Matrix4>(
          tween: Matrix4Tween(
            end: Matrix4.translationValues(
              0,
              plain || busy || disabled
                  ? 0
                  : pressed
                  ? (primary ? 2 : 0)
                  : hover
                  ? -1
                  : 0,
              0,
            ),
          ),
          duration: duration,
          curve: const Cubic(.4, 0, .2, 1),
          builder: (_, matrix, child) => Transform(
            transform: matrix,
            filterQuality: FilterQuality.low,
            child: child,
          ),
          child: AnimatedContainer(
            duration: duration,
            curve: const Cubic(.4, 0, .2, 1),

            constraints: BoxConstraints(minHeight: height),
            decoration: ShapeDecoration(
              shape: shape.copyWith(side: BorderSide.none),
              shadows: depth > 0
                  ? [
                      BoxShadow(
                        color: danger
                            ? const Color(0xffc94444)
                            : const Color(0xffbdaea0),
                        offset: Offset(0, depth),
                      ),
                    ]
                  : !plain && !ghost && !busy && !disabled
                  ? [
                      BoxShadow(
                        color: raisedShadow
                            ? const Color(0x1a3d3428)
                            : const Color(0x0f3d3428),
                        offset: Offset(0, raisedShadow ? 3 : 2),
                        blurRadius: raisedShadow ? 10 : 4,
                      ),
                    ]
                  : null,
            ),
            child: Container(
              foregroundDecoration: FocusOutline(
                shape,
                focused ? tokens.focus : Colors.transparent,
                width: 2,
                offset: 2,
              ),
              decoration: ShapeDecoration(
                color: fill,
                shape: shape.copyWith(
                  side: variant == IslandButtonVariant.dashed
                      ? BorderSide.none
                      : border,
                ),
              ),
              child: CustomPaint(
                foregroundPainter: variant == IslandButtonVariant.dashed
                    ? IslandDashedBorderPainter(
                        shape: shape,
                        color: border.color,
                        strokeWidth: border.width,
                      )
                    : null,
                child: Padding(
                  padding: variant == IslandButtonVariant.dashed
                      ? paddingValue.add(EdgeInsets.all(border.width))
                      : paddingValue,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: height - border.width * 2,
                    ),
                    child: LightSurfaceScope(
                      enabled: busy,
                      onSurface: foreground,
                      child: ContentScope(
                        textStyle: text,
                        iconColor: foreground,
                        iconSize: 20,
                        child: Row(
                          mainAxisSize: block
                              ? MainAxisSize.max
                              : MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (busy) ...[
                              _ButtonBusyIcon(color: foreground),
                              const SizedBox(width: 8),
                            ] else if (icon != null) ...[
                              icon!,
                              const SizedBox(width: 8),
                            ],
                            Flexible(child: child),
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
        return Opacity(opacity: disabled ? .5 : 1, child: visual);
      },
    );
  }
}

/// This ticker owns presentation only; the host owns async work.
class _ButtonBusyIcon extends StatefulWidget {
  const _ButtonBusyIcon({required this.color});
  final Color color;
  @override
  State<_ButtonBusyIcon> createState() => _ButtonBusyIconState();
}

class _ButtonBusyIconState extends State<_ButtonBusyIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  );
  late final Animation<double> turns = Tween<double>(
    begin: 0,
    end: -1,
  ).animate(spin);
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      spin.stop();
      spin.value = 0;
    } else if (!spin.isAnimating) {
      spin.repeat();
    }
  }

  @override
  void dispose() {
    spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: turns,
    child: IslandIcon(IslandGlyph.donut, size: 28, color: widget.color),
  );
}

class IslandIconButton extends StatelessWidget {
  const IslandIconButton({
    super.key,
    required this.glyph,
    required this.label,
    required this.onPressed,
    this.focusNode,
  });
  final IslandGlyph glyph;
  final String label;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => IslandTooltip(
    message: label,
    excludeFromSemantics: true,
    child: IslandButton(
      onPressed: onPressed,
      focusNode: focusNode,
      semanticLabel: label,
      child: ExcludeSemantics(child: IslandIcon(glyph)),
    ),
  );
}
