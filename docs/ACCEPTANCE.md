# Acceptance / 验收

## Current work scope / 当前工作范围 (2026-10-17)

User scope decision, 2026-10-17: all screen-reader execution and validation are excluded from this work, including NVDA and other readers. Do not install or start reader software, request reader validation, or keep it as a remaining acceptance blocker. Excluded is not passed or certified. Preserve existing semantic metadata, keyboard navigation, focus behavior, contrast requirements and their tests. No new software may be installed for acceptance. Historical reader-related pending notes below do not define the current work scope.

用户于2026-10-17明确将所有读屏软件运行与验收从本工作范围中排除，包括NVDA及其他读屏器。不得安装或启动读屏软件、再次要求读屏验收，或将其保留为待完成的验收阻塞项。排除不等于通过或认证。保留现有语义信息、键盘导航、焦点行为、对比度要求及相应测试。验收不得安装新软件。下文历史记录中的读屏待验收说明不再定义当前工作范围。

Status: complete production acceptance remains NOT_ACCEPTED; this does not revoke source-bound finite usability decisions or accepted named limitations. Current status has one owner: `scratch/global-audit-20261014T035753Z/report.json` in the original delivery workspace (outside both source archives), under `finite_closeout_followup`, `current_work_checkpoint` and `remaining_acceptance_work`. The delivery review entry identifies that workspace record. Earlier `latest_attempt`/`final_validation` and dated checkpoints below are historical source-bound inputs, not current projections. A completed checkpoint is historical once source changes; neither an older pass nor a failed native flow proves current source. The baseline is the pinned v2.2.1 Gallery, its 40 component routes, Skill guide and homepage.

- Visual: same viewport, font files, scale, scroll position and state. Compare geometry, spacing, color, illustration, typography, clipping, hover/focus/press/disabled/loading/error/empty states. Random/time-based examples need a fixed clock/seed for repeatable comparison.
- Behavior: every reference demonstration is interactive through the public Flutter package. Controlled proposals can be rejected; stable IDs survive reorder; keyboard activation dispatches once; child actions do not activate ancestors.
- Composition: parent placement constraints, component surfaces and slot defaults have separate owners. Explicit child styles win. Borrowed focus/controllers are not disposed. Rich text uses explicit spans instead of arbitrary Widget-tree rewriting.
- Platforms: build Windows and Web; test keyboard, pointer, focus restoration, resize and IME. Mobile acceptance is deferred.
- Accessibility: document names/roles/states and test keyboard/assistive technology. The pinned reference remains the layout, typography, shape, content and interaction baseline. On 2026-10-15 the user authorized documented accessibility color differences within one Animal Crossing product palette; keep the existing 4.5 text and 3.0 necessary-graphic budgets, preserve historical failures, and verify actual state/background pairs on Windows and Web. No parallel palette, runtime contrast guessing or opaque-child rewriting. Global migration and all-state acceptance are still in progress; token-budget passes alone do not establish compliance.
- Coverage: run tool/reference_coverage.py. Missing stories fail coverage. A registered route or passing build is not visual acceptance.
- Packaging: include SVGs, licenses and required runtime dependencies. Verify a fresh package consumer. Earlier SDK-only and 250 KiB source-budget assumptions are superseded by licensed reference assets.
- Rights: retain source and transformation hashes. GROBOLD use is based on the user's 2026-10-13 confirmation; no additional redistribution rights are inferred. Retain Nunito/Noto OFL and reference MIT notices.
- Release: all of the above remain required. No automatic publishing.

The initial custom visual design, 20-component scope and 48px default-button height are superseded. Reference middle buttons are 45px; touch target enlargement must not silently change desktop Gallery geometry.

## 2026-10-14 historical interaction and narrow-layout checkpoint

The draft now preserves opaque child state and focus when Card, Tag or Table parent callbacks change. A child action dispatches independently. Passive/disabled action surfaces no longer advertise a fake semantic tap; actual controls keep independent labels. Button hover/press/loading, Tag border/close geometry and the actual soft default follow measured reference states. Shared focus painting owns no component colors or motion.

- Root: 159 passed; the unchanged contrast assertion remains FAIL (2.8591789258574094 < 4.5). Palette and threshold are preserved.
- Full fatal-info analysis passed. Gallery: 85 passed, including the new 375px placement and header oracle. Extracted public package: 32 passed, 259 archive members verified and package resolution checked.
- Physical Template: schema-valid draft with all registered scenarios mapped to checks. Original unsupported extensions and eight obsolete contracts were preserved before repair. Reference observations are separated from interface contracts. Structural validity is not visual/commercial acceptance.
- Web Release passed. Live 375×812 reference/local small Tag top-left is (41,467), height 24; widths are 52.609375/52.59375. Header centering, 16px content inset, 21px description line box and default soft blue appearance were inspected. This is one narrow page, not all-route responsive acceptance.

The reference Tag API table says solid, but its live DOM and pinned implementation use soft. The unreleased solid-default attempt was corrected. Documentation now follows actual behavior and records the discrepancy.

The initial Windows command returned success while one drawer trigger missed during the previous close transition. Its no-depth screenshot contained no panel and was rejected as evidence for that state. The integration test now asserts hit-testable triggers, all five visible panel titles and accepted Escape closes after settled transitions; the failed evidence is retained.

