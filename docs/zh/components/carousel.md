<!-- generated:api:start -->
# AnimalCarousel

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCarousel`

## 属性
- `activeIndex`
- `autoPlay`
- `autoPlayInterval`
- `clock`
- `defaultActiveIndex`
- `height`
- `items`
- `loop`
- `onChange`
- `pauseOnHover`
- `showArrows`
- `showDots`
- `visible`

<!-- generated:api:end -->

## 本地化
轮播箭头标签和幻灯片位置语义使用生成的 AnimalLocalizations，并随当前语言更新。幻灯片组件仍由调用方提供。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

自动播放由组件持有的运动调度器驱动。应用进入后台、`TickerMode` 禁用、启用减少动画、焦点进入轮播、调用方将 `visible` 设为 `false` 时都会暂停；`pauseOnHover` 启用时，悬停也会暂停。`visible` 只控制周期工作，不隐藏或测量轮播布局。恢复后只启动一个新的完整间隔，不补播暂停期间的轮播步进。可注入 `AnimalClock`，在确定性测试中控制自动播放经过时间；默认使用 `SystemClock`。

## 示例
参见示例 Gallery 中的 [`carousel_story.dart`](../../../example/lib/stories/carousel_story.dart)。
