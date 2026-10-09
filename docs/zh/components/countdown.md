<!-- generated:api:start -->
# AnimalCountdown

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCountdown`
- `AnimalCountdown.duration`

## 属性
- `bordered`
- `clock`
- `format`
- `onChange`
- `onFinish`
- `prefix`
- `size`
- `style`
- `variant`
- `visible`

## 枚举
- `AnimalCountdownFormat`
- `AnimalCountdownSize`
- `AnimalCountdownVariant`

<!-- generated:api:end -->

`AnimalClock` 和默认实现 `SystemClock` 是 root 公共类型。`FakeClock` 仅供测试使用，
不属于 package API。

## 截止时间

`AnimalCountdown(targetTime: ...)` 倒计时到一个墙钟时间。
`AnimalCountdown.duration(duration: ...)` 在开始时把截止时间固定在时钟的单调时间上，
因此调整墙钟不会移动它。两者使用同一个剩余时间计算。数字块显示向上取整到整秒的剩余
时间，因此只在截止时刻显示 `00`；到达截止时间时 `onFinish` 运行一次。已经过去的截止
时间（包括 0 或负的时长）在首帧之后完成一次。数字块每次变为大于 0 的值时，`onChange`
报告剩余的整秒数。

更改 `targetTime`、`duration` 或 `clock` 会开始新的倒计时；之前倒计时的回调此后不再
运行，即使是在同一帧内安排的回调。

数字块恰好在显示的秒数变化时刷新。减少动态效果不会停止刷新。应用进入后台、`TickerMode`
禁用或调用方将 `visible` 设为 `false` 时暂停刷新（`visible` 只控制刷新，不隐藏布局）；
恢复后显示当前剩余时间，而不是按漏掉的 tick 数递减。这些状态下 `onFinish` 仍在截止时刻
运行。数字块暂停期间调整墙钟时，`targetTime` 截止时间要到其计时器下次触发时才随之移动。

## 格式

`format` 是 `AnimalCountdownFormat`：`daysHoursMinutesSeconds`、
`hoursMinutesSeconds`（默认）、`minutesSeconds` 或 `seconds`。最大单位显示全部剩余量，
不会取模回绕，因此 30 小时显示为 `30` 小时。数字块会变宽以容纳较长的值；在窄容器中
数字块换行显示，而不是溢出。

## 定制

`style` 接收 `AnimalCountdownStyle`，覆盖该倒计时的主题。主题的
`components.countdown` 是 `AnimalCountdownThemeData`，包含通用 `style`，以及优先于它的
`smallStyle`、`middleStyle`、`largeStyle`。未设置的字段回退到 token：数字与分隔符使用
`colors.text` 的 `typography.countdown`（字重 900），small、middle、large 分别缩放
15/28、22/28、1；单位标签使用 `colors.textSecondary` 的加粗 `typography.caption`，
分别缩放 9/12、10/12、11/12；数字块最小为 40×36、54×48、68×60 逻辑像素，圆角基于
`radii.sm`，带 `shadows.input3d`，填充为 `colors.bgContent`（`island` 变体为
`colors.surfaceAlt`）。`bordered` 增加 1.5 逻辑像素的边框。

## 本地化
各时间单位使用生成的 `countdownUnitDays`、`countdownUnitHours`、
`countdownUnitMinutes` 和 `countdownUnitSeconds` 文案；读屏剩余时间使用生成的
复数文案 `countdownRemaining`。

## 示例
参见示例 Gallery 中的 [`countdown_story.dart`](../../../example/lib/stories/countdown_story.dart)。
