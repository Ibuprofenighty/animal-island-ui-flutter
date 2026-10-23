# Architecture / 架构

## Dependency direction

Gallery app/pages/shared → package public entry → component modules → foundation and internal interaction/presentation → Flutter platform.
A component may compose another component's public interface where the reference requires it: Modal → Button/Typewriter; Form → field interfaces; AvatarGroup → Avatar; Badge → arbitrary child; Carousel → arbitrary slide content.
Do not force primitive components into business entity/feature layers. No component reaches into another component's private implementation.

## Common patterns and their actual consumers

| Module | Owns | Implemented consumers |
| --- | --- | --- |
| ActionSurface | activation, focus/hover/press, disabled suppression and shared per-state null fallback; no visual recipes | Button, CodeBlock copy, selection options, Card, Collapse, BackTop |
| ContentScope | merged text/icon defaults without rewriting descendants | Button, Card, Modal, Collapse, Loading |
| LightSurfaceScope | existing owned-surface semantic defaults; explicit data may declare control tokens/brightness, never guessed from pixels | Card, Tag, Title, Modal, Drawer, Notification, Tooltip, Table, Select, Carousel, busy Button |
| AnchoredPanel | actual-overlay geometry, outside dismissal and optional presentation transition; host owns keys/value/focus | Select, TimePicker, DatePicker, Tooltip, Pagination |
| ViewportOverlay | OverlayEntry lifecycle and actual viewport constraints; captures framework theme/locale/direction/media | BackTop, Loading, Drawer, Notification, Cursor |
| PickerTrigger / PickerPanel | shared input/panel anatomy without shared selection state | TimePicker, DatePicker |
| OverlappingRow | opaque child layout, overlap, hit order, direction | AvatarGroup |
| DotPatternPainter | two-layer dot geometry with caller-owned colors | Background, Card |
| RollingDigit | digit transition and reduced motion | Countdown |
| IslandTheme.borderWidth | physical-pixel border metric (foundation/public theme) | Card, PickerPanel, Upload, Tag, Switch, Gallery Title demo frame |
| dismissOwnedRouteAfterFrame | exact-route disposal after tree mutation | Image, Upload |
| HoverSurface | pointer hover observation without activation | Upload |

Form's field registry and DatePicker's calendar traversal are implemented inside their own component boundaries. They are not generalized shared modules. FormTextField connects label activation through an explicit callback and owns or borrows its focus node; FormField does not inspect the widget returned by its builder.
Viewport overlays are independent of a trigger's visibility. Their content receives framework theme, locale, direction and media scopes. Resolve application-provider values in the host and pass them explicitly; arbitrary inherited application state is not captured.

Only extract when actual consumers exist. A shared module must hide repeated behavior, not merely forward calls. Unique geometry (ribbon, calendar, upload) stays with its component.

## Parent/child contract

1. A layout parent owns constraints, spacing and slot arrangement. It does not inspect child runtimeType, mutate child parameters, or reconstruct children.
2. Ambient defaults merge: explicit child TextStyle/Icon properties win. A parent's title style stays in its title slot; it must not bleed into body/footer or nested controls.
3. A child component resolves its own component theme and explicit parameters. Parent Card color must not recolor an explicitly styled Button or override its pressed/disabled state.
4. Controlled values belong to the host. Child callbacks propose changes; rejected proposals do not commit locally. Focus/hover/animation are local transient state.
5. Collection parents own selection and traversal; items have stable IDs, display slots and disabled state. Reorder/remove never transfers selection by old index.
6. Form owns the field registry and validation cycle; fields own editing/focus. Async validation results are accepted only for the current field/value/generation. Unmount/replacement unregisters.
7. Overlay parents own presentation lifetime and close arbitration; nested children keep state while mounted. Closing a child overlay does not close its parent. Borrowed controllers/focus nodes are never disposed.
8. Decorative wrappers do not absorb pointers, duplicate names, or create extra tab stops. Interactive parents and child actions must each activate exactly once.
9. No Gallery-specific implementation of a missing library component. Gallery uses public exports and records actual implementation/acceptance separately.

