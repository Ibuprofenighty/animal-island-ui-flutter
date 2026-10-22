# Gallery 复刻基准 / Gallery replication baseline

## Version scope decision / 本版本范围决定 (2026-10-18)

User decisions, 2026-10-18: SDK-COMBOBOX-001 is an approved exception for this version. The installed SDK still cannot project the Select combobox role; the one button/TextField projection remains, without SDK modifications or DOM shims. This is not an implemented role or a passed role test. Keyboard, focus, names/states, IME and contrast requirements remain. The user confirmed private authorization for all21 previously investigated assets (4 library scene SVGs,1 Gallery logo,16 Gallery photos): "这些也是私人授权". See docs/asset-private-authorization.json for the original confirmation and time. Private-use authorization is no longer unknown or a remaining private-use acceptance item. Preserve provenance and the earlier private-only authorization history. The user subsequently confirmed public repository redistribution on2026-10-22; current scope and original confirmation are recorded in docs/RIGHTS.md. This is not independent legal verification or an unconditional commercial license. Investigation is stopped: do not investigate, contact others, request documents, replace or remove assets. Existing GROBOLD private authorization remains. The user approved60fps as the baseline direction for performance diagnosis and an acceptance proposal; detailed sampling, percentile, startup and size thresholds remain proposed until agreed. No installation, screen readers or supervision restart; do not touch the separately owned keep-awake helper.

用户于2026-10-18批准SDK-COMBOBOX-001为本版本例外：已安装SDK仍不能投射Select的combobox角色，保留唯一button/TextField投射，不修改SDK、不加DOM补丁。例外不等于角色已实现或角色测试通过；键盘、焦点、名称/状态、输入法及对比度要求保持。用户已确认此前21项素材（4张库内场景SVG、1个Gallery Logo、16张Gallery照片）“这些也是私人授权”，原文及实际确认时间保存在docs/asset-private-authorization.json；私人使用授权不再未知，也不再是本次私人使用验收未决项。保留来源及此前仅限私人使用授权的历史。用户于2026-10-22另行确认可随公开仓库分发；当前范围与原文统一记录在docs/RIGHTS.md。这不是独立法律核验或无条件商业许可。授权追溯停止，不再调查、联系他人、索要文件、自行替换或移除素材；GROBOLD既有私人授权不变。用户批准以60fps为基础继续性能诊断并拟定验收方案，采样、分位数、启动及体积的具体门槛仍为待确认提案。不安装软件、不做读屏、不恢复监督，不操作另有所有者的防睡眠程序。

## Current work scope / 当前工作范围 (2026-10-17)

User scope decision, 2026-10-17: all screen-reader execution and validation are excluded from this work, including NVDA and other readers. Do not install or start reader software, request reader validation, or keep it as a remaining acceptance blocker. Excluded is not passed or certified. Preserve existing semantic metadata, keyboard navigation, focus behavior, contrast requirements and their tests. No new software may be installed for acceptance. Historical reader-related pending notes below do not define the current work scope.

用户于2026-10-17明确将所有读屏软件运行与验收从本工作范围中排除，包括NVDA及其他读屏器。不得安装或启动读屏软件、再次要求读屏验收，或将其保留为待完成的验收阻塞项。排除不等于通过或认证。保留现有语义信息、键盘导航、焦点行为、对比度要求及相应测试。验收不得安装新软件。下文历史记录中的读屏待验收说明不再定义当前工作范围。

