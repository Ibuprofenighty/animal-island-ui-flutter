import 'package:flutter/material.dart';

import '../../internal/painting/blob_path.dart';
import '../../foundation/theme/theme.dart';

/// Painter that renders the organic smooth border around the blob modal.
class BlobModalPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  const BlobModalPainter({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final path = AnimalBlobPath.buildPath(size);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    if (borderWidth > 0 && borderColor != Colors.transparent) {
      final borderPaint = Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BlobModalPainter oldDelegate) =>
      oldDelegate.fillColor != fillColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}

/// Organic blob surface container for [AnimalModal].
class AnimalModalSurface extends StatelessWidget {
  final Widget child;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double width;

  const AnimalModalSurface({
    super.key,
    required this.child,
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 2.0,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    return Container(
      width: width,
      decoration: BoxDecoration(boxShadow: theme.shadows.modal),
      child: CustomPaint(
        painter: BlobModalPainter(
          fillColor: fillColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
        ),
        child: ClipPath(
          clipper: const AnimalBlobClipper(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.xxl + theme.spacing.xs,
              vertical: theme.spacing.xxl,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