## Theme precedence

Supported state properties resolve per role and current state: instance non-null value → nearest component theme non-null value → recipe. Explicit transparent is a value. Card/CodeBlock instance and theme use the same component-sized style type and final recipe; contracts own exact support, not another matrix here. TextStyle fields merge; resolved foreground controls Color ink, while explicit foreground Paint retains Flutter precedence/caller ownership and is not inferred as a semantic Color role.
Primitive palettes feed semantic roles; component recipes derive from those roles. Reference geometry is component data, not a uniform 48px rule that changes the design.
Theme changes must propagate to mounted descendants and open presentations. Local themes do not mutate siblings.

Card transmits passive Color defaults and nested-control semantics separately through the existing LightSurfaceScope. IslandSurfaceTheme is immutable declared brightness plus existing IslandTokens data, not a new provider/scope. Null keeps the existing known-light pair; explicit data retains the control recipe without replacing it with passive ink. Presets/custom roles share one Card paint path, and CodeBlock retains one lexer. Button supports only the subset in its contract.

Card 经既有 LightSurfaceScope 分开传递被动Color默认值与嵌套控件语义。IslandSurfaceTheme 只是明确亮度与既有IslandTokens的数据，不是新provider／scope；null保留已知浅表面配对，显式数据不会被被动前景改写。预设／自定义共用同一Card画笔路径，CodeBlock只有一个lexer；Button支持范围只在组件契约维护。

## Required extension proof

Before expanding the catalog, tests exercise Card > Button > Text/Icon, Modal > Form > Input/Select, nested theme scopes, rejected controlled changes, dynamic item reorder/removal, nested overlays, and dispose during async work.
Adding a component adds its own module/export/catalog entry/tests; it must not require changing unrelated component implementations or adding a case to a universal render switch.

## Evidence

Reference specifications are observational inputs, not automatic PASS. Upstream React source is read only as public design/API evidence and asset provenance; no old local Flutter implementation is reused.
Acceptance requires all reference pages/states, real Windows/Web runs, comparison images and interaction checks. Current status remains NOT_ACCEPTED.

### Table and Pagination ownership

Table owns minimum content line boxes (scaled with inherited text scaling), not fixed row heights. Taller opaque children expand rows. Gallery owns explicit story-label line metrics and inline hobby decoration; visual padding does not alter Table column or row ownership.

Title owns its horizontally intrinsic painted surface and inherited nowrap/visible-overflow defaults for all variants. The host owns placement and its occupied layout slot, while the surface may overflow that slot. Constraint-dependent opaque children provide their own finite width; their explicit styles, state, keys and semantics remain intact. This is a Title layout policy, not a Gallery constraint override or child-tree inspection.

Collapse owns inherited question/answer typography; ContentScope only merges slot defaults. Gallery StoryText owns a plain string and its leaf rendering: it derives forced strut and scaled CSS 1/64-pixel line-box heights from the inherited style, measures its own string with TextPainter and permits glyph paint outside the declared box. The shared storyTextStrut factory also serves existing Modal/Drawer leaf renderers. Neither helper is a public library component or a policy imposed on opaque slots. Child layout/explicit metrics remain caller-owned; component font/color recipes are not copied into Gallery. Declared box geometry and Flutter glyph line advances are separate evidence: engine rounding remains, and Windows/Web visual verification is pending.

Table owns intrinsic column geometry inside its private layout part. Explicitly registered cell render boxes expose intrinsic sizes; arbitrary widget subtrees remain opaque and are mounted once. Geometry updates invalidate affected sibling cells through a Flutter layout callback, so child-only content changes reflow every row. Auto columns require finite intrinsic widths; LayoutBuilder and other constraint-dependent content must use column.width. This component-specific layout is not a shared pattern until another real consumer needs the same contract.


