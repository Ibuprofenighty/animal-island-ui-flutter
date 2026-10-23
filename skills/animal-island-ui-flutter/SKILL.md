---
name: animal-island-ui-flutter
description: Use and extend the Animal Island Flutter component library with explicit ownership, composable styles and reference-led Gallery behavior.
---

# Animal Island Flutter

Read the public declarations in `lib/animal_island_ui.dart` for signatures, the relevant `components/*/contract.json` for behavior, [API](../../docs/API.md) for composition, and [DESIGN](../../docs/DESIGN.md) for visual policy. [library.json](../../library.json) owns scope. This file's Chinese translation is not another implementation.

## Choose the owner

- The parent owns constraints, committed controlled values and acceptance/rejection of change requests.
- The component owns its surface, transient interaction, focus behavior and owned resources. Borrowed controllers and focus nodes remain caller-owned; account for callback reentry, cancellation and disposal.
- Shared mechanisms have one owner: AnchoredPanel handles anchored placement/outside dismissal, ActionSurface activation, ContentScope passive slot defaults, and ViewportOverlay full-window presentation. Component selection/search/lifetime remain component-owned.
- Explicit child styles, state, keys, actions and semantics remain authoritative. Never inspect/rebuild arbitrary child Widgets. Nested actions must not activate their parent.
- Use stable IDs for dynamic lists. Do not maintain two committed pagination/selection states. Constraint-dependent Table cells need an explicit column width; do not double-mount or inspect opaque cells.
- Gallery uses app/pages/shared and public library imports. Parent rows own responsive wrapping; components keep their sizing contract. No Gallery-only replacement component or copied palette.

## Color and motion

Use existing theme/instance style roles with their documented precedence. Transparent is an explicit value. Typography and semantic foreground are separate; caller TextStyle.foreground Paint retains Flutter precedence. Arbitrary custom pairs require actual composited-background and state validation, not runtime color guessing.

Follow [shared recipes](../../docs/DESIGN.md#original-color-restoration), [shared accent ink](../../docs/DESIGN.md#shared-accent-foreground) and [Title ink](../../docs/DESIGN.md#title-foreground). Passive slot ink and nested control surface data have different owners. Preserve unrelated ThemeExtensions and explicit content styles.

Keep one content subtree and lifecycle across entry, exit, reverse, reopen, cancel, disposal, theme changes and reduced motion. [Surface sampling](../../docs/DESIGN.md#surface-sampling) does not authorize per-child offsets or a blanket filter. The [Home/photo exception](../../docs/DESIGN.md#home-host-and-photo-gradient) applies only to those named Gallery regions.

## Extend atomically

Inspect unknown reference behavior before changing it. Use the pinned [reference identity](../../docs/reference-gallery.json); adapted code examples may use Dart, but do not invent product behavior. Update declarations, contract, implementation, every consumer, tests, documentation and both Skill languages together. Keep one mechanism: no aliases, compatibility branches, parallel palette or test-only production API.

Run focused public-interface tests for the affected ownership and lifecycle, then required broader checks. Validate real platform behavior separately from widget tests and build success. [Verification limits](../../docs/ACCEPTANCE.md) remain explicit; excluded screen-reader work is not certification. Do not change a threshold or skip a failure merely to make CI green.

## Commands

From the root use `flutter test test/<affected_test>.dart`, `flutter analyze --fatal-infos`, and `python -B tool/reference_coverage.py`. From `example` use the relevant tests and `flutter build web` / `flutter build windows` as required by scope. `python -B tool/verify.py --flutter <configured-flutter> --builds` runs the maintained sequence; see [MAINTENANCE](../../docs/MAINTENANCE.md).

Keep local diagnostics in ignored scratch/evidence directories. Keep source licenses and [redistribution boundaries](../../docs/RIGHTS.md). Publishing requires user authorization. Do not embed workstation paths, session instructions or dated execution reports into product documentation.

Use the public-root `IslandDashedBorderPainter` for a caller-owned dashed frame; keep its shape/paint/spacing recipe local and follow [the drawing contract](../../docs/API.md#dashed-stroke). Do not copy the path-metric loop or import internal package source. Gallery constrained rows follow [the single parent-layout authority](../../docs/DESIGN.md#gallery-parent-layout); current performance limits follow [ACCEPTANCE](../../docs/ACCEPTANCE.md), not historical optional benchmark proposals.
