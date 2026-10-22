import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class InputStory extends StatelessWidget {
  const InputStory({super.key});
  static const _labelStrut = StrutStyle(
    fontSize: 14,
    height: 1.5,
    forceStrutHeight: true,
  );
  Widget field(
    String hint, {
    IslandSize size = IslandSize.middle,
    bool shadow = false,
    bool clear = false,
    bool enabled = true,
    IslandFieldStatus status = IslandFieldStatus.normal,
    Widget? prefix,
    Widget? suffix,
  }) => SizedBox(
    width: 360,
    child: IslandTextField(
      label: hint,
      hint: hint,
      showLabel: false,
      size: size,
      shadow: shadow,
      allowClear: clear,
      enabled: enabled,
      status: status,
      prefix: prefix,
      suffix: suffix,
    ),
  );
  Widget column(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < children.length; i++)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
          child: children[i],
        ),
    ],
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Input',
    tags: ["3 sizes"],
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          width: double.infinity,
          child: Theme(
            data: Theme.of(context).copyWith(
              extensions: [
                for (final e in Theme.of(context).extensions.values)
                  if (e is! IslandCardTheme) e,
                const IslandCardTheme(
                  radius: 18,
                  style: IslandCardStyle(
                    borderColor: WidgetStatePropertyAll(Color(0xfff1d5a4)),
                  ),
                ),
              ],
            ),
            child: IslandCard(
              pattern: IslandColorway.brown,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StoryLabel('shadow 阴影控制', strutStyle: _labelStrut),
                  column([
                    field('No shadow (default)'),
                    field('With shadow', shadow: true),
                  ]),
                  const StoryLabel('基础用法', strutStyle: _labelStrut),
                  column([
                    field('Basic input'),
                    field('With clear', clear: true),
                    field(
                      'Please enter your phone number',
                      prefix: const IslandIcon(IslandGlyph.phone, size: 20),
                      suffix: const Text('⏎'),
                    ),
                  ]),
                  const StoryLabel('size 尺寸', strutStyle: _labelStrut),
                  column([
                    field('Small', size: IslandSize.small),
                    field('Middle (default)'),
                    field('Large', size: IslandSize.large),
                  ]),
                  const StoryLabel('status 校验状态', strutStyle: _labelStrut),
                  column([
                    field('Error status', status: IslandFieldStatus.error),
                    field('Warning status', status: IslandFieldStatus.warning),
                  ]),
                  const StoryLabel('disabled 禁用', strutStyle: _labelStrut),
                  field('Disabled', enabled: false),
                ],
              ),
            ),
          ),
        ),
      ),
      const StoryCode(
        "IslandTextField(\n  label: '姓名',\n  hint: 'Basic input',\n  allowClear: true,\n)",
      ),
      const StoryApi(
        rows: [
          (
            'label / showLabel',
            '可访问名称及可见标签',
            'String / bool',
            'required / true',
          ),
          (
            'controller / focusNode',
            '借用编辑器及焦点',
            'TextEditingController? / FocusNode?',
            'null',
          ),
          ('hint / helper', '占位与辅助文字', 'String?', 'null'),
          (
            'onChanged / onSubmitted',
            '编辑及提交事件',
            'ValueChanged<String>?',
            'null',
          ),
          (
            'size / status',
            '尺寸及校验外观',
            'IslandSize / IslandFieldStatus',
            'middle / normal',
          ),
          (
            'enabled / readOnly / obscureText',
            '禁用、只读、密码',
            'bool',
            'true / false / false',
          ),
          ('shadow / allowClear', '阴影及清空按钮', 'bool', 'false'),
          ('prefix / suffix', '前后内容插槽', 'Widget?', 'null'),
          (
            'validator / autovalidateMode',
            'Flutter 表单校验',
            'FormFieldValidator<String>? / AutovalidateMode',
            'null / disabled',
          ),
          (
            'keyboardType / textInputAction / maxLines',
            '输入配置',
            'TextInputType? / TextInputAction? / int',
            'null / null / 1',
          ),
        ],
      ),
    ],
  );
}

class SwitchStory extends StatefulWidget {
  const SwitchStory({super.key});
  @override
  State<SwitchStory> createState() => _SwitchStoryState();
}

class _SwitchStoryState extends State<SwitchStory> {
  final values = [false, true, true, true, true];
  Widget control(int i, {bool small = false, bool text = false}) =>
      IslandSwitch(
        label: 'Switch $i',
        value: values[i],
        showLabel: false,
        small: small,
        checkedLabel: text ? '开' : null,
        uncheckedLabel: text ? '关' : null,
        onChanged: (v) => setState(() => values[i] = v),
      );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Switch',
    tags: ["2 sizes"],
    children: [
      const StoryLabel('基础用法', strutStyle: storyCaptionStrut),
      storyRow([control(0), Text(values[0] ? 'ON' : 'OFF')]),
      const StoryLabel('checkedChildren / unCheckedChildren 自定义文案'),
      storyRow([control(1, text: true), control(2, text: true)]),
      const StoryLabel('size 尺寸'),
      storyRow([control(3), control(4, small: true)]),
      const StoryLabel('disabled / loading 状态'),
      storyRow([
        const IslandSwitch(
          label: 'Disabled',
          value: false,
          onChanged: null,
          showLabel: false,
        ),
        IslandSwitch(
          label: 'Loading',
          value: true,
          onChanged: (_) {},
          showLabel: false,
          busy: true,
        ),
      ]),
      const StoryCode(
        "IslandSwitch(\n  label: '开关',\n  value: enabled,\n  onChanged: (value) => setState(() => enabled = value),\n)",
      ),
      const StoryApi(
        rows: [
          (
            'value / onChanged',
            '父级受控值及变更请求；null 禁用',
            'bool / ValueChanged<bool>?',
            'required',
          ),
          (
            'label / showLabel',
            '可访问名称及可见标签',
            'String / bool',
            'required / true',
          ),
          ('small', '小尺寸', 'bool', 'false'),
          ('busy', '加载时禁止激活', 'bool', 'false'),
          ('checkedLabel / uncheckedLabel', '开关内文案', 'String?', 'null'),
        ],
      ),
    ],
  );
}
