import 'package:flutter/widgets.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';

/// Footprint decoration types matching upstream animal-island-ui.
enum AnimalFooterType {
  /// Gentle shoreline ocean wave crests.
  sea,

  /// Cozy island pine and apple tree forest canopy silhouette.
  tree,
}

/// Animal Island footer decoration with gentle wave shoreline or forest tree silhouette.
class AnimalFooter extends StatelessWidget {
  /// Footer top silhouette decoration style.
  final AnimalFooterType type;

  /// Whether the footer seamlessly blends into the bottom without top margin.
  final bool seamless;

  /// Custom content inside the footer.
  final Widget? content;

  /// Fallback text when [content] is null.
  final String? defaultText;

  const AnimalFooter({
    super.key,
    this.type = AnimalFooterType.sea,
    this.seamless = false,
    this.content,
    this.defaultText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final footerColor = theme.surfaceSubtle;
    final decoHeight = type == AnimalFooterType.tree ? 32.0 : 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: availableWidth,
              height: decoHeight,
              child: CustomPaint(
                size: Size(availableWidth, decoHeight),
                painter: type == AnimalFooterType.tree
                    ? _TreeCanopyPainter(color: footerColor)
                    : _ShorelineWavePainter(color: footerColor),
              ),
            ),
            Container(
              width: double.infinity,
              color: footerColor,
              padding: EdgeInsets.symmetric(
                vertical: seamless ? 16.0 : 24.0,
                horizontal: 20.0,
              ),
              alignment: Alignment.center,
              child: content ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LeafIcon(size: 18, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        defaultText ?? 'Animal Island UI • Crafted with cozy care',
                        style: AnimalTypography.captionFor(context),
                      ),
                    ],
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _ShorelineWavePainter extends CustomPainter {
  final Color color;

  const _ShorelineWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, size.height);

    const waveWidth = 32.0;
    double currentX = 0.0;

    while (currentX < size.width) {
      path.quadraticBezierTo(
        currentX + waveWidth / 2,
        0,
        currentX + waveWidth,
        size.height,
      );
      currentX += waveWidth;
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShorelineWavePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TreeCanopyPainter extends CustomPainter {
  final Color color;

  const _TreeCanopyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, size.height);

    const treeWidth = 44.0;
    double currentX = 0.0;

    while (currentX < size.width) {
      path.cubicTo(
        currentX + 6.0,
        size.height * 0.4,
        currentX + treeWidth * 0.25,
        0,
        currentX + treeWidth * 0.5,
        0,
      );
      path.cubicTo(
        currentX + treeWidth * 0.75,
        0,
        currentX + treeWidth - 6.0,
        size.height * 0.4,
        currentX + treeWidth,
        size.height,
      );
      currentX += treeWidth;
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TreeCanopyPainter oldDelegate) =>
      oldDelegate.color != color;
}
