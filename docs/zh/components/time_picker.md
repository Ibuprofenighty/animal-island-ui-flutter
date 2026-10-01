<!-- generated:api:start -->
# AnimalTimePicker

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTimePicker`

## 属性
- `allowClear`
- `disabled`
- `focusNode`
- `format`
- `hourStep`
- `minuteStep`
- `onChanged`
- `secondStep`
- `showNow`
- `value`

<!-- generated:api:end -->

## 本地化
默认提示、面板操作和滚轮数值语义使用生成的 AnimalLocalizations，并在语言切换时刷新。传入的 placeholder 仍由调用方提供。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`time_picker_story.dart`](../../../example/lib/stories/time_picker_story.dart)。
