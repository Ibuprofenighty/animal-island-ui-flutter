<!-- generated:api:start -->
# AnimalFormItem

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalFormItem`

## Properties
- `builder`
- `fieldKey`
- `focusNode`
- `help`
- `initialValue`
- `label`
- `labelWidget`
- `margin`
- `required`
- `rules`
- `textController`

<!-- generated:api:end -->

## Validation copy and locale

`AnimalFormItem` displays built-in validation issues and resolves
them with the active generated localization. A locale change redraws the same issue;
it does not call the validator again. Caller-provided custom messages remain literal.

Every item requires a typed `fieldKey` and a `builder` that receives the live
`AnimalFieldBinding<T>` from its enclosing `AnimalForm`. The binding exposes the
current value, `dirty`, `touched`, validation status and issue, focus node, and
typed change/blur callbacks. A text binding reads its value directly from its
borrowed `TextEditingController`; its value is not a second stored text owner.
The item fails with a `StateError` if it is built
without that owner or receives an invalid registration; it never fabricates a
placeholder binding.

For scalar fields, `initialValue` is used only when the form's typed
`initialValues` snapshot has no entry for that key. The controller freezes that
value as the field baseline at registration. For a text field, explicitly pass
`textController`; its complete initial `TextEditingValue` provides the text and
editing state. Do not also set `initialValue` or include the key in
`AnimalForm.initialValues`. This opt-in is explicit even when `T` is `String`,
so non-text String choice values retain scalar behavior. Keys are instance
identities; a label does not create a string-based lookup path.

Keep the key in its owner State (or another stable owner), rather than creating
it in `build`. Ordinary rebuilds and a `GlobalKey` reparent keep the same
registration generation, current value, and baseline. A newly mounted item gets
a new generation and captures the current typed initial value as its baseline.

## Example
See [`form_item_story.dart`](../../../example/lib/stories/form_item_story.dart) in the example Gallery.
