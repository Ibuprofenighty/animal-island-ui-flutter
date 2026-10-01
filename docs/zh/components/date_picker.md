<!-- generated:api:start -->
# AnimalDatePicker

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalDatePicker`

## 属性
- `allowClear`
- `disabled`
- `disabledDate`
- `firstDate`
- `focusNode`
- `lastDate`
- `onChanged`
- `onRangeChanged`
- `picker`
- `range`
- `rangeValue`
- `showToday`
- `value`

## 枚举
- `AnimalDatePickerMode`

<!-- generated:api:end -->

## 本地化
默认提示和底部操作使用生成的 AnimalLocalizations；日期显示、月份名称、星期标签、导航标签和日期单元格语义遵循当前 Material 语言。传入的 placeholder 仍由调用方提供。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`date_picker_story.dart`](../../../example/lib/stories/date_picker_story.dart)。
