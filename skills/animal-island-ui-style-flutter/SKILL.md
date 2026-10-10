---
name: animal-island-ui-style-flutter
description: Use the animal_island_ui Flutter package to compose cozy island-style interfaces, checking the package's actual public declarations before generating code.
---

# Animal Island UI consumer skill

Build Flutter screens with `animal_island_ui`: 36 island-style components and
101 vector icons. [中文镜像](SKILL.zh-CN.md) is a translation of this entry, not a
separately installed skill.

Use `AnimalIcons` for canonical vectors. For custom `AnimalIconData.svg` input,
follow the restricted SVG vocabulary and size limits in the [icon reference](references/components/icon.md);
empty or unsupported SVG input throws `ArgumentError` when rendered.
Tint alpha uses three-decimal canonical precision; affected `stroke-opacity` is
updated while ordinary group `opacity` is preserved. Positive custom stroke
widths use two decimal places; zero and negative widths canonicalize to `0`.

## Read first

- [Package metadata](../../pubspec.yaml): SDK constraints and dependencies.
- [Public root](../../lib/animal_island_ui.dart): the only import; check exported
  symbols and required parameters here.
- [Setup](references/setup.md), [theme and tokens](../../docs/en/tokens.md),
  [Gallery workflows](../../docs/en/workflows.md).
- License: CC BY-NC 4.0. Do not imply that it grants commercial use.

## Rules for using the package

1. Never invent parameters or enum values. Inspect the actual exported
   constructor and make sure the code compiles against the package version in use.
2. Import `package:animal_island_ui/animal_island_ui.dart`; do not import `src`
   or reach into Gallery internals.
3. Install the theme with `AnimalIslandTheme.light.toThemeData()`, the dark preset
   or a custom theme's same conversion. Read its six token families (`colors`,
   `typography`, `radii`, `spacing`, `shadows`, `motion`) through
   `AnimalIslandTheme.of(context)`; a missing extension throws `StateError`. There
   are no static token constants, and the theme is never inferred from host brightness.
4. Keep one owner for each piece of state. Dispose only the controllers and
   resources your code owns.
5. `AnimalModal` and `AnimalDrawer` are shown as routes; `AnimalNotification` and
   `AnimalLoading` are displayed in an overlay. Use each through its own API.
   `AnimalModal.confirm` returns `Future<bool>` (`true` only when confirmed);
   `AnimalModal.show<T>` and `AnimalDrawer.show<T>` return `Future<T?>`: the value
   passed to the `close` callback their builders receive, or `null` when
   dismissed. Both open on the nearest `Navigator`; while an `onConfirm` is
   pending, every close request is ignored.
   `AnimalLoading.show` needs an `AnimalOverlayHost` above the context and returns
   a handle whose idempotent `close()` is the only way to remove the loading.
   `AnimalNotification.open` also needs a host and returns an
   `AnimalNotificationHandle` (`status`, idempotent `close()`); a full placement
   queue (3 shown, 50 waiting) returns it `rejected`. A live business `key` updates
   its notification in place; `AnimalNotification.closeAll(context)` closes that
   host's notifications.
   For a custom overlay, `AnimalOverlayHost.of(context)` returns the host's
   `AnimalOverlayController`: `show(builder:, onClose:)` returns an
   `AnimalOverlayEntryHandle` with an idempotent `close()` and `isClosed`;
   `close(handle)` closes one occurrence of this controller (a handle of
   another controller throws an `ArgumentError`), and `closeAll()` closes every
   occurrence of that host. A controller you pass to
   the host stays yours; dispose it only after the host is removed.
6. Follow each component's own geometry and states; for example, the stacked depth
   shadow belongs to filled primary and danger buttons, not to every widget.
7. When customizing colors, keep readable foreground/background pairs and use the
   semantic `*Text` roles for text on ordinary surfaces.
8. Customize component visuals through one path. A component's `style`
   parameter overrides `AnimalIslandTheme.components`, which overrides defaults
   derived from the token families; both layers use the same `Animal*Style`
   type (for example `AnimalInputStyle`). Sized components also accept per-size
   theme styles such as `middleStyle`. Never wrap a component to restyle it, and
   never hard-code a value the style or tokens already provide.

## Interaction

