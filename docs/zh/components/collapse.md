<!-- generated:api:start -->
# AnimalCollapse

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCollapse`
- `AnimalCollapse.single`

## 属性
- `accordion`
- `activeIds`
- `defaultActiveIds`
- `disabled`
- `items`
- `onChanged`
- `style`

<!-- generated:api:end -->

## 面板项

每个面板是一个 `AnimalCollapseItem`：稳定的 `id`、`title` 与 `content` 组件、标题行末尾可选的
`extra` 组件，以及让它不能展开或收起的 `disabled`。

## 本地化
折叠项标题、内容和附加内容均为调用方提供的组件。调用方负责本地化；组件只提供展开和启用状态语义。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`collapse_story.dart`](../../../example/lib/stories/collapse_story.dart)。

## 所有权与边界

`AnimalCollapseItem.id` 必须非空且唯一。`activeIds` 控制展开值；省略它并传 `defaultActiveIds` 使用仅初始值的非受控状态，两者不可同时提供。每次构造仍按当前 items 校验 defaultActiveIds，删项时父级同批清理默认 ID；合法默认输入变化不重置已挂载展开状态。未知 ID 或 accordion 中多个 ID 抛 `ArgumentError`，挂载期间不能切换所有权。受控回调提议不可变集合，父级拒绝时展开值不变。重排保留内容状态和焦点，非受控删项移除该项展开值。收起内容保留状态，但排除输入、焦点和语义。标题的 Enter/Space 激活由共享交互 owner 处理。

## 定制

在 `style` 或 `AnimalIslandTheme.components.collapse` 使用 `AnimalCollapseStyle`，每个字段按实例 > 组件主题 > token 默认值解析。null 继承下层，局部 TextStyle 按属性合并。非法尺寸、insets、圆角、字号及 duration 在 debug/release 一致抛 `ArgumentError`。这组组件没有尺寸预设，动作的 48px 命中下限保持固定。

| 字段 | 渲染决策 |
| --- | --- |
| `backgroundColor` | 背景填充。 |
| `borderColor` | 轮廓颜色。 |
| `borderWidth` | 轮廓宽度。 |
| `borderRadius` | 圆角。 |
| `shadow` | 阴影。 |
| `headerPadding` | 标题内边距。 |
| `contentPadding` | 内容内边距。 |
| `gap` | 相邻项间距。 |
| `iconGap` | 图标与文字的间距。 |
| `iconSize` | 图标大小。 |
| `iconColor` | 图标颜色。 |
| `headerBackgroundColor` | 标题填充；可按交互状态解析。 |
| `textStyle` | 文字样式。 |
| `textColor` | 文字颜色；支持的交互状态见组件行为。 |
| `contentBackgroundColor` | 内容填充。 |
| `contentTextColor` | 内容文字颜色。 |
| `duration` | 主体过渡时间。 |
| `curve` | 过渡曲线。 |
