import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Blink `line-height: normal` for one line of [text] (styled on top of the
/// ambient [DefaultTextStyle]): the largest ascent and the largest descent of
/// the fonts the line uses, each rounded to whole pixels. Flutter's
/// paragraph instead rounds their fractional sum, so a 15px Nunito line with
/// a Noto Sans SC fallback run is 23px here (17.4 + 5.3) against Blink's
/// 22px (17 + 5).
double cssNormalLineHeight(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: DefaultTextStyle.of(context).style.merge(style),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
  )..layout();
  final metrics = painter.computeLineMetrics();
  final height = metrics.isEmpty
      ? painter.height
      : (metrics.first.ascent.round() + metrics.first.descent.round())
            .toDouble();
  painter.dispose();
  return height;
}

/// Sizes [child] (one text line, natural height) to a CSS line box of
/// [height] and centres it there without clipping, as the inline content of
/// a CSS line box overflows it.
class CssLineBox extends StatelessWidget {
  const CssLineBox({super.key, required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: OverflowBox(
      fit: OverflowBoxFit.deferToChild,
      minHeight: 0,
      maxHeight: double.infinity,
      child: child,
    ),
  );
}

/// [text] with a zero-width space at every boundary next to a CJK
/// ideograph: Blink offers a line break before and after each ideograph
/// (2026 / 年8月, 今 / 天), where Flutter's paragraph keeps such runs whole.
String cssBreakOpportunities(String text) => text.replaceAllMapped(
  RegExp(r'(?<=[\u3400-\u9fff])(?=.)|(?<=.)(?=[\u3400-\u9fff])'),
  (_) => '​',
);

/// Breaks [text] in the fully resolved [style] (not merged with the ambient
/// [DefaultTextStyle], so it matches a text under any style scope) into the
/// lines it takes at [maxWidth] (with [cssBreakOpportunities]), each with its Blink `line-height: normal`
/// box: the line's largest ascent and descent, each rounded to whole
/// pixels, and never less than the primary font's own rounded ascent and
/// descent (the root inline box strut), which Blink keeps on a line whose
/// glyphs all come from a fallback font. A [CssLineBox] per line then
/// reproduces a wrapped CSS paragraph, which one Flutter paragraph cannot:
/// it sums fractional metrics per line.
List<({String text, double height})> cssWrappedLines(
  BuildContext context,
  String text,
  TextStyle style,
  double maxWidth,
) {
  TextPainter painter(String value) => TextPainter(
    text: TextSpan(text: value, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
  );
  // A digit is set in the first family of the stack, as the strut is.
  final strut = painter('0')..layout();
  final strutMetrics = strut.computeLineMetrics().first;
  strut.dispose();
  final breakable = cssBreakOpportunities(text);
  final full = painter(breakable)..layout(maxWidth: maxWidth);
  final lines = <({String text, double height})>[];
  var offset = 0;
  while (offset < breakable.length) {
    var range = full.getLineBoundary(TextPosition(offset: offset));
    if (range.end <= offset) {
      range = TextRange(start: offset, end: breakable.length);
    }
    final line = breakable
        .substring(range.start, range.end)
        .replaceAll('​', '')
        .trim();
    final measured = painter(line)..layout();
    final metrics = measured.computeLineMetrics().first;
    measured.dispose();
    lines.add((
      text: line,
      height:
          (math.max(metrics.ascent.round(), strutMetrics.ascent.round()) +
                  math.max(
                    metrics.descent.round(),
                    strutMetrics.descent.round(),
                  ))
              .toDouble(),
    ));
    offset = range.end;
  }
  full.dispose();
  return lines;
}

/// Blink's first baseline in a block with an explicit `line-height`: the
/// primary font's ascent A plus floor((L - A - D) / 2), with A and the descent
/// D rounded to whole pixels, whatever fallback font draws the glyphs.
/// [style] is fully resolved and carries the `height` multiplier.
double cssFirstBaseline(BuildContext context, TextStyle style) {
  // A digit is set in the first family of the stack, the primary font.
  final painter = TextPainter(
    text: TextSpan(
      text: '0',
      style: style.copyWith(height: kTextHeightNone),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
  )..layout();
  final metrics = painter.computeLineMetrics().first;
  painter.dispose();
  final line =
      MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
  final ascent = metrics.ascent.roundToDouble();
  final descent = metrics.descent.roundToDouble();
  return ascent + ((line - ascent - descent) / 2).floorToDouble();
}

/// Places library-owned text so that its first baseline is [baseline] below
/// the top of its own box, as [cssFirstBaseline] gives it. Flutter takes the
/// baseline from the fonts of the line, so a line of fallback (CJK) glyphs
/// sits up to 2px lower than in a CSS line box. The size stays the child's.
class CssBaselineShift extends SingleChildRenderObjectWidget {
  const CssBaselineShift({
    super.key,
    required this.baseline,
    required Widget super.child,
  });
  final double baseline;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCssBaselineShift(baseline);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) => (renderObject as _RenderCssBaselineShift).baseline = baseline;
}

class _RenderCssBaselineShift extends RenderShiftedBox {
  _RenderCssBaselineShift(this._baseline) : super(null);
  double _baseline;
  set baseline(double value) {
    if (_baseline == value) return;
    _baseline = value;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      child!.getDryLayout(constraints);

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final result = child!.getDryBaseline(constraints, baseline);
    final first = child!.getDryBaseline(constraints, TextBaseline.alphabetic);
    return result == null || first == null
        ? result
        : result + _baseline - first;
  }

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(constraints, parentUsesSize: true);
    size = child.size;
    final first = child.getDistanceToBaseline(
      TextBaseline.alphabetic,
      onlyReal: true,
    );
    (child.parentData! as BoxParentData).offset = Offset(
      0,
      first == null ? 0 : _baseline - first,
    );
  }
}

/// CSS `text-wrap: balance` for one wrapping child: the narrowest width, to
/// a whole pixel, at which the child is no taller than at the full width.
/// A child that does not fill the width (one line, a fixed box) or whose
/// height does not react to the width is laid out as given. Blink stops
/// balancing after a line limit; this box has no such limit.
class CssBalancedWidth extends SingleChildRenderObjectWidget {
  const CssBalancedWidth({super.key, required Widget super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCssBalancedWidth();
}

class _RenderCssBalancedWidth extends RenderProxyBox {
  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      child!.getDryLayout(constraints);

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(constraints, parentUsesSize: true);
    final full = child.size;
    final width = constraints.maxWidth;
    // A balanced paragraph of n >= 2 lines is wider than half the box, so a
    // child that is no taller at half the width is not wrapping text.
    if (width.isFinite && full.width >= width - .01 && width >= 2) {
      BoxConstraints at(double w) => constraints.copyWith(
        minWidth: math.min(constraints.minWidth, w),
        maxWidth: w,
      );
      double heightAt(double w) {
        child.layout(at(w), parentUsesSize: true);
        return child.size.height;
      }

      var low = (width / 2).floorToDouble();
      var high = width;
      if (heightAt(low) > full.height + .01) {
        while (high - low > 1) {
          final middle = ((low + high) / 2).floorToDouble();
          if (heightAt(middle) > full.height + .01) {
            low = middle;
          } else {
            high = middle;
          }
        }
      }
      child.layout(at(high), parentUsesSize: true);
    }
    size = child.size;
  }
}

/// A CSS line of [style] with an explicit `line-height`, in Blink's 1/64px
/// layout units: 12px at 1.7 is 20.390625, where a Flutter paragraph sets
/// every line of a forced strut on a whole 20px.
double cssLineHeight(BuildContext context, TextStyle style) =>
    (MediaQuery.textScalerOf(context).scale(style.fontSize!) *
            style.height! *
            64)
        .floorToDouble() /
    64;

/// Library-owned wrapped text in CSS line boxes of an explicit
/// `line-height`. [child] is one [Text] whose forced strut gives every line
/// the same whole-pixel height; this box is `lines x line` tall, puts the
/// first baseline [baseline] below its top and paints line i at `i x line`,
/// each baseline rounded to a device pixel as Blink paints text.
class CssLineHeightText extends SingleChildRenderObjectWidget {
  const CssLineHeightText({
    super.key,
    required this.line,
    required this.baseline,
    required this.pixelRatio,
    required Text super.child,
  });
  final double line;
  final double baseline;
  final double pixelRatio;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCssLineHeightText(line, baseline, pixelRatio);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) => (renderObject as _RenderCssLineHeightText)
    ..line = line
    ..baseline = baseline
    ..pixelRatio = pixelRatio;
}

class _RenderCssLineHeightText extends RenderShiftedBox {
  _RenderCssLineHeightText(this._line, this._baseline, this._pixelRatio)
    : super(null);
  double _line;
  set line(double value) {
    if (_line == value) return;
    _line = value;
    markNeedsLayout();
  }

