import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

const _palettes = <(IslandPalette, String, String, IslandColorway)>[
  (IslandPalette.green, '默认绿', 'default', IslandColorway.green),
  (IslandPalette.pink, '粉色', 'app-pink', IslandColorway.pink),
  (IslandPalette.purple, '紫色', 'purple', IslandColorway.purple),
  (IslandPalette.blue, '蓝色', 'app-blue', IslandColorway.blue),
  (IslandPalette.yellow, '黄色', 'app-yellow', IslandColorway.yellow),
  (IslandPalette.orange, '橙色', 'app-orange', IslandColorway.orange),
  (IslandPalette.teal, '青色', 'app-teal', IslandColorway.teal),
  (IslandPalette.softGreen, '绿色', 'app-green', IslandColorway.green),
  (IslandPalette.red, '红色', 'app-red', IslandColorway.red),
  (IslandPalette.lime, '青柠', 'lime-green', IslandColorway.lime),
  (IslandPalette.yellowGreen, '黄绿', 'yellow-green', IslandColorway.yellowGreen),
  (IslandPalette.brown, '棕色', 'brown', IslandColorway.brown),
  (IslandPalette.peach, '暖桃粉', 'warm-peach-pink', IslandColorway.peach),
];

class TitleStory extends StatefulWidget {
  const TitleStory({super.key});
  @override
  State<TitleStory> createState() => _TitleStoryState();
}