Table owns client data slicing and composes Pagination through its public controlled API. `IslandPaginationValue` is the shared immutable arithmetic contract. Total shrink normalizes display without generating a user callback. Row and column identities belong to the host; cells remain opaque. `HoverSurface` observes pointer hover for Upload; Card and Table use `ActionSurface` for their optional parent actions. `AnchoredPanel` also supports an upward preference for the size menu; each component still owns its keyboard and selection behavior.

### Numeric and media patterns

NumberSurface owns the shared Countdown/CountUp outer fill, padding, rounded shape, shadow and dashed border. NumberPlate separately owns the inner digit gradient, padding and optional border. Both accept opaque content and own no timeline, callbacks or semantics; each component retains those responsibilities. ActiveStack retains keyed Carousel children while sizing/hit-testing/announcing only the active one. ManagedImage owns decode callback generations for Avatar and Image. ViewportDeferred owns proximity-based activation. paperPalette is the single shared paper-color mapping for Card and Image.

Keep decoration wrapper topology stable across hover/focus changes. A nullable Container foreground decoration can insert/remove a RenderObject wrapper and remount opaque content. Use an always-present decoration wrapper, including an empty decoration when unfocused; test lifecycle identity, not only appearance.

Tooltip reuses AnchoredPanel through an explicit geometric attachment (target/follower/offset); placement remains independent of visibility and selection. Modal and Tooltip share OrganicBubbleClip.

Notification lifecycle belongs to its explicitly created controller, not a global store or the Gallery. One borrowed-controller host projects six viewport groups. Each handle binds an entry generation. Dismissal invalidates updates before invoking application callbacks; bulk dismissal snapshots entries so reentrant additions survive. Opaque action slots retain their own activation.

DrawerHost owns only its explicit background; Drawer owns its viewport panel and controlled close proposals. ViewportOverlay provides a transparent Material ancestor for arbitrary Flutter control slots. Cursor selection belongs to Flutter MouseTracker; local sessions paint only while selected. Nested cursor scopes cooperate explicitly through their own scope, without scanning or rewriting unrelated ancestors/children.

ViewportOverlay derives size from its actual Overlay constraints and captures inherited media before delayed layout, so an offscreen trigger or smaller MediaQuery cannot shrink a viewport surface. DrawerHost explicitly paints the exposed backplane. Cursor verification includes raster pixels and pointer movement/removal, not only MouseTracker selection. DatePicker and TimePicker reuse stateless PickerTrigger/PickerPanel and AnchoredPanel presentation; no shared committed selection state.

Upload owns selection/preflight/job identity and presentation. It receives typed IO callbacks; platform plugins and HTTP configuration belong to the separate public upload integration entry. A controlled progress transaction reads the latest acknowledged list before proposing a new snapshot. Job cancellation invalidates late events. Opaque visual trigger slots contain no nested action; parent placement and descendant content styling retain their existing owners.

IslandTheme.borderWidth is the sole physical-pixel border metric, shared by Card, picker panels, Upload, Tag, Switch and the Gallery Title demo frame through the public root. The old internal helper is removed. Positive borders floor to whole physical pixels with a minimum of one; nonpositive widths are absent. Glyph line boxes, sampling coordinates and item counts retain their separate owners. Explicit Input geometry overrides Material platform density locally; it does not mutate the application theme. Image and Upload share exact-route deferred cleanup, preventing owner disposal from popping another dialog. Picker demo padding is shared through StoryInset; adjacent CSS margins are represented once, explicitly by the Gallery owner.

ViewportOverlay borrows the presenting route FocusScope as the parent of its stable non-focusable bridge. Overlay owns geometry, while the route owns keyboard traversal; the bridge never disposes the borrowed node. Modal components still own their focus trap and restoration. Focus decoration paints without contributing layout padding. Notification close owns a 22px hit area; its opaque visual slot is centered at intrinsic width.

