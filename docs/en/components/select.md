<!-- generated:api:start -->
# AnimalSelect

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalSelect`

## Properties
- `allowClear`
- `disabled`
- `focusNode`
- `onChanged`
- `options`
- `placeholder`
- `readOnly`
- `status`
- `style`
- `value`

<!-- generated:api:end -->

## Localization
When placeholder is null, the select uses the generated localized default. Option labels remain caller-owned. The clear action uses generated AnimalLocalizations; an explicit placeholder overrides only the default prompt.

## Controlled state and interaction

`value` is caller-owned and `onChanged` reports a proposed option value. Options are copied into an immutable snapshot and duplicate `option.value` identities are rejected. An unknown non-null value is retained: the trigger shows the explicit placeholder or localized default and exposes invalid semantics until the caller supplies a known value or accepts a clear proposal.

`readOnly` keeps the trigger focusable and exposes read-only semantics, but it does not open the menu or clear the value. Without `readOnly`, a null callback behaves as disabled. The menu uses a bounded lazy list; its deferred focus work rechecks the current option identity and eligibility. Arrow Up/Down and Home/End move among enabled options. Choosing an option proposes its value, closes the menu, and restores focus to the trigger. When `allowClear` is enabled, the clear action works by pointer or Enter/Space, proposes `null` once, and returns focus to the trigger. The hit target is at least 48 logical pixels.

The trigger label uses the theme body style scaled by 15/14 (15 logical pixels at the standard 14 logical-pixel body) with a state-dependent color. The active `TextScaler` still applies.

## Adaptive menu layout

All option rows share one adaptive extent: at least 48 logical pixels and large enough for two lines of the resolved option text style at the active `TextScaler`, plus the option's vertical padding. Labels show at most two lines with ellipsis, and each option keeps a minimum 48×48 logical-pixel hit target. Theme tokens supply the default menu surface, border, row text and state colors, typography, radii, and spacing. The menu width and list viewport height are capped by `menuMaxWidth` and `menuMaxHeight` (320 logical pixels by default); width also fits the available viewport minus 24 logical pixels, and height fits the option rows up to that cap. The bounded list remains lazy with 1,000 options.

## Customization

`style` takes an `AnimalSelectStyle` and overrides the theme for this select.
The theme's `components.select` is an `AnimalSelectStyle` that applies to
every select; Select has no size presets. Unset fields fall back to defaults
derived from the active tokens: the trigger label is `typography.body` scaled
by 15/14, option labels are `typography.body`, and the focused or open border
uses the library focus color.

Trigger colors resolve against `WidgetState.disabled`, `focused` (focused or
menu open), `error` (error status or an unknown value) and `selected` (the value
matches an option). Option colors resolve against `disabled`, `selected`,
`hovered` and `focused`. The warning status has no select visuals. Option rows
keep the 48 logical-pixel minimum extent and hit target whatever the style says.

## Example
See [`select_story.dart`](../../../example/lib/stories/select_story.dart) in the example Gallery.
