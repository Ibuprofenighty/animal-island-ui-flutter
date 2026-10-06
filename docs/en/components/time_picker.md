<!-- generated:api:start -->
# AnimalTimePicker

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalTimePicker`

## Properties
- `allowClear`
- `clock`
- `disabled`
- `focusNode`
- `format`
- `hourStep`
- `minuteStep`
- `onChanged`
- `secondStep`
- `showNow`
- `style`
- `value`

<!-- generated:api:end -->

## Time values and selection

`AnimalTimeValue` is an immutable time of day with hour 0–23, minute 0–59 and second 0–59; an out-of-range field throws `ArgumentError.value`. The picker keeps all three fields: a hidden seconds wheel (`format: 'HH:mm'`) still carries the value's seconds, so changing the hour or minute, Now, Clear, a reset and form submission never drop them. `AnimalTimeValue.now()` reads the canonical `AnimalClock` (`SystemClock` by default), and both presentations take the same `clock`.

`value` is the only committed time and `onChanged` proposes a new one. The parent accepts a proposal by passing it back; a value it does not accept is not kept on the wheels, which return to `value` once the scroll settles. A value off the configured steps is shown on the nearest step. `hourStep`, `minuteStep` and `secondStep` must be at least 1 (`ArgumentError` otherwise). Inline and popover presentations use one panel.

Programmatic wheel moves (a new `value`, Now, Clear or a reset to null) run as one batch that never reports its intermediate items: Now proposes its final time once and Clear proposes null once, while an external change proposes nothing. A newer value or a user drag supersedes a running batch, so an earlier Now animation can never land after a later value. User scrolling still proposes each item it settles on.

## Defaults

`AnimalTimePicker` defaults to `format: 'HH:mm'`, steps of 1, `showNow: true`, `allowClear: true`, `disabled: false` and `clock: const SystemClock()`. `AnimalTimePicker.popover(...)` uses the same defaults and adds an optional `placeholder` and `status` (`AnimalInputStatus.normal`). A disabled picker locks its wheels and its Now and Clear actions and proposes nothing.

## Localization
Default prompts, panel actions, and wheel-value semantics use generated AnimalLocalizations and refresh when the locale changes. A supplied placeholder remains caller-owned.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Customization

`style` takes an `AnimalTimePickerStyle` and overrides the theme for this
picker; `AnimalTimePicker.popover(style: ...)` applies the same style to the
trigger and its panel. The theme's `components.timePicker` is an
`AnimalTimePickerStyle` that applies to every picker (there are no size
presets). Unset fields fall back to defaults derived from the active tokens:
the title and wheel separators use `typography.heading`, the selected wheel
label `typography.subheading`, other wheel labels and the trigger text
`typography.body`, and the Now and Clear labels `typography.caption`, each at
ratio 1. The focused trigger border uses the library focus color.

Panel colors resolve against `WidgetState.disabled`; wheel labels also against
`WidgetState.selected`. The trigger border resolves against `focused` (also
while the menu is open) and `error`; the warning status uses `warningColor`,
and the status or focus glow follows the resolved border color.

`minItemExtent` (36 by default) is a minimum: each wheel item and the selection
band grow to the rendered height of the larger wheel label under the ambient
text scaler, and `wheelHeight` (160 by default) grows to show at least three
items, so labels never clip at large type or 200% text scale. Footer labels
scale down instead of overflowing a narrow panel. When the extent changes the
wheels re-centre on the shown time without proposing a value; a wheel the user
is dragging keeps its position and is re-centred when the drag ends.

## Example
See [`time_picker_story.dart`](../../../example/lib/stories/time_picker_story.dart) in the example Gallery.
