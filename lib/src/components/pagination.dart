import 'package:flutter/rendering.dart';

import '../foundation/theme.dart';
import '../internal/option_cursor.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/localizations.dart';
import '../foundation/pagination_value.dart';
import '../internal/action_surface.dart';
import '../internal/anchored_panel.dart';

const _sizeLabelStyle = TextStyle(
  fontSize: 13,
  height: 1,
  fontWeight: FontWeight.w600,
  color: Color(0xff725d42),
);
String _sizeDisplayLabel(String label) => label.replaceAllMapped(
  RegExp(r'(?<=[\u3400-\u9fff]/)(?=[\u3400-\u9fff])'),
  (_) => '\u200b',
);

enum IslandPaginationVariant { orange, teal }

/// Paging UI; a controlled host can accept or reject each complete value.
class IslandPagination extends StatefulWidget {
  const IslandPagination({
    super.key,
    required this.total,
    required IslandPaginationValue value,
    required this.onChanged,
    this.onPageSizeChanged,
    this.showTotal = false,
    this.showSizeChanger = false,
    this.showQuickJumper = false,
    this.disabled = false,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.variant = IslandPaginationVariant.orange,
    this.semanticLabel,
    this.alignment = AlignmentDirectional.centerStart,
  }) : value = value,
       initialValue = const IslandPaginationValue(),
       controlled = true,
       assert(total >= 0);
  const IslandPagination.uncontrolled({
    super.key,
    required this.total,
    this.initialValue = const IslandPaginationValue(),
    this.onChanged,
    this.onPageSizeChanged,
    this.showTotal = false,
    this.showSizeChanger = false,
    this.showQuickJumper = false,
    this.disabled = false,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.variant = IslandPaginationVariant.orange,
    this.semanticLabel,
    this.alignment = AlignmentDirectional.centerStart,
  }) : value = null,
       controlled = false,
       assert(total >= 0);

  final int total;
  final IslandPaginationValue? value;
  final IslandPaginationValue initialValue;
  final bool controlled, showTotal, showSizeChanger, showQuickJumper, disabled;
  final List<int> pageSizeOptions;
  final ValueChanged<IslandPaginationValue>? onChanged, onPageSizeChanged;
  final IslandPaginationVariant variant;
  final String? semanticLabel;

  /// Aligns each run; a row below its intrinsic minimum wraps its controls.
  final AlignmentGeometry alignment;
  @override
  State<IslandPagination> createState() => _IslandPaginationState();
}

class _IslandPaginationState extends State<IslandPagination> {
  late IslandPaginationValue inner = widget.initialValue;
  final input = TextEditingController();
  final inputFocus = FocusNode();
  final sizeFocus = FocusNode();
  bool open = false;
  IslandPaginationValue get current =>
      (widget.controlled ? widget.value! : inner).normalized(widget.total);
  List<int> get sizes =>
      widget.pageSizeOptions.where((v) => v > 0).toSet().toList();
  @override
  void initState() {
    super.initState();
    inputFocus.addListener(onInputFocus);
  }

  void onInputFocus() {
    if (!inputFocus.hasFocus) jump();
  }

  @override
  void didUpdateWidget(IslandPagination old) {
    super.didUpdateWidget(old);
    assert(
      old.controlled == widget.controlled,
      'Paging ownership cannot change in place.',
    );
    if (widget.disabled || !widget.showSizeChanger) open = false;
    if (!widget.controlled) inner = inner.normalized(widget.total);
  }

  @override
  void dispose() {
    inputFocus.removeListener(onInputFocus);
    inputFocus.dispose();
    sizeFocus.dispose();
    input.dispose();
    super.dispose();
  }

  void commit(IslandPaginationValue next, {bool sizeChanged = false}) {
    if (widget.disabled) return;
    next = next.normalized(widget.total);
    if (next == current) return;
    if (!widget.controlled) setState(() => inner = next);
    if (sizeChanged) widget.onPageSizeChanged?.call(next);
    widget.onChanged?.call(next);
  }

