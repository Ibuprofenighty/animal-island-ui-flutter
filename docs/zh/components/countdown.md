<!-- generated:api:start -->
# AnimalCountdown

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCountdown`

## 属性
- `bordered`
- `clock`
- `format`
- `onChange`
- `onFinish`
- `prefix`
- `remaining`
- `size`
- `targetTime`
- `variant`
- `visible`

## 枚举
- `AnimalCountdownSize`
- `AnimalCountdownVariant`

<!-- generated:api:end -->

`AnimalClock` 和默认实现 `SystemClock` 是 root 公共类型。`FakeClock` 仅供测试使用，
不属于 package API。

`targetTime` 表示墙钟截止时间；组件创建或时间输入更新时，`remaining` 只转换为一个墙钟截止时间。减少动画不会停掉功能读数；应用进入后台、`TickerMode` 禁用或调用方将 `visible` 设为 `false` 时，更新注册会暂停。`visible` 只控制周期更新，不隐藏布局；重新活跃后根据 `clock.now()` 重算，不按漏掉的 tick 数递减。

## 本地化
各时间单位使用生成的 `countdownUnitDays`、`countdownUnitHours`、
`countdownUnitMinutes` 和 `countdownUnitSeconds` 文案；读屏剩余时间使用生成的
复数文案 `countdownRemaining`。

## 示例
参见示例 Gallery 中的 [`countdown_story.dart`](../../../example/lib/stories/countdown_story.dart)。
