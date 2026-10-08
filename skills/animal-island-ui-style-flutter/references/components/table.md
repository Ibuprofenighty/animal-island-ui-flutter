<!-- generated:api:start -->
# AnimalTable Reference

- **Class**: `AnimalTable`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalTable`

## Properties
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

## Columns and rows

Each column is an `AnimalTableColumn`: a `title`, a fixed `width` or a
`flex` share of the remaining width, and the cell `alignment`. Rows are built
lazily: `rowBuilder` is an `AnimalTableRowBuilder` that returns the cells of
the row at an index, and `rowKey` is an `AnimalTableRowKey` that gives each
row a stable key.

## Localization
The built-in empty state uses the generated `empty` message, and the loading
overlay uses `tableLoadingLabel` for semantics. A caller supplied `emptyWidget`
remains the content shown for an empty table.

## Example
See [`table_story.dart`](../../../../example/lib/stories/table_story.dart) in the example Gallery.
