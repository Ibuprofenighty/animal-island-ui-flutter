import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class CountdownStory extends StatefulWidget {
  const CountdownStory({super.key});
  @override
  State<CountdownStory> createState() => _CountdownStoryState();
}

class _CountdownStoryState extends State<CountdownStory> {
  DateTime deadline = DateTime.now().add(const Duration(seconds: 90061));
  DateTime shortDeadline = DateTime.now().add(const Duration(seconds: 5));
  bool finished = false;
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Countdown',
    tags: ["倒计时", "实时更新"],
    children: [
      const StoryLabel('活动倒计时', strutStyle: storyCaptionStrut),
      IslandCountdown(
        value: deadline,
        format: 'DD 天 HH:mm:ss',
        prefix: const Text('烟火大会开始还有'),
        variant: IslandCountdownVariant.island,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: IslandButton(
          child: const Text('重新计时'),
          size: IslandSize.small,
          onPressed: () => setState(
            () => deadline = DateTime.now().add(const Duration(seconds: 90061)),
          ),
        ),
      ),
      const StoryLabel('default 风格'),
      IslandCountdown(
        value: deadline,
        format: 'DD 天 HH:mm:ss',
        prefix: const Text('活动结束还有'),
      ),
      const StoryLabel('无边框 / 带边框', strutStyle: storyCaptionStrut),
      storyRow([
        for (final variant in IslandCountdownVariant.values)
          for (final bordered in [false, true])
            IslandCountdown(
              value: deadline,
              variant: variant,
              bordered: bordered,
            ),
      ]),
      const StoryLabel('onFinish 回调'),
      IslandCountdown(
        value: shortDeadline,
        prefix: Text(finished ? '已结束' : '商店关门还有'),
        onFinish: () => setState(() => finished = true),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: IslandButton(
          child: const Text('再来 10 秒'),
          size: IslandSize.small,
          onPressed: () => setState(() {
            finished = false;
            shortDeadline = DateTime.now().add(const Duration(seconds: 10));
          }),
        ),
      ),
      const StoryLabel('尺寸', strutStyle: storyCaptionStrut),
      storyRow([
        for (final size in IslandSize.values)
          IslandCountdown(value: deadline, size: size),
      ]),
      const StoryCode(
        "IslandCountdown(\n  value: DateTime.now().add(const Duration(days: 1)),\n  format: 'DD 天 HH:mm:ss',\n  prefix: const Text('活动结束还有'),\n  variant: IslandCountdownVariant.island,\n  onFinish: handleFinish,\n)",
      ),
      const StoryApi(
        rows: [
          ('value', '结束时间', 'DateTime', 'required'),
          ('format', 'DD / HH / mm / ss 格式模板', 'String', 'HH:mm:ss'),
          ('prefix', '倒计时前的说明内容', 'Widget?', 'null'),
          ('size', '尺寸', 'IslandSize', 'middle'),
          ('variant', '显示风格', 'IslandCountdownVariant', 'normal'),
          ('bordered', '数字块是否带边框', 'bool', 'false'),
          ('onChange', '剩余时间变化回调', 'ValueChanged<Duration>?', 'null'),
          ('onFinish', '归零回调', 'VoidCallback?', 'null'),
          ('now', '可替换的时间来源', 'DateTime Function()?', 'null'),
        ],
      ),
    ],
  );
}
