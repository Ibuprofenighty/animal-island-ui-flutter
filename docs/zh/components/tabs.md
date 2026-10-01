<!-- generated:api:start -->
# AnimalTabs

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTabs`

## 属性
- `onChanged`
- `scrollable`
- `selectedIndex`
- `tabs`

<!-- generated:api:end -->

## 已知限制

窄布局下切换选中标签时，活动标签可能不会自动滚动到可见区域。

## 本地化
AnimalTabItem.label 由调用方提供，同时作为可见文字和标签页语义标签。请传入本地化后的标签。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`tabs_story.dart`](../../../example/lib/stories/tabs_story.dart)。
