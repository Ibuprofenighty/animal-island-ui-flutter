<!-- generated:api:start -->
# AnimalTag

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalTag`

## Properties
- `child`
- `color`
- `disabled`
- `focusNode`
- `icon`
- `onClose`
- `onTap`
- `size`
- `variant`

## Enums
- `AnimalTagSize`
- `AnimalTagVariant`

<!-- generated:api:end -->

## Localization
The close action's accessibility label uses the generated `tagRemoveLabel`
message. The tag's `child` content remains caller supplied.

## Interaction and accessibility

When both actions are present, the tag body and the close control are separate targets; activating the close control does not activate the body. Each has its own focus, a 48 logical-pixel hit target, and the two do not overlap. A pending activation is cancelled when the tag loses focus, is disabled, is hidden or is unmounted.

## Example
See [`tag_story.dart`](../../../example/lib/stories/tag_story.dart) in the example Gallery.
