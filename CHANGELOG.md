# Changelog

All notable changes to the `animal_island_ui` package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Localization**: package text comes from English and Chinese ARB files through
  the exported `AnimalLocalizations`, with `resolveAnimalLocale` mapping any
  Chinese locale to Chinese and everything else to English.
- **Bundled fonts**: Nunito and Noto Sans SC variable fonts ship with the package
  under package-qualified family names, with their SIL OFL 1.1 license texts.
- **Typed form issues**: `AnimalValidationIssue` and `AnimalValidationIssueKind`
  expose locale-neutral validation results for programmatic checks.
- **Gallery**: the example app covers all 36 components, the 101-icon browser and
  form, overlay and data-table workflows, and is deployed to GitHub Pages.

### Changed
- **Toolchain**: requires Flutter `>=3.47.5` and Dart `>=3.13.4`.
- **Component styles**: every input, toggle, picker, form item, notification,
  loading, modal, drawer, typewriter, progress, skeleton, countdown and time
  card takes an `Animal*Style` that overrides the theme, and
  `AnimalIslandTheme.components` restyles them app-wide.
- **Countdown**: `AnimalCountdown(targetTime: ...)` counts down to a wall-clock
  time and `AnimalCountdown.duration(duration: ...)` over a duration; `format`
  is an `AnimalCountdownFormat`. The tiles round up to whole seconds and change
  exactly at each second, `onFinish` runs once at the deadline (also while
  hidden or in the background), and a changed target cancels the previous
  callbacks. Tiles grow to fit long values and wrap instead of overflowing.
- **Time**: `AnimalTime(time: ...)` shows a fixed time and `AnimalTime.live()`
  the current time, moving exactly at each wall-clock second; with
  `liveRegion` the announced value has minute precision.
- **Typewriter**: the text never reflows while it types and the cursor takes no
  space; reduced motion shows the whole text at once. `onComplete` runs after
  the frame for an empty text or under reduced motion and is cancelled when the
  text changes or the widget is disposed; a non-positive `speed` throws.
- **Cursor**: exactly one cursor is visible over nested regions; `forceAll`
  also replaces descendant cursors such as text fields, and the region never
  takes hover from its child or from regions behind it.
- **Progress**: a non-finite `percent` throws, the label rounds down to a whole
  percent, and an inside label sits over the fill. The constructors are no
  longer `const`.
- **Skeleton**: `rows` below 1, `rowWidths` entries outside 0..1 and negative
  or non-finite sizes throw; `rowWidths` are fractions of the paragraph width.
  The constructors are no longer `const`.
- **Repeating motion**: progress stripes, skeleton shimmer and loading
  indicators stop while the app is in the background and start again when it
  resumes, including when they were created in the background.
- **Overlays**: notifications and full-screen loadings live in the nearest
  `AnimalOverlayHost`; `AnimalModal.confirm` returns `Future<bool>`, and
  `AnimalModal.show` and `AnimalDrawer.show` return the typed value their
  content closes them with. The image preview is presented the same way.
- **Close and clear controls**: every close, clear and remove button shares one
  48 logical-pixel control with a focus ring and a styleable hover fill; style
  fields are named `closeButton*`/`clearButton*` for the control and
  `closeIcon*`/`clearIcon*` for the icon.
- **Field borders**: Input, Select, DatePicker and TimePicker share one border
  and glow rule (`errorText`/`warningText` borders, 45% focus and 35% status
  glow) with a styleable glow color (`glowColor`, `triggerGlowColor` on
  TimePicker); Select supports the warning status.
- **Validation of styles**: a style rejects negative or non-finite padding and
  corner radii when it is built, like its other dimensions. Style
  interpolation clamps `t` to 0..1, so an overshooting theme animation curve
  stays between the two styles.
- **Option groups**: `AnimalCheckboxGroup` and `AnimalRadioGroup` show an
  option's `icon` and announce its `semanticLabel`, as Select does.
- **Snowflake loading**: the alpha of the snowflake color scales each
  particle's opacity instead of being replaced by it.
- **Notification handle**: `AnimalNotificationHandle` is a final class
  returned by `AnimalNotification`; it can no longer be subclassed.
- **Documentation**: every public member of the package is documented.
- **Form controller**: after `dispose`, starting new work (`setValue`,
  `validate`, `validateField`, `submit`, `reset`, `clear`, `focusFirstError`)
  throws a `StateError`; `validate` takes named `fieldKeys` and `autoFocus`.
  `reset` and `clear` are not re-entrant: form work started by a listener
  while they write the fields throws a `StateError`.
- **Button API**: `AnimalButton` is configured with `variant`
  (`filled`, `outlined`, `dashed`, ...), `tone` and `size`.
