<!-- generated:api:start -->
# AnimalCarousel

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCarousel`
- `AnimalCarousel.uncontrolled`

## 属性
- `activeId`
- `autoPlay`
- `autoPlayInterval`
- `clock`
- `defaultActiveId`
- `items`
- `loop`
- `onChange`
- `pauseOnHover`
- `showArrows`
- `showDots`
- `style`
- `visible`

<!-- generated:api:end -->

## 本地化
轮播箭头标签和幻灯片位置语义使用生成的 AnimalLocalizations，并随当前语言更新。幻灯片组件仍由调用方提供。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

自动播放由组件持有的运动调度器驱动。应用进入后台、`TickerMode` 禁用、启用减少动画、焦点进入轮播、调用方将 `visible` 设为 `false` 时都会暂停；`pauseOnHover` 启用时，悬停也会暂停。`visible` 控制装饰工作，包括自动播放、页面与滑点过渡，不隐藏或测量轮播布局。切为不可见时结束已有过渡并立即对齐当前 owner 值；低运动、禁用 TickerMode 和后台策略同样结束这些过渡，恢复不补播旧动画。恢复后只启动一个新的完整间隔，不补播暂停期间的轮播步进。可注入 `AnimalClock`，在确定性测试中控制自动播放经过时间；默认使用 `SystemClock`。

## 示例
参见示例 Gallery 中的 [`carousel_story.dart`](../../../example/lib/stories/carousel_story.dart)。

## 所有权与边界

幻灯片使用 `AnimalCarouselItem(id: ..., child: ...)`，ID 非空且唯一。`AnimalCarousel` 必须传 `activeId`，仅提议变化；组件持有状态时使用 `AnimalCarousel.uncontrolled` 和可选 `defaultActiveId`。受控非空列表须传现存 ID，空列表须为 null，删项与更新选中值必须原子进行。非受控删除当前项后回到第一项且不通知，空列表没有选中项。重排按 ID 同步分页控制器，每次构造的 defaultActiveId 都须为现存 ID，或用 null 从首项/空列表开始；删项时同批清理已删除的默认 ID，合法默认值改变不重置已挂载选中状态。RTL 箭头位置和图标按逻辑上一项/下一项镜像。挂载期间不能切换所有权。外部更新不回声通知，父级拒绝滑动时恢复权威页面。`autoPlayInterval` 即使关闭自动播放也必须为正。非 loop 自动播放在末项停止。焦点、悬停、可见性、前后台、低运动和 TickerMode 统一经共享运动调度器暂停；恢复后等待一个新间隔。`visible` 只控制工作资格，不隐藏组件。可注入 `AnimalClock` 控制时间。

## 定制

在 `style` 或 `AnimalIslandTheme.components.carousel` 使用 `AnimalCarouselStyle`，每个字段按实例 > 组件主题 > token 默认值解析。null 继承下层。非法尺寸、insets、圆角及 duration 在 debug/release 一致抛 `ArgumentError`。这组组件没有尺寸预设，动作的 48px 命中下限保持固定。

通过 `AnimalCarouselStyle(height: ...)` 设置轮播高度，和所有视觉字段一样按实例 > 组件主题 > 默认值解析，默认值为 200 逻辑像素。两种值所有权构造函数共用这一个视觉输入。

| 字段 | 渲染决策 |
| --- | --- |
| `height` | 轮播高度。 |
| `backgroundColor` | 空轮播占位的填充。 |
| `borderColor` | 空轮播占位的轮廓颜色。 |
| `borderWidth` | 空轮播占位的轮廓宽度。 |
| `borderRadius` | 圆角。 |
| `dotBorderRadius` | 滑点容器的圆角。 |
| `arrowColor` | 箭头前景色。 |
| `arrowBackgroundColor` | 箭头填充。 |
| `arrowIconSize` | 箭头图标大小。 |
| `controlInset` | 控制按钮与容器边缘的距离。 |
| `controlPadding` | 控制按钮内边距。 |
| `dotColor` | 非选中滑点颜色。 |
| `activeDotColor` | 选中滑点颜色。 |
| `dotSize` | 滑点高度及非选中宽度。 |
| `activeDotWidth` | 选中滑点宽度。 |
| `dotGap` | 滑点间距。 |
| `dotPadding` | 滑点容器内边距。 |
| `dotBackgroundColor` | 滑点容器填充。 |
| `shadow` | 阴影。 |
| `duration` | 主体过渡时间。 |
| `dotDuration` | 滑点过渡时间。 |
| `curve` | 过渡曲线。 |
