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
- `initialValue`
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
- `suffix`
- `textInputAction`
- `value`

## Enums
- `AnimalInputSize`
- `AnimalInputStatus`

<!-- generated:api:end -->

## Localization
The clear action label uses generated AnimalLocalizations. placeholder, prefix, suffix, and entered content remain caller-owned.

## Interaction and accessibility

Text editing is handled by the underlying `TextField`. The clear action responds to pointer taps and to Enter or Space when focused,. A supplied `FocusNode` stays owned by the caller, and the input follows a replacement node.

## Example
See [`input_story.dart`](../../../../example/lib/stories/input_story.dart) in the example Gallery.
