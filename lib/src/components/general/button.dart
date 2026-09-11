import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../primitives/pressable.dart';
import '../feedback/loading.dart';

/// Button visual style types matching animal-island-ui.
enum AnimalButtonType {
  primary,
  defaultButton,
  dashed,
  text,
  link,
  danger,
}

/// Button dimensions matching animal-island-ui.
enum AnimalButtonSize {
  small(height: 34.0, fontSize: 13.0, horizontalPadding: 16.0, iconSize: 16.0),
  middle(height: 44.0, fontSize: 15.0, horizontalPadding: 22.0, iconSize: 20.0),
  large(height: 52.0, fontSize: 17.0, horizontalPadding: 28.0, iconSize: 24.0);

  final double height;
  final double fontSize;
  final double horizontalPadding;
  final double iconSize;

  const AnimalButtonSize({
    required this.height,
    required this.fontSize,
    required this.horizontalPadding,
    required this.iconSize,
  });
}

/// A cozy game-like 3D button component.
///
/// Strictly adheres to canonical design laws:
/// - 50px pill shape (`BorderRadius.circular(50)`)
/// - Primary buttons feature stacked 3D shadow (`0 4px/5px 0 0 [depthColor]`)
/// - Default buttons feature soft elevation shadow
/// - Font weight 700, Nunito typography
/// - Micro-haptic tactile feedback on press
/// - Supports dashed, ghost, danger, block, loading, and icon states
class AnimalButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final AnimalButtonType type;
  final AnimalButtonSize size;
  final Widget? icon;
  final bool danger;
  final bool ghost;
  final bool loading;
  final bool disabled;
  final bool block;

  const AnimalButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.type = AnimalButtonType.primary,
    this.size = AnimalButtonSize.middle,
    this.icon,
    this.danger = false,
    this.ghost = false,
    this.loading = false,
    this.disabled = false,
    this.block = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final isDanger = danger || type == AnimalButtonType.danger;

    Color surfaceColor;
    Color? depthColor;
    Color textColor;
    double depth = 0.0;
    List<BoxShadow>? extraShadows;
    Border? border;

    if (disabled) {
      surfaceColor = theme.isDark ? theme.surfaceAlt : AnimalColors.bgDisabled;
      textColor = theme.textDisabled;
      border = Border.all(
        color: theme.isDark ? theme.border : AnimalColors.borderLight,
        width: 1.5,
      );
      depth = 0.0;
    } else {
      switch (type) {
        case AnimalButtonType.primary:
          if (ghost) {
            surfaceColor = Colors.transparent;
            textColor = isDanger ? theme.error : theme.primary;
            border = Border.all(color: textColor, width: 1.8);
            depth = 0.0;
          } else {
            surfaceColor = isDanger ? theme.error : theme.primary;
            depthColor = isDanger ? AnimalColors.errorActive : theme.primaryActive;
            textColor = Colors.white;
            depth = 4.0;
          }
        case AnimalButtonType.danger:
          if (ghost) {
            surfaceColor = Colors.transparent;
            textColor = theme.error;
            border = Border.all(color: theme.error, width: 1.8);
            depth = 0.0;
          } else {
            surfaceColor = theme.error;
            depthColor = AnimalColors.errorActive;
            textColor = Colors.white;
            depth = 4.0;
          }
        case AnimalButtonType.defaultButton:
          surfaceColor = ghost ? Colors.transparent : theme.bgContent;
          depthColor = null;
          textColor = isDanger ? theme.error : theme.text;
          depth = 0.0;
          if (!ghost) {
            extraShadows = const [AnimalShadows.softElevation];
          }
          border = Border.all(
            color: isDanger
                ? theme.error
                : (theme.isDark ? theme.border : AnimalColors.borderLight),
            width: 1.5,
          );
        case AnimalButtonType.dashed:
          surfaceColor = ghost ? Colors.transparent : theme.bgContent;
          depthColor = null;
          textColor = isDanger ? theme.error : theme.text;
          depth = 0.0;
          // Dashed border handled via custom painter wrapper
          border = null;
        case AnimalButtonType.text:
          surfaceColor = Colors.transparent;
          depthColor = null;
          textColor = isDanger ? theme.error : theme.text;
          depth = 0.0;
        case AnimalButtonType.link:
          surfaceColor = Colors.transparent;
          depthColor = null;
          textColor = isDanger ? theme.error : theme.primary;
          depth = 0.0;
      }
    }

    Widget content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: size.iconSize,
            height: size.iconSize,
            child: AnimalLoading(size: size.iconSize, color: textColor),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          IconTheme(
            data: IconThemeData(size: size.iconSize, color: textColor),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        DefaultTextStyle(
          style: AnimalTypography.button.copyWith(
            fontSize: size.fontSize,
            color: textColor,
            decoration: type == AnimalButtonType.link
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
          child: child,
        ),
      ],
    );

    Widget pressable = AnimalPressable(
      onPressed: (disabled || loading) ? null : onPressed,
      depth: depth,
      surfaceColor: surfaceColor,
      depthColor: depthColor,
      borderRadius: AnimalRadii.pillBorder,
      border: border,
      extraShadows: extraShadows,
      padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      disabled: disabled || loading,
      semanticLabel: loading ? 'Loading' : null,
      child: Container(
        height: size.height,
        alignment: Alignment.center,
        child: content,
      ),
    );

    if (type == AnimalButtonType.dashed && !disabled) {
      final dashColor = isDanger
          ? theme.error
          : (theme.isDark ? theme.border : AnimalColors.borderLight);
      pressable = CustomPaint(
        foregroundPainter: _DashedPillPainter(color: dashColor, strokeWidth: 1.6),
        child: pressable,
      );
    }

    final Widget buttonResult = pressable;

    if (block) {
      return SizedBox(width: double.infinity, child: buttonResult);
    }
    return buttonResult;
  }
}

class _DashedPillPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DashedPillPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(size.height / 2),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();

    const dashLength = 5.0;
    const dashGap = 4.0;

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashLength < metric.length)
            ? dashLength
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPillPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

