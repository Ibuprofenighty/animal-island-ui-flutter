<!-- generated:api:start -->
# AnimalInput

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalInput`

## 属性
- `autofocus`
- `clearable`
- `controller`
- `disabled`
- `focusNode`
- `initialValue`
- `inputFormatters`
- `keyboardType`
- `maxLines`
- `minLines`
- `obscureText`
- `onChanged`
- `onSubmitted`
- `placeholder`
- `prefix`
- `readOnly`
- `shadow`
- `size`
- `status`
- `suffix`
- `textInputAction`
- `value`

## 枚举
- `AnimalInputSize`
- `AnimalInputStatus`

<!-- generated:api:end -->

## 本地化
清除操作标签使用生成的 AnimalLocalizations。placeholder、前缀、后缀和输入内容仍由调用方提供。

## 交互与无障碍

文本编辑由底层 `TextField` 处理。清除操作响应指针点击，并在获得焦点时响应 Enter 或 Space。传入的 `FocusNode` 仍归调用方所有，输入框会跟随替换后的节点。

## 示例
参见示例 Gallery 中的 [`input_story.dart`](../../../example/lib/stories/input_story.dart)。
