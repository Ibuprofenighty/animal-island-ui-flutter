import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../foundation/theme.dart';
import '../internal/action_surface.dart';
import '../internal/content_scope.dart';
import '../internal/presentation_focus.dart';

@immutable
class IslandTab<T extends Object> {
  const IslandTab({
    required this.value,
    required this.label,
    required this.child,
    this.semanticLabel,
  });
  final T value;
  final Widget label, child;
  final String? semanticLabel;
}

/// Value-keyed tabs. Switching unmounts the old panel, matching the reference;
/// reordering the active item preserves its content and focus identity.
class IslandTabs<T extends Object> extends StatefulWidget {
  IslandTabs({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.shadow = true,
    this.semanticLabel,
  }) : initialValue = null,
       controlled = true,
       assert(items.map((item) => item.value).toSet().length == items.length);
  IslandTabs.uncontrolled({
    super.key,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.shadow = true,
    this.semanticLabel,
  }) : value = null,
       controlled = false,
       assert(items.map((item) => item.value).toSet().length == items.length);
  final List<IslandTab<T>> items;
  final T? value, initialValue;
  final ValueChanged<T>? onChanged;
  final bool shadow, controlled;
  final String? semanticLabel;
  @override
  State<IslandTabs<T>> createState() => _IslandTabsState<T>();
}

class _IslandTabsState<T extends Object> extends State<IslandTabs<T>> {
  late T? inner = widget.initialValue ?? widget.items.firstOrNull?.value;
  final nodes = <T, FocusNode>{};
  int presentationGeneration = 0;
  T? get value => widget.controlled ? widget.value : inner;
  @override
  void initState() {
    super.initState();
    syncNodes();
  }

