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
- `child`
- `fieldKey`
- `focusNode`
- `help`
- `initialValue`
- `label`
- `labelWidget`
- `margin`
- `name`
- `required`
- `rules`

<!-- generated:api:end -->

## 验证文案与语言

`AnimalFormItem` 负责显示内建验证问题，并使用当前生成的本地化文案。
locale 改变只重绘同一 issue，不会再次调用 validator；调用者提供的自定义文案保持原文。

## 示例
参见示例 Gallery 中的 [`form_item_story.dart`](../../../example/lib/stories/form_item_story.dart)。
