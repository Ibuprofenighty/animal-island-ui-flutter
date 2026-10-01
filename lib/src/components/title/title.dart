import 'package:flutter/material.dart';

import '../../foundation/theme/colors.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/painting/ribbon_painter.dart';

/// Dimensions for [AnimalTitle] ribbon component.
enum AnimalTitleSize {
  small(height: 36.0, fontSize: 16.0, wingWidth: 16.0, foldDrop: 6.0),
  middle(height: 48.0, fontSize: 22.0, wingWidth: 24.0, foldDrop: 8.0),
  large(height: 64.0, fontSize: 30.0, wingWidth: 32.0, foldDrop: 10.0);

  final double height;
  final double fontSize;
  final double wingWidth;
  final double foldDrop;

  const AnimalTitleSize({
    required this.height,
    required this.fontSize,
    required this.wingWidth,
    required this.foldDrop,
  });
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
  final Widget child;
  final AnimalTitleSize size;
  final AnimalTileColor? color;
  final Color? customFrontColor;
  final Color? customTextColor;
  final String? semanticLabel;

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
