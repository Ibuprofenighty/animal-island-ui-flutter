import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import 'table_data.dart';

class TableStory extends StatefulWidget {
  const TableStory({super.key});
  @override
  State<TableStory> createState() => _TableStoryState();
}

class _TableStoryState extends State<TableStory> {
  bool striped = true, loading = false;
  Timer? timer;
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void simulate() {
    setState(() => loading = true);
    timer?.cancel();
    timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Table',
    tags: ["表格"],
    children: [
      const StoryLabel('数据表格组件，支持斑马纹、边框、加载状态等常用功能。', lineHeight: 1.5),
      storyRow([
        IslandButton(
          variant: striped
              ? IslandButtonVariant.primary
              : IslandButtonVariant.normal,
          onPressed: () => setState(() => striped = !striped),
          child: Text('斑马纹 ${striped ? '✓' : '✗'}'),
        ),
        IslandButton(
          variant: IslandButtonVariant.primary,
          onPressed: loading ? null : simulate,
          child: Text(loading ? '加载中...' : '模拟加载'),
        ),
      ]),
      const SizedBox(height: 16),
      IslandTable<Islander>(
        columns: islanderColumns(),
        rows: tablePeople,
        rowKey: (r) => r.id,
        striped: striped,
        loading: loading,
      ),
      const StoryLabel('内置分页（pagination 属性，客户端分页）', lineHeight: 1.5),
      IslandTable<Islander>(
        columns: islanderColumns(),
        rows: generatedPeople,
        rowKey: (r) => r.id,
        pagination: const IslandTablePagination(
          initialValue: IslandPaginationValue(pageSize: 3),
          showTotal: true,
          showSizeChanger: true,
          pageSizeOptions: [3, 5, 8],
        ),
      ),
      const StoryCode("""IslandTable<Person>(
  columns: columns,
  rows: people,
  rowKey: (person) => person.id,
  striped: striped,
  pagination: IslandTablePagination(
    initialValue: IslandPaginationValue(pageSize: 3),
    showTotal: true,
    showSizeChanger: true,
  ),
)"""),
      const StoryApi(
        rows: [
          ('columns *', '类型化表头与不透明单元格', 'List<IslandTableColumn<T>>', '—'),
          (
            'column.width / preferredWidth',
            '固定宽度 / 可收缩期望宽度；互斥',
            'double?',
            '—',
          ),
          ('rows *', '完整客户端数据', 'List<T>', '—'),
          ('rowKey *', '稳定且唯一的行标识', 'Object Function(T)', '—'),
          ('semanticLabel', '表格语义名称', 'String?', 'null'),
          ('striped', '显示斑马纹', 'bool', 'true'),
          ('showHeader', '显示表头', 'bool', 'true'),
          ('loading', '阻止交互并显示加载层', 'bool', 'false'),
          ('empty', '空数据内容', 'Widget?', '暂无数据'),
          ('pagination', '开启客户端分页；支持受控值', 'IslandTablePagination?', '—'),
          ('onRowPressed', '行操作；子控件保持独立', 'ValueChanged<T>?', '—'),
          ('minWidth / maxHeight', '滚动区域约束', 'double / double?', '0 / —'),
        ],
      ),
    ],
  );
}
