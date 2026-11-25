import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import '../../shared/palette.dart';

const _islandItems = [
  '拾贝 —— 退潮后留在沙滩上的小小纪念',
  '采果 —— 岛上的野生柑橘，酸甜刚刚好',
  '野餐 —— 灯塔下面那块被太阳晒暖的草地',
  '篝火晚会 —— 潮水退去后，木柴噼啪作响',
  '珊瑚岛 —— 退潮才能看见的那一小片浅礁',
  '水母 —— 透明的身体在夜里发出微弱的蓝',
  '章鱼 —— 藏在礁石缝里，八只手都不肯出来',
  '贝壳风铃 —— 风一吹，整间屋子都在响',
  '涨潮 —— 海水慢慢漫过昨天的脚印',
  '帆船 —— 停在海湾里，等一个顺风的下午',
  '灯塔 —— 每隔十二秒眨一次眼',
  '椰林 —— 风穿过叶子的声音',
];

/// Line box of the 16px demo rows, observed at 25px in the reference built
/// from upstream main (a 44px row, a 67px horizontal area).
const _rowStrut = StrutStyle(
  fontSize: 16,
  height: 25 / 16,
  forceStrutHeight: true,
);

/// Reference ScrollbarDemo (upstream main after 4.0.1, not yet on the live
/// site): four sections, each followed by its code block, then the API table.
class ScrollbarStory extends StatelessWidget {
  const ScrollbarStory({super.key});