  void page(int value) => commit(
    IslandPaginationValue(
      page: value.clamp(1, current.pageCount(widget.total)),
      pageSize: current.pageSize,
    ),
  );
  void jump() {
    final parsed = int.tryParse(input.text);
    input.clear();
    if (parsed != null) page(parsed);
  }

  void close({bool restoreFocus = false}) {
    if (open) setState(() => open = false);
    if (restoreFocus) sizeFocus.requestFocus();
  }

  List<int?> pageItems(int page, int count) {
    if (count <= 7) return List.generate(count, (i) => i + 1);
    return [
      1,
      if (page > 3) null,
      for (
        int i = math.max(2, page - 1);
        i <= math.min(count - 1, page + 1);
        i++
      )
        i,
      if (page < count - 2) null,
      count,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final strings = IslandLocalizations.of(context);
    final tokens = IslandTheme.of(context);
    final v = current;
    final count = v.pageCount(widget.total);
    var sizeMinimum = 0.0;
    if (widget.showSizeChanger) {
      final measure = TextPainter(
        text: TextSpan(
          text: _sizeDisplayLabel(strings.perPage(v.pageSize)),
          style: DefaultTextStyle.of(context).style.merge(_sizeLabelStyle),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      sizeMinimum =
          measure.minIntrinsicWidth + 46; // Border/padding28 + gap8 + caret10.
      measure.dispose();
    }
    Widget flexible(
      Widget child, {
      double? basis = 32,
      double? contribution,
      double inset = 0,
    }) => _PaginationFlex(
      basis: basis,
      contribution: contribution ?? basis!,
      inset: inset,
      child: child,
    );
    final parts = <Widget>[
      if (widget.showTotal)
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 10),
          child: Text(
            strings.totalItems(widget.total),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: tokens.muted,
            ),
          ),
        ),
      flexible(
        item(
          label: strings.previousPage,
          enabled: !widget.disabled && v.page > 1,
          onTap: () => page(v.page - 1),
          child: const _Chevron(forward: false),
        ),
      ),
      for (final number in pageItems(v.page, count))
        if (number == null)
          flexible(
            SizedBox(
              width: 24,
              height: 32,
              child: Center(
                child: Text(
                  '···',
                  style: TextStyle(
                    color: tokens.muted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            basis: 24,
          )
        else
          flexible(
            item(
              label: strings.pageLabel(number),
              selected: number == v.page,
              enabled: !widget.disabled,
              onTap: () => page(number),
              child: Text('$number'),
            ),
          ),
      flexible(
        item(
          label: strings.nextPage,
          enabled: !widget.disabled && v.page < count,
          onTap: () => page(v.page + 1),
          child: const _Chevron(forward: true),
        ),
      ),
      if (widget.showSizeChanger)
        flexible(
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: sizeChanger(strings),
          ),
          basis: null,
          contribution: sizeMinimum,
          inset: 8,
        ),
      if (widget.showQuickJumper)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Text(
                strings.jumpTo,
                style: TextStyle(fontSize: 13, color: tokens.muted),
              ),
              SizedBox(
                width: 52,
                height: 32,
                child: Semantics(
                  label: strings.jumpPage,
                  child: TextField(
                    controller: input,
                    focusNode: inputFocus,
                    enabled: !widget.disabled,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => jump(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff725d42),
                      height: 1,
                    ),
                    cursorColor: const Color(0xff725d42),
                    decoration: InputDecoration(
                      visualDensity: VisualDensity.standard,
                      constraints: const BoxConstraints(minHeight: 32),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      filled: true,
                      fillColor: widget.disabled
                          ? const Color(0xffece8dc)
                          : const Color(0xfffffbe7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                          color: IslandTokens.light.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                          color: IslandTokens.light.focus,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                strings.pageSuffix,
                style: TextStyle(fontSize: 13, color: tokens.muted),
              ),
            ],
          ),
        ),
    ];
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? strings.pagination,
      child: Opacity(
        opacity: widget.disabled ? .6 : 1,
        child: _PaginationLine(
          direction: Directionality.of(context),
          alignment: widget.alignment,
          children: parts,
        ),
      ),
    );
  }

  Widget item({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    required Widget child,
    bool selected = false,
  }) {
    final teal = widget.variant == IslandPaginationVariant.teal;
    return ActionSurface(
      label: label,
      selected: selected,
      onActivate: enabled ? onTap : null,
      builder: (context, states) {
        final tokens = IslandTheme.of(context);
        final hover = states.contains(WidgetState.hovered);
        final color = selected
            ? (teal
                  ? (hover ? const Color(0xff3dd4c6) : const Color(0xff19c8b9))
                  : (hover ? const Color(0xffffb400) : const Color(0xffffc107)))
            : hover
            ? (teal ? const Color(0xffe6f9f6) : const Color(0xffffd54f))
            : tokens.paper.withValues(alpha: 0);
        final ink = selected
            ? (teal ? IslandTokens.light.onLeaf : IslandTokens.light.onSun)
            : !enabled
            ? const Color(0xffd4c9b4)
            : hover
            ? (teal ? IslandTokens.light.link : IslandTokens.light.onSun)
            : tokens.ink;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50),
            border: states.contains(WidgetState.focused) || selected
                ? Border.all(
                    color: selected
                        ? (teal
                              ? IslandTokens.light.onLeaf
                              : IslandTokens.light.onSun)
                        : hover
                        ? IslandTokens.light.focus
                        : tokens.focus,
                    width: states.contains(WidgetState.focused) ? 2 : 1,
                  )
                : null,
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: ink, size: 14),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: ink,
                  fontSize: 13,
                  height: 1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: ExcludeSemantics(child: child),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget sizeChanger(IslandLocalizations strings) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          close(restoreFocus: true),
      const SingleActivator(LogicalKeyboardKey.arrowDown): () {
        if (!widget.disabled) setState(() => open = true);
      },
    },
    child: AnchoredPanel(
      open: open,
      onDismiss: close,
      placement: PanelPlacement.above,
      gap: 8,
      width: 108,
      estimatedHeight: sizes.length * 36.5 + 16,
      anchor: ActionSurface(
        expanded: open,
        focusNode: sizeFocus,
        label: strings.perPage(current.pageSize),
        onActivate: widget.disabled ? null : () => setState(() => open = !open),
        builder: (_, states) => Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.disabled
                ? const Color(0xfff5f5f0)
                : states.contains(WidgetState.hovered)
                ? const Color(0xfffffdf7)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 2,
              color: states.contains(WidgetState.focused)
                  ? IslandTokens.light.focus
                  : IslandTokens.light.outline,
            ),
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    _sizeDisplayLabel(strings.perPage(current.pageSize)),
                    style: _sizeLabelStyle,
                  ),
                ),
                AnimatedRotation(
                  turns: open ? .5 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: CustomPaint(
                    size: const Size(10, 10),
                    painter: _SizeCaret(
                      open
                          ? (widget.variant == IslandPaginationVariant.teal
                                ? IslandTokens.light.link
                                : IslandTokens.light.warning)
                          : IslandTokens.light.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      panel: FocusTraversalGroup(
        child: Semantics(
          container: true,
          label: strings.pageSize,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xffffeea0),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1f3d3428),
                  offset: Offset(0, 6),
                  blurRadius: 18,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final size in sizes)
                    ActionSurface(
                      selected: size == current.pageSize,
                      onActivate: () {
                        commit(
                          IslandPaginationValue(
                            page: current.page,
                            pageSize: size,
                          ),
                          sizeChanged: true,
                        );
                        close(restoreFocus: true);
                      },
                      builder: (_, states) {
                        final highlighted =
                            states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.focused);
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (size == current.pageSize)
                              Positioned(
                                left: 20,
                                right: 20,
                                top: 13,
                                height: 14,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0x4dffcc00),
                                    border: Border.all(
                                      color: IslandTokens.light.onSun,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(7),
                                    ),
                                  ),
                                ),
                              ),
                            if (highlighted)
                              Positioned(
                                left: -14,
                                top: 11,
                                child: OptionCursor(
                                  reduced: MediaQuery.disableAnimationsOf(
                                    context,
                                  ),
                                ),
                              ),
                            Container(
                              foregroundDecoration:
                                  states.contains(WidgetState.focused)
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: IslandTokens.light.focus,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    )
                                  : null,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  strings.perPage(size),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xff725d42),
                                    fontWeight:
                                        highlighted || size == current.pageSize
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.forward});
  final bool forward;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(14, 14),
    painter: _ChevronPainter(
      IconTheme.of(context).color!,
      forward != (Directionality.of(context) == TextDirection.rtl),
    ),
  );
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color, this.forward);
  final Color color;
  final bool forward;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final path = Path()
      ..moveTo(forward ? 9 : 15, 5)
      ..lineTo(forward ? 16 : 8, 12)
      ..lineTo(forward ? 9 : 15, 19);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) =>
      old.color != color || old.forward != forward;
}