Optional parent actions retain one ActionSurface subtree in Card, Tag and Table. Passive hover is explicitly opt-in and does not invent activation. Composite parents attach child focus to the surrounding focus context, so changing parent activation cannot revoke a child control focus. The shared owner handles activation/hover/focus; each component still owns appearance.

Button, Tag and Collapse share FocusOutline with explicit width and offset policies. Button and Tag retain their observed 2px outline and 2px external gap; Collapse uses a 1px semantic-focus rectangular inset stroke, clipped by its existing rounded surface. It contributes no layout padding. Internal focus bridges use includeSemantics: false so visual parent grouping never combines independent child action names.

StoryDemoBox is the one Gallery owner of solid/dashed demonstration frames. CodeBlock and Rate supply their existing top margin through its explicit margin input; story-local copies of frame decoration are removed. This does not move component behavior into Gallery or share demo state.

ActionSurface projects component-supplied expansion on its existing named action node. Collapse, PickerTrigger and Pagination do not wrap it in a separate expanded-only semantics parent. This shares semantics projection, not disclosure state or child-clear ownership.

PickerFocusBoundary in picker_trigger.dart is the one shared date/time focus-exit policy. It forwards component-owned keyboard events and reports actual external focus targets; scope-only blur has no control target. It has no semantic action, open state, value or DOM/platform branch. AnchoredPanel independently owns outside pointer dismissal.

Semantic action names have one content owner: PickerFooterAction uses its visible plain text; time option labels own value+unit while excluding the duplicate numeric glyph text; PickerTrigger and Input exclude their owned clear glyph. ActionSurface does not globally discard opaque child semantics.

Gallery owns separate framework focus traversal groups for the desktop navigation and document regions. The fixed navigation uses one complete scrollable Column so reverse traversal from the document can reach the final action before that action has ever been scrolled into view. The existing mobile Drawer retains its own focus scope. Primitive controls do not intercept Tab or depend on Gallery/DOM ordering; modal boundaries consume traversal through the existing shared action module as specified below.

paintSixDotSplash is the shared six-dot geometry for ChoiceControl and Rate; it owns neither timelines nor center fill. ChoiceControl owns its immediate committed check and decorative splash, Rate owns350ms staggered new-star pops and a600ms last-star splash. Rate retains its own roving focus nodes and committed-value keyboard rules.

ActionSurface owns both checked and mutually-exclusive flags on its one semantic action node. ChoiceControl and Rate supply the latter; their former flag-only outer wrappers are removed. Radio/Rate own radioGroup roles; Checkbox remains independent.


## Readable motion ownership

The approved rule lives in docs/DESIGN.md. Internal SurfaceMotion provides presentation-only displacement and modest pulse without opacity, duplicated content or lifecycle ownership. Badge/Time consume it and CountUp reuses its pulse. Component controllers keep display conditions, timers, cancellation, focus and close callbacks. ActiveStack retains keyed slide subtrees but paints/hits/exposes only the active child. ViewportOverlay can block prior semantics outside its captured locale boundary when the surface owner marks its background unavailable; this does not move business state or focus policy into the overlay.


### Readable-motion counter-audit followup

Input focus, range placeholder/hover, Avatar overflow, Table loading and CountUp celebration now use readable pairs on their actual owned surfaces. Upload supplies opaque status/action backings over arbitrary thumbnails and theme-aware transparent tips; hidden hover actions reject pointer hits. Date/time navigation and footer controls paint focus without layout changes. Image/Upload preview routes share presentation-only opaque displacement, while components keep route lifetime and content ownership. Badge/IconButton descriptions reuse IslandTooltip. The close SVG changes only its X stroke to #B03038; provenance records the transformation. Drawer reduced-motion settling runs after build. These authorized color/motion differences retain the original thresholds and do not establish exhaustive state or assistive-technology acceptance.

