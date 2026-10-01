<!-- generated:api:start -->
# AnimalTimePicker

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalTimePicker`

## Properties
- `allowClear`
- `disabled`
- `focusNode`
- `format`
- `hourStep`
- `minuteStep`
- `onChanged`
- `secondStep`
- `showNow`
- `value`

<!-- generated:api:end -->

## Localization
Default prompts, panel actions, and wheel-value semantics use generated AnimalLocalizations and refresh when the locale changes. A supplied placeholder remains caller-owned.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`time_picker_story.dart`](../../../example/lib/stories/time_picker_story.dart) in the example Gallery.
