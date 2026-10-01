<!-- generated:api:start -->
# AnimalCodeBlock

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalCodeBlock`

## Properties
- `code`
- `language`

<!-- generated:api:end -->

## Localization
Copy labels, copy status, and accessibility announcements use generated
messages. The optional `language` value remains caller controlled; its default
descriptor comes from `codeDefaultLanguage`.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`code_block_story.dart`](../../../example/lib/stories/code_block_story.dart) in the example Gallery.
