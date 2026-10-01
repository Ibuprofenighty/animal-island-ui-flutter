<!-- generated:api:start -->
# AnimalCard

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalCard`

## Properties
- `borderRadius`
- `child`
- `color`
- `customBackgroundColor`
- `customBorderColor`
- `footer`
- `header`
- `hoverable`
- `margin`
- `onTap`
- `padding`
- `pattern`
- `semanticLabel`
- `type`

## Enums
- `AnimalCardPattern`
- `AnimalCardType`

<!-- generated:api:end -->

## Theme behavior
When `padding` is omitted, the card derives its inset from the active theme as
`EdgeInsets.all(theme.spacing.lg + theme.spacing.xs)`. The standard light and
dark presets currently produce 20 logical pixels; that value is a result of
their spacing tokens, not a second fixed component default. An explicit
`padding` remains the caller's override. The card has no default box shadow.

## Localization
AnimalCard owns no display copy. Localize child, header, footer, and any supplied semanticLabel in the caller.

## Interaction and accessibility

A tappable card surface responds to pointer taps and to Enter or Space when focused. Nested action controls keep their own activation; activating a child action does not invoke the card callback. Each action has a 48 logical-pixel hit target, adjacent targets do not overlap, and a pending activation is cancelled when the card loses focus, is disabled, is hidden or is unmounted.

## Example
See [`card_story.dart`](../../../example/lib/stories/card_story.dart) in the example Gallery.
