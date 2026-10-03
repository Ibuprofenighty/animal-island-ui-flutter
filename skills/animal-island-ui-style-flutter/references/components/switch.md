<!-- generated:api:start -->
# AnimalSwitch Reference

- **Class**: `AnimalSwitch`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

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

Under the N15 target layout, the built-in `small` and `defaultSize` presets set minimum track dimensions of 46×26 and 58×32 logical pixels. The track uses its required inset shadow and has no outer shadow; the bordered thumb stays flat. Thumb diameters are 18/24 logical pixels, the track border is 1.5 logical pixels, the thumb border is 1.2 logical pixels, and the label/thumb gap is 4 logical pixels. The public `size` enum selects these presets; it does not expose arbitrary track geometry. `checkedChildren` and `unCheckedChildren` each mount once and share a stable label area beside the thumb. Both labels use the same constrained layout, and their actual content dimensions determine an area that fits either state alongside the thumb and padding. The track stays stable across toggles. During a transition, the outgoing label fades before thumb travel, the label area stays clear while the thumb moves, and the incoming label fades in after arrival. The inactive child is hidden from semantics, focus, pointer activation, and ticker activity.

Label text defaults to 11/13 logical pixels with preset bold weight for `small`/`defaultSize`. The theme supplies the label's font family, fallbacks, line height, and letter spacing; the current switch state supplies its color. The active `TextScaler` is honored, and caller-provided `Text.style` can override these defaults. Text wraps and can grow the track height instead of shrinking or being ellipsized, including at 200% text scale. The thumb travels between the full track's padded logical ends; label placement follows text direction. The focus outline follows the expanded track and the hit target has a minimum 48×48 logical-pixel area. Switch track and thumb are finite user-triggered transitions. Their N10 motion policy respects the system reduced-motion preference, `TickerMode`, and app foreground state; when animation is disabled, duration is zero. Focus controls the outline and does not suppress these transitions.

## Finite width

`AnimalSwitch` requires a finite `maxWidth`. In a bounded `Row`, use `Flexible` or give it finite constraints with `ConstrainedBox`. For horizontal scrolling, put a `LayoutBuilder` before the scrollable to capture the actual finite viewport width, then pass that bound to a `ConstrainedBox` around the switch. Unbounded width is rejected.

## Controlled state and interaction

`value` is caller-owned and `onChanged` proposes its inverse. The switch displays the supplied value until the caller rebuilds with an accepted update. `disabled` and `loading` prevent focus and activation. `readOnly` prevents activation while keeping the switch focusable and exposing read-only semantics without a tap action, including when `onChanged` is null. Without `readOnly`, a null callback behaves as disabled. Pointer, Enter/Space, and accessibility activation each produce at most one proposal; the hit target is at least 48 logical pixels.

## Example
See [`switch_story.dart`](../../../../example/lib/stories/switch_story.dart) in the example Gallery.