Actionable components and interactive icons use one shared activation and focus
owner. A read-only control remains focusable and exposes no activation action;
a null callback without `readOnly` behaves as disabled. Radio groups use one
roving Tab stop and move through enabled options with arrow/Home/End keys;
checkbox options keep independent Tab stops, and their navigation only moves
focus. Hit targets are at least 48 logical pixels. Pending activation is
cancelled when focus is lost or the control is disabled, hidden or removed.
Switch, checkbox, radio and select values remain caller-owned; callbacks propose
updates. Option lists are immutable snapshots with unique `option.value` values.
The N15 layout target for `AnimalSwitch` sets the built-in `small` and
`defaultSize` track minima to 46×26 and 58×32 logical pixels. Their thumb
diameters are 18/24 logical pixels, the track border is 1.5 logical pixels,
the thumb border is 1.2 logical pixels, and the label/thumb gap is 4 logical
pixels.
The track requires an inset shadow and has
no outer shadow; the bordered thumb remains flat. The public `size` enum selects
these presets, and `AnimalSwitchStyle` (instance or `components.switchControl`)
overrides any of them. ON/OFF
children mount once and share a stable label area beside the thumb. Both labels
use the same constrained layout, and their actual content dimensions determine
an area that fits either state alongside the thumb and padding. During a
transition, the outgoing label fades before thumb travel, the label area stays
clear while the thumb moves, and the incoming label fades in after arrival.
Label text defaults to 11/13 logical pixels with preset bold weight for
`small`/`defaultSize`. The theme supplies the label's font family, fallbacks,
line height, and letter spacing; the current switch state supplies its color. The
active `TextScaler` is honored, and caller-provided `Text.style` can override
these defaults. Text wraps and can grow the track rather than shrinking or
being ellipsized, including at
200% scale.

`AnimalSwitch` requires a finite `maxWidth`. In a bounded `Row`, use `Flexible`
or a finite `ConstrainedBox`. For horizontal scrolling, place a `LayoutBuilder`
before the scrollable to capture its actual finite viewport width, then pass
that bound through a `ConstrainedBox` around the switch. Unbounded width is
rejected. The thumb travels between the expanded track's padded logical ends;
RTL follows text direction. The outer focus outline follows the expanded track
and the hit target is at least 48×48 logical pixels. Switch track and thumb are
finite, user-triggered transitions. Their N10 motion policy respects the system
reduced-motion preference, `TickerMode`, and app foreground state; when it
disables animation, duration is zero. Focus controls the outline and does not
suppress these transitions.
`AnimalSelect` uses one adaptive option-row extent based on the theme body style,
active `TextScaler`, and vertical spacing. Rows show up to two lines with
ellipsis and keep a minimum 48×48 logical-pixel hit target. Theme tokens supply
menu colors, body typography, radii, and spacing. Menu width and list viewport
height default to a 320 logical-pixel cap (`menuMaxWidth`, `menuMaxHeight`); width
also fits the available viewport minus 24 logical pixels. The trigger label defaults to theme body scaled by 15/14,
with state-dependent color and active `TextScaler`. `AnimalSelectStyle`
overrides trigger, menu and option geometry, text and colors; the 48 logical-pixel
option floor stays fixed, and the list remains lazy.
Checkbox field errors are formatted and announced by the surrounding
`AnimalFormItem`; the checkbox owns only its checked and mixed state.

## Localization and validation

`AnimalLocalizations` and `resolveAnimalLocale` are exported from the package root.
Install the generated delegates and supported locales on the host `MaterialApp`;
Chinese locales resolve to Chinese and missing or unsupported locales to English.
`AnimalFormController.getFieldError(key)` returns a locale-neutral
`AnimalValidationIssue` for programmatic checks. Form fields use stable
`AnimalFieldKey<T>` instances identify fields by object identity. The key class
is final, so external libraries cannot extend or implement it; labels do not
identify fields. Read change and submit snapshots with
`AnimalFormValues.valueFor(key)` to retain the key's value type. Use the typed
collection snapshot factories in the [form reference](references/components/form.md).
Let `AnimalFormItem` display built-in issue text; do not add a
second issue-to-message map. Caller-provided validation messages are shown as
written. `AnimalForm.onSubmit` uses one `FutureOr<bool>` contract: true accepts
the snapshot, false returns the typed rejected result, and thrown exceptions are
returned to the caller. Without a handler, a valid form completes validation-only
submission. See the [form reference](references/components/form.md) for details.
For a text field, create one caller-owned `TextEditingController` in `State` and
pass it to both `AnimalFormItem.textController` and `AnimalInput.controller`.
The form reads current text from that buffer; empty text is null, and the key
must not also appear in `initialValues` or `initialValue`. `AnimalInput.onChanged`
is a caller notification, not a second form value write. A non-text String field
remains a scalar value.
For large text scales, `AnimalInput` bounds and wraps prefix/suffix content and
grows beyond the selected size's minimum height while keeping text readable and
the editing area clear.
Value, rule, registration, reset, or default-handler changes cancel an active
local submit even while its handler is pending; late handler completion cannot
affect a replacement operation.
`AnimalRule` compares built-in configuration by value and custom validator
callbacks by identity; reuse the callback to preserve a custom rule across rebuilds.

