<!-- generated:api:start -->
# AnimalModal Reference

- **Class**: `AnimalModal`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalModal`

## Properties
- `content`
- `footer`
- `onClose`
- `style`
- `title`
- `width`

<!-- generated:api:end -->

`AnimalModal` is the blob surface; present it as a route on the nearest
`Navigator` (there is no root-navigator fallback) through one typed entry point:

| Entry point | Result |
| --- | --- |
| `AnimalModal.confirm(context:, content:, onConfirm:)` | `Future<bool>`: `true` only when the confirm action succeeds; `false` when cancelled or dismissed |
| `AnimalModal.showDialogue(context:, speaker:, avatar:, dialogue:)` | `Future<bool>`: a confirmation whose body types the explicit `dialogue` text once; `onFinish` runs once |
| `AnimalModal.show<T>(context:, builder: (context, close) => ...)` | `Future<T?>`: the value passed to `close`; `null` when dismissed |

```dart
final bool deleted = await AnimalModal.confirm(
  context: context,
  title: const Text('Delete island?'),
  content: const Text('This cannot be undone.'),
  onConfirm: () async => api.deleteIsland(), // FutureOr<bool>
);

final String? fruit = await AnimalModal.show<String>(
  context: context,
  title: const Text('Pick a fruit'),
  builder: (context, close) => AnimalButton(
    onPressed: () => close('apple'),
    child: const Text('Apple'),
  ),
);
```

Body content is rendered exactly as given: a rich `Widget` is never re-typed
from extracted text. Use `showDialogue`, or an `AnimalTypewriter` you place in
the body, for typed text.

## Confirmation and dismissal

`onConfirm` returns `FutureOr<bool>`. `true` closes the modal with `true`;
`false` keeps it open; a thrown error keeps it open, shows the error below the
body and the action can be retried. While `onConfirm` is pending, repeated
confirm and every dismissal are ignored, so it runs once per attempt.

Cancel, the close control, Escape and system back dismiss the modal. A barrier
tap dismisses it only when `mask` and `maskClosable` are both `true`; with
`mask: false` there is no dimmed, blurred mask. Focus stays inside the modal
and returns to the opening control when it closes. Closing removes only this
route, even from a nested `Navigator` or when other routes were pushed above
it, and the result is delivered exactly once, also when the `Navigator` is
disposed (`false` or `null`). With reduced motion the modal appears without
transition.

The close control is the package's shared icon action: a 48 logical-pixel target
with a focus ring, the localized close label as its accessible name and a hover
fill from `closeButtonBackgroundColor`, resolved against `WidgetState.hovered`;
under reduced motion the fill changes instantly.

The body scrolls inside the height left by an open keyboard and the actions
wrap, so a long body at 200% text on a 320 logical-pixel screen still reaches
the actions.

## Customization

`style` takes an `AnimalModalStyle` and overrides the theme for this modal; the
theme's `components.modal` applies to every modal. Unset fields fall back to
defaults derived from the active tokens: the surface is `colors.bgContent`
with a 2 logical-pixel outline and `shadows.modal`, the title is
`typography.title` at 3/4 size and weight 800, the body is `typography.body`
scaled by 15/14 with line height 1.5, and errors use `typography.caption` in
`colors.error`. Fields cover the surface (`backgroundColor`, `borderColor`,
`borderWidth`, `shadow`, `padding`, `horizontalMargin`), text (`titleTextStyle`,
`titleTextColor`, `textStyle`, `textColor`, `errorTextStyle`, `errorTextColor`),
gaps (`headerGap`, `errorGap`, `footerGap`, `actionGap`, `avatarGap`), the close
control (`closeIconColor`, `closeIconSize`, `closeButtonPadding`,
`closeButtonBorderRadius`, a circle of radius 24 by default, and
`closeButtonBackgroundColor`, resolved against `WidgetState.hovered`) and the
mask (`barrierColor`, `barrierBlurSigma`).

The preferred surface `width` is 500 logical pixels by default. The body uses
at most 85% of the height left by the keyboard, and on a very
narrow surface each horizontal padding side yields to at most a quarter of the
surface width.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`modal_story.dart`](../../../../example/lib/stories/modal_story.dart) in the example Gallery.
