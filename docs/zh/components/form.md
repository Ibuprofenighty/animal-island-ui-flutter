<!-- generated:api:start -->
# AnimalForm

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalForm`

## 属性
- `child`
- `controller`
- `initialValues`
- `onChanged`
- `onSubmit`

<!-- generated:api:end -->

## 验证状态与语言

`AnimalFormController` 为每个字段保存 locale-neutral 的 `AnimalValidationIssue?`。
程序判断应读取 `kind`，不要解析展示文案。locale 改变会保留已保存 issue，不会重跑验证。

`AnimalRule` 按不可变规则配置比较。自定义规则按 validator callback 的对象身份比较：用同一
callback 重建规则会保留配置身份，替换 callback 则会使旧校验任务失效。

## 类型化字段所有权

`AnimalFieldKey<T>` 是 final class，也是一个不透明的对象身份。外部库不能继承或实现它来改写相等比较与哈希行为。
表单使用期间应保留同一个 key 实例；
`debugLabel` 仅供诊断，不参与身份比较或字段查找。重复注册同一个 key 会立即失败；
旧 registration token 在该 key 被重新注册后注销，不会移除新注册。
请将 key 保存在稳定 owner 中，通常是 State 字段，使普通重建复用相同身份与 baseline。

`AnimalForm.initialValues`、`onChanged` 和 `onSubmit` 使用 `AnimalFormValues`。
通过 `valueFor(key)` 读取字段，返回类型由 key 保持，不需要调用者强制转换。
用 `AnimalFormValues.fromEntries` 与 `AnimalFieldValue<T>` 提供初始值：

文本字段通过 `AnimalFormItem.textController` 显式加入表单。调用方应在所属
`State` 中稳定创建并负责 dispose 借用的 controller。完整 `TextEditingValue` 是唯一文本初值与实时来源；
空缓冲区映射为 null。不要同时在 `AnimalForm.initialValues` 或
`AnimalFormItem.initialValue` 中提供同一个文本 key。非文本 String 字段（例如选项值）仍使用普通不可变字段值。

```dart
final nameKey = AnimalFieldKey<String>(debugLabel: 'name');
final nameController = TextEditingController(text: 'Islander');

AnimalForm(
  onSubmit: (values) {
    final String? name = values.valueFor(nameKey);
    return name != null;
  },
  child: AnimalFormItem<String>(
    fieldKey: nameKey,
    textController: nameController,
    builder: (context, binding) => AnimalInput(controller: nameController),
  ),
)
```

`onSubmit` 返回 `FutureOr<bool>`。不可变快照被接受时返回 true，调用者拒绝时返回 false；
false 会让 `submit()` 返回 typed `rejected` 结果。handler 抛出的异常保留在
`AnimalSubmitResult.error` 中，由调用者呈现。未安装 handler 时，合法表单仍按现有行为在
校验成功后完成 validation-only submit。字段校验 issue 由 `AnimalFormItem` 本地化；handler
结果由调用者负责呈现。
handler 等待期间发生值、规则或字段集合变化、字段注销/同名重注册、reset 或默认 handler
替换时，会取消本地 submit。晚到的 handler 完成不能改变替代 submit；handler 已启动的外部副作用
不由表单取消。

Controller 在注册字段时捕获 baseline。`dirty` 比较当前值与冻结的 baseline；值恢复为
baseline 后 `dirty` 会清除。`reset()` 恢复 baseline，并清除 touched 状态与验证问题。
`clear()` 将字段值设为 null、保留 baseline 与 touched 状态，并清除验证问题。
调用 binding 的 `onBlur` 会标记字段为 touched。

标量 key 直接快照值。平面集合使用 `AnimalFieldKey.list<E>`、`AnimalFieldKey.set<E>` 或
`AnimalFieldKey.map<K, V>`；它们保留泛型、复制外层集合，并拒绝嵌套集合。嵌套集合需要
`AnimalFieldKey.withSnapshot<T>`，并由调用者提供深拷贝且冻结所有嵌套集合的策略。

## 示例
参见示例 Gallery 中的 [`form_story.dart`](../../../example/lib/stories/form_story.dart)。
