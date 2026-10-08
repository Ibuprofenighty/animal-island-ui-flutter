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
  /// Content placed over the background; null paints the background only.
  final Widget? child;

  /// Pattern drawn over the fill. Defaults to [AnimalBackgroundType.dots].
  final AnimalBackgroundType type;

  /// Fill color; null uses the theme background color.
  final Color? backgroundColor;

  /// Color of the dots or grid lines; null derives a subtle color from the
  /// theme for the active brightness.
  final Color? patternColor;

  /// Whether the background fills the bounded incoming constraints.
  ///
  /// Each unbounded axis keeps the child's size. Defaults to true.
  final bool expand;

  /// Creates a themed background behind [child].
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
