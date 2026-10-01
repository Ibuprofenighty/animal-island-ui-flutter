---
name: animal-island-ui-style-flutter
description: Use the animal_island_ui Flutter package to compose cozy island-style interfaces, checking the package's actual public declarations before generating code.
---

# Animal Island UI consumer skill

Build Flutter screens with `animal_island_ui`: 36 island-style components and
101 vector icons. [中文镜像](SKILL.zh-CN.md) is a translation of this entry, not a
separately installed skill.

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
6. Follow each component's own geometry and states; for example, the stacked depth
   shadow belongs to filled primary and danger buttons, not to every widget.
7. When customizing colors, keep readable foreground/background pairs and use the
   semantic `*Text` roles for text on ordinary surfaces.

## Interaction

Actionable components and interactive icons respond to pointer, Enter/Space and
accessibility actions through one shared activation and focus behavior. Group
controls (radio and checkbox groups, tabs) handle arrow/Home/End navigation.
Hit targets are at least 48 logical pixels, and a pending activation is
cancelled when focus is lost or the control is disabled, hidden or removed.

## Localization and validation

`AnimalLocalizations` and `resolveAnimalLocale` are exported from the package root.
Install the generated delegates and supported locales on the host `MaterialApp`;
Chinese locales resolve to Chinese and missing or unsupported locales to English.
`AnimalFormController.getFieldError` returns a locale-neutral `AnimalValidationIssue`
for programmatic checks. Let `AnimalFormItem` display built-in issue text; do not
add a second issue-to-message map. Caller-provided validation messages are shown
as written.

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
