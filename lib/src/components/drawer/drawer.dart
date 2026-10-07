import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/drawer_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/overlay/animal_route.dart';
import '../../internal/timing/motion_policy.dart';

/// Placement edge for [AnimalDrawer].
enum AnimalDrawerPlacement { left, right, top, bottom }

/// Animal Island slide-out drawer sheet with four placements (C22).
///
/// The widget is the sheet: a title row with an optional close control, the
/// body [child] and an optional [footer]. [AnimalDrawer.show] presents it as a
/// route on the nearest Navigator and returns the value its content closes it
/// with.
///
/// The sheet keeps its close control inside the safe area and above an open
/// keyboard, never exceeds the space it is given, and names its route once.
/// With reduced motion the sheet appears without sliding.
class AnimalDrawer extends StatelessWidget {
  /// Preferred width of a left or right sheet when none is given.
  static const double _defaultWidth = 378.0;

  /// Preferred height of a top or bottom sheet when none is given.
  static const double _defaultHeight = 300.0;

  /// Title row content, styled with the title text style.
  final Widget? title;

  /// Body content between the header and the footer.
  final Widget child;

  /// Optional actions row below the body.
  final Widget? footer;

  /// Shows the close control and runs when it is activated.
  final VoidCallback? onClose;

  /// Preferred width of a left or right sheet, 378 logical pixels by default.
  final double width;

  /// Preferred height of a top or bottom sheet, 300 logical pixels by default.
  final double height;

  /// Screen edge the sheet slides in from.
  final AnimalDrawerPlacement placement;

  /// Visual overrides for this drawer; see [AnimalDrawerStyle].
  final AnimalDrawerStyle? style;

  const AnimalDrawer({
    super.key,
    this.title,
    required this.child,
    this.footer,
    this.onClose,
    this.width = _defaultWidth,
    this.height = _defaultHeight,
    this.placement = AnimalDrawerPlacement.right,
    this.style,
  });

