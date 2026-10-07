import 'package:flutter/material.dart';

import '../../internal/painting/blob_path.dart';

/// Painter that renders the organic smooth border around the blob modal.
class BlobModalPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  const BlobModalPainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
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

/// Organic blob surface container for `AnimalModal`.
///
/// Every visual value is resolved by the modal; the surface reads no theme.
class AnimalModalSurface extends StatelessWidget {
  final Widget child;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double width;
  final List<BoxShadow> shadows;
  final EdgeInsetsGeometry padding;

  const AnimalModalSurface({
    super.key,
    required this.child,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.width,
    required this.shadows,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(boxShadow: shadows),
      child: CustomPaint(
        painter: BlobModalPainter(
          fillColor: fillColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
        ),
        child: ClipPath(
          clipper: const AnimalBlobClipper(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
