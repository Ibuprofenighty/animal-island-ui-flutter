<!-- generated:api:start -->
# AnimalCarousel Reference

- **Class**: `AnimalCarousel`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalCarousel`

## Properties
- `activeIndex`
- `autoPlay`
- `autoPlayInterval`
- `defaultActiveIndex`
- `height`
- `items`
- `loop`
- `onChange`
- `pauseOnHover`
- `showArrows`
- `showDots`

<!-- generated:api:end -->

## Localization
Carousel arrow labels and slide-position semantics use generated AnimalLocalizations and update with the active locale. Slide widgets remain caller-owned.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`carousel_story.dart`](../../../../example/lib/stories/carousel_story.dart) in the example Gallery.
