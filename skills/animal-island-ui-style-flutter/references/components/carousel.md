<!-- generated:api:start -->
# AnimalCarousel Reference

- **Class**: `AnimalCarousel`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

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
See [`carousel_story.dart`](../../../../example/lib/stories/carousel_story.dart) in the example Gallery.

## Ownership and customization

Wrap slides in `AnimalCarouselItem(id: ..., child: ...)` with nonempty unique IDs. `AnimalCarousel` requires `activeId` and only proposes changes; use `AnimalCarousel.uncontrolled` with optional `defaultActiveId` for component ownership. A controlled nonempty list requires an existing ID; an empty list requires null. Delete and update controlled selection atomically. Uncontrolled deletion of the current item selects the first remaining item without notifying; an empty list has no selection. Reordering synchronizes the page controller by ID. Every construction requires an existing defaultActiveId, or null for the first item or empty list. Remove a deleted default ID in the same rebuild as its item; valid default changes do not reset mounted selection. RTL mirrors arrow positions and glyphs for logical previous/next navigation. Ownership cannot change while mounted. External updates never echo callbacks; rejected swipes restore the authoritative slide. `autoPlayInterval` must be positive, even when autoplay is disabled. Non-loop autoplay stops at the last slide. Focus, hover, visibility, background, reduced motion and TickerMode pause through the shared motion scheduler; resume starts one fresh interval. `visible` controls work eligibility and does not hide the widget. Inject `AnimalClock` for deterministic time.

Use `AnimalCarouselStyle` through `style` or `AnimalIslandTheme.components.carousel`, with instance > component theme > token precedence. See the component documentation for every field and its validation. There are no size presets.

Configure height through `AnimalCarouselStyle(height: ...)`; both value-ownership constructors resolve the same Style input against the component theme and the 200 logical-pixel default.