## Component references

| Component | Slug | Reference |
| :--- | :--- | :--- |
| `AnimalButton` | `button` | [button.md](references/components/button.md) |
| `AnimalIcon` | `icon` | [icon.md](references/components/icon.md) |
| `101 Icons Browser` | `icons` | [icons.md](references/components/icons.md) |
| `AnimalTypewriter` | `typewriter` | [typewriter.md](references/components/typewriter.md) |
| `AnimalCursor` | `cursor` | [cursor.md](references/components/cursor.md) |
| `AnimalCard` | `card` | [card.md](references/components/card.md) |
| `AnimalTitle` | `title` | [title.md](references/components/title.md) |
| `AnimalDivider` | `divider` | [divider.md](references/components/divider.md) |
| `AnimalBackground` | `background` | [background.md](references/components/background.md) |
| `AnimalCollapse` | `collapse` | [collapse.md](references/components/collapse.md) |
| `AnimalTabs` | `tabs` | [tabs.md](references/components/tabs.md) |
| `AnimalCarousel` | `carousel` | [carousel.md](references/components/carousel.md) |
| `AnimalInput` | `input` | [input.md](references/components/input.md) |
| `AnimalSwitch` | `switch` | [switch.md](references/components/switch.md) |
| `AnimalCheckbox` | `checkbox` | [checkbox.md](references/components/checkbox.md) |
| `AnimalRadio` | `radio` | [radio.md](references/components/radio.md) |
| `AnimalSelect` | `select` | [select.md](references/components/select.md) |
| `AnimalDatePicker` | `date_picker` | [date_picker.md](references/components/date_picker.md) |
| `AnimalTimePicker` | `time_picker` | [time_picker.md](references/components/time_picker.md) |
| `AnimalForm` | `form` | [form.md](references/components/form.md) |
| `AnimalFormItem` | `form_item` | [form_item.md](references/components/form_item.md) |
| `AnimalModal` | `modal` | [modal.md](references/components/modal.md) |
| `AnimalDrawer` | `drawer` | [drawer.md](references/components/drawer.md) |
| `AnimalTooltip` | `tooltip` | [tooltip.md](references/components/tooltip.md) |
| `AnimalProgress` | `progress` | [progress.md](references/components/progress.md) |
| `AnimalLoading` | `loading` | [loading.md](references/components/loading.md) |
| `AnimalSkeleton` | `skeleton` | [skeleton.md](references/components/skeleton.md) |
| `AnimalBackTop` | `back_top` | [back_top.md](references/components/back_top.md) |
| `AnimalCountdown` | `countdown` | [countdown.md](references/components/countdown.md) |
| `AnimalTime` | `time` | [time.md](references/components/time.md) |
| `AnimalNotification` | `notification` | [notification.md](references/components/notification.md) |
| `AnimalTable` | `table` | [table.md](references/components/table.md) |
| `AnimalPagination` | `pagination` | [pagination.md](references/components/pagination.md) |
| `AnimalCodeBlock` | `code_block` | [code_block.md](references/components/code_block.md) |
| `AnimalTag` | `tag` | [tag.md](references/components/tag.md) |
| `AnimalImage` | `image` | [image.md](references/components/image.md) |
| `AnimalFooter` | `footer` | [footer.md](references/components/footer.md) |

## Workflows

Complete examples that combine several components:

- [Form](references/recipes/form_workflow.md)
- [Overlay](references/recipes/overlay_workflow.md)
- [Data](references/recipes/data_workflow.md)

## Stable navigation and data contracts

Navigation and data use stable identities. Tabs selection is caller-owned by `selectedId`; live LTR/RTL direction changes realign its indicator without proposing a selection. Carousel makes controlled `activeId` and `.uncontrolled(defaultActiveId: ...)` ownership explicit; configure its height through `AnimalCarouselStyle.height`. Rejected proposals never commit locally. Table requires stable unique row keys and validates every requested cell schema. Pagination validates its caller-owned page against an exact integer page count. All five expose one style type through the instance and component theme, with no size presets.

An overflowing Table viewport is keyboard reachable: Tab, Left/Right (RTL mirrored), Home/End and PageUp/PageDown scroll the shared header/body geometry. Its child editors retain their keys.

Collapse and uncontrolled Carousel require valid default IDs at every construction; clean deleted defaults in the same rebuild as their items. Changing valid defaults does not reset mounted state. Carousel interrupts running page/dot motion when policy stops it, and RTL arrows follow logical previous/next. Pagination measures page and ellipsis labels with their own typography.
