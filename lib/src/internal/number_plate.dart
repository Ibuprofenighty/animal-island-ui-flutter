import 'package:flutter/material.dart';

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
          island ? const Color(0xfffffdf4) : Colors.white,
          const Color(0xfff8f8f0),
        ],
      ),
      border: bordered
          ? Border.all(color: Color(island ? 0xffd4c4a8 : 0xffd4c9b4), width: 1)
          : null,
    ),
    child: child,
  );
}
