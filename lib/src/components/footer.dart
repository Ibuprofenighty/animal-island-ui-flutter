import '../foundation/theme.dart';

import 'package:flutter/material.dart';

class IslandFooter extends StatelessWidget {
  const IslandFooter({
    super.key,
    this.text = 'All Rights Reserved.',
    this.year,
    this.style,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });
  final String text;
  final int? year;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: SizedBox(
      width: double.infinity,
      child: Text(
        '© ${year ?? DateTime.now().year} $text',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: IslandTheme.of(context).muted,
          letterSpacing: 0,
        ).merge(style),
      ),
    ),
  );
}
