import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class FormStory extends StatefulWidget {
  const FormStory({super.key});
  @override
  State<FormStory> createState() => _FormStoryState();
}

class _FormStoryState extends State<FormStory> {
  final instance = IslandFormController(
    initialValues: {'name': '', 'fruit': 'apple', 'hobby': <String>{}},
  );
  String result = '';
  Map<String, Object?> live = {};
  // The reference chooses random patterns once on mount. Fixed choices make
  // captures repeatable and use only colors in its documented random pool.
  static const patterns = [
    IslandColorway.teal,
    IslandColorway.teal,
    IslandColorway.yellow,
    IslandColorway.orange,
    IslandColorway.green,
  ];
  String json(Map<String, Object?> values) => jsonEncode(
    values.map(
      (key, value) => MapEntry(key, value is Set ? value.toList() : value),
    ),
  );
  @override
  void dispose() {
    instance.dispose();
    super.dispose();
  }

  Widget card(int i, Widget child) => SizedBox(
    width: 360,
    child: IslandCard(
      pattern: patterns[i],
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: child,
        ),
      ),
    ),
  );
  Widget submit(
    String text, {
    bool block = false,
    IslandSize size = IslandSize.middle,
  }) => Builder(
    builder: (context) => IslandButton(
      block: block,
      size: size,
      variant: IslandButtonVariant.primary,
      onPressed: () => IslandForm.of(context).submit(),
      child: Text(text),
    ),
  );
  Widget actions(Widget child) => IslandFormItem(
    child: Padding(padding: const EdgeInsets.only(top: 8), child: child),
  );
  static String? requiredText(String? value, String message) =>
      value == null || value.isEmpty ? message : null;
  Widget caption(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: SizedBox(
      height: MediaQuery.textScalerOf(context).scale(16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 4 / 3,
          color: IslandTokens.light.muted,
        ),
        strutStyle: StrutStyle(
          fontFamily: DefaultTextStyle.of(context).style.fontFamily,
          fontSize: 12,
          height: 4 / 3,
          forceStrutHeight: true,
        ),
      ),
    ),
  );
  Widget checks(String name, String label, Map<String, String> options) =>
      IslandFormField<Set<String>>(
        name: name,
        label: label,
        builder: (context, field) => IslandCheckboxGroup<String>(
          options: [
            for (final e in options.entries)
              IslandOption(value: e.key, label: e.value),
          ],
          values: field.value ?? {},
          size: field.size,
          onChanged: field.enabled ? field.onChanged : null,
        ),
      );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Form',
    tags: ["表单", "useForm", "校验"],
    children: [
      const StoryLabel(
        'Form 表单组件 — 集成表单实例、校验规则、布局网格、依赖字段等基础能力。',
        spaceAfter: 0,
      ),
      const StoryLabel('基础用法：登录表单（required / minLength / 自定义 validator）'),
      card(
        0,
        IslandForm(
          layout: IslandFormLayout.vertical,
          initialValues: const {'username': '', 'password': ''},
          children: [
            IslandFormTextField(
              name: 'username',
              label: '用户名',
              hint: '请输入用户名',
              required: true,
              validators: [
                (v, _) => requiredText(v, '请输入用户名'),
                (v, _) =>
                    v != null && v.isNotEmpty && (v.length < 3 || v.length > 12)
                    ? '长度需在 3 - 12 字符之间'
                    : null,
              ],
            ),
            IslandFormTextField(
              name: 'password',
              label: '密码',
              hint: '请输入密码',
              required: true,
              obscureText: true,
              validators: [
                (v, _) => requiredText(v, '请输入密码'),
                (v, _) async => v != null && v.isNotEmpty && v.length < 6
                    ? '密码至少 6 位'
                    : null,
              ],
            ),
            actions(submit('登录', block: true)),
          ],
        ),
      ),
      const StoryLabel('三种布局：horizontal / vertical / inline'),
      card(
        1,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            caption('layout="horizontal"'),
            const IslandForm(
              labelColumns: 6,
              controlColumns: 18,
              labelAlign: TextAlign.left,
              children: [
                IslandFormTextField(
                  name: 'a',
                  label: '昵称',
                  hint: '输入昵称',
                  required: true,
                ),
                IslandFormTextField(name: 'a-sign', label: '签名', hint: '输入签名'),
              ],
            ),
            const SizedBox(height: 22),
            caption('layout="vertical"'),
            const IslandForm(
              layout: IslandFormLayout.vertical,
              children: [
                IslandFormTextField(
                  name: 'b',
                  label: '标题',
                  hint: '输入标题',
                  required: true,
                ),
              ],
            ),
            const SizedBox(height: 22),
            caption('layout="inline"'),
            IslandForm(
              layout: IslandFormLayout.inline,
              children: [
                const SizedBox(
                  width: 199,
                  child: IslandFormTextField(
                    name: 'c',
                    label: '',
                    hint: '搜索关键词',
                  ),
                ),
                SizedBox(
                  width: 60.484375,
                  child: IslandFormItem(
                    child: submit('搜索', size: IslandSize.small),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const StoryLabel('Form.useForm + 命令式 API（setFieldsValue / resetFields）'),
      card(
        2,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IslandForm(
              controller: instance,
              layout: IslandFormLayout.vertical,
              onFinish: (v) => setState(() => result = 'onFinish: ${json(v)}'),
              children: [
                const IslandFormTextField(
                  name: 'name',
                  label: '姓名',
                  hint: '请输入姓名',
                  required: true,
                ),
                const IslandFormTextField(
                  name: 'fruit',
                  label: '最爱水果',
                  hint: 'apple / orange / grape',
                ),
                checks('hobby', '爱好', {
                  'fish': '钓鱼',
                  'wood': '砍树',
                  'mine': '挖矿',
                }),
                actions(
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      IslandButton(
                        variant: IslandButtonVariant.dashed,
                        onPressed: () => instance.setValues({
                          'name': 'Mochi',
                          'fruit': 'orange',
                          'hobby': {'fish', 'mine'},
                        }),
                        child: const Text('一键填充'),
                      ),
                      IslandButton(
                        onPressed: () => instance.reset(),
                        child: const Text('重置'),
                      ),
                      submit('提交'),
                    ],
                  ),
                ),
              ],
            ),
            if (result.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfffffbe6),
                  border: Border.all(color: const Color(0xffffe58f)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff874d00),
                  ),
                ),
              ),
          ],
        ),
      ),
      const StoryLabel('onValuesChange：实时同步字段值'),
      card(
        3,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IslandForm(
              layout: IslandFormLayout.vertical,
              initialValues: {
                'radio': 'cat',
                'check': {'b'},
              },
              onValuesChanged: (_, all) => setState(() => live = all),
              children: [
                IslandFormField<String>(
                  name: 'radio',
                  label: '你是？',
                  builder: (context, field) => IslandRadioGroup<String>(
                    options: const [
                      IslandOption(value: 'cat', label: '猫'),
                      IslandOption(value: 'dog', label: '狗'),
                      IslandOption(value: 'rabbit', label: '兔子'),
                    ],
                    value: field.value,
                    size: field.size,
                    onChanged: field.enabled ? field.onChanged : null,
                  ),
                ),
                checks('check', '你喜欢？', {'a': 'A', 'b': 'B', 'c': 'C'}),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'liveValues: ${json(live)}',
                style: TextStyle(
                  fontSize: 12,
                  color: IslandColorway.blue.ink,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
      const StoryLabel('校验规则：pattern / type / max / 自定义 async'),
      card(
        4,
        IslandForm(
          layout: IslandFormLayout.vertical,
          initialValues: const {'email': '', 'age': '', 'code': ''},
          onFinish: (v) => Navigator.of(context, rootNavigator: true).push(
            IslandDialogRoute<void>(
              context: context,
              builder: (context) => AlertDialog(
                content: Text('提交: ${json(v)}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
          ),
          children: [
            IslandFormTextField(
              name: 'email',
              label: '邮箱',
              hint: 'example@animal.com',
              required: true,
              validators: [
                (v, _) => requiredText(v, '请输入邮箱'),
                (v, _) =>
                    v != null &&
                        v.isNotEmpty &&
                        !RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(v)
                    ? '邮箱格式不正确'
                    : null,
              ],
            ),
            IslandFormTextField(
              name: 'age',
              label: '年龄',
              hint: '整数',
              required: true,
              validators: [
                (v, _) => requiredText(v, '请输入年龄'),
                (v, _) => v != null && v.isNotEmpty && int.tryParse(v) == null
                    ? '请输入整数'
                    : null,
                (v, _) {
                  final n = int.tryParse(v ?? '');
                  return n != null && (n < 0 || n > 150)
                      ? '年龄应在 0 - 150 之间'
                      : null;
                },
              ],
            ),
            IslandFormTextField(
              name: 'code',
              label: '邀请码',
              hint: '请输入邀请码',
              validators: [
                (v, _) =>
                    v != null &&
                        v.isNotEmpty &&
                        !RegExp(r'^[A-Z]{4}$').hasMatch(v)
                    ? '4 位大写字母'
                    : null,
              ],
            ),
            actions(submit('提交', block: true)),
          ],
        ),
      ),
      const StoryCode(
        "final form = IslandFormController(initialValues: {'name': ''});\nIslandForm(\n  controller: form,\n  layout: IslandFormLayout.vertical,\n  children: [\n    IslandFormTextField(\n      name: 'name', label: '姓名',\n      validators: [(value, _) => value == null || value.isEmpty ? '请输入姓名' : null],\n    ),\n    IslandButton(onPressed: form.submit, child: Text('提交')),\n  ],\n)\n// Creator disposes form; child controls are bound through explicit builders.",
      ),
      const StoryApi(
        rows: [
          (
            'controller / initialValues',
            '借用表单实例 / 内部实例初始值',
            'IslandFormController? / Map<String,Object?>',
            'null / {}',
          ),
          (
            'layout / labelAlign',
            '三种布局 / 标签对齐',
            'IslandFormLayout / TextAlign?',
            'horizontal / 根据布局',
          ),
          ('labelColumns / controlColumns', '24 列网格比例', 'int', '5 / 19'),
          (
            'size / disabled',
            '传给字段的默认尺寸与禁用状态',
            'IslandSize / bool',
            'middle / false',
          ),
          (
            'colon / requiredMark',
            '冒号与必填标记；依据参考实际默认值',
            'bool / IslandFormRequiredMark',
            'true / hidden',
          ),
          (
            'onFinish / onFinishFailed',
            '有效快照提交 / 校验错误结果',
            'ValueChanged callback?',
            'null',
          ),
          ('onValuesChanged / onReset', '用户变更和重置通知', 'callback?', 'null'),
          (
            'setValues / reset / validate / submit',
            '实例命令；过期异步结果不会覆盖新状态',
            'controller methods',
            '—',
          ),
        ],
      ),
      const StoryApi(
        rows: [
          (
            'name / builder',
            '稳定字段名和显式类型绑定',
            'String / Widget Function(context,binding)',
            'required',
          ),
          ('initialValue', '仅字段首次注册时生效；表单初始值优先', 'T?', 'null'),
          (
            'validators / dependencies',
            '同步或异步校验函数 / 依赖字段名',
            'List<IslandFormValidator<T>> / List<String>',
            '[]',
          ),
          ('normalize', '写入前转换；允许返回 null', 'T? Function(T?,T?,Map)?', 'null'),
          (
            'label / help / required',
            '标签、说明和标记；标记不等于校验',
            'String? / Widget? / bool',
            'null / null / false',
          ),
          ('hidden / noStyle', '隐藏显示 / 不渲染标签布局', 'bool', 'false'),
          (
            'enabled / size / layout',
            '显式覆盖表单默认值',
            'bool? / IslandSize? / IslandFormLayout?',
            'null',
          ),
          (
            'IslandFormTextField',
            '拥有编辑控制器的文本字段适配器',
            'name, label, hint, validators, focusNode',
            '—',
          ),
        ],
      ),
    ],
  );
}
