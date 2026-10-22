import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Layout-only overlap; child types, styles, keys and behavior remain opaque.
class OverlappingRow extends MultiChildRenderObjectWidget {
  const OverlappingRow({
    super.key,
    required super.children,
    required this.overlap,
  });
  final double overlap;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _OverlapRender(overlap, Directionality.of(context));
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _OverlapRender renderObject,
  ) {
    renderObject
      ..overlap = overlap
      ..direction = Directionality.of(context);
  }
}

class _OverlapData extends ContainerBoxParentData<RenderBox> {}

class _OverlapRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverlapData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverlapData> {
  _OverlapRender(this._overlap, this._direction);
  double _overlap;
  TextDirection _direction;
  set overlap(double value) {
    if (value != _overlap) {
      _overlap = value;
      markNeedsLayout();
    }
  }

  set direction(TextDirection value) {
    if (value != _direction) {
      _direction = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverlapData) child.parentData = _OverlapData();
  }

  Size measure(BoxConstraints constraints, {required bool dry}) {
    var width = 0.0, height = 0.0;
    var child = firstChild;
    final loose = BoxConstraints(maxHeight: constraints.maxHeight);
    while (child != null) {
      final Size s;
      if (dry) {
        s = child.getDryLayout(loose);
      } else {
        child.layout(loose, parentUsesSize: true);
        s = child.size;
      }
      final data = child.parentData! as _OverlapData;
      if (!dry) data.offset = Offset(width, 0);
      width += s.width;
      if (data.nextSibling != null) width -= math.min(_overlap, s.width);
      height = math.max(height, s.height);
      child = data.nextSibling;
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      measure(constraints, dry: true);
  @override
  void performLayout() {
    size = measure(constraints, dry: false);
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _OverlapData;
      data.offset = Offset(
        _direction == TextDirection.rtl
            ? size.width - data.offset.dx - child.size.width
            : data.offset.dx,
        (size.height - child.size.height) / 2,
      );
      child = data.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
