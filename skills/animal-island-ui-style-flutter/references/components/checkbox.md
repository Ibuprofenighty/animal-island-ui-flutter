<!-- generated:api:start -->
# AnimalCheckbox Reference

- **Class**: `AnimalCheckbox`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalCheckbox`

## Properties
- `disabled`
- `focusNode`
- `indeterminate`
- `label`
- `onChanged`
- `readOnly`
- `size`
- `style`
- `value`

## Enums
- `AnimalCheckboxSize`

<!-- generated:api:end -->

## Localization
The optional checkbox label and group option labels are caller-owned. Localize those labels in the caller; the control adds state semantics without fixed text.

## Controlled state and interaction

`value` is caller-owned and `onChanged` proposes its inverse. `indeterminate` presents mixed semantics while `value` is false; a checked value takes precedence. `readOnly` prevents activation but keeps the item focusable with read-only semantics and no tap action, even when `onChanged` is null. Without `readOnly`, a null callback behaves as disabled. Each pointer, Enter/Space, or accessibility activation produces at most one proposal, with a hit target of at least 48 logical pixels.

`AnimalCheckboxGroup` takes immutable snapshots of its `List<T>` value and options. Option values must be unique; duplicates are rejected at construction. Its callback receives an immutable proposed list, and the group does not register each option as a separate form field. Every checkbox remains an independent Tab stop. Arrow and Home/End keys can move focus among enabled options without changing the value; option focus remains keyed by `option.value` when the list is reordered.

Field validation feedback belongs to the surrounding `AnimalFormItem`, which formats and announces the error; the checkbox keeps ownership of only its checked and mixed state.

## Customization

`style` takes an `AnimalCheckboxStyle` and overrides the theme for this
checkbox; `AnimalCheckboxGroup.style` forwards one style to every item. The
theme's `components.checkbox` (`AnimalCheckboxThemeData`) applies a general
`style` and optional `smallStyle`, `middleStyle` and `largeStyle`. Unset fields
fall back to defaults derived from the active tokens: the label is
`typography.body` scaled by 13/14, 14/14 or 16/14 by size, the label gap is
`spacing.sm`, and the focused border uses the library focus color. The default
box is 18/22/26 logical pixels with a 12/14/18 check glyph and 5/6/7 corner
radii; `boxSize`, `iconSize`, `borderRadius`, `borderWidth` and `labelGap`
override them.

`fillColor`, `borderColor`, `checkColor` and `labelTextColor` resolve against
`WidgetState.selected` (checked or indeterminate), `disabled` and `focused`.
The focus glow follows the resolved border color. A long label wraps inside
the available width; the hit target stays at least 48 logical pixels.

## Example
See [`checkbox_story.dart`](../../../../example/lib/stories/checkbox_story.dart) in the example Gallery.
