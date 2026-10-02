<!-- generated:api:start -->
# AnimalTime

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTime`

## 属性
- `clock`
- `live`
- `liveRegion`
- `time`
- `visible`

<!-- generated:api:end -->

`AnimalClock` 和默认实现 `SystemClock` 是 root 公共类型。`FakeClock` 仅供测试使用，
不属于 package API。

实时显示使用单一功能读数注册，不受减少动画偏好影响。应用进入后台、其 `TickerMode` 禁用或调用方将 `visible` 设为 `false` 时会暂停；`visible` 只控制更新，不隐藏布局。重新活跃后根据 `clock.now()` 刷新；播报更新仍只由 `liveRegion` 控制。

## 本地化
时钟显示使用 `intl` 根据当前语言选择的 `Hms` 格式。无障碍标签来自生成的
`currentTimeLabel` 文案，是否播报仍由 `liveRegion` 控制。

## 示例
参见示例 Gallery 中的 [`time_story.dart`](../../../example/lib/stories/time_story.dart)。
