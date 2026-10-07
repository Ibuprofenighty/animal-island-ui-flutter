<!-- generated:api:start -->
# AnimalNotification

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalNotification`

## 属性
- `defaultDuration`

## 枚举
- `AnimalNotificationPlacement`
- `AnimalNotificationStatus`
- `AnimalNotificationType`

<!-- generated:api:end -->

## 用法与生命周期

`AnimalNotification.open`（以及 `success`、`error`、`warning`、`info`）在最近的
`AnimalOverlayHost` 中显示通知；context 之上没有 host 会抛错。它返回
`AnimalNotificationHandle`：`status` 为 `active`、`waiting`、`rejected` 或 `closed`，
`close()` 幂等。`AnimalNotification.closeAll(context, placement: ...)` 关闭最近 host
的通知，可只关闭某一方位。

- 每个 host 为每个方位维护一个同步队列：最多显示 3 条、等待 50 条。超出的新通知为
  `rejected`，绝不丢弃更早的通知。关闭一条显示中的通知会提升最早等待的一条。
- `duration` 默认 4.5 秒；`null` 表示一直显示直到被关闭。鼠标悬停或焦点位于通知内时
  暂停计时。
- `key` 是业务 key。同一 host 同一方位中仍在队列里的同 key occurrence 会被原位替换全部配置
  （内容、类型、从现在重新计时的 duration、`onClick`、`onClose`），位置不变并返回同一个
  handle。该 occurrence 关闭后，同一 key 会打开新的 occurrence。
- 无论通过关闭按钮、滑动、`handle.close()`、`closeAll`、超时还是移除 host（包括等待中的
  通知）关闭，每个 occurrence 的 `onClose` 都恰好执行一次。被拒绝的通知从未打开，
  其 `onClose` 不会执行。`onClose` 中可以再次打开或关闭通知。
- 每张卡片是一个 live region，在出现或内容变化时播报一次。

通知关闭时在其 occurrence 关闭的同一帧离开所在位置，没有需要等待的退出动画。减少
动态效果时通知在原位出现，不滑动也不淡入。

关闭按钮是包内共用的图标操作：48 逻辑像素目标、焦点环、本地化的关闭标签作为无障碍名称，
以及按 `WidgetState.hovered` 解析的悬停填充（来自 `closeButtonBackgroundColor`）；
减少动态效果时填充立即切换。

## 定制

`style` 参数接受 `AnimalNotificationStyle`，只覆盖该条通知；
`AnimalIslandTheme.components.notification` 作用于所有通知。未设置的字段回落到由当前
token 和通知类型推导的默认值：消息为 `typography.heading` 乘以 0.75、字重 800，描述为
`typography.body` 乘以 13/14，填充、边框、图标和消息颜色跟随类型语义色。样式中设置的颜色
会替换所有类型的类型色。`closeButtonBackgroundColor` 解析 `WidgetState.hovered`。
方位堆叠与 host 边缘的距离为 `spacing.lg`。

## 语言职责

关闭操作使用当前生成的本地化；通知消息和描述由调用者提供。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`notification_story.dart`](../../../example/lib/stories/notification_story.dart)。
