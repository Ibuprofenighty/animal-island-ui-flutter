import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import '../../shared/photos.dart';

class AvatarStory extends StatefulWidget {
  const AvatarStory({super.key});
  @override
  State<AvatarStory> createState() => _AvatarStoryState();
}

class _AvatarStoryState extends State<AvatarStory> {
  IslandAvatarShape shape = IslandAvatarShape.circle;
  Widget section(
    String label,
    String title,
    List<Widget> children, {
    InlineSpan? titleSpan,
  }) => StoryPanel(
    title: title,
    heading: Row(
      spacing: 8,
      children: [
        IslandTag(
          size: IslandSize.small,
          variant: IslandTagVariant.soft,
          child: Text(label),
        ),
        Flexible(
          child: Text.rich(
            titleSpan ?? TextSpan(text: title),
            strutStyle: titleSpan != null
                ? null
                : const StrutStyle(
                    fontSize: 18,
                    height: 1.5,
                    forceStrutHeight: true,
                  ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff725d42),
              height: 4 / 3,
            ),
          ),
        ),
      ],
    ),
    children: [const SizedBox(height: 20), ...children],
  );
  Widget row(
    List<Widget> children, {
    double gap = 20,
    WrapCrossAlignment align = WrapCrossAlignment.center,
  }) => Wrap(
    spacing: gap,
    runSpacing: gap,
    crossAxisAlignment: align,
    children: children,
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      section('基础用法', '文字 / 图标 / 图片三种形态', [
        row([
          const IslandAvatar(child: Text('岛')),
          const IslandAvatar(icon: IslandIcon(IslandGlyph.image)),
          IslandAvatar(image: galleryPhoto(0), semanticLabel: '岛屿风景'),
        ]),
      ]),
      section('形状', '圆形 / 方形', [
        IslandRadioGroup<IslandAvatarShape>(
          options: const [
            IslandOption(value: IslandAvatarShape.circle, label: '圆形'),
            IslandOption(value: IslandAvatarShape.square, label: '方形'),
          ],
          value: shape,
          onChanged: (v) => setState(() => shape = v),
        ),
        const SizedBox(height: 12),
        row([
          IslandAvatar(shape: shape, child: const Text('岛')),
          IslandAvatar(shape: shape, icon: const IslandIcon(IslandGlyph.map)),
          IslandAvatar(
            shape: shape,
            image: galleryPhoto(4),
            semanticLabel: '阳光田野',
          ),
          IslandAvatar(
            shape: shape,
            size: IslandSize.large,
            image: galleryPhoto(5),
            semanticLabel: '湖畔清晨',
          ),
        ]),
      ]),
      section('头像组', '叠加展示 + 超出折叠', [
        row([
          IslandAvatarGroup(
            children: [
              for (var i = 0; i < 4; i++)
                IslandAvatar(
                  image: galleryPhoto(i),
                  semanticLabel: '岛民 ${['A', 'B', 'C', 'D'][i]}',
                ),
            ],
          ),
          IslandAvatarGroup(
            maxCount: 3,
            children: [
              for (final pair in [(4, 'E'), (5, 'F'), (0, 'J'), (1, 'K')])
                IslandAvatar(
                  image: galleryPhoto(pair.$1),
                  semanticLabel: '岛民 ${pair.$2}',
                ),
            ],
          ),
          IslandAvatarGroup(
            size: IslandSize.small,
            shape: IslandAvatarShape.square,
            overlap: 12,
            children: [
              for (var i = 6; i < 9; i++)
                IslandAvatar(
                  image: galleryPhoto(i),
                  semanticLabel: '岛民 ${['G', 'H', 'I'][i - 6]}',
                ),
            ],
          ),
        ], gap: 40),
      ]),
      section('尺寸', '预设三档 + 任意数值', [
        row([
          const IslandAvatar(size: IslandSize.small, child: Text('S')),
          const IslandAvatar(size: IslandSize.middle, child: Text('M')),
          const IslandAvatar(size: IslandSize.large, child: Text('L')),
          const IslandAvatar(dimension: 64, child: Text('64')),
          IslandAvatar(
            dimension: 96,
            image: galleryPhoto(14),
            semanticLabel: '岛屿远眺',
          ),
        ], align: WrapCrossAlignment.end),
      ]),
      section('加载失败', '自动回退到图标 / 文字', [
        row(const [
          IslandAvatar(
            image: AssetImage('assets/missing-avatar.png'),
            icon: IslandIcon(IslandGlyph.map),
          ),
          IslandAvatar(
            image: AssetImage('assets/missing-avatar.png'),
            child: Text('岛'),
          ),
        ]),
      ]),
      section(
        '图标头像',
        'naive-icons 图标作为 child',
        [
          row([
            for (final glyph in [
              IslandGlyph.image,
              IslandGlyph.coffeeCup,
              IslandGlyph.rabbit,
              IslandGlyph.owl,
              IslandGlyph.camera,
              IslandGlyph.sun,
              IslandGlyph.rainbow,
              IslandGlyph.cloud,
              IslandGlyph.star,
              IslandGlyph.leaf,
              IslandGlyph.mushroom,
              IslandGlyph.strawberry,
              IslandGlyph.donut,
              IslandGlyph.icecream,
              IslandGlyph.coffee,
              IslandGlyph.balloon,
              IslandGlyph.rocket,
              IslandGlyph.sailboat,
              IslandGlyph.music,
              IslandGlyph.heart,
            ])
              IslandAvatar(icon: IslandIcon(glyph)),
          ], gap: 16),
        ],
        titleSpan: const TextSpan(
          children: [
            TextSpan(text: 'naive-icons '),
            TextSpan(
              text: '图标作为 ',
              style: TextStyle(height: kTextHeightNone),
            ),
            TextSpan(text: 'child'),
          ],
        ),
      ),
      const StoryCode(
        spaceBefore: 0,
        "const IslandAvatar(child: Text('岛'))\nconst IslandAvatar(icon: IslandIcon(IslandGlyph.user))\nIslandAvatar(image: image, semanticLabel: '岛屿风景')\nIslandAvatarGroup(maxCount: 3, children: [\n  IslandAvatar(image: a), IslandAvatar(image: b),\n  const IslandAvatar(child: Text('C')),\n  const IslandAvatar(child: Text('D')),\n])",
      ),
      const SizedBox(height: 36),
      const StoryPanel(
        title: 'API — Avatar',
        children: [
          StoryApi(
            rows: [
              ('shape', '形状；显式子级优先于组默认值', 'IslandAvatarShape?', 'circle'),
              (
                'size / dimension',
                '预设尺寸 / 自定义像素；互斥',
                'IslandSize? / double?',
                'middle',
              ),
              ('image', '图片源；失败回退到内容', 'ImageProvider?', 'null'),
              ('semanticLabel', '辅助技术名称', 'String?', 'null'),
              ('icon / child', '显式图标 / 通用内容插槽', 'Widget?', 'null'),
              ('gap', '内容内边距', 'double', '4'),
              ('onImageError', '返回 false 阻止回退', 'callback', 'null'),
            ],
          ),
        ],
      ),
      const StoryPanel(
        title: 'API — Avatar.Group',
        children: [
          StoryApi(
            rows: [
              ('children', '保留 Key 和自身行为的子组件', 'List<Widget>', 'required'),
              ('maxCount', '最大显示数量，超出为 +N', 'int?', 'null'),
              (
                'size / dimension / shape',
                '仅为未显式设置的头像提供默认值',
                'nullable',
                'null',
              ),
              ('overlap', '头像重叠距离', 'double', '8'),
              ('moreBuilder', '折叠标识插槽', 'Widget Function(int)?', 'null'),
            ],
          ),
        ],
      ),
    ],
  );
}
