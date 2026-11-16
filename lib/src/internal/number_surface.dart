import 'package:flutter/material.dart';

import '../foundation/dashed_border.dart';
import '../foundation/recipes/number.dart';

/// Shared outer numeric surface; content, semantics and time remain caller-owned.
class NumberSurface extends StatelessWidget {
  const NumberSurface({super.key, required this.island, required this.child});

  final bool island;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: island
        ? IslandDashedBorderPainter(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: NumberColors.islandSurfaceBorder,
            strokeWidth: 2,
          )
        : null,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: island ? 22 : 18,
        vertical: island ? 15 : 12,
      ),
      decoration: BoxDecoration(
        color: island ? NumberColors.islandSurface : NumberColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: island
            ? null
            : const [
                BoxShadow(
                  color: NumberColors.surfaceShadow,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
      ),
      child: child,
    ),
  );
}
