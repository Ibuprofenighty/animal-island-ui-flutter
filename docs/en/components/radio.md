<!-- generated:api:start -->
# AnimalRadio

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalRadio`

## Properties
- `activeColor`
- `disabled`
- `focusNode`
- `groupValue`
- `label`
- `onChanged`
- `size`
- `value`

## Enums
- `AnimalRadioSize`

<!-- generated:api:end -->

## Localization
The optional radio label and group option labels are caller-owned. Localize those labels in the caller; the control adds state semantics without fixed text.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`radio_story.dart`](../../../example/lib/stories/radio_story.dart) in the example Gallery.