Administrator Windows Release passed, and the repaired native flow passed with 93 fresh captures, including 375px Tag and all five drawer states. The live binding needs both surface constraints and TestFlutterView metrics updated; the first narrow run failure is preserved. Evidence: `evidence/raw/native-viewport-20261014T003751Z/checkpoint.json`, supplementing `evidence/raw/tag-narrow-20261014T002722Z/checkpoint.json`. Runtime/assets/dependency hashes are unchanged between these runs; only the native harness changed.

Remaining: Modal example-specific content/body geometry and other listed interaction/motion gaps; all 40 pages/states and remaining narrow layouts; actual OS picker/drop; assistive technology; performance/size and final rights review. The CupertinoIcons Web build warning remains. No publishing. Overall NOT_ACCEPTED.

## 2026-10-13 validation checkpoint

Coverage is complete: 40 component stories plus the Skill guide, with a separate homepage. Implementation maturity remains experimental. No component's visual acceptance has been promoted.

- Root tests: 132 passed, 1 failed (`scratch/root-tests-40-linebox.log`). The remaining contrast assertion is 2.8591789258574094 against 4.5; neither palette nor threshold was changed.
- Fatal-info analysis: passed (`scratch/analyze-40-linebox.log`).
- Gallery tests: 84 passed at 1440 and 768 pixels (`scratch/gallery-tests-40-linebox.log`). The later Form caption correction passed both affected page tests with measured input-position assertions (`scratch/form-reference-geometry-tests.log`).
- Upload: 15 focused tests passed, including coalesced progress bursts, HTTP multipart, cancellation, lazy SVG preview and exact-route disposal (`scratch/upload-final-tests.log`). Form: 11 focused tests passed, including mixed-script line boxes and borrowed focus-node replacement (`scratch/form-linebox-tests-3.log`).
- Administrator Windows build and the complete native Gallery flow passed before the last caption correction (`scratch/windows-admin-current-result.json`, administrator=true). That flow captures 41 registered routes and selected interactive states; it is not exhaustive all-state visual acceptance.
- The first final rebuild was interrupted with an empty `scratch/web-build-40-aligned.log`. It is not PASS. Recovery uses new logs rather than overwriting that attempt.

Outstanding: exhaustive state-by-state reference comparison; Table vertical line-box geometry (intrinsic columns corrected in the later checkpoint); remaining motion/shape/hover differences; narrow Web review; actual Windows file dialog and OS drag/drop; assistive-technology review; broader extracted-package consumer coverage; performance/size and final rights review. Web build output also reports an unresolved CupertinoIcons font warning. GROBOLD authorization is already recorded and is not awaiting another confirmation.

The obsolete custom-design `tool/browser_check.cjs` was removed because its visit/theme/RTL flow did not test the requested Gallery. Existing failed and interrupted logs remain available. Builds and selected interaction flows do not constitute production acceptance.

Recovery completed: latest Web Release and administrator Windows Release/native flow passed after the final Form caption correction. Windows flow completed at 2026-10-13T18:45:38.8405775Z. Independent extracted-package consumer passed and resolved the archived package, with every package member hash retained. Evidence: `evidence/raw/20261013T184907Z-recovery/checkpoint.json`. This is targeted engineering proof, not all-state or commercial acceptance.

## 2026-10-13 Table layout checkpoint

Table now owns intrinsic shared-column layout without inspecting or remounting opaque cell widgets. Child-only content changes, column reorder/removal, resize and RTL are covered. Explicit-width cells support constraint-dependent LayoutBuilder content. The stripe-off label now retains the reference cross symbol.

- Focused Table/Pagination tests: 9 passed. Root regression: 135 passed, the same 1 contrast-budget failure remains (2.8591789258574094 < 4.5). No palette or threshold change.
- Fatal-info analysis passed. Gallery regression: 84 passed at 1440/768, including Table reference-column assertions. The later stripe-label change is exercised by the final Windows flow; the two final Gallery source files also passed a scoped analysis.
- Latest Web Release and administrator Windows Release passed. Windows native flow passed, producing 84 captures across registered pages and selected states. This is selected coverage, not exhaustive visual acceptance.
- Fresh 258-member archive: all extracted member hashes verified, consumer package resolution points to the extraction, and all 4 public-consumer tests passed (including the new Table layout tests).
- Live Web at 1440×1000 DPR 1: auto-column positions are within 0.03px of the reference. Stripe-off, loading/disabled/recovery and client next-page state changes were exercised. Header/body line-box differences still accumulate vertically; see docs/DESIGN.md.

Evidence: `evidence/raw/20261013T191211Z-table/checkpoint.json`. Overall status remains NOT_ACCEPTED. The interrupted and failed diagnostic attempts were preserved separately. The next Table comparison must resolve vertical line boxes on Windows/Web before promoting visual acceptance; the other release gaps listed above remain open.

## 2026-10-13 Table line-box checkpoint

- Table/Pagination focused tests: 10 passed, including text scaling and taller opaque content. Gallery: 84 passed at 1440/768.
- Full analysis initially reported one const-constructor info. It was fixed; all seven changed Dart files passed scoped analysis. The original failure log remains preserved.
- Web Release passed. Live reference/local row geometry at 1280×720 DPR 1 matches for the header and all five body rows; see docs/DESIGN.md and linebox-web-observation.json.
- Fresh 258-member extracted archive: hashes and consumer package resolution verified; 5 consumer tests passed.
- Windows Release and native checks for this source: NOT RUN. Start-Process returned the OS error “操作已被用户取消” at the UAC prompt; no administrator process started. No subsequent retry was attempted. The previous native PASS must not be reused for this source.
- The existing full-root contrast failure remains unresolved; the complete root suite was not rerun for this scoped layout change.