唯一视觉与交互基准：[Animal Island UI Gallery](https://guokaigdg.github.io/animal-island-ui/#/)。
用户于 2026-10-13 明确要求“一模一样”，不是泛化的动森风格。

## 当前授权：必要的无障碍配色差异（2026-10-15）

用户已明确同意全局修正对比度，保留动森风格，只维护一套产品配色，不降低阈值。本段原授权覆盖必要配色差异；后续动效授权见下节。参考布局、字形、形状、内容与交互要求保持。先在现有审计记录登记旧色、新色、实际背景、比值和消费者，再同步代码、契约、文档与 Skill，最后完成 Windows + Web 状态验证。文本 4.5、必要图形 3.0 的原门槛不变。历史失败保留；禁止并行色板、运行时猜测背景、检查或重写不透明子内容。下面有日期的旧观察和未改色说明均是历史，不覆盖本授权。

## 当前授权：全库唯一可读动效规则（2026-10-15）

用户批准以必要内容及其底色、边界组成稳定可读的整体，替代参考整块淡入/淡出。文字、数字、必要图标和操作控件出现后不透明；禁止仅让文字不透明而底板继续渐入。保留适度位移、弹性、合理缩放及节奏，小字号不因入场缩到不可读。阴影、光晕、纹理可渐变，但不得破坏实际背景对比度。危险中间色改为前景/背景同步切换，保留指示器、位置或边框运动。

Modal/Notification内容与底板不透明；遮罩独立渐变，不作为内容达标前提。Badge以完整字号轻微弹跳。共享SurfaceMotion仅负责呈现参数，不管理计时、显示条件、关闭或焦点；这些仍归组件所有者。各组件只有一份内容子树和一条生命周期，不检查或改写不透明子内容。退出、反向、快速重开、取消和卸载同样验收，视觉、点击、焦点与辅助技术状态一致。减少动态效果沿用同一状态机，直接进入稳定状态。Loading在必要层仍可见的退出期间继续拦截背景操作；fadeDuration仅控制装饰退出和整体移除时长，减少动态时立即完成退出。

这是已批准的参考动效差异；全库只维护这一种产品行为，不新增原版/无障碍版，不增加动画期间豁免。文本4.5及必要图形3.0门槛不变，仍须Windows/Web实际背景和过渡帧证据。实现/验证状态由现有审计记录MOTION-001维护，授权不是验收通过。

## 当前授权：锚定浮层越界的限定可用性修正（2026-10-15）

用户已明确批准修复参考站与本地375px Select 都存在的左侧越界裁字问题。保留正常宽度下的参考定位、配色、造型、内容与间距；仅在弹层越出可用视口时调整位置，确实放不下原宽度时才约束宽度并让内容正常换行或滚动。由现有共享浮层机制承担边界，排查全部相关消费者，不做 Select 专用补丁、不复制算法、不增加 helper 模块、shim 或双轨兼容路径。父级仍负责布局，组件负责表面、行为和状态资源，不检查或重写 opaque child。该状态必须标明为已授权参考差异，不宣称与参考完全一致。此例外不扩展为重新设计授权；既有4.5/3.0门槛与完整 Windows/Web 状态验收仍然有效。

The user explicitly authorized the minimum anchored-popup overflow repair. Preserve fitting reference placement and all normal artwork/content; correct only overflow, constrain width only when it cannot fit, and keep necessary content reachable by wrapping or scrolling. The existing shared owner covers every affected consumer with one implementation. This is a documented usability deviation, not exact parity or wider redesign permission.

## 已撤销的设计决定

此前自行设计的岛屿插画首页、森林绿主题、访问预约流程和 20 组件目标不再是交付目标。
已有代码仅是未验收的工程草稿。测试通过不能使其满足参考复刻要求。
不得把原来的视觉方案继续扩展，也不得把近似风格宣称为完成。

## 保留与适配

保留参考站的首页、侧栏分类和排序、组件示例排列、配色、字体、
图标外观、丝带/双层纸/折角标题、胶囊与堆叠阴影按钮、异形弹窗、
背景图案、状态反馈、动效和响应式表现。

目标依然是全新 Flutter 实现，Windows + Web 优先，移动端后续补验。
不得复制旧目录 animal_island_ui 的实现。
React 的代码示例、安装命令和类型表需要对应可编译的 Dart/Flutter 内容；
这种技术内容适配不授权重新设计 Gallery。
不得新增自选首页、品牌、主题切换或无参考依据的示例流程。

## 范围

参考站页面当前显示 v2.2.1。按侧栏实际入口计数为 **40 个组件**，
另有首页与 Skill 指南；不采用站点正文中不一致的 30+/37/38 等统计。
完整有序目录和实测值见 [reference-gallery.json](reference-gallery.json)。

## 验收

1. 按路由建立页面、示例、变体和交互状态清单；未观察状态标为待观察，禁止猜测。
2. 对齐视口、缩放、字体、内容、滚动位置、主题及状态后截图。
   首个桌面对照为 1440 × 1000；375 × 812 的窄屏行为需独立观察。
3. 比较布局、尺寸、换行、颜色、边框、形状、图标、阴影。
   字体栅格差异单独记录，不用任意相似率掩盖结构或造型错误。
4. 检查 hover/focus/pressed/disabled/loading/open/selected/error 和动效过程；
   不将初始静态截图当作全部交互证据。
5. 同一公共组件负责库行为和 Gallery 展示，禁止用 Gallery 专用假外观掩盖库缺失。
6. 视觉对照、行为测试与商业发布分别验收；读屏验收已按用户决定排除，不保留为待办或阻塞项。其余必需项未完成不得汇总为可商用完成。

## 当前证据边界

固定公开源版本、完整目录和资产来源已记录；Gallery 注册页数由 tool/reference_coverage.py 计算，不能由侧栏入口推断。
近期实测包括 Collapse 的展开尺寸、Card 的实际边框与正文间距、Loading 的全屏状态、BackTop 的滚动阈值与位置，以及 Tabs 的选择状态和父子语义关系。
旧的 Windows 截图仅包含页面局部边界，不能证明浮层外观；当前集成测试已改为捕获整个应用与浮层。
尚未完成所有 40 页、全部交互状态和 Windows/Web 逐项对照。
**视觉验收状态仍为 NOT_ACCEPTED。**

### 2026-10-13 Pagination / Table observation

Reference routes /pagination and /table observed at 1440×1000, DPR 1. The size list opens above with an 8px gap; 10→20 changes page count while retaining page 3. Table reference header widths are 120, 80, 252.34375, 342.828125, 270.796875px; header height 53px. Native draft uses equal remaining column widths and differs in fruit/hobby positions. This is a tracked visual gap, not acceptance. Native 30-page flow passes, including size changes and Table loading. Current captures remain under scratch/windows-captures. Font subset now includes the entire pinned reference text; the Tabs circle glyphs no longer fall back to a mismatched font. Final all-state parity remains NOT_ACCEPTED.

### 2026-10-13 Form / shared-pattern corrections

Reference at 1440×1000, DPR 1: username input top 374.390625, nickname input top 676.78125, title input top 845.171875. Labels use 1.6 line height; the 12px layout captions have a measured normal line box of 16px. These three input positions now have executable Gallery assertions with 0.1px geometry tolerance; this tolerance does not define whole-page visual acceptance. Card pattern colors are random in the reference and must be compared within the same variant.

Implemented boundaries: Form labels invoke an explicit callback; text adapters own or borrow focus nodes. Upload coalesces per-frame progress while preserving terminal results and parent-controlled list acknowledgement. Image and Upload remove only their owned preview route after tree mutation. Shared anchors use actual Overlay bounds; explicit input sizes no longer inherit desktop compact-density shrinkage. None of these patterns inspect or rewrite arbitrary child widgets.

### 2026-10-13 Table intrinsic layout checkpoint

The equal-width gap described above is now corrected in the draft through Table-owned intrinsic column layout. Live Web reference/header x positions at 1440×1000 DPR 1: [303, 423, 503, 755.34375, 1098.171875]; local semantics positions: [303, 423, 503, 755.352234, 1098.181885]. Gallery assertions cover the auto-column distribution with 0.1px tolerance; dynamic opaque-cell changes and column reorder/remove/resize/RTL have behavior tests.

This is not Table visual acceptance: live Web line-box rounding still gives header y=354 / height=52 versus reference y=355 / height=53; body row height is 50 versus 50.390625. These accumulating vertical differences remain visible. Web stripe-off, loading/disabled/recovery and next-page data changes were exercised. The 768px reference override did not apply to that tab and is not narrow reference evidence. Measurements: scratch/table-web-observation.json.

### 2026-10-13 Table line-box correction

The previously recorded accumulating vertical gap is corrected in the latest Web build. At the same 1280×720 DPR 1 viewport, live reference and local semantic row rectangles both report header y=355, height=53; body height=50.390625; final row bottom=659.953125. This is an exact match of those observed rectangles, not all-state visual acceptance. Hobby inline decoration paints 24px high while retaining its own text line footprint. Table owns scaled minimum line boxes and still expands for taller opaque children.

Gallery widget assertions also cover 1440×1000 with 0.1px tolerance. After an initial UAC-cancelled attempt, the administrator retry passed the matching Windows engine assertions, Windows Release build and complete native Gallery flow. Current-source native captures and results are bound in evidence/raw/20261013T230411Z-linebox-windows/checkpoint.json. Remaining Table work includes hover/motion and keyboard-focus/opaque-state review; other component and release gaps remain open.

### 2026-10-13 interaction observations

Reference Table hover is rgb(214,240,234), radius 30px, transition 0s. Its current native raster assertion verifies that color after one frame. Reference custom notification close action is 22x22px; CLOSE content is 35.390625x11px and centered with horizontal overflow. Public component tests cover stable child identity, no focus padding and independent keyboard dismissal. Native flow passes; transient Web visual parity remains pending.

Button source baseline: normal/dashed hover y=-1 then pressed y=0; primary pressed y=2; text/link have no translation. Motion is 250ms cubic(.4,0,.2,1). Text hover/press fills are #f0e8d8/#e9ddc6. Link hover/press foreground is #3dd4c6/#50b9ab. Danger primary hover/press uses #e87878/#c94444; danger text/link are white in the reference. Loading uses the pinned 28px donut, counterclockwise over 2.5s. These source observations drive tests; they do not imply all-state live visual acceptance.


### 2026-10-14 Tag default and narrow Gallery correction

Actual Gallery behavior takes precedence over its inconsistent API table. The table lists Tag default solid, but live DOM and pinned Tag.tsx use soft. The unreleased solid-default attempt was reverted; size/clickable examples again inherit soft while explicit solid examples stay filled. At 375×812 DPR 1, the reference small blue tag is rgb(230,240,255) with rgb(21,101,192) text, x=41, y=467, h=24. The live reference story panel starts y=216; the variant caption starts y=285. Source and DOM observations are retained in the next checkpoint's tag-375-reference.json.

The Gallery owns its 52px narrow header, 16px content inset and 21px description line metric. Typewriter exposes caller-owned optional strutStyle for plain/rich text; it does not guess parent layout or rewrite child spans. Existing defaults are unchanged. Both the narrow widget oracle and native flow assert the small-tag placement. Button/Tag focus paint is shared without sharing component colors/timing; Card/Tag/Table preserve opaque child state when the optional parent action changes.

These are selected state and geometry corrections. Exhaustive 40-page parity, all narrow layouts, assistive technology, real file-picker/drop paths and commercial release acceptance remain pending.

### 2026-10-13 Modal observation before implementation

Historical reference observation; the opacity/reveal requirements in this paragraph are superseded by the approved readable-motion rule above. Live reference /modal at 1280×720 DPR1: seven triggers; basic and explicit game both use the organic clip. No rendered close control despite stale description/CSS. Title is 28/700 with 42px normal line box; body 20/600/32px, #8a7b66; body bottom padding20. Museum dialog is520×266 at380,227; custom/weather/light dialogs520×234 at380,243. Game final fishing dialog520×217. Default footer uses actual primary Buttons (45px), not unused footer-btn CSS. Default/light/dark mask alpha .35/.08/.75. Custom actions 再想想 and danger 确认搬家. Escape returns focus to trigger; Tab from 确定 wraps to 取消. Pinned Modal.tsx has no exit animation; entry300ms ease scale.92→1 and opacity, mask250ms ease. Exact demo copy comes from the pinned public demo. These observations are requirements, not implementation acceptance.

### 2026-10-13 Modal page and semantic followup

All seven demos now use observed copy, variants, default/custom footer actions and mask alpha. Body/title styles belong to Modal; Typewriter.builder supplies one grapheme prefix timeline to explicit Gallery layout. Fishing sequence is80ms per grapheme with an8px line gap; component tests cover restart/disposal. Reference entry is300ms ease, .92→1 scale, with250ms mask and immediate exit. Escape remains independent of mask dismissal; default action closures target only their owned route.

Live Web inspection found that the installed Flutter engine SemanticRouteBase only exposes the dialog label when namesRoute is set. The explicit semanticLabel contract and separate title heading now map to a surface-sized520×266 named museum dialog. Forward/reverse focus loop and Escape restoration were exercised. This does not replace screen-reader acceptance.

Pure Chinese StoryLabel was20px versus reference21px. Modal supplies explicit21px strut metrics through the shared label slot, preserving existing natural defaults on other pages. The seven trigger tops at1440px are288,394,394,394,500,606,606; widget oracles bind these observations. Full Modal captures cover1440×1000 and375×812; raster/font differences remain distinguishable from geometry. Overall40-component/release acceptance is still NOT_ACCEPTED.

Historical reference observation; the opacity/reveal requirements in this paragraph are superseded by the approved readable-motion rule above. Next observed gap: Select public reference enters with opacity-only200ms ease and exits150ms ease. Shared AnchoredPanel currently only exposes symmetric duration with hardcoded vertical translation; a future correction must keep motion policy component-owned and overlay lifecycle common.

Live barrier followup: a full-page Cursor region consumed outside taps before the underlying ModalBarrier could receive them. Cursor is now composed separately around the dialog surface and the route-owned barrier. There is one barrier dismissal owner; no duplicate Gallery gesture listener or geometry-based click filter. Both game/normal have body-versus-barrier regression tests, and native flow clicks the light barrier directly.

A second Web hit-target defect was traced to a blank fullscreen semantics node from the cursor overlay's Focus/localization wrappers. ViewportOverlay now has an explicit decorative policy that excludes the entire entry from pointer hit testing and semantics; its borrowed Focus bridge itself has no semantics. Cursor uses that policy instead of excluding only its painter descendants. A public Cursor hover test detects the extra semantic node; deliberately disabling the decorative policy reproduces the failure (5 nodes expected,6 actual). Interactive notification focus/semantics tests remain part of regression coverage.


### 2026-10-14 Select actual behavior correction

Historical reference observation; the opacity/reveal requirements in this paragraph are superseded by the approved readable-motion rule above. The earlier suggestion of150ms exit came from unused .closing CSS. Live Escape removes the listbox immediately; the pinned JSX renders only open && mounted. Keep actual immediate exit and add the real200ms ease opacity-only entry. AnchoredPanel owns timing/lifetime/placement; Select supplies durations, curve and zero translation. Other consumers retain their existing motion defaults.

At1440x1000 the eight reference triggers are (313,332,140,41), (314,467,140,41), (1218,467,140,41), (313,602,140,41), (313,736,140,41), (469,736,140,41), (313,870,213,39), (542,870,213,39). The first popup is102x229 at459,238; five41px rows begin250. Gallery explicitly models collapsed section margins and the8px current-value caption gap. Search inputs reserve19px line height; component icons and padding remain library-owned.

Options reserve the reference16px leading dot space within symmetric30px text insets. The selected pill centers at56% of row height; keyboard active state does not masquerade as committed selection. Hover paints the10x14 amber triangle with the source500ms overshoot, without viewport clipping. Clear retains an open panel and does not bubble into the trigger. Full remaining Select states and mobile acceptance are not implied by these measurements.


Select Gallery frame followup: reuse StoryDemoBox for the actual dashed frame and StoryInset for undecorated examples. Account for the dashed1px border with17px total inset; preserve measured trigger rectangles. The final example margin collapses with the36px code-block margin, so its extra20px spacing is removed. The gap from search trigger bottom to the code-label frame is52px.

### Select search ownership and Drawer state followup
Live reference confirms Escape resets a nonempty Select query without closing, and a later Escape closes. Committed label prefixes are removed on new suffix editing; clear child activation is not handled by its ancestor. Trigger, clear and list semantics are separate. Historical scope note: full combobox semantics were blocked by the SDK implementation (debug role checks and Web engine mapping). The later version-scope decision at the start of this document supersedes the former “not waived” status; this historical observation is not a current undecided blocker.

Drawer reference right panel at1440x1000: x1062 width378, title x1086 y24 height42, first paragraph y101 height64. Header padding24/24/15; direction buttons gap16. Reference Drawer wraps its portal in Cursor. New composition keeps cursor decoration hit-transparent and panel actions separate from mask dismissal. Panel exit uses the360ms CSS elapsed-time cubic curve, mask uses ease. Interrupted/reversed motion and exhaustive AT comparison remain pending.

Web/native followup found the mask exposed as an unnamed button and the close glyph duplicated in its spoken label. The mask now excludes gesture semantics; only the real named close control is exposed, and its decorative glyph is excluded. Native search fixture now selects its own fish before testing query reset. Keyboard-focused rendering and remaining font-raster/motion comparisons still require explicit review.

### 2026-10-14 Collapse and picker followup

Collapse Web at1440x1000 DPR1 still has a20px basic caption versus reference21px, moving the first header to y289 versus290. At375x812, local header x43,y331.0799866,w289,h80 differs from reference x43,y326,w289,h76.78125. These are open visual gaps, not palette changes or acceptance. The existing audit report tracks PARITY-001.

Pinned DatePicker.tsx and TimePicker.tsx only close on blur when relatedTarget names an external element. No-target blur is retained; outside mousedown is independently handled. The Flutter focus boundary now follows this distinction without inspecting opaque child content or adding Web-only code. Web and Windows checks must remain source-bound; overall parity is NOT_ACCEPTED.

### 2026-10-14 Collapse line-box ownership correction

PARITY-001 was reproduced with unchanged 481-file baseline at DPR1/zoom1, 1440x1000 and375x812. At375px the reference ribbon is nowrap (341.484375x56 at34,68); the draft wrapped and added6.08px before the description. Title now owns its intrinsic horizontal surface and default nowrap content. Parent placement constraints remain intact; intentional reference paint overflow is not replaced by a Gallery offset.

The basic Gallery caption explicitly uses its observed21px line box. Collapse still owns question16/1.4/600 and answer14/1.7 defaults. Gallery StoryText owns only its plain string leaf: it derives typography from those inherited defaults, measures its own lines, reserves Chromium's1/64px line boxes, and lets original glyph paint overflow without scaling. It never inspects or rewrites a Widget slot. The existing Modal/Drawer inherited strut factory has one shared Gallery owner. Custom public children retain explicit metrics and may enlarge the component.

Focused widget checks match first card top288/324 and closed heights64/80.78125 at1440/375px; expanded heights111.796875/152.375 and the next card displacement also match within the existing0.1px geometry tolerance. This does not establish exact glyph equivalence: Flutter still rounds glyph line advance, and comparison of text baselines/raster and remaining interaction transitions stays open. The current audit report owns the later source-bound Web/Windows results; no historical build result is reused. Overall NOT_ACCEPTED.


## 2026-10-14 Focus and narrow header continuation

PARITY-002 records the reference Collapse keyboard-focus raster: a 1px #101010 rectangular inset line clipped by the existing rounded header surface. The shared outline painter now takes component-owned width and offset; Button/Tag keep their 2px external stroke and 2px gap. PARITY-003 records absent U+2630 coverage in every bundled font and the measured 52px Gallery header, 28px actions, and equal three-bar menu artwork. Gallery chrome owns this artwork without importing a system font or substituting the different library menu SVG. Source-bound Windows/Web verification remains authoritative in report.final_validation; these scoped repairs do not close exhaustive parity, contrast, AT or release gates.

A11Y-005 was reproduced in both fresh Web and public Gallery widget tests: default spatial traversal interleaved wide navigation and document controls. Separate Gallery traversal regions correct this. Reverse traversal also exposed an initially unmounted final navigation action; the fixed menu now uses one complete scrollable Column. Existing keyboard navigation remains available even though the reference sidebar itself exposes generic click targets. TEST-004 updates the old Tag AppBar finder to the real title and equal-gap rule, preserving all original content geometry assertions. Failed exploration and the prior frozen batch remain historical evidence.

### 2026-10-14 Title / Collapse / choice glyph and motion observation

Title: Live reference: layer/tab hover scales to1.06 over200ms ease without changing layout; ribbon remains static. Padding is1.6em/1.55em/1.5em for ribbon/layer/tab; tab adds0.4em left text margin and uses actual theme-ink text. Only ribbon has0.11em top optical offset. Explicit child styles/state remain authoritative. Reduced motion jumps to the target.

Collapse: Reveal uses300ms cubic(.4,0,.2,1); icon/color/leaf and answer bottom padding0..24 use250ms independently. Reversals start at rendered values, and the grid cannot shrink below its current padding. Rebuilds with unchanged target do not restart motion. Reduced motion synchronizes both timelines.

Historical reference observation; the opacity/reveal requirements in this paragraph are superseded by the approved readable-motion rule above. Checkbox: The shared choice renderer owns the pinned15x14 check path, size-dependent SVG fit,200ms stroke delay plus300ms ease reveal and600ms splash. Label500/.01em/1.5 line height; disabled colors and.55 opacity; focus is a separate2px yellow outline with2px gap. Host-controlled proposals never start selected motion until committed.

Radio: Uses the same choice glyph/typography/motion owner as Checkbox; group identity, selection requests and keyboard traversal remain Radio-owned.

Live Title API text still claims layer default, but pinned implementation and rendered default examples are ribbon; keep the actual default. Font-axis diagnostic renders variable600, explicit wght600 and static600 identically; default-axis100 metadata alone is not a defect. Reference font face availability and cross-engine glyph rasterization remain separate open checks. Original contrast failures are unchanged.


Historical reference observation; the opacity/reveal requirements in this paragraph are superseded by the approved readable-motion rule above. Switch uses intrinsic label width above its52x28/38x20 minima, device-pixel-rounded2.5px borders, reference thumb insets,250ms cubic(.4,0,.2,1), separate2px focus outline with2px gap, and a600ms11px ring at.7 busy opacity. Disabled/busy inputs never commit requests; reduced motion stops the ring.

Title Gallery now includes all25 observed title instances (three random-color variants,13 palettes,three sizes,English and explicit ribbon/layer/tab sections). Gallery background wrappers remain Gallery-owned; all titles use the public component. Wide/narrow widget checks cover section presence and first-title placement; they do not close cross-engine raster acceptance.

The Gallery supplies reference400/500/700 outlines as three static faces registered400/500/900. The bold face carries900 metadata and no stale STAT weight to prevent Flutter synthetic emboldening:600..900 requests all select the reference700 geometry. The former variable font and former700 registration are removed. All6937 covered codepoints are retained. Title captions use16px and labels21px strut line boxes at default scale. This does not itself establish cross-engine raster parity.

Rate live observation confirms350ms cubic-bezier(.4,0,.2,1) pop,60ms new-star stagger,600ms final-star splash and250ms hover/fill/eye transitions. Clear removes hover preview; unchanged boundary scores do not dispatch.

### 2026-10-15 Loading / Skeleton / BackTop motion correction
Historical reference observation; the opacity/reveal requirements in this paragraph are superseded by the approved readable-motion rule above. Reference Loading uses direction-applied opacity easing; reduced motion removes entry animation but retains exit fade. The vignette is a farthest-corner ellipse (CSS Images3), with unchanged colors. Skeleton paragraph has one1600ms sweep across rows and gaps; short supplied row widths repeat the last width. BackTop keeps64px bounds with an external2px focus outline and interpolates its shadow over300ms. Targeted timing/geometry/pixel tests cover these named defects. Rapid CSS transition-reversal shortening, all raster states and exhaustive40-component acceptance remain pending.


### Readable-motion counter-audit followup

Input focus, range placeholder/hover, Avatar overflow, Table loading and CountUp celebration now use readable pairs on their actual owned surfaces. Upload supplies opaque status/action backings over arbitrary thumbnails and theme-aware transparent tips; hidden hover actions reject pointer hits. Date/time navigation and footer controls paint focus without layout changes. Image/Upload preview routes share presentation-only opaque displacement, while components keep route lifetime and content ownership. Badge/IconButton descriptions reuse IslandTooltip. The close SVG changes only its X stroke to #B03038; provenance records the transformation. Drawer reduced-motion settling runs after build. These authorized color/motion differences retain the original thresholds and do not establish exhaustive state or assistive-technology acceptance.


Image preview close uses the pinned16x2 rounded crossed bars and150ms reversible ease scale; its readable gray surface and separately backed focus outline stay opaque. Input visual hint/label no longer duplicate its stable accessible name. Gallery Input supplies the reference full-width brown-pattern Card,12px top gap,20px padding and18px radius through public Card composition; IslandCardTheme.style.borderColor is the border override owner. Gallery header descriptions also use IslandTooltip.

### Atomic theme regions and field feedback
For runtime light/dark changes, use `IslandThemeHost(data: targetTheme, child: content)` inside `Scaffold.body` or the existing Material content. Pass the application's already-resolved target ThemeData, not an upstream AnimatedTheme intermediate frame. The host owns one opaque paper surface and synchronously installs Theme, default ink and IconTheme. It stores no theme mode or controller and does not inspect children. Nested caller-owned Scaffold/Material/AnimatedTheme or explicit styles start a new painting boundary. Static reference Gallery surfaces retain their backgrounds.
Input owns one FormField and TextField; controller/selection/focus survive helper/error and theme changes. Fill, border and helper/error switch atomically outside InputDecorator's implicit fade/interpolation. Validation/reset/controller replacement and error live-region semantics remain with the field. Countdown settles its existing digit timeline when reduced motion starts; restoring motion cannot resume an obsolete transition.

### 原子主题区域与输入反馈
运行时切换明暗主题时，在 `Scaffold.body` 或已有 Material 内容内部使用 `IslandThemeHost(data: targetTheme, child: content)`，传入应用已经解析好的目标 ThemeData，不能传上游 AnimatedTheme 的中间帧。宿主只负责一块不透明纸色底板和同步更新的 Theme、默认文字与图标；不另存主题模式或动画控制器，不检查子内容。调用者嵌套的 Scaffold/Material/AnimatedTheme 或显式样式构成新的绘制边界。静态参考 Gallery 保留已有底色。
Input 保留一个 FormField 和 TextField；辅助/错误消息与主题切换不丢控制器、选区和焦点。填色、边框、辅助/错误行原子切换，不使用 InputDecorator 的默认淡入和插值；校验、重置、外部控制器替换及错误 live-region 语义仍由输入框负责。Countdown 开启减少动态效果时结算原数字时间线，恢复动效不会续播旧过渡。

Fixed light surfaces use one internal LightSurfaceScope for readable token/text/icon defaults while preserving unrelated extensions and explicit child styles. ContentScope defaults IconTheme color to its explicit text role unless the slot supplies a distinct icon role. Card, Drawer, Modal, Notification, Tooltip and Table share the fixed-surface mechanism; Avatar/Badge/Title/Countdown, CountUp, Select, Tabs and Loading pair icon defaults with their owned text roles. This scopes inheritance; it never inspects or rewrites child widgets. 固定浅色表面统一提供可读的语义主题；默认图标跟随对应文字角色，显式子样式不被覆盖。

Tag owns its close-state colors: hover atomically pairs colorway.ink with colorway.soft; resting transparent variants retain surface ink. The16px target, separate keyboard/parent dispatch and host-owned removal remain unchanged. Explicit opaque child styles/state are preserved.

CodeBlock owns its readable syntax palette, including comments on the default deep-brown backing; explicit custom surfaces require a caller-supplied suitable style. Carousel reuses the existing light-surface scope for its fixed pale slide backplane, preserving unrelated theme extensions and explicit opaque slide styles/state. ActiveStack still owns active-only painting/hit/semantics; Carousel owns selection, timers and focus.

Card, filled Tag, Title and Select popup now scope nested public controls to their explicitly known surface foreground. Transparent Tag keeps ambient semantic roles without replacing its child subtree. Icon currentColor inherits IconTheme unless color is supplied; internal multicolor artwork remains asset-owned. All16 unfilled glyphs bind necessary strokes to currentColor while the pale spinner track stays decorative; the current catalog has163 glyphs. Explicit child styles and caller-owned custom surfaces remain the caller’s responsibility. Windows/Web live interface acceptance remains pending; screen-reader validation is excluded by the current user scope decision.

Card、填充 Tag、Title 与 Select 弹层为嵌套公共控件提供已知表面的配对前景色；透明 Tag 沿用宿主语义角色，不替换子树。Icon 的 currentColor 优先采用显式 color，其次继承 IconTheme；多色资产的内部颜色仍归资产所有。16个无内部填色图标的必要描边继承 currentColor，spinner浅色轨道保留为装饰；当前目录为163个图标。显式子样式和自定义底色由调用者负责配对。Windows/Web 现场界面仍待验收；读屏验收已按当前用户范围决定排除。

IslandDialogRoute is the public shared route for caller-owned preview/alert content. Push it on the root Navigator and retain its identity for exact-route cleanup. It captures caller themes and supplies opaque displacement and reduced-motion settlement; the builder owns dialog surface, semantics and actions. Gallery Form/Notification keep their existing AlertDialog adaptations, Upload keeps its560px normal IslandModal, and core Image/Upload reuse this same route. The old internal route name/path is removed. showIslandModal retains its independently observed game-dialog scale/timing. Real platform callback geometry and input acceptance remain pending; screen-reader validation is excluded by the current user scope decision.

IslandDialogRoute 是调用者自有预览/提示内容的公共共享路由。应推入根 Navigator 并保留路由身份，以便只清理本实例。路由捕获调用者主题，统一提供不透明位移和减少动态时的结算；内容、表面、语义和操作仍归 builder。Gallery Form/Notification 保留现有 AlertDialog 适配，Upload 保留560px普通 IslandModal，核心 Image/Upload 复用同一路由。原内部路由名称及路径已移除。showIslandModal 保留已独立观察的游戏弹窗缩放和时序。真实平台的回调几何与输入仍待验收；读屏验收已按当前用户范围决定排除。

The fixed foundation paired foregrounds also cover nested text-button pressed beige and ghost-button8% mint hover composition. Nine onAccent, seven Title and three patterned-paper foreground entries were deepened after396 measured failing frame checks across1092 recipes; fills, hover overlays and motion are retained. The complete old/new pairs and actual backings are registered under A11Y-023; static default contrast is not a substitute for these state checks.

固定基础配对前景色同时覆盖嵌套文字按钮按下时的米色底板，以及幽灵按钮悬停时8%薄荷色叠层。1092种配方中396个过渡状态检查失败后，统一加深了9个 onAccent、7个 Title 和3个纸纹前景色条目；填色、悬停叠层与动效保持。完整新旧色、实际底色和比值登记于 A11Y-023；默认静态对比度不能替代这些状态检查。

All16 glyphs without an internal filled region now inherit their necessary strokes from currentColor (explicit color, then IconTheme). The nine additional node-level transformations follow165 measured failing paint/background pairs across256 rendered contexts; only the pale spinner track remains decorative. Geometry, widths and all147 filled assets remain unchanged. The latter still need paint-order/adjacency review. This is one renderer with targeted owned-asset edits, not a blanket color filter or a second style mode.

16个无内部填色图标的必要描边现统一继承 currentColor（显式 color 优先，其次 IconTheme）。本次新增的9个资产逐节点改色依据256个实际渲染上下文中的165组失败配对；仅 spinner 浅色轨道保留为装饰。几何、描边宽度及其余147个有填色资产保持；后者仍待绘制顺序与邻接背景审查。这是单一渲染器的定向自有资产修复，不采用整图滤色或另一套样式模式。

### 2026-10-15 现场键盘与父级布局修正

模态闭环即使保持同一目标或没有操作控件，也消费正向和反向 Tab。现有动作模块中的同一边界把顺序交给原有 FocusScope，仅为原本为空的 Scope 创建一个跳过遍历且不产生语义节点的内部焦点目标，并在卸载时移除借用 Scope 的监听、释放自有节点。不检查子内容、不增加第二个 FocusScope、不替换调用者的焦点目标。IslandDialogRoute 现明确默认 TraversalEdgeBehavior.closedLoop；调用者显式传入的非闭环策略（包括 null 以继承 Navigator）仍然有效。Drawer、Loading、showIslandModal 和共享预览/提示路由复用同一行为。真实 Web 键盘与 Windows/辅助技术验收独立于 Widget 测试。

<a id="gallery-parent-layout"></a>
### Gallery parent layout / Gallery 父布局（2026-10-20）

The user authorized correction of interactive content escaping its Gallery parent, superseding the prior deliberate Select min-content overflow rule. Shared `example/lib/shared/story.dart` owns example rows and heading/tag wrapping. Layout follows actual container constraints, with one stable child subtree: Select keeps both 140px triggers and a 16px minimum gap, uses reference space-between while they fit, and wraps only below their combined 296px requirement. Do not clip, shrink text/controls, switch mobile subtrees or alter the anchored-panel owner. Inset range-date examples honor their parent's available width; Gallery images keep declared fitting sizes and scale their owned aspect ratio when constrained. The spatial Tooltip direction diagram preserves its arrangement in an explicit horizontal scroll region. Decorative ribbon/shape overhangs are distinct from unreachable interactive controls. Pagination's component-owned row sizing and below-minimum wrapping contract is authoritative in `components/pagination/contract.json`; Gallery must not recreate it. These narrow usability differences are authorized deviations from the pinned reference; prior overflow screenshots/tests remain historical, not current expectations. Validate containment and hit/focus behavior at 320/360/375/390/414, fitting desktop and actual container thresholds, including resize without losing state/focus.

用户批准修复 Gallery 交互内容越出所属父区域的问题，取代旧 Select 刻意最小内容宽度溢出规则。示例行及标题/标签换行由 `example/lib/shared/story.dart` 唯一负责，按实际容器约束布局并保留同一子树：Select 两个140px触发器及16px最小间距不变，能容纳296px时保留参考 space-between，否则换行；不裁切、不缩字或缩控件、不切换手机子树、不改锚定浮层所有者。日期范围示例服从父级可用宽度；Gallery 图片在能容纳时保持声明尺寸，受限时按自有宽高比等比收缩；Tooltip 方位图在显式横向滚动区域保留位置关系。装饰丝带/形状外延与交互控件不可达分别处理。Pagination 行布局及低于固有最小宽度时的换行契约以 `components/pagination/contract.json` 为权威，Gallery 不复制算法。这些窄屏可用性差异是已授权的参考差异，旧越界截图/测试保留为历史。验收覆盖320/360/375/390/414、正常桌面及实际容器阈值两侧，同时检查包含关系、命中/键盘、resize状态与焦点保持。


### 2026-10-17 catalog layout and font followup / 目录布局与字体复测


The catalog layout followup keeps each owner explicit. Pagination.alignment defaults to AlignmentDirectional.centerStart; Table chooses centerEnd so its final page-size action stays at the trailing edge when the single row cannot shrink further. It does not create scrolling or a second pagination implementation. Tabs proportionally shrinks each capsule's content contribution, preserves padding and intrinsic minima, and stretches the capsules to the tallest wrapped label. Opaque labels keep their keys, styles and lifecycle; a caller controls their line-break opportunities. The Gallery's known Chinese tab labels explicitly include zero-width break opportunities to reproduce CSS CJK wrapping without inspecting arbitrary children. Divider repeats complete size+gap cycles with no final connector; tiled waves retain the centered reference phase.

IslandTheme.codeFontFamily is the package-qualified bundled Fira Code family. CodeBlock and Gallery icon identifiers use it with zero default letter spacing; an explicit CodeBlock.textStyle still wins. Fira Code is a project resource, not an installed system font. Arimo is a Gallery-only fallback for the reference's Arial native-control examples. docs/font-resources.json binds upstream commits, unchanged font bytes and OFL notices. Fonts/engine raster differences remain separately reviewable; neither font packaging nor widget tests establish whole-library visual acceptance.


目录布局修正保持所有者清晰：Pagination.alignment 默认 AlignmentDirectional.centerStart；Table 显式选择 centerEnd，使单行无法继续收缩时末端条数操作仍贴近尾边。它不引入滚动或第二份分页实现。Tabs 按各胶囊的内容宽度比例收缩，保留内边距和固有最小值，并将各标签拉伸至最高换行标题的高度。不透明标题保留键、样式和生命周期，换行机会由调用者决定。Gallery 自己拥有的中文标题显式声明零宽换行机会，以映射 CSS 中文换行；公共组件不检查任意子内容。Divider 只重复完整的 size+gap 周期，不留下末端连接线；波纹保留参考的居中平铺相位。

IslandTheme.codeFontFamily 是包内 Fira Code 的完整字体族名。CodeBlock 与 Gallery 图标标识使用它，默认字距为零；显式 CodeBlock.textStyle 仍优先。Fira Code 只是项目资源，不安装系统字体。Arimo 仅作为 Gallery 原生控件示例的 Arial 后备字体。docs/font-resources.json 绑定上游提交、未修改的字体字节及 OFL 声明。字体及引擎栅格差异仍单独核验；打包字体和组件测试不代表整库视觉验收通过。

These repairs are in targeted retest; updated Windows/Web captures and source-bound integrated checks are still required. / 以上修正处于针对性复测阶段，仍需更新 Windows/Web 截图和源代码绑定的整体验证。


### Catalog measured layout followup

CodeBlock.padding is an optional content inset; null retains the copyable-dependent default. Explicit insets must reserve space for a visible copy action. The Home consumer requests28px horizontal/20px vertical,13px/1.8 text, zero margin and max600px width. Progress info inherits16px/1, weight700 and0.32px letter spacing; explicit opaque info styles remain authoritative. No public slot is inspected or rewritten.

Gallery-only layout fixes map measured CSS margin collapse, row stretching, owned text line boxes and initial example configurations. The native static capture waits for BackTop's known initial timer before positioning and asserts every actual captured scroll offset. Capture success and widget tests do not establish complete visual acceptance.


### 目录实测布局后续修正

CodeBlock.padding 可显式指定内容内边距；null 保留依复制按钮状态决定的默认值。显式内边距需为可见复制按钮留出空间。首页消费者使用水平28px/垂直20px、13px/1.8文字、零外边距及最大600px宽度。Progress信息默认16px/1、字重700、字距0.32px；不透明内容的显式样式仍优先，不检查或改写公共插槽。

Gallery布局修正对应实测CSS外边距折叠、同一行卡片拉伸、自有文本行框及示例初始配置。原生静态截图先等BackTop已知的初始计时结束，再定位并断言每张截图的实际滚动位置。截图成功与组件测试不代表完整视觉验收。


Filled icon artwork separates host-facing contextual contours from interior fixed drawing ink. docs/icon-paint-roles.json records the reviewed element indices; geometry is unchanged. Interior marks on their own opaque backings do not inherit a pale host color. Named raster assertions verify actual backing colors and the3.0 threshold across30 host/Card contexts. Facial and heat details have individually required roles; material seams/highlights retain provenance without a blanket necessary-mark exemption. The named probes do not certify every glyph adjacency or complete visual acceptance.


有填充图标分别维护面向宿主的上下文轮廓与内部固定画笔。docs/icon-paint-roles.json 记录逐图元审查清单，不改几何。位于自身不透明底色上的内部标记不继承宿主浅色描边。具名像素断言在30种宿主/Card上下文中同时核对真实底色与3.0门槛。面部和热气细节按逐项必要角色验收；材质接缝与高光保留素材来源，不构成必要标记的整类豁免。具名采样不代表每个图标邻接色或完整视觉验收通过。

### 2026-10-17 Carousel keyboard-focus visual followup

Actual1440x1000 Web Home-key focus on the carousel region showed no contour; the fixed reference displays2px outline with3px offset (carousel.module.less:10-12). Control focus used inner borders rather than reference external2px outlines offset2px (:83-87). This newly inspected state is registered asA11Y-031 before repair, with matched root-focus screenshots; an early reference arrow screenshot caught its own crossfade and is diagnostic only.

Carousel now reuses the existing FocusOutline painter without layout padding. Root primary focus uses its host focus role; descendant focus hands off rather than leaving a root ring. White arrow/dot/rotation controls use the existing light focus color and opaque white stroke backing over unknown photo pixels, under the already approved necessary-contrast exception. Normal root20px corner geometry and all control dimensions remain unchanged; default arrow border restores reference1.5px paint. No extra focus node, duplicate slide, timer owner or opaque-child inspection is added. Public actual-pixel regressions cover root-to-child handoff, light/dark hosts, external ink/backing contrast and geometry; source-bound Windows/Web retest remains required.

### 2026-10-17 Gallery photo-caption backing followup

Historical observation and superseded repair, retained for provenance only. The [current Home/Carousel authority](#home-host-and-photo-gradient) replaces the opaque-caption instruction below. / 以下为历史观测及已撤销的修复，仅保留溯源；[现行权威](#home-host-and-photo-gradient)已替代下述caption实底指引。

A11Y-032 was registered before repair: native375px first Carousel photo renders the actual title core#FFF9E3 over a clear#ADA7A2 wall counter (82,560 versus86,560), contrast2.25599. Nearby antialiased glyph-edge candidates are not used as backing proof. A dedicated original-Gallery public-render oracle over all3 actual photos at1440/375 also reproduced4.5 failures in the blank6px title/body gap (minimum observed2.55355). This is a real consumer contrast gap despite the prior focus and general-surface tests passing.

Under the existing one-palette necessary-color authorization, Gallery now backs only its owned title/body Column with the existing opaque#2B2118 drawing color;#FFF9E3 has14.9323 against it. No padding, text metric, image position, frame geometry, carousel API or opaque slide behavior changes. The original photo gradient remains decorative; it no longer supplies the necessary text backing. This visible necessary-color deviation is explicit, not claimed exact reference-color parity. Source-bound complete engineering and Windows/Web actual-frame retest remain required.


Necessary filled-glyph roles (current2026-10-17): eyes, beaks, eye stalks, steam, connectors, off slashes and the coffee-cup heart are required marks. Brown-faced ink is strengthened to black; navy-faced eye rims use white and beaks keep their own yellow/coral. Exposed steam/connectors inherit currentColor. Off slashes use currentColor on the host and existing danger #E05A5A clipped to the original owned body. Snail eye stalks retain dark ink only over the owned green head. The original geometry and widths are unchanged; static local SVG clip/use references share paths, with no runtime background inference. The147 host-contour/closed-silhouette matrix is separate from individually named interior role probes and is not blanket certification of every artwork adjacency or browser state.

有填色图标的必要角色（当前2026-10-17）：眼睛、喙、眼柄、蒸汽、连接线、关闭斜线和咖啡杯爱心均为必要标记。棕色脸部画笔加强为黑色；深蓝脸部眼圈使用白色，喙保持自身黄色/珊瑚色。外露蒸汽、连接线继承currentColor。关闭斜线在宿主上继承currentColor，在原有自有图形内部裁切使用既有危险色#E05A5A。蜗牛眼柄仅在自有绿色头部保留深色画笔。原几何和描边宽度不变，静态SVG局部clip/use共享路径，不在运行时猜测背景。147项宿主轮廓/封闭剪影矩阵与逐项内部语义采样分开，不代表每个插画邻接色或浏览器状态均已通过。

The same required connector rule covers the original apple stem and balloon string: currentColor on the exposed host, with unchanged geometry. The public-render matrix additionally checks71 individually named semantic probes at48px; prior named own-backing and transparent-role assertions remain binding.

同一必要连接线规则也覆盖原有苹果茎和气球绳：外露宿主区域继承currentColor，不改几何。公共渲染矩阵另在48px逐项检查71个具名语义采样；此前具名自有底色和透明区域断言仍然有效。


Canonical scene SVGs expand their finite circle tiles during the existing offline asset import. Original dot geometry, opacity, colors and clipping remain; no runtime shader fallback, renderer fork or parser-limit relaxation is introduced. Validate the existing four packaged-scene decode oracles in actual Windows and Web engines, not only the VM.

规范场景 SVG 在现有离线素材导入流程中展开有限的圆点平铺，保留原圆点几何、透明度、配色与裁剪；不引入运行时回退、渲染器分支或解析上限放宽。现有四个打包场景解码用例必须在真实 Windows 与 Web 引擎复测，不能只依赖 VM。


### 2026-10-17 Select native composition session repair

IME-001 reproduces a real ordinary-browser commit failure: rewriting `AppleB` to `B` during composition leaves a later native event addressing range5..6 in text of length1. Select now keeps the active native buffer/range intact and derives the logical suffix query separately; normalization waits for commit/end. While composing, the original selected-label prefix may remain visible. This is the minimum native-editing adaptation needed to preserve the contracted IME session, with unchanged control geometry, typography, palette and final committed-query display. Candidate keys stay with the editor; selection remains host-owned, and current-value/session checks protect focus-ending reconciliation. No SDK/renderer edit, DOM workaround or duplicate content/input owner is introduced. Source-bound actual Windows/Chrome/Edge retest remains required.

IME-001已在普通浏览器路径复现：组合期间把AppleB改成B，后续原生事件仍使用5..6范围，超出长度1而报错。Select现保留活动编辑缓冲及范围，另行计算逻辑查询后缀，提交／结束后才整理前缀；组合期间可能仍显示原选中标签。这是为保留既定输入法会话所需的最小原生输入适配，不改控件几何、字体、配色或最终查询展示。候选按键归编辑器，选择值归宿主，结束会话整理按当前值／会话校验且不抢清除焦点。不修改SDK或渲染器、不加DOM补丁或第二份内容／输入所有者；仍须同源Windows、Chrome、Edge复测。

Browser state-combination repairs, 2026-10-17: Card/Tag reconcile only their still-mounted child focus after optional parent actions change and semantic DOM reparenting blurs the resumed view; Tabs reconcile semantic reorder blur only in the same resumed view, respecting explicit external focus. Select names its stable editable child separately from popup metadata. These change focus/metadata ownership without changing reference geometry, colors, fonts or content. Actual native-pointer browser failures and their repaired-source retests are retained separately.

2026-10-17 浏览器状态组合修复：Card／Tag 可选父操作变化引发语义 DOM 改挂后，仅整理当前活动视图中仍挂载的子控件焦点；Tabs 仅在当前活动视图整理重排造成的焦点丢失，尊重显式外部焦点。Select 编辑节点具名且与弹层元信息分离。不改参考几何、配色、字体或内容，保留原生点击失败与修复后复测的独立记录。

Gallery leaves semantics activation to Flutter/platform demand instead of unconditionally forcing Web accessibility text editing. Semantic metadata remains in the widgets; semantic contract tests enable it explicitly. Normal Web editing retains native composition and first-input behavior. Reader execution remains excluded.

Gallery 由 Flutter／平台按需启用语义，不再无条件强制 Web 无障碍文本编辑路径。控件语义元数据保留，语义契约测试显式启用；普通 Web 输入保留原生组合与首次输入行为，读屏执行仍排除。

When search becomes disabled, its native editing client is retired before the committed host label replaces a composition buffer. Deferred restoration uses the latest label and is cancelled by re-enabling, a newer host update or disposal; it emits no selection proposal and takes no focus.

搜索框被禁用时，先退出原生编辑连接，再以宿主已提交标签替换组合缓冲；延后整理使用最新标签，重新启用、新宿主更新或卸载会取消旧回调，不提出选值请求或抢焦点。

Select filtering opts out of native autofill forms: its query is transient option search, not a saved form field. Clear-slot geometry changes must not trigger autofill focus changes during disable.

Select 的临时选项搜索不参与原生自动填充表单，避免清除按钮改变编辑框几何时触发表单切焦点并干扰禁用。

A pending presentation-focus recovery survives benign host/theme rebuilds while its child/header owner is unchanged. New recovery ownership supersedes the previous request; replacement, removal, disposal, inactive view and explicit external destinations retain priority. Rebuilding alone does not cancel an otherwise valid request.

两帧呈现焦点整理期间，若子控件／页签所有者未变，普通宿主或主题重建不会取消有效恢复。新所有者取代旧请求；替换、移除、卸载、非活动视图和显式外部焦点仍优先。

Independent Card/Tag/Table child focus attaches to the existing caller Focus node, including a FocusScope; if no inherited focus exists it uses the existing manager root. A scope boundary must not silently place the child beneath the optional parent detector or paint parent focus over child focus. One shared ActionSurface owns this fork; no new scope or copied child subtree is introduced.

Card／Tag／Table 的独立子焦点挂接到现有调用者 Focus 节点（包含 FocusScope）；没有继承节点时使用现有管理器根节点。作用域边界不能悄悄把子焦点挂回父操作检测器，或用父焦点描边覆盖子焦点。该隔离仅由共享 ActionSurface 负责，不新建作用域或复制子树。

Closed Drawer uses the existing viewport exclusion mode for the entire retained entry, including captured locale semantics. This fixes semantic DOM pointer interception without changing layout, artwork or the retained content lifecycle. / 关闭抽屉沿用现有整层排除机制，避免空语言语义层拦截浏览器指针，不改变布局、图案或内容保留生命周期。


<a id="home-host-and-photo-gradient"></a>
## Home host and photo gradient / 首页宿主与照片渐变 (2026-10-18)

Current user decision (Home/Carousel,2026-10-18): the official GalleryPage→Scaffold/Material host remains required; wrong-host fallback double-underline samples remain historical. Home removes the six added text-specific backplates, retaining the page canvas, original cards/badge, fonts and motion. HOME-REFERENCE-CONTRAST-001 is now explicitly approved by the user for those named Home text regions over original wallpaper; record actual below4.5 pixels as a reference-priority exception, never4.5PASS. Card text, actionable controls and focus remain required. Gallery's photograph caption restores the pinned original linear-gradient(0deg,rgba(43,33,24,.72),transparent62%) with unchanged geometry; no caption rectangle, adaptive safety plateau or private caption renderer remains. CAROUSEL-REFERENCE-CONTRAST-001 is a user-approved reference-priority exception for that named photo-caption region only: publish real measured ratios and failures, never a4.5PASS or global waiver. Controls/focus/necessary graphics still require3.0, other text retains4.5. Safe-gradient samples are superseded historical alternatives. The public Carousel continues to treat arbitrary slide Widgets as opaque.

当前用户决定（首页/轮播，2026-10-18）：保留正式GalleryPage→Scaffold/Material宿主，错误宿主的黄色双下划线样本仅为历史。首页撤掉新增的六处文字专用底板，保留页面底色、原卡片/版本badge、字体及动效；用户现已明确批准HOME-REFERENCE-CONTRAST-001，仅覆盖这些首页文字区域与原背景重叠时的参考优先例外；保留低于4.5的实际像素，不称4.5PASS。卡片文字、操作控件和焦点仍须达标。Gallery照片caption恢复固定参考原有linear-gradient(0deg,rgba(43,33,24,.72),transparent62%)及几何，不留caption矩形实底、自适应安全平台或专用caption渲染器。CAROUSEL-REFERENCE-CONTRAST-001只针对该照片caption区域，是用户批准的参考优先例外：如实公布实际比值与不达标，不称4.5PASS、不扩张为全局豁免。控件/焦点/必要图形仍需3.0，其余文字仍需4.5。安全渐变样本降为历史方案；公共Carousel继续将任意slide Widget视为不透明内容。

## Gallery Background preview repaint ownership / Gallery背景预览重绘职责 (2026-10-20)

The Background story owns its static preview composition and scroll placement. Its non-scene type tiles and content example isolate their repaint work with RepaintBoundary while continuing to mount the one public IslandBackground. The two SVG scene previews skip paint only when their entire bounds are outside the nearest actual scroll viewport plus a one-logical-pixel guard. They keep the same mounted subtree, layout, semantics and input path. Visible scenes paint directly in the existing canvas so their fractional-position edge samples retain the existing result. The existing outer MouseRegion and preview-provider callbacks retain hover behavior. This uses Flutter's ordinary repaint/layer lifecycle; it adds no custom bitmap cache, duplicate implementation, public option or content inspection. Library circle painting, colors, geometry and child content remain unchanged. Actual native viewport pixels and profiling validate only their recorded scope; later named Web observations and remaining raw-frame gaps are resolved by the sole current audit record, not this dated description. No60fps acceptance follows from a build.

Background故事页负责静态预览的组合与滚动位置；非场景类型的卡片预览及承载内容示例通过RepaintBoundary隔离重绘，仍然挂载唯一公共IslandBackground；两张SVG场景预览仅在完整边界位于最近实际滚动视口及其1逻辑像素保护区之外时跳过绘制，保留同一挂载子树、布局、语义和输入路径；可见场景继续在现有画布直接绘制，保留小数位置的原有边缘采样。外层MouseRegion及预览provider回调保持。此处使用Flutter正常的重绘/图层生命周期，不维护自定义位图缓存、不复制实现、不加公共选项，也不检查子内容。库内圆点绘法、颜色、几何与内容保持不变。实际原生视口像素与性能证据只说明其记录范围；后续具名Web观察及仍缺失的原始帧由唯一当前审计记录区分，此处历史描述不另定义当前阻塞，构建通过不等于60fps验收。

## Finite usability scope / 有限可用性范围 (2026-10-20)

The user accepted ICON-ACTUAL-LOAD-CADENCE-001 for this version and authorized formal adoption of the tested Gallery Background optimization. The finite result is “verified usable with explicit limitations” only within the recorded Windows representative/native-pixel/framework-interaction scope, after corresponding engineering and delivery checks complete. Current source/evidence identity and final status live in the existing scratch/global-audit-20261014T035753Z/report.json. This does not declare every reference state or platform accepted.

The actual-load diagnostic recorded pre-CPU12.7268% and runtime mean16.2734%. Background three30s rasterP95 values were15.430/15.266/14.923ms; prior short candidate3pass/2fail and product failures remain. Recent three Icon30s runs had0/8/4 observation callback intervals over100ms; new maxima140.568/129.327ms occurred inside actual moving commands. Scheduler/system counts also8+4 are pipeline-shifted neighboring pairs, not24independent physical stalls. The accepted limit does not turn those intervals into PASS. The user's simultaneous computer use may contribute load but is not proven as the sole cause. This is not a quiet-load benchmark, all-platform/all-state60fps guarantee, exactengine-startup/compositor/panel measurement or new redistribution authorization. Existing browser tool blockage and all named Home/Carousel/SDK exceptions remain; no new installation, reader execution or supervision restart.

用户接受本版本的ICON-ACTUAL-LOAD-CADENCE-001，并授权正式采用已测Gallery Background优化。“已验证可用、保留明确限制”仅适用于记录中的Windows代表性运行、原生像素及框架交互范围，且须完成对应工程和交付检查；当前源与证据身份及最终状态由既有scratch/global-audit-20261014T035753Z/report.json维护，不代表所有参考状态或平台均通过。

实际负载诊断测前CPU12.7268%、运行期平均16.2734%；Background三轮30秒raster P95为15.430/15.266/14.923ms，旧短测3通过2失败及正式版历史失败保留。最近三轮Icon30秒有0/8/4次观测回调间隔超过100ms，新两轮最大140.568/129.327ms，发生于实际滚动命令内；scheduler/system各8+4次在相邻对中有pipeline位移，不能称24次独立屏幕停顿。接受此限制不把长间隔改为PASS；用户同时用电脑可能贡献负载，但未证实唯一因果。此结论不承诺低负载基准、全平台全状态60fps、精确引擎启动/合成器/面板呈现，也不新增再分发授权。浏览器工具受阻和既有Home/Carousel/SDK具名例外保持；不安装、不读屏、不恢复监督。


<a id="surface-sampling"></a>
### Surface sampling / 表面采样（2026-10-20）

Fractional motion must sample a complete owned backing/border/content group together. Pure translated drawing can quantize glyph pixels separately from vector edges even under one logical matrix; do not add text delays or offsets. Use the existing framework filtered Transform only where the named scene evidence validates it; this is not a blanket prescription for every moving owner. Each owning component retains its one position/scale timeline, targets, reduced-motion settlement, focus/hit testing and single child identity; shadow/color decoration can keep its separately specified interpolation. Existing SurfaceMotion composes its supplied translation/scale into one filtered matrix, remaining stateless and leaving timing/visibility to its caller. Gallery uses the same framework mechanism through public Flutter APIs, without private package imports or a new product API. Unchanged integer jumps (Upload), decorative shadow extent and nonmoving labels are distinct cases. Pixel oracles compare the Button backing alpha-edge and linear ink-mass centroids; an opaque payload inside an opaque host uses its known contrasting color-edge derivative and linear ink mass. The original0.25 tolerance is unchanged. toImage observations are output-image pixels at the declared pixelRatio, independent of OS DPR; they do not establish physical scanout. The Notification/Tooltip measurement limitation accepted below does not turn failing numbers intoPASS. Browser raw frames and Windows engine observations qualify platform behavior separately; no new60fps guarantee is inferred.

分数位移必须把所属底板、边界和内容作为完整整体一起采样。即使只有一个逻辑矩阵，直接平移绘制也可能让字形像素与矢量边界采用不同量化；不得给文字加延迟或补偿偏移。仅在具名场景证据有效时使用既有框架 filtered Transform，不向所有运动所有者机械推广；各组件仍拥有唯一位移/缩放时间线、目标、减少动态时结算、命中/焦点及单一子身份，阴影/配色装饰保留各自已规定的插值。既有无状态 SurfaceMotion 把调用方给定的位移/缩放合成一个 filtered 矩阵，不接管时序或显示条件；Gallery 通过公共 Flutter API 使用同一框架机制，不导入包内私有实现、不新增产品API。Upload 的整数跳变、装饰阴影外延和本就不移动的文字分别归类。像素测试比较Button底板alpha边缘与线性文字质量中心；位于不透明宿主内的受控内容则用已知对比色边缘导数与线性文字质量中心。原0.25门槛不变。toImage观测单位为声明pixelRatio下的输出图像像素，独立于OS DPR，不证明物理屏幕呈现；下述通知／气泡测量限制的接受不把失败数值改成PASS。浏览器原始帧及Windows引擎观察分别说明平台有效范围，不新增60fps承诺。


Surface-sampling owner coverage / 表面采样所有者覆盖：

| Existing owner | Active motion and classification |
| --- | --- |
| Notification | Original250ms cubic/±16px renderer retained under the user-accepted measurement limitation2026-10-21. Output-image ink-centroid failures remain; calibrated rigid glyph controls also fail, so this alone does not establish a component timing defect or pixelPASS. Slots remain opaque; leaving handles remain non-reversible. |
| Tooltip | Original250ms directional bubble retained under the same user-accepted measurement limitation. A filtered-transform proposal regressed a named native horizontal sample and was reverted. Original/control glyph changes do not prove a separate text timeline, pixelPASS or engine cause; AnchoredPanel itself has zero duration here. |
| AnchoredPanel | DatePicker/TimePicker pass200ms with the existing default−6px offset. Placement, focus/semantics availability, portal lifetime and curve are unchanged. Select explicitly supplies Offset.zero; Pagination uses Duration.zero. These nonmoving paths do not acquire an extra filtered layer. |
| Carousel | The active opaque slide child translates along its existing0..18px timeline. The Gallery photo/gradient/caption is one caller-owned payload; no caption inspection, added backing or opacity change. ActiveStack paints only the selected slide, so an outgoing hidden slide has no visible exit sample. Integer arrow jumps are a separate unchanged path. |

以上是既有机制的覆盖分类，非全字体／全内容／平台验收证明。针对性测试使用真实Gallery英文字体和中文字体、奇偶内容高度以及两种渲染目标比例，经原始中间帧比较相对位移。公开消费者的定位、受控状态、焦点、快速反向、减少动态及卸载回归另行检查；实际浏览器证据限制仍须原样保留。


### Accepted measurement limitation / 已接受的测量限制（2026-10-21）

The user explicitly accepted retaining original Notification/Tooltip and the bounded ink-centroid measurement limitation after independent review. Same-backend controls replayed measured actual displacement with one rigid owner: Notification component/control maxima0.955284553/0.956521739 and Tooltip-x0.303329363/0.300683344 output pixels; geometric positive controls remained≤0.25, and injected relative geometry offset was detected. Text-to-patch matrices/styles were constant. This establishes that the ink-mass criterion alone cannot identify component-specific animation desynchronization. It does not establish the precise Flutter raster/hinting/compositor cause, perceptual delay, physical-screen parity or a new calibrated text acceptance model. Static-control bounds came from measured inputs rather than an independently measured RichText, and outside backgrounds differ; this is not exact scene equivalence. Colored outer-skin edge sampling remains unqualified. Keep all raw failures and the unchanged0.25 threshold; no extra runtime wrapper, neutral filter or caller text compensation is adopted. Browser hover/Edge375 and other pending work are separate and remain pending.

用户明确接受通知／气泡保留原实现与具名墨量质心测量限制。同后端单一刚性所有者按实际位移重放，组件与刚性文字控制均有近似超限，几何正控制≤0.25、注入的相对几何错位能被检出，文字对底板矩阵及样式恒定。这证明该墨量指标不能单独识别组件特有的动画不同步；不证明具体Flutter光栅／hinting／合成器原因、感知延迟、物理屏幕一致或新的文字验收模型。静态控制边界来自测量输入，未再次独立测量RichText，外部背景也不同，不能称场景完全等同；彩色外表面边缘仍未合格测量。原始失败与0.25门槛保留，不新增运行时包装、中性滤镜或调用方文字补偿。浏览器悬停／Edge375及其他待验项不由本次接受一并清除。

Root-cause boundaries: the Select placeholder row in the pinned reference has display:flex/gap16 and two140px minimum fields, without flexWrap. Our shared-parent Wrap is an authorized narrow-layout usability difference; it is not original wrapping parity. The initial Button and current Date/Time-panel/Carousel sampler corrections remain owned by the existing whole-surface transform and supported only by their named captures/behavior tests. They do not prove independent text animation, font substitution, a particular GPU cache defect, or all-content/all-platform60fps. The reference Button root, Notification card and Tooltip root own their transform; CSS transform/will-change is not evidence of Flutter internals.

根因边界：固定参考中的Select占位行使用display:flex／gap16，两个字段各有140px最小宽度且没有flexWrap；共享父布局Wrap是获准的窄屏可用性差异，并非原版就换行。此前Button及本轮日期／时间浮层、Carousel的采样修正归既有完整表面变换所有者，结论仅限具名画面／行为测试；不证明独立文字动画、换字体、特定GPU缓存缺陷或全内容全平台60fps。参考Button根、Notification整卡、Tooltip根拥有其主要位移，CSS transform／will-change不是Flutter内部原因的证据。

Reference identity: existing reference commit79810934ee9d08c22044d34e06f8bba40391207b; read-only comparison to main279959f7b30229ccdf2fb017126ac1a2e61e5f43, not a claim that latestmain is the deployed historical reference. Exact paths and retrieved-text hashes are retained in the source-bound audit evidence; no original implementation is copied.

<a id="gallery-product-version"></a>
### Gallery product version / Gallery 产品版本

The existing Home badge shows the independent root `pubspec.yaml` version through the generated `example/lib/shared/version.g.dart` projection. `tool/verify.py --generate-gallery-version` owns generation and validates equality with the Gallery pubspec; source policy rejects stale output. Do not maintain per-page version literals. Badge style and layout stay unchanged. The footer retains Reference Gallery attribution without presenting its observed version as this product's version; the original observed version remains provenance in `docs/reference-gallery.json`.

首页现有徽标通过生成的 `example/lib/shared/version.g.dart` 展示独立项目根 `pubspec.yaml` 版本；生成及与 Gallery pubspec 的一致性由 `tool/verify.py --generate-gallery-version` 所有，源码检查拒绝过期输出。不在页面手工维护另一份版本值，不改变徽标样式或布局。页脚保留 Reference Gallery 归属，但不把参考观测版本当成本项目版本；原观测版本仍保留在 `docs/reference-gallery.json` 来源记录中。


<a id="original-color-restoration"></a>
### Original-color restoration contract / 原色恢复契约（2026-10-21）

The root product remains0.0.1. Original colors may return only through their existing owner and shared consumers while preserving text4.5/necessary graphics3.0, actual composed surfaces, interruption states and explicit style precedence. No new contrast exception is authorized. Green soft ink, lime/yellow-green onAccent and yellow-green Title foreground are source-owned roles; do not copy a parallel palette into Gallery. Button owns one fixed busy fill recipe, separate from the unchanged global brand leaf; the existing onLeaf/border/focus and style-resolution owners remain. This fixed recipe applies in both host themes; applications customizing a busy pair use the existing ButtonStyle foreground/background/side together. Neither busy nor a light surface scans or rewrites opaque child styling.

产品版本保持0.0.1。原色只能在既有所有者原地恢复，并同步所有共享消费者；文字4.5、必要图形3.0、实际合成背景、中断状态和显式样式优先级均不变，不新增对比度例外。绿色soft文字、青柠／黄绿onAccent和黄绿Title前景由现有源文件拥有，不在Gallery维护平行色板。Button拥有一份固定busy填充配方，与保持原样的全局品牌leaf分开；onLeaf、边框、焦点与样式解析仍由现有所有者负责。这份busy配方用于两种宿主主题，自定义busy配对通过既有ButtonStyle共同设置前景／背景／边框，不检查或改写opaque child。

The proposed light ink original fails the existing named ink/sun token budget; this is not by itself a newly reproduced page defect. Original yellow/lime paper foregrounds fail an actually reachable nested Text Button pressed pairing, so those three current roles remain. Decisions, unrounded measurements, before/after source identities and actual platform limitations belong to the sole existing audit report; this contract is not acceptance.

基础light ink候选未通过既有ink/sun具名Token预算，不将此自动描述为新复现的页面缺陷。黄色／青柠纸面原前景则在实际可达的嵌套Text Button按下配对中不通过，因此这三项保留当前值。逐项决定、未舍入测量、前后源码身份和真实平台限制只由既有唯一审计报告维护，本契约不代表验收通过。

Busy 的既有不透明表面通过共享 LightSurfaceScope 提供嵌套默认角色；busy 开关只更新作用域值，内容树拓扑稳定。该作用域不增加绘制底板、不检查或重写 opaque child，保留其他 ThemeExtensions 与显式样式。The existing fixed-surface scope pairs nested defaults with the busy-owned surface in one stable content topology, retaining unrelated extensions and explicit styles.


<a id="color-api-p1"></a>
## Bounded color API P1 / 有限颜色 API P1

The user authorized the finite CodeBlock/Card customization repair and Button styling-contract convergence after the eight-color checkpoint. Component style recipes have one owner; presets and custom overrides use the same renderer, existing state mechanism and existing light-surface scope. Passive content defaults, nested control states, explicit caller content and artwork have separate responsibilities. CodeBlock keeps its single lexer and exposes its actual syntax/copy roles; Card carries final paint and semantic data together. Button adds no new styling capability. Current signatures and exact support live in declarations and component contracts; docs/API.md#color-api-p1 records the atomic migration.

用户在8项颜色检查点之后授权有限 CodeBlock／Card 自定义修复与 Button 样式契约收敛。组件配方只有一个所有者，预设／自定义共用同一 renderer、既有状态机制及浅表面作用域。被动内容默认值、嵌套控件状态、显式内容和素材职责分离；CodeBlock 保留唯一 lexer 并开放实际语法／复制角色，Card 一并传递最终画笔与语义数据。Button 不扩样式能力；当前签名和准确支持以声明及组件契约为准，docs/API.md#color-api-p1 记录一次迁移。

Other eight-color values and the busy-owned-surface repair remain protected; the later explicit C6 and C7 finite authorizations supersede that freeze only for their respective shared roles. No new contrast exception, runtime contrast guessing, opaque-child rewriting, compatibility track, P2/full40-branding API or performance change is authorized by this batch. Existing4.5 text/3 necessary-graphics budgets remain; custom caller recipes are not automatically certified. Engineering proofs, actual platform presentation and complete reference comparison remain separate. The existing18 numerical failures and five platform/claim limits, including incomplete actual Web before/after comparison, retain their recorded scope until real evidence changes it.

除后续明确授权有限回退的C6及C7各自共享角色外，其他8项色值和busy表面修正仍受保护；不新增对比度例外、运行时猜色、opaque child 改写、兼容轨、P2／全40组件换肤 API 或性能改动。4.5文字／3必要图形预算不变，自定义配方不自动获认证。工程、实际呈现与完整参考对比各自验收；18项数值失败、五项现场／声明限制和不完整实际Web前后对照继续保留原范围，直到真实证据改变结论。


<a id="c6-shared-foreground"></a>
### C6 shared foreground rollback / C6共享前景回退

C6 follow-up: yellowGreen.onAccent alone reverts from #725D42 to the pre-restoration #625A11 because the complete default ghost-state composition failed4.5. Card/filled Tag scopes, Badge and the Gallery palette caption read that same owner; no local patch, palette alias, overlay or state change. The independent Title role has its separate authorization and policy below; it is not the same role as onAccent. Original-color history is not all-state acceptance.

C6后续：完整默认ghost状态合成未达4.5，因此仅将yellowGreen.onAccent从#725D42回退到恢复前#625A11。Card／填色Tag作用域、Badge和Gallery色标读取同一所有者；不加局部补丁、色板别名，不改叠层或状态。独立Title角色的后续授权和配对规则见下节，不能将其与onAccent当作同一角色；原色恢复历史不等于全状态验收。


<a id="c7-title-foreground"></a>
### C7 independent Title foreground / C7独立标题前景

The user authorized finite validation of the existing yellow-green titlePalette fourth role, returning #725D42 to its historical pre-restoration #69563D. All Title variants, sizes, passive content and nested defaults consume this one role through the existing renderer and LightSurfaceScope. C6 onAccent remains separate and unchanged. Front/back/fold, other palette entries, geometry, motion, alpha, child ownership and text4.5/necessary graphics3 budgets do not change. The historical candidate must satisfy actual composed states; a failed candidate remains a failure, without a new exception or local compensation. Current executed results and platform limits belong only to the audit record, not this decision contract.

用户授权有限验证既有黄绿titlePalette第四项前景，从#725D42回到恢复前历史值#69563D。全部Title变体、尺寸、被动内容和嵌套默认值经既有renderer与LightSurfaceScope读取这一角色；C6 onAccent独立且保持。正面／背层／折角、其他配色、几何、动效、alpha、子内容所有权及4.5文字／3必要图形预算均不改。历史候选仍须在实际合成状态中验证；候选失败应保留失败，不扩例外或添加局部补偿。当前执行结果和平台限制只由审计记录拥有，本决定契约不复制验收状态。
