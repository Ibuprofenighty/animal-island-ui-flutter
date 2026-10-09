import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Builds [builder] twice in its first frame: first for a [firstWidth] wide
/// box, then for the incoming constraints. Later frames build it for the
/// incoming constraints only.
///
/// Both builds update the same element before the frame's post-frame
/// callbacks run, so a test can replace a component's input, or remove the
/// component, between the moment it defers a callback and the end of that
/// frame. [builder] receives the width it is built for.
class SameFrameRebuild extends StatelessWidget {
  /// Creates a box that builds [builder] for [firstWidth], then for its own
  /// constraints.
  const SameFrameRebuild({
    super.key,
    required this.firstWidth,
    required this.builder,
  });

  /// Width of the first build.
  final double firstWidth;

  /// Builds the child for a given width.
  final Widget Function(double width) builder;

  @override
  Widget build(BuildContext context) => _LayoutTwice(
    firstWidth: firstWidth,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          builder(constraints.maxWidth),
    ),
  );
}

class _LayoutTwice extends SingleChildRenderObjectWidget {
  const _LayoutTwice({required this.firstWidth, required super.child});

  final double firstWidth;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderLayoutTwice(firstWidth);
}

class _RenderLayoutTwice extends RenderProxyBox {
  _RenderLayoutTwice(this.firstWidth);

  final double firstWidth;
  bool _laidOut = false;

  @override
  void performLayout() {
    final RenderBox child = this.child!;
    if (!_laidOut) {
      _laidOut = true;
      child.layout(
        BoxConstraints(maxWidth: firstWidth, maxHeight: constraints.maxHeight),
        parentUsesSize: true,
      );
    }
    child.layout(constraints, parentUsesSize: true);
    size = child.size;
  }
}
