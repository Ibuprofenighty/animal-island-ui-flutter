import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class SelectStory extends StatefulWidget {
  const SelectStory({super.key});
  @override
  State<SelectStory> createState() => _SelectStoryState();
}

class _SelectStoryState extends State<SelectStory> {
  final values = <String?>[
    'fish1',
    null,
    'flower2',
    null,
    null,
    'fish3',
    'flower4',
    null,
  ];
  static const fish = [
    IslandOption(value: 'fish1', label: '鲈鱼'),
    IslandOption(value: 'fish2', label: '鲷鱼'),
    IslandOption(value: 'fish3', label: '草鱼'),
    IslandOption(value: 'fish4', label: '龙睛鱼'),
    IslandOption(value: 'fish5', label: '神仙鱼'),
  ];
  static const flowers = [
    IslandOption(value: 'flower1', label: '樱花'),
    IslandOption(value: 'flower2', label: '玫瑰'),
    IslandOption(value: 'flower3', label: '向日葵'),
    IslandOption(value: 'flower4', label: '薰衣草'),
    IslandOption(value: 'flower5', label: '郁金香'),
  ];
  static const fruits = [
    IslandOption(value: 'fruit1', label: '草莓'),
    IslandOption(value: 'fruit2', label: '蓝莓'),
    IslandOption(value: 'fruit3', label: '桃子'),
    IslandOption(value: 'fruit4', label: '樱桃'),
    IslandOption(value: 'fruit5', label: '猕猴桃'),
  ];
  Widget field(
    int index,
    List<IslandOption<String>> options, {
    String placeholder = '请选择',
    bool disabled = false,
    bool clear = false,
    bool search = false,
    String clearLabel = '清除',
  }) => IslandSelect<String>(
    label: placeholder,
    options: options,
    value: values[index],
    onChanged: (v) => setState(() => values[index] = v),
    placeholder: placeholder,
    disabled: disabled,
    allowClear: clear,
    showSearch: search,
    clearLabel: clearLabel,
  );
  Widget box(
    Widget child, {
    bool decorated = false,
    bool trailingSpace = true,
  }) => Padding(
    padding: EdgeInsets.only(bottom: trailingSpace ? 20 : 0),
    child: decorated
        ? StoryDemoBox(
            dashed: true,
            padding: const EdgeInsets.all(17),
            child: child,
          )
        : StoryInset(child: child),
  );
  Widget label(String text, {bool first = false}) => StoryLabel(
    text,
    spaceBefore: first ? 20 : 0,
    strutStyle: const StrutStyle(
      fontSize: 14,
      height: 1.5,
      forceStrutHeight: true,
    ),
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Select',
    tags: ["基础用法"],
    children: [
      label('默认状态', first: true),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text.rich(
          TextSpan(
            text: '当前选中: ',
            children: [
              TextSpan(
                text:
                    fish
                        .where((o) => o.value == values[0])
                        .firstOrNull
                        ?.label ??
                    '',
                style: TextStyle(
                  color: IslandTokens.light.link,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          strutStyle: const StrutStyle(
            fontSize: 13,
            height: 20 / 13,
            forceStrutHeight: true,
          ),
          style: TextStyle(fontSize: 13, color: IslandTokens.light.muted),
        ),
      ),
      box(Align(alignment: Alignment.centerLeft, child: field(0, fish))),
      label('自定义占位文本'),
      box(
        storyRow([
          field(1, flowers, placeholder: '请选择花朵'),
          field(3, fruits, placeholder: '请选择水果'),
        ], alignment: WrapAlignment.spaceBetween),
        decorated: true,
      ),
      label('禁用状态'),
      box(
        Align(
          alignment: Alignment.centerLeft,
          child: field(2, flowers, disabled: true),
        ),
      ),
      label('allowClear 一键清空'),
      box(
        storyRow([
          field(5, fish, clear: true),
          field(6, flowers, clear: true, clearLabel: '清除已选花朵'),
        ]),
      ),
      label('showSearch 输入关键字过滤'),
      box(
        storyRow([
          field(4, fish, search: true, placeholder: '搜索鱼类'),
          field(7, fruits, search: true, placeholder: '搜索水果'),
        ]),
        trailingSpace: false,
      ),
      const StoryCode(
        "IslandSelect<String>(\n  options: options,\n  value: value,\n  onChanged: (v) => setState(() => value = v),\n  allowClear: true,\n  showSearch: true,\n)",
      ),
      const StoryApi(
        rows: [
          ('options', '具有稳定唯一值的选项', 'List<IslandOption<T>>', 'required'),
          ('value', '父级控制的当前值', 'T?', 'required'),
          ('onChanged', '选择或清空请求', 'ValueChanged<T?>?', 'required'),
          ('label / clearLabel', '控件与清除动作名称', 'String', '选择 / 清除'),
          ('onClear', '清除通知', 'VoidCallback?', 'null'),
          ('width', '触发器宽度；弹层只在越界时适配视口', 'double?', 'null'),
          ('focusNode', '借用焦点；打开后可直接键盘操作；清除/搜索独立', 'FocusNode?', 'null'),
          ('placeholder', '占位文本', 'String', '请选择'),
          ('disabled', '禁用', 'bool', 'false'),
          ('allowClear', '一键清空', 'bool', 'false'),
          ('showSearch', '输入过滤', 'bool', 'false'),
          (
            'filter',
            '自定义过滤规则',
            'bool Function(String, IslandOption<T>)?',
            'null',
          ),
          ('filterLocally', 'false 由宿主提供过滤结果', 'bool', 'true'),
          ('onSearch', '查询及关闭重置通知', 'ValueChanged<String>?', 'null'),
          ('notFound', '浅色语义表面的无匹配插槽；显式样式优先', 'Widget', '暂无数据'),
        ],
      ),
    ],
  );
}
