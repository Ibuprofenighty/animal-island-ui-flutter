import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

const _labels = [
  ('Default', '默认奶油色'),
  ('App Pink', '应用粉'),
  ('Purple', '紫色'),
  ('App Blue', '应用蓝'),
  ('App Yellow', '应用黄'),
  ('App Orange', '应用橙'),
  ('App Teal', '应用青'),
  ('App Green', '应用绿'),
  ('App Red', '应用红'),
  ('Lime Green', '青柠绿'),
  ('Yellow-Green', '黄绿色'),
  ('Brown', '棕色'),
  ('Warm Peach Pink', '暖桃粉'),
];

class CardStory extends StatelessWidget {
  const CardStory({super.key});
  Widget paragraph(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5625)),
  );
  Widget sample(IslandColorway color, {required bool pattern}) {
    final labels = _labels[color.index];
    return IslandCard(
      colorway: color,
      pattern: pattern ? color : null,
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: pattern ? 24 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pattern ? color.referenceName : labels.$1,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: kTextHeightNone,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            labels.$2,
            strutStyle: const StrutStyle(
              fontSize: 12,
              height: 1.5,
              forceStrutHeight: true,
            ),
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Card',
    tags: ["2 types", "13 colors", "14 patterns"],
    children: [
      const StoryLabel('type="default"'),
      storyRow([
        IslandCard(child: paragraph('基础卡片')),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SizedBox(
            width: double.infinity,
            child: IslandCard(
              child: paragraph(
                '长文本卡片示例：卡片组件适合展示一段介绍文字、列表内容或图文混排信息，内容过长时会自动换行并保持内边距一致。',
              ),
            ),
          ),
        ),
      ]),
      const StoryLabel('type="dashed"'),
      storyRow([
        IslandCard(
          variant: IslandCardVariant.dashed,
          child: paragraph('虚线边框卡片'),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SizedBox(
            width: double.infinity,
            child: IslandCard(
              variant: IslandCardVariant.dashed,
              child: paragraph('欢迎来到小岛！虚线边框适合用于轻量提示或次要信息展示。'),
            ),
          ),
        ),
      ]),
      const StoryLabel('hoverable 启用 hover(默认关闭)'),
      SizedBox(
        width: 260,
        child: IslandCard(hoverable: true, child: paragraph('鼠标移上来看看 ↑')),
      ),
      const StoryLabel('pattern — 风格花纹'),
      const SizedBox(height: 24),
      storyRow([
        for (final color in IslandColorway.values)
          SizedBox(width: 170, child: sample(color, pattern: true)),
      ]),
      const StoryLabel('color'),
      LayoutBuilder(
        builder: (_, constraints) {
          final columns = ((constraints.maxWidth + 16) / 156).floor().clamp(
            1,
            13,
          );
          final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final color in IslandColorway.values)
                SizedBox(width: width, child: sample(color, pattern: false)),
            ],
          );
        },
      ),
      const SizedBox(height: 24),
      const StoryCode("""IslandCard(child: Text('基础卡片'))
IslandCard(variant: IslandCardVariant.dashed, child: Text('虚线卡片'))
IslandCard(colorway: IslandColorway.blue, child: Text('蓝色卡片'))
IslandCard(pattern: IslandColorway.neutral, child: Text('默认花纹卡片'))
IslandCard(hoverable: true, child: Text('鼠标移上来看看 ↑'))"""),
      const StoryApi(
        rows: [
          ('variant', '卡片类型', 'IslandCardVariant', 'normal'),
          ('colorway', '背景及嵌套控件的配对语义色', 'IslandColorway', 'neutral'),
          ('pattern', '背景花纹；null 关闭', 'IslandColorway?', 'null'),
          ('hoverable', '启用 hover', 'bool', 'false'),
          ('child *', '自定义内容', 'Widget', '—'),
          ('header / footer', '可选内容槽', 'Widget?', '—'),
          ('onTap', '卡片激活回调', 'VoidCallback?', '—'),
          (
            'padding / style',
            '局部布局与完整表面角色；见组件契约',
            'EdgeInsetsGeometry? / IslandCardStyle?',
            'null',
          ),
        ],
      ),
    ],
  );
}
