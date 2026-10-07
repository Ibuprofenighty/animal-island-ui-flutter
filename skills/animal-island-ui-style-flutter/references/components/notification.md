<!-- generated:api:start -->
# AnimalNotification Reference

- **Class**: `AnimalNotification`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalNotification`

## Properties
- `defaultDuration`

## Enums
- `AnimalNotificationPlacement`
- `AnimalNotificationStatus`
- `AnimalNotificationType`

<!-- generated:api:end -->

## Usage and lifecycle

`AnimalNotification.open` (and `success`, `error`, `warning`, `info`) shows a
notification in the nearest `AnimalOverlayHost`; a context without a host throws.
It returns an `AnimalNotificationHandle`: `status` is `active`, `waiting`,
`rejected` or `closed`, and `close()` is idempotent.
`AnimalNotification.closeAll(context, placement: ...)` closes the notifications
of the nearest host, optionally of one placement only.

- Each host keeps one synchronous queue per placement: at most 3 shown and 50
  waiting. A notification beyond that is `rejected`; older ones are never dropped.
  Closing a shown notification promotes the oldest waiting one.
- `duration` defaults to 4.5 seconds; `null` keeps the notification until it is
  closed. Hovering or focusing a notification pauses its timer.
- `key` is a business key. While an occurrence with that key is queued in the same
  placement of the same host, `open` replaces its whole configuration in place
  (content, type, duration restarted from now, `onClick`, `onClose`), keeps its
  position and returns the same handle. After it closes, the key opens a new
  occurrence.
- `onClose` runs exactly once per occurrence, whichever way it closes: close button,
  swipe, `handle.close()`, `closeAll`, timeout or removal of the host (waiting
  notifications included). A rejected notification never opened, so its `onClose`
  never runs. `onClose` may open or close notifications.
- Each card is one live region, announced when it appears or its content changes.

A closed notification leaves its placement immediately, in the same frame as
its occurrence closes; there is no exit animation to wait for. With reduced
motion a notification appears in place without sliding or fading.

The close button is the package's shared icon action: a 48 logical-pixel target
with a focus ring, the localized dismiss label as its accessible name and a
hover fill from `closeButtonBackgroundColor`, resolved against
`WidgetState.hovered`; under reduced motion the fill changes instantly.

## Customization

The `style` argument takes an `AnimalNotificationStyle` and overrides the theme for
that notification; `AnimalIslandTheme.components.notification` applies to every
notification. Unset fields fall back to defaults derived from the active tokens and
the notification type: the message is `typography.heading` scaled by 0.75 at weight
800, the description `typography.body` scaled by 13/14, and the fill, border, icon
and message colors follow the type's semantic colors. A color set in a style
replaces the type color for every type. `closeButtonBackgroundColor` resolves
`WidgetState.hovered`. The distance of a placement stack from the host edges is
`spacing.lg`.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`notification_story.dart`](../../../../example/lib/stories/notification_story.dart) in the example Gallery.
