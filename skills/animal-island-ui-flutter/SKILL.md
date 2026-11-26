---
name: animal-island-ui-flutter
description: Use and extend the Animal Island Flutter component library (package animal_island_ui) with explicit ownership, composable styles and reference-led Gallery behavior. Use whenever code imports animal_island_ui or mentions an Island* widget, when building or testing an app screen with these components, and when changing the library, its tokens, icons or Gallery.
---

# Animal Island Flutter

`lib/animal_island_ui.dart` lists what is public. Signatures and defaults are in the file that declares each symbol; the `interface.inputs` entry of the relevant `components/*/contract.json` links it, and several classes share a file (`IslandButton` in `actions.dart`, `IslandSwitch` and `IslandTextField` in `inputs.dart`, the chart data types in `chart/model.dart`). Read that contract for behavior, [API](../../docs/API.md) for composition, and [DESIGN](../../docs/DESIGN.md) for visual policy. [library.json](../../library.json) owns scope. This file's Chinese translation is not another implementation.

## Use in an app

Applies when building an application with the library; skip to the later sections when changing the library or its Gallery.

1. Depend on the package by path and import only `package:animal_island_ui/animal_island_ui.dart`; the [README](../../README.md) has the install steps and a complete starter. `flutter_localizations` is not needed as a separate dependency.
2. Wire `MaterialApp(theme: IslandTheme.create(), darkTheme: IslandTheme.create(brightness: Brightness.dark), localizationsDelegates: IslandLocalizations.delegates, supportedLocales: IslandLocalizations.supportedLocales)`. For a runtime light/dark switch, also wrap the content inside `Scaffold.body` in `IslandThemeHost(data: resolvedTargetTheme, child: ...)` as [API](../../docs/API.md) describes.
3. Take colors from `IslandTheme.of(context)` tokens or an `IslandColorway`; write no color literal.
4. Card, Title, Modal, Drawer, Notification, Tooltip and Table are fixed pale surfaces: `Theme.of(context)` below them stays light in a dark app. Read or assert the app theme from a context outside them.
5. Built-in copy (placeholders, empty text, close and clear names, picker footers, the default Modal actions) follows `IslandLocalizations` in Chinese and English: Chinese under a `zh` locale with the delegates registered, English otherwise. Pass your own text only to change it; for another language pass every string and `actions:` to `showIslandModal`. `IslandTime` takes its own `locale`.

| Need | Use |
|---|---|
| Validated form | `IslandForm` with `IslandFormTextField` and `IslandFormField<T>`; the builder's `IslandFormBinding` (`value`, `onChanged`) connects Select, Switch and the pickers. `required: true` only draws the mark; write the rule as an `IslandFormValidator` (`FutureOr<String?> Function(T? value, Map<String, Object?> values)`). Validation runs on edit and on submit |
| Submit from outside the fields | Create an `IslandFormController`, pass it as `controller:` (not together with `initialValues:`), call `controller.submit()`; `onFinish` fires when valid, `onFinishFailed` otherwise. Dispose the controller yourself |
| Notification | Wrap content in `IslandNotifications(controller:, child:)` with a controller you create and dispose; call `controller.show(IslandNotification(...))`. The default duration is 4.5 s |
| Confirm dialog | `showIslandModal(actions: (ctx) => [...])`; the default actions only close. Close from a custom action with `Navigator.of(ctx, rootNavigator: true).pop(result)` |
| Buttons | `IslandButtonVariant.primary` for the main action; `normal` is the default variant |
| Icon names | `IslandGlyph` values in `lib/src/foundation/icon_names.dart`, or the Gallery Icon page |

Widget tests of an app: give the test view a desktop-sized surface, use `pumpAndSettle` after edits and submit because validation is asynchronous, and pump past the notification duration before the test ends.

### Cost and accessibility in an app

- Mount long collections lazily (`ListView.builder`, `GridView.builder`). Every tile built from an action surface (`IslandCard`, `IslandTag`, buttons) is a stateful element with its own focus node, so a `Column` or `Wrap` of several hundred costs memory and build time before the user scrolls.
- A plain `IslandCard` is the cheap one: only `hoverable: true` adds the lift animation. Leave it off for static cards in a list.
- You dispose what you create. The library disposes only the controllers and focus nodes it made itself, so an `IslandFormController`, `IslandNotificationsController`, `FocusNode` or `ScrollController` you pass in stays yours.
- Controls already carry their accessible names (`IslandIconButton.label` is required). What an app can still break is its own layout: test key screens at `TextScaler.linear(2)` and with `MediaQueryData(disableAnimations: true)`, and run `meetsGuideline(labeledTapTargetGuideline)` over them.

## Choose the owner