### Atomic theme regions and field feedback
For runtime light/dark changes, use `IslandThemeHost(data: targetTheme, child: content)` inside `Scaffold.body` or the existing Material content. Pass the application's already-resolved target ThemeData, not an upstream AnimatedTheme intermediate frame. The host owns one opaque paper surface and synchronously installs Theme, default ink and IconTheme. It stores no theme mode or controller and does not inspect children. Nested caller-owned Scaffold/Material/AnimatedTheme or explicit styles start a new painting boundary. Static reference Gallery surfaces retain their backgrounds.
Input owns one FormField and TextField; controller/selection/focus survive helper/error and theme changes. Fill, border and helper/error switch atomically outside InputDecorator's implicit fade/interpolation. Validation/reset/controller replacement and error live-region semantics remain with the field. Countdown settles its existing digit timeline when reduced motion starts; restoring motion cannot resume an obsolete transition.

### 原子主题区域与输入反馈
运行时切换明暗主题时，在 `Scaffold.body` 或已有 Material 内容内部使用 `IslandThemeHost(data: targetTheme, child: content)`，传入应用已经解析好的目标 ThemeData，不能传上游 AnimatedTheme 的中间帧。宿主只负责一块不透明纸色底板和同步更新的 Theme、默认文字与图标；不另存主题模式或动画控制器，不检查子内容。调用者嵌套的 Scaffold/Material/AnimatedTheme 或显式样式构成新的绘制边界。静态参考 Gallery 保留已有底色。
Input 保留一个 FormField 和 TextField；辅助/错误消息与主题切换不丢控制器、选区和焦点。填色、边框、辅助/错误行原子切换，不使用 InputDecorator 的默认淡入和插值；校验、重置、外部控制器替换及错误 live-region 语义仍由输入框负责。Countdown 开启减少动态效果时结算原数字时间线，恢复动效不会续播旧过渡。

Fixed light surfaces use one internal LightSurfaceScope for readable token/text/icon defaults while preserving unrelated extensions and explicit child styles. ContentScope defaults IconTheme color to its explicit text role unless the slot supplies a distinct icon role. Card, Drawer, Modal, Notification, Tooltip and Table share the fixed-surface mechanism; Avatar/Badge/Title/Countdown, CountUp, Select, Tabs and Loading pair icon defaults with their owned text roles. This scopes inheritance; it never inspects or rewrites child widgets. 固定浅色表面统一提供可读的语义主题；默认图标跟随对应文字角色，显式子样式不被覆盖。

Tag owns its close-state colors: hover atomically pairs colorway.ink with colorway.soft; resting transparent variants retain surface ink. The16px target, separate keyboard/parent dispatch and host-owned removal remain unchanged. Explicit opaque child styles/state are preserved.

CodeBlock instance/theme use one typed style for surface, semantic syntax colors and copy states, with the same lexer/render path. Caller Paint remains opaque; see components/codeblock/contract.json. CodeBlock实例／主题以同一typed style和lexer／绘制路径覆盖表面、语法Color角色与复制状态，显式Paint仍归调用方。 Carousel reuses the existing light-surface scope for its fixed pale slide backplane, preserving unrelated theme extensions and explicit opaque slide styles/state. ActiveStack still owns active-only painting/hit/semantics; Carousel owns selection, timers and focus.

Card, filled Tag, Title and Select popup now scope nested public controls to their explicitly known surface foreground. Transparent Tag keeps ambient semantic roles without replacing its child subtree. Icon currentColor inherits IconTheme unless color is supplied; internal multicolor artwork remains asset-owned. All16 unfilled glyphs bind necessary strokes to currentColor while the pale spinner track stays decorative; the current catalog has163 glyphs. Explicit child styles and caller-owned custom surfaces remain the caller’s responsibility. Windows/Web live interface acceptance remains pending; screen-reader validation is excluded by the current user scope decision.

