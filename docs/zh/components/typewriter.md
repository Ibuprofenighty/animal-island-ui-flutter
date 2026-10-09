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

## 逐字显示

`text` 只排版一次，逐字显示过程中换行与组件尺寸都不会改变。每经过一个 `speed` 的
逐字时间多显示一个 Unicode 字素簇（迟到的 tick 显示所有到期的字素簇），因此 emoji 或带组合音标的字母不会被拆开；`speed` 不为正时
抛出 `ArgumentError`。可选光标画在当前输入位置的文字之上，不占空间，所以 `showCursor`
不会改变换行。组件为每个字素簇只保留一个偏移量，内存随文本线性增长。

`onComplete` 在整段文本可见时对每段文本运行一次：最后一个字素簇显示之后；空文本或减少
动态效果时在首帧之后。更换 `text` 会重新开始逐字显示，并取消上一段文本尚未执行的完成
回调；组件销毁同样会取消它。

应用进入后台、`TickerMode` 禁用、鼠标悬停在文本上、调用方将 `visible` 设为
`false` 时，逐字显示与光标闪烁都会暂停。`visible` 只控制逐字显示，不隐藏布局。恢复后
从当前字素簇继续，不补播暂停期间的步进。减少动态效果时整段文本立即显示。

可注入 `AnimalClock`，在确定性测试中控制逐字显示的已用时间；默认 `SystemClock` 使用
单调时钟测量时间间隔。

## 定制

`style` 接收 `AnimalTypewriterStyle`，覆盖该打字机的主题；主题的
`components.typewriter` 作用于所有打字机。未设置的字段回退到 token：文字使用
`colors.text` 的 `typography.body`；光标是宽 2 逻辑像素、与所在行等高的
`colors.primary` 竖条，每 500 毫秒闪烁一次。

## 本地化
text 由调用方提供。传入组件前应完成本地化；无障碍语义会播报完整的调用方文本。

## 示例
参见示例 Gallery 中的 [`typewriter_story.dart`](../../../example/lib/stories/typewriter_story.dart)。