Evidence: `evidence/raw/20261013T212248Z-linebox/checkpoint.json`. Overall status remains NOT_ACCEPTED. Resume with the prepared scratch/windows-linebox-admin.ps1 after the user is ready for the Windows UAC prompt, then continue the remaining state comparisons.

## 2026-10-13 Windows line-box retry

The user-requested administrator retry completed at 2026-10-13T23:03:05.8825083Z. Windows Release build and the complete native Gallery flow both returned exit 0; administrator=true. The native flow passed the new Table header/body geometry assertions and generated 84 page/state captures. All 309 runtime, asset, dependency and integration-test hashes checked against the preceding Web checkpoint are unchanged.

Evidence: `evidence/raw/20261013T230411Z-linebox-windows/checkpoint.json`. This supplements the earlier UAC-cancelled checkpoint without overwriting it. The matching Web and Windows engineering checks are now complete for this line-box change; exhaustive state parity and commercial acceptance remain NOT_ACCEPTED. The unresolved contrast result and other release gaps above remain open.

## 2026-10-13 interaction checkpoint

Table hover now paints immediately; keyboard focus no longer changes row geometry or remounts opaque cells. Notification custom close content remains centered at intrinsic width inside its 22px hit area. Viewport overlays borrow the presenting route focus scope, allowing keyboard traversal into notifications.

Evidence: `evidence/raw/20261013T233127Z-interaction/checkpoint.json`; 411 source hashes verified unchanged at collection. Focused regressions: 25 passed. Root: 139 passed, the same contrast assertion failed (2.8591789258574094 < 4.5). Full fatal-info analysis, 84 Gallery tests, Web Release, administrator Windows Release and native flow passed. Native flow produced 87 captures including immediate Table hover and custom-close keyboard activation. Live Web persistent notification creation/clear worked, but transient custom-close visual capture remains unverified. These results precede the next Button change and must not be reused for changed source. Overall NOT_ACCEPTED.


## 2026-10-14 Modal and decorative overlay checkpoint

All seven Modal demonstrations now follow the pinned/live reference copy, organic shape, footer variants, mask opacity and typewriter sequence. Dialog routing, barrier dismissal, focus and surface styles have one library owner; Gallery owns demonstration state and explicit text composition. Typewriter.builder owns the grapheme timeline. Cursor uses a decorative overlay policy that cannot introduce fullscreen pointer or semantic targets.

Evidence: `evidence/raw/modal-decorative-20261014T021731Z/checkpoint.json`. The bound 469 source files matched before this documentation-only entry. Full root tests: 170 passed, one unchanged contrast failure (2.8591789258574094 < 4.5); Gallery: 89 passed; extracted-package consumer: 44 passed, all 259 package member hashes and actual package resolution verified. Fatal-info analysis, Web Release, Windows Release and native interaction flow passed; the native flow captured 106 page/states, including seven Modal examples at wide/narrow sizes and a real mouse barrier click. This run used ordinary privileges (administrator=false); the unattended elevation attempt did not start an administrator child.

Current live Web captures cover all seven final dialogs at 1440x1000 and the title dialog at 375x812. Reference surface geometry matches: wide widths520, heights217/234/266; narrow museum343x330. Escape/trigger restoration, default/custom actions, body-preserving clicks and outside mouse dismissal were exercised. A negative challenge disabling the decorative policy reproduces the extra semantic-node defect. The supplemental headless Chrome widget test stalled at suite loading and was cancelled; no PASS is claimed for it. Earlier attempts and discovered defects are preserved separately.

Overall NOT_ACCEPTED: this is a Modal engineering checkpoint, not exhaustive 40-component or commercial acceptance. Remaining reference states, actual OS picker/drop, assistive technology, performance/size, unresolved contrast and reference-asset rights remain open. No reference palette or threshold was changed to conceal the contrast result.


## 2026-10-14 Select selected-state checkpoint

Select now follows actual200ms opacity-only entry and immediate unmount; the unused150ms CSS rule was rejected after checking live behavior and JSX. Component-owned option spacing, hover triangle, selected pill and search-trigger geometry follow the reference. Clear emits one request without toggling the ancestor or closing the panel. Gallery reuses shared demonstration frames and accounts for CSS collapsed margins explicitly.

The component checkpoint `evidence/raw/select-20261014T023942Z/checkpoint.json` verifies471 source files,175 passing root tests plus the unchanged contrast failure,90 Gallery tests,52 extracted-package consumer tests and259 package members. Analysis, Web Release, ordinary-privilege Windows Release and native flow passed, with107 native captures. Actual Web selection, clear-while-open, filtering, empty state and committed search value were exercised. Wide trigger/option geometry matches measured reference positions (Web font width differs about0.016px). Select Web still exposes button/textbox roles rather than reference combobox/listbox; AT acceptance is pending.

Final Gallery-only frame/margin followup evidence is `evidence/raw/select-gallery-20261014T024717Z/checkpoint.json`. Its record independently binds the current Gallery validation and the unchanged library/package proof from the preceding checkpoint. No whole-source proof is silently reused across changed bytes. Overall40-component and commercial status remains NOT_ACCEPTED, with the previously recorded release gaps still open.