class _SizeCaret extends CustomPainter {
  const _SizeCaret(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(
      Path()
        ..moveTo(12, 16.5)
        ..lineTo(5.5, 9)
        ..lineTo(18.5, 9)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SizeCaret old) => old.color != color;
}

class _PaginationData extends ContainerBoxParentData<RenderBox> {
  bool flexible = false;
  double? basis;
  double contribution = 0, inset = 0;
}

class _PaginationFlex extends ParentDataWidget<_PaginationData> {
  const _PaginationFlex({
    required this.basis,
    required this.contribution,
    required this.inset,
    required super.child,
  });
  final double? basis;
  final double contribution, inset;
  @override
  Type get debugTypicalAncestorWidgetClass => _PaginationLine;
  @override
  void applyParentData(RenderObject object) {
    final data = object.parentData! as _PaginationData;
    if (data.flexible &&
        data.basis == basis &&
        data.contribution == contribution &&
        data.inset == inset)
      return;
    data.flexible = true;
    data.basis = basis;
    data.contribution = contribution;
    data.inset = inset;
    object.parent?.markNeedsLayout();
  }
}

class _PaginationLine extends MultiChildRenderObjectWidget {
  const _PaginationLine({
    required this.direction,
    required this.alignment,
    required super.children,
  });
  final AlignmentGeometry alignment;
  final TextDirection direction;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPaginationLine(direction, alignment);
  @override
  void updateRenderObject(BuildContext context, _RenderPaginationLine object) {
    object.direction = direction;
    object.alignment = alignment;
  }
}

// Match the owned CSS inline-flex controls: intrinsic contributions use declared
// page widths and the size label's word minimum. Once that minimum is reached,
// page/ellipsis/size cells share proportional shrink; margins never shrink.
// Intrinsic queries do not mount or inspect widgets. Each child is laid out once.
class _RenderPaginationLine extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PaginationData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PaginationData> {
  _RenderPaginationLine(this._direction, this._alignment);
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  TextDirection _direction;
  set direction(TextDirection value) {
    if (value == _direction) return;
    _direction = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PaginationData)
      child.parentData = _PaginationData();
  }

