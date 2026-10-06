import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../internal/overlay/animal_localized_dialog_route.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/interactive_region.dart';

/// Placement edge for [AnimalDrawer].
enum AnimalDrawerPlacement { left, right, top, bottom }

/// Animal Island slide-out Drawer sheet with 4 placements and modal route focus scope (C22).
///
/// Features:
/// - 4 slide directions (Left, Right, Top, Bottom)
/// - Responsive dimension clamping with screen boundaries and safe insets (DRW01)
/// - Mask closable barrier guard (DRW02)
/// - Accessible route semantics with `scopesRoute: true` and keyboard close activation (DRW03)
class AnimalDrawer extends StatelessWidget {
  final Widget? title;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  final double width;
  final double height;
  final AnimalDrawerPlacement placement;

  const AnimalDrawer({
    super.key,
    this.title,
    required this.child,
    this.footer,
    this.onClose,
    this.width = 378.0,
    this.height = 300.0,
    this.placement = AnimalDrawerPlacement.right,
  });

  /// Shows the drawer in a modal sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget child,
    Widget? footer,
    double width = 378.0,
    double height = 300.0,
    AnimalDrawerPlacement placement = AnimalDrawerPlacement.right,
    bool maskClosable = true,
    Color? barrierColor,
  }) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveBarrierColor =
        barrierColor ??
        theme.colors.text.withValues(
          alpha: theme.colors.brightness == Brightness.dark ? 0.6 : 0.4,
        );

    return showAnimalLocalizedDialog<T>(
      context: context,
      barrierDismissible: maskClosable,
      barrierColor: effectiveBarrierColor,
      transitionDuration: theme.motion.normal,
      pageBuilder: (ctx, anim1, anim2) {
        Alignment alignment;
        switch (placement) {
          case AnimalDrawerPlacement.left:
            alignment = Alignment.centerLeft;
          case AnimalDrawerPlacement.right:
            alignment = Alignment.centerRight;
          case AnimalDrawerPlacement.top:
            alignment = Alignment.topCenter;
          case AnimalDrawerPlacement.bottom:
            alignment = Alignment.bottomCenter;
        }

        return FocusScope(
          autofocus: true,
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: AnimalLocalizations.of(ctx)!.drawerSemanticsLabel,
            child: Align(
              alignment: alignment,
              child: Material(
                color: Colors.transparent,
                child: AnimalDrawer(
                  title: title,
                  width: width,
                  height: height,
                  placement: placement,
                  footer: footer,
                  onClose: () => Navigator.of(ctx).pop(),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        Offset beginOffset;
        switch (placement) {
          case AnimalDrawerPlacement.left:
            beginOffset = const Offset(-1.0, 0.0);
          case AnimalDrawerPlacement.right:
            beginOffset = const Offset(1.0, 0.0);
          case AnimalDrawerPlacement.top:
            beginOffset = const Offset(0.0, -1.0);
          case AnimalDrawerPlacement.bottom:
            beginOffset = const Offset(0.0, 1.0);
        }

        final curvedAnim = CurvedAnimation(
          parent: anim1,
          curve: theme.motion.spring,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnim),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final mq = MediaQuery.of(context);

    final bool isHorizontal =
        placement == AnimalDrawerPlacement.left ||
        placement == AnimalDrawerPlacement.right;

    final double effectiveWidth = isHorizontal
        ? math.min(width, mq.size.width)
        : mq.size.width;

    final double effectiveHeight = isHorizontal
        ? mq.size.height
        : math.min(height, mq.size.height);

    BorderRadius borderRadius;
    switch (placement) {
      case AnimalDrawerPlacement.left:
        borderRadius = BorderRadius.horizontal(
          right: Radius.circular(theme.radii.card * 1.2),
        );
      case AnimalDrawerPlacement.right:
        borderRadius = BorderRadius.horizontal(
          left: Radius.circular(theme.radii.card * 1.2),
        );
      case AnimalDrawerPlacement.top:
        borderRadius = BorderRadius.vertical(
          bottom: Radius.circular(theme.radii.card * 1.2),
        );
      case AnimalDrawerPlacement.bottom:
        borderRadius = BorderRadius.vertical(
          top: Radius.circular(theme.radii.card * 1.2),
        );
    }

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: theme.colors.bgContent,
        borderRadius: borderRadius,
        border: Border.all(
          color: theme.colors.brightness == Brightness.dark
              ? theme.colors.border
              : theme.colors.borderLight,
          width: 1.5,
        ),
        boxShadow: theme.shadows.modal,
      ),
      child: SafeArea(
        top: placement != AnimalDrawerPlacement.bottom,
        bottom: placement != AnimalDrawerPlacement.top,
        left: placement != AnimalDrawerPlacement.right,
        right: placement != AnimalDrawerPlacement.left,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg + theme.spacing.xs,
                theme.spacing.lg,
                theme.spacing.lg,
                theme.spacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: title != null
                        ? DefaultTextStyle(
                            style: theme.typography.title
                                .apply(fontSizeFactor: 0.75)
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colors.text,
                                ),
                            child: title!,
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (onClose != null)
                    _DrawerCloseButton(onClose: onClose!, theme: theme),
                ],
              ),
            ),
            const Divider(height: 1.0, thickness: 1.0),
            // Body
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.lg + theme.spacing.xs),
                child: child,
              ),
            ),
            // Footer
            if (footer != null) ...[
              const Divider(height: 1.0, thickness: 1.0),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.lg + theme.spacing.xs,
                  vertical: theme.spacing.lg - theme.spacing.xxs,
                ),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerCloseButton extends StatefulWidget {
  final VoidCallback onClose;
  final AnimalIslandTheme theme;

  const _DrawerCloseButton({required this.onClose, required this.theme});

  @override
  State<_DrawerCloseButton> createState() => _DrawerCloseButtonState();
}

class _DrawerCloseButtonState extends State<_DrawerCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InteractiveRegion(
        onPressed: widget.onClose,
        depth: 0,
        surfaceColor: _isHovered
            ? widget.theme.colors.surfaceAlt
            : Colors.transparent,
        borderRadius: widget.theme.radii.tooltipBorder,
        padding: EdgeInsets.all(
          widget.theme.spacing.xs + widget.theme.spacing.xxs,
        ),
        semanticLabel: AnimalLocalizations.of(context)!.drawerCloseLabel,
        child: AnimalIcon(
          data: AnimalIcons.close,
          size: 16,
          color: widget.theme.colors.textSecondary,
        ),
      ),
    );
  }
}