## Contrast diagnosis — 2026-10-14

The original first failure is light `muted/paper`: `#9F927D` on `#F8F8F0`, ratio **2.8591789258574094**, required **4.5**. These match pinned `src/styles/variables.less` (`@text-color-secondary`, `@bg-color`). Collapse answer text and Tabs panel text use this pair at 14px; live reference Collapse computed styles confirm both colors. This is not font rasterization, rounding, or a numeric-surface refactor regression.

The original loop threw at its first failed assertion, hiding later results. It now evaluates the same ten theme/pair budgets and reports all failures together, without changing a color or threshold:

| Theme | Pair | Colors | Actual ratio | Required |
| --- | --- | --- | --- | --- |
| light | muted/paper | #9F927D / #F8F8F0 | 2.8591789258574094 | 4.5 |
| light | leaf/onLeaf | #19C8B9 / #FFFFFF | 2.099243904954096 | 4.5 |
| light | light.ink/sun | #794F27 / #F5C31C | 4.291348614020366 | 4.5 |
| light | outline/paper | #DCD8D1 / #F8F8F0 | 1.3307376198822338 | 3.0 |
| dark | light.ink/sun | #794F27 / #F5C31C | 4.291348614020366 | 4.5 |

These are token-budget failures, not a complete page audit or five independent WCAG violations. `leaf/onLeaf` feeds the Material primary/onPrimary projection; Collapse also uses white symbols on teal. `light.ink/sun` is installed as Material onSecondaryContainer/secondaryContainer in both themes. `outline/paper` feeds control borders; decorative borders require use-specific classification, but the project's existing 3.0 budget remains unchanged. The supplied dark tokens are not evidence of reference dark-Gallery parity.

[W3C text contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) uses actual foreground/background colors without rounding the result; normal text requires 4.5. [Non-text contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html) requires contextual assessment of necessary control/state visuals. No disabled/decorative exception has been introduced into the existing tests. Exact reference colors and the retained acceptance budgets currently conflict; both remain recorded, and accessibility/release acceptance stays FAILED/NOT_ACCEPTED. User authorization is required before changing the design requirement, not before continuing unaffected reference checks.

The retained full diagnostic checkpoint is `evidence/raw/contrast-disclosure-20261014T051638Z/checkpoint.json`: 181 root passes plus the one contrast test failure (all five budgets listed), 91 Gallery passes, 53 extracted consumer passes, both Release builds and Windows flow passed with114 captures. A subsequent live Web picker focus-exit finding required another source correction, so this checkpoint is historical for that later change. The current report identifies the matching final source and remaining open checks. Collapse line metrics and exhaustive all-state/AT/release acceptance remain pending.

## 2026-10-14 Collapse scoped continuation

Current-source recovery initially matched all481 files in the previous final snapshot. PARITY-001 separates the Title nowrap surface, Gallery caption, and explicit question/answer leaf line boxes. Focused geometry and public style/opaque-content/scaling regressions pass; the preflight Gallery regression has94 passes. These are preflight results, not a replacement for the source-bound completed batch under report.final_validation.

The five contrast-budget assertions/four distinct pairs remain unchanged and failed. PARITY-001 geometry is corrected in the draft, but glyph baseline/raster and transition equivalence still require review. All-state40-page Windows/Web comparison, real assistive technology, Select combobox SDK limitations, actual OS picker/drop, remaining narrow/motion states, performance/size and asset distribution review remain open. Method1.1.0 is the reader used for this continuation; project method_version remains1.0.0 and is not an acceptance switch.


## 2026-10-14 Focus and narrow header continuation

PARITY-002 records the reference Collapse keyboard-focus raster: a 1px #101010 rectangular inset line clipped by the existing rounded header surface. The shared outline painter now takes component-owned width and offset; Button/Tag keep their 2px external stroke and 2px gap. PARITY-003 records absent U+2630 coverage in every bundled font and the measured 52px Gallery header, 28px actions, and equal three-bar menu artwork. Gallery chrome owns this artwork without importing a system font or substituting the different library menu SVG. Source-bound Windows/Web verification remains authoritative in report.final_validation; these scoped repairs do not close exhaustive parity, contrast, AT or release gates.

A11Y-005 was reproduced in both fresh Web and public Gallery widget tests: default spatial traversal interleaved wide navigation and document controls. Separate Gallery traversal regions correct this. Reverse traversal also exposed an initially unmounted final navigation action; the fixed menu now uses one complete scrollable Column. Existing keyboard navigation remains available even though the reference sidebar itself exposes generic click targets. TEST-004 updates the old Tag AppBar finder to the real title and equal-gap rule, preserving all original content geometry assertions. Failed exploration and the prior frozen batch remain historical evidence.


2026-10-15: One user-approved readable-motion rule replaces necessary whole-surface fades. MOTION-001 covers entry/exit/reversal/reduced and retained-subtree oracles. A11Y-011 records Loading background semantics leakage; A11Y-012 records dark Collapse focus. Original contrast budgets remain unchanged. Windows flow033138Z stalled after75 captures and exited79; preserve as failure. Current source requires a fresh Windows/Web checkpoint.


