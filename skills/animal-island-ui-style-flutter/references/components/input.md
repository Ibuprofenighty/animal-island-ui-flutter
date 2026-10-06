<!-- generated:api:start -->
# AnimalInput Reference

- **Class**: `AnimalInput`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalInput`

## Properties
- `autofocus`
- `clearable`
- `controller`
- `disabled`
- `focusNode`
- `inputFormatters`
- `keyboardType`
- `maxLines`
- `minLines`
- `obscureText`
- `onChanged`
- `onSubmitted`
- `placeholder`
- `prefix`
- `readOnly`
- `shadow`
- `size`
- `status`
- `style`
- `suffix`
- `textInputAction`

## Enums
- `AnimalInputSize`
- `AnimalInputStatus`

<!-- generated:api:end -->

## Localization
The caller supplies and owns one stable `TextEditingController`; `AnimalInput`
borrows it and never disposes it. The complete `TextEditingValue` keeps selection
and IME composing state. For a form field, use the same controller in
`AnimalFormItem.textController`, so the buffer is the sole current text source.
`onChanged` only notifies the caller; form observation comes from the controller.

The clear action label uses generated AnimalLocalizations. Placeholder, prefix,
suffix, and entered content remain caller-owned. Clear writes once and calls
`onChanged` once; read-only inputs do not show a clear action.

## Interaction and accessibility

Text editing is handled by the underlying `TextField`. The clear action responds to pointer taps and to Enter or Space when focused. A supplied `FocusNode` stays owned by the caller, and the input follows a replacement node.

Error status is exposed as an invalid text-field validation result. A visible
label and validation message supplied by `AnimalFormItem` remain available to
assistive technology, while the placeholder remains the field hint. Normal
inputs have no depth shadow unless `shadow` is enabled; prefix and suffix stay
outside the editable area at every size. The selected size height is a minimum.
At large text scales, prefix and suffix stay within a bounded share of the
available width and wrap as needed; the input grows without shrinking text or
covering the editable area.

## Customization

`style` takes an `AnimalInputStyle` and overrides the theme for this input.
The theme's `components.input` (`AnimalInputThemeData`) applies a general
`style` and optional `smallStyle`, `middleStyle` and `largeStyle`. Unset
fields fall back to defaults derived from the active tokens: text is
`typography.body` scaled by 13/14, 15/14 or 17/14 by size, and the focused
border uses the library focus color.

Colors resolve against `WidgetState.disabled`, `focused` and `error`; the
warning status uses `warningColor`. The status glow follows the resolved border
color.

## Example
See [`input_story.dart`](../../../../example/lib/stories/input_story.dart) in the example Gallery.
