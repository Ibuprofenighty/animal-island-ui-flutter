import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class BadgeStory extends StatelessWidget {
  const BadgeStory({super.key});
  Widget avatar(Widget child) => IslandAvatar(
    shape: IslandAvatarShape.square,
    size: IslandSize.large,
    child: child,
  );
  Widget row(List<Widget> children, {double gap = 28}) => Wrap(
    spacing: gap,
    runSpacing: gap,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Badge',
    tags: ["数字角标", "封顶数字", "小红点", "12 colors"],
    children: [
      const StoryLabel('基本：图标 / 头像右上角的徽标数', strutStyle: storyCaptionStrut),
      row([
        IslandBadge(
          count: 5,
          child: avatar(const IslandIcon(IslandGlyph.bell, size: 24)),
        ),
        IslandBadge(count: 12, child: avatar(const Text('狸'))),
        IslandBadge(
          indicator: const IslandIcon(IslandGlyph.gift, size: 12),
          color: IslandColorway.purple,
          child: avatar(const IslandIcon(IslandGlyph.mail, size: 24)),
        ),
      ]),
      const StoryLabel('count 为 0 时默认隐藏，showZero 可强制展示'),
      row([
        for (final show in [false, true])
          IslandBadge(count: 0, showZero: show, child: avatar(const Text('零'))),
      ]),
      const StoryLabel('独立使用：不包裹任何元素，可单独作为计数展示', strutStyle: storyCaptionStrut),
      row(const [
        IslandBadge(count: 11),
        IslandBadge(count: 25, color: IslandColorway.teal),
        IslandBadge(text: '新', color: IslandColorway.orange),
        IslandBadge(count: 0, showZero: true, color: IslandColorway.brown),
      ]),
      const StoryLabel('封顶数字：超过 overflowCount（默认 99）时显示为「99+」'),
      row([
        IslandBadge(count: 99, child: avatar(const Text('99'))),
        IslandBadge(count: 100, child: avatar(const Text('100'))),
        IslandBadge(
          count: 99,
          overflowCount: 10,
          child: avatar(const Text('10+')),
        ),
        IslandBadge(
          count: 1000,
          overflowCount: 999,
          child: avatar(const Text('999+', style: TextStyle(fontSize: 16))),
        ),
      ]),
      const StoryLabel('讨嫌的小红点：没有具体数字，只有一个小圆点', strutStyle: storyCaptionStrut),
      row([
        IslandBadge(
          dot: true,
          child: avatar(const IslandIcon(IslandGlyph.bell, size: 24)),
        ),
        const IslandBadge(
          dot: true,
          color: IslandColorway.green,
          child: IslandIcon(IslandGlyph.bell, size: 26),
        ),
        const IslandBadge(
          dot: true,
          color: IslandColorway.teal,
          child: Text(
            '一段文字',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff725d42),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]),
      const StoryLabel('size 尺寸（medium / small）'),
      row([
        IslandBadge(count: 5, child: avatar(const Text('M'))),
        IslandBadge(
          count: 5,
          size: IslandBadgeSize.small,
          child: avatar(const Text('S')),
        ),
        const IslandBadge(
          count: 5,
          size: IslandBadgeSize.small,
          color: IslandColorway.blue,
        ),
      ]),
      const StoryLabel('color 多彩徽标（与 Card / Tag 同一调色板）'),
      row([
        for (final color in [
          IslandColorway.red,
          IslandColorway.pink,
          IslandColorway.orange,
          IslandColorway.yellow,
          IslandColorway.teal,
          IslandColorway.green,
          IslandColorway.blue,
          IslandColorway.purple,
          IslandColorway.lime,
          IslandColorway.yellowGreen,
          IslandColorway.brown,
          IslandColorway.peach,
        ])
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IslandBadge(count: 12, color: color),
              const SizedBox(height: 6),
              Text(
                color.referenceName,
                strutStyle: const StrutStyle(
                  fontSize: 11,
                  height: 15 / 11,
                  forceStrutHeight: true,
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: IslandTokens.light.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ], gap: 18),
      const StoryCode(
        "const IslandBadge(\n  count: 5,\n  child: IslandAvatar(\n    shape: IslandAvatarShape.square,\n    size: IslandSize.large,\n    icon: IslandIcon(IslandGlyph.bell, size: 24),\n  ),\n)\nconst IslandBadge(count: 100, overflowCount: 99)\nconst IslandBadge(dot: true, child: Text('消息'))",
      ),
      const StoryApi(
        rows: [
          (
            'count / text / indicator',
            '数字 / 文本 / 显式内容；互斥',
            'num? / String? / Widget?',
            'null',
          ),
          ('overflowCount', '数字显示上限', 'num', '99'),
          ('showZero', '显示零值', 'bool', 'false'),
          ('dot', '显示小圆点', 'bool', 'false'),
          ('size', '数字徽标尺寸', 'IslandBadgeSize', 'medium'),
          ('color', '公共配色', 'IslandColorway', 'red'),
          ('child', '被包裹的组件；省略为独立展示', 'Widget?', 'null'),
          ('semanticLabel', '自定义读屏说明', 'String?', 'null'),
        ],
      ),
    ],
  );
}
