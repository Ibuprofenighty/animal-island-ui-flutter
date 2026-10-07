<!-- generated:api:start -->
# AnimalInput

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

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
The caller must provide one stable `TextEditingController` and dispose it when
its owner is done. `AnimalInput` borrows the controller, follows controller
replacement, and never disposes it. Its complete `TextEditingValue` preserves
selection and IME composing state. `onChanged` is a user-edit notification for
the caller; Form observes the same controller directly and does not need a
second value write from that callback.

The clear action label uses generated AnimalLocalizations. Placeholder,
prefix, suffix, and entered content remain caller-owned. A clear action writes
the borrowed controller once and then calls `onChanged` once; read-only inputs
do not offer a clear action.

## Interaction and accessibility

Text editing is handled by the underlying `TextField`. The clear action responds to pointer taps and to Enter or Space when focused. A supplied `FocusNode` stays owned by the caller, and the input follows a replacement node.

An error status is exposed as an invalid text-field validation result. A visible
label and validation message supplied by `AnimalFormItem` remain available to
assistive technology, while the placeholder remains the field hint. Normal
inputs have no depth shadow unless `shadow` is enabled; prefix and suffix stay
outside the editable area at every size. The selected size height is a minimum.
Prefix and suffix are bounded to part of the available width, wrap when large
text scaling needs more room, and let the input grow without shrinking text or
covering the editable area.

## Customization

`style` takes an `AnimalInputStyle` and overrides the theme for this input.
The theme's `components.input` (`AnimalInputThemeData`) applies a general
`style` and optional `smallStyle`, `middleStyle` and `largeStyle`. Unset
fields fall back to defaults derived from the active tokens: text is
`typography.body` scaled by 13/14, 15/14 or 17/14 by size, and the focused
border uses the library focus color.

Colors, including `borderColor` and `glowColor`, resolve against
`WidgetState.disabled`, `focused` and `error`; the warning status uses
`warningColor`.

The trigger border and glow follow the one rule shared by Input, Select,
DatePicker and TimePicker. A disabled trigger uses the styled border, otherwise
`borderLight` in light themes or `border` at 30% opacity in dark themes, and
has no glow. The warning status uses `warningColor`, otherwise `warningText`;
an error wins over a warning. Otherwise the styled border applies, then
`errorText` for an error, the focus-ring color when focused and `border` at
rest. An idle trigger without a status has no glow; otherwise the glow is the
styled glow color, or the border color at 45% opacity when only focused and
35% for an error or warning, with blur 4 and spread 2.

The clear action is the package's shared icon action: a 48 logical-pixel target
with a focus ring, the localized clear label as its accessible name and a hover
fill from `clearButtonBackgroundColor`, resolved against `WidgetState.hovered`;
under reduced motion the fill changes instantly. `clearIconSize` defaults to
14, 16 or 18 for the small, middle and large size, `clearButtonPadding` to
`spacing.xs` on each side,
`clearButtonBorderRadius` to a pill and `clearButtonBackgroundColor` to
transparent.

## Example
See [`input_story.dart`](../../../example/lib/stories/input_story.dart) in the example Gallery.
