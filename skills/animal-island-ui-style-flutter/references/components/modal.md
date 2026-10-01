<!-- generated:api:start -->
# AnimalModal Reference

- **Class**: `AnimalModal`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalModal`

## Properties
- `cancelText`
- `content`
- `footer`
- `okText`
- `onClose`
- `onOk`
- `title`
- `typeSpeed`
- `typewriter`
- `width`

<!-- generated:api:end -->

The modal surface remains an internal rendering detail.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`modal_story.dart`](../../../../example/lib/stories/modal_story.dart) in the example Gallery.