  double preferred(RenderBox child, _PaginationData data, double height) =>
      data.basis ?? (child.getMaxIntrinsicWidth(height) - data.inset);
  Size layoutLine(BoxConstraints constraints, {bool dry = false}) {
    final boxes = <RenderBox, Size>{}, bases = <RenderBox, double>{};
    var fixed = 0.0, basis = 0.0, minimum = 0.0, height = 0.0;
    final children = getChildrenAsList();
    Size measure(RenderBox child, BoxConstraints constraints) {
      if (dry) return child.getDryLayout(constraints);
      child.layout(constraints, parentUsesSize: true);
      return child.size;
    }

    for (final child in children) {
      final data = child.parentData! as _PaginationData;
      if (!data.flexible) {
        final actual = measure(child, const BoxConstraints());
        boxes[child] = actual;
        fixed += actual.width;
        minimum += actual.width;
        height = math.max(height, actual.height);
      } else {
        final value = preferred(child, data, double.infinity);
        bases[child] = value;
        basis += value;
        fixed += data.inset;
        minimum += data.inset + data.contribution;
      }
    }
    final gaps = math.max(0, children.length - 1) * 2.0;
    if (minimum + gaps > constraints.maxWidth) {
      final runs = <List<RenderBox>>[];
      final widths = <double>[];
      final heights = <double>[];
      for (final child in children) {
        final data = child.parentData! as _PaginationData;
        if (data.flexible) {
          boxes[child] = measure(
            child,
            BoxConstraints.tightFor(
              width: math.min(
                data.inset + data.contribution,
                constraints.maxWidth,
              ),
            ),
          );
        }
        final actual = boxes[child]!;
        if (runs.isEmpty ||
            widths.last + 2 + actual.width > constraints.maxWidth) {
          runs.add([]);
          widths.add(0);
          heights.add(0);
        }
        widths[widths.length - 1] += (runs.last.isEmpty ? 0 : 2) + actual.width;
        heights[heights.length - 1] = math.max(heights.last, actual.height);
        runs.last.add(child);
      }
      final result = constraints.constrain(
        Size(
          widths.fold(0.0, math.max),
          heights.fold(0.0, (a, b) => a + b) + math.max(0, runs.length - 1) * 8,
        ),
      );
      if (!dry) {
        var y = 0.0;
        for (var i = 0; i < runs.length; i++) {
          final start =
              (result.width - widths[i]) *
              (_alignment.resolve(_direction).x + 1) /
              2;
          var x = _direction == TextDirection.ltr ? start : start + widths[i];
          for (final child in runs[i]) {
            final actual = boxes[child]!;
            if (_direction == TextDirection.rtl) x -= actual.width;
            (child.parentData! as _PaginationData).offset = Offset(
              x,
              y + (heights[i] - actual.height) / 2,
            );
            x += _direction == TextDirection.ltr ? actual.width + 2 : -2;
          }
          y += heights[i] + 8;
        }
      }
      return result;
    }
    final desired = fixed + gaps + basis;
    final width = math.max(
      minimum + gaps,
      math.min(desired, constraints.maxWidth),
    );
    final fraction = basis == 0 ? 1.0 : (width - fixed - gaps) / basis;
    for (final child in children) {
      final data = child.parentData! as _PaginationData;
      if (!data.flexible) continue;
      final actual = measure(
        child,
        BoxConstraints.tightFor(width: data.inset + bases[child]! * fraction),
      );
      boxes[child] = actual;
      height = math.max(height, actual.height);
    }
    final result = constraints.constrain(Size(width, height));
    if (!dry) {
      final start =
          (result.width - width) * (_alignment.resolve(_direction).x + 1) / 2;
      var x = _direction == TextDirection.ltr ? start : start + width;
      for (final child in children) {
        final actual = boxes[child]!;
        final data = child.parentData! as _PaginationData;
        if (_direction == TextDirection.rtl) x -= actual.width;
        data.offset = Offset(x, (result.height - actual.height) / 2);
        x += _direction == TextDirection.ltr ? actual.width + 2 : -2;
      }
    }
    return result;
  }

  double intrinsicLineWidth(double height, {required bool minimum}) {
    var width = math.max(0, childCount - 1) * 2.0;
    for (final child in getChildrenAsList()) {
      final data = child.parentData! as _PaginationData;
      width += data.flexible
          ? data.inset +
                (minimum ? data.contribution : preferred(child, data, height))
          : child.getMaxIntrinsicWidth(height);
    }
    return width;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      intrinsicLineWidth(height, minimum: true);
  @override
  double computeMaxIntrinsicWidth(double height) =>
      intrinsicLineWidth(height, minimum: false);
  @override
  double computeMinIntrinsicHeight(double width) =>
      layoutLine(BoxConstraints(maxWidth: width), dry: true).height;
  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);
  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      layoutLine(constraints, dry: true);
  @override
  void performLayout() {
    size = layoutLine(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