默认 Card、填充 Tag、Title 与 Select 弹层为嵌套公共控件提供已知表面的配对前景色；透明 Tag 沿用宿主语义角色，不替换子树。Icon 的 currentColor 优先采用显式 color，其次继承 IconTheme；多色资产的内部颜色仍归资产所有。16个无内部填色图标的必要描边继承 currentColor，spinner浅色轨道保留为装饰；当前目录为163个图标。显式子样式和自定义底色由调用者负责配对。Windows/Web 现场界面仍待验收；读屏验收已按当前用户范围决定排除。

IslandDialogRoute is the public shared route for caller-owned preview/alert content. Push it on the root Navigator and retain its identity for exact-route cleanup. It captures caller themes and supplies opaque displacement and reduced-motion settlement; the builder owns dialog surface, semantics and actions. Gallery Form/Notification keep their existing AlertDialog adaptations, Upload keeps its560px normal IslandModal, and core Image/Upload reuse this same route. The old internal route name/path is removed. showIslandModal retains its independently observed game-dialog scale/timing. Real platform callback geometry and input acceptance remain pending; screen-reader validation is excluded by the current user scope decision.

IslandDialogRoute 是调用者自有预览/提示内容的公共共享路由。应推入根 Navigator 并保留路由身份，以便只清理本实例。路由捕获调用者主题，统一提供不透明位移和减少动态时的结算；内容、表面、语义和操作仍归 builder。Gallery Form/Notification 保留现有 AlertDialog 适配，Upload 保留560px普通 IslandModal，核心 Image/Upload 复用同一路由。原内部路由名称及路径已移除。showIslandModal 保留已独立观察的游戏弹窗缩放和时序。真实平台的回调几何与输入仍待验收；读屏验收已按当前用户范围决定排除。

The fixed foundation paired foregrounds also cover nested text-button pressed beige and ghost-button8% mint hover composition. Nine onAccent, seven Title and three patterned-paper foreground entries were deepened after396 measured failing frame checks across1092 recipes; fills, hover overlays and motion are retained. The complete old/new pairs and actual backings are registered under A11Y-023; static default contrast is not a substitute for these state checks.

固定基础配对前景色同时覆盖嵌套文字按钮按下时的米色底板，以及幽灵按钮悬停时8%薄荷色叠层。1092种配方中396个过渡状态检查失败后，统一加深了9个 onAccent、7个 Title 和3个纸纹前景色条目；填色、悬停叠层与动效保持。完整新旧色、实际底色和比值登记于 A11Y-023；默认静态对比度不能替代这些状态检查。

All16 glyphs without an internal filled region now inherit their necessary strokes from currentColor (explicit color, then IconTheme). The nine additional node-level transformations follow165 measured failing paint/background pairs across256 rendered contexts; only the pale spinner track remains decorative. Geometry, widths and all147 filled assets remain unchanged. The latter still need paint-order/adjacency review. This is one renderer with targeted owned-asset edits, not a blanket color filter or a second style mode.

16个无内部填色图标的必要描边现统一继承 currentColor（显式 color 优先，其次 IconTheme）。本次新增的9个资产逐节点改色依据256个实际渲染上下文中的165组失败配对；仅 spinner 浅色轨道保留为装饰。几何、描边宽度及其余147个有填色资产保持；后者仍待绘制顺序与邻接背景审查。这是单一渲染器的定向自有资产修复，不采用整图滤色或另一套样式模式。

Anchored panels share one actual-Overlay layout owner for Select, DatePicker, TimePicker, Pagination and Tooltip. A fitting reference attachment keeps its position, gap, shape, color and content. Only an overflowing result is moved inside the viewport; the existing available-width constraint applies when content cannot fit. The real child is laid out once, with no post-frame size guessing, cloned content, Gallery override or parallel positioning path. Components retain selection, focus, lifetime and scrolling: Select reveals its active keyboard option; a narrow single calendar scrolls horizontally, range calendars retain their existing horizontal scroll, and short time/long tooltip panels scroll vertically. Explicit opaque child styling and state remain authoritative. This is the user-approved limited usability deviation from the reference overflow defect, not a claim of exact parity or complete platform acceptance.

