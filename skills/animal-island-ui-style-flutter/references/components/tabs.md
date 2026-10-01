<!-- generated:api:start -->
# AnimalTabs Reference

- **Class**: `AnimalTabs`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalTabs`

## Properties
- `onChanged`
- `scrollable`
- `selectedIndex`
- `tabs`

<!-- generated:api:end -->

## Known limitation

When a narrow layout changes the selected tab, the active tab may not be brought
into view.

## Localization
AnimalTabItem.label is caller-owned and supplies both visible text and the tab semantics label. Pass a localized label.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`tabs_story.dart`](../../../../example/lib/stories/tabs_story.dart) in the example Gallery.
