<!-- generated:api:start -->
# AnimalPagination

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalPagination`

## Properties
- `current`
- `disabled`
- `onChanged`
- `pageSize`
- `simple`
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
See [`pagination_story.dart`](../../../example/lib/stories/pagination_story.dart) in the example Gallery.
