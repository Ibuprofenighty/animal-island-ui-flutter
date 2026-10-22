import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class FooterStory extends StatelessWidget {
  const FooterStory({super.key});
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Footer',
    tags: ["版权栏"],
    children: [
      const StoryLabel(
        'Footer 版权栏 — 默认展示 © 当前年份 All Rights Reserved.，年份动态获取、文案可传参自定义。',
      ),
      const StoryLabel('默认', spaceBefore: 0, strutStyle: storyCaptionStrut),
      const IslandFooter(),
      const StoryLabel('自定义文案', strutStyle: storyCaptionStrut),
      const IslandFooter(text: 'Pocket Projects Inc.'),
      const StoryLabel('自定义年份 / 样式', strutStyle: storyCaptionStrut),
      DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xfff7f3ea),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const IslandFooter(text: 'Acme Ltd.', year: 2020),
      ),
      const StoryCode(
        "const IslandFooter()\nconst IslandFooter(text: 'Acme Ltd.')\nconst IslandFooter(text: 'Acme', year: 2020)",
      ),
      const StoryApi(
        rows: [
          ('text', '版权文案', 'String', 'All Rights Reserved.'),
          ('year', '年份，省略时取当前年份', 'int?', 'null'),
          ('style', '文字样式覆盖', 'TextStyle?', 'null'),
          ('padding', '内边距', 'EdgeInsetsGeometry', 'vertical: 16'),
        ],
      ),
    ],
  );
}
