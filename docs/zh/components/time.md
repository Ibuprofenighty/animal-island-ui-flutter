<!-- generated:api:start -->
# AnimalTime

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTime`
- `AnimalTime.live`

## 属性
- `liveRegion`
- `style`
- `visible`

<!-- generated:api:end -->

`AnimalClock` 和默认实现 `SystemClock` 是 root 公共类型。`FakeClock` 仅供测试使用，
不属于 package API。

## 固定时间与实时时间

`AnimalTime(time: ...)` 显示给定时间，且永不改变。`AnimalTime.live(clock: ...)` 显示
其时钟的当前时间，并在墙钟进入下一秒时恰好跳到下一秒。减少动态效果偏好不会停止实时
时间。应用进入后台、其 `TickerMode` 禁用或调用方将 `visible` 设为 `false` 时暂停
（`visible` 只控制更新，不隐藏布局）；恢复后再次显示当前时间，不补播错过的秒数。

读屏在读到卡片时读出时间。`liveRegion: true` 时播报变化；播报的值精确到分钟，因此
实时卡片每分钟最多播报一次。

## 定制

`style` 接收 `AnimalTimeStyle`，覆盖该卡片的主题；主题的 `components.time` 作用于所有
卡片。未设置的字段回退到 token：卡片水平内边距为 `spacing.lg + spacing.xxs`、垂直为
`spacing.md`，填充为 `colors.bgContent`，边框为 1.5 逻辑像素的 `colors.border`，圆角为
`radii.card`；时间使用 `colors.text` 的 `typography.heading`（0.9 倍）；20 逻辑像素的
时钟图标使用 `colors.primaryText`，与时间相距 `spacing.sm`。

## 本地化
时钟显示使用 `intl` 根据当前语言选择的 `Hms` 格式。无障碍标签来自生成的
`currentTimeLabel` 文案，是否播报仍由 `liveRegion` 控制。

## 示例
参见示例 Gallery 中的 [`time_story.dart`](../../../example/lib/stories/time_story.dart)。
