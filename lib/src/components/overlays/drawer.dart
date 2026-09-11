import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';
import '../../primitives/pressable.dart';

/// Placement edge for [AnimalDrawer].
enum AnimalDrawerPlacement {
  left,
  right,
  top,
  bottom,
}

/// Animal Island slide-out Drawer sheet with 4 placements and modal route focus scope.
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

  /// Show the drawer in a modal sheet.
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
    final effectiveBarrierColor = barrierColor ??
        (theme.isDark ? const Color(0x99100D0A) : const Color(0x66332C25));

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: maskClosable,
      barrierLabel: 'Dismiss',
      barrierColor: effectiveBarrierColor,
      transitionDuration: const Duration(milliseconds: 280),
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
            label: 'Drawer',
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
            beginOffset = const Offset(-1, 0);
          case AnimalDrawerPlacement.right:
            beginOffset = const Offset(1, 0);
          case AnimalDrawerPlacement.top:
            beginOffset = const Offset(0, -1);
          case AnimalDrawerPlacement.bottom:
            beginOffset = const Offset(0, 1);
        }

        return SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final isHorizontal = placement == AnimalDrawerPlacement.left ||
        placement == AnimalDrawerPlacement.right;

    BorderRadius borderRadius;
    switch (placement) {
      case AnimalDrawerPlacement.right:
        borderRadius = const BorderRadius.horizontal(left: Radius.circular(24.0));
      case AnimalDrawerPlacement.left:
        borderRadius = const BorderRadius.horizontal(right: Radius.circular(24.0));
      case AnimalDrawerPlacement.top:
        borderRadius = const BorderRadius.vertical(bottom: Radius.circular(24.0));
      case AnimalDrawerPlacement.bottom:
        borderRadius = const BorderRadius.vertical(top: Radius.circular(24.0));
    }

    final borderColor = theme.isDark ? theme.border : AnimalColors.borderLight;

    return Container(
      width: isHorizontal ? width : double.infinity,
      height: isHorizontal ? double.infinity : height,
      decoration: BoxDecoration(
        color: theme.bgContent,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(61, 52, 40, 0.18),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight;

          Widget bodyWidget = DefaultTextStyle(
            style: AnimalTypography.bodyFor(context),
            child: child,
          );

          if (hasBoundedHeight) {
            bodyWidget = Expanded(child: bodyWidget);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    DefaultTextStyle(
                      style: AnimalTypography.headingFor(context),
                      child: title!,
                    )
                  else
                    const SizedBox.shrink(),
                  if (onClose != null)
                    AnimalPressable(
                      onPressed: onClose,
                      depth: 2.0,
                      surfaceColor: theme.bgInput,
                      depthColor: theme.depthColor,
                      borderRadius: BorderRadius.circular(16.0),
                      padding: const EdgeInsets.all(6.0),
                      semanticLabel: 'Close drawer',
                      child: CloseIcon(size: 16, color: theme.textSecondary),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              bodyWidget,
              if (footer != null) ...[
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.only(top: 12.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.isDark ? theme.border : AnimalColors.borderLight,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: footer!,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
