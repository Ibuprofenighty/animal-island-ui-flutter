<!-- generated:api:start -->
# AnimalModal

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalModal`

## 属性
- `content`
- `footer`
- `onClose`
- `style`
- `title`
- `width`

<!-- generated:api:end -->

`AnimalModal` 是 blob 外观；通过一个有类型的入口以 route 方式显示在最近的
`Navigator` 上（没有 root navigator 回退）：

| 入口 | 结果 |
| --- | --- |
| `AnimalModal.confirm(context:, content:, onConfirm:)` | `Future<bool>`：只有确认操作成功时为 `true`；取消或关闭时为 `false` |
| `AnimalModal.showDialogue(context:, speaker:, avatar:, dialogue:)` | `Future<bool>`：正文逐字显示明确的 `dialogue` 文本一次的确认框；`onFinish` 只运行一次 |
| `AnimalModal.show<T>(context:, builder: (context, close) => ...)` | `Future<T?>`：传给 `close` 的值；被关闭时为 `null` |

```dart
final bool deleted = await AnimalModal.confirm(
  context: context,
  title: const Text('Delete island?'),
  content: const Text('This cannot be undone.'),
  onConfirm: () async => api.deleteIsland(), // FutureOr<bool>
);

final String? fruit = await AnimalModal.show<String>(
  context: context,
  title: const Text('Pick a fruit'),
  builder: (context, close) => AnimalButton(
    onPressed: () => close('apple'),
    child: const Text('Apple'),
  ),
);
```

正文按原样渲染：富文本 `Widget` 不会被抽取文字后重新打字。需要打字效果时使用
`showDialogue`，或在正文中自行放置 `AnimalTypewriter`。

## 确认与关闭

`onConfirm` 返回 `FutureOr<bool>`。`true` 以 `true` 关闭；`false` 保持打开；抛出的
错误保持打开、在正文下方显示错误，并可重试。`onConfirm` 挂起期间，重复确认和所有
关闭请求都会被忽略，因此每次尝试只运行一次。

取消、关闭按钮、Escape 和系统返回都会关闭 modal。只有 `mask` 与 `maskClosable`
都为 `true` 时点击遮罩才会关闭；`mask: false` 时没有变暗和模糊的遮罩。焦点保持在
modal 内，关闭后回到打开它的控件。关闭只移除这个 route，即使位于嵌套
`Navigator`，或其上方又压入了其他 route；结果恰好交付一次，`Navigator` 被销毁时
也一样（`false` 或 `null`）。减少动态效果时 modal 直接出现，没有过渡。

关闭按钮是包内共用的图标操作：48 逻辑像素目标、焦点环、本地化的关闭标签作为无障碍名称，
以及按 `WidgetState.hovered` 解析的悬停填充（来自 `closeButtonBackgroundColor`）；
减少动态效果时填充立即切换。

正文在键盘留下的高度内滚动，操作按钮会换行，因此在 320 逻辑像素宽的屏幕上以 200%
文字显示长正文时仍能到达操作按钮。

## 定制

`style` 接收 `AnimalModalStyle`，为这个 modal 覆盖主题；主题的 `components.modal`
作用于所有 modal。未设置的字段回退到由当前 token 推导的默认值：外观为
`colors.bgContent`、2 逻辑像素描边和 `shadows.modal`；标题为 3/4 大小、字重 800 的
`typography.title`；正文为按 15/14 缩放、行高 1.5 的 `typography.body`；错误使用
`colors.error` 的 `typography.caption`。字段覆盖外观（`backgroundColor`、
`borderColor`、`borderWidth`、`shadow`、`padding`、`horizontalMargin`）、文字
（`titleTextStyle`、`titleTextColor`、`textStyle`、`textColor`、`errorTextStyle`、
`errorTextColor`）、间距（`headerGap`、`errorGap`、`footerGap`、`actionGap`、
`avatarGap`）、关闭按钮（`closeIconColor`、`closeIconSize`、`closeButtonPadding`、
默认为半径 24 圆形的 `closeButtonBorderRadius`、按 `WidgetState.hovered` 解析的
`closeButtonBackgroundColor`）和遮罩（`barrierColor`、`barrierBlurSigma`）。

外观首选宽度 `width` 默认 500 逻辑像素。正文最多使用键盘留下高度的 85%；外观非常窄时，每一侧水平内边距最多让到外观宽度的
四分之一。

## 语言行为

默认操作文案、route 名称（`modalRouteLabel`，只朗读一次）和 route barrier label
来自当前生成的本地化；route 打开期间也会更新。
调用者提供的操作文案和 modal 内容仍由调用者负责。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`modal_story.dart`](../../../example/lib/stories/modal_story.dart)。
