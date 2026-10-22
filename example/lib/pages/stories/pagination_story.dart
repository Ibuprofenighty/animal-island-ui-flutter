import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import 'table_data.dart';

final _people =
    [
      'Mochi|26|彩虹岛',
      'Pudding|24|彩虹岛',
      'Cream|28|好评岛',
      'Yuki|30|小岛',
      'Haru|22|摸鱼岛',
      'Kaori|45|小岛',
      'Momo|38|博物馆岛',
      'Rin|35|艺术品岛',
      'Sora|29|拍照岛',
      'Hana|60|萝卜岛',
      'Hoshi|18|夜光岛',
      'Koko|33|鞋岛',
      'Ito|27|裁缝岛',
      'Ishi|41|石头岛',
      'Kari|36|猎人之岛',
      'Nae|31|园艺岛',
      'Oto|34|音乐岛',
      'Seki|37|化石岛',
      'Ken|25|旅行岛',
      'Ame|23|云朵岛',
      'Penguin|20|冰岛',
      'Boku|21|呆萌岛',
      'Shinbun|39|新闻岛',
      'Tento|26|体操岛',
      'Onsen|44|温泉岛',
      'Kenko|28|健身岛',
      'Tsubomi|27|花岛',
      'Omocha|24|玩具岛',
      'Shiori|29|书本岛',
      'Ribon|32|派对岛',
    ].indexed.map((entry) {
      final parts = entry.$2.split('|');
      return (
        id: '${entry.$1}',
        name: parts[0],
        age: int.parse(parts[1]),
        island: parts[2],
        fruit: '',
        hobby: '',
      );
    }).toList();

class PaginationStory extends StatefulWidget {
  const PaginationStory({super.key});
  @override
  State<PaginationStory> createState() => _PaginationStoryState();
}

class _PaginationStoryState extends State<PaginationStory> {
  IslandPaginationValue value = const IslandPaginationValue(pageSize: 5);
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Pagination',
    tags: ["分页", "受控 / 非受控"],
    children: [
      const StoryLabel('基础用法', strutStyle: storyCaptionStrut),
      for (final variant in IslandPaginationVariant.values) ...[
        if (variant == IslandPaginationVariant.teal) const SizedBox(height: 12),
        storyRow(
          [
            IslandTag(
              variant: IslandTagVariant.soft,
              size: IslandSize.small,
              child: Text(
                variant == IslandPaginationVariant.orange
                    ? 'orange（默认）'
                    : 'teal',
              ),
            ),
            IslandPagination.uncontrolled(
              total: 85,
              initialValue: const IslandPaginationValue(page: 4),
              variant: variant,
            ),
          ],
          spacing: 8,
          runSpacing: 8,
          align: WrapCrossAlignment.center,
        ),
      ],
      const StoryLabel('总条数 + 每页条数切换', strutStyle: storyCaptionStrut),
      const IslandPagination.uncontrolled(
        total: 85,
        initialValue: IslandPaginationValue(page: 3),
        showTotal: true,
        showSizeChanger: true,
        pageSizeOptions: [10, 20, 50],
      ),
      const StoryLabel('快速跳转（受控）', strutStyle: storyCaptionStrut),
      IslandPagination(
        total: 500,
        value: value,
        showTotal: true,
        showQuickJumper: true,
        onChanged: (v) => setState(() => value = v),
      ),
      const StoryLabel('禁用', strutStyle: storyCaptionStrut),
      const IslandPagination.uncontrolled(
        total: 85,
        initialValue: IslandPaginationValue(page: 4),
        disabled: true,
      ),
      const StoryLabel('配合 Table（pagination 属性）'),
      IslandTable<Islander>(
        columns: islanderColumns(full: false),
        rows: _people,
        rowKey: (r) => r.id,
        pagination: const IslandTablePagination(
          initialValue: IslandPaginationValue(pageSize: 5),
          showTotal: true,
          showSizeChanger: true,
          pageSizeOptions: [5, 10, 20],
        ),
      ),
      const StoryCode("""IslandPagination(
  total: 500,
  value: page,
  showTotal: true,
  showQuickJumper: true,
  onChanged: (next) => setState(() => page = next),
)
IslandTable<Person>(
  columns: columns, rows: people, rowKey: (person) => person.id,
  pagination: IslandTablePagination(
    initialValue: IslandPaginationValue(pageSize: 5),
    showTotal: true, showSizeChanger: true,
  ),
)"""),
      const StoryApi(
        rows: [
          ('total *', '数据总数', 'int', '—'),
          ('value', '受控页码和每页条数', 'IslandPaginationValue', '—'),
          (
            'initialValue',
            '非受控初始值',
            'IslandPaginationValue',
            'page: 1, pageSize: 10',
          ),
          (
            'onChanged',
            '请求变更完整分页值',
            'ValueChanged<IslandPaginationValue>?',
            '—',
          ),
          (
            'onPageSizeChanged',
            '每页条数变更通知',
            'ValueChanged<IslandPaginationValue>?',
            '—',
          ),
          ('showSizeChanger', '显示每页条数菜单', 'bool', 'false'),
          ('pageSizeOptions', '可选的每页条数', 'List<int>', '[10,20,50,100]'),
          ('showQuickJumper', '显示快速跳转', 'bool', 'false'),
          ('showTotal', '显示总条数', 'bool', 'false'),
          ('disabled', '禁用交互', 'bool', 'false'),
          ('semanticLabel', '分页区域名称', 'String?', 'null'),
          ('variant', '橘色 / 青色', 'IslandPaginationVariant', 'orange'),
          (
            'alignment',
            '单行溢出时的方向性对齐',
            'AlignmentGeometry',
            'AlignmentDirectional.centerStart',
          ),
        ],
      ),
    ],
  );
}
