import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/palette.dart';
import '../../shared/story.dart';

/// Reference `.my-time` restyle, carried by [IslandTimeStyle].
final _timeCustomStyle = IslandTimeStyle(
  clockColor: GalleryPalette.timeCustomClock,
  weekdayColor: GalleryPalette.timeCustomWeekday,
  dateColor: GalleryPalette.timeCustomDate,
  separatorColor: GalleryPalette.timeCustomDot,
  capsuleColor: GalleryPalette.timeCustomCapsule,
  fontFamily: 'IslandGallerySans',
  capsuleFontSize: 15,
  padding: const EdgeInsets.fromLTRB(36, 24, 36, 18),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        GalleryPalette.timeCustomGradientStart,
        GalleryPalette.timeCustomGradientMiddle,
        IslandTokens.light.leaf,
      ],
      stops: const [0, .55, 1],
      transform: const CssGradientAngle(160),
    ),
    borderRadius: BorderRadius.circular(28),
    boxShadow: const [
      BoxShadow(
        color: GalleryPalette.timeCustomShadow,
        offset: Offset(0, 14),
        blurRadius: 30,
      ),
    ],
  ),
);

/// CSS `linear-gradient(<angle>, …)` geometry for a top-to-bottom
/// [LinearGradient]: the gradient line passes through the centre at
/// [degrees] (0 points up, clockwise) and is long enough for the corners to
/// meet the first and last stops.
class CssGradientAngle extends GradientTransform {
  const CssGradientAngle(this.degrees);

  /// CSS angle in degrees.
  final double degrees;
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final a = degrees * math.pi / 180;
    final length =
        (bounds.width * math.sin(a)).abs() +
        (bounds.height * math.cos(a)).abs();
    final c = bounds.center;
    return Matrix4.translationValues(c.dx, c.dy, 0)
      ..rotateZ(a - math.pi)
      ..scaleByDouble(1, length / bounds.height, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
  }
}

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
      const StoryLabel(
        '搭配 style 自定义：IslandTimeStyle 作用于根节点，用颜色角色换色并覆盖背景、描边与字体',
        strutStyle: storyCaptionStrut,
      ),
      IslandTime(style: _timeCustomStyle, semanticLabel: '岛屿时间'),
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
        "IslandTime(style: myTimeStyle, semanticLabel: '岛屿时间')",
      ),
      const StoryLabel(
        '自定义样式由使用方在 Dart 中提供',
        spaceAfter: 0,
        strutStyle: storyCaptionStrut,
      ),
      const StoryCode(
        "// 覆盖 Time 的样式角色：时钟、星期、日期、分隔点与胶囊颜色，日期字号、字体\n"
        "final myTimeStyle = IslandTimeStyle(\n"
        "  clockColor: Color(0xFFFFFDF4),\n"
        "  weekdayColor: Color(0xFFFFD166),\n"
        "  dateColor: Color(0xFFA0937E),\n"
        "  separatorColor: Color(0xFFE0BD75),\n"
        "  capsuleColor: Color(0xFF3D2A17),\n"
        "  fontFamily: 'Noto Sans SC',\n"
        "  capsuleFontSize: 15,\n"
        "  padding: EdgeInsets.fromLTRB(36, 24, 36, 18),\n"
        "  decoration: BoxDecoration(\n"
        "    // CSS linear-gradient(160deg, …)：CssGradientAngle 按 CSS 角度放置渐变线，实现见 Gallery time_story.dart\n"
        "    gradient: LinearGradient(\n"
        "      begin: Alignment.topCenter,\n"
        "      end: Alignment.bottomCenter,\n"
        "      colors: [Color(0xFF0F4C46), Color(0xFF00766B), Color(0xFF19C8B9)],\n"
        "      stops: [0, .55, 1],\n"
        "      transform: CssGradientAngle(160),\n"
        "    ),\n"
        "    borderRadius: BorderRadius.circular(28),\n"
        "    boxShadow: [\n"
        "      BoxShadow(\n"
        "        color: Color(0x470F4C46),\n"
        "        offset: Offset(0, 14),\n"
        "        blurRadius: 30,\n"
        "      ),\n"
        "    ],\n"
        "  ),\n"
        ");",
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
          (
            'style',
            '自定义样式：时钟、星期、日期、分隔与胶囊颜色，背景装饰、内边距、字体与胶囊字号；空字段沿用默认',
            'IslandTimeStyle?',
            'null',
          ),
          ('semanticLabel', '自定义辅助技术标签', 'String?', 'null'),
          ('now', '时间来源；省略时为本地实时时间', 'DateTime Function()?', 'null'),
        ],
      ),
    ],
  );
}
