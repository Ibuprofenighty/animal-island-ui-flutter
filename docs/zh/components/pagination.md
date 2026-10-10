<!-- generated:api:start -->
# AnimalPagination

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalPagination`

## 属性
- `current`
- `disabled`
- `onChanged`
- `pageSize`
- `simple`
- `style`
- `total`
- `totalPages`

<!-- generated:api:end -->

## 本地化
导航、上一页/下一页、页码及前后跳五页的语义使用生成的分页文案。页码仍为数字，
控件挂载期间切换语言时所有标签会更新。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`pagination_story.dart`](../../../example/lib/stories/pagination_story.dart)。

## 所有权与边界

`current` 只由调用者持有。`total` 非负、`pageSize` 为正，页数采用精确整数计算。空数据保留一页及 `current: 1`，不发导航回调；其他 current 须在 1..totalPages 内，否则抛 `RangeError`。禁用、边界及当前页激活不通知，有效动作仅提议且不本地提交。省略号跳五页并限制在页范围内，最大整数边界不会溢出。紧凑布局按页码和省略号各自渲染字体的实测宽度、文字缩放、解析后间距和实际约束决定；RTL 箭头反向，320px/200% 下仍可操作。

## 定制

在 `style` 或 `AnimalIslandTheme.components.pagination` 使用 `AnimalPaginationStyle`，每个字段按实例 > 组件主题 > token 默认值解析。null 继承下层，局部 TextStyle 按属性合并。非法尺寸、insets、圆角、字号 在 debug/release 一致抛 `ArgumentError`。这组组件没有尺寸预设，动作的 48px 命中下限保持固定。

| 字段 | 渲染决策 |
| --- | --- |
| `backgroundColor` | 背景填充。 |
| `selectedBackgroundColor` | 选中项填充。 |
| `disabledBackgroundColor` | 禁用项填充。 |
| `borderRadius` | 圆角。 |
| `padding` | 内边距。 |
| `gap` | 相邻项间距。 |
| `textStyle` | 文字样式。 |
| `ellipsisTextStyle` | 省略号文字样式。 |
| `textColor` | 文字颜色；支持的交互状态见组件行为。 |
| `ellipsisTextColor` | 省略号文字颜色。 |
| `selectedTextColor` | 选中项文字颜色。 |
| `disabledTextColor` | 禁用项文字颜色。 |
| `iconSize` | 图标大小。 |
| `shadow` | 阴影。 |
| `depth` | 按下时的位移。 |
