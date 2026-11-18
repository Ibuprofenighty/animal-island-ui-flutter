import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;

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
