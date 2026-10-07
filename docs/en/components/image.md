<!-- generated:api:start -->
# AnimalImage

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

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
preview resolves its route name (`imagePreviewRouteLabel`, announced
once), close and barrier labels from the active locale, including locale
changes while the route remains open.

## Preview

The preview is presented as the same route as Modal and Drawer: the close
control, Escape, system back and a barrier tap dismiss it, focus stays inside it
and returns to the control that was focused when it opened. With reduced motion
it appears without transition. The close control is the package's shared icon
action: a 48 logical-pixel target with a focus ring, the localized close label
as its accessible name and a hover fill resolved against `WidgetState.hovered`;
under reduced motion the fill changes instantly.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`image_story.dart`](../../../example/lib/stories/image_story.dart) in the example Gallery.
