<!-- generated:api:start -->
# AnimalForm

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalForm`

## Properties
- `child`
- `controller`
- `initialValues`
- `onChanged`
- `onSubmit`

<!-- generated:api:end -->

## Validation state and locale

`AnimalFormController` stores a locale-neutral `AnimalValidationIssue?` for each
field. Use its `kind` for programmatic decisions instead of parsing display text.
Changing locale preserves the stored issue and does not rerun validation.

## Typed field ownership

`AnimalFieldKey<T>` is a final class and an opaque object identity. External
libraries cannot extend or implement it to override equality or hashing. Keep
one key instance for a field for as long as the form uses it; `debugLabel` is
diagnostic text and does not identify or look up a field. Registering the same
key twice fails immediately, and unregistering an old registration token
cannot remove a newer registration that reuses the key.
Store the key in a stable owner, usually a `State` field, so ordinary rebuilds
reuse the same identity and baseline.

`AnimalForm.initialValues`, `onChanged`, and `onSubmit` use
`AnimalFormValues`. Read each field with `valueFor(key)` so the key's generic
type is preserved without a cast. Supply initial values with
`AnimalFormValues.fromEntries` and `AnimalFieldValue<T>`:

```dart
final nameKey = AnimalFieldKey<String>(debugLabel: 'name');

AnimalForm(
  initialValues: AnimalFormValues.fromEntries([
    AnimalFieldValue(nameKey, 'Islander'),
  ]),
  onSubmit: (values) {
    final String? name = values.valueFor(nameKey);
  },
  child: AnimalFormItem<String>(
    fieldKey: nameKey,
    builder: (context, binding) => AnimalInput(
      value: binding.value,
      onChanged: binding.onChanged,
    ),
  ),
)
```

The controller captures a field's baseline when it registers. `dirty` compares
the current value with that frozen baseline; returning to the baseline clears
`dirty`. `reset()` restores baselines and clears touched state and validation
issues. `clear()` writes null to each field, keeps its baseline and touched
state, and clears validation issues. A binding's `onBlur` marks it touched.

Scalar keys snapshot values directly. Use `AnimalFieldKey.list<E>`,
`AnimalFieldKey.set<E>`, or `AnimalFieldKey.map<K, V>` for flat collections;
they preserve generic types, copy the outer collection, and reject nested
collections. Nested collections require `AnimalFieldKey.withSnapshot<T>` with
a caller-supplied deep copy that freezes each nested collection.

## Example
See [`form_story.dart`](../../../example/lib/stories/form_story.dart) in the example Gallery.
