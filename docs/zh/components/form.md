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

## 类型化字段所有权

`AnimalFieldKey<T>` 是 final class，也是一个不透明的对象身份。外部库不能继承或实现它来改写相等比较与哈希行为。
表单使用期间应保留同一个 key 实例；
`debugLabel` 仅供诊断，不参与身份比较或字段查找。重复注册同一个 key 会立即失败；
旧 registration token 在该 key 被重新注册后注销，不会移除新注册。
请将 key 保存在稳定 owner 中，通常是 State 字段，使普通重建复用相同身份与 baseline。

`AnimalForm.initialValues`、`onChanged` 和 `onSubmit` 使用 `AnimalFormValues`。
通过 `valueFor(key)` 读取字段，返回类型由 key 保持，不需要调用者强制转换。
用 `AnimalFormValues.fromEntries` 与 `AnimalFieldValue<T>` 提供初始值：

```dart
final nameKey = AnimalFieldKey<String>(debugLabel: 'name');

AnimalForm(
  initialValues: AnimalFormValues.fromEntries([
    AnimalFieldValue(nameKey, 'Islander'),
  ]),
  onSubmit: (values) {
    final String? name = values.valueFor(nameKey);
  },
  child: AnimalFormItem<String>(
    fieldKey: nameKey,
    builder: (context, binding) => AnimalInput(
      value: binding.value,
      onChanged: binding.onChanged,
    ),
  ),
)
```

Controller 在注册字段时捕获 baseline。`dirty` 比较当前值与冻结的 baseline；值恢复为
baseline 后 `dirty` 会清除。`reset()` 恢复 baseline，并清除 touched 状态与验证问题。
`clear()` 将字段值设为 null、保留 baseline 与 touched 状态，并清除验证问题。
调用 binding 的 `onBlur` 会标记字段为 touched。

标量 key 直接快照值。平面集合使用 `AnimalFieldKey.list<E>`、`AnimalFieldKey.set<E>` 或
`AnimalFieldKey.map<K, V>`；它们保留泛型、复制外层集合，并拒绝嵌套集合。嵌套集合需要
`AnimalFieldKey.withSnapshot<T>`，并由调用者提供深拷贝且冻结所有嵌套集合的策略。

## 示例
参见示例 Gallery 中的 [`form_story.dart`](../../../example/lib/stories/form_story.dart)。
