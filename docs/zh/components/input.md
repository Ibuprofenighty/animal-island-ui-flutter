<!-- generated:api:start -->
# AnimalInput

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalInput`

## 属性
- `autofocus`
- `clearable`
- `controller`
- `disabled`
- `focusNode`
- `inputFormatters`
- `keyboardType`
- `maxLines`
- `minLines`
- `obscureText`
- `onChanged`
- `onSubmitted`
- `placeholder`
- `prefix`
- `readOnly`
- `shadow`
- `size`
- `status`
- `style`
- `suffix`
- `textInputAction`

## 枚举
- `AnimalInputSize`
- `AnimalInputStatus`

<!-- generated:api:end -->

## 本地化
调用方必须提供一个稳定的 `TextEditingController`，并在 owner 生命周期结束时负责 dispose。
`AnimalInput` 借用该 controller、跟随 controller 替换且不会 dispose 它。完整
`TextEditingValue` 会保留 selection 和 IME composing 状态。`onChanged` 只向调用方报告用户编辑；
Form 直接观察同一个 controller，无需该回调再写入第二份值。

清除操作标签使用生成的 AnimalLocalizations。placeholder、前缀、后缀和输入内容仍由调用方提供。
清除操作只写入一次借用的 controller，并只调用一次 `onChanged`；只读输入不显示清除操作。

## 交互与无障碍

文本编辑由底层 `TextField` 处理。清除操作响应指针点击，并在获得焦点时响应 Enter 或 Space。传入的 `FocusNode` 仍归调用方所有，输入框会跟随替换后的节点。

错误状态会在文本框语义中标记为校验无效。`AnimalFormItem` 提供的可见标签和校验消息仍对辅助技术可见，placeholder 作为文本框提示保留。普通输入不会添加厚重的底部阴影，除非显式启用 `shadow`；不同尺寸下前后缀都位于可编辑区域之外。尺寸高度是最小高度。大字号缩放时，前后缀限制在可用宽度的一部分并可换行，输入框随之增高；文字不会缩小，可编辑区域也不会被遮挡。

## 定制

`style` 接受 `AnimalInputStyle`，只覆盖当前输入框。主题的 `components.input`
（`AnimalInputThemeData`）提供通用 `style`，以及可选的 `smallStyle`、
`middleStyle`、`largeStyle`。未设置的字段回落到由当前 token 推导的默认值：
文字为 `typography.body` 按尺寸乘以 13/14、15/14 或 17/14；聚焦边框使用库统一的焦点色。

颜色（包括 `borderColor` 与 `glowColor`）按 `WidgetState.disabled`、`focused`、
`error` 解析；warning 状态使用 `warningColor`。

触发器边框与光晕遵循 Input、Select、DatePicker、TimePicker 共用的同一规则。禁用的
触发器使用样式边框，否则浅色主题使用 `borderLight`、深色主题使用 30% 透明度的
`border`，且没有光晕。warning 状态使用 `warningColor`，否则使用 `warningText`；error
优先于 warning。其余情况使用样式边框，否则 error 使用 `errorText`，聚焦时使用焦点环
颜色，静止时使用 `border`。没有状态的静止触发器没有光晕；其余情况的光晕为样式光晕色，
否则仅聚焦时为 45% 透明度的边框色，error 或 warning 时为 35%，模糊半径 4、扩散半径 2。

清除操作是包内共用的图标操作：48 逻辑像素目标、焦点环、本地化的清除标签作为无障碍名称，
以及按 `WidgetState.hovered` 解析的悬停填充（来自 `clearButtonBackgroundColor`）；
减少动态效果时填充立即切换。`clearIconSize` 按 small、middle、large 尺寸默认为 14、16、18，
`clearButtonPadding` 默认为两侧各 `spacing.xs`，`clearButtonBorderRadius` 默认为胶囊形，
`clearButtonBackgroundColor` 默认为透明。

## 示例
参见示例 Gallery 中的 [`input_story.dart`](../../../example/lib/stories/input_story.dart)。
