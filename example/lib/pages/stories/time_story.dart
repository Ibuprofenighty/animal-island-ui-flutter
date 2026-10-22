import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class TimeStory extends StatelessWidget {
  const TimeStory({super.key});
  @override
  Widget build(BuildContext context) => const StoryPanel(
    title: 'Time',
    tags: ["实时时钟"],
    children: [
      StoryLabel('HUD 风格的实时时钟卡片，实时显示星期、月日与 HH:MM，每秒自动刷新。'),
      IslandTime(),
      StoryLabel('搭配语义标签自定义', strutStyle: storyCaptionStrut),
      IslandTime(semanticLabel: '岛屿时间'),
      StoryCode("const IslandTime()\nconst IslandTime(semanticLabel: '岛屿时间')"),
      StoryApi(
        rows: [
          ('semanticLabel', '自定义辅助技术标签', 'String?', 'null'),
          ('now', '时间来源；省略时为本地实时时间', 'DateTime Function()?', 'null'),
        ],
      ),
    ],
  );
}
