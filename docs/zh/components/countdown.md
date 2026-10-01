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

## 枚举
- `AnimalCountdownSize`
- `AnimalCountdownVariant`

<!-- generated:api:end -->

`AnimalClock` 和默认实现 `SystemClock` 是 root 公共类型。`FakeClock` 仅供测试使用，
不属于 package API。

## 本地化
各时间单位使用生成的 `countdownUnitDays`、`countdownUnitHours`、
`countdownUnitMinutes` 和 `countdownUnitSeconds` 文案；读屏剩余时间使用生成的
复数文案 `countdownRemaining`。

## 示例
参见示例 Gallery 中的 [`countdown_story.dart`](../../../example/lib/stories/countdown_story.dart)。
