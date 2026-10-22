import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class TypewriterStory extends StatefulWidget {
  const TypewriterStory({super.key});
  @override
  State<TypewriterStory> createState() => _TypewriterStoryState();
}

class _TypewriterStoryState extends State<TypewriterStory> {
  int replay = 0;
  Widget box(Widget child) => StoryDemoBox(
    dashed: true,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(17),
    child: child,
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Typewriter',
    tags: ["打字机"],
    children: [
      const StoryLabel('基础用法', strutStyle: storyCaptionStrut),
      box(
        IslandTypewriter(
          '你好，欢迎来到动物岛！今天的天气真不错呢～',
          trigger: replay,
          style: const TextStyle(fontSize: 16),
          strutStyle: const StrutStyle(
            fontSize: 16,
            height: 25 / 16,
            forceStrutHeight: true,
          ),
        ),
      ),
      const StoryLabel('保留多行与富内容 (速度 40ms)'),
      box(
        IslandTypewriter.builder(
          '第一行：钓到石头了！\n第二行：竟然连这种都能钓起来...\n第三行：继续加油吧！',
          speed: const Duration(milliseconds: 40),
          trigger: replay,
          builder: (context, text) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              for (final (index, line) in text.split('\n').indexed)
                Text(
                  line,
                  style: TextStyle(
                    fontSize: 16,
                    height: kTextHeightNone,
                    color: index == 2 ? IslandColorway.orange.ink : null,
                    fontWeight: index == 2 ? FontWeight.w700 : null,
                  ),
                  strutStyle: const StrutStyle(
                    fontSize: 16,
                    height: 25 / 16,
                    forceStrutHeight: true,
                  ),
                ),
            ],
          ),
        ),
      ),
      primary('重新播放', action: () => setState(() => replay++)),
      const StoryCode(
        "IslandTypewriter.rich(\n  const TextSpan(children: [\n    TextSpan(text: '第一行\\n'),\n    TextSpan(text: '第二行', style: TextStyle(color: Colors.orange)),\n  ]),\n  trigger: replay,\n)",
      ),
      const StoryApi(
        rows: [
          ('text / span', '纯文本或显式富文本插槽', 'String / TextSpan', 'required'),
          (
            'style / strutStyle',
            '普通/富文本样式与行高度量',
            'TextStyle? / StrutStyle?',
            'null',
          ),
          (
            'builder',
            '.builder 构造器：显式字素前缀渲染',
            'Widget Function(BuildContext, String)',
            'required',
          ),
          ('speed', '每字间隔', 'Duration', '90ms'),
          ('trigger', '值变化时重新播放', 'Object?', 'null'),
          ('play', 'false 直接显示全部', 'bool', 'true'),
          ('onDone', '单次播放完成回调', 'VoidCallback?', 'null'),
        ],
      ),
    ],
  );
}