2026-10-15 counter-audit: A11Y-013..016 and MOTION-002..004 registered before correction. Eight new public tests cover actual focused input pixels, range hover, full celebration gradient, arbitrary-thumbnail status backings, preview/tooltip frames, local theme/reduced-motion retention, required glyph/loading pixels and single action names. Failed checkpoint040353Z retains Drawer build-phase assertions and stale-oracle evidence. Fresh source-bound Windows/Web and consumer proof remains required; exhaustive40-component visual/AT parity remains NOT_ACCEPTED.


2026-10-15 glyph followup: PARITY-018/019 and A11Y-017/018 record preview-close geometry/hover, Input full-width patterned Card and21px captions, stable field naming, and small-preview close hit bounds. Named targeted tests pass, including measured first field(318,321,360,40),32/40/48px sizes and150ms hover reversal. MOTION-005 removes implicit placeholder fading. A fresh source-bound batch is required after these edits.

### Atomic theme regions and field feedback
For runtime light/dark changes, use `IslandThemeHost(data: targetTheme, child: content)` inside `Scaffold.body` or the existing Material content. Pass the application's already-resolved target ThemeData, not an upstream AnimatedTheme intermediate frame. The host owns one opaque paper surface and synchronously installs Theme, default ink and IconTheme. It stores no theme mode or controller and does not inspect children. Nested caller-owned Scaffold/Material/AnimatedTheme or explicit styles start a new painting boundary. Static reference Gallery surfaces retain their backgrounds.
Input owns one FormField and TextField; controller/selection/focus survive helper/error and theme changes. Fill, border and helper/error switch atomically outside InputDecorator's implicit fade/interpolation. Validation/reset/controller replacement and error live-region semantics remain with the field. Countdown settles its existing digit timeline when reduced motion starts; restoring motion cannot resume an obsolete transition.

### 原子主题区域与输入反馈
运行时切换明暗主题时，在 `Scaffold.body` 或已有 Material 内容内部使用 `IslandThemeHost(data: targetTheme, child: content)`，传入应用已经解析好的目标 ThemeData，不能传上游 AnimatedTheme 的中间帧。宿主只负责一块不透明纸色底板和同步更新的 Theme、默认文字与图标；不另存主题模式或动画控制器，不检查子内容。调用者嵌套的 Scaffold/Material/AnimatedTheme 或显式样式构成新的绘制边界。静态参考 Gallery 保留已有底色。
Input 保留一个 FormField 和 TextField；辅助/错误消息与主题切换不丢控制器、选区和焦点。填色、边框、辅助/错误行原子切换，不使用 InputDecorator 的默认淡入和插值；校验、重置、外部控制器替换及错误 live-region 语义仍由输入框负责。Countdown 开启减少动态效果时结算原数字时间线，恢复动效不会续播旧过渡。

Fixed light surfaces use one internal LightSurfaceScope for readable token/text/icon defaults while preserving unrelated extensions and explicit child styles. ContentScope defaults IconTheme color to its explicit text role unless the slot supplies a distinct icon role. Card, Drawer, Modal, Notification, Tooltip and Table share the fixed-surface mechanism; Avatar/Badge/Title/Countdown, CountUp, Select, Tabs and Loading pair icon defaults with their owned text roles. This scopes inheritance; it never inspects or rewrites child widgets. 固定浅色表面统一提供可读的语义主题；默认图标跟随对应文字角色，显式子样式不被覆盖。

2026-10-15 continuation: A11Y-020 (MON-004) reproduced dark outlined/dashed Tag close hover at1.000481940691818:1 against3.0 using public API tests and Windows engine capture; live Web shows the same disappearing mark. Tag now pairs its own hover glyph/fill. Current-source verification is pending in the unique report; this repair does not establish exhaustive state/AT acceptance.

Card, filled Tag, Title and Select popup now scope nested public controls to their explicitly known surface foreground. Transparent Tag keeps ambient semantic roles without replacing its child subtree. Icon currentColor inherits IconTheme unless color is supplied; internal multicolor artwork remains asset-owned. All16 unfilled glyphs bind necessary strokes to currentColor while the pale spinner track stays decorative; the current catalog has163 glyphs. Explicit child styles and caller-owned custom surfaces remain the caller’s responsibility. Windows/Web live interface acceptance remains pending; screen-reader validation is excluded by the current user scope decision.

Card、填充 Tag、Title 与 Select 弹层为嵌套公共控件提供已知表面的配对前景色；透明 Tag 沿用宿主语义角色，不替换子树。Icon 的 currentColor 优先采用显式 color，其次继承 IconTheme；多色资产的内部颜色仍归资产所有。16个无内部填色图标的必要描边继承 currentColor，spinner浅色轨道保留为装饰；当前目录为163个图标。显式子样式和自定义底色由调用者负责配对。Windows/Web 现场界面仍待验收；读屏验收已按当前用户范围决定排除。

IslandDialogRoute is the public shared route for caller-owned preview/alert content. Push it on the root Navigator and retain its identity for exact-route cleanup. It captures caller themes and supplies opaque displacement and reduced-motion settlement; the builder owns dialog surface, semantics and actions. Gallery Form/Notification keep their existing AlertDialog adaptations, Upload keeps its560px normal IslandModal, and core Image/Upload reuse this same route. The old internal route name/path is removed. showIslandModal retains its independently observed game-dialog scale/timing. Real platform callback geometry and input acceptance remain pending; screen-reader validation is excluded by the current user scope decision.

