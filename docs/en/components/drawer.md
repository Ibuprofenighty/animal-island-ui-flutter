<!-- generated:api:start -->
# AnimalDrawer

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalDrawer`

## Properties
- `child`
- `footer`
- `height`
- `onClose`
- `placement`
- `style`
- `title`
- `width`

## Enums
- `AnimalDrawerPlacement`

<!-- generated:api:end -->

`AnimalDrawer` is the sheet; `AnimalDrawer.show<T>` presents it as a route on
the nearest `Navigator` (there is no root-navigator fallback) and returns
`Future<T?>`: the value passed to the `close` callback that `builder` and the
optional `footerBuilder` receive, or `null` when dismissed.

```dart
final String? choice = await AnimalDrawer.show<String>(
  context: context,
  placement: AnimalDrawerPlacement.right,
  title: const Text('Settings'),
  builder: (context, close) => const Text('Sound effects: on'),
  footerBuilder: (context, close) => AnimalButton(
    onPressed: () => close('saved'),
    child: const Text('Save'),
  ),
);
```

## Placement, safe area and keyboard

`placement` is `left`, `right`, `top` or `bottom`; the preferred `width` of a
side sheet is 378 and the `height` of a top or bottom sheet 300 logical pixels
by default. The sheet never exceeds the
space it is given, so a `width` or `height` larger than the screen does not
overflow. It stays above an open keyboard and inside the safe area, so the close
control remains visible and operable at 320 logical pixels, 200% text and with
the IME open. With reduced motion the sheet
appears without sliding and stays fully operable.

## Dismissal, result and focus

The close control, Escape and system back dismiss the drawer with `null`. A
barrier tap does so only when `mask` and `maskClosable` are both `true`. Focus
stays inside the drawer and returns to the opening control when it closes.
Closing removes only this route, even from a nested `Navigator` or when other
routes were pushed above it; the result is delivered exactly once and later
`close` calls are ignored. The route is announced once with the localized
drawer label (`drawerRouteLabel`) and has no second route scope.

The close control is the package's shared icon action: a 48 logical-pixel target
with a focus ring, the localized close label as its accessible name and a hover
fill from `closeButtonBackgroundColor`, resolved against `WidgetState.hovered`;
under reduced motion the fill changes instantly.

## Customization

`style` takes an `AnimalDrawerStyle` and overrides the theme for this drawer;
the theme's `components.drawer` applies to every drawer. Unset fields fall back
to defaults derived from the active tokens: the sheet is `colors.bgContent`
with a 1.5 logical-pixel border, `shadows.modal`, and `radii.card × 1.2` on the
corners facing into the screen; the title is `typography.title` at 3/4 size and
weight 800. Fields cover the sheet (`backgroundColor`, `borderColor`,
`borderWidth`, `borderRadius`, `shadow`), the title (`titleTextStyle`,
`titleTextColor`), padding (`headerPadding`, `bodyPadding`, `footerPadding`),
the rules (`dividerColor`, `dividerThickness`), the close control
(`closeIconColor`, `closeIconSize`, `closeButtonPadding`, `closeButtonBorderRadius`,
`closeButtonBackgroundColor`, resolved against `WidgetState.hovered`) and the mask
(`barrierColor`).

## Locale behavior

Default drawer and close semantics plus the route barrier label follow the active
generated localization while the route remains open. The drawer title and body
content are caller-owned.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

## Example
See [`drawer_story.dart`](../../../example/lib/stories/drawer_story.dart) in the example Gallery.
