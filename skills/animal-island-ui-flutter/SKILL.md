---
name: animal-island-ui-flutter
description: Extend or consume the Animal Island Flutter library in this repository, preserving the reference Gallery, component ownership, controlled state, and parent-child composition contracts. Use for adding components, changing public APIs or shared patterns, building Gallery stories, and checking Windows/Web behavior.
---

# Animal Island Flutter

## Current work scope / 当前工作范围 (2026-10-17)

User scope decision, 2026-10-17: all screen-reader execution and validation are excluded from this work, including NVDA and other readers. Do not install or start reader software, request reader validation, or keep it as a remaining acceptance blocker. Excluded is not passed or certified. Preserve existing semantic metadata, keyboard navigation, focus behavior, contrast requirements and their tests. No new software may be installed for acceptance. Historical reader-related pending notes below do not define the current work scope.

The repository root is two directories above this file. This is a new implementation; do not import the old local Flutter library.

## Resolve evidence before editing

Read `AGENTS.md`, `docs/DESIGN.md`, the relevant `components/<id>/contract.json`, and the actual declarations exported by `lib/animal_island_ui.dart`. Scope is `library.json`; design authority is `docs/reference-gallery.json`. Page presence is measured by `tool/reference_coverage.py`, not inferred from a sidebar entry. Unimplemented stories and NOT_ACCEPTED states remain gaps.

For a reference-led change, inspect the corresponding pinned public source under `scratch/reference-react` when available and operate the live Gallery for unknown interactions. Record viewport, route, state and measured differences. Do not invent another palette, silhouette, default Material control or demo flow. Flutter code examples may adapt technical content.

## Verification and historical evidence

Current source-bound acceptance and pending work have one owner: `scratch/global-audit-20261014T035753Z/report.json` in the original delivery workspace, outside the library and complete-source ZIPs. The delivery entry supplies that record and the cold-archive index at `outputs/cold-archive-20261021/index.html`. Archived reference inputs retain their original identities; an unexpanded historical path is not missing proof. Read only the needed members through the archive access instructions. Do not turn old tests, CPU/round statistics or matched-input reuse into full acceptance of changed source.

## Assign one owner

- Parent: constraints, explicit controlled values, business decisions and acceptance/rejection of change requests.
- Component: its visual anatomy, focus behavior, temporary interaction state and owned resource disposal.
- Shared primitive: one complete recurring responsibility; placement/outside dismissal belongs to AnchoredPanel, activation to ActionSurface, slot defaults to ContentScope. Selection/search remain component-owned.
- Child slot: preserve explicit text/icon styles, actions, focus, keys and semantics. Do not inspect arbitrary child runtime types, rewrite descendants, or catch a child action as a parent activation.
- Controlled callbacks are proposals. A rejected proposal must leave the displayed committed value unchanged. Use stable option identities across insertions/reordering; do not confuse indexes with keys.
- Dispose only owned controllers/nodes/timers. Supplied resources are borrowed. Cancel delayed work on disposal or superseding requests; guard reentrant callbacks.
- Viewport overlays use ViewportOverlay so an offscreen/zero-size trigger cannot remove their semantics. AnchoredPanel remains for anchored controls. Framework theme/locale/direction/media are captured; pass application-provider values explicitly into viewport content.
- Keep Gallery app/pages/shared; consume the public package root only. Do not embed component implementations in stories.

Extract a shared pattern only after identifying a common invariant and a meaningful complete interface. Similar-looking screens alone do not justify a generic all-purpose component or a module per helper.

## Deliver an atomic extension

1. Define props, slots, defaults, state transitions, keyboard behavior, errors and ownership in the component contract.
2. Implement the public component and reuse existing pattern owners.
3. Export it explicitly; update the executable story, API table, relevant consumers and documentation together.
4. Test meaningful boundaries: rejected updates, child actions, sibling isolation, disabled options, reorder/removal, focus restoration, reduced motion, resource ownership and teardown as applicable.
5. Run relevant tests and analysis. Run Gallery width checks; build Windows and Web for platform changes. Visual acceptance additionally needs matched screenshots and interaction comparison.
6. Report structural, behavior, visual, accessibility and release evidence separately. A compiling placeholder or passing test is not Gallery parity or commercial acceptance.

