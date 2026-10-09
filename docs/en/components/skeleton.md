<!-- generated:api:start -->
# AnimalSkeleton

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalSkeleton`
- `AnimalSkeleton.avatar`
- `AnimalSkeleton.button`
- `AnimalSkeleton.input`
- `AnimalSkeleton.paragraph`

## Properties
- `active`
- `child`
- `height`
- `loading`
- `rowWidths`
- `rows`
- `style`
- `variant`
- `width`

## Enums
- `AnimalSkeletonVariant`

<!-- generated:api:end -->

## Placeholder

While `loading` is true the skeleton shows placeholder blocks; when it is false
it shows `child`, or the placeholder when there is no child. The placeholder is
announced as loading and exposes no fake text or controls.

`width` and `height` must be finite and non-negative; text and rectangle
blocks fill the available width when `width` is null. A paragraph has `rows`
rows (at least 1). Each entry of `rowWidths` is a fraction of the paragraph
width from 0 to 1, and rows without an entry use 1, 0.82 and 0.6 for the first
three rows and 1 after them. Invalid values throw an `ArgumentError`. When the
available width is unbounded, a paragraph is `width` wide, or 280 logical
pixels.

## Motion

A shimmer sweeps across the blocks while `active` is true. Each skeleton has
one animation controller that starts and stops as often as needed. It rests,
and the blocks show their plain fill, under a disabled `TickerMode`, with
reduced motion and while the app is in the background.

## Customization

`style` takes an `AnimalSkeletonStyle` and overrides the theme for this
skeleton; the presets accept the same `style`, and the theme's
`components.skeleton` applies one to every skeleton. Unset fields fall back to
the tokens: blocks use `colors.bgDisabled` with a `colors.bgInput` shimmer
(`colors.surfaceHeader` and `colors.surfaceAlt` in dark themes); rectangles
have `radii.card` corners, or pill corners for the `button` and `input`
presets; text lines and paragraph rows are 16 logical pixel high pills,
`spacing.md - spacing.xxs` apart. Without a size, a rectangle is 100 logical
pixels high and a circle 44 wide.

## Localization
While loading, the skeleton's accessibility label uses the generated `loading`
message and follows the host locale.

## Example
See [`skeleton_story.dart`](../../../example/lib/stories/skeleton_story.dart) in the example Gallery.
