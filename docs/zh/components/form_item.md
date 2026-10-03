<!-- generated:api:start -->
# AnimalFormItem

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalFormItem`

## 属性
- `builder`
- `fieldKey`
- `focusNode`
- `help`
- `initialValue`
- `label`
- `labelWidget`
- `margin`
- `required`
- `rules`
- `textController`

<!-- generated:api:end -->

## 验证文案与语言

`AnimalFormItem` 负责显示内建验证问题，并使用当前生成的本地化文案。
locale 改变只重绘同一 issue，不会再次调用 validator；调用者提供的自定义文案保持原文。

每个 item 都必须提供类型化 `fieldKey` 与 `builder`。builder 从外层 `AnimalForm`
接收实时 `AnimalFieldBinding<T>`，其中包含当前值、`dirty`、`touched`、验证状态与问题、
焦点节点，以及类型化的 change/blur 回调。没有对应 owner 或注册无效时，item 会抛出
`StateError`，不会伪造占位 binding。

文本 binding 的当前值直接读取借用的 `TextEditingController`，不会再保存第二份当前文本。
标量字段仅当表单类型化 `initialValues` 中没有该 key 时，才使用 item 的 `initialValue`；
Controller 在注册时冻结该值作为 baseline。文本字段必须显式传 `textController`，其完整初始
`TextEditingValue` 提供唯一文本与编辑状态。不要同时设置 `initialValue` 或在
`AnimalForm.initialValues` 中包含该 key。即使 `T` 为 `String`，也只有显式 opt-in 才是文本字段，
非文本 String 选项值仍保持标量语义。key 以对象实例作为身份，标签不会建立字符串查找路径。

请把 key 保存在所属 State 或其他稳定 owner 中，不要在 `build` 中创建。
普通重建和通过 `GlobalKey` 移动同一个 State 都会保留 registration generation、当前值和 baseline。
重新挂载的新 item 会取得新 generation，并以当前类型化初始值捕获 baseline。

## 示例
参见示例 Gallery 中的 [`form_item_story.dart`](../../../example/lib/stories/form_item_story.dart)。
