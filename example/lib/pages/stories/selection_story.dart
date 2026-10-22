import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class SelectionStory extends StatefulWidget {
  const SelectionStory({super.key, required this.radio});
  final bool radio;
  @override
  State<SelectionStory> createState() => _SelectionStoryState();
}

class _SelectionStoryState extends State<SelectionStory> {
  final choices = <int, Set<String>>{
    0: {'海滩', '花园'},
    1: {},
    2: {'森林'},
    3: {'海滩'},
    4: {'海滩'},
    5: {'花园', '村庄'},
  };
  final radios = <int, String?>{
    0: '春天',
    1: null,
    2: '早晨',
    3: '中午',
    4: '深夜',
    5: '中午',
    6: '冬天',
  };
  Widget group(
    int n,
    List<String> labels, {
    IslandSize size = IslandSize.middle,
    bool vertical = false,
    bool disabled = false,
    String? disabledItem,
  }) {
    final items = [
      for (final label in labels)
        IslandOption(
          value: label,
          label: label,
          disabled: disabledItem == label,
        ),
    ];
    final control = widget.radio
        ? IslandRadioGroup<String>(
            options: items,
            value: radios[n],
            size: size,
            vertical: vertical,
            spacing: n == 0 ? 20 : null,
            onChanged: disabled ? null : (v) => setState(() => radios[n] = v),
          )
        : IslandCheckboxGroup<String>(
            options: items,
            values: choices[n] ?? {},
            size: size,
            vertical: vertical,
            spacing: n == 0 ? 20 : null,
            onChanged: disabled ? null : (v) => setState(() => choices[n] = v),
          );
    return StoryDemoBox(child: control);
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.radio
        ? ['春天', '夏天', '秋天', '冬天']
        : ['海滩', '森林', '花园', '村庄'];
    final times = widget.radio ? ['早晨', '中午', '傍晚', '深夜'] : labels;
    return StoryPanel(
      title: widget.radio ? 'Radio' : 'Checkbox',
      tags: [widget.radio ? '单选框' : '基础用法'],
      children: [
        StoryLabel(
          widget.radio ? '水平排列（受控）— 支持方向键 ↑↓←→ 切换' : '默认水平排列（受控）',
          strutStyle: storyCaptionStrut,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '已选中: '),
                TextSpan(
                  text: widget.radio
                      ? radios[0] ?? '无'
                      : labels.where(choices[0]!.contains).join('、'),
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
            style: TextStyle(
              fontSize: 13,
              height: 20 / 13,
              color: IslandTokens.light.muted,
            ),
          ),
        ),
        group(0, labels),
        const StoryLabel('垂直排列 + 含禁用选项', strutStyle: storyCaptionStrut),
        group(
          1,
          widget.radio
              ? ['苹果', '橙子', '桃子', '梨子', '樱桃']
              : ['蝴蝶', '鲈鱼', '螃蟹', '毛毛虫', '水母'],
          vertical: true,
          disabledItem: widget.radio ? '梨子' : '螃蟹',
        ),
        const StoryLabel('小尺寸', strutStyle: storyCaptionStrut),
        group(2, times, size: IslandSize.small),
        const StoryLabel('中尺寸（默认）', strutStyle: storyCaptionStrut),
        group(3, times),
        const StoryLabel('大尺寸', strutStyle: storyCaptionStrut),
        group(
          4,
          widget.radio ? times : times.take(3).toList(),
          size: IslandSize.large,
        ),
        if (widget.radio) ...[
          const StoryLabel('3D 按键感 — 点击体验下压反馈'),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: '已选中: '),
                  TextSpan(
                    text: radios[5] ?? '无',
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
              style: TextStyle(
                fontSize: 13,
                height: 20 / 13,
                color: IslandTokens.light.muted,
              ),
            ),
          ),
          group(5, times, size: IslandSize.large),
        ],
        const StoryLabel('全部禁用', strutStyle: storyCaptionStrut),
        group(widget.radio ? 6 : 5, labels, disabled: true),
        StoryCode(
          widget.radio
              ? "IslandRadioGroup<String>(\n  options: options, value: value,\n  onChanged: (next) => setState(() => value = next),\n)"
              : "IslandCheckboxGroup<String>(\n  options: options, values: values,\n  onChanged: (next) => setState(() => values = next),\n)",
        ),
        StoryApi(
          rows: [
            ('options', '稳定值、标签及选项禁用状态', 'List<IslandOption<T>>', 'required'),
            (
              widget.radio ? 'value' : 'values',
              '父级持有选择；可拒绝更新',
              widget.radio ? 'T?' : 'Set<T>',
              'required',
            ),
            (
              'onChanged',
              '选择意图；null 禁用整组',
              widget.radio ? 'ValueChanged<T>?' : 'ValueChanged<Set<T>>?',
              'required',
            ),
            ('vertical', '垂直排列', 'bool', 'false'),
            ('spacing', '选项间距；水平默认16，垂直默认12', 'double?', 'null'),
            ('size', '三种尺寸', 'IslandSize', 'middle'),
          ],
        ),
      ],
    );
  }
}
