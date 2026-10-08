<!-- generated:api:start -->
# AnimalTable

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTable`

## 属性
- `columns`
- `emptyWidget`
- `horizontalScrollController`
- `loading`
- `maxHeight`
- `minWidth`
- `rowBuilder`
- `rowCount`
- `rowKey`
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
