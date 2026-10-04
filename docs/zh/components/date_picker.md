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

<!-- generated:api:end -->

## Civil 日期与选择值

`AnimalDate` 表示公历 1–9999 年的 Civil 日期，日历序数负责日期运算，因此加一天不依赖本机时区的 24 小时长度。`AnimalDate.fromDateTime()` 保留输入对象提供的年、月、日字段；`toDateTime()` 返回相同年月日的 UTC 零点。非法年份、月份或日构造抛出 `ArgumentError.value`；算术超出支持年份范围时在 debug/release 模式下均抛出 `RangeError`。支持范围之外的日历格是不可操作的占位格。

`AnimalDatePickerMode.date`、`.range`、`.month` 通过 `mode` 选择，默认值为 `.date`。三种模式共用一个受控的 `AnimalDateSelection? selection` 和一个 `ValueChanged<AnimalDateSelection?>? onChanged` 提议回调。`AnimalDateSelection.date(...)` 创建 `AnimalDateSingleSelection`；`AnimalDateSelection.range(start:, end:)` 创建 `AnimalDateRangeSelection`。范围模式中 `end == null` 表示由外部 owner 持有的起点草稿；选择结束日期后才提出完整范围。范围构造器拒绝早于起点的终点，并抛出 `ArgumentError.value`。月份模式复用单日期变体，所选日期必须是当月 1 日。`mode` 与 `selection` 不匹配时抛出 `ArgumentError.value`；`firstDate` 晚于 `lastDate` 时抛出 `ArgumentError`。

父级始终是已提交选择值的唯一 owner。父级将接受的提议回传为 `selection` 后，面板才显示该值；如果 `selection` 保持不变，选择器继续显示原外部值，不保留乐观的第二当前值。inline 与 popover 共用同一 calendar model 和 panel。`CalendarModel` 显式接收 `today`；`AnimalDate.today()` 与两种呈现均使用 package 的规范 `AnimalClock`/`SystemClock` 路径。

## 默认值与主题

inline `AnimalDatePicker` 默认 `mode: AnimalDatePickerMode.date`、空 selection、`showToday: true`、`allowClear: true`、`disabled: false` 和 `clock: const SystemClock()`。边界、`disabledDate`、回调与 `focusNode` 均可选。`AnimalDatePicker.popover(...)` 使用相同默认值，并增加可选的调用方 `placeholder` 和 `status`；`status` 默认为 `AnimalInputStatus.normal`。未提供 placeholder 时，单日期/月模式显示本地化单日期提示，range 模式显示本地化范围提示。触发器按外部选择值显示日期或范围。

Today 在 date 模式提出当前 Civil 日期，在 range 模式提出受控起点草稿，在 month 模式提出当月首日。若目标超出包含式边界或命中 `disabledDate`，Today 会禁用；整个控件禁用时不产生回调。存在选择值时，Clear 只提出一次 null。popover 中 Clear 会关闭菜单并将焦点还给触发器；完整的日期/月选择或范围也会关闭，范围起点草稿则保持打开。

共用 panel 宽 300 逻辑像素，使用 `bgContent`、`cardBorder`、`spacing.md` 内边距及 1.5 像素边框（深色主题使用 `border`，浅色主题使用 `borderLight`）。区块间距使用 `spacing.sm`，紧凑网格/页脚间距使用 `spacing.xs`。日期和月份文字使用 13 像素 body 字体；星期与页脚文字使用 caption 字体；标题使用 15 像素 heading 字体。单日期选择使用 `primary`/`onPrimary`；月份选择使用同色，并以 `primaryActive` 作边框。范围端点使用 `warning`/`onWarning`，范围内部使用 18% 透明度的 `warning`。日期列宽至少为 48 逻辑像素，并按最宽日期文字（另加 12 像素横向内边距）或星期文字扩展；日期格高度为 `max(48, 实测日期排版高度 + 12)`，星期行高度为 `max(24, 实测 caption 排版高度)`。唯一测量使用当前主题文字样式和 `MediaQuery` 文字缩放，同时纳入 paragraph 尺寸与居中 selection box 外伸，使字体排版保持在单元格内。月份格至少为 86×48 逻辑像素，并按最宽本地化月份文字（宽度另加 12 像素内边距）和实测排版高度（另加上下各 1 像素边框的内缩预算）扩展。默认文字尺寸下，日期格为 48×48、星期格为 48×24、月份格为 86×48。尺寸会按文字自适应，没有公开的几何自定义参数。popover trigger 使用 `bgInput`；禁用时深色主题使用 `surfaceHeader`，浅色主题使用 `bgInputDisabled`。正常状态使用主题暗/浅边框；error/warning 分别使用对应颜色和 35% 光晕，focus 使用 45% 光晕的 `focusYellow`。日历布局仍共用同一 panel。

## 本地化
默认提示和底部操作使用生成的 AnimalLocalizations；日期显示、月份名称、星期标签、导航标签和日期单元格语义遵循当前 Material 语言。传入的 placeholder 仍由调用方提供。

## 交互与无障碍

日期格至少满足 48 逻辑像素的命中尺寸。宽度为 320 逻辑像素时，共用 panel 通过可访问的横向视口呈现七列日期格，不会将单元格缩小到最小尺寸以下；文字较大时列宽和行高会增大。inline 内容超出可用高度时使用宿主页的纵向滚动布局；popover 使用菜单原生的纵向视口。视口移动时键盘焦点保持可见。公历范围外的单元格没有文字、语义或焦点。禁用日期不能作为范围端点，也不能被包含在已完成的范围内。反向选择第二个端点时，范围按升序提交。范围完成后，下一次选日以 `end == null` 开始新范围；父级拒绝提议时，已提交显示保持不变。范围只有两个端点带 selected 语义。

日期格方向键的目标是移动 1 天或 7 天；Home/End 的目标是当前周的周日/周六，在公历第 1 年或第 9999 年边界夹入支持范围。目标日期禁用时，焦点只在目标月份的 42 格网格内沿移动方向搜索；若网格内没有可用目标，焦点保持原位，仍可通过 PageUp/PageDown 或标题控件切换月份。PageUp/PageDown 切换月份；Shift+PageUp/Shift+PageDown 切换年份，并将日期夹到目标月份末日。月份格在同一横向视口中固定为三列，列间使用 `spacing.xs`。水平箭头移动 1 个月，垂直箭头移动 3 个月；Home/End 从一月/十二月边界向内寻找最近可用月份。PageUp/PageDown 在支持的边界内切换年份，并聚焦最近可用月份。月份模式的年份按钮采用相同的最近可用月份规则，仅在目标年份没有可用月份时禁用。日期格标题导航将键盘基准同步到显示月份，不改变父级受控选择。其他箭头目标禁用时沿移动方向跳过。RTL 中左右键依照屏幕物理方向移动。Enter/Space 激活已聚焦操作。Escape 或点击外部关闭 popover；完整范围关闭 popover，范围起点草稿仍保持打开。Clear 后焦点回到 popover trigger。

## 示例
参见示例 Gallery 中的 [`date_picker_story.dart`](../../../example/lib/stories/date_picker_story.dart)。