  double _baseline;
  set baseline(double value) {
    if (_baseline == value) return;
    _baseline = value;
    markNeedsLayout();
  }

  double _pixelRatio;
  set pixelRatio(double value) {
    if (_pixelRatio == value) return;
    _pixelRatio = value;
    markNeedsPaint();
  }

  int _lines = 1;
  final _clips = <LayerHandle<ClipRectLayer>>[];

  /// Lines of the paragraph, whose own line is the strut on a whole pixel.
  int _count(double height) =>
      math.max(1, (height / _line.roundToDouble()).round());

  BoxConstraints _text(BoxConstraints value) =>
      value.copyWith(minHeight: 0, maxHeight: double.infinity);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _count(child!.getMinIntrinsicHeight(width)) * _line;
  @override
  double computeMaxIntrinsicHeight(double width) =>
      _count(child!.getMaxIntrinsicHeight(width)) * _line;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final text = child!.getDryLayout(_text(constraints));
    return constraints.constrain(Size(text.width, _count(text.height) * _line));
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final text = _text(constraints);
    final result = child!.getDryBaseline(text, baseline);
    final first = child!.getDryBaseline(text, TextBaseline.alphabetic);
    return result == null || first == null
        ? result
        : result + _baseline - first;
  }

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(_text(constraints), parentUsesSize: true);
    _lines = _count(child.size.height);
    size = constraints.constrain(Size(child.size.width, _lines * _line));
    final first = child.getDistanceToBaseline(
      TextBaseline.alphabetic,
      onlyReal: true,
    );
    (child.parentData! as BoxParentData).offset = Offset(
      0,
      first == null ? 0 : _baseline - first,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child!;
    final origin = (child.parentData! as BoxParentData).offset;
    final top = localToGlobal(Offset.zero).dy;
    // Line i has its baseline at top + baseline + i x line in the view.
    double snap(int i) {
      final y = top + _baseline + i * _line;
      return (y * _pixelRatio).roundToDouble() / _pixelRatio - y;
    }

    // To 1/1024px, so that equal targets get equal paint offsets whatever
    // floating-point path led to them.
    Offset exact(Offset value) =>
        Offset(value.dx, (value.dy * 1024).roundToDouble() / 1024);

    if (_lines < 2) {
      _disposeClips(0);
      context.paintChild(child, exact(offset + origin + Offset(0, snap(0))));
      return;
    }
    final pitch = child.size.height / _lines;
    const far = 1e5;
    _disposeClips(_lines);
    while (_clips.length < _lines) {
      _clips.add(LayerHandle<ClipRectLayer>());
    }
    for (var i = 0; i < _lines; i++) {
      final drift = i * (_line - pitch) + snap(i);
      final lineTop = origin.dy + i * pitch + drift;
      _clips[i].layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTRB(
          -far,
          i == 0 ? -far : lineTop,
          far,
          i == _lines - 1 ? far : lineTop + pitch,
        ),
        (context, offset) => context.paintChild(
          child,
          exact(offset + origin + Offset(0, drift)),
        ),
        oldLayer: _clips[i].layer,
      );
    }
  }

  void _disposeClips(int keep) {
    while (_clips.length > keep) {
      _clips.removeLast().layer = null;
    }
  }

  @override
  void dispose() {
    _disposeClips(0);
    super.dispose();
  }
}
