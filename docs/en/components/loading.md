<!-- generated:api:start -->
# AnimalLoading

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalLoading`
- `AnimalLoading.dots`
- `AnimalLoading.snowflake`
- `AnimalLoading.spinner`

## Properties
- `fullScreen`
- `maxSnowCount`
- `minSnowCount`
- `size`
- `snowCount`
- `snowSeed`
- `style`
- `tip`
- `tipWidget`
- `type`

## Enums
- `AnimalLoadingType`

<!-- generated:api:end -->

## Locale ownership

The default accessibility label uses the active generated localization. Explicit
`tip` and `tipWidget` values are caller-owned and remain unchanged across locale changes.

## Full-screen loading

`AnimalLoading.show(context, ...)` displays a full-screen loading in the
nearest `AnimalOverlayHost` and returns an `AnimalLoadingHandle`:

```dart
final handle = AnimalLoading.show(context, tip: 'Syncing island...');
try {
  await sync();
} finally {
  handle.close();
}
```

`close()` is the only way to remove it. Repeated calls are ignored, and a close
before the first frame leaves no overlay entry behind. `isClosed` also becomes
true when the host is removed, because a host closes its loadings when it
unmounts. Two hosts, including nested ones, never share loadings. A context
without a host throws; there is no root-overlay fallback and no global hide.

The barrier blocks pointer input to the controls it covers, moves keyboard
focus into its own scope (returning it on close) and removes the covered
controls from the accessibility tree. The tip, or the localized loading label,
is announced once. With reduced motion the indicator stops but keeps its
loading semantics.

`snowCount` accepts `AnimalLoading.minSnowCount` (1) to
`AnimalLoading.maxSnowCount` (100); other values throw a `RangeError`. Falling
particles are generated only for a full-screen snowflake loading.

## Customization

`style` takes an `AnimalLoadingStyle` and overrides the theme for this
indicator; `AnimalLoading.show` accepts the same `style`. The theme's
`components.loading` applies an `AnimalLoadingStyle` to every indicator. The
indicator color and the full-screen barrier color come from the style's
`color` and `barrierColor` fields. Unset fields fall back to defaults derived
from the active tokens: the indicator uses `colors.primaryText`, the tip uses
bold `typography.caption` on a pill surface with `shadows.softElevation`, the
barrier is the translucent page background and the snow particles use
`colors.info`. The indicator `size` and the dot proportions stay constructor
parameters; `size` defaults to 40 for the unnamed and `spinner` constructors,
48 for `snowflake` and 32 for `dots`.

## Example
See [`loading_story.dart`](../../../example/lib/stories/loading_story.dart) in the example Gallery.
