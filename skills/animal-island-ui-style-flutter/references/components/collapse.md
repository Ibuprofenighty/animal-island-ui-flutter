<!-- generated:api:start -->
# AnimalCollapse Reference

- **Class**: `AnimalCollapse`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalCollapse`
- `AnimalCollapse.single`

## Properties
- `accordion`
- `activeIds`
- `defaultActiveIds`
- `disabled`
- `items`
- `onChanged`
- `style`

<!-- generated:api:end -->

## Items

Each panel is an `AnimalCollapseItem`: a stable `id`, a `title` and
`content` widget, an optional trailing `extra` widget in the header, and
`disabled` to keep it from expanding or collapsing.

## Localization
Collapse item titles, content, and extras are caller-owned widgets. Localize them in the caller; the component only adds expanded/enabled semantics.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`collapse_story.dart`](../../../../example/lib/stories/collapse_story.dart) in the example Gallery.

## Ownership and customization

Use nonempty unique `AnimalCollapseItem.id` values. `activeIds` owns controlled expansion; omit it and supply `defaultActiveIds` for initial-only ownership. Do not supply both. Every construction validates defaultActiveIds against the current items, so remove deleted default IDs in the same rebuild. Valid default changes do not reset mounted expansion. Unknown IDs and multiple accordion IDs throw `ArgumentError`. While mounted, ownership cannot change. Controlled callbacks propose an immutable set; rejection leaves expansion unchanged. Reordering preserves child state and focus; deleting an uncontrolled item removes its expansion. Hidden content retains state but is excluded from input, focus and semantics. Header Enter/Space activation uses the shared interaction owner.

Use `AnimalCollapseStyle` through `style` or `AnimalIslandTheme.components.collapse`, with instance > component theme > token precedence. See the component documentation for every field and its validation. There are no size presets.
