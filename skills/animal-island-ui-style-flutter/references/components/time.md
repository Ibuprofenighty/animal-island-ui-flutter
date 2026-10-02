<!-- generated:api:start -->
# AnimalTime Reference

- **Class**: `AnimalTime`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalTime`

## Properties
- `clock`
- `live`
- `liveRegion`
- `time`
- `visible`

<!-- generated:api:end -->

`AnimalClock` and its default `SystemClock` are public root types. `FakeClock`
is test support only; it is not part of the package API.

Live time uses one functional readout registration and continues under reduced-motion preferences. It pauses while the app is in the background, its `TickerMode` is disabled, or the owner sets `visible: false`; this input controls updates only and does not hide layout. It refreshes from `clock.now()` when active again. `liveRegion` remains the only control for announcing those updates.

## Localization
The clock display uses `intl`'s locale-specific `Hms` pattern. Its accessible
label comes from the generated `currentTimeLabel` message, and `liveRegion`
continues to control announcements.

## Example
See [`time_story.dart`](../../../../example/lib/stories/time_story.dart) in the example Gallery.
