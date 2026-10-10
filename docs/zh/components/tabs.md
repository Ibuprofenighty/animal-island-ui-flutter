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
- `selectedId`
- `style`
- `tabs`

<!-- generated:api:end -->

## 本地化
AnimalTabItem.label 由调用方提供，同时作为可见文字和标签页语义标签。请传入本地化后的标签。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`tabs_story.dart`](../../../example/lib/stories/tabs_story.dart)。

## 所有权与边界

每个 `AnimalTabItem` 必须提供非空唯一 `id`，调用者传入 `selectedId` 和 `onChanged`；null 表示无选中项。未知或禁用的选中 ID 抛 `ArgumentError`，删除选中项须同时更新 ID。选中值只属于父级。方向键、Home、End 移动 roving 焦点并提议可用 ID，RTL 下水平键镜像；父级拒绝时选中值不变。Enter/Space 和指针激活提议焦点项 ID，包括已选中项。标签、文字缩放及宽度变化重新测量指示器，滚动布局会显示选中项。重排时焦点跟随 ID。

父级拒绝选中提议时，共享焦点 owner 仍立即显示键盘焦点目标；挂载后的文字缩放及 LTR/RTL 方向变化在布局后重新测量指示器，保留选中 ID 且不发出选中提议。

## 定制

在 `style` 或 `AnimalIslandTheme.components.tabs` 使用 `AnimalTabsStyle`，每个字段按实例 > 组件主题 > token 默认值解析。null 继承下层，局部 TextStyle 按属性合并。非法尺寸、insets、圆角、字号及 duration 在 debug/release 一致抛 `ArgumentError`。这组组件没有尺寸预设，动作的 48px 命中下限保持固定。

| 字段 | 渲染决策 |
| --- | --- |
| `backgroundColor` | 背景填充。 |
| `borderColor` | 轮廓颜色。 |
| `borderWidth` | 轮廓宽度。 |
| `borderRadius` | 圆角。 |
| `padding` | 内边距。 |
| `tabPadding` | 每个标签项的内边距。 |
| `iconGap` | 图标与文字的间距。 |
| `iconSize` | 图标大小。 |
| `textStyle` | 文字样式。 |
| `textColor` | 文字颜色；支持的交互状态见组件行为。 |
| `indicatorColor` | 选中指示器的填充。 |
| `shadow` | 阴影。 |
| `duration` | 主体过渡时间。 |
| `curve` | 过渡曲线。 |
