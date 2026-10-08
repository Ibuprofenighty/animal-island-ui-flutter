import 'package:flutter/material.dart';

import '../../internal/painting/blob_path.dart';

/// Painter that renders the organic smooth border around the blob modal.
class BlobModalPainter extends CustomPainter {
  /// Fill of the blob shape.
  final Color fillColor;

  /// Color of the blob outline; a transparent color skips the outline.
  final Color borderColor;

  /// Width of the blob outline in logical pixels; zero or less skips it.
  final double borderWidth;

  /// Creates a painter for the blob fill and outline.
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

    if (borderWidth > 0 && borderColor.a > 0) {
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
  /// Content clipped to the blob shape.
  final Widget child;

  /// Fill of the blob shape.
  final Color fillColor;

  /// Color of the blob outline.
  final Color borderColor;

  /// Width of the blob outline in logical pixels.
  final double borderWidth;

  /// Width of the surface in logical pixels.
  final double width;

  /// Shadows painted under the surface's bounding box.
  final List<BoxShadow> shadows;

  /// Space between the blob edge and [child].
  final EdgeInsetsGeometry padding;

  /// Creates a blob surface around [child].
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
