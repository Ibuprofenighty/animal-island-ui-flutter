<!-- generated:api:start -->
# AnimalTable

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalTable`

## Properties
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
See [`table_story.dart`](../../../example/lib/stories/table_story.dart) in the example Gallery.

## Ownership and boundaries

Supply a nonempty immutable column schema, nonnegative `rowCount`, a required unique stable `rowKey`, and one lazy `rowBuilder`. Keys are snapshotted at construction without building cells; use data IDs rather than positions. Every requested row must return exactly one cell per column or throws `ArgumentError`. Fixed widths must be finite and positive and flex weights positive. Header and body share resolved widths including border, row padding and `minWidth`; horizontal scrolling moves them together. Rows grow for large text. Provide bounded dimensions or positive finite `minWidth`/`maxHeight` in an unbounded parent. Borrowed scroll controllers remain caller-owned. `cacheExtent` is finite and nonnegative, default 96px. The canonical virtualization test uses 10,000 rows, a 480px body viewport, 48px rows and 96px cache; first build requests at most 24 rows and live elements stay bounded while scrolling.

## Customization

Use `AnimalTableStyle` on `style` or `AnimalIslandTheme.components.table`. Each field resolves instance > component theme > token default. Null inherits the lower layer; partial text styles merge by property. Invalid numeric dimensions, insets, radii, font sizes throw `ArgumentError` in debug and release. There are no size presets. The 48px action target remains fixed.

| Field | Rendered decision |
| --- | --- |
| `backgroundColor` | Table fill. |
| `headerBackgroundColor` | Header fill. |
| `evenRowBackgroundColor` | Even row fill. |
| `oddRowBackgroundColor` | Odd row fill. |
| `borderColor` | Table outline. |
| `borderWidth` | Table outline width. |
| `borderRadius` | Table corners. |
| `dividerColor` | Row separator color. |
| `dividerThickness` | Row separator width. |
| `rowPadding` | Shared header and body row insets. |
| `minRowHeight` | Minimum row height; rows grow to fit content. |
| `flexMinWidth` | Minimum width per flex unit. |
| `headerTextStyle` | Header typography. |
| `textStyle` | Body typography. |
| `headerTextColor` | Header foreground. |
| `textColor` | Body foreground. |
| `emptyTextStyle` | Empty label typography. |
| `emptyTextColor` | Empty label and illustration foreground. |
| `emptyPadding` | Empty content insets. |
| `emptyIconSize` | Empty illustration size. |
| `emptyIconGap` | Space after the empty illustration. |
| `loadingSize` | Loading indicator size. |

When content overflows horizontally, Tab enters a visible focus ring on the viewport. Left/Right scroll by 50 logical pixels (mirrored in RTL), Home/End reach the start/end, and PageUp/PageDown move one viewport. These key responses are immediate. Focused descendant editors retain their own keys. Native scroll semantics remain available to screen readers.
