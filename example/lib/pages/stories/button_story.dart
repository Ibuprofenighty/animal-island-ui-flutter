import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class ButtonStory extends StatelessWidget {
  const ButtonStory({super.key});
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Button',
    tags: ["6 types"],
    children: [
      const StoryLabel('type 按钮类型'),
      storyRow([
        primary('Primary'),
        IslandButton(onPressed: () {}, child: const Text('Default')),
        IslandButton(
          variant: IslandButtonVariant.dashed,
          onPressed: () {},
          child: const Text('Dashed'),
        ),
        IslandButton(
          variant: IslandButtonVariant.text,
          onPressed: () {},
          child: const Text('Text'),
        ),
        IslandButton(
          variant: IslandButtonVariant.link,
          onPressed: () {},
          child: const Text('Link'),
        ),
      ]),
      const StoryLabel('danger / ghost / loading / disabled 状态'),
      storyRow([
        IslandButton(
          variant: IslandButtonVariant.primary,
          danger: true,
          onPressed: () {},
          child: const Text('Danger'),
        ),
        IslandButton(
          variant: IslandButtonVariant.primary,
          ghost: true,
          onPressed: () {},
          child: const Text('Ghost'),
        ),
        IslandButton(
          variant: IslandButtonVariant.primary,
          busy: true,
          onPressed: () {},
          child: const Text('Loading'),
        ),
        const IslandButton(
          variant: IslandButtonVariant.primary,
          onPressed: null,
          child: Text('Disabled'),
        ),
      ]),
      const StoryLabel('size 尺寸'),
      storyRow([
        primary('Small', size: IslandSize.small),
        primary('Middle'),
        primary('Large', size: IslandSize.large),
      ]),
      const StoryLabel('icon 图标按钮'),
      storyRow([
        IslandButton(
          variant: IslandButtonVariant.primary,
          icon: const IslandIcon(IslandGlyph.search),
          onPressed: () {},
          child: const Text('搜索'),
        ),
        IslandButton(
          icon: const IslandIcon(IslandGlyph.star),
          onPressed: () {},
          child: const Text('收藏'),
        ),
        IslandButton(
          variant: IslandButtonVariant.dashed,
          icon: const Text('＋'),
          onPressed: () {},
          child: const Text('新增'),
        ),
      ]),
      const StoryLabel('block 块级按钮'),
      SizedBox(
        width: 360,
        child: IslandButton(
          variant: IslandButtonVariant.primary,
          block: true,
          onPressed: () {},
          child: const Text('Block Button'),
        ),
      ),
      const StoryLabel('danger 组合'),
      storyRow([
        for (final entry in <(IslandButtonVariant, String)>[
          (IslandButtonVariant.primary, 'Primary Danger'),
          (IslandButtonVariant.normal, 'Default Danger'),
          (IslandButtonVariant.dashed, 'Dashed Danger'),
          (IslandButtonVariant.text, 'Text Danger'),
          (IslandButtonVariant.link, 'Link Danger'),
        ])
          IslandButton(
            variant: entry.$1,
            danger: true,
            onPressed: () {},
            child: Text(entry.$2),
          ),
      ]),
      const StoryCode(
        "IslandButton(\n  variant: IslandButtonVariant.primary,\n  onPressed: () {},\n  child: const Text('Primary'),\n)",
      ),

      const StoryApi(
        rows: [
          ("child / icon", "内容与图标插槽", "Widget / Widget?", "required / null"),
          ("onPressed", "操作回调；null 禁用", "VoidCallback?", "required"),
          ("variant", "按钮类型", "IslandButtonVariant", "normal"),
          ("size", "三种尺寸", "IslandSize", "middle"),
          ("busy / danger / ghost / block", "加载、危险、幽灵、块级", "bool", "false"),
          ("style", "实例样式；支持范围及逐状态回落见Button契约", "ButtonStyle?", "null"),
          (
            "focusNode / autofocus",
            "焦点由调用方持有",
            "FocusNode? / bool",
            "null / false",
          ),
          ("semanticLabel", "辅助技术名称", "String?", "null"),
        ],
      ),
    ],
  );
}
