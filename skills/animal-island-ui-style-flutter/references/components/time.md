<!-- generated:api:start -->
# AnimalTime Reference

- **Class**: `AnimalTime`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalTime`
- `AnimalTime.live`

## Properties
- `liveRegion`
- `style`
- `visible`

<!-- generated:api:end -->

`AnimalClock` and its default `SystemClock` are public root types. `FakeClock`
is test support only; it is not part of the package API.

## Fixed and live time

`AnimalTime(time: ...)` shows the given time and never changes it.
`AnimalTime.live(clock: ...)` shows the current time of its clock and moves to
the next second exactly when the wall clock does. Reduced-motion preferences
do not stop live time. It pauses while the app is in the background, its
`TickerMode` is disabled, or the owner sets `visible: false` (this input
controls updates only and does not hide layout), and shows the current time
again when it returns, without replaying missed seconds.

Screen readers read the time when they reach the card. With `liveRegion: true`
changes are announced; the announced value has minute precision, so a live
card is announced at most once a minute.

## Customization

`style` takes an `AnimalTimeStyle` and overrides the theme for this card; the
theme's `components.time` applies one to every card. Unset fields fall back to
the tokens: the card has `spacing.lg + spacing.xxs` horizontal and
`spacing.md` vertical padding, a `colors.bgContent` fill, a 1.5 logical pixel
`colors.border` border and `radii.card` corners; the time uses
`typography.heading` at 0.9 in `colors.text`; the 20 logical pixel clock icon
uses `colors.primaryText`, `spacing.sm` before the time.

## Localization
The clock display uses `intl`'s locale-specific `Hms` pattern. Its accessible
label comes from the generated `currentTimeLabel` message, and `liveRegion`
continues to control announcements.

## Example
See [`time_story.dart`](../../../../example/lib/stories/time_story.dart) in the example Gallery.