- The parent owns constraints, committed controlled values and acceptance/rejection of change requests.
- The component owns its surface, transient interaction, focus behavior and owned resources. Borrowed controllers and focus nodes remain caller-owned; account for callback reentry, cancellation and disposal.
- Shared mechanisms have one owner: AnchoredPanel handles anchored placement/outside dismissal, ActionSurface activation, ContentScope passive slot defaults, and ViewportOverlay full-window presentation. Component selection/search/lifetime remain component-owned.
- Explicit child styles, state, keys, actions and semantics remain authoritative. Never inspect/rebuild arbitrary child Widgets. Nested actions must not activate their parent.
- Use stable IDs for dynamic lists. Do not maintain two committed pagination/selection states. Constraint-dependent Table cells need an explicit column width; do not double-mount or inspect opaque cells.
- Gallery uses app/pages/shared and public library imports. Parent rows own responsive wrapping; components keep their sizing contract. No Gallery-only replacement component or copied palette.

## Color and motion

Every color is a named token: primitive palette → `IslandTokens`/`IslandColorway` → component recipe; Gallery colors live in `GalleryPalette`. Add a new value as a token at its owner; never write a color literal in a component or Gallery page, and never branch `reference ? literal : token`. `test/color_literal_policy_test.dart` and the `tool/verify.py` policy enforce this. Reference colors that differ for contrast are registered in [measured color differences](../../docs/DESIGN.md#measured-color-differences).

Use existing theme/instance style roles with their documented precedence. Transparent is an explicit value. Typography and semantic foreground are separate; caller TextStyle.foreground Paint retains Flutter precedence. Arbitrary custom pairs require actual composited-background and state validation, not runtime color guessing.

Follow [shared recipes](../../docs/DESIGN.md#original-color-restoration), [shared accent ink](../../docs/DESIGN.md#shared-accent-foreground) and [Title ink](../../docs/DESIGN.md#title-foreground). Passive slot ink and nested control surface data have different owners. Preserve unrelated ThemeExtensions and explicit content styles.

Keep one content subtree and lifecycle across entry, exit, reverse, reopen, cancel, disposal, theme changes and reduced motion. [Surface sampling](../../docs/DESIGN.md#surface-sampling) does not authorize per-child offsets or a blanket filter; Notification and Tooltip move their whole surface in whole device pixels instead. The [Home/photo exception](../../docs/DESIGN.md#home-host-and-photo-gradient) applies only to those named Gallery regions.

## Charts, Calendar and icons

Choose a chart kind through the matching typed `IslandChartData` constructor and follow its data shapes and invalid-data rules in [API](../../docs/API.md#reference-400-additions); a map needs caller-supplied regions, and the empty state is `IslandNoData`. Calendar, Chart and NoData take their chrome text from `IslandLocalizations` and show English without its `zh` locale. `IslandGlyph` values (709, naive-icons v1.14.0) change only by running `python -B tool/import_icons.py`; never hand-edit `assets/icons`, and treat the paint outcomes as measured and owner-accepted as a set, not glyph by glyph (the 15 roles kept by owner rule O7 in `docs/icon-paint-roles.json` `import_v1_14.settled` are not certified by a contrast matrix).

## Extend atomically

Inspect unknown reference behavior before changing it. Use the pinned [reference identity](../../docs/reference-gallery.json); adapted code examples may use Dart, but do not invent product behavior. Update declarations, contract, implementation, every consumer, tests, documentation and both Skill languages together. Keep one mechanism: no aliases, compatibility branches, parallel palette or test-only production API.

Run focused public-interface tests for the affected ownership and lifecycle, then required broader checks. Validate real platform behavior separately from widget tests and build success. [Verification limits](../../docs/ACCEPTANCE.md) remain explicit; excluded screen-reader work is not certification. Do not change a threshold or skip a failure merely to make CI green.

## Commands

From the root use `flutter test test/<affected_test>.dart`, `flutter analyze --fatal-infos`, and `python -B tool/reference_coverage.py`. From `example` use the relevant tests and `flutter build web` / `flutter build windows` as required by scope. `python -B tool/verify.py --flutter <configured-flutter> --builds` runs the maintained sequence; see [MAINTENANCE](../../docs/MAINTENANCE.md).

Keep local diagnostics in ignored scratch/evidence directories. Keep source licenses and [redistribution boundaries](../../docs/RIGHTS.md). Publishing requires user authorization. Do not embed workstation paths, session instructions or dated execution reports into product documentation.

Use the public-root `IslandDashedBorderPainter` for a caller-owned dashed frame; keep its shape/paint/spacing recipe local and follow [the drawing contract](../../docs/API.md#dashed-stroke). Do not copy the path-metric loop or import internal package source. Gallery constrained rows follow [the single parent-layout authority](../../docs/DESIGN.md#gallery-parent-layout); current performance limits follow [ACCEPTANCE](../../docs/ACCEPTANCE.md), not historical optional benchmark proposals.
