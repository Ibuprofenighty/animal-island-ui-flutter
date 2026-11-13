import 'package:flutter/material.dart';

import '../foundation/recipes/number.dart';

/// Shared numeric plate skin. The owning component supplies its content/timeline.
class NumberPlate extends StatelessWidget {
  const NumberPlate({
    super.key,
    required this.child,
    required this.island,
    required this.bordered,
  });
  final Widget child;
  final bool island, bordered;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          island ? NumberColors.islandPlateTop : NumberColors.plateTop,
          NumberColors.plateBottom,
        ],
      ),
      border: bordered
          // Reference `.bordered .unit/.plate { border: 1.5px solid }`.
          ? Border.all(
              color: island
                  ? NumberColors.islandPlateBorder
                  : NumberColors.plateBorder,
              width: 1.5,
            )
          : null,
    ),
    child: child,
  );
}
