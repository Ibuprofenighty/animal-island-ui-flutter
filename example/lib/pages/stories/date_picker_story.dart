import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class DatePickerStory extends StatefulWidget {
  const DatePickerStory({super.key});
  @override
  State<DatePickerStory> createState() => _DatePickerStoryState();
}

class _DatePickerStoryState extends State<DatePickerStory> {
  DateTime? value = DateTime(2026, 8, 10);
  DateTimeRange? range = DateTimeRange(
    start: DateTime(2026, 8, 10),
    end: DateTime(2026, 8, 20),
  );
  String date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  bool weekend(DateTime d) => d.weekday == 6 || d.weekday == 7;
  Widget box(Widget child) => StoryInset(child: child);
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'DatePicker',
    tags: ["基础用法"],
    children: [
      const StoryLabel('受控模式', strutStyle: storyCaptionStrut),
      selection('当前选中: ', value == null ? '未选择' : date(value!)),
      box(
        IslandDatePicker(
          value: value,
          onChanged: (next) => setState(() => value = next),
        ),
      ),
      const StoryLabel('非受控默认值 + 自定义格式', strutStyle: storyCaptionStrut),
      box(
        IslandDatePicker.uncontrolled(
          initialValue: DateTime(2026, 8, 10),
          format: 'YYYY年MM月DD日',
        ),
      ),
      const StoryLabel('允许清空 + 禁用日期（周末）', strutStyle: storyCaptionStrut),
      box(
        IslandDatePicker.uncontrolled(
          initialValue: DateTime(2026, 8, 1),
          allowClear: true,
          disabledDate: weekend,
        ),
      ),
      const StoryLabel('三种尺寸', strutStyle: storyCaptionStrut),
      storyRow([
        for (final size in IslandSize.values)
          IslandDatePicker.uncontrolled(
            initialValue: DateTime(2026, 8, 10),
            size: size,
          ),
      ]),
      const StoryLabel('校验状态', strutStyle: storyCaptionStrut),
      storyRow([
        for (final status in [
          IslandFieldStatus.error,
          IslandFieldStatus.warning,
        ])
          IslandDatePicker.uncontrolled(
            initialValue: DateTime(2026, 8, 10),
            status: status,
          ),
      ]),
      const StoryLabel('禁用状态', strutStyle: storyCaptionStrut),
      box(
        IslandDatePicker.uncontrolled(
          initialValue: DateTime(2026, 8, 10),
          disabled: true,
        ),
      ),
      const StoryLabel('隐藏「今天」快捷按钮'),
      box(const IslandDatePicker.uncontrolled(showToday: false)),
      const StoryLabel('月份选择模式', strutStyle: storyCaptionStrut),
      box(
        IslandDatePicker.uncontrolled(
          initialValue: DateTime(2026, 8),
          mode: IslandDatePickerMode.month,
        ),
      ),
      const StoryLabel('范围选择（开始日期 ~ 结束日期）'),
      selection(
        '当前范围: ',
        range == null ? '未选择' : '${date(range!.start)} ~ ${date(range!.end)}',
      ),
      box(
        SizedBox(
          width: 300,
          child: IslandDatePicker.range(
            value: range,
            onChanged: (next) => setState(() => range = next),
          ),
        ),
      ),
      const StoryLabel('范围 + 清空 + 禁用周末', strutStyle: storyCaptionStrut),
      box(
        SizedBox(
          width: 300,
          child: IslandDatePicker.rangeUncontrolled(
            initialValue: DateTimeRange(
              start: DateTime(2026, 8, 1),
              end: DateTime(2026, 8, 15),
            ),
            allowClear: true,
            disabledDate: weekend,
          ),
        ),
      ),
      const StoryCode(
        "IslandDatePicker(\n  value: date,\n  onChanged: (next) => setState(() => date = next),\n)\nIslandDatePicker.uncontrolled(\n  initialValue: DateTime(2026, 8, 10),\n  format: 'YYYY年MM月DD日',\n  allowClear: true,\n)\nIslandDatePicker.range(\n  value: range,\n  onChanged: (next) => setState(() => range = next),\n)",
      ),
      const StoryApi(
        rows: [
          (
            'range / rangeUncontrolled',
            '范围构造器，使用类型安全的起止日期',
            'DateTimeRange?',
            'null',
          ),
          ('mode', '日期或月份选择粒度', 'IslandDatePickerMode', 'date'),
          ('value', '受控日期；null 为空值', 'DateTime?', 'required'),
          ('initialValue', 'uncontrolled 构造器的初始日期', 'DateTime?', 'null'),
          (
            'onChanged',
            '确认或清空请求；范围构造器使用 DateTimeRange',
            'ValueChanged<DateTime?>?',
            'null',
          ),
          ('placeholder / label', '占位文本 / 辅助技术标签', 'String', '请选择日期 / 选择日期'),
          ('disabled / allowClear', '禁用 / 允许清空', 'bool', 'false'),
          (
            'size / status',
            '尺寸 / 校验状态',
            'IslandSize / IslandFieldStatus',
            'middle / normal',
          ),
          ('format', 'YYYY / MM / DD / M / D 展示模板', 'String', 'YYYY-MM-DD'),
          ('disabledDate', '不可提交的日历日期', 'bool Function(DateTime)?', 'null'),
          (
            'open / onOpenChanged',
            '独立受控展开状态及变更请求',
            'bool? / ValueChanged<bool>?',
            'null',
          ),
          ('showToday', '显示今天快捷按钮', 'bool', 'true'),
          (
            'focusNode / now',
            '借用焦点节点 / 今天的时间来源',
            'FocusNode? / DateTime Function()?',
            'null',
          ),
        ],
      ),
    ],
  );
  Widget selection(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: TextStyle(
              color: IslandTokens.light.link,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      style: TextStyle(fontSize: 13, color: IslandTokens.light.muted),
    ),
  );
}
