<!-- generated:api:start -->
# AnimalForm Reference

- **Class**: `AnimalForm`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalForm`

## Properties
- `child`
- `controller`
- `initialValues`
- `onChanged`
- `onSubmit`

<!-- generated:api:end -->

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
See [`form_story.dart`](../../../../example/lib/stories/form_story.dart) in the example Gallery.

`AnimalFieldKey<T>` is a final class, so external libraries cannot extend or
implement it to override identity equality or hashing. Identity belongs to one
key object; `debugLabel` is only for diagnostics. Keep keys stable while their
form is mounted. Read submit and
change snapshots with `AnimalFormValues.valueFor(key)`, which preserves the
field's generic type. Use `AnimalFormValues.fromEntries` and
`AnimalFieldValue<T>` for typed initial values. Collection keys copy and freeze
flat list, set, and map values while preserving element types. Nested
collections require an explicit deep snapshot callback.

`onSubmit` returns `FutureOr<bool>`: true accepts the validated snapshot and
false returns `AnimalSubmitStatus.rejected`. Thrown exceptions are retained in
`AnimalSubmitResult.error` for caller presentation. If no handler is installed,
a valid submit completes after validation only. Built-in field issues stay
locale-neutral and `AnimalFormItem` formats them for the active locale.
Changing a value, rules, field set, or the form's handler, unregistering or
re-registering a field, starting a new validation (including the validation a
field runs when it loses focus), resetting, clearing or disposing while the
submit is validating or its handler is pending cancels that local submit. Late handler completion cannot
affect a replacement operation; external effects remain outside the form's
cancellation control.

`submit()` completes with an `AnimalSubmitResult` whose `status` is one of:

- `success`: every field validated and the handler accepted the snapshot, or no
  handler was installed.
- `invalid`: at least one field failed validation.
- `rejected`: the handler returned false.
- `busy`: another submission was already in progress; nothing was validated.
- `changedDuringValidation`: the submission was cancelled by one of the changes
  above.
- `error`: the handler threw; the exception is in `AnimalSubmitResult.error`.

`AnimalRule` compares built-in configuration by value and custom validator
callbacks by identity. Reuse the same callback when rebuilding a custom rule;
replacing it invalidates the previous validation attempt.

The controller captures the registration baseline. `dirty` means the current
value differs from that baseline. `reset()` restores the baseline and clears
touched state and issues; `clear()` sets values to null, keeps baselines and
touched state, and clears issues.
Store each key in a stable owner, usually a `State` field, so ordinary rebuilds
reuse the same object identity and baseline.

Text fields opt in with `AnimalFormItem.textController`. Use the same stable,
caller-owned controller for `AnimalInput.controller`; it is the only current
text source and the form borrows it without disposing it. Its full initial
`TextEditingValue` is the seed, empty text reads as null, and selection/composing
only edits do not change the form value. Do not provide that key through form or
item initial values. Non-text String values continue to use scalar registration.
