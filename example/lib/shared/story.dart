import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import 'palette.dart';
import 'reference_source_link.dart';

class StoryPanel extends StatelessWidget {
  const StoryPanel({
    super.key,
    required this.title,
    this.tags = const [],
    this.heading,
    this.dashed = false,
    required this.children,
  });
  final String title;
  final List<String> tags;
  final Widget? heading;

  /// Reference `Section dashed`: the same 1px `#e8e2d6` border, dashed.
  final bool dashed;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 36),
    decoration: BoxDecoration(
      color: GalleryPalette.demoSurface,
      border: dashed ? null : Border.all(color: GalleryPalette.rule),
      borderRadius: BorderRadius.circular(12),
    ),
    child: CustomPaint(
      foregroundPainter: dashed
          ? const IslandDashedBorderPainter(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              color: GalleryPalette.rule,
              dash: 3,
              gap: 3,
            )
          : null,
      child: Padding(
        // The solid Border inset its 1px; the dashed stroke keeps that box.
        padding: EdgeInsets.all(dashed ? 25 : 24),
        child: _panelBody(),
      ),
    ),
  );

  Widget _panelBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (heading != null)
        heading!
      else
        Builder(
          builder: (context) {
            final headingChildren = [
              Text(
                title,
                strutStyle: StrutStyle(
                  fontSize: 18,
                  height: RegExp(r'[\u3400-\u9fff]').hasMatch(title)
                      ? 1.5
                      : 4 / 3,
                  forceStrutHeight: true,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.333333,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: GalleryPalette.storyInk,
                ),
              ),
              for (final label in tags)
                IslandTag(
                  size: IslandSize.small,
                  variant: IslandTagVariant.soft,
                  child: Text(label),
                ),
            ];
            return storyRow(
              headingChildren,
              align: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
            );
          },
        ),
      ...children,
    ],
  );
}

const storyCaptionStrut = StrutStyle(
  fontSize: 14,
  height: 1.5,
  forceStrutHeight: true,
);

class StoryLabel extends StatelessWidget {
  const StoryLabel(
    this.text, {
    super.key,
    this.spaceBefore = 20,
    this.spaceAfter = 20,
    this.lineHeight,
    this.strutStyle,
    this.links = const {},
    this.code = const {},
  });
  final double spaceBefore, spaceAfter;
  final double? lineHeight;
  final StrutStyle? strutStyle;
  final String text;

  /// Reference `<a>` runs inside the label: each key is the first occurrence
  /// of its link text in [text], each value the URL it opens.
  final Map<String, String> links;

  /// Reference inline `<code>` runs inside the label: the first occurrence of
  /// each entry in [text] uses the library code font in the label's colour.
  final Set<String> code;
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: lineHeight ?? kTextHeightNone,
      color: IslandTokens.light.muted,
    );
    return Padding(
      padding: EdgeInsets.only(top: spaceBefore, bottom: spaceAfter),
      child: links.isEmpty && code.isEmpty
          ? Text(text, strutStyle: strutStyle, style: style)
          : Text.rich(
              TextSpan(children: _inlineSpans(context, style)),
              strutStyle: strutStyle,
              style: style,
            ),
    );
  }

  List<InlineSpan> _inlineSpans(BuildContext context, TextStyle style) {
    final runs = <(int, String, String?)>[
      for (final link in links.entries)
        if (text.indexOf(link.key) case final start when start >= 0)
          (start, link.key, link.value),
      for (final run in code)
        if (text.indexOf(run) case final start when start >= 0)
          (start, run, null),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    // Browser `<code>` inherits the label size through the UA monospace
    // default, which Chromium scales by 13/16.
    final codeStyle = TextStyle(
      fontSize: style.fontSize! * 13 / 16,
      fontFamily: IslandTheme.codeFontFamily,
      fontFamilyFallback: DefaultTextStyle.of(context).style.fontFamilyFallback,
    );
    final spans = <InlineSpan>[];
    var offset = 0;
    for (final (start, label, url) in runs) {
      if (start < offset) continue;
      if (start > offset)
        spans.add(TextSpan(text: text.substring(offset, start)));
      spans.add(
        url == null
            ? TextSpan(text: label, style: codeStyle)
            : WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: _StoryLink(label, url, style),
              ),
      );
      offset = start + label.length;
    }
    if (offset < text.length) spans.add(TextSpan(text: text.substring(offset)));
    return spans;
  }
}

