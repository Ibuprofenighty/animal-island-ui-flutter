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

The controller captures the registration baseline. `dirty` means the current
value differs from that baseline. `reset()` restores the baseline and clears
touched state and issues; `clear()` sets values to null, keeps baselines and
touched state, and clears issues.
Store each key in a stable owner, usually a `State` field, so ordinary rebuilds
reuse the same object identity and baseline.
