import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/palette.dart';
import '../../shared/story.dart';

final _islandEvents = [
  IslandCalendarEvent(
    id: 'check-in',
    title: '每日签到',
    start: DateTime(2026, 8, 10, 9, 30),
    showTime: true,
  ),
  IslandCalendarEvent(
    id: 'new-island',
    title: '开荒新岛',
    start: DateTime(2026, 8, 10, 14),
    showTime: true,
    color: IslandCalendarColor.green,
  ),
  IslandCalendarEvent(
    id: 'harvest',
    title: '海岛丰收祭',
    start: DateTime(2026, 8, 12),
    end: DateTime(2026, 8, 18),
    color: IslandCalendarColor.amber,
  ),
  IslandCalendarEvent(
    id: 'fishing',
    title: '钓鱼大赛',
    start: DateTime(2026, 8, 20),
    color: IslandCalendarColor.coral,
  ),
  IslandCalendarEvent(
    id: 'bonfire',
    title: '篝火晚会',
    start: DateTime(2026, 8, 24, 20),
    showTime: true,
    color: IslandCalendarColor.purple,
  ),
  IslandCalendarEvent(id: 'fruit', title: '摘果子', start: DateTime(2026, 8, 24)),
  IslandCalendarEvent(id: 'flowers', title: '浇花', start: DateTime(2026, 8, 24)),
];

/// Drag-created entries are named 事件一, 事件二 … in turn.
const _createdNames = ['事件一', '事件二', '事件三', '事件四', '事件五'];

class CalendarStory extends StatefulWidget {
  const CalendarStory({super.key});
  @override
  State<CalendarStory> createState() => _CalendarStoryState();
}

class _CalendarStoryState extends State<CalendarStory> {
  DateTime date = DateTime(2026, 8, 10);
  DateTime month = DateTime(2026, 8);
  final created = <IslandCalendarEvent>[];

  String format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget box(Widget child) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 780),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GalleryPalette.demoPanel,
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Calendar',
    tags: const ['基础用法'],
    children: [
      const StoryLabel('基础', strutStyle: storyCaptionStrut),
      box(
        IslandCalendar.uncontrolled(
          initialValue: DateTime(2026, 8, 10),
          events: _islandEvents,
        ),
      ),
      const StoryLabel('受控模式：点击日期选中', strutStyle: storyCaptionStrut),
      status('当前选中: ', format(date)),
      box(
        IslandCalendar(
          value: date,
          month: month,
          onChanged: (next) => setState(() => date = next),
          onMonthChanged: (next) => setState(() => month = next),
        ),
      ),
      const StoryLabel(
        '拖拽跨日期创建事项（draggableEvents）',
        strutStyle: storyCaptionStrut,
      ),
      status(
        '新建事项: ',
        created.isEmpty
            ? '在日期上按住并横向拖动'
            : created
                  .map(
                    (event) =>
                        '${event.title}（${format(event.start)} ~ ${format(event.end!)}）',
                  )
                  .join('，'),
      ),
      box(
        IslandCalendar.uncontrolled(
          initialValue: DateTime(2026, 8, 10),
          events: List.unmodifiable(created),
          onCreateEvent: (range) => setState(
            () => created.add(
              IslandCalendarEvent(
                id: created.length,
                title: _createdNames[created.length % _createdNames.length],
                start: range.start,
                end: range.end,
                color: IslandCalendarColor
                    .values[created.length % IslandCalendarColor.values.length],
              ),
            ),
          ),
        ),
      ),
      const StoryCode(
        "final events = [\n"
        "  IslandCalendarEvent(\n"
        "    id: 'check-in',\n"
        "    title: '每日签到',\n"
        "    start: DateTime(2026, 8, 10, 9, 30),\n"
        "    showTime: true,\n"
        "  ),\n"
        "  IslandCalendarEvent(\n"
        "    id: 'harvest',\n"
        "    title: '海岛丰收祭',\n"
        "    start: DateTime(2026, 8, 12),\n"
        "    end: DateTime(2026, 8, 18),\n"
        "    color: IslandCalendarColor.amber,\n"
        "  ),\n"
        "];\n"
        "\n"
        "IslandCalendar.uncontrolled(\n"
        "  initialValue: DateTime(2026, 8, 10),\n"
        "  events: events,\n"
        "  onChanged: (date) => debugPrint('\$date'),\n"
        "  onCreateEvent: (range) => debugPrint('\${range.start} \${range.end}'),\n"
        ")",
      ),
      const StoryApi(
        title: 'Calendar API',
        rows: [
          ('width', '面板宽度，默认铺满父容器（数值按 px 处理）', 'double?', 'null'),
          (
            'value / initialValue',
            '选中日期（受控 / uncontrolled 构造器的初始值）',
            'DateTime?',
            'required / 今天',
          ),
          (
            'onChanged',
            '日期选择请求（点选单元格、Enter / 空格或「今天」）',
            'ValueChanged<DateTime>?',
            'null',
          ),
          (
            'month',
            '面板月份，非 null 时受控，须配合 onMonthChanged 回写',
            'DateTime?',
            'null',
          ),
          ('initialMonth', '非受控面板的初始月份', 'DateTime?', '选中日期 / 今天'),
          (
            'onMonthChanged',
            '面板月份变化请求（上/下月、上/下年、光标跨月）',
            'ValueChanged<DateTime>?',
            'null',
          ),
          (
            'events',
            '事项列表，支持同日多条与跨日期连续条',
            'List<IslandCalendarEvent>',
            'const []',
          ),
          ('showEventTime', '是否展示事项起始时间（仅首段）', 'bool', 'true'),
          (
            'onCreateEvent',
            '非 null 时允许鼠标拖拽跨日期创建事项，松手回调起止日期',
            'ValueChanged<DateTimeRange>?',
            'null',
          ),
          ('semanticLabel', '日期网格的辅助技术标签', 'String?', 'null'),
          ('now', '今天的时间来源', 'DateTime Function()?', 'null'),
        ],
      ),
      const StoryApi(
        title: 'IslandCalendarEvent',
        rows: [
          ('id', '稳定标识，列表内唯一', 'Object', 'required'),
          ('title', '事项内容', 'String', 'required'),
          ('start', '开始时间（showTime 时展示 HH:mm）', 'DateTime', 'required'),
          ('end', '结束日期（含），省略时等同于 start；传入时渲染成跨天连续条', 'DateTime?', 'null'),
          (
            'color',
            '配色；teal 是默认暖橙，与 coral 相近，同屏时优先用 green / purple 区分',
            'IslandCalendarColor',
            'teal',
          ),
          ('showTime', '是否展示起始时间', 'bool', 'false'),
        ],
      ),
    ],
  );

  Widget status(String label, String value) => Padding(
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