## Commands

From the repository root:
```text
flutter test test/<relevant_test>.dart
flutter analyze --fatal-infos
python tool/reference_coverage.py
```

From `example`:
```text
flutter test
flutter build web
flutter build windows
```

Use the configured Flutter installation. Keep diagnostics in ignored `scratch/`. Preserve source/font provenance and the existing GROBOLD authorization record. Publishing is a separate user-authorized action.

- Table owns data slicing and passes a controlled IslandPaginationValue to Pagination. Do not create two committed page states. Host-supplied row and column IDs are stable; nested cell actions remain independent.
- Table auto columns use finite intrinsic content widths. Give constraint-dependent cells (for example LayoutBuilder) an explicit column.width. Table owns shared column layout; never inspect, reconstruct or double-mount cell widgets.
- Table line boxes are minimum constraints, not fixed row heights. Text scaling and taller opaque children must expand rows; visual inline padding must not silently increase a containing text line.

- Preserve wrapper topology when hover/focus decorations change; an empty decoration avoids remounting child state. ManagedImage owns decode events; Carousel retains child state and exposes only the active item. Child editors keep their keyboard events.
- Tooltip observes hover/focus; click triggers explicitly compose a supplied toggle with the child's action. Never inspect/rewrite the trigger or intercept its pointer events. AnchoredPanel owns geometry; Tooltip owns timing.

- Notifications use a locally owned controller and one borrowed-controller host. Keep the returned handle for asynchronous progress updates; a dismissed handle rejects updates. Do not recreate notifications from stale callbacks or store them in a process-global singleton.

- Drawer requires an explicit IslandDrawerHost below the Navigator Overlay; the host owns only its page depth/backplane. Never mutate unrelated roots. Cursor scopes alter mouse-cursor priority without rewriting or intercepting child gestures.
- DatePicker uses explicit date/range and controlled/uncontrolled constructors. Keep pending selection separate from committed values; use shared picker anatomy and cancellable AnchoredPanel motion. Respect disabled dates on every commit path.

- Form binds typed values through IslandFormField builders and IslandFormTextField adapters. Never detect and rewrite child widgets to inject value/callback/disabled. Preserve caller widget keys on reorder. Async validator completion must match its field registration and value generation before updating metadata or submitting.

- Upload takes explicit picker/request/drop adapters. The host owns controlled file lists; core owns per-file cancellation and progress serialization. Import animal_island_upload_platform.dart only for platform IO. Never silently simulate a production upload. Trigger child slots are presentation-only; do not nest another button inside them. Pending picker/preflight/removal results and errors must still belong to their operation generation; removal also requires the current file source. Disable/disposal and file replacement suppress obsolete error callbacks, while current errors report once. Disabling alone does not cancel accepted transports.

- Explicit input sizes must not inherit desktop density shrinkage. Shared presentation cleanup removes the owned route after tree mutation, never the current top route. Upload preview builders receive BoxFit explicitly; preflight must run before loading image bytes.

- Form label activation is explicit through onLabelPressed. The text adapter owns an internal focus node or borrows the caller node; it never disposes a borrowed node. Disabled fields suppress label activation.

- ViewportOverlay borrows the presenting route focus scope for keyboard traversal; Overlay owns placement. Keep stable decoration wrappers and paint focus outlines without border padding. Notification closeIcon is an opaque visual slot centered at intrinsic width inside a 22px action; use onDismiss for dismissal behavior.

