import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class TagStory extends StatefulWidget {
  const TagStory({super.key});
  @override
  State<TagStory> createState() => _TagStoryState();
}

class _TagStoryState extends State<TagStory> {
  final items = <String, IslandColorway>{
    'Apple': IslandColorway.pink,
    'Banana': IslandColorway.yellow,
    'Grape': IslandColorway.purple,
    'Blueberry': IslandColorway.blue,
    'Mint': IslandColorway.teal,
    'Lime': IslandColorway.lime,
    'Orange': IslandColorway.orange,
  };
  void alert(String text) =>
      showIslandModal<void>(context: context, builder: (_) => Text(text));
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Tag',
    tags: ["4 variants", "16 colors", "3 sizes"],
    children: [
      const StoryLabel('variant 风格变体'),
      storyRow([
        const IslandTag(variant: IslandTagVariant.solid, child: Text('solid')),
        const IslandTag(
          variant: IslandTagVariant.outlined,
          colorway: IslandColorway.blue,
          child: Text('outlined'),
        ),
        const IslandTag(
          variant: IslandTagVariant.soft,
          colorway: IslandColorway.green,
          child: Text('soft'),
        ),
        const IslandTag(
          variant: IslandTagVariant.dashed,
          colorway: IslandColorway.orange,
          child: Text('dashed'),
        ),
        const IslandTag(
          variant: IslandTagVariant.soft,
          colorway: IslandColorway.red,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [IslandIcon(IslandGlyph.flame, size: 18), Text(' hot')],
          ),
        ),
      ]),
      const StoryLabel('size 尺寸'),
      storyRow([
        for (final size in IslandSize.values)
          IslandTag(
            size: size,
            colorway: IslandColorway.blue,
            child: Text(size == IslandSize.middle ? 'medium' : size.name),
          ),
      ]),
      for (final variant in [
        IslandTagVariant.soft,
        IslandTagVariant.solid,
        IslandTagVariant.outlined,
        IslandTagVariant.dashed,
      ]) ...[
        StoryLabel(
          'color 颜色（${variant.name}${variant == IslandTagVariant.soft ? ' · 同色系' : ''}）',
        ),
        storyRow([
          for (final color in IslandColorway.values)
            IslandTag(
              variant: variant,
              colorway: color,
              child: Text(color.referenceName),
            ),
        ]),
      ],
      const StoryLabel('closable 可关闭'),
      storyRow([
        for (final item in items.entries)
          IslandTag(
            key: ValueKey(item.key),
            variant: IslandTagVariant.soft,
            colorway: item.value,
            onClose: () => setState(() => items.remove(item.key)),
            child: Text(item.key),
          ),
        if (items.isEmpty) const Text('所有标签都已关闭'),
      ]),
      const StoryLabel('onClick 可点击（hover + 键盘 Enter / Space 触发）'),
      storyRow([
        IslandTag(
          colorway: IslandColorway.blue,
          onPressed: () => alert('点了 Tag'),
          child: const Text('可点击'),
        ),
        IslandTag(
          variant: IslandTagVariant.outlined,
          colorway: IslandColorway.green,
          onPressed: () => alert('点了 outlined Tag'),
          child: const Text('outlined 可点击'),
        ),
        IslandTag(
          colorway: IslandColorway.brown,
          disabled: true,
          onPressed: () {},
          child: const Text('disabled'),
        ),
      ]),
      const StoryCode(
        "IslandTag(\n  colorway: IslandColorway.blue,\n  onClose: () => setState(() => items.remove(id)),\n  child: const Text('Blueberry'),\n)",
      ),
      const StoryApi(
        rows: [
          ('child', '标签内容；显式子样式优先', 'Widget', 'required'),
          ('variant', '风格变体', 'IslandTagVariant', 'soft'),
          ('colorway', '13色；填充表面为嵌套控件提供配对前景', 'IslandColorway', 'neutral'),
          ('size', '尺寸', 'IslandSize', 'middle'),
          ('onClose', '独立关闭请求；父级决定是否移除，悬停使用浅底可读色对', 'VoidCallback?', 'null'),
          ('onPressed', '点击、Enter、Space 激活', 'VoidCallback?', 'null'),
          ('closeLabel', '关闭动作的语义名称', 'String', 'close'),
          ('disabled', '禁用标签和关闭动作', 'bool', 'false'),
        ],
      ),
    ],
  );
}
