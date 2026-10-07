<!-- generated:api:start -->
# AnimalDrawer

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalDrawer`

## 属性
- `child`
- `footer`
- `height`
- `onClose`
- `placement`
- `style`
- `title`
- `width`

## 枚举
- `AnimalDrawerPlacement`

<!-- generated:api:end -->

`AnimalDrawer` 是抽屉面板；`AnimalDrawer.show<T>` 以 route 方式把它显示在最近的
`Navigator` 上（没有 root navigator 回退），并返回 `Future<T?>`：`builder` 与可选
`footerBuilder` 收到的 `close` 回调所传入的值，被关闭时为 `null`。

```dart
final String? choice = await AnimalDrawer.show<String>(
  context: context,
  placement: AnimalDrawerPlacement.right,
  title: const Text('Settings'),
  builder: (context, close) => const Text('Sound effects: on'),
  footerBuilder: (context, close) => AnimalButton(
    onPressed: () => close('saved'),
    child: const Text('Save'),
  ),
);
```

## 方向、安全区与键盘

`placement` 为 `left`、`right`、`top` 或 `bottom`；左右面板首选 `width` 默认 378、上下面板首选 `height`
默认 300 逻辑像素。面板不会超出给定空间，因此
`width` 或 `height` 大于屏幕时也不会溢出。面板保持在弹出的键盘之上和安全区之内，
在 320 逻辑像素、200% 文字和输入法打开时关闭按钮仍可见、可操作。减少动态效果
时面板不滑动直接出现，并保持完全可操作。

## 关闭、结果与焦点

关闭按钮、Escape 和系统返回以 `null` 关闭抽屉。只有 `mask` 与 `maskClosable` 都为
`true` 时点击遮罩才会关闭。焦点保持在抽屉内，关闭后回到打开它的控件。关闭只移除
这个 route，即使位于嵌套 `Navigator`，或其上方又压入了其他 route；结果恰好交付
一次，之后的 `close` 调用会被忽略。route 只以本地化的抽屉标签（`drawerRouteLabel`）播报一次，没有第二层
route 作用域。

关闭按钮是包内共用的图标操作：48 逻辑像素目标、焦点环、本地化的关闭标签作为无障碍名称，
以及按 `WidgetState.hovered` 解析的悬停填充（来自 `closeButtonBackgroundColor`）；
减少动态效果时填充立即切换。

## 定制

`style` 接收 `AnimalDrawerStyle`，为这个抽屉覆盖主题；主题的 `components.drawer`
作用于所有抽屉。未设置的字段回退到由当前 token 推导的默认值：面板为
`colors.bgContent`、1.5 逻辑像素边框、`shadows.modal`，朝向屏幕内侧的角使用
`radii.card × 1.2`；标题为 3/4 大小、字重 800 的 `typography.title`。字段覆盖面板
（`backgroundColor`、`borderColor`、`borderWidth`、`borderRadius`、`shadow`）、标题
（`titleTextStyle`、`titleTextColor`）、内边距（`headerPadding`、`bodyPadding`、
`footerPadding`）、分隔线（`dividerColor`、`dividerThickness`）、关闭按钮
（`closeIconColor`、`closeIconSize`、`closeButtonPadding`、`closeButtonBorderRadius`、按
`WidgetState.hovered` 解析的 `closeButtonBackgroundColor`）和遮罩（`barrierColor`）。

## 语言行为

抽屉默认语义、关闭语义和 route barrier label 在 route 打开期间跟随当前生成的本地化。
标题和正文内容由调用者负责。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`drawer_story.dart`](../../../example/lib/stories/drawer_story.dart)。