- [Button's contract](../../components/button/contract.json) owns its actual ButtonStyle subset, state fallback and Color-foreground rule (including the existing caller-Paint boundary). IconButton inherits IslandButtonTheme without an instance style input. Explicit transparent stays a value; default evidence does not certify arbitrary caller pairs. Keep Button variant colors, depth and loading artwork inside Button. Reuse ActionSurface for activation; do not turn it into a universal visual recipe. Busy owns only its presentation ticker; the host owns async work. Dashed and solid borders reserve equal space; explicit child styling is preserved.

- Optional parent activation must not switch between wrapper types. Card, Tag and Table keep one ActionSurface and a stable child-focus bridge. Passive hover does not create a fake action. Child focus and local state survive removing the parent callback; keyboard activation belongs to the primary action focus.

- Tag defaults to soft, matching the actual Gallery and pinned implementation; its reference API table incorrectly says solid. Request solid explicitly for filled tags. Focus bridges are implementation plumbing and must not insert semantic grouping that merges separate child actions. Button, Tag and Collapse share a no-padding outline painter with component-owned color, shape, width, offset and motion. Button/Tag retain the 2px external outline and 2px gap; Collapse uses the reference 1px black rectangular inset clipped by its rounded surface.

- Typewriter accepts optional strutStyle for caller-owned line metrics in plain/rich text. Use forced metrics only when the design requires them; preserve text scaling and explicit span styling.

- Title owns a horizontally intrinsic surface and inherited nowrap/visible-overflow defaults for all variants. The host owns placement and the occupied layout slot; surface overflow is intentional reference behavior. Give constraint-dependent opaque children their own finite width. Keep their explicit styles, keys, state and semantics; do not solve Title wrapping with Gallery offsets or child inspection.
- Collapse owns inherited question/answer typography. Gallery StoryText is an owned plain-string leaf, not a public library component: derive strut and scaled CSS 1/64-pixel line boxes from the inherited style, and measure only that string. The Gallery reuses storyTextStrut for its Modal/Drawer leaves; package consumers define their own leaf text metrics and must not import Gallery helpers. Never impose these helpers on opaque children or copy component font/color recipes. Preserve text scaling; engine glyph line advances still round independently. Geometry tests do not prove pixel-identical text, and Windows/Web visual verification remains pending.

- Use IslandTypewriter.builder for caller-owned multi-line composition; consume its visible prefix without duplicating timers or walking widgets. Modal owns inherited title/body tokens, chrome and route/focus behavior. Leaf Text renderers may derive forced strut metrics from inherited styles. Default modal actions close only their own route; custom actions own their commit policy. onClose is an Escape intent, not a visual close-button switch.

- Pass semanticLabel when the modal has an accessible name; do not extract labels from arbitrary title widgets. Modal owns a separate title heading and surface-sized dialog semantics.

- Overlay cursor scopes must preserve hit-test ownership. Modal wraps its surface and its route-owned barrier separately; a full-page cursor wrapper above the barrier consumes outside clicks. Verify body clicks and barrier clicks independently, on both game and normal surfaces.

- Pure visual overlays exclude their entire entry from semantics and hit testing, including Focus/localization wrappers. Excluding only painted children can leave a full-screen blank Web semantics node above real controls. Borrowed focus bridges use includeSemantics:false; interactive descendants retain their own semantics.

- Verify rendered behavior before adopting dormant CSS. Select closes immediately despite an unused fade-out rule. Keep overlay lifecycle in AnchoredPanel and component motion/hover styling in Select. A clear child emits intent without toggling its ancestor; committed selection alone paints the selected pill.

- Select trigger keyboard handlers must ignore descendant clear focus. Search editing and query-reset Escape are local presentation; committed value remains parent-owned. Preserve the active IME buffer/range, derive only the logical suffix for onSearch, and strip the owned label prefix after commit/end without duplicate query callbacks. Candidate keys belong to the composing editor; ended-session normalization must not steal clear focus or retarget to a newly committed host value. The non-search trigger publishes its own primary focus and focus action; search retains TextField focus. Keep list, trigger and clear semantics separate; do not claim enum availability proves platform role support.
- Drawer composes Cursor over its owned mask/panel, with hit-transparent decoration. Provide semanticLabel (default null) explicitly instead of inspecting title widgets; closeLabel (default '关闭') names the header close action. Host owns depth; drawer owns focus/motion; child actions never bubble into dismissal.

- CountUp/Countdown share NumberSurface outer decoration and NumberPlate inner styling only. Keep timelines, callbacks and semantics component-owned. CountUp semanticLabel (String?, default null) explicitly names its value; builder/affixes are visual-only slots, with controls outside them. Do not inspect child widgets to derive names.

- Scope changes remove obsolete implementations, exports and exclusive consumers together; no migration commands, aliases, shims or tests kept solely to sustain retired APIs. Record newly found violations in the audit report before repair; do not claim global clearance from a keyword scan.

- Public Dart declarations own complete signatures and defaults. Component input contracts link those owners; keep behavior requirements in the contract and usage explanations in Gallery/docs. Verify every reference when changing exports; never repair drift by creating another manual parameter inventory.

- Keep expanded/collapsed state on the same named actionable trigger, through ActionSurface for disclosures, pickers and pagination size menus. Do not add an expanded-only parent or merge independent child clear actions. Keep all contrast pairs/thresholds observable: reference parity does not waive failures. See docs/ACCEPTANCE.md; necessary color corrections are authorized under docs/DESIGN.md; register actual foreground/background/state differences first, use one product palette, and never lower thresholds or add a parallel palette. Tabs proposals use stable item values, not indexes.

Date/time focus exit: use the shared PickerFocusBoundary. Blur to a focus scope with no external control target preserves the panel; an actual external focus target closes it. Keep outside pointer dismissal with AnchoredPanel, values/open requests with the component, and trigger/clear semantic actions separate. No DOM focus shim or platform-specific exception.

Keep one semantic name owner per action. Plain Picker footer text names itself; explicit time value/unit labels and clear-action labels exclude their own duplicate/decorative text only. Never solve repetition by globally excluding opaque child semantics in ActionSurface.

- Reference motion: Title layer/tab hover is200ms ease to1.06; ribbon stays static. Collapse has independent300ms reveal and250ms icon/padding timelines. Checkbox/Radio share the pinned check path, immediately paint its committed full mark, and retain600ms decorative splash. Preserve these component-owned policies; reduced motion skips them. No palette or contrast-threshold exception is implied.

- Switch inner labels determine intrinsic width above52px (38px small); do not add fixed width for text. Retain reference thumb insets,250ms cubic motion and600ms busy ring. Busy content remains opaque for contrast; reduced motion stops the ring.

Custom reference frames use IslandTheme.borderWidth(context, logicalWidth) through the public root. It floors positive borders to physical pixels with a one-pixel minimum; do not duplicate DPR arithmetic or use this metric for glyph line heights. Gallery CJK reference400/500/700 outlines are registered400/500/900 so600..900 uses the reference bold geometry without synthesis. This mapping belongs to the font recipe; do not rewrite opaque text or add another fallback family.

Rate keyboard uses committed values and clamps at endpoints (Right/Up increase; Left/Down decrease). Only one star is tabbable. Controlled rejection does not change selection. New-star motion is350ms with60ms stagger; the final new star splashes600ms.

Radio/Rate expose radioGroup semantics; mutually-exclusive and checked flags share each action node. Checkbox remains independent.

Skeleton paragraph owns one shared sweep. rowWidths repeats the last supplied fraction; an empty list uses full width. Loading reduced motion freezes snow, stabilizes entry and immediately finishes exit in the same lifecycle. BackTop focus decoration does not change its64px layout. These selected corrections do not establish full-state visual acceptance.

- Semantic colors: use IslandTokens readable roles for text/focus/control outlines, and pair brand fills with onLeaf/onSun/onDanger. IslandColorway.ink belongs on soft/paper surfaces; onAccent belongs on the accent fill. Do not infer ancestor pixels or rewrite opaque child styles. Switch exposes toggled semantics with one owned accessible name. Global Windows/Web all-state validation remains pending.

- Fixed pale Card surfaces establish a light surface Theme for descendants while preserving other ThemeExtensions and explicit child styles. Card/Tag switch foreground/fill pairs atomically; transform/shadow motion continues. Transparent Tag uses its surface text role. Image/Tag two-tone focus does not infer background pixels. Loading decorative reversals shorten by remaining distance; a separate exit timer owns removal and reactivation cancels it. Necessary content/backing stay opaque, with background pointer/focus/semantics blocked until removal.

Gallery token swatches read IslandTokens.light directly. Do not copy an older palette into consumer documentation. Title demo captions use readable public colorway foregrounds on the patterned surface.

Tabs/Pagination selection colors update as an atomic readable pair. Transparent content follows its host theme; fixed pale inputs/popups keep their light foreground recipe. This color exception does not remove shadow or arrow rotation motion.

### Approved readable motion / 已批准的可读动效

One readable motion policy: necessary text, numbers, icons, actions and their backing/boundaries stay opaque and contrast-compliant on every entry, exit, reversal and interrupted frame. Atomic paired colors replace unsafe color interpolation. Modest displacement, scale and decorative motion remain; decoration must not invalidate the actual content background. Reduced motion settles the same state machine. One content subtree and lifecycle per owner; no animation clones, opaque-child inspection, parallel variants or transition contrast exemption. See docs/DESIGN.md. Loading retains its blocking opaque surface until removal; fadeDuration controls decorative exit and removal, while reduced motion completes immediately. Historical fade observations are superseded by this approved rule, not deleted evidence.

### Readable-motion counter-audit followup

Input focus, range placeholder/hover, Avatar overflow, Table loading and CountUp celebration now use readable pairs on their actual owned surfaces. Upload supplies opaque status/action backings over arbitrary thumbnails and theme-aware transparent tips; hidden hover actions reject pointer hits. Date/time navigation and footer controls paint focus without layout changes. Image/Upload preview routes share presentation-only opaque displacement, while components keep route lifetime and content ownership. Badge/IconButton descriptions reuse IslandTooltip. Drawer reduced-motion settling runs after build. These authorized color/motion differences retain the original thresholds and do not establish exhaustive state or assistive-technology acceptance.

Already named actions can set IslandTooltip.excludeFromSemantics to omit its duplicate description; child semantics remain intact. Preview owners forward local reduced-motion changes to the same route, which captures inherited themes at presentation.

Image preview close uses the pinned16x2 rounded crossed bars and150ms reversible ease scale; its readable gray surface and separately backed focus outline stay opaque. Input visual hint/label no longer duplicate its stable accessible name. Gallery Input supplies the reference full-width brown-pattern Card,12px top gap,20px padding and18px radius through public Card composition; IslandCardTheme.style.borderColor is the border override owner. Gallery header descriptions also use IslandTooltip.

### Atomic theme regions and field feedback
For runtime light/dark changes, use `IslandThemeHost(data: targetTheme, child: content)` inside `Scaffold.body` or the existing Material content. Pass the application's already-resolved target ThemeData, not an upstream AnimatedTheme intermediate frame. The host owns one opaque paper surface and synchronously installs Theme, default ink and IconTheme. It stores no theme mode or controller and does not inspect children. Nested caller-owned Scaffold/Material/AnimatedTheme or explicit styles start a new painting boundary. Static reference Gallery surfaces retain their backgrounds.
Input owns one FormField and TextField; controller/selection/focus survive helper/error and theme changes. Fill, border and helper/error switch atomically outside InputDecorator's implicit fade/interpolation. Validation/reset/controller replacement and error live-region semantics remain with the field. Countdown settles its existing digit timeline when reduced motion starts; restoring motion cannot resume an obsolete transition.

Fixed light surfaces use one internal LightSurfaceScope for readable token/text/icon defaults while preserving unrelated extensions and explicit child styles. ContentScope defaults IconTheme color to its explicit text role unless the slot supplies a distinct icon role. Card, Drawer, Modal, Notification, Tooltip and Table share the fixed-surface mechanism; Avatar/Badge/Title/Countdown, CountUp, Select, Tabs and Loading pair icon defaults with their owned text roles. This scopes inheritance; it never inspects or rewrites child widgets.

Tag owns its close-state colors: hover atomically pairs colorway.ink with colorway.soft; resting transparent variants retain surface ink. The16px target, separate keyboard/parent dispatch and host-owned removal remain unchanged. Explicit opaque child styles/state are preserved.

CodeBlock uses one `IslandCodeBlockStyle` for instance and `IslandCodeBlockTheme.style` overrides: backing, base foreground, border, lexer syntax roles and copy-action state colors share one rendering path. Typography belongs to `style.textStyle`; base ink belongs to `style.foregroundColor`, and highlighted tokens to `style.syntaxColors`. Explicit TextStyle.foreground Paint retains Flutter precedence and caller ownership; it is not inferred as a semantic Color pair. Changing to plain language is not a theming repair. Configure the actual color pair; the library does not guess or silently correct arbitrary caller colors. Styling/state support is owned by [the CodeBlock contract](../../components/codeblock/contract.json). Carousel reuses the existing light-surface scope for its fixed pale slide backplane, preserving unrelated theme extensions and explicit opaque slide styles/state. ActiveStack still owns active-only painting/hit/semantics; Carousel owns selection, timers and focus.

Card instance/theme values share IslandCardStyle; its final recipe drives paint, passive slot defaults and the existing surface scope. Explicit IslandSurfaceTheme declares nested-control brightness and tokens; passive foreground does not rewrite that recipe. Without it, the existing known-light semantic protection remains, including on dark hosts. IslandTokens is not a promise of arbitrary branding of all fixed materials. Use [Card's contract](../../components/card/contract.json) for actual role/state support; do not maintain a second parameter matrix. Opaque content and artwork remain caller/asset-owned, and unrelated ThemeExtensions are preserved. Filled Tag, Title and Select retain their existing known-surface recipes; transparent Tag keeps ambient roles and the same child subtree.

IslandDialogRoute is the public shared route for caller-owned preview/alert content. Push it on the root Navigator and retain its identity for exact-route cleanup. It captures caller themes and supplies opaque displacement and reduced-motion settlement; the builder owns dialog surface, semantics and actions. Gallery Form/Notification keep their existing AlertDialog adaptations, Upload keeps its560px normal IslandModal, and core Image/Upload reuse this same route. The old internal route name/path is removed. showIslandModal retains its independently observed game-dialog scale/timing. Real platform callback geometry and input acceptance remain pending; screen-reader validation is excluded by the current user scope decision.

For IslandIcon, an explicit color supplies currentColor; otherwise use the inherited IconTheme. Keep asset-owned internal multicolor paint instead of recoloring the entire illustration. Host-facing necessary strokes and off marks follow currentColor, while marks over an owned internal backing use the asset's own paint/clip ownership. The per-element [icon paint roles](../../docs/icon-paint-roles.json) are the single authority, including filled artwork and exposed connectors; do not infer that filled assets are unchanged or wholly exempt. Do not add runtime background guessing, another renderer or a copied color table. Geometry and explicit child styling remain caller/asset-owned.

Anchored panels share one actual-Overlay layout owner for Select, DatePicker, TimePicker, Pagination and Tooltip. A fitting reference attachment keeps its position, gap, shape, color and content. Only an overflowing result is moved inside the viewport; the existing available-width constraint applies when content cannot fit. The real child is laid out once, with no post-frame size guessing, cloned content, Gallery override or parallel positioning path. Components retain selection, focus, lifetime and scrolling: Select reveals its active keyboard option; a narrow single calendar scrolls horizontally, range calendars retain their existing horizontal scroll, and short time/long tooltip panels scroll vertically. Explicit opaque child styling and state remain authoritative. This is the user-approved limited usability deviation from the reference overflow defect, not a claim of exact parity or complete platform acceptance.

Vertical popup height follows the available attachment-side space so the original trigger remains usable; fitting geometry receives no extra offset. Select owns and disposes its list scroll controller, reveals the committed row on list attachment and moves only that list for keyboard activity, preserving caller scroll positions.

Modal Tab traversal consumes forward and reverse keys even when a closed loop keeps the same target or contains no actions. One shared boundary in the existing action module delegates order to the existing FocusScope, owns one skipped non-semantic target for an otherwise empty scope, and removes its borrowed-scope listener and owned node on disposal. It does not inspect children, add another FocusScope or replace a caller-owned focus target. IslandDialogRoute now defaults explicitly to TraversalEdgeBehavior.closedLoop; an explicitly supplied non-closed-loop policy, including null inheritance from Navigator, remains authoritative. Drawer, Loading, showIslandModal and the shared preview/alert route consume this same behavior. Platform input verification remains separate from widget tests; current scope is resolved by the audit owner above.

[Gallery parent layout authority](../../docs/DESIGN.md#gallery-parent-layout)

Select completes keyboard focus after popup presentation using the latest focus history. Pointer opening, selection, Escape and clear keep keyboard input usable; Tab retains its destination, including the separate clear action. A single cancellable completion after portal attachment/removal restores focus only when it has fallen to the framework root scope and the app is active. Explicit controls and caller-owned scopes remain authoritative. Disable, borrowed-focus replacement and unmount cancel stale completion. No DOM patch, polling, global keyboard interception or additional FocusScope is used.

Radio and Checkbox groups expose optional spacing: a finite nonnegative gap, default16 horizontally and12 vertically. The same gap governs wrapped rows; selection and focus ownership remain unchanged. Gallery supplies20 for the first controlled example, uses the existing demo surface and the recorded initial values. Single-line Input hints remain single-line with adornments; maxLines explicitly governs multiline hints.

Use column.width for fixed or LayoutBuilder cells. Use mutually exclusive preferredWidth when intrinsic content may shrink a desired width; auto/preferred cells require finite intrinsic widths. Headers inherit no-wrap defaults, and explicit child styles remain authoritative. For Pagination fitting, wrapping and alignment, use the [Pagination contract](../../components/pagination/contract.json).

Stamp masks keep centered5px holes/16px pitch, partial corner holes and the reference masked shadow result. Parents own layout; a caption must retain the same declared width as its image.

The catalog layout followup keeps each owner explicit. Table requests centerEnd for its pagination composition. Tabs proportionally shrinks each capsule's content contribution, preserves padding and intrinsic minima, and stretches the capsules to the tallest wrapped label. Opaque labels keep their keys, styles and lifecycle; a caller controls their line-break opportunities. The Gallery's known Chinese tab labels explicitly include zero-width break opportunities to reproduce CSS CJK wrapping without inspecting arbitrary children. Divider repeats complete size+gap cycles with no final connector; tiled waves retain the centered reference phase.

IslandTheme.codeFontFamily is the package-qualified bundled Fira Code family. CodeBlock and Gallery icon identifiers use it with zero default letter spacing; explicit CodeBlock.style.textStyle controls typography; the style foreground and syntax roles own ink. Fira Code is a project resource, not an installed system font. Arimo is a Gallery-only fallback for the reference's Arial native-control examples. docs/font-resources.json binds upstream commits, unchanged font bytes and OFL notices. Fonts/engine raster differences remain separately reviewable; neither font packaging nor widget tests establish whole-library visual acceptance.

### Catalog measured layout followup

CodeBlock.padding is an optional content inset; null retains the copyable-dependent default. Explicit insets must reserve space for a visible copy action. The Home consumer requests28px horizontal/20px vertical,13px/1.8 text, zero margin and max600px width. Progress info inherits16px/1, weight700 and0.32px letter spacing; explicit opaque info styles remain authoritative. No public slot is inspected or rewritten.

Gallery owns its margins, row stretching, leaf text metrics and example configuration. Package consumers must not import Gallery capture helpers or treat capture success as complete visual acceptance.

Carousel region primary focus owns an external2px contour offset3px; descendants keep their own indicators. Arrow/dot/rotation controls reuse FocusOutline for2px external contours offset2px with opaque white backing over photo pixels. Keep wrapper topology and geometry stable; do not add another focus node or inspect slide contents.

Gallery photo captions remain explicit caller-owned content under [the current presentation authority](../../docs/DESIGN.md#home-host-and-photo-gradient). Runtime Carousel must not inspect, duplicate or recolor opaque slides.

Use the maintained scene SVGs through the existing renderer/import pipeline. Preserve asset geometry, opacity, paint and clipping; do not add a runtime fallback, renderer fork or relaxed parser limit. Current target-engine decode evidence belongs to the audit entry above.

Optional parent Card/Tag actions must preserve opaque child focus; resumed-view reconciliation respects explicit external focus and disposal. Value-keyed Tabs preserve focused header identity on reorder; external browser/control focus wins. Search Select owns one named editable node across popup updates; do not replace it in a host.

Gallery leaves semantics activation to Flutter/platform demand instead of unconditionally forcing Web accessibility text editing. Semantic metadata remains in the widgets; semantic contract tests enable it explicitly. Normal Web editing retains native composition and first-input behavior. Reader execution remains excluded.

When search becomes disabled, its native editing client is retired before the committed host label replaces a composition buffer. Deferred restoration uses the latest label and is cancelled by re-enabling, a newer host update or disposal; it emits no selection proposal and takes no focus.

Select filtering opts out of native autofill forms: its query is transient option search, not a saved form field. Clear-slot geometry changes must not trigger autofill focus changes during disable.

A pending presentation-focus recovery survives benign host/theme rebuilds while its child/header owner is unchanged. New recovery ownership supersedes the previous request; replacement, removal, disposal, inactive view and explicit external destinations retain priority. Rebuilding alone does not cancel an otherwise valid request.

Locale acceptance covers the declared English/Chinese internal action defaults and inherited direction/text scale. Application copy and the Chinese reference Gallery remain caller-owned; no automatic translation of opaque content is promised. 

Independent Card/Tag/Table child focus attaches to the existing caller Focus node, including a FocusScope; if no inherited focus exists it uses the existing manager root. A scope boundary must not silently place the child beneath the optional parent detector or paint parent focus over child focus. One shared ActionSurface owns this fork; no new scope or copied child subtree is introduced.

Closed Drawer excludes the whole retained viewport entry, including captured locale wrapper semantics. Keep its child mounted; do not replace this with a second overlay or a Gallery-only pointer fix.

### Version scope / 本版本范围 (2026-10-18)

The installed SDK does not project the full Select combobox role; its existing button/TextField projection is a named version exception, not an implemented or passed role. Keep keyboard, focus, IME, names/states and contrast requirements; do not modify the SDK or add a DOM shim. Existing version decisions follow [DESIGN](../../docs/DESIGN.md). Public repository redistribution follows the owner confirmation recorded in the [rights and provenance boundary](../../docs/RIGHTS.md). Current accepted limitations, verification and pending work have the single audit owner identified above.

### Gallery visual follow-up / Gallery视觉修正

Current Gallery Home/Carousel presentation and named contrast exceptions follow [the DESIGN authority](../../docs/DESIGN.md#home-host-and-photo-gradient). This reference is not a new platform acceptance or a global contrast waiver.

### Gallery Background visibility and finite scope (2026-10-20)

Gallery alone owns scene-preview viewport culling. It skips painting a wholly clipped preview outside the nearest scroll viewport plus1logicalpixel, while retaining the mounted public IslandBackground subtree, geometry, semantics and hover/click path. Partially visible scenes keep the existing canvas; no public option, bitmap cache or child inspection is added. Host applications do not need to copy this Gallery optimization.

Icon retains the user-accepted actual-load cadence limitation. It grants no guarantee of physical frame delivery, all-platform performance or a quiet-load benchmark. Use the current audit entry above for the recorded scope and remaining verification; do not copy historical CPU, round or timing statistics into an application contract.

Surface sampling / 表面采样 authority: [DESIGN](../../docs/DESIGN.md#surface-sampling). Platform results remain source-bound in the sole audit record; this contract update is not acceptance.

Fractionally moving notification, tooltip, picker-panel and opaque carousel content follow [the existing surface-sampling owner contract](../../docs/DESIGN.md#surface-sampling). Content remains caller-owned; no child inspection or host-side text compensation is needed.

The retained Notification/Tooltip renderers have an accepted ink-centroid measurement limitation. This is not a passed pixel criterion, proof of perceptual lag or a diagnosis of engine cause. Do not add host-side text compensation. Current source-bound results and remaining browser/physical-presentation checks belong to the audit entry above.

- Button owns one fixed busy surface recipe in both host themes; global brand leaf remains unchanged. Customize a busy pair through the existing ButtonStyle foreground/background/side together. Colorway and Title defaults remain with their shared source owners; verify nested text-action pressed/close/focus states before changing shared foregrounds. See docs/DESIGN.md#original-color-restoration; never add a consumer palette or rewrite explicit child styles.
- Follow the [fixed-pair design authority](../../docs/DESIGN.md#c6-shared-foreground) and [Title role policy](../../docs/DESIGN.md#c7-title-foreground) for palette ownership decisions; consume the library roles rather than copy a local palette.

- Busy content reuses the existing fixed-surface semantic scope for nested defaults. Keep one stable child topology across busy changes and retain unrelated ThemeExtensions and explicit slot styles; do not add per-child compensation.