  /// Reference demo `textStyle`: 13px at the page's weight 400, 8px below the
  /// title and 20px above the demo; its `#8a7b66` takes the muted role, as
  /// the other demo text.
  Widget text(BuildContext context, List<InlineSpan> spans) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 20),
    child: Text.rich(
      TextSpan(children: spans),
      // Every reference line is 20px, with or without a code span.
      strutStyle: const StrutStyle(
        fontSize: 13,
        height: 20 / 13,
        forceStrutHeight: true,
      ),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: kTextHeightNone,
        color: IslandTokens.light.muted,
      ),
    ),
  );

  TextSpan code(BuildContext context, String value) => TextSpan(
    text: value,
    style: TextStyle(
      fontFamily: IslandTheme.codeFontFamily,
      fontFamilyFallback: DefaultTextStyle.of(context).style.fontFamilyFallback,
    ),
  );

  /// Reference `rowStyle`: 9px above and below, a dashed rule underneath; the
  /// text inherits the page's 16px and `#794f27`. Rows are 44px high.
  Widget rows() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final item in _islandItems)
        CustomPaint(
          foregroundPainter: const _DashedRule(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 9, 0, 10),
            child: Text(
              item,
              strutStyle: _rowStrut,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: kTextHeightNone,
                color: GalleryPalette.demoStrongInk,
              ),
            ),
          ),
        ),
    ],
  );

  /// Reference `frameStyle` on the scroll area itself: the border, the 12px
  /// corners (which clip the thumb ends, as in the reference) and the 16px
  /// padding inside the scrolling content. The height includes the border.
  Widget frame({double? height, required Widget Function(EdgeInsets) child}) =>
      Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: GalleryPalette.demoPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GalleryPalette.rule),
        ),
        child: child(const EdgeInsets.all(16)),
      );

  Widget vertical({
    required double height,
    bool showTrack = false,
    Color? thumbColor,
  }) => frame(
    height: height,
    child: (padding) => IslandScrollbar(
      padding: padding,
      showTrack: showTrack,
      thumbColor: thumbColor,
      child: rows(),
    ),
  );

  /// Reference `hintStyle`: 12px, 8px above.
  Widget hint(String value) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      value,
      style: TextStyle(
        fontSize: 12,
        height: kTextHeightNone,
        color: IslandTokens.light.muted,
      ),
    ),
  );

  /// Reference `columnStyle` with `columnTitleStyle`: 13px weight 600, 8px
  /// above the demo.
  Widget column(String title, Widget demo, [String? note]) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: kTextHeightNone,
            color: IslandTokens.light.muted,
          ),
        ),
      ),
      demo,
      if (note != null) hint(note),
    ],
  );

  /// Reference flex row: `gap: 20`, wrapping, each column `flex: 1 1 260px`.
  Widget columns(Widget first, Widget second) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 260 * 2 + 20
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 20),
              Expanded(child: second),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 20), second],
          ),
  );

  Widget snippet(String value) =>
      StoryCode(value, spaceBefore: 0, spaceAfter: 16);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StoryPanel(
        title: '基础用法',
        children: [
          text(context, const [
            TextSpan(text: '滚动条只'),
            TextSpan(
              text: '换了一层外观',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text:
                  ' —— 滚轮、拖动、键盘、触摸手势全部照旧，只替换轨道与滑块。'
                  '内容溢出时滑块一直可见；滚到边界后滚动也不会链式传给外层页面，滚轮被锁定在本容器内。',
            ),
          ]),
          vertical(height: 220),
          hint('↑ 可滚动 · 聚焦后用方向键滚动'),
        ],
      ),
      snippet(
        'SizedBox(\n  height: 220,\n  child: IslandScrollbar(\n'
        '    child: Column(children: [for (final item in items) Text(item)]),\n'
        '  ),\n)',
      ),
      StoryPanel(
        title: '和默认滚动条对比',
        children: [
          text(context, const [
            TextSpan(
              text:
                  '左边是框架自带的滚动条，右边是组件包起来的同一个滚动区 —— 滚动行为完全一样，'
                  '区别在滚动条本身：左边是默认的灰色细杆，右边是岛国风的沙色圆角胶囊。',
            ),
          ]),
          columns(
            column(
              '默认 SingleChildScrollView',
              frame(
                height: 200,
                child: (padding) =>
                    _DefaultScroll(padding: padding, child: rows()),
              ),
              '↑ 框架默认的灰色细杆',
            ),
            column('IslandScrollbar 包裹', vertical(height: 200), '↑ 岛国风的沙色胶囊'),
          ),
        ],
      ),
      snippet(
        '// 左边：默认\nSizedBox(height: 200, child: SingleChildScrollView(child: …))\n\n'
        '// 右边：组件\nIslandScrollbar(height: 200, child: …)',
      ),
      StoryPanel(
        title: '滚动方向',
        children: [
          text(context, [
            code(context, 'direction'),
            const TextSpan(text: ' 决定哪条轴可以滚动，另一条轴不可滚动，也不会留着第二条滚动条。'),
          ]),
          columns(
            column('vertical（默认）', vertical(height: 150)),
            column(
              'horizontal',
              frame(
                child: (padding) => IslandScrollbar(
                  direction: IslandScrollbarDirection.horizontal,
                  padding: padding,
                  child: Row(
                    children: [
                      for (final item in _islandItems)
                        Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: Text(
                            item,
                            strutStyle: _rowStrut,
                            style: const TextStyle(
                              fontSize: 16,
                              height: kTextHeightNone,
                              color: GalleryPalette.demoStrongInk,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      snippet(
        'IslandScrollbar(\n  direction: IslandScrollbarDirection.horizontal,\n  child: …,\n)',
      ),
      StoryPanel(
        title: '轨道与滑块',
        children: [
          text(context, [
            const TextSpan(text: '默认轨道是透明的，只留一根沙色滑块；滑块与轨道同宽，两端是对称的正半圆。'),
            code(context, 'showTrack'),
            const TextSpan(text: ' 给出轨道底色，'),
            code(context, 'thumbColor'),
            const TextSpan(text: ' 与 '),
            code(context, 'thumbSize'),
            const TextSpan(text: ' 则改滑块本身 —— 传主题里的颜色就能跟随主题换肤。'),
          ]),
          columns(
            column('showTrack', vertical(height: 150, showTrack: true)),
            column(
              '自定义滑块',
              vertical(height: 150, thumbColor: IslandTheme.of(context).leaf),
            ),
          ),
        ],
      ),
      snippet(
        'IslandScrollbar(height: 150, showTrack: true, child: …)\n'
        'IslandScrollbar(\n  height: 150,\n  thumbColor: IslandTheme.of(context).leaf,\n'
        '  thumbSize: 8,\n  child: …,\n)',
      ),
      const StoryApi(
        rows: [
          ('height', '容器高度；省略时取内容高度', 'double?', 'null'),
          ('maxHeight', '容器最大高度', 'double?', 'null'),
          ('width', '容器宽度；省略时由父级约束决定', 'double?', 'null'),
          ('maxWidth', '容器最大宽度', 'double?', 'null'),
          (
            'direction',
            '滚动方向，另一条轴不可滚动',
            'IslandScrollbarDirection',
            'vertical',
          ),
          ('thumbColor', '滑块颜色，省略时取主题 outline', 'Color?', 'null'),
          ('thumbSize', '滑块粗细，默认 8 —— 比系统经典滚动条更细', 'double', '8'),
          ('showTrack', '是否显示轨道底色', 'bool', 'false'),
          ('padding', '滚动内容的内边距，滑块在其外侧', 'EdgeInsetsGeometry', 'zero'),
          ('verticalController', '纵向滚动控制器，借用不释放', 'ScrollController?', 'null'),
          (
            'horizontalController',
            '横向滚动控制器，借用不释放',
            'ScrollController?',
            'null',
          ),
          ('child', '滚动区域内容', 'Widget', '必填'),
        ],
      ),
    ],
  );
}

/// The framework's own scrollbar over the same content, for comparison.
class _DefaultScroll extends StatefulWidget {
  const _DefaultScroll({required this.padding, required this.child});
  final EdgeInsets padding;
  final Widget child;
  @override
  State<_DefaultScroll> createState() => _DefaultScrollState();
}

class _DefaultScrollState extends State<_DefaultScroll> {
  final controller = ScrollController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scrollbar(
    controller: controller,
    thumbVisibility: true,
    child: SingleChildScrollView(
      controller: controller,
      padding: widget.padding,
      child: widget.child,
    ),
  );
}

/// Reference row `border-bottom: 1px dashed #e0d8c8`.
class _DashedRule extends CustomPainter {
  const _DashedRule();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = GalleryPalette.demoPanelDashedBorder;
    for (var x = 0.0; x < size.width; x += 6) {
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - 1, (size.width - x).clamp(0, 3), 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRule old) => false;
}
