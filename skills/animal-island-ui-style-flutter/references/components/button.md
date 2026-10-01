<!-- generated:api:start -->
# AnimalButton Reference

- **Class**: `AnimalButton`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalButton`

## Properties
- `block`
- `child`
- `disabled`
- `focusNode`
- `icon`
- `loading`
- `onPressed`
- `semanticLabel`
- `size`
- `tone`
- `variant`

## Enums
- `AnimalButtonSize`
- `AnimalButtonTone`
- `AnimalButtonVariant`

<!-- generated:api:end -->

## Localization
AnimalButton owns no display copy. Localize its child and any supplied semanticLabel in the caller; the component passes that content through.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`button_story.dart`](../../../../example/lib/stories/button_story.dart) in the example Gallery.
