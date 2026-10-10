<!-- generated:api:start -->
# AnimalCarousel

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Constructors
- `AnimalCarousel`
- `AnimalCarousel.uncontrolled`

## Properties
- `activeId`
- `autoPlay`
- `autoPlayInterval`
- `clock`
- `defaultActiveId`
- `items`
- `loop`
- `onChange`
- `pauseOnHover`
- `showArrows`
- `showDots`
- `style`
- `visible`

<!-- generated:api:end -->

## Localization
Carousel arrow labels and slide-position semantics use generated AnimalLocalizations and update with the active locale. Slide widgets remain caller-owned.

## Interaction and accessibility

Each actionable part responds to pointer taps and, when focused, to Enter or Space, with matching accessibility semantics and focus handling. Where the component groups several items, keyboard navigation between them is handled by the component itself. Each action has a 48 logical-pixel hit target, adjacent actions do not overlap, and a pending activation is cancelled when the control loses focus, is disabled, is hidden, has its callback replaced, or is unmounted.

Autoplay uses the component-owned motion scheduler. It pauses in the background, under a disabled `TickerMode` or reduced-motion preference, while focus is inside the carousel, while hovered when `pauseOnHover` is enabled, and when the owner sets `visible: false`. The `visible` input controls decorative work, including autoplay and page/dot transitions; it does not hide or measure the carousel. Becoming invisible ends running transitions and settles the current owner value immediately. Reduced motion, disabled TickerMode and background policy also end these transitions; resuming does not replay them. Resume starts one fresh interval and does not advance for time spent paused. Inject `AnimalClock` to control autoplay elapsed time in deterministic tests; the default is `SystemClock`.

## Example
See [`carousel_story.dart`](../../../example/lib/stories/carousel_story.dart) in the example Gallery.

## Ownership and boundaries

Wrap slides in `AnimalCarouselItem(id: ..., child: ...)` with nonempty unique IDs. `AnimalCarousel` requires `activeId` and only proposes changes; use `AnimalCarousel.uncontrolled` with optional `defaultActiveId` for component ownership. A controlled nonempty list requires an existing ID; an empty list requires null. Delete and update controlled selection atomically. Uncontrolled deletion of the current item selects the first remaining item without notifying; an empty list has no selection. Reordering synchronizes the page controller by ID. Every construction requires an existing defaultActiveId, or null for the first item or empty list. Remove a deleted default ID in the same rebuild as its item; valid default changes do not reset mounted selection. RTL mirrors arrow positions and glyphs for logical previous/next navigation. Ownership cannot change while mounted. External updates never echo callbacks; rejected swipes restore the authoritative slide. `autoPlayInterval` must be positive, even when autoplay is disabled. Non-loop autoplay stops at the last slide. Focus, hover, visibility, background, reduced motion and TickerMode pause through the shared motion scheduler; resume starts one fresh interval. `visible` controls work eligibility and does not hide the widget. Inject `AnimalClock` for deterministic time.

## Customization

Use `AnimalCarouselStyle` on `style` or `AnimalIslandTheme.components.carousel`. Each field resolves instance > component theme > token default. Null inherits the lower layer. Invalid numeric dimensions, insets, radii and durations throw `ArgumentError` in debug and release. There are no size presets. The 48px action target remains fixed.

Set the carousel height with `AnimalCarouselStyle(height: ...)`. Height follows the same instance > component theme > default resolution as every visual field; the default is 200 logical pixels. Both value-ownership constructors use this one visual input.

| Field | Rendered decision |
| --- | --- |
| `height` | Carousel height. |
| `backgroundColor` | Empty carousel fill. |
| `borderColor` | Empty carousel outline. |
| `borderWidth` | Empty carousel outline width. |
| `borderRadius` | Slide corners. |
| `dotBorderRadius` | Corner radius of the dot rail |
| `arrowColor` | Arrow foreground. |
| `arrowBackgroundColor` | Arrow fill. |
| `arrowIconSize` | Arrow icon size. |
| `controlInset` | Distance of controls from the slide edge. |
| `controlPadding` | Arrow insets. |
| `dotColor` | Unselected dot fill. |
| `activeDotColor` | Selected dot fill. |
| `dotSize` | Dot height and unselected width. |
| `activeDotWidth` | Selected dot width. |
| `dotGap` | Space between dot hit areas. |
| `dotPadding` | Indicator rail insets. |
| `dotBackgroundColor` | Indicator rail fill. |
| `shadow` | Indicator rail elevation. |
| `duration` | Slide and dot transition duration. |
| `dotDuration` | Dot transition duration |
| `curve` | Slide and dot transition curve. |
