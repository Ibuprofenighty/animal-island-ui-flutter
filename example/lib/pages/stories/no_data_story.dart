import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

const _islands = ['薄荷岛', '蜜桃岛', '珊瑚岛'];

/// Reference `NoDataDemo`: native-icon preview, defaults, search recovery,
/// table creation action, sizes and custom content, then the API table.
class NoDataStory extends StatefulWidget {
  const NoDataStory({super.key});
  @override
  State<NoDataStory> createState() => _NoDataStoryState();
}

class _NoDataStoryState extends State<NoDataStory> {
  final search = TextEditingController(text: '星星');
  bool created = false;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Widget section(String title, List<Widget> children) => StoryPanel(
    title: title,
    children: [const SizedBox(height: 20), ...children],
  );

  @override
  Widget build(BuildContext context) {
    final query = search.text;
    final islands = _islands.where((name) => name.contains(query)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section('naive-icons 原生图标空态', const [
          _AutoFitGrid(
            minColumnWidth: 260,
            gap: 24,
            children: [
              IslandNoData(
                bordered: true,
                title: StoryText('这里还是空白的一页'),
                description: StoryText('记录下一件小事，让海岛的故事慢慢展开。'),
              ),
              IslandNoData(
                variant: IslandNoDataVariant.search,
                bordered: true,
                title: StoryText('暂时没有找到'),
                description: StoryText('换个关键词试试，也许会有新的发现。'),
              ),
            ],
          ),
        ]),
        section('基础空态', const [
          IslandNoData(description: StoryText('这里还没有记录，新的故事可以从现在开始。')),
          StoryCode(
            "const IslandNoData(\n  description: Text('这里还没有记录，新的故事可以从现在开始。'),\n)",
          ),
        ]),
        section('搜索无结果与恢复', [
          IslandTextField(
            label: '搜索岛屿',
            showLabel: false,
            hint: '搜索岛屿名称',
            controller: search,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            // Reference status line and list inherit the page's 16px.
            child: Text(
              islands.isNotEmpty
                  ? '找到 ${islands.length} 个岛屿'
                  : '没有找到“$query”相关的岛屿',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (islands.isNotEmpty)
            Semantics(
              label: '岛屿搜索结果',
              container: true,
              child: Padding(
                // Browser `<ul>`: 1em block margins, 40px inline start.
                padding: const EdgeInsetsDirectional.fromSTEB(40, 16, 0, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final name in islands)
                      Text('•  $name', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            IslandNoData(
              variant: IslandNoDataVariant.search,
              title: StoryText('没有找到“$query”'),
              description: const StoryText('试试其他名称，或清除条件查看全部岛屿。'),
              actions: [
                IslandButton(
                  onPressed: () => setState(search.clear),
                  child: const Text('清除搜索'),
                ),
              ],
            ),
          const StoryCode(
            "IslandNoData(\n  variant: IslandNoDataVariant.search,\n  description: const Text('试试其他名称，或清除条件查看全部岛屿。'),\n  actions: [\n    IslandButton(onPressed: clearSearch, child: const Text('清除搜索')),\n  ],\n)",
          ),
        ]),
        section('表格内的简洁空态', [
          IslandTable<String>(
            columns: [
              IslandTableColumn<String>(
                id: 'name',
                title: const Text('岛屿手账'),
                cellBuilder: (_, record, _) => Text(record),
              ),
            ],
            rows: created ? const ['第一篇海岛手账'] : const [],
            rowKey: (record) => record,
            empty: IslandNoData(
              variant: IslandNoDataVariant.simple,
              size: IslandSize.small,
              showIcon: false,
              description: const StoryText('写下今天的第一件小事。'),
              actions: [
                IslandButton(
                  size: IslandSize.small,
                  onPressed: () => setState(() => created = true),
                  child: const Text('新建手账'),
                ),
              ],
            ),
          ),
          if (created)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: IslandButton(
                  size: IslandSize.small,
                  onPressed: () => setState(() => created = false),
                  child: const Text('重新体验空态'),
                ),
              ),
            ),
          const StoryCode(
            "IslandTable<Note>(\n  columns: columns,\n  rows: const [],\n  rowKey: (note) => note.id,\n  empty: IslandNoData(\n    variant: IslandNoDataVariant.simple,\n    size: IslandSize.small,\n    showIcon: false,\n    description: const Text('写下今天的第一件小事。'),\n    actions: [\n      IslandButton(\n        size: IslandSize.small,\n        onPressed: createNote,\n        child: const Text('新建手账'),\n      ),\n    ],\n  ),\n)",
          ),
        ]),
        section('尺寸与自定义内容', const [
          _AutoFitGrid(
            minColumnWidth: 200,
            gap: 20,
            children: [
              IslandNoData(
                size: IslandSize.small,
                bordered: true,
                title: StoryText('小尺寸'),
                description: StoryText('适合列表与卡片内部'),
              ),
              IslandNoData(
                bordered: true,
                title: StoryText('标准尺寸'),
                description: StoryText('适合常规内容区'),
              ),
              IslandNoData(
                size: IslandSize.large,
                bordered: true,
                title: StoryText('大尺寸'),
                description: StoryText('适合整页空态'),
              ),
            ],
          ),
          SizedBox(height: 24),
          IslandNoData(
            icon: IslandIcon(IslandGlyph.folder),
            title: StoryText('收藏夹还是空的'),
            description: StoryText('遇到喜欢的内容时，记得收藏到这里。'),
          ),
          SizedBox(height: 24),
          IslandNoData(
            showIcon: false,
            title: StoryText('仅文字提示'),
            description: StoryText('图标、标题、说明和操作区都可以单独配置。'),
          ),
          StoryCode(
            "const IslandNoData(\n  size: IslandSize.large,\n  bordered: true,\n  icon: IslandIcon(IslandGlyph.folder),\n  title: Text('收藏夹还是空的'),\n  description: Text('遇到喜欢的内容时，记得收藏到这里。'),\n)\nconst IslandNoData(showIcon: false, title: Text('仅文字提示'))",
          ),
        ]),
        const StoryApi(
          rows: [
            ('variant', '默认 / 搜索无结果 / 简洁', 'IslandNoDataVariant', 'normal'),
            ('size', '尺寸', 'IslandSize', 'middle'),
            ('title', '标题', 'Widget?', '暂无数据 / 没有找到相关结果'),
            ('showTitle', '是否显示标题', 'bool', 'true'),
            ('description', '补充说明', 'Widget?', 'null'),
            ('icon', '自定义装饰图标', 'Widget?', 'noData / search 图标'),
            ('showIcon', '是否显示图标', 'bool', 'true'),
            ('actions', '操作区，推荐复用 IslandButton', 'List<Widget>', '[]'),
            ('bordered', '奶油背景与沙色虚线边框', 'bool', 'false'),
          ],
        ),
      ],
    );
  }
}

/// Reference CSS grid `repeat(auto-fit, minmax(min(100%, min), 1fr))`:
/// as many equal columns as fit, empty tracks collapsed, rows stretched to
/// their tallest item.
class _AutoFitGrid extends StatelessWidget {
  const _AutoFitGrid({
    required this.minColumnWidth,
    required this.gap,
    required this.children,
  });
  final double minColumnWidth, gap;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final fit = ((width + gap) / (minColumnWidth + gap)).floor();
      final columns = math.max(1, math.min(fit, children.length));
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += columns) {
        if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: [
                for (var j = i; j < i + columns; j++)
                  Expanded(
                    child: j < children.length
                        ? children[j]
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      );
    },
  );
}
