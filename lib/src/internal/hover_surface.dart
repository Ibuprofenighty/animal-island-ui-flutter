import 'package:flutter/widgets.dart';

/// Pointer observation only; does not invent activation or own child state.
class HoverSurface extends StatefulWidget {
  const HoverSurface({
    super.key,
    required this.builder,
    this.enabled = true,
    this.cursor = SystemMouseCursors.click,
  });
  final bool enabled;
  final MouseCursor cursor;
  final Widget Function(Set<WidgetState>) builder;
  @override
  State<HoverSurface> createState() => _HoverSurfaceState();
}

class _HoverSurfaceState extends State<HoverSurface> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: widget.enabled ? widget.cursor : MouseCursor.defer,
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: widget.builder({if (hovered && widget.enabled) WidgetState.hovered}),
  );
}
