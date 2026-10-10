<!-- generated:api:start -->
# AnimalTable

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTable`

## 属性
- `cacheExtent`
- `columns`
- `emptyWidget`
- `horizontalScrollController`
- `loading`
- `maxHeight`
- `minWidth`
- `rowBuilder`
- `rowCount`
- `rowKey`
- `style`
- `verticalScrollController`

<!-- generated:api:end -->

## 列与行

每一列是一个 `AnimalTableColumn`：`title`、固定 `width` 或按 `flex` 分配剩余宽度，以及单元格
`alignment`。行按需构建：`rowBuilder` 是返回某一行单元格的 `AnimalTableRowBuilder`，`rowKey`
是为每行提供稳定 key 的 `AnimalTableRowKey`。

## 本地化
内置空状态使用生成的 `empty` 文案，加载遮罩的语义标签使用 `tableLoadingLabel`。
空表传入的 `emptyWidget` 仍由调用者提供并显示。

## 示例
参见示例 Gallery 中的 [`table_story.dart`](../../../example/lib/stories/table_story.dart)。

## 所有权与边界

传入非空不可变列 schema、非负 `rowCount`、必需且唯一稳定的 `rowKey` 和一个按需 `rowBuilder`。构造时只快照 key，不构建单元格；key 使用数据 ID，不能使用位置。每个被请求的行必须恰好返回与列数相等的单元格，否则抛 `ArgumentError`。固定列宽须有限且为正，flex 权重须为正。表头和正文共享含边框、padding、`minWidth` 的几何；水平滚动同步移动，行随大字内容增高。父级需约束尺寸，无界时传有限正数 `minWidth`/`maxHeight`。借入的滚动控制器仍由调用者管理。`cacheExtent` 有限且非负，默认 96px。标准虚拟化测试使用 10,000 行、480px 正文视口、48px 行高和 96px 缓存；首次构建最多请求 24 行，滚动时存活元素保持有界。

## 定制

在 `style` 或 `AnimalIslandTheme.components.table` 使用 `AnimalTableStyle`，每个字段按实例 > 组件主题 > token 默认值解析。null 继承下层，局部 TextStyle 按属性合并。非法尺寸、insets、圆角、字号 在 debug/release 一致抛 `ArgumentError`。这组组件没有尺寸预设，动作的 48px 命中下限保持固定。

| 字段 | 渲染决策 |
| --- | --- |
| `backgroundColor` | 背景填充。 |
| `headerBackgroundColor` | 表头填充。 |
| `evenRowBackgroundColor` | 偶数行底色。 |
| `oddRowBackgroundColor` | 奇数行底色。 |
| `borderColor` | 轮廓颜色。 |
| `borderWidth` | 轮廓宽度。 |
| `borderRadius` | 圆角。 |
| `dividerColor` | 行分隔线颜色。 |
| `dividerThickness` | 行分隔线宽度。 |
| `rowPadding` | 表头与正文共用的行内边距。 |
| `minRowHeight` | 最小行高；行会随内容增高。 |
| `flexMinWidth` | 每个 flex 单位的最小宽度。 |
| `headerTextStyle` | 表头文字样式。 |
| `textStyle` | 文字样式。 |
| `headerTextColor` | 表头文字颜色。 |
| `textColor` | 文字颜色；支持的交互状态见组件行为。 |
| `emptyTextStyle` | 空状态文字样式。 |
| `emptyTextColor` | 空状态文字与插画颜色。 |
| `emptyPadding` | 空状态内边距。 |
| `emptyIconSize` | 空状态插画大小。 |
| `emptyIconGap` | 空状态插画后的间距。 |
| `loadingSize` | 加载指示器大小。 |

内容横向溢出时，Tab 可进入视口并显示焦点环。左右键每次滚动 50 逻辑像素（RTL 镜像），Home/End 到达起点/终点，PageUp/PageDown 移动一个视口。这些按键即时响应；已聚焦的子级编辑器保留自己的按键处理。屏幕阅读器仍可使用原生滚动语义。
