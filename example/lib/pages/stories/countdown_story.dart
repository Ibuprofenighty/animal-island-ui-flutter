import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/palette.dart';
import '../../shared/story.dart';

class CountdownStory extends StatefulWidget {
  const CountdownStory({super.key});
  @override
  State<CountdownStory> createState() => _CountdownStoryState();
}

class _CountdownStoryState extends State<CountdownStory> {
  DateTime deadline = DateTime.now().add(const Duration(seconds: 90061));
  DateTime shortDeadline = DateTime.now().add(const Duration(seconds: 5));
  DateTime reminderDeadline = DateTime.now().add(const Duration(seconds: 15));
  bool finished = false;
  final notifications = IslandNotificationsController();

  @override
  void dispose() {
    notifications.dispose();
    super.dispose();
  }

  /// Reference demo `textStyle`: 13px at the page's weight 400; its
  /// `#8a7b66` takes the muted role, as the other demo text.
  Widget demoText(String text, {double top = 0, double bottom = 0}) => Padding(
    padding: EdgeInsets.only(top: top, bottom: bottom),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: kTextHeightNone,
        color: IslandTokens.light.muted,
      ),
    ),
  );

  Widget captioned(Widget countdown, String caption) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [countdown, demoText(caption, top: 6)],
  );

  /// Reference `CountdownReminderDemo`: one `<section aria-label>` with each
  /// countdown named by its own label.
  Widget reminderDemo() => Semantics(
    container: true,
    explicitChildNodes: true,
    label: '倒计时颜色提醒演示',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StoryLabel('颜色提醒'),
        demoText('剩余 60 秒转橙、10 秒转红；最后 5 秒数字轻抖。', bottom: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final seconds in const [60, 10, 5])
              IslandButton(
                size: IslandSize.small,
                onPressed: () => setState(
                  () => reminderDeadline = DateTime.now().add(
                    Duration(seconds: seconds),
                  ),
                ),
                child: Text('重置为 $seconds 秒'),
              ),
            IslandButton(
              size: IslandSize.small,
              onPressed: () =>
                  setState(() => reminderDeadline = DateTime.now()),
              child: const Text('归零'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 40,
          runSpacing: 40,
          children: [
            captioned(
              IslandCountdown(
                value: reminderDeadline,
                format: 'mm:ss',
                reminders: IslandCountdownReminder.defaults,
                bordered: true,
                semanticLabel: '默认提醒倒计时',
              ),
              '默认提醒：60 秒橙 / 10 秒红',
            ),
            captioned(
              IslandCountdown(
                value: reminderDeadline,
                format: 'mm:ss',
                semanticLabel: '无提醒倒计时',
              ),
              '关闭提醒：保留原配色',
            ),
            captioned(
              IslandCountdown(
                value: reminderDeadline,
                format: 'mm:ss',
                variant: IslandCountdownVariant.island,
                reminders: const [
                  IslandCountdownReminder(
                    threshold: Duration(seconds: 5),
                    color: GalleryPalette.countdownReminderBerry,
                  ),
                  IslandCountdownReminder(
                    threshold: Duration(seconds: 20),
                    color: GalleryPalette.countdownReminderBrown,
                  ),
                ],
                bordered: true,
                semanticLabel: '自定义提醒倒计时',
              ),
              '自定义提醒：20 秒暖棕 / 5 秒莓红',
            ),
            captioned(
              IslandCountdown(
                value: reminderDeadline,
                format: 'mm:ss',
                variant: IslandCountdownVariant.island,
                reminders: IslandCountdownReminder.defaults,
                shake: const IslandCountdownShake(),
                bordered: true,
                semanticLabel: '抖动提醒倒计时',
              ),
              '抖动提醒：最后 5 秒轻抖',
            ),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) =>
      IslandNotifications(controller: notifications, child: story());

  Widget story() => StoryPanel(
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
      storyRow(align: WrapCrossAlignment.center, [
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
        onFinish: () {
          setState(() => finished = true);
          notifications.show(
            const IslandNotification(
              message: Text('倒计时结束，商店已关门'),
              type: IslandNotificationType.success,
            ),
          );
        },
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
      reminderDemo(),
      const StoryLabel('尺寸', strutStyle: storyCaptionStrut),
      storyRow(align: WrapCrossAlignment.center, spacing: 14, runSpacing: 14, [
        for (final size in IslandSize.values)
          IslandCountdown(value: deadline, size: size),
      ]),
      const StoryCode(
        "IslandCountdown(\n  value: DateTime.now().add(const Duration(days: 1)),\n  format: 'DD 天 HH:mm:ss',\n  prefix: const Text('活动结束还有'),\n  variant: IslandCountdownVariant.island,\n  onFinish: handleFinish,\n)\n\n// 颜色提醒：默认 60 秒橙 / 10 秒红，列表可替换全部规则\nIslandCountdown(value: deadline, reminders: IslandCountdownReminder.defaults)\n\n// 最后 5 秒抖动，可与颜色提醒叠加\nIslandCountdown(\n  value: deadline,\n  reminders: IslandCountdownReminder.defaults,\n  shake: const IslandCountdownShake(),\n)",
      ),
      const StoryApi(
        rows: [
          ('value', '结束时间', 'DateTime', 'required'),
          ('format', 'DD / HH / mm / ss 格式模板', 'String', 'HH:mm:ss'),
          ('prefix', '倒计时前的说明内容', 'Widget?', 'null'),
          ('size', '尺寸', 'IslandSize', 'middle'),
          ('variant', '显示风格', 'IslandCountdownVariant', 'normal'),
          ('bordered', '数字块是否带边框', 'bool', 'false'),
          (
            'reminders',
            '颜色提醒规则；IslandCountdownReminder.defaults 为 60 秒橙色 / 10 秒红色',
            'List<IslandCountdownReminder>',
            '[]',
          ),
          (
            'shake',
            '最后几秒抖动；可自定义阈值、加强阶段、周期、幅度与缓动',
            'IslandCountdownShake?',
            'null',
          ),
          ('onChange', '剩余时间变化回调', 'ValueChanged<Duration>?', 'null'),
          ('onFinish', '归零回调', 'VoidCallback?', 'null'),
          ('now', '可替换的时间来源', 'DateTime Function()?', 'null'),
        ],
      ),
    ],
  );
}
