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
