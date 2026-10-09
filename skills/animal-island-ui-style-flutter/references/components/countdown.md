<!-- generated:api:start -->
# AnimalCountdown Reference

- **Class**: `AnimalCountdown`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalCountdown`
- `AnimalCountdown.duration`

## Properties
- `bordered`
- `clock`
- `format`
- `onChange`
- `onFinish`
- `prefix`
- `size`
- `style`
- `variant`
- `visible`

## Enums
- `AnimalCountdownFormat`
- `AnimalCountdownSize`
- `AnimalCountdownVariant`

<!-- generated:api:end -->

`AnimalClock` and its default `SystemClock` are public root types. `FakeClock`
is test support only; it is not part of the package API.

## Deadline

`AnimalCountdown(targetTime: ...)` counts down to a wall-clock time.
`AnimalCountdown.duration(duration: ...)` fixes its deadline on the clock's
monotonic time when it starts, so wall-clock adjustments do not move it. Both
use one remaining-time computation. The tiles show the remaining time rounded
up to whole seconds, so they read `00` only at the deadline, and `onFinish`
runs once when the deadline is reached. A deadline that has already passed,
including a zero or negative duration, finishes once after the first frame.
`onChange` reports the remaining whole seconds each time the tiles change to a
value above zero.

Changing `targetTime`, `duration` or `clock` starts a new countdown; callbacks
of the previous one never run afterwards, even one scheduled in the same frame.

The tiles refresh exactly when the shown second changes. Reduced-motion
settings do not stop them. They pause in the background, under a disabled
`TickerMode`, or when the owner sets `visible: false` (that input controls
refreshes only and does not hide layout), and show the current remaining time
when they return instead of subtracting missed ticks. `onFinish` still runs at
the deadline in those states. A wall-clock adjustment made while the tiles are
paused moves a `targetTime` deadline only when its timer next fires.

## Format

`format` is an `AnimalCountdownFormat`: `daysHoursMinutesSeconds`,
`hoursMinutesSeconds` (the default), `minutesSeconds` or `seconds`. The largest
unit shows the whole remaining amount and never wraps, so 30 hours shows as
`30` hours. Tiles grow to fit long values, and in a narrow box the tiles wrap
onto further lines instead of overflowing.

## Customization

`style` takes an `AnimalCountdownStyle` and overrides the theme for this
countdown. The theme's `components.countdown` is an `AnimalCountdownThemeData`
with a general `style`, and `smallStyle`, `middleStyle` and `largeStyle` that
win over it. Unset fields fall back to the tokens: digits and separators use
`typography.countdown` (weight 900) in `colors.text`, scaled by 15/28, 22/28 or
1 for small, middle and large; unit labels use bold `typography.caption` in
`colors.textSecondary`, scaled by 9/12, 10/12 or 11/12; tiles are at least
40×36, 54×48 or 68×60 logical pixels with `radii.sm`-based corners,
`shadows.input3d` and a `colors.bgContent` fill (`colors.surfaceAlt` for the
`island` variant). `bordered` adds a 1.5 logical pixel border.

## Localization
Unit tiles use the generated `countdownUnitDays`, `countdownUnitHours`,
`countdownUnitMinutes`, and `countdownUnitSeconds` messages. The spoken remaining
time uses the generated plural `countdownRemaining` message.

## Example
See [`countdown_story.dart`](../../../../example/lib/stories/countdown_story.dart) in the example Gallery.
