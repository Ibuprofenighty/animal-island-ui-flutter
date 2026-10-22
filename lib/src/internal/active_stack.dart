import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Retains keyed child subtrees but sizes and hit-tests only the active child.
class ActiveStack extends MultiChildRenderObjectWidget {
  const ActiveStack({super.key, required this.index, required super.children});
  final int index;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderActiveStack(index);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderActiveStack renderObject,
  ) => renderObject.index = index;
}

class _ActiveData extends ContainerBoxParentData<RenderBox> {}

class _RenderActiveStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ActiveData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ActiveData> {
  _RenderActiveStack(this._index);
  int _index;
  set index(int value) {
    if (value != _index) {
      _index = value;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ActiveData) child.parentData = _ActiveData();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    var child = firstChild;
    var i = 0;
    Size active = Size.zero;
    while (child != null) {
      if (i == _index) active = child.getDryLayout(constraints.loosen());
      child = childAfter(child);
      i++;
    }
    return constraints.constrain(active);
  }

  @override
  void performLayout() {
    var child = firstChild;
    var i = 0;
    Size active = Size.zero;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      (child.parentData! as _ActiveData).offset = Offset.zero;
      if (i == _index) active = child.size;
      child = childAfter(child);
      i++;
    }
    size = constraints.constrain(active);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    var i = 0;
    while (child != null) {
      if (i == _index) {
        context.paintChild(child, offset);
        return;
      }
      child = childAfter(child);
      i++;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = firstChild;
    var i = 0;
    while (child != null) {
      if (i == _index) return child.hitTest(result, position: position);
      child = childAfter(child);
      i++;
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    var i = 0;
    while (child != null) {
      if (i == _index) visitor(child);
      child = childAfter(child);
      i++;
    }
  }
}