/// Reference demo anchor: `#725d42`, underlined, opens in a new tab.
class _StoryLink extends StatefulWidget {
  const _StoryLink(this.text, this.url, this.style);
  final String text, url;
  final TextStyle style;
  @override
  State<_StoryLink> createState() => _StoryLinkState();
}

class _StoryLinkState extends State<_StoryLink> {
  bool focused = false;
  void open() => openExternalUrl(widget.url);
  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    mouseCursor: SystemMouseCursors.click,
    onShowFocusHighlight: (value) => setState(() => focused = value),
    actions: {
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (_) {
          open();
          return null;
        },
      ),
    },
    child: Semantics(
      link: true,
      linkUrl: Uri.tryParse(widget.url),
      child: GestureDetector(
        onTap: open,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: focused ? IslandTokens.light.focus : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            widget.text,
            style: widget.style.copyWith(
              color: GalleryPalette.storyInk,
              decoration: TextDecoration.underline,
              decorationColor: GalleryPalette.storyInk,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Explicit plain-text leaf for reference content with a CSS line-height.
/// Typography stays with the enclosing component; no opaque child is inspected.
class StoryText extends StatelessWidget {
  const StoryText(
    this.text, {
    super.key,
    this.semanticLabel,
    this.inlinePadding = 0,
    this.maxLines,
    this.textAlign,
  });
  final String text;
  final String? semanticLabel;
  final double inlinePadding;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    final strut = storyTextStrut(context);
    final span = TextSpan(
      style: style,
      text: inlinePadding == 0 ? text : null,
      children: inlinePadding == 0
          ? null
          : [
              WidgetSpan(child: SizedBox(width: inlinePadding)),
              TextSpan(text: text),
              WidgetSpan(child: SizedBox(width: inlinePadding)),
            ],
    );
    return _StoryLineBox(
      metrics: (
        span: span,
        maxLines: maxLines,
        style: style,
        strut: strut,
        scaler: MediaQuery.textScalerOf(context),
        direction: Directionality.of(context),
        locale: Localizations.maybeLocaleOf(context),
        placeholders: inlinePadding == 0
            ? const []
            : [
                for (var i = 0; i < 2; i++)
                  PlaceholderDimensions(
                    size: Size(inlinePadding, 0),
                    alignment: PlaceholderAlignment.bottom,
                  ),
              ],
      ),
      child: Text.rich(
        span,
        semanticsLabel: semanticLabel,
        strutStyle: strut,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      ),
    );
  }
}

typedef _StoryMetrics = ({
  InlineSpan span,
  int? maxLines,
  List<PlaceholderDimensions> placeholders,
  TextStyle style,
  StrutStyle strut,
  TextScaler scaler,
  TextDirection direction,
  Locale? locale,
});

// An explicit plain-text leaf can report intrinsic widths to Table while keeping
// Chromium's fractional line boxes. It never examines caller-owned widgets.
class _StoryLineBox extends SingleChildRenderObjectWidget {
  const _StoryLineBox({required this.metrics, required super.child});
  final _StoryMetrics metrics;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderStoryLineBox(metrics);
  @override
  void updateRenderObject(BuildContext context, _RenderStoryLineBox object) {
    object.metrics = metrics;
  }
}

class _RenderStoryLineBox extends RenderShiftedBox {
  _RenderStoryLineBox(this._metrics) : super(null);
  _StoryMetrics _metrics;
  set metrics(_StoryMetrics value) {
    if (_metrics == value) return;
    _metrics = value;
    markNeedsLayout();
  }

  double lineHeight(double width) {
    final m = _metrics;
    final painter =
        TextPainter(
            text: m.span,
            maxLines: m.maxLines,
            ellipsis: m.maxLines == null ? null : '…',
            textDirection: m.direction,
            textScaler: m.scaler,
            strutStyle: m.strut,
            locale: m.locale,
          )
          ..setPlaceholderDimensions(m.placeholders)
          ..layout(maxWidth: width);
    final count = painter.computeLineMetrics().length;
    painter.dispose();
    return (m.scaler.scale(m.style.fontSize!) * m.style.height! * 64).floor() /
        64 *
        count;
  }

  BoxConstraints textConstraints(BoxConstraints value) =>
      value.copyWith(minHeight: 0, maxHeight: double.infinity);
  @override
  double computeMinIntrinsicHeight(double width) => lineHeight(width);
  @override
  double computeMaxIntrinsicHeight(double width) => lineHeight(width);
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final actual = child!.getDryLayout(textConstraints(constraints));
    return constraints.constrain(Size(actual.width, lineHeight(actual.width)));
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final textBox = textConstraints(constraints);
    final actual = child!.getDryLayout(textBox);
    final result = child!.getDryBaseline(textBox, baseline);
    return result == null
        ? null
        : result + (computeDryLayout(constraints).height - actual.height) / 2;
  }

  @override
  void performLayout() {
    child!.layout(textConstraints(constraints), parentUsesSize: true);
    size = constraints.constrain(
      Size(child!.size.width, lineHeight(child!.size.width)),
    );
    (child!.parentData! as BoxParentData).offset = Offset(
      0,
      (size.height - child!.size.height) / 2,
    );
  }
}

/// Caller-owned leaf metrics, derived from the component's inherited style.
StrutStyle storyTextStrut(BuildContext context) => StrutStyle.fromTextStyle(
  DefaultTextStyle.of(context).style,
  forceStrutHeight: true,
);

/// A single wrapping subtree keeps control state/focus when available width changes.
/// Space-between fills a fitting run; spacing remains its minimum gap.
Widget storyRow(
  List<Widget> children, {
  WrapCrossAlignment align = WrapCrossAlignment.start,
  WrapAlignment alignment = WrapAlignment.start,
  double spacing = 16,
  double runSpacing = 16,
}) => SizedBox(
  width: alignment == WrapAlignment.spaceBetween ? double.infinity : null,
  child: Wrap(
    spacing: spacing,
    runSpacing: runSpacing,
    alignment: alignment,
    crossAxisAlignment: align,
    children: children,
  ),
);

class StoryCode extends StatelessWidget {
  const StoryCode(
    this.code, {
    super.key,
    this.label = '使用示例',
    this.spaceBefore = 36,
  });
  final double spaceBefore;
  final String code, label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: spaceBefore),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _codeLabel(label),
        IslandCodeBlock(
          code: code,
          margin: EdgeInsets.zero,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ],
    ),
  );
}

