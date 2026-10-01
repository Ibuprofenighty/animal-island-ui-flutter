<!-- generated:api:start -->
# AnimalIcon Reference

- **Class**: `AnimalIcon`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalIcon`

## Properties
- `bounce`
- `color`
- `data`
- `focusNode`
- `monochrome`
- `onTap`
- `semanticLabel`
- `size`
- `strokeColor`
- `strokeWidth`

<!-- generated:api:end -->

## Localization
Interactive canonical icons use the generated localized icon name when neither semanticLabel nor AnimalIconData.semanticLabel is supplied. A caller label takes precedence; unlabeled decorative icons remain excluded from semantics.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`icon_story.dart`](../../../../example/lib/stories/icon_story.dart) in the example Gallery.
