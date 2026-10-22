import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class DividerStory extends StatelessWidget {
  const DividerStory({super.key});
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Divider',
    tags: ["5 types + icon divider · pure CSS"],
    children: [
      const StoryLabel('dashed-brown（虚线棕色，默认）'),
      const IslandDivider(),
      const StoryLabel('thin（1px 细线）'),
      const IslandDivider(variant: IslandDividerVariant.thin),
      const StoryLabel('hairline（1px 细密虚线）'),
      const IslandDivider(variant: IslandDividerVariant.hairline),
      const StoryLabel('wave-yellow（黄色波浪线）'),
      const IslandDivider(variant: IslandDividerVariant.waveYellow),
      const StoryLabel('squiggle（主题青色波浪线）'),
      const IslandDivider(variant: IslandDividerVariant.squiggle),
      const StoryLabel('icon（单图标相连分割线）'),
      for (final glyph in [
        IslandGlyph.bee,
        IslandGlyph.fish,
        IslandGlyph.flower,
        IslandGlyph.watermelon,
        IslandGlyph.star,
        IslandGlyph.rainbow,
        IslandGlyph.cloud,
        IslandGlyph.cactus,
        IslandGlyph.cake,
        IslandGlyph.coffee,
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: IslandDivider(iconBuilder: (_) => IslandIcon(glyph, size: 24)),
        ),
      const StoryCode(
        'IslandDivider(variant: IslandDividerVariant.waveYellow)\nIslandDivider(iconBuilder: (_) => const IslandIcon(IslandGlyph.fish))',
      ),
      const StoryApi(
        rows: [
          ('variant', '分隔线类型', 'IslandDividerVariant', 'dashedBrown'),
          ('iconBuilder', '重复图标插槽，优先于 variant', 'WidgetBuilder?', 'null'),
          ('iconSize', '图标尺寸', 'double', '24'),
          ('iconGap', '图标间距', 'double', '8'),
        ],
      ),
    ],
  );
}
