import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';

/// Style variants for [AnimalTooltip].
enum AnimalTooltipVariant {
  /// Standard cozy 16px-radius rounded rectangle tooltip.
  standard,

  /// Organic speech bubble with pointer arrow beak.
  island,
}

/// Animal Island 16px-radius speech bubble Tooltip.
class AnimalTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final Widget? title;
  final AnimalTooltipVariant variant;
  final bool bordered;
  final TooltipTriggerMode triggerMode;
  final Duration waitDuration;

  const AnimalTooltip({
    super.key,
    required this.child,
    required this.message,
    this.title,
    this.variant = AnimalTooltipVariant.standard,
    this.bordered = true,
    this.triggerMode = TooltipTriggerMode.tap,
    this.waitDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final borderColor = theme.isDark ? theme.border : AnimalColors.borderLight;

    final Decoration decoration = variant == AnimalTooltipVariant.island
        ? ShapeDecoration(
            color: theme.bgContent,
            shadows: const [
              BoxShadow(
                color: Color.fromRGBO(61, 52, 40, 0.14),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            shape: _IslandBubbleShapeBorder(
              borderColor: bordered ? borderColor : Colors.transparent,
              borderWidth: bordered ? 1.5 : 0.0,
              radius: 16.0,
              arrowSize: 6.0,
            ),
          )
        : BoxDecoration(
            color: theme.bgContent,
            borderRadius: AnimalRadii.tooltipBorder,
            border: bordered ? Border.all(color: borderColor, width: 1.5) : null,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(61, 52, 40, 0.14),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          );

    return Tooltip(
      message: title == null ? message : '',
      richMessage: title != null
          ? TextSpan(
              children: [
                WidgetSpan(
                  child: DefaultTextStyle(
                    style: AnimalTypography.caption.copyWith(
                      color: theme.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.0,
                    ),
                    child: title!,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: message,
                    style: AnimalTypography.caption.copyWith(
                      color: theme.textBody,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ],
            )
          : null,
      triggerMode: triggerMode,
      waitDuration: waitDuration,
      showDuration: const Duration(seconds: 3),
      padding: EdgeInsets.fromLTRB(
        14.0,
        8.0,
        14.0,
        variant == AnimalTooltipVariant.island ? 14.0 : 8.0,
      ),
      decoration: decoration,
      textStyle: AnimalTypography.caption.copyWith(
        color: theme.text,
        fontWeight: FontWeight.w700,
        fontSize: 13.0,
      ),
      child: child,
    );
  }
}

class _IslandBubbleShapeBorder extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final double arrowSize;

  const _IslandBubbleShapeBorder({
    required this.borderColor,
    this.borderWidth = 1.5,
    this.radius = 16.0,
    this.arrowSize = 6.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowSize);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(borderWidth), textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final bubbleRect = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width,
      rect.height - arrowSize,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(bubbleRect, Radius.circular(radius)));

    final arrowCenterX = rect.center.dx;
    final arrowTop = bubbleRect.bottom;
    final arrowBottom = rect.bottom;

    final arrowPath = Path()
      ..moveTo(arrowCenterX - arrowSize * 1.2, arrowTop)
      ..lineTo(arrowCenterX, arrowBottom)
      ..lineTo(arrowCenterX + arrowSize * 1.2, arrowTop)
      ..close();

    return Path.combine(PathOperation.union, path, arrowPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderWidth <= 0 || borderColor == Colors.transparent) return;
    final path = getOuterPath(rect, textDirection: textDirection);
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) => _IslandBubbleShapeBorder(
        borderColor: borderColor,
        borderWidth: borderWidth * t,
        radius: radius * t,
        arrowSize: arrowSize * t,
      );
}

