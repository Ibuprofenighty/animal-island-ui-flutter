import 'package:flutter/material.dart';

import '../foundation/dashed_border.dart';
import '../foundation/icon.dart';
import '../foundation/localizations.dart';
import '../foundation/recipes/no_data.dart';
import '../foundation/size.dart';
import '../foundation/theme.dart';
import '../internal/content_scope.dart';
import '../internal/css_line_box.dart';

/// Built-in empty-state artwork and default title.
enum IslandNoDataVariant {
  /// Reference `default`: the open cardboard box, titled 暂无数据 / No data.
  normal,

  /// Search without results: the magnifier, titled 没有找到相关结果.
  search,

  /// The box in the smaller icon area, for cells and compact cards.
  simple,
}

/// Measured geometry of one [IslandSize] preset.
typedef _Metrics = ({
  EdgeInsets padding,
  double art,
  double icon,
  double artGap,
  double simpleArtGap,
  double title,
  double description,
  double descriptionGap,
  double actionGap,
});

const _metrics = <IslandSize, _Metrics>{
  IslandSize.small: (
    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
    art: 64,
    icon: 32,
    artGap: 14,
    simpleArtGap: 14,
    title: 14,
    description: 12,
    descriptionGap: 5,
    actionGap: 14,
  ),
  IslandSize.middle: (
    padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
    art: 96,
    icon: 52,
    artGap: 22,
    simpleArtGap: 16,
    title: 16,
    description: 13,
    descriptionGap: 8,
    actionGap: 22,
  ),
  IslandSize.large: (
    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
    art: 120,
    icon: 64,
    artGap: 26,
    simpleArtGap: 26,
    title: 18,
    description: 14,
    descriptionGap: 8,
    actionGap: 22,
  ),
};

/// Static empty-content presentation: artwork, title, optional description
/// and an optional action area, centred in that order.
///
/// It owns no request, loading or live-region behaviour; wrap it in
/// [Semantics] (for example `liveRegion: true`) when its appearance should be
/// announced. The artwork is decorative and excluded from semantics. Fills
/// the available width when bounded and shrink-wraps otherwise.
class IslandNoData extends StatelessWidget {
  const IslandNoData({
    super.key,
    this.variant = IslandNoDataVariant.normal,
    this.size = IslandSize.middle,
    this.title,
    this.showTitle = true,
    this.description,
    this.icon,
    this.showIcon = true,
    this.actions = const [],
    this.bordered = false,
  });

  /// Built-in artwork and default title.
  final IslandNoDataVariant variant;

  /// Padding, artwork area and type scale.
  final IslandSize size;

  /// Title slot; null shows the localized default of [variant]. Wrapped
  /// lines are balanced: the title takes the narrowest width that keeps its
  /// line count.
  final Widget? title;

  /// Whether the title row is shown; false hides the default title too.
  final bool showTitle;

  /// Secondary explanation below the title; hidden when null. At most 32
  /// "0" advances wide; wrapped lines are balanced as the title's are.
  final Widget? description;

  /// Custom decorative icon in the compact square area (32/52/64), scaled to
  /// fit and coloured by the title ink unless it sets its own colour. Null
  /// shows the [variant] artwork.
  final Widget? icon;

  /// Whether the artwork (built-in or [icon]) is shown.
  final bool showIcon;

  /// Recovery controls, centred with a 12px gap and wrapping on narrow
  /// widths. Each keeps its own focus and styles.
  final List<Widget> actions;

  /// Cream surface with a dashed sand outline and 20px radius.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final m = _metrics[size]!;
    final colors = NoDataColors.of(context, IslandTheme.of(context));
    final strings = IslandLocalizations.of(context);
    final descriptionStyle = TextStyle(
      fontSize: m.description,
      height: 1.8,
      leadingDistribution: TextLeadingDistribution.even,
      color: colors.description,
    );
    final titleStyle = TextStyle(
      fontSize: m.title,
      height: 1.5,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      color: colors.title,
    );
    final children = <Widget>[
      if (showIcon) ...[
        ExcludeSemantics(child: _artwork(m, colors)),
        SizedBox(
          height: variant == IslandNoDataVariant.simple
              ? m.simpleArtGap
              : m.artGap,
        ),
      ],
      if (showTitle)
        ContentScope(
          textStyle: titleStyle,
          child: CssBalancedWidth(
            child: _centred(
              title ??
                  // Library-owned text: the reference line box, where the
                  // Chinese default would otherwise sit 2px low.
                  CssBaselineShift(
                    baseline: cssFirstBaseline(
                      context,
                      DefaultTextStyle.of(context).style.merge(titleStyle),
                    ),
                    child: Text(
                      variant == IslandNoDataVariant.search
                          ? strings.noResults
                          : strings.noData,
                    ),
                  ),
            ),
          ),
        ),
      if (description != null)
        Padding(
          padding: EdgeInsets.only(top: m.descriptionGap),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 32 * _zeroAdvance(context, descriptionStyle),
            ),
            child: ContentScope(
              textStyle: descriptionStyle,
              child: CssBalancedWidth(child: _centred(description!)),
            ),
          ),
        ),
      if (actions.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(top: m.actionGap),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: actions,
          ),
        ),
    ];
    final border = bordered ? IslandTheme.borderWidth(context, 1.5) : 0.0;
    Widget body = Padding(
      padding: m.padding + EdgeInsets.all(border),
      child: Align(
        heightFactor: 1,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
    if (bordered) {
      const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      );
      body = DecoratedBox(
        decoration: ShapeDecoration(color: colors.fill, shape: shape),
        child: CustomPaint(
          foregroundPainter: IslandDashedBorderPainter(
            shape: shape,
            color: colors.border,
            strokeWidth: border,
            dash: border * 3,
            gap: border * 2,
          ),
          child: body,
        ),
      );
    }
    return body;
  }

  Widget _artwork(_Metrics m, NoDataColors colors) {
    final custom = icon;
    final Widget art;
    if (custom != null) {
      art = SizedBox.square(
        dimension: m.icon,
        child: IconTheme.merge(
          data: IconThemeData(color: colors.title, size: m.icon),
          child: FittedBox(child: custom),
        ),
      );
    } else {
      final simple = variant == IslandNoDataVariant.simple;
      art = IslandIcon(
        variant == IslandNoDataVariant.search
            ? IslandGlyph.search
            : IslandGlyph.noData,
        size: simple ? m.icon : m.art,
        color: NoDataColors.artworkInk,
      );
    }
    // Reference `max-width: 100%` with a square aspect ratio.
    return FittedBox(fit: BoxFit.scaleDown, child: art);
  }

  /// Text leaves centre their lines; other widgets keep their own layout.
  static Widget _centred(Widget child) =>
      DefaultTextStyle.merge(textAlign: TextAlign.center, child: child);

  /// CSS `ch`: the advance of "0" in the resolved description style.
  static double _zeroAdvance(BuildContext context, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(
        text: '0',
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textScaler: MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling,
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

/// Default title of the search variant.
