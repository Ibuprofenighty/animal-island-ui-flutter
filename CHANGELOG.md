# Changelog

## 0.0.1 — independent project, unreleased

- Correct the independent Title foreground pairing through its existing owner; policy remains in `docs/DESIGN.md#c7-title-foreground`, with unchanged APIs and contrast budgets.

- Correct shared fixed-palette guidance and consolidate its decision authority in `docs/DESIGN.md#c6-shared-foreground`; component APIs and rendering mechanisms are unchanged.

- Unreleased: unify bounded CodeBlock/Card custom color ownership and the ButtonStyle support contract; migrate all current consumers atomically, retain existing visual/platform limits.

- Establish the independent library and Gallery version as0.0.1. Current package/version metadata and companion archive names agree; Windows/Web artifacts require fresh builds with this internal version. No runtime, palette or component mechanism changes accompany this version synchronization.
- Earlier experimental artifacts keep their original source and version identities; they are historical evidence, not renamed0.0.1builds. Production acceptance and public publication remain pending.

## Historical development notes — former unreleased 0.2.0 label

- Apply the existing complete-surface sampler to active date/time-panel and opaque-slide fractional motion, preserving curves/placement/lifetime. Notification/Tooltip proposals are reverted; the user accepted retaining their original renderers and the independently reviewed ink-centroid measurement limitation on2026-10-21. Original0.25 failures remain, not pixel or physical-screenPASS. Nonmoving Select/Pagination paths and integer carousel arrows stay unchanged.

- Honor actual Gallery parent constraints for Select example rows, headings/tags, range-date examples and images; keep the Tooltip direction diagram reachable by explicit horizontal scrolling. Pagination preserves fitting sizing and wraps below its true minimum without replacing controls. Current authority: docs/DESIGN.md#gallery-parent-layout and components/pagination/contract.json.
- Sample moving backing/border/content as one surface to prevent glyph/vector rounding from producing hover lift mismatch. Preserve component timing, state/focus, reduced-motion behavior and single child identity. Current authority: docs/DESIGN.md#surface-sampling. Platform acceptance is source-bound in the existing audit report.

- Preserve independent Card/Tag/Table child focus at caller scope boundaries, and pending child focus and value-keyed Tabs focus across unrelated host/theme rebuilds; explicit external focus and owner disposal remain authoritative.

Fresh Flutter implementation of the pinned reference Gallery. Target: 40 components, homepage and Skill guide; Windows and Web first. Current page coverage is measured by tool/reference_coverage.py. Added composition patterns, reference SVG/font provenance, component stories, scoped extension Skill and behavioral tests. Visual, accessibility and commercial release acceptance remain NOT_ACCEPTED; no published release.

- Reference interaction alignment: Button variant states and loading motion, Tag border/close geometry, optional parent action identity and passive semantics. Tag retains the observed soft default; the reference API table listing solid is inconsistent with its live implementation. The unreleased solid-default attempt was corrected before release.

- Modal reference correction: seven demo contents and actions, body/header metrics, entry/exit, route-owned dismissal and focus. Added Typewriter.builder for explicit visible-prefix composition. Removed the unreferenced close icon; onClose remains an Escape intent.

- Select reference correction: opacity-only entry and actual immediate exit, option spacing/hover artwork, search trigger metrics and clear-child ownership. Gallery uses measured section spacing; shared overlay defaults remain unchanged for other consumers.

- Select search-prefix/IME handling, two-step Escape and clear keyboard ownership; explicit semantic relationships with SDK combobox limitations recorded. Drawer cursor composition, named dialog/title semantics, reference heading metrics and exit easing.

- Removed the unreachable Drawer title fallback. Synchronized closeLabel and semanticLabel in its contract, API documentation, Gallery API table and bilingual usage Skill.

Audit correction: Countdown/CountUp now use one outer numeric surface without sharing time state. Documented CountUp semanticLabel across contract, Gallery and bilingual Skill. Replaced obsolete Gallery/release guidance and included maintained delivery documents and project configuration in source-bound evidence scope.

