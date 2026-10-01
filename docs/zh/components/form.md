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

## 示例
参见示例 Gallery 中的 [`form_story.dart`](../../../example/lib/stories/form_story.dart)。
