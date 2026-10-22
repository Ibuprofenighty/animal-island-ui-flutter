import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

typedef Islander = ({
  String id,
  String name,
  int age,
  String island,
  String fruit,
  String hobby,
});
const tablePeople = <Islander>[
  (id: '1', name: 'Mochi', age: 26, island: '彩虹岛', fruit: '苹果', hobby: '音乐'),
  (id: '2', name: 'Pudding', age: 24, island: '彩虹岛', fruit: '橘子', hobby: '运动'),
  (id: '3', name: 'Cream', age: 28, island: '好评岛', fruit: '樱桃', hobby: '唱歌'),
  (id: '4', name: 'Yuki', age: 30, island: '小岛', fruit: '梨', hobby: '钓鱼'),
  (id: '5', name: 'Haru', age: 22, island: '摸鱼岛', fruit: '桃子', hobby: '画画'),
];
final generatedPeople = List<Islander>.generate(
  12,
  (i) => (
    id: '$i',
    name: '岛民${i + 1}号',
    age: 20 + i,
    island: ['彩虹岛', '好评岛', '小岛', '摸鱼岛'][i % 4],
    fruit: ['苹果', '橘子', '樱桃', '梨', '桃子', '椰子'][i % 6],
    hobby: ['音乐', '运动', '唱歌', '钓鱼', '画画'][i % 5],
  ),
);
// Explicit Gallery data leaf: Chromium allows a break between CJK glyphs.
// Keep the original semantic value while supplying equivalent line opportunities.
Widget _tableText(String value) => StoryText(
  value.replaceAllMapped(
    RegExp(r'(?<=[\u3400-\u9fff])(?=[\u3400-\u9fff])'),
    (_) => '\u200b',
  ),
  semanticLabel: value,
);

List<IslandTableColumn<Islander>> islanderColumns({bool full = true}) => [
  IslandTableColumn(
    id: 'name',
    title: const Text('岛民'),
    preferredWidth: 120,
    cellBuilder: (_, r, __) => _tableText(r.name),
  ),
  IslandTableColumn(
    id: 'age',
    title: const Text('年龄'),
    preferredWidth: 80,
    alignment: Alignment.center,
    cellBuilder: (_, r, __) => _tableText('${r.age}'),
  ),
  IslandTableColumn(
    id: 'island',
    title: const Text('岛屿'),
    cellBuilder: (_, r, __) => _tableText(r.island),
  ),
  if (full)
    IslandTableColumn(
      id: 'fruit',
      title: const Text('喜欢的水果'),
      cellBuilder: (_, r, __) => _tableText(r.fruit),
    ),
  if (full)
    IslandTableColumn(
      id: 'hobby',
      title: const Text('爱好'),
      cellBuilder: (_, r, __) => HobbyPill(r.hobby),
    ),
];

class HobbyPill extends StatelessWidget {
  const HobbyPill(this.hobby, {super.key});
  final String hobby;
  @override
  Widget build(BuildContext context) {
    final (bg, ink) = switch (hobby) {
      '音乐' => (0xffece7f8, IslandColorway.purple.ink),
      '运动' => (0xfffff0dc, IslandColorway.orange.ink),
      '唱歌' => (0xffffe8e4, IslandColorway.red.ink),
      '钓鱼' => (0xffe2effd, IslandColorway.blue.ink),
      '画画' => (0xffffe8f1, IslandColorway.pink.ink),
      _ => (0xffe0f7f4, IslandColorway.teal.ink),
    };
    return CustomPaint(
      painter: _HobbyBackground(Color(bg)),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 12,
          height: 14 * 1.6 / 12,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        child: StoryText(
          hobby.replaceAllMapped(
            RegExp(r'(?<=[\u3400-\u9fff])(?=[\u3400-\u9fff])'),
            (_) => '\u200b',
          ),
          semanticLabel: hobby,
          inlinePadding: 12,
        ),
      ),
    );
  }
}

class _HobbyBackground extends CustomPainter {
  const _HobbyBackground(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0, -4, size.width, size.height + 4),
        const Radius.circular(20),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_HobbyBackground oldDelegate) =>
      oldDelegate.color != color;
}