IslandDialogRoute 是调用者自有预览/提示内容的公共共享路由。应推入根 Navigator 并保留路由身份，以便只清理本实例。路由捕获调用者主题，统一提供不透明位移和减少动态时的结算；内容、表面、语义和操作仍归 builder。Gallery Form/Notification 保留现有 AlertDialog 适配，Upload 保留560px普通 IslandModal，核心 Image/Upload 复用同一路由。原内部路由名称及路径已移除。showIslandModal 保留已独立观察的游戏弹窗缩放和时序。真实平台的回调几何与输入仍待验收；读屏验收已按当前用户范围决定排除。

The fixed foundation paired foregrounds also cover nested text-button pressed beige and ghost-button8% mint hover composition. Nine onAccent, seven Title and three patterned-paper foreground entries were deepened after396 measured failing frame checks across1092 recipes; fills, hover overlays and motion are retained. The complete old/new pairs and actual backings are registered under A11Y-023; static default contrast is not a substitute for these state checks.

固定基础配对前景色同时覆盖嵌套文字按钮按下时的米色底板，以及幽灵按钮悬停时8%薄荷色叠层。1092种配方中396个过渡状态检查失败后，统一加深了9个 onAccent、7个 Title 和3个纸纹前景色条目；填色、悬停叠层与动效保持。完整新旧色、实际底色和比值登记于 A11Y-023；默认静态对比度不能替代这些状态检查。

All16 glyphs without an internal filled region now inherit their necessary strokes from currentColor (explicit color, then IconTheme). The nine additional node-level transformations follow165 measured failing paint/background pairs across256 rendered contexts; only the pale spinner track remains decorative. Geometry, widths and all147 filled assets remain unchanged. The latter still need paint-order/adjacency review. This is one renderer with targeted owned-asset edits, not a blanket color filter or a second style mode.

16个无内部填色图标的必要描边现统一继承 currentColor（显式 color 优先，其次 IconTheme）。本次新增的9个资产逐节点改色依据256个实际渲染上下文中的165组失败配对；仅 spinner 浅色轨道保留为装饰。几何、描边宽度及其余147个有填色资产保持；后者仍待绘制顺序与邻接背景审查。这是单一渲染器的定向自有资产修复，不采用整图滤色或另一套样式模式。

Anchored panels share one actual-Overlay layout owner for Select, DatePicker, TimePicker, Pagination and Tooltip. A fitting reference attachment keeps its position, gap, shape, color and content. Only an overflowing result is moved inside the viewport; the existing available-width constraint applies when content cannot fit. The real child is laid out once, with no post-frame size guessing, cloned content, Gallery override or parallel positioning path. Components retain selection, focus, lifetime and scrolling: Select reveals its active keyboard option; a narrow single calendar scrolls horizontally, range calendars retain their existing horizontal scroll, and short time/long tooltip panels scroll vertically. Explicit opaque child styling and state remain authoritative. This is the user-approved limited usability deviation from the reference overflow defect, not a claim of exact parity or complete platform acceptance.

Select、DatePicker、TimePicker、Pagination 与 Tooltip 共用唯一的实际 Overlay 布局所有者。参考定位能放下时保留原位置、间距、形状、配色与内容，仅在实际越界时把弹层移回视口；内容确实放不下时沿用可用宽度约束。实际子树只布局一次，不猜测下一帧尺寸、不克隆内容、不做 Gallery 特例或并行定位路径。选择、焦点、生命周期与滚动仍归组件：Select 让键盘活动项进入可视区；单月日历过窄时可横向滚动，范围日历保留原横向滚动，短视口时间面板和长 Tooltip 可纵向滚动。显式不透明子样式和状态仍由调用者拥有。这是用户批准的限定可用性差异，不能宣称该越界状态与参考完全一致，也不代表平台整体验收通过。

Modal Tab traversal consumes forward and reverse keys even when a closed loop keeps the same target or contains no actions. One shared boundary in the existing action module delegates order to the existing FocusScope, owns one skipped non-semantic target for an otherwise empty scope, and removes its borrowed-scope listener and owned node on disposal. It does not inspect children, add another FocusScope or replace a caller-owned focus target. IslandDialogRoute now defaults explicitly to TraversalEdgeBehavior.closedLoop; an explicitly supplied non-closed-loop policy, including null inheritance from Navigator, remains authoritative. Drawer, Loading, showIslandModal and the shared preview/alert route consume this same behavior. Actual Web keyboard and Windows/AT validation remain separate from widget tests.

模态闭环即使保持同一目标或没有操作控件，也消费正向和反向 Tab。现有动作模块中的同一边界把顺序交给原有 FocusScope，仅为原本为空的 Scope 创建一个跳过遍历且不产生语义节点的内部焦点目标，并在卸载时移除借用 Scope 的监听、释放自有节点。不检查子内容、不增加第二个 FocusScope、不替换调用者的焦点目标。IslandDialogRoute 现明确默认 TraversalEdgeBehavior.closedLoop；调用者显式传入的非闭环策略（包括 null 以继承 Navigator）仍然有效。Drawer、Loading、showIslandModal 和共享预览/提示路由复用同一行为。真实 Web 键盘与 Windows/辅助技术验收独立于 Widget 测试。

