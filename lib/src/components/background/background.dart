import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';
import 'background_painter.dart';

export 'background_painter.dart';

/// Animal Island wallpaper / container background (C08).
///
/// Features:
/// - Supports [AnimalBackgroundType.parchment], [dots], and [grid]
/// - Theme color awareness with accessible contrast
/// - Robust bounded and unbounded constraint layout contracts
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
    final bg = backgroundColor ?? theme.colors.bg;
    final pattern =
        patternColor ??
        ((theme.colors.brightness == Brightness.dark)
            ? theme.colors.border.withValues(alpha: 0.15)
            : theme.colors.bgSecondary);

    final wrappedChild = DefaultTextStyle(
      style: theme.typography.body.copyWith(color: theme.colors.text),
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
          return Container(color: bg, child: content);
        }

        return CustomPaint(
          painter: AnimalBackgroundPainter(
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
