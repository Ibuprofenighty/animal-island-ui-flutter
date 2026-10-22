import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class CarouselStory extends StatelessWidget {
  const CarouselStory({super.key});
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Carousel',
    tags: ["轮播图", "键盘可用"],
    children: [
      const StoryLabel('自动播放（悬停或聚焦时暂停）', strutStyle: storyCaptionStrut),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: IslandCarousel.uncontrolled(
          autoplay: true,
          interval: const Duration(milliseconds: 3500),
          semanticLabel: '岛屿风景',
          items: [
            for (final slide in const [
              ('hillside-town.jpg', '山坡小筑', '沿坡而建的小镇，屋顶连成一片暖色。'),
              ('sunny-field.jpg', '阳光田野', '风掠过田野，草浪一层层推向天边。'),
              ('lake-morning.jpg', '晨光湖面', '湖面倒映天光，晨雾如薄纱浮在水上。'),
            ])
              IslandSlide(
                value: slide.$1,
                child: Container(
                  height: 360,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/photos/${slide.$1}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0, .62],
                        colors: [
                          Color.fromRGBO(43, 33, 24, .72),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 58),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide.$2,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xfffff9e3),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              slide.$3,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xfffff9e3),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      const StoryCode("""IslandCarousel.uncontrolled(
  autoplay: true,
  interval: Duration(milliseconds: 3500),
  semanticLabel: '岛屿照片',
  items: [
    IslandSlide(value: 'beach', child: Image.asset('beach.jpg')),
    IslandSlide(value: 'plaza', child: Image.asset('plaza.jpg')),
  ],
)"""),
      const StoryApi(
        rows: [
          ('items *', '稳定标识与不透明内容；固定浅底提供可读默认样式', 'List<IslandSlide<T>>', '—'),
          ('value / initialValue', '受控当前值 / 非受控初始值', 'T?', '首项'),
          ('onChanged', '切换请求', 'ValueChanged<T>?', '—'),
          ('autoplay', '自动播放', 'bool', 'false'),
          ('interval', '自动播放间隔，最小 1 秒', 'Duration', '3 秒'),
          ('loop', '首尾循环', 'bool', 'true'),
          ('showArrows / showDots', '显示箭头 / 圆点', 'bool', 'true'),
          ('pauseOnHover', '悬停暂停；焦点进入总是暂停', 'bool', 'true'),
          ('focusNode', '借用键盘焦点', 'FocusNode?', '—'),
          ('semanticLabel', '轮播图名称', 'String?', '轮播图'),
        ],
      ),
    ],
  );
}
