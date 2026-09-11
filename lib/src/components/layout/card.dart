import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';

/// Card style types matching animal-island-ui.
enum AnimalCardType {
  defaultCard,
  dashed,
}

/// Card background pattern types.
enum AnimalCardPattern {
  none,
  dots,
  sprinkles,
  stripes,
}

/// Animal Island 20px-radius Card.
///
/// Strictly adheres to canonical design laws:
/// - Fixed 20px border radius
/// - Hard rule 8: Card has NO default box-shadow; lifts with translateY(-2px) when [hoverable] is true
/// - Supports 13 Island app-tile color themes
/// - Supports dashed border and organic patterns (dots, sprinkles, stripes)
/// - Full keyboard accessibility when interactive (Tab to focus, Space / Enter to activate when [onTap] is provided)
class AnimalCard extends StatefulWidget {
  final Widget child;
  final AnimalCardType type;
  final AnimalTileColor color;
  final AnimalCardPattern pattern;
  final Color? customBackgroundColor;
  final Color? customBorderColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hoverable;
  final bool patterned;

  const AnimalCard({
    super.key,
    required this.child,
    this.type = AnimalCardType.defaultCard,
    this.color = AnimalTileColor.def,
    this.pattern = AnimalCardPattern.none,
    this.customBackgroundColor,
    this.customBorderColor,
    this.padding = const EdgeInsets.all(20.0),
    this.onTap,
    this.hoverable = false,
    this.patterned = false,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  bool _isHovered = false;
  bool _isFocused = false;

  AnimalCardPattern get _effectivePattern {
    if (widget.pattern != AnimalCardPattern.none) return widget.pattern;
    if (widget.patterned) return AnimalCardPattern.dots;
    return AnimalCardPattern.none;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final isDefault = widget.color == AnimalTileColor.def;
    final bgColor = widget.customBackgroundColor ??
        (isDefault ? theme.bgContent : widget.color.background);
    final defaultTextColor = isDefault ? theme.textBody : widget.color.text;
    final hasPattern = _effectivePattern != AnimalCardPattern.none;

    final borderColor = widget.customBorderColor ??
        (hasPattern
            ? defaultTextColor.withValues(alpha: 0.25)
            : (theme.isDark
                ? theme.border.withValues(alpha: 0.4)
                : AnimalColors.borderLight.withValues(alpha: 0.6)));

    final isInteractive = widget.hoverable || widget.onTap != null;
    final double offsetY = (_isHovered && isInteractive) ? -2.0 : 0.0;

    Widget coreContent = DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'Nunito',
        fontFamilyFallback: const ['Noto Sans SC', 'sans-serif'],
        color: defaultTextColor,
      ),
      child: widget.child,
    );

    Widget cardContent = coreContent;
    if (hasPattern) {
      cardContent = CustomPaint(
        foregroundPainter: _PatternCardPainter(
          pattern: _effectivePattern,
          color: defaultTextColor.withValues(alpha: 0.08),
          radius: AnimalRadii.card,
        ),
        child: cardContent,
      );
    }

    Widget card = AnimatedContainer(
      duration: AnimalMotion.fast,
      curve: AnimalMotion.ease,
      transform: Matrix4.translationValues(0, offsetY, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AnimalRadii.cardBorder,
        border: widget.type == AnimalCardType.dashed
            ? null
            : Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (_isHovered && isInteractive) AnimalShadows.softElevation,
          if (_isFocused)
            BoxShadow(
              color: theme.focusYellow.withValues(alpha: 0.65),
              spreadRadius: 2.5,
              blurRadius: 4,
            ),
        ],
      ),
      child: cardContent,
    );

    if (widget.type == AnimalCardType.dashed) {
      card = CustomPaint(
        foregroundPainter: _DashedCardPainter(
          color: borderColor,
          strokeWidth: 1.8,
          radius: AnimalRadii.card,
        ),
        child: card,
      );
    }

    if (widget.onTap != null) {
      return Semantics(
        button: true,
        enabled: true,
        child: FocusableActionDetector(
          enabled: true,
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (val) => setState(() => _isFocused = val),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap?.call();
                return null;
              },
            ),
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: card,
            ),
          ),
        ),
      );
    }

    if (isInteractive) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: card,
      );
    }

    return card;
  }
}

class _PatternCardPainter extends CustomPainter {
  final AnimalCardPattern pattern;
  final Color color;
  final double radius;

  const _PatternCardPainter({
    required this.pattern,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || pattern == AnimalCardPattern.none) return;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipRRect(rrect);

    switch (pattern) {
      case AnimalCardPattern.dots:
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        const spacing = 18.0;
        const dotRadius = 2.2;
        for (double y = spacing / 2; y < size.height; y += spacing) {
          final isOffsetRow = ((y / spacing).floor() % 2) == 1;
          final startX = isOffsetRow ? spacing : spacing / 2;
          for (double x = startX; x < size.width; x += spacing) {
            canvas.drawCircle(Offset(x, y), dotRadius, paint);
          }
        }
      case AnimalCardPattern.stripes:
        final stripePaint = Paint()
          ..color = color
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke;
        const spacing = 16.0;
        final total = size.width + size.height;
        for (double d = -size.height; d < total; d += spacing) {
          canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), stripePaint);
        }
      case AnimalCardPattern.sprinkles:
        final sprinklePaint = Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        const step = 28.0;
        int index = 0;
        for (double y = 14; y < size.height; y += step) {
          for (double x = 14; x < size.width; x += step) {
            index++;
            final angle = (index % 4) * 0.785;
            final dx = 5.0 * math.cos(angle);
            final dy = 5.0 * math.sin(angle);
            canvas.drawLine(Offset(x - dx, y - dy), Offset(x + dx, y + dy), sprinklePaint);
          }
        }
      case AnimalCardPattern.none:
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PatternCardPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.color != color || oldDelegate.radius != radius;
}

class _DashedCardPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  const _DashedCardPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
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
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().toList();

    const dashLength = 6.0;
    const dashGap = 5.0;

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
  bool shouldRepaint(covariant _DashedCardPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}

