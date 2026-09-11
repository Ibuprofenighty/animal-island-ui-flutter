import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/theme.dart';
import '../../primitives/ribbon_painter.dart';

/// Dimensions for AnimalTitle ribbon component.
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

/// Swallowtail ribbon Title banner.
///
/// Strictly adheres to canonical design laws:
/// - Swallowtail notched ribbon with 3D folded corner triangle shadows
/// - Font weight: 900 (never light)
/// - Supports 13 Island app-tile color themes or dynamic [AnimalIslandTheme]
class AnimalTitle extends StatelessWidget {
  final Widget child;
  final AnimalTitleSize size;
  final AnimalTileColor? color;
  final Color? customFrontColor;
  final Color? customTextColor;

  const AnimalTitle({
    super.key,
    required this.child,
    this.size = AnimalTitleSize.middle,
    this.color,
    this.customFrontColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final front = customFrontColor ?? color?.background ?? theme.primary;
    final back = HSLColor.fromColor(front).withLightness((HSLColor.fromColor(front).lightness * 0.8).clamp(0.0, 1.0)).toColor();
    final fold = HSLColor.fromColor(front).withLightness((HSLColor.fromColor(front).lightness * 0.5).clamp(0.0, 1.0)).toColor();
    final textColor = customTextColor ?? color?.text ?? const Color(0xFFFFFFFF);

    return Semantics(
      header: true,
      child: IntrinsicWidth(
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
                left: size.wingWidth + 12.0,
                right: size.wingWidth + 12.0,
                bottom: size.foldDrop,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontFamilyFallback: const ['Noto Sans SC', 'sans-serif'],
                  fontSize: size.fontSize,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
