<!-- generated:api:start -->
# AnimalSwitch

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalSwitch`

## 属性
- `checkedChildren`
- `disabled`
- `focusNode`
- `loading`
- `onChanged`
- `readOnly`
- `size`
- `style`
- `unCheckedChildren`
- `value`

## 枚举
- `AnimalSwitchSize`

<!-- generated:api:end -->

## 本地化
开关无障碍标签使用生成的 AnimalLocalizations。checkedChildren 和 unCheckedChildren 仍由调用方提供。

## 自适应标签布局

按 N15 目标布局，内置 `small` 和 `defaultSize` 预设分别规定 46×26、58×32 的药丸轨道最小尺寸。轨道必须使用内阴影且没有外阴影；带边框的 thumb 保持平面。thumb 直径为 18/24 逻辑像素；轨道边框为 1.5 逻辑像素，thumb 边框为 1.2 逻辑像素，标签/thumb 间距为 4 逻辑像素。这些是预设的默认值；`AnimalSwitchStyle` 可覆盖它们（见“定制”）。调用方提供的 `checkedChildren` 和 `unCheckedChildren` 各挂载一次，并在 thumb 旁的轨道空余区域共用一个稳定尺寸的标签区域。两种标签使用相同的受限布局，其实际内容尺寸共同确定可容纳任一状态的区域。轨道连同 thumb 和内边距一起自适应扩展，因此切换 `value` 不会改变轨道尺寸。过渡时，旧标签先淡出，thumb 移动期间标签区域保持空白，抵达后新标签再淡入。非活动标签会视觉隐藏，并从语义、焦点、指针激活和 ticker 活动中排除。

`small`/`defaultSize` 标签文本默认字号分别为 11/13 逻辑像素，并使用预设粗体；主题提供实际使用的字体族、回退字体、行高和字距，当前 switch 状态提供文字颜色。系统当前 `TextScaler` 仍生效，调用方可用 `Text.style` 显式覆盖这些默认值。文字不会为适配而缩小或省略；两个标签使用相同可用空间，宽度受限时自然换行，外轨道随之增高，文本缩放至 200% 时也如此。thumb 在整条轨道两端的内边距之间移动；标签与 thumb 的布局和移动方向遵循文本方向。外层焦点轮廓沿扩大的轨道显示；交互区域至少提供 48×48 逻辑像素的命中区域。Switch 轨道与 thumb 是由用户操作触发的有限时长过渡，其 N10 共享动效政策尊重系统减少动画偏好、`TickerMode` 和应用前后台；政策关闭动效时持续时间为零。焦点只控制轮廓，不会禁用这些过渡。

## 有限宽度

`AnimalSwitch` 必须收到有限的 `maxWidth`。在有界 `Row` 中，将它放入 `Flexible`，或用 `ConstrainedBox` 提供有限约束。用于横向滚动时，在滚动容器之前放置 `LayoutBuilder` 读取实际有限 viewport 宽度，再通过包住 Switch 的 `ConstrainedBox` 传入该上限。无界宽度会被拒绝。

## 受控状态与交互

`value` 由调用方持有，`onChanged` 提议切换为相反值。调用方接受更新并以新值重建前，开关始终显示传入值。`disabled` 和 `loading` 会阻止焦点与激活。`readOnly` 阻止激活，但开关仍可聚焦，并提供只读语义且不暴露 tap action；即使 `onChanged` 为 null 也如此。未设置 `readOnly` 时，null callback 表现为禁用。指针、Enter/Space 和无障碍激活每次至多发出一次提议；命中区域至少为 48×48 逻辑像素。

## 定制

`style` 接受 `AnimalSwitchStyle`，只覆盖当前开关。主题的 `components.switchControl`
（`AnimalSwitchThemeData`）提供通用 `style`，以及可选的 `smallStyle`、
`defaultSizeStyle`。未设置的字段回落到上述默认值：标签文字为粗体
`typography.body` 按尺寸乘以 11/14 或 13/14，轨道保持胶囊圆角与
`shadows.softElevation` 内阴影，焦点轮廓使用库统一的焦点色。

轨道、边框、thumb、标签和加载指示器颜色按 `WidgetState.selected`（开启）与
`WidgetState.disabled` 解析；已开启标签按 selected 解析。thumb 内缩为
`height` 与 `thumbSize` 之差的一半，加载指示器直径为 thumb 的 0.6 倍。

## 示例
参见示例 Gallery 中的 [`switch_story.dart`](../../../example/lib/stories/switch_story.dart)。
