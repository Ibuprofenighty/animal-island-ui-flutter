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
- `readOnly`
- `status`
- `style`
- `value`

<!-- generated:api:end -->

## 本地化
placeholder 为 null 时，选择器使用生成的本地化默认提示。选项标签仍由调用方提供。清除操作使用生成的 AnimalLocalizations；显式 placeholder 仅覆盖默认提示。

## 受控状态与交互

`value` 由调用方持有，`onChanged` 报告选项值提议。选项会复制为不可变快照，并拒绝重复的 `option.value`。未知的非 null 值会原样保留：触发器显示显式 placeholder 或本地化默认提示，并暴露 invalid 语义，直到调用方传入已知值或接受清除提议。

`readOnly` 下触发器仍可聚焦并提供只读语义，但不会打开菜单或清除值。未设置 `readOnly` 时，null callback 表现为禁用。菜单使用有界 lazy list；延后的焦点处理会重新检查当前选项身份和可用状态。Arrow Up/Down 与 Home/End 在可用选项间移动。选择选项会提议其值、关闭菜单并将焦点还给触发器。启用 `allowClear` 后，清除动作支持指针及 Enter/Space，只提议一次 `null`，并将焦点还给触发器。命中区域至少为 48 逻辑像素。

触发器标签使用主题 body style 乘以 15/14（标准 14 逻辑像素正文时为 15 逻辑像素），文字颜色随状态变化。系统当前 `TextScaler` 仍生效。

## 自适应菜单布局

所有选项行共用一个自适应 extent：至少 48 逻辑像素，并足以容纳解析后的选项文字样式在系统 `TextScaler` 下的两行文字及选项垂直内边距。标签最多显示两行，溢出时使用省略号；每个选项的命中区域至少为 48×48 逻辑像素。主题 token 提供菜单表面色、边框色、行文字和状态色、排版、圆角与间距的默认值。菜单宽度和列表视口高度分别受 `menuMaxWidth` 与 `menuMaxHeight` 限制（默认 320 逻辑像素）；宽度还受可用视口宽度减 24 逻辑像素约束，高度按选项行计算并受此上限约束。列表在 1,000 个选项时仍保持有界 lazy 构建。

## 定制

`style` 接收 `AnimalSelectStyle`，覆盖该选择器的主题设置。主题的
`components.select` 本身就是一个 `AnimalSelectStyle`，作用于所有选择器；Select
没有尺寸预设。未设置的字段回落到由当前 token 推导的默认值：触发器标签为
`typography.body` 乘以 15/14，选项标签为 `typography.body`，聚焦或展开时的边框使用库统一的焦点色。

触发器颜色按 `WidgetState.disabled`、`focused`（聚焦或菜单展开）、`error`
（error 状态或未知值）与 `selected`（值匹配某个选项）解析；选项颜色按
`disabled`、`selected`、`hovered`、`focused` 解析。warning 状态在选择器上没有视觉表现。
无论样式如何，选项行最小高度与命中区域保持 48 逻辑像素。

## 示例
参见示例 Gallery 中的 [`select_story.dart`](../../../example/lib/stories/select_story.dart)。
