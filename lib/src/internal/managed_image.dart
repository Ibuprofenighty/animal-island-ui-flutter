import 'package:flutter/widgets.dart';

/// Decode/render ownership with once-per-source, post-frame lifecycle callbacks.
class ManagedImage extends StatefulWidget {
  const ManagedImage({
    super.key,
    required this.image,
    this.fit = BoxFit.fill,
    this.width,
    this.height,
    this.onLoaded,
    this.onError,
    required this.errorBuilder,
  });
  final ImageProvider image;
  final BoxFit fit;
  final double? width, height;
  final VoidCallback? onLoaded;
  final bool Function(Object, StackTrace?)? onError;
  final Widget Function(BuildContext, Object, StackTrace?, bool) errorBuilder;
  @override
  State<ManagedImage> createState() => _ManagedImageState();
}

class _ManagedImageState extends State<ManagedImage> {
  bool loaded = false, failed = false, allowFallback = true;
  int generation = 0;
  @override
  void didUpdateWidget(ManagedImage old) {
    super.didUpdateWidget(old);
    if (old.image != widget.image) {
      generation++;
      loaded = false;
      failed = false;
      allowFallback = true;
    }
  }

  @override
  void dispose() {
    generation++;
    super.dispose();
  }

  void notifyLoaded() {
    if (loaded || failed) return;
    loaded = true;
    final token = generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && token == generation) widget.onLoaded?.call();
    });
  }

  @override
  Widget build(BuildContext context) => Image(
    key: ValueKey(widget.image),
    image: widget.image,
    width: widget.width,
    height: widget.height,
    fit: widget.fit,
    excludeFromSemantics: true,
    frameBuilder: (_, child, frame, synchronous) {
      if (frame != null || synchronous) notifyLoaded();
      return child;
    },
    errorBuilder: (context, error, stack) {
      if (!failed) {
        failed = true;
        final token = generation;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || token != generation) return;
          final allow = widget.onError?.call(error, stack) ?? true;
          if (mounted && token == generation && allow != allowFallback)
            setState(() => allowFallback = allow);
        });
      }
      return widget.errorBuilder(context, error, stack, allowFallback);
    },
  );
}
