<!-- generated:api:start -->
# AnimalPagination Reference

- **Class**: `AnimalPagination`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalPagination`

## Properties
- `current`
- `disabled`
- `onChanged`
- `pageSize`
- `simple`
- `style`
- `total`
- `totalPages`

<!-- generated:api:end -->

## Localization
Navigation, previous/next, page, and five-page skip semantics use generated
pagination messages. Numeric page values remain numeric, and labels update while
the control is mounted when the locale changes.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`pagination_story.dart`](../../../../example/lib/stories/pagination_story.dart) in the example Gallery.

## Ownership and customization

The caller owns `current`. `total` must be nonnegative and `pageSize` positive; page counts use exact integer arithmetic. Empty data has one page, `current: 1`, with no navigation callbacks. Other current values must be in 1..totalPages or throw `RangeError`. Disabled, boundary and current-page activations do not notify; valid actions only propose and never commit locally. Ellipses jump five pages and clamp to the range without overflowing at the maximum integer. Compact layout is selected from page and ellipsis labels measured with their own rendered text styles, active text scaling, resolved spacing and the actual width. RTL reverses arrow direction; navigation remains operable at 320px and 200% text.

Use `AnimalPaginationStyle` through `style` or `AnimalIslandTheme.components.pagination`, with instance > component theme > token precedence. See the component documentation for every field and its validation. There are no size presets.
