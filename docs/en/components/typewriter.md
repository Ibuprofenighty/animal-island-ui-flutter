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

## Typing

`text` is laid out once, so its line breaks and the widget's size never change
while it types. Each `speed` of typing time reveals one more Unicode grapheme
cluster (a late tick reveals the clusters that are due), so an emoji or a letter
with a combining accent is never split; a `speed` that is not positive throws
an `ArgumentError`. The optional cursor is drawn over
the text at the typing position and takes no space, so `showCursor` never
changes wrapping. The widget keeps one offset per grapheme cluster, so its
memory grows linearly with the text.

`onComplete` runs once per text when the whole text is visible: after the last
cluster is typed, or after the first frame for an empty text or under reduced
motion. Changing `text` restarts typing and cancels a pending completion of the
previous text; disposing the widget cancels it too.

Typing and the cursor blink pause in the background, under a disabled
`TickerMode`, while the text is hovered, and when the owner sets
`visible: false`. The `visible` input controls typing only; it does not hide
layout. Typing continues from the current cluster without replaying missed
steps. With reduced motion the whole text appears at once.

Inject an `AnimalClock` to control elapsed typing time in deterministic tests;
the default `SystemClock` measures elapsed time monotonically.

## Customization

`style` takes an `AnimalTypewriterStyle` and overrides the theme for this
typewriter; the theme's `components.typewriter` applies one to every
typewriter. Unset fields fall back to the tokens: the text uses
`typography.body` in `colors.text`, and the cursor is a 2 logical pixel wide
`colors.primary` bar as tall as its line that blinks every 500 ms.

## Localization
The text is caller-owned. Localize it before passing it to the component; accessibility semantics announce that complete caller string.

## Example
See [`typewriter_story.dart`](../../../example/lib/stories/typewriter_story.dart) in the example Gallery.
