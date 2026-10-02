<!-- generated:api:start -->
# AnimalTypewriter

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTypewriter`

## 属性
- `clock`
- `onComplete`
- `showCursor`
- `speed`
- `style`
- `text`
- `textAlign`
- `visible`

<!-- generated:api:end -->

## 本地化
text 由调用方提供。传入组件前应完成本地化；无障碍语义会播报完整的调用方文本。

逐字显示与可选光标共用组件持有的运动调度器。应用进入后台、`TickerMode` 禁用、启用减少动画、文本获得焦点/鼠标悬停，或调用方将 `visible` 设为 `false` 时，两者都会暂停。`visible` 只控制周期工作，不隐藏布局。恢复后从当前字素继续，不补播暂停期间的步进。

可注入 `AnimalClock`，在确定性测试中控制逐字显示的已用时间；默认 `SystemClock` 使用单调时钟测量时间间隔。

## 示例
参见示例 Gallery 中的 [`typewriter_story.dart`](../../../example/lib/stories/typewriter_story.dart)。
