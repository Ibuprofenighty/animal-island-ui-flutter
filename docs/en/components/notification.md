<!-- generated:api:start -->
# AnimalNotification

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalNotification`

## Properties
*No public properties.*

## Enums
- `AnimalNotificationPlacement`
- `AnimalNotificationType`

<!-- generated:api:end -->

## Locale ownership

The dismiss action uses the active generated localization. Notification messages and
descriptions are caller-owned content.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`notification_story.dart`](../../../example/lib/stories/notification_story.dart) in the example Gallery.
