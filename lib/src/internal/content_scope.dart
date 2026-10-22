import 'package:flutter/material.dart';

/// Slot-local defaults. Explicit descendants retain their own styling.
class ContentScope extends StatelessWidget {
  const ContentScope({
    super.key,
    required this.child,
    this.textStyle,
    this.iconColor,
    this.iconSize,
    this.softWrap,
    this.overflow,
  });
  final Widget child;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final bool? softWrap;
  final TextOverflow? overflow;
  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: textStyle,
    softWrap: softWrap,
    overflow: overflow,
    child: IconTheme.merge(
      data: IconThemeData(color: iconColor ?? textStyle?.color, size: iconSize),
      child: child,
    ),
  );
}
