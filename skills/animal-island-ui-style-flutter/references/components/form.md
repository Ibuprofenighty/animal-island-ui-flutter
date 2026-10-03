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
Changes to values, rules, field registrations, reset state, or the default handler
cancel an active local submit even while its handler is pending. Late handler
completion cannot affect a replacement operation; external effects remain outside
the form's cancellation control.

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
