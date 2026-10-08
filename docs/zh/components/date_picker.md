<!-- generated:api:start -->
# AnimalDatePicker

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalDatePicker`

## 属性
- `allowClear`
- `clock`
- `disabled`
- `disabledDate`
- `firstDate`
- `focusNode`
- `lastDate`
- `mode`
- `onChanged`
- `selection`
- `showToday`
- `style`

<!-- generated:api:end -->

## Civil 日期与选择值

`AnimalDate` 表示公历 1–9999 年的 Civil 日期，日历序数负责日期运算，因此加一天不依赖本机时区的 24 小时长度。`AnimalDate.fromDateTime()` 保留输入对象提供的年、月、日字段；`toDateTime()` 返回相同年月日的 UTC 零点。非法年份、月份或日构造抛出 `ArgumentError.value`；算术超出支持年份范围时在 debug/release 模式下均抛出 `RangeError`。支持范围之外的日历格是不可操作的占位格。

`AnimalDate` 成员：`year`、`month`、`day`、`weekday`（1 为周一）、`AnimalDate.minimumYear`/`maximumYear`、
`AnimalDate.daysInMonth(year, month)`、`AnimalDate.today({clock})`、`AnimalDate.fromDateTime`、`toDateTime()`、
`addDays`/`subtractDays`、`isBefore`/`isAfter`/`compareTo` 与 `toIso8601String()`（也是其 `toString`）；年月日相同的两个日期相等。
`AnimalDateSingleSelection.date` 与 `AnimalDateRangeSelection.start`/`end` 保存选择值，`isCompatibleWith(mode)` 判断其是否适用于某个选择模式。

`AnimalDatePickerMode.date`、`.range`、`.month` 通过 `mode` 选择，默认值为 `.date`。三种模式共用一个受控的 `AnimalDateSelection? selection` 和一个 `ValueChanged<AnimalDateSelection?>? onChanged` 提议回调。`AnimalDateSelection.date(...)` 创建 `AnimalDateSingleSelection`；`AnimalDateSelection.range(start:, end:)` 创建 `AnimalDateRangeSelection`。范围模式中 `end == null` 表示由外部 owner 持有的起点草稿；选择结束日期后才提出完整范围。范围构造器拒绝早于起点的终点，并抛出 `ArgumentError.value`。月份模式复用单日期变体，所选日期必须是当月 1 日。`mode` 与 `selection` 不匹配时抛出 `ArgumentError.value`；`firstDate` 晚于 `lastDate` 时抛出 `ArgumentError`。

父级始终是已提交选择值的唯一 owner。父级将接受的提议回传为 `selection` 后，面板才显示该值；如果 `selection` 保持不变，选择器继续显示原外部值，不保留乐观的第二当前值。inline 与 popover 共用同一 calendar model 和 panel。`CalendarModel` 显式接收 `today`；`AnimalDate.today()` 与两种呈现均使用 package 的规范 `AnimalClock`/`SystemClock` 路径。

## 默认值与主题

inline `AnimalDatePicker` 默认 `mode: AnimalDatePickerMode.date`、空 selection、`showToday: true`、`allowClear: true`、`disabled: false` 和 `clock: const SystemClock()`。边界、`disabledDate`、回调与 `focusNode` 均可选。`AnimalDatePicker.popover(...)` 使用相同默认值，并增加可选的调用方 `placeholder` 和 `status`；`status` 默认为 `AnimalInputStatus.normal`。未提供 placeholder 时，单日期/月模式显示本地化单日期提示，range 模式显示本地化范围提示。触发器按外部选择值显示日期或范围。

Today 在 date 模式提出当前 Civil 日期，在 range 模式提出受控起点草稿，在 month 模式提出当月首日。若目标超出包含式边界或命中 `disabledDate`，Today 会禁用；整个控件禁用时不产生回调。存在选择值时，Clear 只提出一次 null。popover 中 Clear 会关闭菜单并将焦点还给触发器；完整的日期/月选择或范围也会关闭，范围起点草稿则保持打开。

共用 panel 首选宽度为 300 逻辑像素，父级给出更窄宽度时随之收窄；使用 `bgContent`、`cardBorder`、`spacing.md` 内边距及 1.5 像素边框（深色主题使用 `border`，浅色主题使用 `borderLight`）。区块间距使用 `spacing.sm`，紧凑网格/页脚间距使用 `spacing.xs`。日期和月份文字使用 `typography.body` 乘以 13/14（标准字体下为 13 像素）；星期与页脚文字使用 caption 字体；标题使用 `typography.heading` 乘以 15/20（15 像素）。单日期选择使用 `primary`/`onPrimary`；月份选择使用同色，并以 `primaryActive` 作边框。范围端点使用 `warning`/`onWarning`，范围内部使用 18% 透明度的范围色。日期列宽至少为 48 逻辑像素，并按最宽日期文字（另加两倍 6 像素单元格内缩）或星期文字扩展；日期格高度为 `max(48, 实测日期排版高度 + 2 × 单元格内缩)`，星期行高度为 `max(24, 实测 caption 排版高度)`。唯一测量使用解析后的文字样式和 `MediaQuery` 文字缩放，同时纳入 paragraph 尺寸与居中 selection box 外伸，使字体排版保持在单元格内。月份格至少为 86×48 逻辑像素，并按最宽本地化月份文字（宽度另加两倍单元格内缩）和实测排版高度（另加上下各一个月份边框宽度，默认 1 像素）扩展。默认文字尺寸下，日期格为 48×48、星期格为 48×24、月份格为 86×48。panel 过窄、无法在一行放下导航按钮和 48 像素标题位时，标题移到导航上方，导航按钮换行且保持 48 像素目标；日期与月份网格可横向滚动，大字号放不下时 Today 与 Clear 分行显示。popover trigger 使用 `bgInput`；禁用时深色主题使用 `surfaceHeader`，浅色主题使用 `bgInputDisabled`。其边框与光晕遵循“定制”一节所述的字段触发器规则。日历布局仍共用同一 panel。

## 本地化
默认提示和底部操作使用生成的 AnimalLocalizations；日期显示、月份名称、星期标签、导航标签和日期单元格语义遵循当前 Material 语言。传入的 placeholder 仍由调用方提供。

## 交互与无障碍

日期格至少满足 48 逻辑像素的命中尺寸。宽度为 320 逻辑像素时，共用 panel 通过可访问的横向视口呈现七列日期格，不会将单元格缩小到最小尺寸以下；文字较大时列宽和行高会增大。inline 内容超出可用高度时使用宿主页的纵向滚动布局；popover 使用菜单原生的纵向视口。视口移动时键盘焦点保持可见。公历范围外的单元格没有文字、语义或焦点。禁用日期不能作为范围端点，也不能被包含在已完成的范围内。反向选择第二个端点时，范围按升序提交。范围完成后，下一次选日以 `end == null` 开始新范围；父级拒绝提议时，已提交显示保持不变。范围只有两个端点带 selected 语义。

日期格方向键的目标是移动 1 天或 7 天；Home/End 的目标是当前周的周日/周六，在公历第 1 年或第 9999 年边界夹入支持范围。目标日期禁用时，焦点只在目标月份的 42 格网格内沿移动方向搜索；若网格内没有可用目标，焦点保持原位，仍可通过 PageUp/PageDown 或标题控件切换月份。PageUp/PageDown 切换月份；Shift+PageUp/Shift+PageDown 切换年份，并将日期夹到目标月份末日。月份格在同一横向视口中固定为三列，列间使用 `spacing.xs`。水平箭头移动 1 个月，垂直箭头移动 3 个月；Home/End 从一月/十二月边界向内寻找最近可用月份。PageUp/PageDown 在支持的边界内切换年份，并聚焦最近可用月份。月份模式的年份按钮采用相同的最近可用月份规则，仅在目标年份没有可用月份时禁用。日期格标题导航将键盘基准同步到显示月份，不改变父级受控选择。其他箭头目标禁用时沿移动方向跳过。RTL 中左右键依照屏幕物理方向移动。Enter/Space 激活已聚焦操作。Escape 或点击外部关闭 popover；完整范围关闭 popover，范围起点草稿仍保持打开。Clear 后焦点回到 popover trigger。

## 定制

`style` 接受 `AnimalDatePickerStyle`，只覆盖当前选择器；`AnimalDatePicker.popover`
接受同一个 `style`，作用于触发器、菜单和 panel。主题的 `components.datePicker`
是作用于所有选择器的 `AnimalDatePickerStyle`（没有尺寸预设）。优先级为实例
style、主题 style、再到由当前 token 推导的默认值：标题为 `typography.heading`
乘以 15/20，日期和月份文字为 `typography.body` 乘以 13/14，星期与页脚文字跟随
`typography.caption`，聚焦的触发器使用库统一的焦点色。文字样式逐字段合并，
部分覆盖会保留下层设置。

几何字段为 `width`（父级更窄时仍以父级为准）、`padding`（类型为
`EdgeInsetsGeometry`，start/end 内边距随文字方向）、`borderWidth`、
`borderRadius`、`cellInset`、`rangeBorderRadius`、`monthBorderWidth`、
`monthBorderRadius`、`navigationIconSize`（年份图标为其 18/20）、
`triggerIconSize`、`triggerBorderRadius`、`triggerHorizontalPadding` 和
`triggerIconGap`。间距字段为 `sectionGap`（标题到网格、网格到页脚分隔线，默认
`spacing.sm`）、`footerGap`（分隔线到操作，`spacing.xs`）、`cellGap`（月份格之间、
日期行之间以及星期行下方，`spacing.xs`）和 `actionHorizontalPadding`（Today 与
Clear 内部，`spacing.sm`）。文字字段为 `headerTextStyle`、`weekdayTextStyle`、
`cellTextStyle`、`actionTextStyle` 和 `triggerTextStyle`；选中格与今天保持粗体，
今天保留下划线。`cellTextColor` 按 `WidgetState.selected` 与 `disabled` 解析；
`headerTextColor`、`todayTextColor`、`clearTextColor`、`triggerBackgroundColor`、
`triggerTextColor`、`triggerIconColor` 按 `disabled` 解析；`monthBorderColor`
按 `selected` 解析；触发器上的 `borderColor` 按 `focused`、`error`、`disabled`
解析。选中填充为 `selectedBackgroundColor`；范围端点使用 `rangeBackgroundColor`
与 `rangeTextColor`，非本月日期使用 `outsideMonthTextColor`，星期文字使用
`weekdayTextColor`，空触发器使用 `placeholderTextColor`，warning 状态使用
`warningColor`，触发器光晕使用按 `focused` 与 `error` 解析的 `glowColor`。48 像素目标、
86 像素月份最小宽度、24 像素星期行、三列月份网格和 18% 范围填充保持固定。

触发器边框与光晕遵循 Input、Select、DatePicker、TimePicker 共用的同一规则。禁用的
触发器使用样式边框，否则浅色主题使用 `borderLight`、深色主题使用 30% 透明度的
`border`，且没有光晕。warning 状态使用 `warningColor`，否则使用 `warningText`；error
优先于 warning。其余情况使用样式边框，否则 error 使用 `errorText`，聚焦时使用焦点环
颜色，静止时使用 `border`。没有状态的静止触发器没有光晕；其余情况的光晕为样式光晕色，
否则仅聚焦时为 45% 透明度的边框色，error 或 warning 时为 35%，模糊半径 4、扩散半径 2。

清除控件是包内共用的图标操作：48 逻辑像素目标、焦点环、本地化的清除标签作为无障碍名称，
关闭图标使用 `triggerIconSize` 与 `triggerIconColor`，悬停填充来自按 `WidgetState.hovered`
解析的 `triggerClearButtonBackgroundColor`；减少动态效果时填充立即切换。
`triggerClearButtonPadding` 默认为零，`triggerClearButtonBorderRadius` 默认为胶囊形，
`triggerClearButtonBackgroundColor` 默认为透明。

## 示例
参见示例 Gallery 中的 [`date_picker_story.dart`](../../../example/lib/stories/date_picker_story.dart)。
