import 'package:flutter/material.dart';

/// Viewport-wide presentation has Overlay-owned semantics, independent of a
/// zero-size/offscreen trigger. Anchored panels intentionally use OverlayPortal.
/// Captures framework themes, locale, direction and media. Resolve application
/// provider values in the host before passing opaque content into this surface.
class ViewportOverlay extends StatefulWidget {
  const ViewportOverlay({
    super.key,
    required this.visible,
    required this.builder,
    this.decorative = false,
    this.blocksBackgroundSemantics = false,
  });
  final bool visible;

  /// Pure paint: exclude the entire entry, including framework wrapper semantics.
  final bool decorative;

  /// Must surround captured locale semantics so blocking reaches older entries.
  /// The surface owner decides when its background is unavailable.
  final bool blocksBackgroundSemantics;
  final WidgetBuilder builder;
  @override
  State<ViewportOverlay> createState() => _ViewportOverlayState();
}

class _ViewportOverlayState extends State<ViewportOverlay> {
  OverlayEntry? entry;
  OverlayState? owner;
  bool scheduled = false;
  void schedule() {
    if (scheduled) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (!mounted) return;
      final nextOwner = Overlay.of(context, rootOverlay: true);
      if (!widget.visible || nextOwner != owner) remove();
      owner = nextOwner;
      if (!widget.visible) return;
      if (entry == null) {
        entry = OverlayEntry(
          builder: (_) {
            final media = MediaQuery.of(context);
            return BlockSemantics(
              blocking: widget.blocksBackgroundSemantics,
              child: ExcludeSemantics(
                excluding: widget.decorative,
                child: IgnorePointer(
                  ignoring: widget.decorative,
                  child: Focus(
                    includeSemantics: false,
                    // Visual placement belongs to Overlay; keyboard traversal remains
                    // in the presenting route's scope. This node is borrowed.
                    parentNode: FocusScope.of(context),
                    canRequestFocus: false,
                    skipTraversal: true,
                    child: InheritedTheme.captureAll(
                      context,
                      Localizations.override(
                        context: context,
                        child: Directionality(
                          textDirection: Directionality.of(context),
                          child: LayoutBuilder(
                            builder: (overlayContext, constraints) =>
                                MediaQuery(
                                  data: media.copyWith(
                                    size: constraints.biggest,
                                  ),
                                  child: Material(
                                    type: MaterialType.transparency,
                                    animationDuration: Duration.zero,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Builder(builder: widget.builder),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
        owner!.insert(entry!);
      } else {
        entry!.markNeedsBuild();
      }
    });
  }

  void remove() {
    entry?.remove();
    entry?.dispose();
    entry = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    schedule();
  }

  @override
  void didUpdateWidget(ViewportOverlay old) {
    super.didUpdateWidget(old);
    schedule();
  }

  @override
  void dispose() {
    remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Register dependencies so frozen theme captures refresh while open.
    Theme.of(context);
    IconTheme.of(context);
    DefaultTextStyle.of(context);
    return const SizedBox.shrink();
  }
}
