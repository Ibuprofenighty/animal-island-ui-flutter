<!-- generated:api:start -->
# AnimalTag

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTag`

## 属性
- `child`
- `color`
- `disabled`
- `focusNode`
- `icon`
- `onClose`
- `onTap`
- `size`
- `variant`

## 枚举
- `AnimalTagSize`
- `AnimalTagVariant`

<!-- generated:api:end -->

## 本地化
关闭操作的无障碍标签使用生成的 `tagRemoveLabel` 文案；标签主体 `child` 仍由调用者提供。

## 交互与无障碍

同时提供两种动作时，标签主体和关闭控件是相互独立的目标；激活关闭控件不会同时激活主体。两者各自拥有焦点和 48 逻辑像素命中区域，且互不重叠。标签失去焦点、被禁用、被隐藏或被卸载时，未完成的激活会被取消。

关闭控件是包内共用的图标操作，带焦点环，并以本地化的 `tagRemoveLabel` 作为无障碍名称。

## 示例
参见示例 Gallery 中的 [`tag_story.dart`](../../../example/lib/stories/tag_story.dart)。