class _TitleStoryState extends State<TitleStory> {
  // Reference randomizes only the first variant examples. Keep a mounted
  // story's choices stable during unrelated Flutter ancestor rebuilds.
  late final colors = List.generate(
    3,
    (_) => _palettes[math.Random().nextInt(_palettes.length)].$1,
  );
  Widget label(String text) => StoryLabel(
    text,
    lineHeight: 1.5,
    strutStyle: const StrutStyle(
      fontSize: 14,
      height: 1.5,
      forceStrutHeight: true,
    ),
  );
  Widget caption(Widget title, String text, {Color? color}) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      title,
      const SizedBox(height: 16),
      Text(
        text,
        strutStyle: const StrutStyle(
          fontSize: 12,
          height: 4 / 3,
          forceStrutHeight: true,
        ),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 4 / 3,
          color: color ?? IslandTokens.light.ink,
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Title',
    tags: ["标题"],
    children: [
      label('全部类型（随机取色）'),
      _TitleDemoBox(
        tone: 0,
        child: Wrap(
          spacing: 50,
          runSpacing: 32,
          children: [
            for (final item in [
              (IslandTitleVariant.layer, '双层纸'),
              (IslandTitleVariant.ribbon, '飘带类型'),
              (IslandTitleVariant.tab, '折角便签'),
            ].indexed)
              caption(
                IslandTitle(
                  variant: item.$2.$1,
                  palette: colors[item.$1],
                  child: Text(item.$2.$2),
                ),
                'variant="${item.$2.$1.name}"',
              ),
          ],
        ),
      ),
      label('配色变体（默认双层纸 Layer）'),
      _TitleDemoBox(
        tone: 1,
        child: Wrap(
          spacing: 50,
          runSpacing: 32,
          children: [
            for (final item in _palettes)
              caption(
                IslandTitle(palette: item.$1, child: Text(item.$2)),
                item.$3,
                color: item.$4.onAccent,
              ),
          ],
        ),
      ),
      label('尺寸'),
      LayoutBuilder(
        builder: (context, constraints) {
          final count = ((constraints.maxWidth + 24) / 224).floor().clamp(1, 3);
          const sizes = [
            (IslandSize.small, '小尺寸', '小标题', 3),
            (IslandSize.middle, '中尺寸（默认）', '中等标题', 4),
            (IslandSize.large, '大尺寸', '大号标题', 2),
          ];
          return Column(
            children: [
              for (var start = 0; start < 3; start += count)
                Padding(
                  padding: EdgeInsets.only(top: start == 0 ? 0 : 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (
                        var i = start;
                        i < math.min(start + count, 3);
                        i++
                      ) ...[
                        if (i > start) const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label(sizes[i].$2),
                              _TitleDemoBox(
                                tone: sizes[i].$4,
                                child: IslandTitle(
                                  size: sizes[i].$1,
                                  child: Text(sizes[i].$3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      label('支持英文文案'),
      const _TitleDemoBox(
        tone: 0,
        child: IslandTitle(child: Text("LET'S PLAY!")),
      ),
      label('飘带标题 Ribbon'),
      const _TitleDemoBox(tone: 5, child: IslandTitle(child: Text('飘带类型'))),
      label('双层纸 Layer'),
      const _TitleDemoBox(
        tone: 5,
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            IslandTitle(
              variant: IslandTitleVariant.layer,
              palette: IslandPalette.yellow,
              child: Text('蜂蜜阳光'),
            ),
            IslandTitle(
              variant: IslandTitleVariant.layer,
              palette: IslandPalette.blue,
              child: Text('海风信箱'),
            ),
          ],
        ),
      ),
      label('折角便签 Tab'),
      const _TitleDemoBox(
        tone: 2,
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            IslandTitle(
              variant: IslandTitleVariant.tab,
              palette: IslandPalette.lime,
              child: Text('青柠苏打'),
            ),
            IslandTitle(
              variant: IslandTitleVariant.tab,
              palette: IslandPalette.brown,
              child: Text('热可可'),
            ),
          ],
        ),
      ),
      const StoryCode(
        "IslandTitle(\n  variant: IslandTitleVariant.layer,\n  palette: IslandPalette.yellow,\n  child: const Text('蜂蜜阳光'),\n)",
      ),
      const StoryApi(
        rows: [
          ("variant", "缎带、叠层、标签", "IslandTitleVariant", "ribbon"),
          ("child", "标题内容", "Widget", "required"),
          ("palette", "参考色板及嵌套控件的配对前景", "IslandPalette", "green"),
          ("size", "标题尺寸", "IslandSize", "middle"),
        ],
      ),
    ],
  );
}

// These are Gallery demo backgrounds, not alternate Title implementations.
const _tones = <(Color, Color, Color, Color)>[
  (Color(0xffddf0fa), Color(0x2650aae6), Color(0x1a8cd2fa), Color(0xff90cce8)),
  (Color(0xfffdf3d8), Color(0x26dcb450), Color(0x1ff0d278), Color(0xffe8d090)),
  (Color(0xffede8f8), Color(0x26a078e6), Color(0x1fc8a0fa), Color(0xffc0a8e8)),
  (Color(0xfffce8e0), Color(0x26f0785a), Color(0x1fffaa8c), Color(0xffe8b0a0)),
  (Color(0xffd8f5f0), Color(0x2e3cbeaa), Color(0x1f78e6d2), Color(0xff88d8c8)),
  (Color(0xffe8f5d8), Color(0x2e78c850), Color(0x1fb4e678), Color(0xffb8d890)),
];

class _TitleDemoBox extends StatelessWidget {
  const _TitleDemoBox({required this.tone, required this.child});
  final int tone;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final colors = _tones[tone];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.$4,
          width: IslandTheme.borderWidth(context, 1.5),
        ),
      ),
      child: CustomPaint(
        painter: _TitleDots(colors.$2, colors.$3),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ),
    );
  }
}

class _TitleDots extends CustomPainter {
  const _TitleDots(this.large, this.small);
  final Color large, small;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
    );
    for (final layer in [(14.0, 1.0, small), (28.0, 1.5, large)]) {
      for (double x = 14; x < size.width; x += layer.$1) {
        for (double y = 14; y < size.height; y += layer.$1) {
          canvas.drawCircle(Offset(x, y), layer.$2, Paint()..color = layer.$3);
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TitleDots old) =>
      old.large != large || old.small != small;
}
