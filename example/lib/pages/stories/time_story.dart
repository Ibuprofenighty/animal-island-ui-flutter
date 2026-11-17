import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class TimeStory extends StatelessWidget {
  const TimeStory({super.key});
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Time',
    tags: const ["实时时钟"],
    children: [
      const StoryLabel('HUD 风格的实时时钟卡片，实时显示星期、月日与 HH:MM，每秒自动刷新。'),
      const IslandTime(),
      const StoryLabel(
        'variant="game" — 竖排 HUD：时间 / 分割线 / 月日 + 周几',
        strutStyle: storyCaptionStrut,
      ),
      storyRow(const [
        IslandTime(variant: IslandTimeVariant.game),
        IslandTime(
          variant: IslandTimeVariant.game,
          locale: IslandTimeLocale.zhCn,
        ),
      ]),
      const StoryLabel(
        '中文日期：locale="zh-cn"（内置，无需额外注册）',
        strutStyle: storyCaptionStrut,
      ),
      const IslandTime(locale: IslandTimeLocale.zhCn),
      const StoryLabel('用 dayjs token 定制星期与月日', strutStyle: storyCaptionStrut),
      storyRow(align: WrapCrossAlignment.center, const [
        IslandTime(weekdayFormat: 'ddd', dateFormat: 'YYYY/MM/DD'),
        IslandTime(
          locale: IslandTimeLocale.zhCn,
          weekdayFormat: 'ddd',
          dateFormat: 'YYYY年M月D日',
        ),
      ]),
      const StoryLabel('搭配语义标签自定义', strutStyle: storyCaptionStrut),
      const IslandTime(semanticLabel: '岛屿时间'),
      const StoryCode(
        "const IslandTime()\n"
        "const IslandTime(variant: IslandTimeVariant.game)\n"
        "const IslandTime(\n"
        "  variant: IslandTimeVariant.game,\n"
        "  locale: IslandTimeLocale.zhCn,\n"
        ")\n"
        "const IslandTime(locale: IslandTimeLocale.zhCn)\n"
        "const IslandTime(weekdayFormat: 'ddd', dateFormat: 'YYYY/MM/DD')\n"
        "const IslandTime(\n"
        "  locale: IslandTimeLocale.zhCn,\n"
        "  weekdayFormat: 'ddd',\n"
        "  dateFormat: 'YYYY年M月D日',\n"
        ")\n"
        "const IslandTime(semanticLabel: '岛屿时间')",
      ),
      const StoryApi(
        rows: [
          (
            'variant',
            '展示变体：normal 时钟卡片 / game 竖排 HUD（时间 / 分割线 / 月日 + 周几）',
            'IslandTimeVariant',
            'IslandTimeVariant.normal',
          ),
          ('weekdayFormat', '星期格式（dayjs 核心 token）', 'String', "'dddd'"),
          (
            'dateFormat',
            '月日格式（dayjs 核心 token）',
            'String?',
            "'MMM D'（zhCn 下 'M月D日'）",
          ),
          ('locale', '日期行语言', 'IslandTimeLocale', 'IslandTimeLocale.en'),
          ('semanticLabel', '自定义辅助技术标签', 'String?', 'null'),
          ('now', '时间来源；省略时为本地实时时间', 'DateTime Function()?', 'null'),
        ],
      ),
    ],
  );
}