Select、DatePicker、TimePicker、Pagination 与 Tooltip 共用唯一的实际 Overlay 布局所有者。参考定位能放下时保留原位置、间距、形状、配色与内容，仅在实际越界时把弹层移回视口；内容确实放不下时沿用可用宽度约束。实际子树只布局一次，不猜测下一帧尺寸、不克隆内容、不做 Gallery 特例或并行定位路径。选择、焦点、生命周期与滚动仍归组件：Select 让键盘活动项进入可视区；单月日历过窄时可横向滚动，范围日历保留原横向滚动，短视口时间面板和长 Tooltip 可纵向滚动。显式不透明子样式和状态仍由调用者拥有。这是用户批准的限定可用性差异，不能宣称该越界状态与参考完全一致，也不代表平台整体验收通过。

Vertical popup height follows the available attachment-side space so the original trigger remains usable; fitting geometry receives no extra offset. Select owns and disposes its list scroll controller, reveals the committed row on list attachment and moves only that list for keyboard activity, preserving caller scroll positions.

垂直弹层按所附方向的可用空间约束高度，使原触发控件保持可用；能放下的定位不增加额外偏移。Select 自己创建并释放列表滚动控制器，在列表接入时显示已提交选项，键盘活动项仅滚动自己的列表，不改动调用者的滚动位置。

Modal Tab traversal consumes forward and reverse keys even when a closed loop keeps the same target or contains no actions. One shared boundary in the existing action module delegates order to the existing FocusScope, owns one skipped non-semantic target for an otherwise empty scope, and removes its borrowed-scope listener and owned node on disposal. It does not inspect children, add another FocusScope or replace a caller-owned focus target. IslandDialogRoute now defaults explicitly to TraversalEdgeBehavior.closedLoop; an explicitly supplied non-closed-loop policy, including null inheritance from Navigator, remains authoritative. Drawer, Loading, showIslandModal and the shared preview/alert route consume this same behavior. Actual Web keyboard and Windows/AT validation remain separate from widget tests.

模态闭环即使保持同一目标或没有操作控件，也消费正向和反向 Tab。现有动作模块中的同一边界把顺序交给原有 FocusScope，仅为原本为空的 Scope 创建一个跳过遍历且不产生语义节点的内部焦点目标，并在卸载时移除借用 Scope 的监听、释放自有节点。不检查子内容、不增加第二个 FocusScope、不替换调用者的焦点目标。IslandDialogRoute 现明确默认 TraversalEdgeBehavior.closedLoop；调用者显式传入的非闭环策略（包括 null 以继承 Navigator）仍然有效。Drawer、Loading、showIslandModal 和共享预览/提示路由复用同一行为。真实 Web 键盘与 Windows/辅助技术验收独立于 Widget 测试。

The Select Gallery placeholder row models the reference CSS min-content width296=140+16+140 with visible parent overflow. It preserves both140px triggers, the16px minimum gap and fitting desktop space-between; it neither wraps nor shrinks the controls. At375px the reference trigger rectangles are(58,505,140,41) and(214,505,140,41). This corrects the parent layout mapping and is not another popup algorithm or a new visual exception.

Select Gallery 的占位示例行按参考 CSS 最小内容宽度296=140+16+140以及父级可见溢出布局；保留两个140px触发器、16px最小间距及桌面能放下时的 space-between，不临时换行或压缩控件。375px下参考矩形为(58,505,140,41)与(214,505,140,41)。这是父级布局映射修正，不是另一个浮层算法或新增视觉例外。
