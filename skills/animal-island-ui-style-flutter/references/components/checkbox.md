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

## Example
See [`checkbox_story.dart`](../../../../example/lib/stories/checkbox_story.dart) in the example Gallery.
