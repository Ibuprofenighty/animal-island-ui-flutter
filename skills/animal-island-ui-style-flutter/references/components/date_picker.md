<!-- generated:api:start -->
# AnimalDatePicker Reference

- **Class**: `AnimalDatePicker`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalDatePicker`

## Properties
- `allowClear`
- `clock`
- `disabled`
- `disabledDate`
- `firstDate`
- `focusNode`
- `lastDate`
- `mode`
- `onChanged`
- `selection`
- `showToday`
- `style`

<!-- generated:api:end -->

## Civil dates and selection

`AnimalDate` is a Gregorian civil date from year 1 through 9999. Its arithmetic uses calendar ordinals, so advancing a day never depends on a local 24-hour interval. `AnimalDate.fromDateTime()` reads the input object's year, month, and day fields as supplied; `toDateTime()` returns those fields at UTC midnight. Invalid year, month, or day construction throws `ArgumentError.value`; arithmetic that leaves the supported year range throws `RangeError` in debug and release builds. Calendar cells beyond the supported years are inert placeholders.

`AnimalDate` members: `year`, `month`, `day`, `weekday` (1 = Monday),
`AnimalDate.minimumYear`/`maximumYear`, `AnimalDate.daysInMonth(year, month)`,
`AnimalDate.today({clock})`, `AnimalDate.fromDateTime`, `toDateTime()`,
`addDays`/`subtractDays`, `isBefore`/`isAfter`/`compareTo` and
`toIso8601String()` (also its `toString`); two dates are equal when their
year, month and day are. `AnimalDateSingleSelection.date` and
`AnimalDateRangeSelection.start`/`end` hold a selection, and
`isCompatibleWith(mode)` tells whether it fits a picker mode.

`AnimalDatePickerMode.date`, `.range`, and `.month` are selected through `mode`, which defaults to `.date`. They share one controlled `AnimalDateSelection? selection` and one `ValueChanged<AnimalDateSelection?>? onChanged` proposal callback. `AnimalDateSelection.date(...)` creates `AnimalDateSingleSelection`; `AnimalDateSelection.range(start:, end:)` creates `AnimalDateRangeSelection`. In range mode, `end == null` represents the externally controlled start-date draft. A complete range is proposed after its end date is chosen. The range constructor rejects an end before its start with `ArgumentError.value`. Month mode reuses the single-date variant and requires day 1 of the chosen month. A mode/selection mismatch throws `ArgumentError.value`, and `firstDate` after `lastDate` throws `ArgumentError`.

The parent remains the only owner of the committed selection. It accepts a proposal by passing the resulting selection back; if it leaves `selection` unchanged, the picker continues to display that external value without retaining an optimistic second value. Inline and popover presentations use the same calendar model and panel. `CalendarModel` receives `today` explicitly; `AnimalDate.today()` and both presentations use the canonical `AnimalClock`/`SystemClock` path.

## Defaults and theme

The inline `AnimalDatePicker` defaults to `mode: AnimalDatePickerMode.date`, a null selection, `showToday: true`, `allowClear: true`, `disabled: false`, and `clock: const SystemClock()`. Bounds, `disabledDate`, the callback, and `focusNode` are optional. `AnimalDatePicker.popover(...)` uses the same defaults and adds an optional caller-supplied `placeholder` and `status`, which defaults to `AnimalInputStatus.normal`. Without a placeholder, the component uses the localized single-date text, or the range text in range mode. The popover trigger uses the selected date or range as its display text.

Today proposes the current civil date in date mode, a controlled start draft in range mode, and the first day of the current month in month mode. It is disabled when that target is outside the inclusive bounds or matches `disabledDate`; the whole disabled picker has no callbacks. Clear proposes null once when a selection exists. In popover mode, Clear closes the menu and restores focus to its trigger; a completed date/month selection or range also closes it, while a range start draft stays open.

The shared panel prefers a width of 300 logical pixels and takes a narrower parent width when one is given, with `bgContent`, `cardBorder`, `spacing.md` padding, and a 1.5-pixel border (`border` in dark themes, `borderLight` in light themes). It uses `spacing.sm` between sections and `spacing.xs` for compact grid/footer gaps. Date and month labels use `typography.body` scaled by 13/14 (13 pixels in the standard typography); weekday and footer labels use caption typography; the header uses `typography.heading` scaled by 15/20 (15 pixels). Single-date selections use `primary`/`onPrimary`; month selections use those colors with a `primaryActive` outline. Range endpoints use `warning`/`onWarning`, and the range interior uses the range color at 18% opacity. Date-grid columns are at least 48 logical pixels wide and expand to fit the widest rendered day label plus twice the 6-pixel cell inset, or the weekday label. Day-cell height is `max(48, measured day-layout height + 2 × cell inset)` and weekday-row height is `max(24, measured caption-layout height)`, measured with the resolved styles and `MediaQuery` text scaling. The single measurement includes the paragraph size and centered selection-box extents so font layout stays within the cell. Month cells are at least 86×48 logical pixels and expand to fit the widest localized month label plus twice the cell inset and its measured layout height plus two month-border insets (1 pixel by default). With default text metrics, dates are 48×48, weekdays 48×24, and months 86×48. When the panel is too narrow for the navigation buttons and a 48-pixel label slot on one line, the heading moves above the navigation, which wraps while every button keeps its 48-pixel target; the date and month grids scroll horizontally, and the Today and Clear actions wrap onto separate lines when large text does not fit. The popover trigger uses `bgInput`, or `surfaceHeader` when disabled in a dark theme and `bgInputDisabled` when disabled in a light theme. Its border and glow follow the field-trigger rule described under Customization. The calendar keeps the same shared layout.

## Localization
Default prompts and footer actions use generated AnimalLocalizations; date display, month names, weekday labels, navigation labels, and date-cell semantics follow the active Material locale. A supplied placeholder remains caller-owned.

## Interaction and accessibility

Date cells have a 48 logical-pixel minimum hit target. At 320 logical pixels, the shared panel exposes the seven-column grid through an accessible horizontal viewport rather than shrinking cells below their minimum; keyboard focus remains visible as the viewport moves. Larger text can widen columns and increase row heights. Inline content uses the host page's vertical scroll layout when it exceeds the available height; popovers use the menu's native vertical viewport. Cells outside years 1–9999 have no text, semantics, or focus. Disabled dates cannot be selected as a range endpoint or included inside a completed range. A range entered in reverse order is proposed in ascending order. Once a range is complete, the next date starts a new range with `end == null`; rejecting any proposal leaves the committed display unchanged. Only range endpoints carry selected semantics.

In the date grid, arrows target one or seven days away; Home/End targets Sunday/Saturday in the current week, clamped to the supported civil-date boundary at year 1 or 9999. If a target date is disabled, focus searches in that direction through the target month's 42-cell grid. If no enabled date remains in that grid, focus stays in place; PageUp/PageDown or the header can still move to another month. PageUp/PageDown changes month, and Shift+PageUp/Shift+PageDown changes year while clamping to the destination month's last day. The month grid has three columns with `spacing.xs` gaps inside the same horizontal viewport. Its arrows target one month horizontally or three months vertically; Home/End starts at January/December and searches inward for the nearest enabled month. PageUp/PageDown changes year within the supported bounds and focuses the nearest enabled month. Month-mode year buttons use the same nearest-enabled-month rule and are disabled only when the target year has no enabled month. Date-grid header navigation retargets the keyboard anchor to the displayed month without changing the controlled selection. Disabled arrow targets are skipped in the movement direction. Left and Right follow physical screen direction in RTL. Enter and Space activate a focused action. Escape or an outside tap closes the popover; completing a range closes it, while a partial range stays open. Clear returns focus to the popover trigger.

## Customization

`style` takes an `AnimalDatePickerStyle` and overrides the theme for this
picker; `AnimalDatePicker.popover` accepts the same `style` for its trigger,
menu and panel. The theme's `components.datePicker` is an
`AnimalDatePickerStyle` applied to every picker (there are no size presets).
Precedence is the instance style, then the theme style, then defaults derived
from the active tokens: the heading is `typography.heading` scaled by 15/20,
day and month labels are `typography.body` scaled by 13/14, weekday and footer
labels follow `typography.caption`, and the focused trigger uses the library
focus color. Text styles merge field by field, so a partial override keeps the
lower layers.

Geometry fields are `width` (a narrower parent still wins), `padding` (an
`EdgeInsetsGeometry`, so start/end insets follow the text direction),
`borderWidth`, `borderRadius`, `cellInset`, `rangeBorderRadius`,
`monthBorderWidth`, `monthBorderRadius`, `navigationIconSize` (year icons use
18/20 of it), `triggerIconSize`, `triggerBorderRadius`,
`triggerHorizontalPadding` and `triggerIconGap`. Spacing fields are
`sectionGap` (header to grid and grid to footer divider, default
`spacing.sm`), `footerGap` (divider to actions, `spacing.xs`), `cellGap`
(between month cells, between date rows and below the weekdays, `spacing.xs`)
and `actionHorizontalPadding` (inside Today and Clear, `spacing.sm`). Text
fields are `headerTextStyle`, `weekdayTextStyle`, `cellTextStyle`,
`actionTextStyle` and `triggerTextStyle`; selected cells and today stay bold,
and today keeps its underline. `cellTextColor` resolves against
`WidgetState.selected` and `disabled`; `headerTextColor`, `todayTextColor`,
`clearTextColor`, `triggerBackgroundColor`, `triggerTextColor` and
`triggerIconColor` against `disabled`; `monthBorderColor` against `selected`;
and `borderColor` against `focused`, `error` and `disabled` on the trigger.
The selected fill is `selectedBackgroundColor`; range endpoints use
`rangeBackgroundColor` and `rangeTextColor`, outside-month days
`outsideMonthTextColor`, the weekday labels `weekdayTextColor`, the empty
trigger `placeholderTextColor`, the warning status `warningColor`, and the
trigger glow `glowColor`, resolved against `focused` and `error`. The 48-pixel
targets, 86-pixel month minimum, 24-pixel weekday row, three month columns and
the 18% range fill are fixed.

The trigger border and glow follow the one rule shared by Input, Select,
DatePicker and TimePicker. A disabled trigger uses the styled border, otherwise
`borderLight` in light themes or `border` at 30% opacity in dark themes, and
has no glow. The warning status uses `warningColor`, otherwise `warningText`;
an error wins over a warning. Otherwise the styled border applies, then
`errorText` for an error, the focus-ring color when focused and `border` at
rest. An idle trigger without a status has no glow; otherwise the glow is the
styled glow color, or the border color at 45% opacity when only focused and
35% for an error or warning, with blur 4 and spread 2.

The clear control is the package's shared icon action: a 48 logical-pixel
target with a focus ring, the localized clear label as its accessible name, the
close icon in `triggerIconSize` and `triggerIconColor`, and a hover fill from
`triggerClearButtonBackgroundColor`, resolved against `WidgetState.hovered`;
under reduced motion the fill changes instantly. `triggerClearButtonPadding`
defaults to zero, `triggerClearButtonBorderRadius` to a pill and
`triggerClearButtonBackgroundColor` to transparent.

## Example
See [`date_picker_story.dart`](../../../../example/lib/stories/date_picker_story.dart) in the example Gallery.