[Gallery parent layout authority](DESIGN.md#gallery-parent-layout)

[Gallery parent layout authority](DESIGN.md#gallery-parent-layout)

## Scenario registration repair (2026-10-17)

Fifty previously added scenarios were absent from `library.json` check references. Their existing oracle groups are now registered with component-behavior or semantics-and-keyboard. This repairs the check inventory; it does not grant PASS or replace platform/reference review. Title is caller-owned content inside a modal, not another modal/FocusScope owner. Existing modal traversal policy, focus restoration and opaque-content contracts are unchanged.

| Contract group | Existing named oracle files |
| --- | --- |
| Physical border metrics | `test/border_metrics_test.dart`; component geometry tests and native Gallery geometry remain separate |
| Focus/state contrast and owned surfaces | `test/counter_audit_test.dart`, `test/known_surface_states_test.dart`, `test/navigation_contrast_test.dart`, `test/remaining_contrast_test.dart` |
| Single/empty modal traversal and lifecycle | `test/dialog_route_test.dart`, `test/drawer_test.dart`, `test/loading_test.dart`, `test/modal_contract_test.dart`; `example/test/dialog_callback_test.dart` |
| Select focus and placeholder-parent layout | `test/select_state_contract_test.dart`; `example/test/select_test.dart` |
| Anchored viewport bounds | `test/anchor_viewport_test.dart` |
| Picker focus exit | `test/disclosure_semantics_test.dart` |
| Radio/Rate state and keyboard | `test/selection_composition_test.dart`, `test/rate_motion_test.dart`, `test/choice_motion_test.dart` |
| Readable lifecycle/motion | `test/readable_motion_test.dart`, `test/loading_test.dart`, `test/theme_interruption_test.dart`, `test/time_components_test.dart` |

50个已新增场景此前未登记到library.json检查引用，现已接入已有行为或语义/键盘检查。上表给出实际已有测试文件；登记不是通过证明，不替代Windows/Web现场、逐状态参考对照或栅格审查。Title仅作为调用者自有模态中的内容，不拥有另一套路由或FocusScope；原有模态遍历策略、焦点返回与不透明子内容要求保留。测试粒度和尚未覆盖的实际状态必须继续如实报告。

## Cupertino font diagnostic (2026-10-17)

The locked SDK const-finder reports seven Cupertino icon constants before final JS optimization. A successful release `--dump-info` diagnostic retains none of the reported icon codepoints or the Cupertino font family/package string. The inspector, expansion/list, navigation and search rendering consumers are eliminated. CupertinoTextField retains a zero-byte type and a non-rendering spell-check inference helper. The raw compiler report and JS hashes are recorded by FONT-001 in the current audit. The original warning remains in raw build output; it was not suppressed, and no font, package or software was installed. This resolves the warning's reported consumer investigation for this build, not general visual acceptance or support for undeclared platforms.

锁定SDK的常量扫描发生在最终JS优化之前。成功的Release编译信息诊断确认：所报七个图标码点、Cupertino字体族与包名均未留在最终JS中；相关图标渲染构造与状态已消除，仅保留零字节类型和非渲染的拼写检查推断辅助函数。FONT-001绑定实际编译信息与JS哈希。原警告完整保留，没有静音，也没有添加字体、包或安装软件。此结论只解决该构建的字体消费者排查，不代表完整视觉验收或未声明平台支持。

## 2026-10-17 Select pointer-open keyboard focus

Select completes keyboard focus after popup presentation using the latest focus history. Pointer opening, selection, Escape and clear keep keyboard input usable; Tab retains its destination, including the separate clear action. A single cancellable completion after portal attachment/removal restores focus only when it has fallen to the framework root scope and the app is active. Explicit controls and caller-owned scopes remain authoritative. Disable, borrowed-focus replacement and unmount cancel stale completion. No DOM patch, polling, global keyboard interception or additional FocusScope is used.

Select 在弹层呈现结束后按最新焦点历史完成键盘焦点交接。鼠标打开、选择、Escape 和清除后可继续键盘操作；Tab 保留其目标，包括独立清除按钮。弹层接入或移除后的单次可取消回调，仅在应用处于活动状态且焦点落到框架根作用域时恢复焦点。明确的控件及调用者自有作用域优先；禁用、替换借用焦点及卸载会取消过期回调。不修补 DOM、不轮询、不全局拦截键盘、不增加 FocusScope。

Earlier tests at the reused 8791 origin lacked confirmation of the loaded bundle and cannot isolate implementation causality. Preserve that aborted checkpoint as historical evidence. A fresh-origin event-based implementation passed basic selection but a supplementary Tab-to-clear check lost focus. Additional semantics boundaries also failed a fresh ordinary-Gallery check and were removed. The current presentation completion passed ordinary Gallery checks at the no-store 8795 origin: pointer open, ArrowDown+Enter commits 鲷鱼, Enter reopens, Escape closes, and Tab+Enter clears the separate allowClear field without refocusing. These are connected in-app browser observations; actual Chrome/Edge retest remains required. New public oracles cover opening/closing scope loss, Tab destination, inactive app, explicit external/caller-scope focus and close/disable/replacement/unmount. Screen-reader execution is excluded.

## 2026-10-17 whole-library visual continuation

The live public site added Calendar after the fixed40-component scope. Visual comparison uses unmodified historical Pages deployment bb793a1bdc549ec78b2cfe25e179139ec10d655c; GitHub source history at deployment time resolves to the pinned79810934ee9d08c22044d34e06f8bba40391207b. The current audit binds all extracted blobs, matched1440x1000 and375x812 captures, and current Windows engine captures. Random photo order/Home wallpaper, authorized colors/readable motion and necessary Flutter usage text are attributed separately. Initial captures are not acceptance: native images must finish decoding, and animated score captures assert their intended phase.

The integrated correction restores choice demo surfaces/default values and spacing, separate navigation/page titles, Background navigation preview, short Home summaries and explicit DemoTag groups. Gallery-owned plain introductions keep solid ASCII slash words together as the measured browser layout does; Typewriter retains original semantic text. Home wallpaper retains random choices and percentage positions on viewport resize. Footer/Icon adjacent labels collapse the known parent margins; Icon supplies a labeled Flutter package setup block. Current execution results belong to scratch/global-audit-20261014T035753Z/report.json and its bound artifacts; these implementation notes do not declare full visual or release acceptance. Reader execution remains excluded and no new software is installed.

整库视觉续验使用与固定源对应的历史静态部署，并逐项记录参考/Web/Windows、桌面/窄屏和实际状态。随机内容、已批准的配色/可读动效和 Flutter 技术文案适配分别归因。修正实现不等于验收通过；最新结论只由既有审计及其绑定证据给出。读屏仍排除，不安装新软件。


The narrow review additionally repairs centered Tooltip direction rows, explicit Image widths, inline Pagination and its measured CSS shrink, preferred Table columns with fractional line boxes, completed Typewriter line spacing, and intrinsic Countdown/Rate rows. Gallery geometry fixtures now use actual zh localization and375x812. Raw quick-navigation captures that returned a stale composited route are diagnostic only; qualification requires separate navigation/screenshot calls and visible-title review. New integrated Windows/Web proof is required for this source; targeted checks and earlier-source captures do not confer acceptance.

窄屏复核继续修正方向行居中、图片声明宽度、分页单行及其实际收缩、表格可收缩列与分数行高、打字机行距，以及倒计时/评分固有宽度。测试按真实中文语言和375x812视口执行。快速切页得到的旧合成帧只作诊断；验收截图须分步切页、截取并目视核对标题。当前源必须重新收集 Windows/Web 证据；定向测试或旧源截图不等于验收通过。


Necessary filled-glyph roles (current2026-10-17): eyes, beaks, eye stalks, steam, connectors, off slashes and the coffee-cup heart are required marks. Brown-faced ink is strengthened to black; navy-faced eye rims use white and beaks keep their own yellow/coral. Exposed steam/connectors inherit currentColor. Off slashes use currentColor on the host and existing danger #E05A5A clipped to the original owned body. Snail eye stalks retain dark ink only over the owned green head. The original geometry and widths are unchanged; static local SVG clip/use references share paths, with no runtime background inference. The147 host-contour/closed-silhouette matrix is separate from individually named interior role probes and is not blanket certification of every artwork adjacency or browser state.

有填色图标的必要角色（当前2026-10-17）：眼睛、喙、眼柄、蒸汽、连接线、关闭斜线和咖啡杯爱心均为必要标记。棕色脸部画笔加强为黑色；深蓝脸部眼圈使用白色，喙保持自身黄色/珊瑚色。外露蒸汽、连接线继承currentColor。关闭斜线在宿主上继承currentColor，在原有自有图形内部裁切使用既有危险色#E05A5A。蜗牛眼柄仅在自有绿色头部保留深色画笔。原几何和描边宽度不变，静态SVG局部clip/use共享路径，不在运行时猜测背景。147项宿主轮廓/封闭剪影矩阵与逐项内部语义采样分开，不代表每个插画邻接色或浏览器状态均已通过。

The same required connector rule covers the original apple stem and balloon string: currentColor on the exposed host, with unchanged geometry. The public-render matrix additionally checks71 individually named semantic probes at48px; prior named own-backing and transparent-role assertions remain binding.

同一必要连接线规则也覆盖原有苹果茎和气球绳：外露宿主区域继承currentColor，不改几何。公共渲染矩阵另在48px逐项检查71个具名语义采样；此前具名自有底色和透明区域断言仍然有效。



Home/Carousel contrast acceptance follows the [current Home/Carousel decision](DESIGN.md#home-host-and-photo-gradient), including only its named exceptions; recorded failures remain failures.

首页／轮播对比度验收沿用[现行首页／轮播决定](DESIGN.md#home-host-and-photo-gradient)，仅适用已明确命名的例外；记录中的失败仍保留为失败。

Surface sampling / 表面采样 authority: [DESIGN](DESIGN.md#surface-sampling). Platform results remain source-bound in the sole audit record; this contract update is not acceptance.


### Fixed palette evidence / 固定配色证据

Follow the [fixed-pair authority](DESIGN.md#c6-shared-foreground) and [Title role policy](DESIGN.md#c7-title-foreground) when selecting applicable palette cases. Source-bound commands, original pixels, unresolved failures and platform outcomes remain in the sole audit record; this document does not duplicate current results.

配色场景适用范围遵循[固定配对权威](DESIGN.md#c6-shared-foreground)及[Title角色规则](DESIGN.md#c7-title-foreground)。源绑定命令、原始像素、未解决失败及平台结果仍由唯一审计记录拥有，本文件不复制当前结果。
