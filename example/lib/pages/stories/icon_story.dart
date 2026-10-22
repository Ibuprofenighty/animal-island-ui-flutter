import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import '../../shared/icon_labels.dart';

class IconStory extends StatelessWidget {
  const IconStory({super.key});
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Icon',
    tags: ["naive-icons"],
    children: [
      const StoryLabel(
        '图标来自 naive-icons —— 手绘 naive folk art 风格的 SVG 图标库，150+ 个原创图标；Flutter 包已内置固定版本资源。',
        spaceAfter: 0,
      ),
      const StoryCode(
        'dependencies:\n  animal_island_ui:\n    path: ../animal_island_ui',
        label: '安装',
      ),
      const StoryLabel('文档与完整示例参考 https://github.com/guokaigdg/naive-icons'),
      const StoryLabel('基础用法', spaceBefore: 0),
      Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final icon in [
            IslandGlyph.flower,
            IslandGlyph.mic,
            IslandGlyph.star,
            IslandGlyph.sun,
            IslandGlyph.umbrella,
            IslandGlyph.wifi,
            IslandGlyph.map,
            IslandGlyph.camera,
          ])
            IslandIcon(icon, size: 32),
        ],
      ),
      const StoryLabel('size 尺寸'),
      const Row(
        spacing: 20,
        children: [
          IslandIcon(IslandGlyph.heart, size: 16),
          IslandIcon(IslandGlyph.heart),
          IslandIcon(IslandGlyph.heart, size: 32),
          IslandIcon(IslandGlyph.heart, size: 48),
        ],
      ),
      const StoryLabel('color / strokeWidth 自定义'),
      Row(
        spacing: 20,
        children: [
          const IslandIcon(
            IslandGlyph.coffee,
            size: 32,
            color: const Color(0xffe05260),
            strokeWidth: 3,
          ),
          const IslandIcon(
            IslandGlyph.cherry,
            size: 32,
            color: const Color(0xff2a9d8f),
            strokeWidth: 3,
          ),
          IslandIcon(
            IslandGlyph.bulb,
            size: 32,
            color: IslandColorway.yellow.ink,
            strokeWidth: 3,
          ),
        ],
      ),
      const StoryLabel('全部图标', strutStyle: storyCaptionStrut),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffe8e2d6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final count = ((constraints.maxWidth + 14) / 134).floor().clamp(
              1,
              20,
            );
            final width = (constraints.maxWidth - (count - 1) * 14) / count;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final glyph in (List<IslandGlyph>.of(
                  IslandGlyph.values,
                )..sort((a, b) => '${a.name}Icon'.compareTo('${b.name}Icon'))))
                  SizedBox(width: width, child: _IconTile(glyph)),
              ],
            );
          },
        ),
      ),
      const StoryLabel('使用示例', strutStyle: storyCaptionStrut),
      const IslandCodeBlock(
        code: "const IslandIcon(IslandGlyph.flower, size: 32, color: Color(0xffe05260), strokeWidth: 3)",
      ),
      const StoryApi(
        rows: [
          ('glyph', '固定图标标识', 'IslandGlyph', 'required'),
          ('size', '宽高相等', 'double', '24'),
          ('color', '必要描边继承；有填色内部颜色保留', 'Color?', 'IconTheme'),
          ('strokeWidth', '按设计比例缩放全部描边', 'double', '3.5'),
          ('semanticLabel', '有意义图标的名称；null 为装饰', 'String?', 'null'),
        ],
      ),
    ],
  );
}

class _IconTile extends StatefulWidget {
  const _IconTile(this.glyph);
  final IslandGlyph glyph;
  @override
  State<_IconTile> createState() => _IconTileState();
}

class _IconTileState extends State<_IconTile> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final name = widget.glyph.name;
    final title = name[0].toUpperCase() + name.substring(1);
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: TweenAnimationBuilder<Matrix4>(
        tween: Matrix4Tween(
          end: Matrix4.translationValues(0, hover ? -2 : 0, 0),
        ),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 150),
        curve: Curves.ease,
        builder: (_, matrix, child) => Transform(
          transform: matrix,
          filterQuality: FilterQuality.low,

          child: child,
        ),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          curve: Curves.ease,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
          decoration: BoxDecoration(
            color: hover ? const Color(0xfffaf7f0) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hover ? const Color(0xffe8dec7) : Colors.transparent,
            ),
          ),
          child: Column(
            spacing: 8,
            children: [
              IslandIcon(widget.glyph, size: 45),
              Text(
                '${title}Icon',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                strutStyle: const StrutStyle(
                  fontSize: 11,
                  height: 13 / 11,
                  forceStrutHeight: true,
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: IslandTheme.codeFontFamily,
                  height: 13 / 11,
                  letterSpacing: 0,
                  color: IslandTokens.light.muted,
                ),
              ),
              Text(
                iconLabels[name] ?? title,
                strutStyle: StrutStyle(
                  fontSize: 13,
                  height:
                      RegExp(r'[\u3400-\u9fff]')
                          .hasMatch(iconLabels[name] ?? title)
                      ? 20 / 13
                      : 18 / 13,
                  forceStrutHeight: true,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff725d42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
