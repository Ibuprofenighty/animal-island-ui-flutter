<!-- generated:api:start -->
# AnimalImage Reference

- **Class**: `AnimalImage`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalImage`

## Properties
- `borderRadius`
- `color`
- `fallback`
- `fit`
- `height`
- `image`
- `placeholder`
- `preview`
- `semanticLabel`
- `variant`
- `width`

## Enums
- `AnimalImageVariant`

<!-- generated:api:end -->

## Localization
The preview trigger uses generated default or caller-label messages. The open
preview resolves its close and barrier labels from the active locale, including
locale changes while the route remains open.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`image_story.dart`](../../../../example/lib/stories/image_story.dart) in the example Gallery.
