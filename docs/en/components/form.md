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

## Example
See [`form_story.dart`](../../../example/lib/stories/form_story.dart) in the example Gallery.
