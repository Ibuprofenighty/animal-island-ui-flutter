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
- `value`

<!-- generated:api:end -->

## Localization
When placeholder is null, the select uses the generated localized default. Option labels remain caller-owned. The clear action uses generated AnimalLocalizations; an explicit placeholder overrides only the default prompt.

## Controlled state and interaction

`value` is caller-owned and `onChanged` reports a proposed option value. Options are copied into an immutable snapshot and duplicate `option.value` identities are rejected. An unknown non-null value is retained: the trigger shows the explicit placeholder or localized default and exposes invalid semantics until the caller supplies a known value or accepts a clear proposal.

`readOnly` keeps the trigger focusable and exposes read-only semantics, but it does not open the menu or clear the value. Without `readOnly`, a null callback behaves as disabled. The menu uses a bounded lazy list; its deferred focus work rechecks the current option identity and eligibility. Arrow Up/Down and Home/End move among enabled options. Choosing an option proposes its value, closes the menu, and restores focus to the trigger. When `allowClear` is enabled, the clear action works by pointer or Enter/Space, proposes `null` once, and returns focus to the trigger. The hit target is at least 48 logical pixels.

The trigger label uses the theme body style's other typography attributes with a fixed 15 logical-pixel font size and state-dependent color. The active `TextScaler` still applies.

## Adaptive menu layout

All option rows share one adaptive extent: at least 48 logical pixels and large enough for two lines of the current theme body style at the active `TextScaler`, plus vertical theme padding. Labels show at most two lines with ellipsis, and each option keeps a minimum 48×48 logical-pixel hit target. Theme tokens supply the menu surface, border, row text and state colors, typography, radii, and spacing. The menu width and list viewport height have fixed 320 logical-pixel upper bounds; width also fits the available viewport minus 24 logical pixels, and height fits the option rows up to that cap. The public API has no menu width or height override. The bounded list remains lazy with 1,000 options.

## Example
See [`select_story.dart`](../../../example/lib/stories/select_story.dart) in the example Gallery.
