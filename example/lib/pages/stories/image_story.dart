import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import '../../shared/photos.dart';

// Reference shuffles the public photo pool once per application load.
final _photos = List<String>.of(galleryPhotos)..shuffle();

class ImageStory extends StatelessWidget {
  const ImageStory({super.key});
  Widget photo(
    int index,
    String alt, {
    double width = 330,
    double height = 200,
    IslandImageVariant variant = IslandImageVariant.normal,
    IslandColorway? colorway,
    String? year,
  }) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: width),
    child: AspectRatio(
      aspectRatio: width / height,
      child: IslandImage(
        image: AssetImage('assets/photos/${_photos[index % _photos.length]}'),
        alt: alt,
        width: width,
        height: height,
        variant: variant,
        colorway: colorway,
        stampYear: year,
        lazy: true,
      ),
    ),
  );
  Widget caption(Widget image, String label) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      image,
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          label,
          strutStyle: const StrutStyle(
            fontSize: 12,
            height: 1.5,
            forceStrutHeight: true,
          ),
          style: TextStyle(
            fontSize: 12,
            color: IslandTokens.light.muted,
            height: kTextHeightNone,
          ),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Image',
    tags: ["13 props"],
    children: [
      const StoryLabel(
        '点击预览（preview 默认开启，点击图片弹出大图，ESC / 遮罩 / 关闭按钮均可关闭）',
        strutStyle: storyCaptionStrut,
      ),
      photo(0, '点击预览大图'),
      const StoryLabel(
        '相框类型（variant）— default 卡片大阴影+大圆角（默认），bordered 柔和阴影+小圆角（原样式）',
        strutStyle: storyCaptionStrut,
      ),
      storyRow([
        caption(photo(1, '默认类型'), 'default（默认）'),
        caption(
          photo(2, '边框类型', variant: IslandImageVariant.bordered),
          'bordered（边框）',
        ),
      ]),
      const StoryLabel(
        '邮票类型（variant="stamp"）— 四周齿孔 + 暖白底纸 + 半色调网点；可选 stampYear 在右上角印发行年份',
        strutStyle: storyCaptionStrut,
      ),
      storyRow([
        caption(
          photo(
            1,
            '邮票（带年份）',
            width: 210,
            height: 154,
            variant: IslandImageVariant.stamp,
            year: '2026',
          ),
          '带年份',
        ),
        caption(
          photo(
            2,
            '纯邮票边框',
            width: 210,
            height: 154,
            variant: IslandImageVariant.stamp,
          ),
          '仅齿孔边框（无文字）',
        ),
      ]),
      const StoryLabel('基础用法（自定义宽高）', strutStyle: storyCaptionStrut),
      storyRow([
        photo(3, '林间溪流'),
        photo(4, '阳光田野', width: 480, height: 300),
      ], align: WrapCrossAlignment.center),
      const StoryLabel(
        '背景颜色（color，Card pattern 同款底色，无花纹）',
        strutStyle: storyCaptionStrut,
      ),
      storyRow([
        for (final entry in <(IslandColorway?, String)>[
          (null, 'White 白色'),
          (IslandColorway.neutral, 'Default 奶油色'),
          (IslandColorway.pink, 'App Pink 应用粉'),
          (IslandColorway.purple, 'Purple 紫色'),
          (IslandColorway.blue, 'App Blue 应用蓝'),
          (IslandColorway.yellow, 'App Yellow 应用黄'),
          (IslandColorway.orange, 'App Orange 应用橙'),
          (IslandColorway.teal, 'App Teal 应用青'),
          (IslandColorway.green, 'App Green 应用绿'),
          (IslandColorway.red, 'App Red 应用红'),
          (IslandColorway.lime, 'Lime Green 青柠绿'),
          (IslandColorway.yellowGreen, 'Yellow-Green 黄绿色'),
          (IslandColorway.brown, 'Brown 棕色'),
          (IslandColorway.peach, 'Warm Peach Pink 暖桃粉'),
        ].indexed)
          caption(
            photo(
              entry.$1 + 5,
              entry.$2.$2,
              width: 300,
              variant: IslandImageVariant.bordered,
              colorway: entry.$2.$1,
            ),
            entry.$2.$2,
          ),
      ]),
      const StoryLabel('懒加载（lazy，滚动到视口附近才加载）', strutStyle: storyCaptionStrut),
      photo(4, '晨光湖面', width: 360, height: 230),
      const StoryLabel('错误占位（加载失败时显示占位）', strutStyle: storyCaptionStrut),
      const IslandImage(
        image: AssetImage('no-such-image.png'),
        alt: '加载失败',
        width: 210,
        height: 210,
      ),
      const StoryCode("""IslandImage(
  image: AssetImage('photo.png'),
  alt: '岛屿风景', width: 330, height: 200,
)
IslandImage(
  image: AssetImage('photo.png'),
  alt: '邮票', width: 210, height: 154,
  variant: IslandImageVariant.stamp, stampYear: '2026', lazy: true,
)"""),
      const StoryApi(
        rows: [
          ('image *', 'Flutter 图片来源；无需绑定 URL 或文件平台', 'ImageProvider', '—'),
          ('alt', '替代文本；空表示装饰图片', 'String', '空'),
          ('width / height', '外框尺寸', 'double?', '自然尺寸'),
          ('colorway', '纸张底色，仅边框/错误态生效；null 为白色', 'IslandColorway?', '—'),
          ('variant', '普通 / 边框 / 邮票', 'IslandImageVariant', 'normal'),
          ('stampYear', '照片右上角年份', 'String?', '—'),
          ('lazy', '接近视口后加载', 'bool', 'false'),
          ('preview', '点击、Enter、Space 打开大图', 'bool', 'true'),
          ('fit', '照片缩放方式', 'BoxFit', 'fill'),
          (
            'onLoaded / onError',
            '每个来源只通知一次；忽略过期回调',
            'VoidCallback? / error callback?',
            '—',
          ),
        ],
      ),
    ],
  );
}
