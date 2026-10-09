<!-- generated:api:start -->
# AnimalProgress

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalProgress`
- `AnimalProgress.circle`

## Properties
- `animated`
- `diameter`
- `format`
- `infoPosition`
- `percent`
- `showInfo`
- `size`
- `status`
- `striped`
- `style`

## Enums
- `AnimalProgressInfoPosition`
- `AnimalProgressSize`
- `AnimalProgressStatus`

<!-- generated:api:end -->

## Value

`percent` is the completed fraction. Values below 0 or above 1 show as 0 or 1,
and a value that is not finite throws an `ArgumentError`. The label shows the
shown fraction rounded down to a whole percent; `format` receives the same
shown fraction. Screen readers read the
label as the progress value without live announcements. The linear bar and
`AnimalProgress.circle` share one value model, status colors and label.

`infoPosition` places a bar's label on the right, on top, inside the fill (when
the bar is at least 14 logical pixels high and the fill is wider than 38) or
nowhere. `AnimalProgress.circle` takes a `diameter` (120 by default; a negative
or non-finite value throws an `ArgumentError`) and shows its label in the
center unless `showInfo` is false.

## Motion

The stripes of an `active` bar move unless `animated` or `striped` is false.
Each bar has one animation controller that starts and stops as often as
needed. It rests at its first frame under a disabled `TickerMode`, with reduced
motion and while the app is in the background, so a resting bar schedules no
frames.

## Customization

`style` takes an `AnimalProgressStyle` and overrides the theme for this
indicator. The theme's `components.progress` is an `AnimalProgressThemeData`
with a general `style`, and `smallStyle`, `middleStyle` and `largeStyle` for
linear bars that win over it; a ring uses the general style. Unset fields fall
back to the tokens: the fill follows the status (`colors.primary`,
`colors.success` or `colors.error`); the track uses `colors.bgDisabled` with a
1.2 logical pixel `colors.borderLight` border (`colors.surfaceAlt` and
`colors.border` in dark themes); bars are 8, 14 or 22 logical pixels high and a
ring's stroke is 10; stripes are translucent white. Labels beside or above a
bar use bold `typography.caption` in `colors.text`, `spacing.md` to the right
or `spacing.xs + spacing.xxs` above; a ring's label scales
`typography.digitLarge` by its diameter / 180; a label inside the fill uses
`typography.button` at 0.8 in the status's on-color with
`shadows.softElevation`.

## Localization
Linear and circular indicators use the generated `progressLabel` and
`circularProgressLabel` messages as their built-in semantics labels. A caller's
`format` still controls the shown percentage text.

## Example
See [`progress_story.dart`](../../../example/lib/stories/progress_story.dart) in the example Gallery.
