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
Changing a value, rules, field set, or the form's handler, unregistering or
re-registering a field, starting a new validation (including the validation a
field runs when it loses focus), resetting, clearing or disposing while the
submit is validating or its handler is pending cancels that local submit. Late
handler completion cannot alter a replacement submit; external effects already
started by the handler remain outside the form's cancellation control.

`submit()` completes with an `AnimalSubmitResult` whose `status` is one of:

- `success`: every field validated and the handler accepted the snapshot, or no
  handler was installed.
- `invalid`: at least one field failed validation.
- `rejected`: the handler returned false.
- `busy`: another submission was already in progress; nothing was validated.
- `changedDuringValidation`: the submission was cancelled by one of the changes
  above.
- `error`: the handler threw; the exception is in `AnimalSubmitResult.error`.

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

## Controller

`AnimalFormController` reads and drives the registered fields:

- `valueFor(key)`, `getFieldError(key)` and `getFieldStatus(key)` read one
  field; `values` is an immutable snapshot of every field; `isDirty` reports
  whether any field differs from its baseline; `isSubmitting` is true while
  `submit` runs.
- `setValue(key, value, validate: true)` writes a field; `validateField(key)`
  and `validate(fieldKeys:, autoFocus:)` run the rules with latest-wins
  results; `focusFirstError()` focuses the first invalid field.
- `submit(onSubmit:)`, `reset()` and `clear()` are described above.

The controller notifies its listeners when values, validation or submission
state change. It is owned by its creator: dispose it when the form is gone.
After `dispose`, starting new work (`setValue`, `validate`, `validateField`,
`submit`, `reset`, `clear`, `focusFirstError`) throws a `StateError`, work
already in flight settles without effect, and reads report an empty form.
`reset` and `clear` cannot be re-entered: while they write the fields, a
listener (for example of a borrowed `TextEditingController`) that starts form
work gets a `StateError`. Unregistering a field is still allowed and drops it
from the write; disposing the form is allowed and ends the call without
notifying. Field and form listeners are notified once after the write, see the
final state and may start new work.

## Example
See [`form_story.dart`](../../../example/lib/stories/form_story.dart) in the example Gallery.