  void syncNodes() {
    final keys = widget.items.map((item) => item.value).toSet();
    var removedFocus = false;
    for (final key in nodes.keys.toList()) {
      if (!keys.contains(key)) {
        final node = nodes.remove(key)!;
        removedFocus |= node.hasFocus;
        node.dispose();
      }
    }
    for (final key in keys) {
      nodes.putIfAbsent(key, () => FocusNode());
    }
    if (!widget.controlled && !keys.contains(inner))
      inner = widget.items.firstOrNull?.value;
    if (removedFocus)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) (nodes[value] ?? nodes.values.firstOrNull)?.requestFocus();
      });
  }

  @override
  void didUpdateWidget(IslandTabs<T> old) {
    super.didUpdateWidget(old);
    final reordered = !listEquals(
      old.items.map((item) => item.value).toList(),
      widget.items.map((item) => item.value).toList(),
    );
    final focused = nodes.entries
        .where((entry) => entry.value.hasPrimaryFocus)
        .firstOrNull;
    syncNodes();
    if (reordered &&
        focused != null &&
        identical(nodes[focused.key], focused.value)) {
      final generation = ++presentationGeneration;
      settlePresentationFocus(
        current: () =>
            mounted &&
            generation == presentationGeneration &&
            identical(nodes[focused.key], focused.value),
      );
    }
  }

  @override
  void dispose() {
    presentationGeneration++;
    for (final node in nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void choose(T next) {
    nodes[next]?.requestFocus();
    if (!widget.controlled) setState(() => inner = next);
    widget.onChanged?.call(next);
  }

  void move(int delta, {int? edge}) {
    if (widget.items.isEmpty) return;
    final focused = widget.items.indexWhere(
      (item) => nodes[item.value]!.hasFocus,
    );
    final selected = widget.items.indexWhere((item) => item.value == value);
    final from = focused >= 0
        ? focused
        : selected >= 0
        ? selected
        : 0;
    final index = edge ?? (from + delta) % widget.items.length;
    choose(widget.items[index].value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = IslandTheme.of(context);
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final active = widget.items
        .where((item) => item.value == value)
        .firstOrNull;
    final tabStop = active?.value ?? widget.items.firstOrNull?.value;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 250);
    for (final entry in nodes.entries) {
      entry.value.skipTraversal = entry.key != tabStop;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffe8e2d6), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                        move(direction),
                    const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                        move(-direction),
                    const SingleActivator(LogicalKeyboardKey.home): () =>
                        move(0, edge: 0),
                    const SingleActivator(LogicalKeyboardKey.end): () =>
                        move(0, edge: widget.items.length - 1),
                  },
                  child: Semantics(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? tokens.paper
                            : const Color(0x99ffffff),
                        border: const Border(
                          bottom: BorderSide(
                            color: Color(0xffe8e2d6),
                            width: 2,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Semantics(
                        role: SemanticsRole.tabBar,
                        label: widget.semanticLabel,
                        container: true,
                        explicitChildNodes: true,
                        child: _TabsHeader(
                          direction: Directionality.of(context),
                          children: [
                            for (var i = 0; i < widget.items.length; i++) ...[
                              Semantics(
                                key: ValueKey(widget.items[i].value),
                                role: SemanticsRole.tab,
                                selected: widget.items[i].value == value,
                                label: widget.items[i].semanticLabel,
                                child: ActionSurface(
                                  button: false,
                                  focusNode: nodes[widget.items[i].value],
                                  onActivate: () =>
                                      choose(widget.items[i].value),
                                  builder: (_, states) {
                                    final selected =
                                        widget.items[i].value == value;
                                    return AnimatedContainer(
                                      duration: duration,
                                      curve: const Cubic(.4, 0, .2, 1),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: selected && widget.shadow
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0x143d3428),
                                                  offset: Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? tokens.leaf
                                              : states.contains(
                                                  WidgetState.hovered,
                                                )
                                              ? tokens.leaf.withValues(
                                                  alpha: .1,
                                                )
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        foregroundDecoration:
                                            states.contains(WidgetState.focused)
                                            ? BoxDecoration(
                                                border: Border.all(
                                                  color: selected
                                                      ? tokens.onLeaf
                                                      : tokens.focus,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              )
                                            : const BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ExcludeSemantics(
                                              child: Transform.scale(
                                                scale: selected ? 1.2 : 1,
                                                child: Text(
                                                  selected ? '●' : '○',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    height: kTextHeightNone,
                                                    color: selected
                                                        ? tokens.onLeaf
                                                        : tokens.ink,
                                                    fontWeight: selected
                                                        ? FontWeight.w600
                                                        : FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: ContentScope(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  height: kTextHeightNone,
                                                  fontWeight: selected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selected
                                                      ? tokens.onLeaf
                                                      : tokens.ink,
                                                ),
                                                child: ExcludeSemantics(
                                                  excluding:
                                                      widget
                                                          .items[i]
                                                          .semanticLabel !=
                                                      null,
                                                  child: widget.items[i].label,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Focus(
                  child: Semantics(
                    container: true,
                    label: active?.semanticLabel,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 40),
                        child: ContentScope(
                          textStyle: TextStyle(
                            color: tokens.muted,
                            fontSize: 14,
                            height: 1.5715,
                          ),
                          child: active == null
                              ? const SizedBox.shrink()
                              : KeyedSubtree(
                                  key: ValueKey(active.value),
                                  child: active.child,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Flex shrink uses public render-box intrinsic contributions. Opaque labels keep
// their own state, styles and line breaking; no widget or span is inspected.
class _TabsHeader extends MultiChildRenderObjectWidget {
  const _TabsHeader({required this.direction, required super.children});
  final TextDirection direction;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTabsHeader(direction);
  @override
  void updateRenderObject(BuildContext context, _RenderTabsHeader object) {
    object.direction = direction;
  }
}

class _TabHeaderData extends ContainerBoxParentData<RenderBox> {}

class _RenderTabsHeader extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TabHeaderData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TabHeaderData> {
  _RenderTabsHeader(this._direction);
  TextDirection _direction;
  set direction(TextDirection value) {
    if (value == _direction) return;
    _direction = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TabHeaderData)
      child.parentData = _TabHeaderData();
  }

  double intrinsic(double height, {required bool minimum}) =>
      math.max(0, childCount - 1) * 4.0 +
      getChildrenAsList().fold(
        0.0,
        (sum, child) =>
            sum +
            (minimum
                ? child.getMinIntrinsicWidth(height)
                : child.getMaxIntrinsicWidth(height)),
      );
  Size layoutHeader(BoxConstraints constraints, {bool dry = false}) {
    final children = getChildrenAsList();
    final gaps = math.max(0, children.length - 1) * 4.0;
    final bases = [
      for (final c in children) c.getMaxIntrinsicWidth(double.infinity),
    ];
    final minima = [
      for (var i = 0; i < children.length; i++)
        math.min(bases[i], children[i].getMinIntrinsicWidth(double.infinity)),
    ];
    final widths = [...bases];
    final basis = bases.fold(0.0, (a, b) => a + b);
    var remaining = math.max(0.0, basis + gaps - constraints.maxWidth);
    final flexible = {
      for (var i = 0; i < children.length; i++)
        if (bases[i] > minima[i]) i,
    };
    while (remaining > 1e-8 && flexible.isNotEmpty) {
      final total = flexible.fold(
        0.0,
        (sum, i) => sum + math.max(0.0, bases[i] - 32),
      );
      final frozen = flexible
          .where(
            (i) =>
                widths[i] - remaining * math.max(0.0, bases[i] - 32) / total <
                minima[i],
          )
          .toList();
      if (frozen.isEmpty) {
        for (final i in flexible) {
          widths[i] -= remaining * math.max(0.0, bases[i] - 32) / total;
        }
        break;
      }
      for (final i in frozen) {
        remaining -= widths[i] - minima[i];
        widths[i] = minima[i];
        flexible.remove(i);
      }
    }
    // CSS flex items stretch to the tallest wrapped label. Dry measurement
    // supplies that cross-axis constraint without mounting another child tree.
    final drySizes = [
      for (var i = 0; i < children.length; i++)
        children[i].getDryLayout(BoxConstraints(maxWidth: widths[i])),
    ];
    final height = drySizes.fold(0.0, (h, s) => math.max(h, s.height));
    final sizes = <Size>[];
    for (var i = 0; i < children.length; i++) {
      final offered = BoxConstraints(
        maxWidth: widths[i],
        minHeight: height,
        maxHeight: height,
      );
      if (dry) {
        sizes.add(children[i].getDryLayout(offered));
      } else {
        children[i].layout(offered, parentUsesSize: true);
        sizes.add(children[i].size);
      }
    }
    final result = constraints.constrain(
      Size(
        sizes.fold(gaps, (sum, s) => sum + s.width),
        sizes.fold(0.0, (h, s) => math.max(h, s.height)),
      ),
    );
    if (!dry) {
      var x = _direction == TextDirection.ltr ? 0.0 : result.width;
      for (var i = 0; i < children.length; i++) {
        final actual = sizes[i];
        if (_direction == TextDirection.rtl) x -= actual.width;
        (children[i].parentData! as _TabHeaderData).offset = Offset(
          x,
          (result.height - actual.height) / 2,
        );
        x += _direction == TextDirection.ltr ? actual.width + 4 : -4;
      }
    }
    return result;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      intrinsic(height, minimum: true);
  @override
  double computeMaxIntrinsicWidth(double height) =>
      intrinsic(height, minimum: false);
  @override
  double computeMinIntrinsicHeight(double width) =>
      layoutHeader(BoxConstraints(maxWidth: width), dry: true).height;
  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);
  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      layoutHeader(constraints, dry: true);
  @override
  void performLayout() {
    size = layoutHeader(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
