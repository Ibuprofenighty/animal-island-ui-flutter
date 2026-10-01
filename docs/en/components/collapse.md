<!-- generated:api:start -->
# AnimalCollapse

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalCollapse`
- `AnimalCollapse.single`

## Properties
- `accordion`
- `activeIds`
- `defaultActiveIds`
- `disabled`
- `items`
- `onChanged`

<!-- generated:api:end -->

## Localization
Collapse item titles, content, and extras are caller-owned widgets. Localize them in the caller; the component only adds expanded/enabled semantics.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`collapse_story.dart`](../../../example/lib/stories/collapse_story.dart) in the example Gallery.
