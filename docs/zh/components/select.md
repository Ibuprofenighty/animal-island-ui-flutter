<!-- generated:api:start -->
# AnimalSelect

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalSelect`

## 属性
- `allowClear`
- `disabled`
- `focusNode`
- `onChanged`
- `options`
- `placeholder`
- `status`
- `value`

<!-- generated:api:end -->

## 本地化
placeholder 为 null 时，选择器使用生成的本地化默认提示。选项标签仍由调用方提供。清除操作使用生成的 AnimalLocalizations；显式 placeholder 仅覆盖默认提示。

## 交互与无障碍

触发器、菜单选项和清除动作分别响应指针点击，并在获得焦点时响应 Enter 或 Space，每次操作只激活一次。弹出菜单内的键盘导航由选择器自身处理。

## 示例
参见示例 Gallery 中的 [`select_story.dart`](../../../example/lib/stories/select_story.dart)。
