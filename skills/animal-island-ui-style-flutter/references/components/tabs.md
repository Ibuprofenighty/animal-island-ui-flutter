<!-- generated:api:start -->
# AnimalTabs Reference

- **Class**: `AnimalTabs`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalTabs`

## Properties
- `onChanged`
- `scrollable`
- `selectedId`
- `style`
- `tabs`

<!-- generated:api:end -->

## Localization
AnimalTabItem.label is caller-owned and supplies both visible text and the tab semantics label. Pass a localized label.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`tabs_story.dart`](../../../../example/lib/stories/tabs_story.dart) in the example Gallery.

Keyboard navigation reveals the focused tab even when the caller rejects its proposal. Live text-scaler and LTR/RTL direction changes remeasure the indicator after layout, preserving the selected ID without emitting a selection proposal.

## Ownership and customization

Every `AnimalTabItem` requires a nonempty unique `id`. Supply `selectedId` and `onChanged`; null means no selection. Unknown or disabled selected IDs throw `ArgumentError`, so delete a selected item and update the ID together. The caller owns selection. Arrow keys, Home and End move one roving focus and propose an enabled ID; horizontal arrows mirror in RTL. A rejected proposal leaves selection unchanged. Enter/Space and pointer activation propose the focused ID, including the current ID. Labels, text scaling and available width remeasure the indicator; a selected scrollable tab is revealed. Reordering keeps focus with the ID.

Use `AnimalTabsStyle` through `style` or `AnimalIslandTheme.components.tabs`, with instance > component theme > token precedence. See the component documentation for every field and its validation. There are no size presets.
