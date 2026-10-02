<!-- generated:api:start -->
# AnimalTypewriter

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalTypewriter`

## Properties
- `clock`
- `onComplete`
- `showCursor`
- `speed`
- `style`
- `text`
- `textAlign`
- `visible`

<!-- generated:api:end -->

## Localization
The text is caller-owned. Localize it before passing it to the component; accessibility semantics announce that complete caller string.

Typing and the optional cursor share the component-owned motion scheduler. They pause in the background, under a disabled `TickerMode` or reduced-motion preference, while the text is focused or hovered, and when the owner sets `visible: false`. The `visible` input controls periodic work only; it does not hide layout. Resume continues from the current grapheme without replaying missed steps.

Inject an `AnimalClock` to control elapsed typing time in deterministic tests; the default `SystemClock` measures elapsed time monotonically.

## Example
See [`typewriter_story.dart`](../../../example/lib/stories/typewriter_story.dart) in the example Gallery.
