import 'package:flutter/material.dart';

/// Defers expensive content until its placeholder approaches the scroll viewport.
class ViewportDeferred extends StatefulWidget {
  const ViewportDeferred({
    super.key,
    required this.builder,
    required this.placeholder,
    this.enabled = true,
  });
  final WidgetBuilder builder;
  final Widget placeholder;
  final bool enabled;
  @override
  State<ViewportDeferred> createState() => _ViewportDeferredState();
}

class _ViewportDeferredState extends State<ViewportDeferred> {
  ScrollPosition? position;
  bool activated = false, scheduled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next != position) {
      position?.removeListener(schedule);
      position = next;
      position?.addListener(schedule);
    }
    MediaQuery.sizeOf(context);
    schedule();
  }

  @override
  void didUpdateWidget(ViewportDeferred old) {
    super.didUpdateWidget(old);
    schedule();
  }

  void schedule() {
    if (activated || scheduled) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (!mounted || activated) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      final viewport = (Offset.zero & MediaQuery.sizeOf(context)).inflate(200);
      if (rect.overlaps(viewport)) setState(() => activated = true);
    });
  }

  @override
  void dispose() {
    position?.removeListener(schedule);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => !widget.enabled || activated
      ? widget.builder(context)
      : widget.placeholder;
}
