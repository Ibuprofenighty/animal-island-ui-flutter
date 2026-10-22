import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class TimePickerStory extends StatefulWidget {
  const TimePickerStory({super.key});
  @override
  State<TimePickerStory> createState() => _TimePickerStoryState();
}

class _TimePickerStoryState extends State<TimePickerStory> {
  IslandTimeValue? value = const IslandTimeValue(9, 30);
  Widget box(Widget child) => StoryInset(child: child);
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'TimePicker',
    tags: ["基础用法"],
    children: [
      const StoryLabel('受控模式', strutStyle: storyCaptionStrut),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: '当前选中: '),
              TextSpan(
                text: value?.format() ?? '未选择',
                style: TextStyle(
                  color: IslandTokens.light.link,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          style: TextStyle(fontSize: 13, color: IslandTokens.light.muted),
        ),
      ),
      box(
        IslandTimePicker(
          value: value,
          onChanged: (next) => setState(() => value = next),
        ),
      ),
      const StoryLabel('非受控默认值 + 自定义格式（不含秒）', strutStyle: storyCaptionStrut),
      box(
        const IslandTimePicker.uncontrolled(
          initialValue: IslandTimeValue(14, 30),
          format: 'HH:mm',
        ),
      ),
      const StoryLabel('分钟步进（15 分钟一档）'),
      box(
        const IslandTimePicker.uncontrolled(
          initialValue: IslandTimeValue(9, 30),
          minuteStep: 15,
        ),
      ),
      const StoryLabel('允许清空', strutStyle: storyCaptionStrut),
      box(
        const IslandTimePicker.uncontrolled(
          initialValue: IslandTimeValue(9, 30),
          allowClear: true,
        ),
      ),
      const StoryLabel('三种尺寸', strutStyle: storyCaptionStrut),
      storyRow([
        for (final size in IslandSize.values)
          IslandTimePicker.uncontrolled(
            initialValue: const IslandTimeValue(9, 30),
            size: size,
          ),
      ]),
      const StoryLabel('校验状态', strutStyle: storyCaptionStrut),
      storyRow([
        for (final status in [
          IslandFieldStatus.error,
          IslandFieldStatus.warning,
        ])
          IslandTimePicker.uncontrolled(
            initialValue: const IslandTimeValue(9, 30),
            status: status,
          ),
      ]),
      const StoryLabel('禁用状态', strutStyle: storyCaptionStrut),
      box(
        const IslandTimePicker.uncontrolled(
          initialValue: IslandTimeValue(9, 30),
          disabled: true,
        ),
      ),
      const StoryCode(
        "IslandTimePicker(\n  value: value,\n  onChanged: (next) => setState(() => value = next),\n)\nconst IslandTimePicker.uncontrolled(\n  initialValue: IslandTimeValue(14, 30),\n  format: 'HH:mm',\n  minuteStep: 15,\n  allowClear: true,\n)",
      ),
      const StoryApi(
        rows: [
          ('value', '受控时间；null 表示空值', 'IslandTimeValue?', 'required'),
          ('initialValue', 'uncontrolled 构造器的初始时间', 'IslandTimeValue?', 'null'),
          (
            'onChanged',
            '确认或清空请求；受控构造器必传',
            'ValueChanged<IslandTimeValue?>?',
            'required / uncontrolled: null',
          ),
          ('placeholder / label', '占位文本 / 辅助技术标签', 'String', '请选择时间 / 选择时间'),
          ('disabled / allowClear', '禁用 / 允许清空', 'bool', 'false'),
          (
            'size / status',
            '尺寸 / 校验状态',
            'IslandSize / IslandFieldStatus',
            'middle / normal',
          ),
          ('format', 'HH / mm / ss 模板；ss 控制秒列', 'String', 'HH:mm:ss'),
          ('hourStep / minuteStep / secondStep', '各列正整数步进', 'int', '1'),
          (
            'open / onOpenChanged',
            '受控展开；短视口面板可滚动，焦点与值仍由组件拥有',
            'bool? / ValueChanged<bool>?',
            'null',
          ),
          ('focusNode', '借用的焦点节点', 'FocusNode?', 'null'),
          ('now', '此刻按钮的时间来源', 'DateTime Function()?', 'null'),
        ],
      ),
    ],
  );
}
