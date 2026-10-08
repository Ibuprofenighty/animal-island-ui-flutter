import 'package:flutter/widgets.dart';

/// Footprint decoration types matching upstream animal-island-ui.
enum AnimalFooterType {
  /// Gentle shoreline ocean wave crests.
  sea,

  /// Cozy island pine and apple tree forest canopy silhouette.
  tree,
}

/// Painter for gentle wave shoreline silhouette on [AnimalFooter].
class AnimalShorelineWavePainter extends CustomPainter {
  /// Fill of the wave silhouette.
  final Color color;

  /// Creates a wave painter filled with [color].
  const AnimalShorelineWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    const waveWidth = 32.0;
    final waveCount = (size.width / waveWidth).ceil() + 1;

    for (int i = 0; i < waveCount; i++) {
      final startX = i * waveWidth;
      path.lineTo(startX, size.height * 0.4);
      path.quadraticBezierTo(
        startX + waveWidth * 0.5,
        0,
        startX + waveWidth,
        size.height * 0.4,
      );
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimalShorelineWavePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Painter for island forest canopy silhouette on [AnimalFooter].
class AnimalTreeCanopyPainter extends CustomPainter {
  /// Fill of the canopy silhouette.
  final Color color;

  /// Creates a canopy painter filled with [color].
  const AnimalTreeCanopyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    const treeWidth = 40.0;
    final treeCount = (size.width / treeWidth).ceil() + 1;

    for (int i = 0; i < treeCount; i++) {
      final startX = i * treeWidth;
      final isPine = (i % 2) == 0;

      if (isPine) {
        path.lineTo(startX + treeWidth * 0.2, size.height * 0.5);
        path.lineTo(startX + treeWidth * 0.5, 0);
        path.lineTo(startX + treeWidth * 0.8, size.height * 0.5);
      } else {
        path.lineTo(startX + treeWidth * 0.15, size.height * 0.4);
        path.arcToPoint(
          Offset(startX + treeWidth * 0.85, size.height * 0.4),
          radius: const Radius.circular(16),
          clockwise: true,
        );
      }
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimalTreeCanopyPainter oldDelegate) =>
      oldDelegate.color != color;
}
