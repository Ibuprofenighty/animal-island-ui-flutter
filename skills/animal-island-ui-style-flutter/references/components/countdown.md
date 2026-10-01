<!-- generated:api:start -->
# AnimalCountdown Reference

- **Class**: `AnimalCountdown`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalCountdown`

## Properties
- `bordered`
- `clock`
- `format`
- `onChange`
- `onFinish`
- `prefix`
- `remaining`
- `size`
- `targetTime`
- `variant`

## Enums
- `AnimalCountdownSize`
- `AnimalCountdownVariant`

<!-- generated:api:end -->

`AnimalClock` and its default `SystemClock` are public root types. `FakeClock`
is test support only; it is not part of the package API.

## Localization
Unit tiles use the generated `countdownUnitDays`, `countdownUnitHours`,
`countdownUnitMinutes`, and `countdownUnitSeconds` messages. The spoken remaining
time uses the generated plural `countdownRemaining` message.

## Example
See [`countdown_story.dart`](../../../../example/lib/stories/countdown_story.dart) in the example Gallery.
