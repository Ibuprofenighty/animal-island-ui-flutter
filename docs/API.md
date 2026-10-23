# Public API / 公共接口

## Implemented reference stories / 已有参考展示

The registry in `example/lib/pages/stories/registry.dart` owns executable page presence. Run `tool/reference_coverage.py` to compare against all 40 components and the guide. Presence does not mean complete visual/state coverage.

- Button / IconButton: typed variants and sizes, disabled/loading behavior, explicit content slots; ActionSurface owns activation.
- Title: layer/ribbon/tab silhouettes and reference palettes; inherited nowrap defaults and a horizontally intrinsic surface that may overflow the host layout slot.
- Icon: 163 pinned Naive Icons names; currentColor strokes inherit IconTheme unless color is explicit; internal multicolor paint remains asset-owned.
- Tag: four variants, palette, sizes, closable/clickable states; close does not activate the wrapper.
- Divider: reference line variants or repeated icon slot.
- Input / Switch / Checkbox / Radio: editing and controlled selection; stable option values.
- Select: typed options, controlled value, search/filter/clear; yellow side panel, keyboard and outside dismissal.
- TimePicker: controlled nullable value or explicit uncontrolled constructor; pending preview, confirmation, step values, controlled open state.
- Rate: controlled/uncontrolled value, preview, keyboard, clear/read-only.
- Modal: reference game/normal surfaces and route-based dismissal.
- Skeleton: paragraph rows share one full-block sweep. A short rowWidths list repeats its last fraction; an empty list uses full width. Loading=false preserves the caller child; absent child retains the placeholder.
- Typewriter / CodeBlock: placeholders and reduced motion; grapheme-safe explicit rich text; syntax display and clipboard lifecycle.
- Time / Countdown: instance-owned timers, injectable clock, deadline-based remaining time, one completion per deadline.
- Background: 19 reference wallpapers; only paints behind content. Scene assets shared with Progress.
- Footer: current or supplied year and copyright content.
- Progress: clamped percent, three sizes, optional scene, custom visual/semantic values; parent owns business progress.
- Avatar / AvatarGroup: explicit image/icon/content slots, load failure policy, inherited group defaults and opaque child overlap layout.
- Badge: mutually exclusive numeric/text/custom indicator slots, overflow/zero/dot states and optional wrapped child.

- Collapse: controlled/uncontrolled disclosure, opaque persistent slots, hidden focus exclusion and header focus restoration.
- Card: normal/dashed surface, 13 colorways and optional matching dot patterns; hover is independent of activation.
- Loading: full viewport snow, delay, decorative exit/reentry and local ticker; host owns business activity.
- Tabs: stable value-keyed items and focus, controlled/uncontrolled selection, active-panel lifecycle and keyboard traversal. The draft labels/index API is removed; the reference leafAnimation no-op is not reintroduced.
- BackTop: borrowed explicit/primary scroll controller, strict visibility threshold, keyboard return and independent viewport semantics.

Only the current reference component families and their explicit support types are exported. Export presence does not establish full page/state acceptance.

## Ownership / 所有权

A controlled callback proposes state; it does not commit it. Use stable value identities across reorder/removal. Borrowed TextEditingController and FocusNode instances are not disposed by components. Slot widgets retain their styles, keys and actions. Groups use inherited defaults, never runtime-type inspection or child reconstruction.

Title owns the intrinsic horizontal size of its painted surface and supplies non-wrapping, visible-overflow text defaults for every variant. The host retains control of placement and occupied layout constraints; the surface can extend beyond that slot. Supply a finite width inside a constraint-dependent child when needed. Explicit child text/layout choices remain authoritative; Title never derives them by inspecting the child tree.

IslandTimePicker uses IslandTimeValue(hour, minute, second), independent of date/timezone. Its normal constructor requires value and onChanged; null is a real controlled empty value. The uncontrolled constructor uses initialValue. open is independently controlled when non-null.

IslandProgress uses percent in 0–100, not the superseded 0–1 draft API. IslandBadge uses count/text/indicator, not the former tone label. IslandAvatar uses child/icon/image and size/dimension, not initials. All local consumers are updated together.

## Evidence / 证据

Component contracts live under `components/`. Composition and lifecycle tests exercise rejection, nested actions, defaults, reorder and disposal. Gallery tests check real fonts and layout at registered widths. Exact visuals, all interaction states and release acceptance remain pending; screen-reader execution is excluded by the current user scope.

## Pagination and Table

Pagination uses one immutable `IslandPaginationValue(page, pageSize)`. The default constructor is controlled; `.uncontrolled` owns only its initial value. Total changes normalize the displayed value without emitting a user event. Size changes deliver one normalized value; a rejecting controlled parent remains authoritative.

Table requires stable row keys and typed columns containing opaque header/cell Widgets. Optional `IslandTablePagination` supplies the parent-owned client pagination configuration. Table slices data once and composes a controlled Pagination. Reordering preserves row identity, and cell actions must not invoke row actions. Neither component mutates caller collections or takes ownership of caller resources. Auto columns share the finite intrinsic widths of their mounted cells and reflow when a child changes its own content. Set `IslandTableColumn.width` for constraint-dependent widgets such as LayoutBuilder. Width includes cell padding; when all columns specify widths, extra available space is distributed proportionally. 单元格仍是不透明插槽；Table 只通过显式注册的渲染单元同步列约束，不重复挂载子组件。

Table line-box minima scale with inherited text scaling. They do not cap row height: taller or multiline opaque content expands its row. 行框最小值随文字缩放变化，不截断更高的单元格内容。

Acceptance: controlled rejection, page-size clamping, total shrink, zero records, keyboard/outside dismissal, stable row reordering, child action isolation, two Gallery viewport sizes, and Windows/Web reference captures. Visual parity remains NOT_ACCEPTED until compared.

## CountUp

`IslandCountUp` owns its timeline, pause state, celebration and delayed repeats. The host owns target/start/counting intent. Callback replacement and formatting changes do not restart an animation. A borrowed `IslandCountUpController` offers reset; a reset during onUpdate supersedes the old completion. Builder/prefix/suffix are visual slots, excluded from focus and animated live announcements. Controls belong outside them. `semanticLabel` (`String?`, default null) explicitly names the value; the component never extracts a name from builder or affix widgets. CountUp and Countdown share only outer NumberSurface decoration and inner NumberPlate styling, not time state or callbacks.

