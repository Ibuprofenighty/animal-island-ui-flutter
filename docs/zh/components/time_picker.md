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
- `clock`
- `disabled`
- `focusNode`
- `format`
- `hourStep`
- `minuteStep`
- `onChanged`
- `secondStep`
- `showNow`
- `style`
- `value`

<!-- generated:api:end -->

## 时间值与选择

`AnimalTimeValue` 是不可变的一天中的时间，时为 0–23、分为 0–59、秒为 0–59；超出范围的字段抛出 `ArgumentError.value`。选择器保留全部三个字段：隐藏秒滚轮（`format: 'HH:mm'`）时仍保留值中的秒，因此更改时或分、Now、Clear、重置和表单提交都不会丢失秒。`AnimalTimeValue.now()` 读取规范的 `AnimalClock`（默认 `SystemClock`），两种呈现方式使用同一个 `clock`。

`value` 是唯一已提交的时间，`onChanged` 提出新值。父级把提议传回即表示接受；父级不接受的值不会留在滚轮上，滚动停止后滚轮回到 `value`。不在步长上的值显示在最近的步长项上。`hourStep`、`minuteStep` 和 `secondStep` 必须不小于 1，否则抛出 `ArgumentError`。内联与弹出两种呈现共用同一个面板。

程序性滚轮移动（新的 `value`、Now、Clear 或重置为 null）作为一个批次运行，从不报告中间项：Now 只提议一次最终时间，Clear 只提议一次 null，外部变更不提议任何值。新的值或用户拖动会取代正在运行的批次，因此较早的 Now 动画不会在较新的值之后落定。用户滚动仍会提议其停留的每一项。

## 默认值

`AnimalTimePicker` 默认 `format: 'HH:mm'`、各步长为 1、`showNow: true`、`allowClear: true`、`disabled: false`、`clock: const SystemClock()`。`AnimalTimePicker.popover(...)` 使用相同默认值，并增加可选的 `placeholder` 与 `status`（`AnimalInputStatus.normal`）。禁用的选择器锁定滚轮及 Now、Clear 操作，不提议任何值。

## 本地化
默认提示、面板操作和滚轮数值语义使用生成的 AnimalLocalizations，并在语言切换时刷新。传入的 placeholder 仍由调用方提供。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 定制

`style` 接受 `AnimalTimePickerStyle`，只覆盖当前选择器；
`AnimalTimePicker.popover(style: ...)` 将同一样式应用于触发器及其面板。主题的
`components.timePicker` 是一个作用于所有选择器的 `AnimalTimePickerStyle`（没有尺寸预设）。
未设置的字段回落到由当前 token 推导的默认值：标题和滚轮分隔符使用
`typography.heading`，选中滚轮标签使用 `typography.subheading`，其他滚轮标签和触发器文字使用
`typography.body`，“现在”和“清除”标签使用 `typography.caption`，比例均为 1。
聚焦的触发器边框使用库统一的焦点色。

面板颜色按 `WidgetState.disabled` 解析，滚轮标签还按 `WidgetState.selected` 解析。
触发器边框按 `focused`（菜单打开时同样适用）和 `error` 解析；warning 状态使用
`warningColor`，状态或焦点光晕跟随解析后的边框颜色。

`minItemExtent`（默认 36）是最小值：每个滚轮项和选中带会增长到环境文字缩放下较大滚轮标签的
实际渲染高度，`wheelHeight`（默认 160）会增长到至少显示三项，因此大字号或 200% 文字缩放下
标签不会被裁切。页脚标签在面板较窄时缩小而不是溢出。项高度变化时，滚轮重新居中到当前显示的
时间且不提出任何值；用户正在拖动的滚轮保持位置，并在拖动结束时重新居中。

## 示例
参见示例 Gallery 中的 [`time_picker_story.dart`](../../../example/lib/stories/time_picker_story.dart)。