- **Runtime dependencies**: `flutter_svg`, `characters`, `intl` and
  `flutter_localizations`.

### Removed
- `AnimalOverlayEntryState`, the controller's `liveCount`, `isAttached` and
  `isDisposed`, and the handle's `state`; use `AnimalOverlayEntryHandle.isClosed`.
  `AnimalOverlayController.show` no longer takes a `duration` (a
  notification's own `duration` times it).
- `AnimalLoading.color` and `AnimalLoading.barrierColor`: use
  `AnimalLoadingStyle.color` and `AnimalLoadingStyle.barrierColor`.
- `AnimalCountdown.remaining` (use `AnimalCountdown.duration`) and string
  countdown formats (use `AnimalCountdownFormat`); `AnimalTime.live` as a flag
  and the public `time` and `clock` fields of `AnimalTime` (use the
  `AnimalTime` and `AnimalTime.live` constructors).
- `AnimalProgress.color`, `trackColor` and `height` and the `size` and
  `strokeWidth` of `AnimalProgress.circle`: use `AnimalProgressStyle` and
  `diameter`. `AnimalSkeleton.borderRadius`: use
  `AnimalSkeletonStyle.borderRadius`. The `TextStyle` `style` of
  `AnimalTypewriter`: use `AnimalTypewriterStyle.textStyle`.
- `AnimalInputStyle.iconSize`: use `clearIconSize`.
- Form internals: `AnimalFieldRegistration`, the controller's field registration
  methods (`registerField`, `bindingFor`, ...), `epoch`, `isDisposed`, `isValid`
  and `touchField`; register fields by placing an `AnimalFormItem` in an
  `AnimalForm`. `AnimalFieldBinding` has no public constructor and no
  `generation`, `hasError`, `isValid` or `isValidating`; read `status` and
  `error`. `AnimalSubmitResult.isSuccess`: read `status`.
- `AnimalRuleType` and the `AnimalRule` configuration fields; build rules with
  the `AnimalRule` factories.
- `AnimalDate.isLeapYear` and `AnimalDate.isAtSameMomentAs` (use
  `daysInMonth` and `compareTo`), `AnimalTimeValue.fromTimeOfDay` and
  `toTimeOfDay`, and the root export of `lookupAnimalLocalizations`.
- The pixel metrics of `AnimalButtonSize`, `AnimalTitleSize` and
  `AnimalTagSize`; the enums select a size.
- The `AnimalFieldKey` type guards (`valueType`, `acceptsRequestedType`,
  `requireRequestedType`, `requireValueType`, `snapshotValue`) and
  `AnimalFormController.defaultSubmitHandler`; pass `onSubmit` to
  `AnimalForm` or to `submit`.
- The Gallery's `gallery*` and `provenance*` strings from
  `AnimalLocalizations`; the example app owns them.
- `AnimalLocalizations.close`, which no component read; components use their
  own close labels such as `modalCloseLabel`.
- `AnimalTabItem.id`, which no tab read.

## [1.0.0] - 2026-09-14

### Added
- First stable version of the library: 36 components and 101 vector icons on the
  single-module architecture introduced in 1.0.0-dev.1.
- Browser end-to-end tests for the web Gallery covering routing, deep links and
  offline font loading.

## [1.0.0-dev.1] - 2026-09-13

### Changed
- **Component modules**: every component lives in its own module under
  `lib/src/components/<component>/`, replacing the former category folders
  (`general/`, `feedback/`, `form_controls/`, `overlays/`, `layout/`,
  `data_display/`, `decorative/`).
- **Unified theme**: a single `AnimalIslandTheme` (`ThemeExtension<AnimalIslandTheme>`)
  with `light` and `dark` presets replaces the previous duplicate token
  implementations.
- **Icons**: the 101 standalone icon widget classes were replaced by immutable
  `AnimalIconData` descriptors on `AnimalIcons` and a single renderer,
  `AnimalIcon(data: ...)`.
- **Overlays**: `AnimalOverlayHost` scopes overlay state per app instead of
  sharing process-wide static queues.
- **Forms**: `AnimalForm` and `AnimalFormController` track revisions so a
  late-arriving asynchronous validation result cannot overwrite newer input.
- **Table**: `AnimalTable` builds rows lazily from `rowCount` + `rowBuilder`
  instead of an eager list of row widgets.
- **Gallery**: the example app was split from a single large file into separate
  component stories and workflow pages.
- **Documentation**: bilingual guides now live in `docs/en/` and `docs/zh/`, and the
  consumer skill in `skills/animal-island-ui-style-flutter/`.
