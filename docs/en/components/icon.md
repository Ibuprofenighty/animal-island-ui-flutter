<!-- generated:api:start -->
# AnimalIcon

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

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

## Custom SVG input
`AnimalIconData.svg` accepts a restricted SVG subset: one balanced `<svg>` root, allowlisted shape elements and presentation attributes, and local fragment references. Empty input, DTDs, entity declarations, scripts, styles, event attributes and external resources are rejected. Inputs are limited to 256 KiB of UTF-8, 2,000 elements and 64 levels of nesting. Invalid or unsupported markup throws `ArgumentError` when rendered. Both quote styles are accepted; `stroke="none"` stays invisible, while an explicit tint can replace a visible stroke including `currentColor`. Tint alpha is canonicalized to three decimal places and replaces the affected `stroke-opacity`; ordinary group `opacity` is preserved. Positive custom stroke widths use two decimal places; zero and negative widths canonicalize to `0`.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`icon_story.dart`](../../../example/lib/stories/icon_story.dart) in the example Gallery.
