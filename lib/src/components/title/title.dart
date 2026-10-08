import 'package:flutter/material.dart';

import '../../foundation/theme/colors.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/painting/ribbon_painter.dart';

/// Size of an [AnimalTitle] ribbon.
enum AnimalTitleSize {
  /// 36 logical pixels high.
  small,

  /// 48 logical pixels high.
  middle,

  /// 64 logical pixels high.
  large,
}

/// Metrics of each [AnimalTitleSize]. Package-internal: the root library
/// exports the enum without this extension.
extension AnimalTitleSizeMetrics on AnimalTitleSize {
  /// Height of the ribbon.
  double get height => switch (this) {
    AnimalTitleSize.small => 36,
    AnimalTitleSize.middle => 48,
    AnimalTitleSize.large => 64,
  };

  /// Font size of the title.
  double get fontSize => switch (this) {
    AnimalTitleSize.small => 16,
    AnimalTitleSize.middle => 22,
    AnimalTitleSize.large => 30,
  };

  /// Width of each swallowtail wing.
  double get wingWidth => switch (this) {
    AnimalTitleSize.small => 16,
    AnimalTitleSize.middle => 24,
    AnimalTitleSize.large => 32,
  };

  /// Depth of the folded corner below the ribbon.
  double get foldDrop => switch (this) {
    AnimalTitleSize.small => 6,
    AnimalTitleSize.middle => 8,
    AnimalTitleSize.large => 10,
  };
}

/// Swallowtail ribbon Title banner (C06).
///
/// Strictly adheres to canonical design laws:
/// - Swallowtail notched ribbon with 3D folded corner triangle shadows
/// - Font weight: 900 (bold playful typography)
/// - Heading semantics (`Semantics(header: true)`)
/// - Supports 13 Island app-tile color themes or dynamic [AnimalIslandTheme]
/// - Protected against narrow/infinite constraint overflows
class AnimalTitle extends StatelessWidget {
  /// Content shown on the ribbon.
  final Widget child;

  /// Size step of the ribbon. Defaults to [AnimalTitleSize.middle].
  final AnimalTitleSize size;

  /// Island tile color for the ribbon and text; null uses the theme primary
  /// colors.
  final AnimalTileColor? color;

  /// Front ribbon color; takes precedence over [color]. The back and fold
  /// shades are derived from it.
  final Color? customFrontColor;

  /// Text color; takes precedence over [color].
  final Color? customTextColor;

  /// Label of the heading semantics node; null adds no label.
  final String? semanticLabel;

  /// Creates a ribbon title around [child].
  const AnimalTitle({
    super.key,
    required this.child,
    this.size = AnimalTitleSize.middle,
    this.color,
    this.customFrontColor,
    this.customTextColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final tile = color == null ? null : theme.colors.tile(color!);
    final front = customFrontColor ?? tile?.background ?? theme.colors.primary;
    final hsl = HSLColor.fromColor(front);
    final back = hsl
        .withLightness((hsl.lightness * 0.8).clamp(0.0, 1.0))
        .toColor();
    final fold = hsl
        .withLightness((hsl.lightness * 0.5).clamp(0.0, 1.0))
        .toColor();
    final textColor =
        customTextColor ?? tile?.foreground ?? theme.colors.onPrimary;

    return Semantics(
      header: true,
      label: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return IntrinsicWidth(
            child: SizedBox(
              height: size.height,
              child: CustomPaint(
                painter: AnimalRibbonPainter(
                  frontColor: front,
                  backColor: back,
                  foldColor: fold,
                  wingWidth: size.wingWidth,
                  foldDrop: size.foldDrop,
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    left: size.wingWidth + theme.spacing.md,
                    right: size.wingWidth + theme.spacing.md,
                    bottom: size.foldDrop,
                  ),
                  child: DefaultTextStyle(
                    style: theme.typography.resolve(
                      TextStyle(
                        fontSize: size.fontSize,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
