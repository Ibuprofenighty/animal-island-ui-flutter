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

`AnimalRule` compares by its immutable rule configuration. Custom rules compare
their validator callbacks by identity, so rebuilding a rule with the same
callback preserves its configuration while replacing the callback invalidates
the previous validation attempt.

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

Text fields opt in with `AnimalFormItem.textController`. Create that borrowed
controller once in its caller-owned `State` and dispose it there. Its complete
`TextEditingValue` is the only text seed and live text source; an empty buffer
projects to null. Do not also provide that key in `AnimalForm.initialValues` or
`AnimalFormItem.initialValue`. A non-text String field, such as a choice value,
continues to use the ordinary immutable field value.

```dart
final nameKey = AnimalFieldKey<String>(debugLabel: 'name');
final nameController = TextEditingController(text: 'Islander');

AnimalForm(
  onSubmit: (values) {
    final String? name = values.valueFor(nameKey);
    return name != null;
  },
  child: AnimalFormItem<String>(
    fieldKey: nameKey,
    textController: nameController,
    builder: (context, binding) => AnimalInput(controller: nameController),
  ),
)
```

`onSubmit` returns `FutureOr<bool>`. Return true when the immutable snapshot is
accepted and false when the caller rejects it; `submit()` returns the typed
`rejected` outcome for false. A thrown handler exception stays in
`AnimalSubmitResult.error` for the caller to present. With no handler, a valid
form keeps the existing validation-only successful submit behavior. Field
validation issues are localized by `AnimalFormItem`; handler outcomes remain the
caller's responsibility.
Changing a value, rules, field set, or default handler, unregistering/re-registering
a field, or resetting while a handler is pending cancels that local submit. Late
handler completion cannot alter a replacement submit; external effects already
started by the handler remain outside the form's cancellation control.

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
