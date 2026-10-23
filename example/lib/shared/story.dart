import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

class StoryPanel extends StatelessWidget {
  const StoryPanel({
    super.key,
    required this.title,
    this.tags = const [],
    this.heading,
    required this.children,
  });
  final String title;
  final List<String> tags;
  final Widget? heading;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.only(bottom: 36),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xffe8e2d6)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
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
                    color: Color(0xff725d42),
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
    ),
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
  });
  final double spaceBefore, spaceAfter;
  final double? lineHeight;
  final StrutStyle? strutStyle;
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: spaceBefore, bottom: spaceAfter),
    child: Text(
      text,
      strutStyle: strutStyle,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: lineHeight ?? kTextHeightNone,
        color: IslandTokens.light.muted,
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
class StoryApi extends StatelessWidget {
  const StoryApi({super.key, required this.rows});
  final List<(String, String, String, String)> rows;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _codeLabel('API'),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: ColoredBox(
            color: const Color(0xff2b2118),
            child: LayoutBuilder(
              builder: (_, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: constraints.maxWidth < 650
                      ? 650
                      : constraints.maxWidth,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1.8),
                      3: FlexColumnWidth(.8),
                    },
                    border: const TableBorder(
                      horizontalInside: BorderSide(color: Color(0xff3d3028)),
                    ),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xff3d3028),
                        ),
                        children: [
                          for (final heading in ['属性', '说明', '类型', '默认值'])
                            _cell(
                              heading,
                              color: const Color(0xffe8d5bc),
                              bold: true,
                            ),
                        ],
                      ),
                      for (final row in rows)
                        TableRow(
                          children: [
                            _cell(row.$1, color: const Color(0xffe8c87a)),
                            _cell(row.$2),
                            _cell(row.$3, color: const Color(0xffd4a0e0)),
                            _cell(row.$4, color: const Color(0xffa8d4a0)),
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
  Widget _cell(
    String text, {
    bool bold = false,
    Color color = const Color(0xffc8bba8),
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: color,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}

Widget _codeLabel(String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: const BoxDecoration(
    color: Color(0xff3d3028),
    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
  ),
  child: Text(
    label,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xffe7e4e0),
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
      color: dashed ? const Color(0xfffaf8f2) : const Color(0xfffaf8f3),
      borderRadius: BorderRadius.circular(dashed ? 18 : 12),
      border: dashed ? null : Border.all(color: const Color(0xffe8e2d6)),
    ),
    child: CustomPaint(
      foregroundPainter: dashed
          ? const IslandDashedBorderPainter(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              color: Color(0xffe0d8c8),
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
