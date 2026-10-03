<!-- generated:api:start -->
# AnimalSwitch

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalSwitch`

## Properties
- `checkedChildren`
- `disabled`
- `focusNode`
- `loading`
- `onChanged`
- `readOnly`
- `size`
- `unCheckedChildren`
- `value`

## Enums
- `AnimalSwitchSize`

<!-- generated:api:end -->

## Localization
The switch accessibility label uses generated AnimalLocalizations. checkedChildren and unCheckedChildren remain caller-owned content.

## Responsive label layout

Under the N15 target layout, the built-in `small` and `defaultSize` presets set minimum pill-track dimensions of 46×26 and 58×32. The pill track uses its required inset shadow and has no outer shadow; the bordered thumb stays flat. Thumb diameters are 18/24 logical pixels; the track border is 1.5 logical pixels, the thumb border is 1.2 logical pixels, and the label/thumb gap is 4 logical pixels. These are built-in presets; the public API does not expose arbitrary track geometry. The caller-provided `checkedChildren` and `unCheckedChildren` each mount once and share a stable label area in the free track segment beside the thumb. Both labels use the same constrained layout, and their actual content dimensions determine an area that accommodates either state. The track grows to fit that area together with the thumb and padding, so changing `value` does not resize it. During a transition, the outgoing label fades before thumb travel, the label area stays clear while the thumb moves, and the incoming label fades in after arrival. The inactive label is visually hidden and excluded from semantics, focus, pointer activation, and ticker activity.

Label text defaults to 11/13 logical pixels and bold weight for `small`/`defaultSize`; the theme supplies its font family, fallbacks, line height, and letter spacing, while the current switch state supplies its color. The active `TextScaler` is honored, and caller-provided `Text.style` can override these defaults. Text is not shrunk or ellipsized to fit; both labels use the same available space, wrap at constrained widths, and can grow the outer track in height, including at 200% text scale. The thumb travels between the padded logical ends of the full track; label placement and thumb travel follow text direction. The outer focus outline follows the expanded track; the interactive region has a minimum 48×48 logical-pixel hit area. Switch track and thumb are finite user-triggered transitions. Their shared N10 motion policy respects the system reduced-motion preference, `TickerMode`, and app foreground state; when animation is disabled, duration is zero. Focus controls the outline and does not suppress these transitions.

## Finite width

`AnimalSwitch` requires a finite `maxWidth`. In a bounded `Row`, place it in `Flexible` or give it finite constraints with `ConstrainedBox`. For horizontal scrolling, put a `LayoutBuilder` before the scrollable to capture the actual finite viewport width, then pass that bound to a `ConstrainedBox` around the switch. Unbounded width is rejected.

## Controlled state and interaction

`value` is the caller-owned state and `onChanged` proposes its inverse. The switch displays the supplied value until the caller rebuilds with an accepted update. `disabled` and `loading` prevent focus and activation. `readOnly` prevents activation while keeping the switch focusable and exposing read-only semantics without a tap action, including when `onChanged` is null. Without `readOnly`, a null callback behaves as disabled. Pointer, Enter/Space, and accessibility activation each produce at most one proposal; the hit target is at least 48×48 logical pixels.

## Example
See [`switch_story.dart`](../../../example/lib/stories/switch_story.dart) in the example Gallery.
