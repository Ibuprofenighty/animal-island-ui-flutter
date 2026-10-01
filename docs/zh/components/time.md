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

<!-- generated:api:end -->

`AnimalClock` 和默认实现 `SystemClock` 是 root 公共类型。`FakeClock` 仅供测试使用，
不属于 package API。

## 本地化
时钟显示使用 `intl` 根据当前语言选择的 `Hms` 格式。无障碍标签来自生成的
`currentTimeLabel` 文案，是否播报仍由 `liveRegion` 控制。

## 示例
参见示例 Gallery 中的 [`time_story.dart`](../../../example/lib/stories/time_story.dart)。
