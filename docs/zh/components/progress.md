<!-- generated:api:start -->
# AnimalProgress

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalProgress`
- `AnimalProgress.circle`

## 属性
- `animated`
- `diameter`
- `format`
- `infoPosition`
- `percent`
- `showInfo`
- `size`
- `status`
- `striped`
- `style`

## 枚举
- `AnimalProgressInfoPosition`
- `AnimalProgressSize`
- `AnimalProgressStatus`

<!-- generated:api:end -->

## 数值

`percent` 是完成比例。小于 0 或大于 1 的值显示为 0 或 1，非有限值抛出
`ArgumentError`。标签显示向下取整到整数百分比的显示比例；`format` 接收同一个显示比例。读屏把标签作为进度值读出，不做实时播报。横向
进度条与 `AnimalProgress.circle` 共用同一个数值模型、状态颜色与标签。

`infoPosition` 把横向进度条的标签放在右侧、上方、填充内部（进度条至少 14 逻辑像素高
且填充宽于 38 时）或不显示。`AnimalProgress.circle` 接收 `diameter`（默认 120；负值或
非有限值抛出 `ArgumentError`），除非 `showInfo` 为 false，否则在中心显示标签。

## 动画

`active` 状态的进度条条纹会移动，除非 `animated` 或 `striped` 为 false。每个进度条只有
一个动画控制器，可按需反复启停。`TickerMode` 禁用、减少动态效果以及应用在后台时，它停在
第一帧，因此静止的进度条不安排任何帧。

## 定制

`style` 接收 `AnimalProgressStyle`，覆盖该指示器的主题。主题的 `components.progress`
是 `AnimalProgressThemeData`，包含通用 `style`，以及对横向进度条优先于它的
`smallStyle`、`middleStyle`、`largeStyle`；环形使用通用样式。未设置的字段回退到 token：
填充跟随状态（`colors.primary`、`colors.success` 或 `colors.error`）；轨道使用
`colors.bgDisabled`，边框为 1.2 逻辑像素的 `colors.borderLight`（暗色主题为
`colors.surfaceAlt` 与 `colors.border`）；进度条高 8、14 或 22 逻辑像素，环形描边为 10；
条纹为半透明白色。进度条右侧或上方的标签使用 `colors.text` 的加粗 `typography.caption`，
右侧间距 `spacing.md`、上方间距 `spacing.xs + spacing.xxs`；环形标签按直径 / 180 缩放
`typography.digitLarge`；填充内部的标签使用 0.8 倍的 `typography.button`，颜色为状态的
on 色，并带 `shadows.softElevation`。

## 本地化
横向与圆形进度条的内置语义标签分别使用生成的 `progressLabel` 和
`circularProgressLabel` 文案。调用者提供的 `format` 仍控制显示的百分比文本。

## 示例
参见示例 Gallery 中的 [`progress_story.dart`](../../../example/lib/stories/progress_story.dart)。
