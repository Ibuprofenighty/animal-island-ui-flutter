import 'package:flutter/material.dart';

import '../foundation/dashed_border.dart';

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
            color: const Color(0xffd4c4a8),
            strokeWidth: 2,
          )
        : null,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: island ? 22 : 18,
        vertical: island ? 15 : 12,
      ),
      decoration: BoxDecoration(
        color: Color(island ? 0xfff7f3df : 0xfff8f8f0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: island
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0f3d3428),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
      ),
      child: child,
    ),
  );
}
