<!-- generated:api:start -->
# AnimalSkeleton

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalSkeleton`
- `AnimalSkeleton.avatar`
- `AnimalSkeleton.button`
- `AnimalSkeleton.input`
- `AnimalSkeleton.paragraph`

## 属性
- `active`
- `child`
- `height`
- `loading`
- `rowWidths`
- `rows`
- `style`
- `variant`
- `width`

## 枚举
- `AnimalSkeletonVariant`

<!-- generated:api:end -->

## 占位

`loading` 为 true 时显示占位块；为 false 时显示 `child`，没有 child 时仍显示占位。占位
被播报为加载中，不暴露虚假的文字或控件。

`width` 与 `height` 必须是有限的非负数；`width` 为 null 时文本块与矩形块填满可用宽度。
段落有 `rows` 行（至少 1 行）。`rowWidths` 的每一项是段落宽度的比例（0 到 1），没有
对应项的行在前三行分别使用 1、0.82、0.6，之后使用 1。无效值抛出 `ArgumentError`。
可用宽度无界时，段落宽度为 `width`，否则为 280 逻辑像素。

## 动画

`active` 为 true 时，光泽会扫过占位块。每个骨架屏只有一个动画控制器，可按需反复启停。
`TickerMode` 禁用、减少动态效果以及应用在后台时，它停止，占位块显示纯色填充。

## 定制

`style` 接收 `AnimalSkeletonStyle`，覆盖该骨架屏的主题；各预设接受同样的 `style`，主题的
`components.skeleton` 作用于所有骨架屏。未设置的字段回退到 token：占位块使用
`colors.bgDisabled`，光泽为 `colors.bgInput`（暗色主题为 `colors.surfaceHeader` 与
`colors.surfaceAlt`）；矩形使用 `radii.card` 圆角，`button` 与 `input` 预设为胶囊圆角；
文本行与段落行是 16 逻辑像素高的胶囊，行距为 `spacing.md - spacing.xxs`。未指定尺寸时，
矩形高 100 逻辑像素，圆形宽 44。

## 本地化
Skeleton 处于加载状态时，其无障碍标签使用生成的 `loading` 文案，并随宿主语言切换更新。

## 示例
参见示例 Gallery 中的 [`skeleton_story.dart`](../../../example/lib/stories/skeleton_story.dart)。
