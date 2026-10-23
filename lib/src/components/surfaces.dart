import 'package:flutter/material.dart';

import '../foundation/theme.dart';
import '../foundation/colorway.dart';
import '../foundation/dashed_border.dart';
import '../internal/dot_pattern.dart';
import '../internal/content_scope.dart';
import '../internal/action_surface.dart';
import '../internal/light_surface_scope.dart';

enum IslandCardVariant { normal, dashed }

/// Component-owned roles, resolved per state: instance > theme > recipe.
/// foregroundColor owns default Color ink; explicit TextStyle foreground Paint
/// retains Flutter precedence and remains caller-owned, not a semantic token.
@immutable
class IslandCardStyle {
  const IslandCardStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.focusColor,
    this.dividerColor,
    this.largeDotColor,
    this.smallDotColor,
    this.textStyle,
    this.surfaceTheme,
  });
  final WidgetStateProperty<Color?>? backgroundColor,
      foregroundColor,
      borderColor,
      focusColor,
      dividerColor,
      largeDotColor,
      smallDotColor;
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// Optional complete control semantics; passive ink remains foregroundColor.
  /// Null retains the known-light paired recipe, not arbitrary host branding.
  final IslandSurfaceTheme? surfaceTheme;
}

@immutable
class IslandCardTheme extends ThemeExtension<IslandCardTheme> {
  const IslandCardTheme({
    this.style = const IslandCardStyle(),
    this.padding,
    this.radius,
  });
  final IslandCardStyle style;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  @override
  IslandCardTheme copyWith({
    IslandCardStyle? style,
    EdgeInsetsGeometry? padding,
    double? radius,
  }) => IslandCardTheme(
    style: style ?? this.style,
    padding: padding ?? this.padding,
    radius: radius ?? this.radius,
  );
  @override
  IslandCardTheme lerp(covariant IslandCardTheme? other, double t) =>
      other == null || t < .5 ? this : other;
}

/// Slot defaults never inspect or replace explicit opaque content.
class IslandCard extends StatelessWidget {
  const IslandCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.padding,
    this.style,
    this.onTap,
    this.hoverable = false,
    this.variant = IslandCardVariant.normal,
    this.colorway = IslandColorway.neutral,
    this.pattern,
  });
  final Widget child;
  final Widget? header, footer;
  final EdgeInsetsGeometry? padding;
  final IslandCardStyle? style;
  final VoidCallback? onTap;
  final bool hoverable;
  final IslandCardVariant variant;
  final IslandColorway colorway;

  /// Null disables the pattern. Pattern recipe supersedes solid colorway.
  final IslandColorway? pattern;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IslandCardTheme>();
    final themed = theme?.style;
    final spacing =
        padding ??
        theme?.padding ??
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    final palette = paperPalette(pattern ?? colorway);
    final patterned = pattern != null;
    final ink = patterned || colorway == IslandColorway.neutral
        ? palette.$2
        : colorway.onAccent;
    Widget paint(Set<WidgetState> states) {
      final hovering = hoverable && states.contains(WidgetState.hovered);
      final dashed = variant == IslandCardVariant.dashed;
      final borderWidth = patterned
          ? IslandTheme.borderWidth(context, 1.5)
          : dashed
          ? 2.0
          : 0.0;
      final foreground = ActionSurface.resolveStyleValue(
        states,
        style?.foregroundColor,
        themed?.foregroundColor,
        ink,
      );
      // This final recipe is the only source for paint and descendant defaults.
      final roles = (
        foreground: foreground,
        background: ActionSurface.resolveStyleValue(
          states,
          style?.backgroundColor,
          themed?.backgroundColor,
          patterned
              ? palette.$1
              : colorway != IslandColorway.neutral
              ? colorway.accent
              : dashed
              ? const Color(0xfffaf8f2)
              : const Color(0xfff7f3df),
        ),
        border: ActionSurface.resolveStyleValue(
          states,
          style?.borderColor,
          themed?.borderColor,
          hovering && dashed
              ? const Color(0xffd4c4a8)
              : patterned
              ? (pattern == IslandColorway.neutral
                    ? const Color(0xffd4c4a8)
                    : pattern!.accent)
              : const Color(0xffe8dcc8),
        ),
        focus: ActionSurface.resolveStyleValue(
          states,
          style?.focusColor,
          themed?.focusColor,
          foreground,
        ),
        divider: ActionSurface.resolveStyleValue(
          states,
          style?.dividerColor,
          themed?.dividerColor,
          const Color(0xffe8dcc8),
        ),
        largeDot: ActionSurface.resolveStyleValue(
          states,
          style?.largeDotColor,
          themed?.largeDotColor,
          (pattern == IslandColorway.neutral
                  ? const Color(0xffc4b89e)
                  : (pattern ?? colorway).accent)
              .withValues(alpha: pattern == IslandColorway.neutral ? .15 : .18),
        ),
        smallDot: ActionSurface.resolveStyleValue(
          states,
          style?.smallDotColor,
          themed?.smallDotColor,
          palette.$3.withValues(
            alpha: pattern == IslandColorway.neutral ? .1 : .12,
          ),
        ),
        text: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
            .merge(themed?.textStyle?.resolve(states))
            .merge(style?.textStyle?.resolve(states))
            .copyWith(color: foreground),
        surfaceTheme: style?.surfaceTheme ?? themed?.surfaceTheme,
      );
      Widget slot(Widget value, {bool heading = false}) => Padding(
        padding: spacing,
        child: ContentScope(
          textStyle: heading
              ? roles.text.copyWith(fontWeight: FontWeight.w700)
              : roles.text,
          child: value,
        ),
      );
      final body = header == null && footer == null
          ? slot(child)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) ...[
                  slot(header!, heading: true),
                  Divider(height: 1, color: roles.divider),
                ],
                slot(child),
                if (footer != null) ...[
                  Divider(height: 1, color: roles.divider),
                  slot(footer!),
                ],
              ],
            );
      final radius = BorderRadius.circular(theme?.radius ?? 20);
      return TweenAnimationBuilder<Matrix4>(
        tween: Matrix4Tween(
          end: Matrix4.translationValues(0, hovering && !dashed ? -2 : 0, 0),
        ),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.ease,
        builder: (_, matrix, child) => Transform(
          transform: matrix,
          filterQuality: FilterQuality.low,
          child: child,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: roles.background,
            borderRadius: radius,
          ),
          child: CustomPaint(
            foregroundPainter: dashed && !patterned
                ? IslandDashedBorderPainter(
                    shape: RoundedRectangleBorder(borderRadius: radius),
                    color: roles.border,
                    strokeWidth: 2,
                    dash: 6,
                    gap: 4,
                  )
                : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: states.contains(WidgetState.focused)
                    ? Border.all(color: roles.focus, width: 2)
                    : borderWidth > 0 && (!dashed || patterned)
                    ? Border.all(color: roles.border, width: borderWidth)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: CustomPaint(
                  painter: patterned
                      ? DotPatternPainter(
                          largeDot: roles.largeDot,
                          smallDot: roles.smallDot,
                        )
                      : null,
                  child: Padding(
                    padding: EdgeInsets.all(borderWidth),
                    child: LightSurfaceScope(
                      onSurface: roles.foreground,
                      surfaceTheme: roles.surfaceTheme,
                      child: body,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ActionSurface(
      button: onTap != null,
      isolateChildFocus: true,
      passiveHover: hoverable,
      mouseCursor: hoverable || onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onActivate: onTap,
      builder: (_, states) => paint(states),
    );
  }
}