Removed obsolete custom-design APIs (Dialog/showDialog, Notice, Spinner, EmptyState, ChoiceGroup, Slider and Tone) and the completed Button migration script. This experimental breaking cleanup has no aliases or compatibility wrappers. Current Radio/Card scenarios retain selection, disabled and narrow-layout coverage; tests exclusive to removed APIs are retired.

Component contracts now link their actual exported Dart declarations as the single signature/default authority, retaining behavioral requirements. Gallery usage tables document omitted labels, focus, style and rendering options.

Removed the unreachable custom Gallery postcard and CountUp celebration fallback; the public reference scene assets and the bounded celebration keyframes remain unchanged.

CodeBlock and Rate stories reuse StoryDemoBox with their explicit existing margin; duplicated local frame implementations are removed without altering demonstration content or geometry.

Contrast diagnostics now enumerate every existing theme/pair failure without changing palette or budgets. Disclosure, picker and pagination expansion is projected by their existing action semantics owner; fixed the Tabs scenario to describe stable value proposals.

Corrected DatePicker/TimePicker no-target blur through their shared focus boundary; external-control focus and outside-pointer dismissal remain effective. Added public and Windows-engine regressions. No reference colors or contrast thresholds changed.

Removed repeated Picker footer/time-option speech and decorative clear-glyph speech in Input/date/time controls; public semantic-name regressions cover the shared owners.

- Correct Title hover/variant text placement, Collapse independent reveal/detail timing, and Checkbox/Radio check glyph, delayed stroke, splash, disabled styling and focus outline. Cross-platform visual acceptance remains open.

- Unify border pixel metrics under IslandTheme for components and Gallery; preserve minimum physical strokes. Align Gallery CJK face availability and Title caption line boxes with the reference.

- Match Rate new-star stagger, shared splash geometry, hover/fill transitions and clamped roving keyboard behavior; retain11px busy Switch glyph at small size.

- Prevent synthetic bold for Gallery CJK600..900 through the single font recipe; expose Radio/Rate checked actions as radios on Web.

- Pair Tag close-hover glyph with its owned pale surface in every theme/variant. Add public palette, input-isolation and retained-child regressions; keep historical failed contrast evidence and original thresholds.

- Make CodeBlock comments readable on its default backing; reuse the shared light-surface semantic owner for Carousel slides without rewriting opaque content or duplicating lifecycle/state.

- Pair nested public controls with known Card/Tag/Title/Select surfaces; inherit monochrome SVG strokes from IconTheme with explicit-color precedence. Retain multicolor artwork and bind seven necessary-stroke changes in provenance. Remove obsolete Switch/ghost/Pagination state plumbing. Qualify all four scene decoder tests with the package asset namespace; prior consumer failure remains recorded.

- Expose the existing shared opaque preview route as IslandDialogRoute and migrate every consumer; remove the old private name. Gallery callback dialogs retain their surfaces while dropping the framework whole-content fade.

- Deepen only the foundation foreground entries failing nested ghost-hover/text-pressed compositions, retaining the same product palette, fills and motion.

- Extend inherited necessary strokes to the9 additional no-filled-region glyphs proven to fail in actual supported backgrounds (165 pairs/256 contexts). Preserve spinner decoration, geometry and147 filled assets; bind all node edits in provenance.

- Expose Select trigger focusability, primary-focus state and focus action without merging the separate clear or search field.

- Keep anchored content inside its actual Overlay while preserving fitting reference placement; retain component scrolling and reveal Select keyboard-active rows. Remove document navigation chrome from narrow Gallery Home.

- Modal keyboard correction: a shared closed-loop action boundary consumes Tab for single/empty content, keeps caller focus/order and cleans up its fallback target. IslandDialogRoute now defaults explicitly to closedLoop; explicit route policy overrides remain. The earlier Select placeholder min-content mapping is historical; the2026-10-20 parent-layout authorization supersedes its deliberate narrow overflow (docs/DESIGN.md#gallery-parent-layout). Existing failing platform evidence is retained; current Windows/Web verification is pending.

- Closed retained drawers no longer publish an empty viewport semantic layer over host actions; state retention and first-click/keyboard ownership remain intact.
