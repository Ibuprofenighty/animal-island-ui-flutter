<!-- generated:api:start -->
# AnimalRadio Reference

- **Class**: `AnimalRadio`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalRadio`

## Properties
- `activeColor`
- `disabled`
- `focusNode`
- `groupValue`
- `label`
- `onChanged`
- `readOnly`
- `size`
- `style`
- `value`

## Enums
- `AnimalRadioSize`

<!-- generated:api:end -->

## Localization
The optional radio label and group option labels are caller-owned. Localize those labels in the caller; the control adds state semantics without fixed text.

## Controlled state and interaction

`AnimalRadio` proposes its `value` through `onChanged`; `AnimalRadioGroup` keeps the selected value supplied by its caller. The group snapshots its options and rejects duplicate `option.value` identities. It has one roving Tab stop. Arrow keys move through enabled options (left/right follow text direction in horizontal groups); Home and End move to the first and last enabled option. Navigation moves focus and proposes the target value, while `readOnly` allows focus movement without a proposal. On re-entry, focus follows the current enabled selection or the first enabled option. Reordering preserves focus by `option.value`. Like Select, each option shows its `icon` before its `label` and is announced by its `semanticLabel` when one is given.

`readOnly` leaves the control focusable and exposes read-only semantics without a tap action, including with a null callback. Without `readOnly`, a null callback behaves as disabled. Pointer, Enter/Space, and accessibility activation each produce at most one proposal. The hit target is at least 48 logical pixels. The three sizes use 12, 14, and 16 logical-pixel corner radii and retain the selected check glyph; `activeColor` changes the selected surface while the focus indicator remains visible.

## Customization

`style` takes an `AnimalRadioStyle` and overrides the theme for this radio;
`AnimalRadioGroup.style` forwards one style to every item. The theme's
`components.radio` (`AnimalRadioThemeData`) applies a general `style` and
optional `smallStyle`, `middleStyle` and `largeStyle`. Unset fields fall back
to defaults derived from the active tokens: the label is `typography.body`
scaled by 13/14, 14/14 or 16/14 by size, the label gap is `spacing.sm`, the
selected surface is `colors.primary`, and the focused border uses the library
focus color. The default control is 18/22/26 logical pixels with 12/14/16
corner radii and a 12/14/18 check glyph; `boxSize`, `iconSize`,
`borderRadius`, `borderWidth` and `labelGap` override them.

`fillColor`, `borderColor`, `checkColor` and `labelTextColor` resolve against
`WidgetState.selected`, `disabled` and `focused`. `activeColor` belongs to the
instance layer: it sets the enabled selected fill and border with a white
check, the instance `style` fields win over it, and it wins over the theme. The
focus glow follows the resolved border color. A long label wraps inside the
available width; the hit target stays at least 48 logical pixels.

## Example
See [`radio_story.dart`](../../../../example/lib/stories/radio_story.dart) in the example Gallery.
