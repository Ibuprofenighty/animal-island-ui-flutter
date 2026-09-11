import 'package:flutter/widgets.dart';
import '../../tokens/theme.dart';

enum AnimalBackgroundType {
  parchment,
  dots,
  grid,
}

/// Animal Island wallpaper / container background.
class AnimalBackground extends StatelessWidget {
  final Widget? child;
  final AnimalBackgroundType type;
  final Color? backgroundColor;
  final Color? patternColor;
  final bool expand;

  const AnimalBackground({
    super.key,
    this.child,
    this.type = AnimalBackgroundType.dots,
    this.backgroundColor,
    this.patternColor,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final bg = backgroundColor ?? theme.bg;
    final pattern = patternColor ??
        (theme.isDark
            ? theme.border.withValues(alpha: 0.15)
            : const Color(0xFFEFE8D6));

    final wrappedChild = DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'Nunito',
        fontFamilyFallback: const ['Noto Sans SC', 'sans-serif'],
        color: theme.text,
      ),
      child: child ?? const SizedBox.shrink(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        Widget content = wrappedChild;
        if (expand && (hasBoundedWidth || hasBoundedHeight)) {
          content = SizedBox(
            width: hasBoundedWidth ? constraints.maxWidth : null,
            height: hasBoundedHeight ? constraints.maxHeight : null,
            child: wrappedChild,
          );
        }

        if (type == AnimalBackgroundType.parchment) {
          return Container(
            color: bg,
            child: content,
          );
        }

        return CustomPaint(
          painter: _BackgroundPatternPainter(
            type: type,
            bgColor: bg,
            patternColor: pattern,
          ),
          child: content,
        );
      },
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final AnimalBackgroundType type;
  final Color bgColor;
  final Color patternColor;

  _BackgroundPatternPainter({
    required this.type,
    required this.bgColor,
    required this.patternColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    final patternPaint = Paint()
      ..color = patternColor
      ..strokeWidth = 1.0;

    const spacing = 28.0;

    if (type == AnimalBackgroundType.dots) {
      patternPaint.style = PaintingStyle.fill;
      for (double y = spacing / 2; y < size.height; y += spacing) {
        for (double x = spacing / 2; x < size.width; x += spacing) {
          canvas.drawCircle(Offset(x, y), 2.0, patternPaint);
        }
      }
    } else if (type == AnimalBackgroundType.grid) {
      patternPaint.style = PaintingStyle.stroke;
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), patternPaint);
      }
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), patternPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.bgColor != bgColor ||
      oldDelegate.patternColor != patternColor;
}
