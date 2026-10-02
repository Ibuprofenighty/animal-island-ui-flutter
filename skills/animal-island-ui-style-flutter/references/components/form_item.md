<!-- generated:api:start -->
# AnimalFormItem Reference

- **Class**: `AnimalFormItem`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

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

<!-- generated:api:end -->

## Example
See [`form_item_story.dart`](../../../../example/lib/stories/form_item_story.dart) in the example Gallery.

Supply one stable `AnimalFieldKey<T>` and a `builder` for the real
`AnimalFieldBinding<T>` owned by `AnimalForm`. The binding includes its typed
value, dirty/touched state, issue/status, focus node, and change/blur callbacks.
The form item throws `StateError` when there is no matching owner; it has no
string lookup or placeholder-binding path. `initialValue` applies only when
the form's typed `initialValues` has no entry for the key.
Keep the key in a stable owner such as a `State` field; do not construct it in
`build`. Ordinary rebuilds and `GlobalKey` reparenting preserve the current
registration generation, value, and baseline. A newly mounted item receives a
new generation and captures the current initial value as its baseline.