## Carousel

`IslandCarousel<T>` uses stable `IslandSlide<T>.value` identities. Controlled proposals can be rejected. Inactive children retain state while being excluded from focus, hit testing and semantics; only the active child contributes height. Arrow/Home/End navigation belongs to the focused carousel region, so opaque child editors retain their keys. Autoplay pauses on region entry and resumes explicitly or after leaving; moving focus inside the region is not another entry. Primary region focus paints an external2px outline offset3px; descendant focus hands the indicator to its own control. Arrow/dot/rotation controls use external2px outlines offset2px with opaque white backing over unknown photos. These decorations reuse FocusOutline and do not add layout, focus nodes or slide lifecycles. Explicit photo captions remain caller-owned; their Gallery presentation and named contrast exception follow [DESIGN](DESIGN.md#home-host-and-photo-gradient). The runtime never extracts or restyles child content.

## Image

`IslandImage` accepts an ImageProvider. It owns preview visibility and removes only its own route on source replacement/disposal; it never pops an unrelated dialog. Preview dismissal restores the trigger only when its page is current. Lazy mode defers provider resolution until near the viewport. Load/error callbacks are source-bound; error frames are noninteractive. Card/Image share paper palette data; Avatar/Image share decode lifecycle handling.

### Tooltip
`IslandTooltip` observes hover or descendant focus; `.click` passes a toggle to an explicit trigger builder. The child owns its action, editing and focus. `message` supplies semantics; optional `content` is a noninteractive rich display slot. Twelve placements, normal/island surfaces, border toggles, 100 ms hover travel grace and 250 ms motion. Escape dismisses without stealing focus. No child cloning or pointer-event interception.

### Notifications
`IslandNotifications` borrows one `IslandNotificationsController`; its creator disposes it. `show(config, id:)` returns an identity-bound handle. `update` returns false from the instant dismissal starts, so stale progress cannot revive a notification or update a later generation with the same ID. The controller owns expiration and the 250 ms removal timer. `onDismiss` runs at the committed closing transition; `onClose` after removal. Body, action and close callbacks remain independent. Zero duration means persistent. Six groups render in ViewportOverlay; framework scopes are captured, arbitrary application dependencies must be passed as values.

### Drawer and Cursor
`IslandDrawerHost` explicitly owns a page background below the Navigator Overlay. Descendant controlled drawers register only their own open/depth state. Closing requests never commit open locally. Panel content remains mounted but hidden from pointers, focus and semantics when closed. Focus loops inside and returns after accepted close; the transparent Material viewport surface supports opaque native Flutter controls.

`IslandCursor` observes mouse motion and delegates cursor selection to Flutter MouseTracker. The selected local session hides the native cursor and paints the reference shape. `forceAll` changes cursor priority only; an explicit nested scope takes precedence, and scoped mode retains child MouseCursor contracts. No child widget inspection or gesture interception. Native/Web performance and latency profiling remain pending; this is a software cursor implementation.

### DatePicker
Use DateTime for single/month selection and DateTimeRange through explicit range constructors. All dates are local calendar dates; month values normalize to day 1. Preview stays local until confirmation; Escape/outside dismissal discards it. Controlled null is distinct from uncontrolled state. Disabled dates cannot be committed, including via Today. The trigger and panel anatomy are shared with TimePicker; AnchoredPanel owns placement and cancellable 200 ms presentation, while each picker owns its pending value and keyboard behavior.

### Form
IslandForm owns an internal controller or borrows an explicit controller whose creator supplies initial values and disposes it. IslandFormField<T> binds a stable name to an explicit builder; values must match T. IslandFormTextField owns its editor and synchronizes programmatic fill/reset without remounting it. Use widget keys when reordering field subtrees. Validators return FutureOr<String?>; async work is invalidated by edits, reset, removal or disposal. Submit emits only a current complete snapshot. Child size/enabled overrides remain explicit; defaults come from Form. Returned maps are read-only; application values should be immutable. No child-type guessing, reflective prop injection or global form store.

Form labels activate only an explicit onLabelPressed callback. The text adapter connects it to its own FocusNode or a borrowed caller node; disabled fields do not activate labels. Borrowed nodes survive replacement and unmount.

### Upload
IslandUpload requires explicit file-selection and request callbacks. The controlled host owns immutable file snapshots and stable IDs; rejected insertion never starts a transfer. Serialized progress commits wait for parent acknowledgement so concurrent files do not overwrite each other. Accepted deletion and disposal cancel only this owner's requests. Preflight hooks are serialized and invalidated by disable/disposal. Late selection/preflight errors follow the same generation check. Pending removal results and errors also require the same current file source; clearing/replacing that file invalidates both. Current errors still report once. Disabling does not cancel an already accepted transport.

预检按顺序执行，禁用或卸载会使其操作世代失效，迟到的选择／预检错误不会再通知当前宿主。待决删除的结果与错误还必须匹配当前文件来源；清空或替换该文件会使两者失效。当前有效错误仍只报告一次；仅禁用控件不会取消已接受的传输。 The visual child slot is noninteractive content; the Upload surface owns activation.

The separate animal_island_upload_platform.dart entry provides Windows/Web file selection, drop and HTTP multipart transport. Endpoint and extra fields may resolve asynchronously; cancellation is checked after each await. Browser credentials are opt-in. Unknown Windows MIME filter mappings fall back to an unrestricted chooser; the component still filters actual selections. The file-only adapter does not support directory selection. SVG and raster previews are loaded lazily after preflight; thumbnailBuilder receives an explicit BoxFit and bounded constraints. Simulation is explicitly selected by the Gallery; it is never an implicit production transport.


Table row hover switches immediately as in the reference; focus outlines do not change row geometry or cell identity. Notification closeIcon is a visual slot centered at intrinsic width within a 22px action area. Its explicit child styles remain authoritative; use onDismiss for dismissal side effects rather than nesting a close action.

### Button state ownership
Button owns each variant color, border, depth and 250ms cubic transition. ActionSurface supplies activation, focus states and the shared per-state null-fallback rule; component recipes still own appearance. Busy owns a disposable 2.5s counterclockwise 28px donut ticker and honors reduced motion; the host still owns the asynchronous operation. ButtonStyle instance values override the scoped theme, and explicit slot styles remain authoritative. Dashed borders reserve the same geometry as solid borders.

Card.onTap, Tag.onPressed and Table.onRowPressed may change between null and a callback without remounting opaque children. Child actions remain independent. Composite parents borrow the surrounding focus context for child traversal; disabling/removing a parent action does not revoke a child control focus. Passive parents add no keyboard target.

Tag defaults to soft, matching the live Gallery and pinned Tag.tsx. The reference API table incorrectly lists solid; actual behavior takes precedence. Request solid explicitly for filled tags. Close remains a separate 16px action; dashed borders reserve the same horizontal space as outlined. Button, Tag and Collapse share only the no-padding FocusOutline painter; color, shape, width, offset and timing remain component-owned. Collapse keyboard focus is the reference 1px black rectangular inset stroke clipped by the rounded surface.

Typewriter accepts optional strutStyle in both text and rich constructors. The caller owns line metrics; defaults remain Flutter Text defaults. The Gallery supplies its measured 21px description line box; explicit rich span styles remain intact.

Collapse owns inherited question/answer styles through ContentScope; opaque slots own their explicit line metrics and layout. Gallery StoryText is an owned plain-string leaf in example/lib/shared/story.dart, not a public library component. It derives strut and scaled CSS 1/64-pixel line-box heights from the enclosing component style, measures only its own string with TextPainter, and allows glyph paint to overflow the declared box. storyTextStrut is the shared Gallery factory also used by Modal/Drawer leaf renderers. These helpers never walk or rewrite opaque children and do not duplicate component font/color recipes. Flutter glyph line advances still use engine rounding; matching declared rectangles does not establish pixel-identical text. Windows/Web visual verification remains pending.

### Modal / Typewriter explicit composition

IslandModal owns surface, title/body style defaults, scrolling and action placement. onClose is an Escape intent; there is no synthesized close icon. An empty actions list omits the footer. showIslandModal owns a root-Navigator route: default cancel/confirm close that route, custom actions retain host policy, barrier dismissal and Escape are independent, focus loops and returns to the trigger. Entry is300ms ease(.92→1), barrier250ms; exit immediate.

IslandTypewriter.builder(text, builder:) supplies the visible grapheme prefix to a caller-owned layout. It shares the plain/rich constructors' timer, replay, reduced-motion, semantics and disposal behavior. It never walks the Widget tree. An explicitly owned Gallery leaf renderer can use its shared storyTextStrut factory to derive forced strut metrics from inherited defaults; this does not change Modal tokens or explicit span styles, and does not establish identical engine glyph advances.

Modal 管理表面、标题/正文默认样式、滚动和操作区；onClose 仅为 Esc 意图，不生成关闭图标。showIslandModal 管理自身路由和焦点，默认操作只关闭其拥有的路由，自定义操作由宿主决定。Typewriter.builder 仅向显式布局提供已显示的字素前缀，沿用同一个计时器，不检查任意子组件树。

Modal semanticLabel explicitly names an opaque title slot without inspecting its widget tree. Title semantics remain a separate heading; dialog bounds follow the surface, not the full-screen route. / semanticLabel 为不透明标题插槽提供显式名称，组件不推断子树；标题保留独立标题语义，对话框边界对应表面而非整个屏幕。

Cursor composition around modal surfaces and barriers must preserve the route barrier hit target. Never put an opaque full-page cursor wrapper above that barrier. / 弹窗表面与路由遮罩分别组合 Cursor，不能让整页不透明命中区域遮住路由的点击目标。


Select now shows its readable panel immediately and retains immediate exit; the reference opacity-only entry is superseded by the approved readable-motion rule. AnchoredPanel remains the shared overlay lifetime/placement owner; component motion parameters do not leak into Gallery. Clearing emits a null proposal and onClear once, preserves an open panel, and leaves commit authority with the host.

Select keyboard handling runs only for the trigger/search focus owner; clear owns its Enter/Space activation. Editing after a committed label starts a logical suffix query. During IME composition the native buffer and its original UTF-16 range stay intact; the field may temporarily retain the label prefix, and only commit/end normalizes it. onSearch receives the suffix once per changed logical query; normalization alone emits no duplicate. Active candidate keys belong to the text editor. Parent value changes keep the editing prefix bound to its original session, and focus-ending normalization cannot steal clear focus. Escape first clears a nonempty query, then closes. Trigger value/expanded/controlsNodes, list and clear have separate semantic owners. The non-search trigger also publishes focusability, primary focus and a focus action on its existing node; clear focus is independent and search uses its TextField. Disabled triggers omit the focus action. Flutter 3.47.3 exposes comboBox in the enum but rejects it in debug validation and leaves it unimplemented in Web; the current button/text-field fallback does not satisfy combobox AT acceptance.

搜索逻辑与输入法编辑缓冲分开：组合期间保留原始文字和UTF-16范围，onSearch仅收到新查询后缀；提交／结束后再去掉原选中标签前缀，不重复通知相同查询。候选按键归文本编辑器；父级改值不重定向已开始的组合会话，内部清除焦点也不会被结束会话的整理操作抢走。

Drawer composes Cursor around its owned mask and panel. `closeLabel` (String, default `'关闭'`) names the header close action. `semanticLabel` (String?, default null) names the dialog independently of its opaque title, which receives heading semantics. Supply the dialog name explicitly; the component never derives it by inspecting child widgets. The title default is28px/42px; leaf text may use an explicit strut to retain inherited metrics. Exit easing follows elapsed closing time; background depth remains DrawerHost-owned.

Disclosure headers, picker triggers and the pagination size action expose expanded state on their named actionable node. Each component owns the state; the shared action owns its semantics. Child clear actions remain independent. Tabs emits stable values, never positional indices.

The original reference secondary-text and other contrast failures are preserved in docs/ACCEPTANCE.md. Necessary palette corrections are now authorized; current global implementation and validation remain in progress. IslandTokens separates brand fills (leaf, sun, danger) from readable content (link, onLeaf, onSun, dangerText, onDanger), with explicit focus, outline, inputSurface and onCanvas roles. IslandColorway.ink is for soft/paper surfaces; onAccent is for its accent fill. Foundation owns the fixed pair tables; components own state recipes. Transparent defaults support the documented product surfaces; arbitrary imagery or custom backgrounds require the host to supply a known surface and explicit style. Opaque child styles are never inspected or rewritten. Light/dark use the same schema, not parallel accessibility themes.

DatePicker and TimePicker retain an open panel on blur without a new control target, matching the pinned reference relatedTarget condition. Transfer to an external focusable control closes it; outside clicks still dismiss independently. This does not commit a pending value.

Picker footer action names occur once. Time options announce value and unit once; Input/date/time clear actions announce their action name without the decorative ×. This changes semantic output only, not visible captions or child event ownership.

### Reference motion and glyph checkpoint

Title: Live reference: layer/tab hover scales to1.06 over200ms ease without changing layout; ribbon remains static. Padding is1.6em/1.55em/1.5em for ribbon/layer/tab; tab adds0.4em left text margin and uses the paired Title palette foreground. Only ribbon has0.11em top optical offset. Explicit child styles/state remain authoritative. Reduced motion jumps to the target.

Collapse: Reveal uses300ms cubic(.4,0,.2,1); icon/color/leaf and answer bottom padding0..24 use250ms independently. Reversals start at rendered values, and the grid cannot shrink below its current padding. Rebuilds with unchanged target do not restart motion. Reduced motion synchronizes both timelines.

Checkbox: The shared choice renderer owns the pinned15x14 check path, size-dependent SVG fit,an immediately complete committed stroke and600ms decorative splash. Label500/.01em/1.5 line height; disabled colors and.55 opacity; focus is a separate2px semantic focus outline with2px gap. Host-controlled proposals never start selected motion until committed.

Radio: Uses the same choice glyph/typography/motion owner as Checkbox; group identity, selection requests and keyboard traversal remain Radio-owned.

These scoped repairs do not establish all-state or cross-engine raster acceptance.


Switch uses intrinsic label width above its52x28/38x20 minima, device-pixel-rounded2.5px borders, reference thumb insets,250ms cubic(.4,0,.2,1), separate2px focus outline with2px gap, and a600ms11px ring at full busy opacity. Disabled/busy inputs never commit requests; reduced motion stops the ring.

Title Gallery now includes all25 observed title instances (three random-color variants,13 palettes,three sizes,English and explicit ribbon/layer/tab sections). Gallery background wrappers remain Gallery-owned; all titles use the public component. Wide/narrow widget checks cover section presence and first-title placement; they do not close cross-engine raster acceptance.

IslandTheme.borderWidth(context, width) resolves a finite logical border width using the nearest MediaQuery DPR: nonpositive widths return zero; positive borders floor to physical pixels with a minimum of one pixel. Use it for custom frames that share the library border grid, not typography or spacing. No new helper namespace or internal Gallery imports.

Rate uses one selected-or-first Tab stop. Right/Up increase and Left/Down decrease the committed value, clamped to1..count; Home/End select endpoints. Rejected controlled proposals never become the keyboard arithmetic source. Only increases animate new stars, with350ms pop/60ms stagger and600ms final-star splash.

ActionSurface owns both checked and mutually-exclusive flags on its one semantic action node. ChoiceControl and Rate supply the latter; their former flag-only outer wrappers are removed. Radio/Rate own radioGroup roles; Checkbox remains independent.

- Fixed pale Card surfaces establish a light surface Theme for descendants while preserving other ThemeExtensions and explicit child styles. Card/Tag switch foreground/fill pairs atomically; transform/shadow motion continues. Transparent Tag uses its surface text role. Image/Tag two-tone focus does not infer background pixels. Loading decorative reversals shorten by remaining distance; a separate exit timer owns removal and reactivation cancels it. Necessary content/backing stay opaque, with background pointer/focus/semantics blocked until removal.

Gallery token swatches project IslandTokens.light directly; Title captions reuse public colorway foregrounds over their patterned demo surfaces. / Gallery 色块直接投影 IslandTokens.light；Title 小字复用公开色板的可读前景色。

Tabs and Pagination atomically pair selection/hover fills with owned foregrounds and focus. Transparent pagination labels inherit theme roles; fixed light inputs/popups retain light surface recipes. Tabs shadow and pagination arrow rotation remain animated. / Tabs 与 Pagination 的选中填面、前景及焦点原子配对；透明说明跟随主题，固定浅色输入及弹层保留浅表面配方。


### Approved readable motion / 已批准的可读动效

One readable motion policy: necessary text, numbers, icons, actions and their backing/boundaries stay opaque and contrast-compliant on every entry, exit, reversal and interrupted frame. Atomic paired colors replace unsafe color interpolation. Modest displacement, scale and decorative motion remain; decoration must not invalidate the actual content background. Reduced motion settles the same state machine. One content subtree and lifecycle per owner; no animation clones, opaque-child inspection, parallel variants or transition contrast exemption. See docs/DESIGN.md. Loading retains its blocking opaque surface until removal; fadeDuration controls decorative exit and removal, while reduced motion completes immediately. Historical fade observations are superseded by this approved rule, not deleted evidence.

SurfaceMotion is internal presentation only (one subtree, displacement and modest pulse); component owners keep controllers, display lifetime and callbacks. ViewportOverlay places semantic blocking outside captured locale boundaries only when its owner declares background unavailable. Badge retains wrapped content through zero visibility; CountUp keeps builder identity and900ms celebration display in reduced mode.


### Readable-motion counter-audit followup

Input focus, range placeholder/hover, Avatar overflow, Table loading and CountUp celebration now use readable pairs on their actual owned surfaces. Upload supplies opaque status/action backings over arbitrary thumbnails and theme-aware transparent tips; hidden hover actions reject pointer hits. Date/time navigation and footer controls paint focus without layout changes. Image/Upload preview routes share presentation-only opaque displacement, while components keep route lifetime and content ownership. Badge/IconButton descriptions reuse IslandTooltip. The close SVG changes only its X stroke to #B03038; provenance records the transformation. Drawer reduced-motion settling runs after build. These authorized color/motion differences retain the original thresholds and do not establish exhaustive state or assistive-technology acceptance.

Already named actions can set IslandTooltip.excludeFromSemantics to omit its duplicate description; child semantics remain intact. Preview owners forward local reduced-motion changes to the same route, which captures inherited themes at presentation.


Image preview close uses the pinned16x2 rounded crossed bars and150ms reversible ease scale; its readable gray surface and separately backed focus outline stay opaque. Input visual hint/label no longer duplicate its stable accessible name. Gallery Input supplies the reference full-width brown-pattern Card,12px top gap,20px padding and18px radius through public Card composition; IslandCardTheme.style.borderColor is the border override owner. Gallery header descriptions also use IslandTooltip.

### Atomic theme regions and field feedback
For runtime light/dark changes, use `IslandThemeHost(data: targetTheme, child: content)` inside `Scaffold.body` or the existing Material content. Pass the application's already-resolved target ThemeData, not an upstream AnimatedTheme intermediate frame. The host owns one opaque paper surface and synchronously installs Theme, default ink and IconTheme. It stores no theme mode or controller and does not inspect children. Nested caller-owned Scaffold/Material/AnimatedTheme or explicit styles start a new painting boundary. Static reference Gallery surfaces retain their backgrounds.
Input owns one FormField and TextField; controller/selection/focus survive helper/error and theme changes. Fill, border and helper/error switch atomically outside InputDecorator's implicit fade/interpolation. Validation/reset/controller replacement and error live-region semantics remain with the field. Countdown settles its existing digit timeline when reduced motion starts; restoring motion cannot resume an obsolete transition.

### 原子主题区域与输入反馈
运行时切换明暗主题时，在 `Scaffold.body` 或已有 Material 内容内部使用 `IslandThemeHost(data: targetTheme, child: content)`，传入应用已经解析好的目标 ThemeData，不能传上游 AnimatedTheme 的中间帧。宿主只负责一块不透明纸色底板和同步更新的 Theme、默认文字与图标；不另存主题模式或动画控制器，不检查子内容。调用者嵌套的 Scaffold/Material/AnimatedTheme 或显式样式构成新的绘制边界。静态参考 Gallery 保留已有底色。
Input 保留一个 FormField 和 TextField；辅助/错误消息与主题切换不丢控制器、选区和焦点。填色、边框、辅助/错误行原子切换，不使用 InputDecorator 的默认淡入和插值；校验、重置、外部控制器替换及错误 live-region 语义仍由输入框负责。Countdown 开启减少动态效果时结算原数字时间线，恢复动效不会续播旧过渡。

Fixed light surfaces use one internal LightSurfaceScope for readable token/text/icon defaults while preserving unrelated extensions and explicit child styles. ContentScope defaults IconTheme color to its explicit text role unless the slot supplies a distinct icon role. Card, Drawer, Modal, Notification, Tooltip and Table share the fixed-surface mechanism; Avatar/Badge/Title/Countdown, CountUp, Select, Tabs and Loading pair icon defaults with their owned text roles. This scopes inheritance; it never inspects or rewrites child widgets. 固定浅色表面统一提供可读的语义主题；默认图标跟随对应文字角色，显式子样式不被覆盖。

Tag owns its close-state colors: hover atomically pairs colorway.ink with colorway.soft; resting transparent variants retain surface ink. The16px target, separate keyboard/parent dispatch and host-owned removal remain unchanged. Explicit opaque child styles/state are preserved.

CodeBlock uses one `IslandCodeBlockStyle` for instance and `IslandCodeBlockTheme.style` overrides: backing, base foreground, border, lexer syntax roles and copy-action state colors share one rendering path. Typography belongs to `style.textStyle`; base ink belongs to `style.foregroundColor`, and highlighted tokens to `style.syntaxColors`. Explicit TextStyle.foreground Paint retains Flutter precedence and caller ownership; it is not inferred as a semantic Color pair. Changing to plain language is not a theming repair. Configure the actual color pair; the library does not guess or silently correct arbitrary caller colors. Styling/state support is owned by [the CodeBlock contract](../components/codeblock/contract.json). Carousel reuses the existing light-surface scope for its fixed pale slide backplane, preserving unrelated theme extensions and explicit opaque slide styles/state. ActiveStack still owns active-only painting/hit/semantics; Carousel owns selection, timers and focus.

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

Vertical popup height follows the available attachment-side space so the original trigger remains usable; fitting geometry receives no extra offset. Select owns and disposes its list scroll controller, reveals the committed row on list attachment and moves only that list for keyboard activity, preserving caller scroll positions.

垂直弹层按所附方向的可用空间约束高度，使原触发控件保持可用；能放下的定位不增加额外偏移。Select 自己创建并释放列表滚动控制器，在列表接入时显示已提交选项，键盘活动项仅滚动自己的列表，不改动调用者的滚动位置。

Modal Tab traversal consumes forward and reverse keys even when a closed loop keeps the same target or contains no actions. One shared boundary in the existing action module delegates order to the existing FocusScope, owns one skipped non-semantic target for an otherwise empty scope, and removes its borrowed-scope listener and owned node on disposal. It does not inspect children, add another FocusScope or replace a caller-owned focus target. IslandDialogRoute now defaults explicitly to TraversalEdgeBehavior.closedLoop; an explicitly supplied non-closed-loop policy, including null inheritance from Navigator, remains authoritative. Drawer, Loading, showIslandModal and the shared preview/alert route consume this same behavior. Actual Web keyboard and Windows/AT validation remain separate from widget tests.

模态闭环即使保持同一目标或没有操作控件，也消费正向和反向 Tab。现有动作模块中的同一边界把顺序交给原有 FocusScope，仅为原本为空的 Scope 创建一个跳过遍历且不产生语义节点的内部焦点目标，并在卸载时移除借用 Scope 的监听、释放自有节点。不检查子内容、不增加第二个 FocusScope、不替换调用者的焦点目标。IslandDialogRoute 现明确默认 TraversalEdgeBehavior.closedLoop；调用者显式传入的非闭环策略（包括 null 以继承 Navigator）仍然有效。Drawer、Loading、showIslandModal 和共享预览/提示路由复用同一行为。真实 Web 键盘与 Windows/辅助技术验收独立于 Widget 测试。

[Gallery parent layout authority](DESIGN.md#gallery-parent-layout)

[Gallery parent layout authority](DESIGN.md#gallery-parent-layout)

Select completes keyboard focus after popup presentation using the latest focus history. Pointer opening, selection, Escape and clear keep keyboard input usable; Tab retains its destination, including the separate clear action. A single cancellable completion after portal attachment/removal restores focus only when it has fallen to the framework root scope and the app is active. Explicit controls and caller-owned scopes remain authoritative. Disable, borrowed-focus replacement and unmount cancel stale completion. No DOM patch, polling, global keyboard interception or additional FocusScope is used.

Select 在弹层呈现结束后按最新焦点历史完成键盘焦点交接。鼠标打开、选择、Escape 和清除后可继续键盘操作；Tab 保留其目标，包括独立清除按钮。弹层接入或移除后的单次可取消回调，仅在应用处于活动状态且焦点落到框架根作用域时恢复焦点。明确的控件及调用者自有作用域优先；禁用、替换借用焦点及卸载会取消过期回调。不修补 DOM、不轮询、不全局拦截键盘、不增加 FocusScope。

Radio and Checkbox groups expose optional spacing: a finite nonnegative gap, default16 horizontally and12 vertically. The same gap governs wrapped rows; selection and focus ownership remain unchanged. Gallery supplies20 for the first controlled example, uses the existing demo surface and the recorded initial values. Single-line Input hints remain single-line with adornments; maxLines explicitly governs multiline hints.

Radio 和 Checkbox 组提供可选 spacing：有限非负间距，水平默认16、垂直默认12；换行后的行间距沿用同一个值，选择与焦点所有权保持。Gallery 首个受控示例传20，复用已有示例底板并恢复参考初始值。Input 单行占位文字在有前后缀时仍保持单行；多行占位由显式 maxLines 控制。


Table column.width is fixed and supports constraint-dependent content; preferredWidth is mutually exclusive and shrinks to finite intrinsic content minima. Headers default to no wrapping. The single registered-cell layout owns both kinds and reacts to child-only resizing. Gallery sizing and spatial diagrams follow [Gallery parent layout authority](DESIGN.md#gallery-parent-layout). Typewriter examples use explicit16px leaves and8px inter-line gaps.

Table 的 column.width 为固定宽度，可承载依赖约束的内容；preferredWidth 与其互斥，可收缩至有限的内容最小宽度。表头默认不换行，列几何仍由同一注册单元格布局负责，并响应子项独立尺寸变化。Gallery 尺寸及方位图遵循上述父布局权威；打字机示例显式使用16px文字和8px行间距。


Pagination layout authority: `components/pagination/contract.json` (same component owner; fitting sizing and below-minimum wrapping).

Pagination 布局权威：`components/pagination/contract.json`。


Stamp Image matches actual final-mask compositing: opaque paper and centered5px-radius holes at16px pitch, including partial corner holes, with no external filtered shadow. Gallery captions keep the full declared frame width and explicit observed line boxes. This corrects reference parity rather than changing the color policy.

邮票 Image 按实际最终遮罩合成：不透明纸面、居中的5px半径/16px孔距，以及跨越角落的部分齿孔；遮罩外不保留滤镜阴影。Gallery 说明跟随完整相框声明宽度，并使用已观察的明确行高。这是参考还原修正，不是配色例外。


The catalog layout followup keeps each owner explicit. Pagination fitting/wrapping/alignment follows `components/pagination/contract.json`; Table requests centerEnd. Tabs proportionally shrinks each capsule's content contribution, preserves padding and intrinsic minima, and stretches the capsules to the tallest wrapped label. Opaque labels keep their keys, styles and lifecycle; a caller controls their line-break opportunities. The Gallery's known Chinese tab labels explicitly include zero-width break opportunities to reproduce CSS CJK wrapping without inspecting arbitrary children. Divider repeats complete size+gap cycles with no final connector; tiled waves retain the centered reference phase.

IslandTheme.codeFontFamily is the package-qualified bundled Fira Code family. CodeBlock and Gallery icon identifiers use it with zero default letter spacing; explicit CodeBlock.style.textStyle controls typography; the style foreground and syntax roles own ink. Fira Code is a project resource, not an installed system font. Arimo is a Gallery-only fallback for the reference's Arial native-control examples. docs/font-resources.json binds upstream commits, unchanged font bytes and OFL notices. Fonts/engine raster differences remain separately reviewable; neither font packaging nor widget tests establish whole-library visual acceptance.


目录布局修正保持所有者清晰：Pagination 容纳、换行及对齐遵循 `components/pagination/contract.json`，Table 选择 centerEnd。Tabs 按各胶囊的内容宽度比例收缩，保留内边距和固有最小值，并将各标签拉伸至最高换行标题的高度。不透明标题保留键、样式和生命周期，换行机会由调用者决定。Gallery 自己拥有的中文标题显式声明零宽换行机会，以映射 CSS 中文换行；公共组件不检查任意子内容。Divider 只重复完整的 size+gap 周期，不留下末端连接线；波纹保留参考的居中平铺相位。

IslandTheme.codeFontFamily 是包内 Fira Code 的完整字体族名。CodeBlock 与 Gallery 图标标识使用它，默认字距为零；显式 CodeBlock.style.textStyle 控制字形，style前景与语法角色拥有文字颜色。Fira Code 只是项目资源，不安装系统字体。Arimo 仅作为 Gallery 原生控件示例的 Arial 后备字体。docs/font-resources.json 绑定上游提交、未修改的字体字节及 OFL 声明。字体及引擎栅格差异仍单独核验；打包字体和组件测试不代表整库视觉验收通过。

Necessary glyph strokes on transparent regions now inherit the existing currentColor role through a reviewed per-element map in docs/icon-paint-roles.json; filled internal artwork remains asset-owned. Off slashes use #B03038 on their own cream backing. These are registered contrast differences, with unchanged path geometry and no runtime background guessing.

透明区域上的必要图标线条按 docs/icon-paint-roles.json 逐元素映射继承已有 currentColor 角色，内部多色插画仍由资产拥有。关闭斜线在自身奶油色底面上使用 #B03038。以上为已登记的必要对比度差异，路径几何保持，不在运行时猜测背景。


### Catalog measured layout followup

CodeBlock.padding is an optional content inset; null retains the copyable-dependent default. Explicit insets must reserve space for a visible copy action. The Home consumer requests28px horizontal/20px vertical,13px/1.8 text, zero margin and max600px width. Progress info inherits16px/1, weight700 and0.32px letter spacing; explicit opaque info styles remain authoritative. No public slot is inspected or rewritten.

Gallery-only layout fixes map measured CSS margin collapse, row stretching, owned text line boxes and initial example configurations. The native static capture waits for BackTop's known initial timer before positioning and asserts every actual captured scroll offset. Capture success and widget tests do not establish complete visual acceptance.


### 目录实测布局后续修正

CodeBlock.padding 可显式指定内容内边距；null 保留依复制按钮状态决定的默认值。显式内边距需为可见复制按钮留出空间。首页消费者使用水平28px/垂直20px、13px/1.8文字、零外边距及最大600px宽度。Progress信息默认16px/1、字重700、字距0.32px；不透明内容的显式样式仍优先，不检查或改写公共插槽。

Gallery布局修正对应实测CSS外边距折叠、同一行卡片拉伸、自有文本行框及示例初始配置。原生静态截图先等BackTop已知的初始计时结束，再定位并断言每张截图的实际滚动位置。截图成功与组件测试不代表完整视觉验收。


Filled icon artwork separates host-facing contextual contours from interior fixed drawing ink. docs/icon-paint-roles.json records the reviewed element indices; geometry is unchanged. Interior marks on their own opaque backings do not inherit a pale host color. Named raster assertions verify actual backing colors and the3.0 threshold across30 host/Card contexts. Facial and heat details have individually required roles; material seams/highlights retain provenance without a blanket necessary-mark exemption. The named probes do not certify every glyph adjacency or complete visual acceptance.


有填充图标分别维护面向宿主的上下文轮廓与内部固定画笔。docs/icon-paint-roles.json 记录逐图元审查清单，不改几何。位于自身不透明底色上的内部标记不继承宿主浅色描边。具名像素断言在30种宿主/Card上下文中同时核对真实底色与3.0门槛。面部和热气细节按逐项必要角色验收；材质接缝与高光保留素材来源，不构成必要标记的整类豁免。具名采样不代表每个图标邻接色或完整视觉验收通过。


Necessary filled-glyph roles (current2026-10-17): eyes, beaks, eye stalks, steam, connectors, off slashes and the coffee-cup heart are required marks. Brown-faced ink is strengthened to black; navy-faced eye rims use white and beaks keep their own yellow/coral. Exposed steam/connectors inherit currentColor. Off slashes use currentColor on the host and existing danger #E05A5A clipped to the original owned body. Snail eye stalks retain dark ink only over the owned green head. The original geometry and widths are unchanged; static local SVG clip/use references share paths, with no runtime background inference. The147 host-contour/closed-silhouette matrix is separate from individually named interior role probes and is not blanket certification of every artwork adjacency or browser state.

有填色图标的必要角色（当前2026-10-17）：眼睛、喙、眼柄、蒸汽、连接线、关闭斜线和咖啡杯爱心均为必要标记。棕色脸部画笔加强为黑色；深蓝脸部眼圈使用白色，喙保持自身黄色/珊瑚色。外露蒸汽、连接线继承currentColor。关闭斜线在宿主上继承currentColor，在原有自有图形内部裁切使用既有危险色#E05A5A。蜗牛眼柄仅在自有绿色头部保留深色画笔。原几何和描边宽度不变，静态SVG局部clip/use共享路径，不在运行时猜测背景。147项宿主轮廓/封闭剪影矩阵与逐项内部语义采样分开，不代表每个插画邻接色或浏览器状态均已通过。

The same required connector rule covers the original apple stem and balloon string: currentColor on the exposed host, with unchanged geometry. The public-render matrix additionally checks71 individually named semantic probes at48px; prior named own-backing and transparent-role assertions remain binding.

同一必要连接线规则也覆盖原有苹果茎和气球绳：外露宿主区域继承currentColor，不改几何。公共渲染矩阵另在48px逐项检查71个具名语义采样；此前具名自有底色和透明区域断言仍然有效。


Canonical scene SVGs expand their finite circle tiles during the existing offline asset import. Original dot geometry, opacity, colors and clipping remain; no runtime shader fallback, renderer fork or parser-limit relaxation is introduced. Validate the existing four packaged-scene decode oracles in actual Windows and Web engines, not only the VM.

规范场景 SVG 在现有离线素材导入流程中展开有限的圆点平铺，保留原圆点几何、透明度、配色与裁剪；不引入运行时回退、渲染器分支或解析上限放宽。现有四个打包场景解码用例必须在真实 Windows 与 Web 引擎复测，不能只依赖 VM。

Optional Card/Tag activation preserves independently named child focus through resumed-view reconciliation after semantic layout. Tabs preserve the focused value through header reorder; explicit external focus wins. Search Select keeps the named editable node separate from changing popup metadata.

Card／Tag 切换可选父操作时，在语义布局后整理当前活动视图，保留独立子控件焦点。Tabs 重排后按值保留焦点，显式外部焦点优先。可搜索 Select 将具名编辑节点与变化的弹层元信息分开。

Gallery leaves semantics activation to Flutter/platform demand instead of unconditionally forcing Web accessibility text editing. Semantic metadata remains in the widgets; semantic contract tests enable it explicitly. Normal Web editing retains native composition and first-input behavior. Reader execution remains excluded.

Gallery 由 Flutter／平台按需启用语义，不再无条件强制 Web 无障碍文本编辑路径。控件语义元数据保留，语义契约测试显式启用；普通 Web 输入保留原生组合与首次输入行为，读屏执行仍排除。

When search becomes disabled, its native editing client is retired before the committed host label replaces a composition buffer. Deferred restoration uses the latest label and is cancelled by re-enabling, a newer host update or disposal; it emits no selection proposal and takes no focus.

搜索框被禁用时，先退出原生编辑连接，再以宿主已提交标签替换组合缓冲；延后整理使用最新标签，重新启用、新宿主更新或卸载会取消旧回调，不提出选值请求或抢焦点。

Select filtering opts out of native autofill forms: its query is transient option search, not a saved form field. Clear-slot geometry changes must not trigger autofill focus changes during disable.

Select 的临时选项搜索不参与原生自动填充表单，避免清除按钮改变编辑框几何时触发表单切焦点并干扰禁用。

A pending presentation-focus recovery survives benign host/theme rebuilds while its child/header owner is unchanged. New recovery ownership supersedes the previous request; replacement, removal, disposal, inactive view and explicit external destinations retain priority. Rebuilding alone does not cancel an otherwise valid request.

两帧呈现焦点整理期间，若子控件／页签所有者未变，普通宿主或主题重建不会取消有效恢复。新所有者取代旧请求；替换、移除、卸载、非活动视图和显式外部焦点仍优先。

Locale acceptance covers the declared English/Chinese internal action defaults and inherited direction/text scale. Application copy and the Chinese reference Gallery remain caller-owned; no automatic translation of opaque content is promised. The named localization layout oracle checks both delegates, literal action labels, RTL at2x in a375px host, long content and paging proposals; target execution evidence is recorded separately.

本地化验收覆盖已声明的英文／中文内部操作默认文案及继承的方向、字号缩放。应用文案与中文参考Gallery仍归调用者，不承诺自动翻译不透明内容。具名布局回归检查两种delegate、固定操作文案、375px宿主内RTL与2倍字号、长内容和分页请求；目标平台执行证据另行记录。

Independent Card/Tag/Table child focus attaches to the existing caller Focus node, including a FocusScope; if no inherited focus exists it uses the existing manager root. A scope boundary must not silently place the child beneath the optional parent detector or paint parent focus over child focus. One shared ActionSurface owns this fork; no new scope or copied child subtree is introduced.

Card／Tag／Table 的独立子焦点挂接到现有调用者 Focus 节点（包含 FocusScope）；没有继承节点时使用现有管理器根节点。作用域边界不能悄悄把子焦点挂回父操作检测器，或用父焦点描边覆盖子焦点。该隔离仅由共享 ActionSurface 负责，不新建作用域或复制子树。

Closed retained Drawer excludes its whole viewport entry, including inherited locale wrapper semantics. First host clicks remain reachable with semantic presentation active; the existing closed subtree remains mounted. / 关闭抽屉排除整条视口浮层及语言包装语义，首击可到达宿主；内部状态仍保留。


## Home host and photo gradient / 首页宿主与照片渐变 (2026-10-18)

Current Gallery Home/Carousel presentation and named contrast exceptions follow [the DESIGN authority](DESIGN.md#home-host-and-photo-gradient). This reference is not a new platform acceptance or a global contrast waiver.

首页／轮播的现行呈现规则与具名对比度例外统一引用[DESIGN权威](DESIGN.md#home-host-and-photo-gradient)；此引用不构成新增平台验收或全局对比度豁免。


Surface sampling / 表面采样 authority: [DESIGN](DESIGN.md#surface-sampling). Platform results remain source-bound in the sole audit record; this contract update is not acceptance.


Button busy is a fixed component-owned surface recipe, independent of global brand leaf in both host themes. Customize its color pair through existing IslandButtonTheme.style / IslandButton.style backgroundColor, foregroundColor and side; explicit child styles stay authoritative. Button busy为组件自有固定表面配方，两种宿主主题均与全局品牌leaf分开；通过既有主题／实例ButtonStyle共同定制配对，显式子样式保持优先。 See [current color contract](DESIGN.md#original-color-restoration).

Busy content uses the existing fixed-surface semantic scope for default nested controls while retaining unrelated extensions and explicit child styles. Busy 内容通过既有固定表面作用域提供嵌套默认角色；其他主题扩展、子树身份与显式样式保持。


<a id="color-customization"></a>
## Color customization ownership / 颜色自定义职责

Card and CodeBlock now expose component-sized style data used by both instance and theme overrides, with one recipe/render path. Source declarations own signatures; [Card](../components/card/contract.json), [CodeBlock](../components/codeblock/contract.json) and [Button](../components/button/contract.json) contracts own exact style support and precedence. For supported state properties, an instance's non-null value for that state wins, then a non-null theme value, then the default. Transparent is an explicit value. TextStyle merges typography; resolved foreground replaces textStyle.color for base Color ink. Explicit textStyle.foreground Paint retains Flutter precedence and caller ownership rather than becoming a semantic Color role. Explicit opaque child styles and assets stay authoritative.

Card 与 CodeBlock 的实例／主题现在共用各自小型样式数据和唯一配方／绘制路径。声明拥有签名；[Card](../components/card/contract.json)、[CodeBlock](../components/codeblock/contract.json)、[Button](../components/button/contract.json) 契约拥有准确样式支持与优先级。已支持的状态属性逐状态取实例非空值、主题非空值、默认值；透明不是空。TextStyle 合并字形，已解析前景替换 textStyle.color 作为基础Color文字；显式 textStyle.foreground Paint 保留Flutter优先级和调用方所有权，不自动成为语义Color角色；opaque child 显式样式和素材仍优先。

`IslandSurfaceTheme` is explicit data, not a new scope: brightness plus the existing IslandTokens recipe. Card carries it through the existing LightSurfaceScope for nested controls while passive slot ink is separate. Without it, existing known-light protection stays intact. It does not infer color brightness, clone custom brand defaults, or restyle descendants. Arbitrary custom pairs still require validation against actual alpha/backing and state.

`IslandSurfaceTheme` 只是明确亮度与既有 IslandTokens 的数据，不是新增作用域。Card 经既有 LightSurfaceScope 传递嵌套控件配方，被动插槽前景分开；未指定时保留已知浅表面保护。不推断亮度、不自动复制全部品牌值、不改写后代；自定义配对仍需结合真实 alpha／底色和状态验证。

Atomic pre-release migration: old Card color/textStyle and CardTheme color/borderColor/textStyle move to the corresponding style roles; typography stays in style.textStyle while ink moves to style.foregroundColor. CodeBlock backgroundColor/textStyle likewise move to style; highlighted syntax remains configured through syntaxColors rather than changing language. All maintained consumers are migrated; no legacy aliases or parallel formats remain. Layout padding/radius retain their existing owners.

发布前一次迁移：Card 原 color/textStyle 及 CardTheme 原 color/borderColor/textStyle 改为相应 style 角色，字形在 style.textStyle，颜色在 style.foregroundColor。CodeBlock 原 backgroundColor/textStyle 同样迁入 style，高亮通过 syntaxColors 定制而不是换语言规避。维护消费者已同批迁移，不保留旧别名或双格式；padding／radius 的布局职责保持。


### Fixed palette references / 固定配色引用

Fixed-pair decisions do not add constructor parameters. Public signatures remain in exported declarations; component contracts own supported customization. See the [fixed-pair decision authority](DESIGN.md#shared-accent-foreground) and [independent Title role policy](DESIGN.md#title-foreground).

固定配对决定不增加构造参数。公开声明拥有签名，组件契约拥有定制能力；配对处置只引用[固定配对设计决定](DESIGN.md#shared-accent-foreground)及[独立Title角色规则](DESIGN.md#title-foreground)。