  /// Shows a drawer and returns the value its content closes it with.
  ///
  /// [builder] builds the body and [footerBuilder] the optional footer. Both
  /// receive `close`, which completes the drawer with a typed value. The close
  /// control, Escape and system back complete it with null; a barrier tap does
  /// so only when [mask] and [maskClosable] are both true. Focus stays inside
  /// the drawer and returns to the opening control when it closes.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget Function(
      BuildContext context,
      void Function(T result) close,
    )
    builder,
    Widget Function(BuildContext context, void Function(T result) close)?
    footerBuilder,
    double width = _defaultWidth,
    double height = _defaultHeight,
    AnimalDrawerPlacement placement = AnimalDrawerPlacement.right,
    bool mask = true,
    bool maskClosable = true,
    AnimalDrawerStyle? style,
  }) {
    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final _ResolvedDrawerStyle resolved = _ResolvedDrawerStyle.resolve(
      theme,
      style,
      placement,
    );
    final bool animate = AnimalMotionPolicy.shouldAnimate(context);

    return presentAnimalRoute<T>(
      context: context,
      maskClosable: mask && maskClosable,
      barrierColor: mask ? resolved.barrierColor : const Color(0x00000000),
      transitionDuration: animate ? theme.motion.normal : Duration.zero,
      routeLabel: (context) =>
          AnimalLocalizations.of(context)!.drawerRouteLabel,
      // The sheet stays above an open keyboard, and a top or bottom sheet
      // never reaches into the system inset on its open edge; the sheet's own
      // SafeArea covers the edges it touches.
      builder: (context, session) => Padding(
        padding: EdgeInsets.only(
          top: placement == AnimalDrawerPlacement.bottom
              ? MediaQuery.paddingOf(context).top
              : 0,
          bottom:
              MediaQuery.viewInsetsOf(context).bottom +
              (placement == AnimalDrawerPlacement.top
                  ? MediaQuery.paddingOf(context).bottom
                  : 0),
        ),
        child: Align(
          alignment: switch (placement) {
            AnimalDrawerPlacement.left => Alignment.centerLeft,
            AnimalDrawerPlacement.right => Alignment.centerRight,
            AnimalDrawerPlacement.top => Alignment.topCenter,
            AnimalDrawerPlacement.bottom => Alignment.bottomCenter,
          },
          child: Material(
            color: Colors.transparent,
            child: AnimalDrawer(
              title: title,
              width: width,
              height: height,
              placement: placement,
              style: style,
              footer: footerBuilder == null
                  ? null
                  : Builder(
                      builder: (context) =>
                          footerBuilder(context, session.close),
                    ),
              onClose: session.dismiss,
              child: Builder(
                builder: (context) => builder(context, session.close),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        if (!animate) return child;
        final Offset begin = switch (placement) {
          AnimalDrawerPlacement.left => const Offset(-1.0, 0.0),
          AnimalDrawerPlacement.right => const Offset(1.0, 0.0),
          AnimalDrawerPlacement.top => const Offset(0.0, -1.0),
          AnimalDrawerPlacement.bottom => const Offset(0.0, 1.0),
        };
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: theme.motion.spring),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ResolvedDrawerStyle s = _ResolvedDrawerStyle.resolve(
      AnimalIslandTheme.of(context),
      style,
      placement,
    );
    final Size screen = MediaQuery.sizeOf(context);
    final bool isHorizontal =
        placement == AnimalDrawerPlacement.left ||
        placement == AnimalDrawerPlacement.right;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The route pads the space an open keyboard covers, so the bounded
        // constraints are the area the sheet may occupy.
        final double maxWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : screen.width;
        final double maxHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : screen.height;
        final double effectiveWidth = isHorizontal
            ? math.min(width, maxWidth)
            : maxWidth;
        final double effectiveHeight = isHorizontal
            ? maxHeight
            : math.min(height, maxHeight);

        return Container(
          width: effectiveWidth,
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: s.backgroundColor,
            borderRadius: s.borderRadius,
            border: Border.all(color: s.borderColor, width: s.borderWidth),
            boxShadow: s.shadows,
          ),
          child: SafeArea(
            top: placement != AnimalDrawerPlacement.bottom,
            bottom: placement != AnimalDrawerPlacement.top,
            left: placement != AnimalDrawerPlacement.right,
            right: placement != AnimalDrawerPlacement.left,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: s.headerPadding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: title != null
                            ? DefaultTextStyle(
                                style: s.titleTextStyle,
                                child: title!,
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (onClose case final VoidCallback onClose)
                        AnimalIconAction(
                          onPressed: onClose,
                          semanticLabel: AnimalLocalizations.of(context)!
                              .drawerCloseLabel,
                          padding: s.closeButtonPadding,
                          borderRadius: s.closeButtonBorderRadius,
                          backgroundColor: s.closeButtonBackgroundColor,
                          icon: AnimalIcon(
                            data: AnimalIcons.close,
                            size: s.closeIconSize,
                            color: s.closeIconColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(
                  height: s.dividerThickness,
                  thickness: s.dividerThickness,
                  color: s.dividerColor,
                ),
                Expanded(
                  child: Padding(padding: s.bodyPadding, child: child),
                ),
                if (footer != null) ...[
                  Divider(
                    height: s.dividerThickness,
                    thickness: s.dividerThickness,
                    color: s.dividerColor,
                  ),
                  Padding(padding: s.footerPadding, child: footer!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The single resolver of every visual value of [AnimalDrawer].
///
/// Precedence: instance `style` > `AnimalIslandTheme.components.drawer` >
/// defaults derived from theme tokens.
class _ResolvedDrawerStyle {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;
  final TextStyle titleTextStyle;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry bodyPadding;
  final EdgeInsetsGeometry footerPadding;

  /// Null keeps the framework divider color of the ambient Material theme.
  final Color? dividerColor;
  final double dividerThickness;
  final Color closeIconColor;
  final double closeIconSize;
  final EdgeInsetsGeometry closeButtonPadding;
  final BorderRadius closeButtonBorderRadius;
  final WidgetStateProperty<Color> closeButtonBackgroundColor;
  final Color barrierColor;

  const _ResolvedDrawerStyle._({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.shadows,
    required this.titleTextStyle,
    required this.headerPadding,
    required this.bodyPadding,
    required this.footerPadding,
    required this.dividerColor,
    required this.dividerThickness,
    required this.closeIconColor,
    required this.closeIconSize,
    required this.closeButtonPadding,
    required this.closeButtonBorderRadius,
    required this.closeButtonBackgroundColor,
    required this.barrierColor,
  });

  static _ResolvedDrawerStyle resolve(
    AnimalIslandTheme theme,
    AnimalDrawerStyle? style,
    AnimalDrawerPlacement placement,
  ) {
    final AnimalDrawerStyle merged = (style ?? AnimalDrawerStyle()).merge(
      theme.components.drawer,
    );
    final colors = theme.colors;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final bool dark = colors.brightness == Brightness.dark;
    final BoxShadow? shadow = merged.shadow;
    // Only the corners facing into the screen are rounded.
    final Radius corner = Radius.circular(theme.radii.card * 1.2);

    return _ResolvedDrawerStyle._(
      backgroundColor: merged.backgroundColor ?? colors.bgContent,
      borderColor:
          merged.borderColor ?? (dark ? colors.border : colors.borderLight),
      borderWidth: merged.borderWidth ?? 1.5,
      borderRadius:
          merged.borderRadius ??
          switch (placement) {
            AnimalDrawerPlacement.left => BorderRadius.horizontal(
              right: corner,
            ),
            AnimalDrawerPlacement.right => BorderRadius.horizontal(
              left: corner,
            ),
            AnimalDrawerPlacement.top => BorderRadius.vertical(bottom: corner),
            AnimalDrawerPlacement.bottom => BorderRadius.vertical(top: corner),
          },
      shadows: shadow != null ? <BoxShadow>[shadow] : theme.shadows.modal,
      titleTextStyle: typography
          .resolve(
            typography.title
                .apply(fontSizeFactor: 0.75)
                .copyWith(fontWeight: FontWeight.w800)
                .merge(merged.titleTextStyle),
          )
          .copyWith(color: merged.titleTextColor ?? colors.text),
      headerPadding:
          merged.headerPadding ??
          EdgeInsets.fromLTRB(
            spacing.lg + spacing.xs,
            spacing.lg,
            spacing.lg,
            spacing.md,
          ),
      bodyPadding:
          merged.bodyPadding ?? EdgeInsets.all(spacing.lg + spacing.xs),
      footerPadding:
          merged.footerPadding ??
          EdgeInsets.symmetric(
            horizontal: spacing.lg + spacing.xs,
            vertical: spacing.lg - spacing.xxs,
          ),
      dividerColor: merged.dividerColor,
      dividerThickness: merged.dividerThickness ?? 1.0,
      closeIconColor: merged.closeIconColor ?? colors.textSecondary,
      closeIconSize: merged.closeIconSize ?? 16,
      closeButtonPadding:
          merged.closeButtonPadding ?? EdgeInsets.all(spacing.xs + spacing.xxs),
      closeButtonBorderRadius:
          merged.closeButtonBorderRadius ?? theme.radii.tooltipBorder,
      closeButtonBackgroundColor: resolveIconActionBackground(
        merged.closeButtonBackgroundColor,
        idle: const Color(0x00000000),
        hovered: colors.surfaceAlt,
      ),
      barrierColor:
          merged.barrierColor ??
          colors.text.withValues(alpha: dark ? 0.6 : 0.4),
    );
  }
}