/// API projection uses Flutter declarations, preserving the reference table layout.
///
/// Reference `ApiTable`: an HTML auto-layout table (columns sized from their
/// content, cells vertically centred) under an optional [title] label. Below
/// the table's min-content width the region scrolls horizontally instead of
/// clipping (narrow-layout usability difference, docs/DESIGN.md).
class StoryApi extends StatelessWidget {
  const StoryApi({super.key, required this.rows, this.title = 'API'});
  final List<(String, String, String, String)> rows;

  /// Code-tab label above the table, e.g. `Form API`.
  final String title;
  static const _headings = ['属性', '说明', '类型', '默认值'];
  static final _minContentToken = RegExp(r'[⺀-鿿豈-﫿＀-￯]|[^\s⺀-鿿豈-﫿＀-￯]+');

  /// Readable floor of the 说明 column: four CJK characters per line, as the
  /// reference shows at phone width. Below the summed floors the table
  /// scrolls horizontally instead of collapsing the description to one
  /// character per line.
  static const _descriptionFloor = '说明文字';

  /// Browser min-content of one column: its widest unbreakable run, with the
  /// 说明 column held at [_descriptionFloor].
  List<double> _minWidths(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    double measure(String run, bool bold) {
      final painter = TextPainter(
        text: TextSpan(text: run, style: base.merge(_cellStyle(bold))),
        textScaler: scaler,
        textDirection: direction,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    double widest(String text, bool bold) {
      var result = 0.0;
      for (final token in _minContentToken.allMatches(text)) {
        result = math.max(result, measure(token[0]!, bold));
      }
      return result + 32;
    }

    return [
      for (var column = 0; column < 4; column++)
        [
          widest(_headings[column], true),
          if (column == 1)
            measure(_descriptionFloor, false).ceilToDouble() + 32,
          for (final row in rows)
            widest([row.$1, row.$2, row.$3, row.$4][column], false),
        ].reduce(math.max),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mins = _minWidths(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _codeLabel(title),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: ColoredBox(
              color: GalleryPalette.apiTableBackground,
              child: LayoutBuilder(
                builder: (_, constraints) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(
                      constraints.maxWidth,
                      mins.reduce((a, b) => a + b),
                    ),
                    child: Table(
                      columnWidths: {
                        for (var i = 0; i < 4; i++)
                          i: _ContentColumnWidth(mins[i]),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: const TableBorder(
                        horizontalInside: BorderSide(
                          color: GalleryPalette.apiTableRule,
                        ),
                      ),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: GalleryPalette.apiTableHeader,
                          ),
                          children: [
                            for (final heading in _headings)
                              _cell(
                                heading,
                                color: GalleryPalette.apiTableHeading,
                                bold: true,
                              ),
                          ],
                        ),
                        for (final row in rows)
                          TableRow(
                            children: [
                              _cell(row.$1, color: GalleryPalette.apiTableName),
                              _cell(row.$2),
                              _cell(row.$3, color: GalleryPalette.apiTableType),
                              _cell(
                                row.$4,
                                color: GalleryPalette.apiTableDefault,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle _cellStyle(bool bold) => TextStyle(
    fontSize: 13,
    height: 1.5,
    fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
  );

  Widget _cell(
    String text, {
    bool bold = false,
    Color color = GalleryPalette.apiTableCell,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Text(text, style: _cellStyle(bold).copyWith(color: color)),
  );
}

/// HTML auto table layout for a fitting table: every column starts at its
/// max-content width and shares the remaining width in proportion to it.
/// When the table is too narrow, Flutter shrinks columns towards their
/// min-content width, as the browser does.
///
/// [minWidth] is the browser min-content width (longest Latin word or one
/// CJK character, plus cell padding), measured by StoryApi because the
/// paragraph min intrinsic width does not break between CJK characters.
class _ContentColumnWidth extends TableColumnWidth {
  const _ContentColumnWidth(this.minWidth);
  final double minWidth;
  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      math.min(minWidth, maxIntrinsicWidth(cells, containerWidth));
  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      cells.fold(
        0.0,
        (width, cell) =>
            math.max(width, cell.getMaxIntrinsicWidth(double.infinity)),
      );
  @override
  double? flex(Iterable<RenderBox> cells) =>
      math.max(1.0, maxIntrinsicWidth(cells, double.infinity));
}

Widget _codeLabel(String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: const BoxDecoration(
    color: GalleryPalette.codeLabelFill,
    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
  ),
  child: Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: GalleryPalette.codeLabelText,
    ),
  ),
);

Widget primary(
  String label, {
  VoidCallback? action,
  IslandSize size = IslandSize.middle,
}) => IslandButton(
  variant: IslandButtonVariant.primary,
  size: size,
  onPressed: action ?? () {},
  child: Text(label),
);

/// Gallery demonstration frame; distinct from the product's Card component.
class StoryDemoBox extends StatelessWidget {
  const StoryDemoBox({
    super.key,
    required this.child,
    this.dashed = false,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final bool dashed;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: margin,
    decoration: BoxDecoration(
      color: dashed ? GalleryPalette.demoPanelDashed : GalleryPalette.demoPanel,
      borderRadius: BorderRadius.circular(dashed ? 18 : 12),
      border: dashed ? null : Border.all(color: GalleryPalette.rule),
    ),
    child: CustomPaint(
      foregroundPainter: dashed
          ? const IslandDashedBorderPainter(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              color: GalleryPalette.demoPanelDashedBorder,
              dash: 3,
              gap: 3,
            )
          : null,
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// Reference demo-box padding. Its trailing CSS margin collapses with the next
/// StoryLabel margin; do not add both as separate Flutter padding.
class StoryInset extends StatelessWidget {
  const StoryInset({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(16), child: child);
}
