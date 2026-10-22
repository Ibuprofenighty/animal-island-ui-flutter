import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/background_type.dart';
import '../internal/background_painter.dart';

/// Paints behind the child; never rewrites child styles or intercepts input.
class IslandBackground extends StatelessWidget {
  const IslandBackground({
    super.key,
    this.type = IslandBackgroundType.cream,
    this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.sceneScale = 1,
  }) : assert(sceneScale > 0);
  final IslandBackgroundType type;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double sceneScale;
  @override
  Widget build(BuildContext context) {
    final scene =
        type == IslandBackgroundType.sweetCorner ||
        type == IslandBackgroundType.coffeeBreak;
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        painter: BackgroundPainter(type),
        child: Stack(
          children: [
            if (scene)
              Positioned.fill(
                child: ExcludeSemantics(
                  child: Transform.scale(
                    scale: sceneScale,
                    child: SvgPicture.asset(
                      'assets/scenes/${type.referenceName}.svg',
                      package: 'animal_island_ui',
                      fit: sceneScale == 1 ? BoxFit.cover : BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            Padding(padding: padding, child: child ?? const SizedBox.expand()),
          ],
        ),
      ),
    );
  }
}
