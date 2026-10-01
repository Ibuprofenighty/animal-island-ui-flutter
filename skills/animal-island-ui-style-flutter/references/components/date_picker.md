<!-- generated:api:start -->
# AnimalDatePicker Reference

- **Class**: `AnimalDatePicker`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalDatePicker`

## Properties
- `allowClear`
- `disabled`
- `disabledDate`
- `firstDate`
- `focusNode`
- `lastDate`
- `onChanged`
- `onRangeChanged`
- `picker`
- `range`
- `rangeValue`
- `showToday`
- `value`

## Enums
- `AnimalDatePickerMode`

<!-- generated:api:end -->

## Localization
Default prompts and footer actions use generated AnimalLocalizations; date display, month names, weekday labels, navigation labels, and date-cell semantics follow the active Material locale. A supplied placeholder remains caller-owned.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`date_picker_story.dart`](../../../../example/lib/stories/date_picker_story.dart) in the example Gallery.
