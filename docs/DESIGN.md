# Product design / 产品设计

The pinned [reference identity](reference-gallery.json) defines the 43 component families, Home and Skill pages. Windows and Web are primary targets. Preserve reference layout, typography, silhouettes, content and interaction except for the explicit differences below; adapt technical examples to Flutter. Current component details are in [the reference catalog](component-reference-details.json) and component contracts.

固定[参考身份](reference-gallery.json)定义 43 类组件、首页和 Skill 页，Windows 与 Web 优先。除下列明确差异外，保留参考布局、字形、造型、内容和交互，技术示例适配 Flutter；组件细节见[参考目录](component-reference-details.json)及各组件契约。

## Color and ownership / 配色与所有权

Maintain one light/dark product palette. Text requires 4.5:1 and necessary graphics 3:1 on their actual composited backgrounds, except the named Home/photo regions below. Every color is a named token in one of three library tiers: the primitive palette (`lib/src/foundation/palette.dart`, one name per raw value, plus the indexed IslandColorway and generated Background tables), the themable semantic roles (`IslandTokens`, `IslandColorway`), and one recipe per component (`lib/src/foundation/recipes/`) that resolves its state colors from the theme, including the reference-palette decision. Components and Gallery pages hold no color literals; Gallery demo colors live only in `example/lib/shared/palette.dart` and library values reach the Gallery through the public root. `tool/verify.py` and `test/color_literal_policy_test.dart` enforce this. Parent layout, passive slot defaults, nested controls, explicit caller styles and artwork have separate owners. Never infer arbitrary background colors, inspect/rewrite opaque child widgets or introduce a parallel palette.

仅维护一套明暗产品配色。除下述首页／照片具名区域外，文字在实际合成背景上要求 4.5:1，必要图形要求 3:1。颜色均为具名令牌，分三层归库：基础色板（`lib/src/foundation/palette.dart`，每个原始值一个名称，另含 IslandColorway 索引表与生成的 Background 表）、可定制的语义角色（`IslandTokens`、`IslandColorway`）、每个组件一处从主题解析状态色（含参考配色判断）的组件配方（`lib/src/foundation/recipes/`）；组件与 Gallery 页面不写颜色字面量，Gallery 演示色只在 `example/lib/shared/palette.dart`，库已有的值经公共入口读取，由 `tool/verify.py` 与 `test/color_literal_policy_test.dart` 检查；父布局、被动插槽、嵌套控件、显式子样式和素材各自负责，不猜测背景、不遍历改写 opaque child、不维护平行色板。

<a id="readable-motion"></a>
## Readable motion / 可读动效

Necessary content, its backing and boundary remain a readable opaque group. Keep appropriate translation, spring and scale; decorative shadows or masks may fade without making required content depend on them. Unsafe intermediate color pairs switch together. Each component owns one timeline, one content subtree, visibility and lifecycle. Shared SurfaceMotion composes presentation values only. Reverse, reopen, cancel, dispose, theme changes and reduced motion retain the same lifecycle and consistent focus/hit testing. Loading blocks background input while its necessary exiting layer is present.

必要内容、底板和边界组成可读的不透明整体；保留合理位移、弹性和缩放，装饰阴影或遮罩可渐变，必要内容不能依赖遮罩达标。不安全的中间配色成对切换。组件各自拥有唯一时间线、内容子树、显示条件和生命周期；SurfaceMotion 仅组合呈现参数。反向、重开、取消、卸载、主题切换和减少动态沿同一生命周期，焦点及命中一致；Loading 必要退出层可见时继续拦截背景输入。

## Viewport constraints / 视口约束

The shared anchored-overlay owner preserves fitting reference placement. It repositions only on overflow and constrains width only when the preferred width cannot fit, keeping content reachable through wrapping or scrolling. This is a narrow-layout usability difference, not a new component-specific layout mechanism or exact reference parity.

共享锚定浮层保留能放下的参考位置；仅越界时调整，首选宽度确实放不下才限宽并允许换行或滚动。这是窄屏可用性差异，不是组件专用算法，也不声称参考完全一致。

<a id="gallery-parent-layout"></a>
### Gallery parent layout / Gallery 父布局（2026-10-20）

The user authorized correction of interactive content escaping its Gallery parent, superseding the prior deliberate Select min-content overflow rule. Shared `example/lib/shared/story.dart` owns example rows and heading/tag wrapping. Layout follows actual container constraints, with one stable child subtree: Select keeps both 140px triggers and a 16px minimum gap, uses reference space-between while they fit, and wraps only below their combined 296px requirement. Do not clip, shrink text/controls, switch mobile subtrees or alter the anchored-panel owner. Inset range-date examples honor their parent's available width; Gallery images keep declared fitting sizes and scale their owned aspect ratio when constrained. The spatial Tooltip direction diagram preserves its arrangement in an explicit horizontal scroll region. Decorative ribbon/shape overhangs are distinct from unreachable interactive controls. Pagination's component-owned row sizing and below-minimum wrapping contract is authoritative in `components/pagination/contract.json`; Gallery must not recreate it. These narrow usability differences are authorized deviations from the pinned reference; prior overflow screenshots/tests remain historical, not current expectations. Validate containment and hit/focus behavior at 320/360/375/390/414, fitting desktop and actual container thresholds, including resize without losing state/focus.

用户批准修复 Gallery 交互内容越出所属父区域的问题，取代旧 Select 刻意最小内容宽度溢出规则。示例行及标题/标签换行由 `example/lib/shared/story.dart` 唯一负责，按实际容器约束布局并保留同一子树：Select 两个140px触发器及16px最小间距不变，能容纳296px时保留参考 space-between，否则换行；不裁切、不缩字或缩控件、不切换手机子树、不改锚定浮层所有者。日期范围示例服从父级可用宽度；Gallery 图片在能容纳时保持声明尺寸，受限时按自有宽高比等比收缩；Tooltip 方位图在显式横向滚动区域保留位置关系。装饰丝带/形状外延与交互控件不可达分别处理。Pagination 行布局及低于固有最小宽度时的换行契约以 `components/pagination/contract.json` 为权威，Gallery 不复制算法。这些窄屏可用性差异是已授权的参考差异，旧越界截图/测试保留为历史。验收覆盖320/360/375/390/414、正常桌面及实际容器阈值两侧，同时检查包含关系、命中/键盘、resize状态与焦点保持。



<a id="home-host-and-photo-gradient"></a>
## Home and photograph captions / 首页与照片说明

Use the official GalleryPage → Scaffold/Material host. Home has no added text-specific backplates; its page canvas, original cards and version badge remain. Text over the original Home wallpaper is a reference-priority contrast exception; do not report below-4.5 pixels as passing. Card text, actionable controls and focus retain their requirements.

Gallery photograph captions use the reference `linear-gradient(0deg, rgba(43,33,24,.72), transparent 62%)`, with no opaque caption rectangle or adaptive plateau. Only that caption region has the same reference-priority exception. Controls/focus/necessary graphics still require 3:1 and other text 4.5:1. Public Carousel slides remain opaque caller-owned Widgets.

使用正式 GalleryPage → Scaffold/Material 宿主。首页没有新增文字专用底板，保留页面底色、原卡片和版本徽标；原背景上的首页文字采用参考优先对比度例外，低于 4.5 的像素不能标为通过。卡片文字、操作控件和焦点要求保持。

Gallery 照片说明使用参考渐变 `linear-gradient(0deg, rgba(43,33,24,.72), transparent 62%)`，不添加实底矩形或自适应安全平台；仅该说明区域适用参考优先例外。控件、焦点、必要图形仍要求 3:1，其他文字 4.5:1。公共 Carousel 不检查调用方 slide Widget。

## Gallery preview painting / Gallery 预览绘制

Gallery owns viewport culling: fully clipped scene previews outside the nearest scroll viewport plus one logical pixel skip painting but retain their mounted subtree, geometry, semantics and input path. Visible scenes use the existing canvas. Other static previews use Flutter RepaintBoundary. This creates no public option, bitmap cache or second component implementation.

Gallery 负责视口裁切：场景预览完整位于最近滚动视口及 1 逻辑像素保护区之外时跳过绘制，保留同一子树、几何、语义和输入路径；可见场景继续使用既有画布，其他静态预览使用 Flutter RepaintBoundary。不新增公共选项、位图缓存或第二组件实现。

<a id="surface-sampling"></a>
### Surface sampling / 表面采样（2026-10-20）

Fractional motion must sample a complete owned backing/border/content group together. Pure translated drawing can quantize glyph pixels separately from vector edges even under one logical matrix; do not add text delays or offsets. Use the existing framework filtered Transform only where the named scene evidence validates it; this is not a blanket prescription for every moving owner. Each owning component retains its one position/scale timeline, targets, reduced-motion settlement, focus/hit testing and single child identity; shadow/color decoration can keep its separately specified interpolation. Existing SurfaceMotion composes its supplied translation/scale into one filtered matrix, remaining stateless and leaving timing/visibility to its caller. Gallery uses the same framework mechanism through public Flutter APIs, without private package imports or a new product API. Unchanged integer jumps (Upload), decorative shadow extent and nonmoving labels are distinct cases. Pixel oracles compare the Button backing alpha-edge and linear ink-mass centroids; an opaque payload inside an opaque host uses its known contrasting color-edge derivative and linear ink mass. The original0.25 tolerance is unchanged. toImage observations are output-image pixels at the declared pixelRatio, independent of OS DPR; they do not establish physical scanout. Notification and Tooltip instead round their pure translation to whole device pixels, which keeps text unfiltered and sharp while it moves; positional error is at most half a device pixel and the timeline is unchanged. Browser raw frames and Windows engine observations qualify platform behavior separately; no new60fps guarantee is inferred.

分数位移必须把所属底板、边界和内容作为完整整体一起采样。即使只有一个逻辑矩阵，直接平移绘制也可能让字形像素与矢量边界采用不同量化；不得给文字加延迟或补偿偏移。仅在具名场景证据有效时使用既有框架 filtered Transform，不向所有运动所有者机械推广；各组件仍拥有唯一位移/缩放时间线、目标、减少动态时结算、命中/焦点及单一子身份，阴影/配色装饰保留各自已规定的插值。既有无状态 SurfaceMotion 把调用方给定的位移/缩放合成一个 filtered 矩阵，不接管时序或显示条件；Gallery 通过公共 Flutter API 使用同一框架机制，不导入包内私有实现、不新增产品API。Upload 的整数跳变、装饰阴影外延和本就不移动的文字分别归类。像素测试比较Button底板alpha边缘与线性文字质量中心；位于不透明宿主内的受控内容则用已知对比色边缘导数与线性文字质量中心。原0.25门槛不变。toImage观测单位为声明pixelRatio下的输出图像像素，独立于OS DPR，不证明物理屏幕呈现；下述通知／气泡测量限制的接受不把失败数值改成PASS。浏览器原始帧及Windows引擎观察分别说明平台有效范围，不新增60fps承诺。


Surface-sampling owner coverage / 表面采样所有者覆盖：

| Existing owner | Active motion and classification |
| --- | --- |
| Notification | Reference 250ms cubic/±16px timeline retained; since 2026-11-13 the translation is rounded to whole device pixels (`snapToDevicePixels`), so backing, border and glyphs keep one pixel phase in every frame. This supersedes the 2026-10-21 accepted measurement limitation: the unchanged 0.25 oracle passes in the test host and on the Windows engine (pixel ratio 1). Slots remain opaque; leaving handles remain non-reversible. |
| Tooltip | Reference 250ms directional bubble retained with the same whole-device-pixel translation; no filter, wrapper, text compensation or timing change. The earlier filtered-transform proposal stays reverted. The 0.25 oracle passes in the test host and on the Windows engine (pixel ratio 1). AnchoredPanel itself has zero duration here. |
| AnchoredPanel | DatePicker/TimePicker pass200ms with the existing default−6px offset. Placement, focus/semantics availability, portal lifetime and curve are unchanged. Select explicitly supplies Offset.zero; Pagination uses Duration.zero. These nonmoving paths do not acquire an extra filtered layer. |
| Carousel | The active opaque slide child translates along its existing0..18px timeline. The Gallery photo/gradient/caption is one caller-owned payload; no caption inspection, added backing or opacity change. ActiveStack paints only the selected slide, so an outgoing hidden slide has no visible exit sample. Integer arrow jumps are a separate unchanged path. |

以上是既有机制的覆盖分类，非全字体／全内容／平台验收证明。针对性测试使用真实Gallery英文字体和中文字体、奇偶内容高度以及两种渲染目标比例，经原始中间帧比较相对位移。公开消费者的定位、受控状态、焦点、快速反向、减少动态及卸载回归另行检查；实际浏览器证据限制仍须原样保留。


<a id="gallery-product-version"></a>
### Gallery product version / Gallery 产品版本

The existing Home badge shows the independent root `pubspec.yaml` version through the generated `example/lib/shared/version.g.dart` projection. `tool/verify.py --generate-gallery-version` owns generation and validates equality with the Gallery pubspec; source policy rejects stale output. Do not maintain per-page version literals. Badge style and layout stay unchanged. The footer reads `MIT License · Reference Gallery` and does not repeat the reference site's copyright line (owner decision 2026-11-17); it retains Reference Gallery attribution without presenting its observed version as this product's version; the original observed version remains provenance in `docs/reference-gallery.json`.

首页现有徽标通过生成的 `example/lib/shared/version.g.dart` 展示独立项目根 `pubspec.yaml` 版本；生成及与 Gallery pubspec 的一致性由 `tool/verify.py --generate-gallery-version` 所有，源码检查拒绝过期输出。不在页面手工维护另一份版本值，不改变徽标样式或布局。页脚只写 `MIT License · Reference Gallery`，不照搬参考站的版权声明（所有者决定 2026-11-17），但不把参考观测版本当成本项目版本；原观测版本仍保留在 `docs/reference-gallery.json` 来源记录中。



<a id="original-color-restoration"></a>
## Shared color recipes / 共享配色

Change colors only at their existing owner and validate all shared consumers, composed backgrounds and interrupted states. Button busy uses a fixed component surface in both host themes, independent of global brand leaf. Customize its background/foreground/side together through existing ButtonStyle. Nested defaults use the existing surface scope; explicit child styles and unrelated ThemeExtensions remain intact.

颜色只在既有所有者修改，并验证全部共享消费者、合成背景及中断状态。Button busy 在两种主题下使用组件自有固定表面，与全局品牌 leaf 分开；通过既有 ButtonStyle 成对定制背景／前景／边框。嵌套默认值沿用既有表面作用域，显式子样式与无关 ThemeExtension 保持。

<a id="color-customization"></a>
## Component customization / 组件定制

Card, CodeBlock and Button style support and precedence are defined by their declarations and [API contracts](API.md#color-customization). Presets and custom values use one renderer and state mechanism. No automatic contrast certification is implied for caller-supplied values.

Card、CodeBlock 和 Button 的样式能力与优先级由声明和 [API 契约](API.md#color-customization)定义；预设及自定义共用唯一 renderer 和状态机制，不自动认证调用者自定义配色。

<a id="shared-accent-foreground"></a>
## Shared accent foreground / 共享强调前景

The yellow-green `onAccent` role is `#625A11`; the reference candidate `#725D42` fails the default composed ghost state. Card, filled Tag scopes, Badge and Gallery captions consume the same owner. No consumer-local correction is permitted.

黄绿 `onAccent` 为 `#625A11`；参考候选 `#725D42` 无法满足默认 ghost 合成状态。Card、填色 Tag 作用域、Badge 和 Gallery 色标读取同一所有者，不做消费者局部修正。

<a id="title-foreground"></a>
## Title foreground / 标题前景

The yellow-green Title palette's fourth role is `#69563D`. It is distinct from `onAccent` and is shared by Title variants, sizes, passive content and nested defaults through the existing renderer and surface scope. Front/back/fold colors and explicit caller styling keep their own responsibilities.

黄绿 Title 配方第四项为 `#69563D`，与 `onAccent` 是不同角色。全部 Title 变体、尺寸、被动内容及嵌套默认值通过既有 renderer 和表面作用域读取；正面／背层／折角及显式子样式各自负责。

<a id="measured-color-differences"></a>
## Measured color differences / 实测配色差异（2026-11-12）

User rule: measure each reference value on its actual composited backgrounds in the supported states and themes. Passing values, disabled controls and decorative graphics keep the reference; a failing value moves along OKLCH lightness in its own hue only until it passes (text 4.5:1, necessary graphics 3:1). Restored: Tag solid border = fill and outlined/dashed accent contours (decorative; text identifies the tag), Avatar icon ink `#2A2A2A`, Checkbox/Radio unchecked fill `rgb(247,243,223)` and `#725d42`/`#794f27` labels with the 0.15s change (default light palette), DatePicker endpoint white 1px ring, disabled Input/DatePicker/TimePicker text `#c4b89e`, Tabs selected fill `#0cc0b5` through `IslandTokens.leafSelected`, Input/DatePicker/TimePicker error `#c94444`, decorative Input bar `#d4c9b4`/hover `#c4b89e` and picker hover/focus `#c4b89e`/open `#e0b800` underlines, clear-hover glyphs `#725d42` (Select, pickers), Rate eyes `#794f27` fill under the `#dba90e` stroke, Button danger default/dashed border `#e05a5a`/active `#c94444`, Skeleton loaded text `#725d42`. Reference recipes apply on the default light palette and on light Card papers that their owner declares (`LightSurfaceScope.referencePaper`: pattern and neutral Cards without caller backgrounds); accent fills, dark and customized palettes keep their token roles. A ring or boundary drawn around the control's own opaque fill is measured against that fill. Authorized deepened differences, each at its owner token:

用户规则：在支持的状态与主题下按实际合成背景测量参考值。达标值、禁用控件和装饰图形恢复参考；不达标值只沿自身色相的 OKLCH 明度移动至刚好达标（文字 4.5:1，必要图形 3:1）。已恢复：Tag 实心边框同填色、描边/虚线色相轮廓（装饰，文字识别标签）、Avatar 图标墨色 `#2A2A2A`、Checkbox/Radio 未选填色与 `#725d42`/`#794f27` 标签及 0.15s 变色（默认浅色配色）、DatePicker 端点白色 1px 圈、禁用 Input/DatePicker/TimePicker 文字 `#c4b89e`、Tabs 选中填色 `#0cc0b5`（经 `IslandTokens.leafSelected`）、输入框与日期/时间选择器错误色 `#c94444`、装饰状态条与下划线参考色、清除悬停 `#725d42`、评分眼睛、危险按钮默认/虚线边框、骨架屏加载完成文字 `#725d42`。参考配方适用于默认浅色配色及所有者声明的浅色 Card 纸面（`referencePaper`：图案与中性 Card 且无调用方背景）；强调色、深色和自定义配色沿用令牌角色。围绕控件自身不透明填色的圈或边界以该填色测量。以下为授权加深差异及其所有者令牌：

| Owner / 所有者 | Reference → product / 参考 → 产品 |
| --- | --- |
| Tag outlined/dashed text (`colorway.dart` `outlineInk`) / 描边、虚线标签文字 | per-hue accent (1.1–3.7:1 on light papers) → same-hue 4.5:1 light set, e.g. pink `#f8a6b2`→`#9d5461`; dark papers keep passing accents, others lighten (neutral `#b89b75`, purple `#c086f8`, red `#fe756f`, brown `#b49d73`) / 浅色纸面逐色加深，深色纸面达标保留、其余提亮 |
| Badge dot (`colorway.dart` `dotFill`) / 徽标圆点 | accent (1.2–2.6:1) → same-hue 3:1 fill, e.g. red `#e7605c`; cream ring only when attached, as reference / 同色相 3:1 填色，仅附着时奶油圈 |
| Progress fill edge (`ProgressColors.fillEdge`) / 进度填充边 | none; `#19c8b9` is 1.9:1 on the track → 2px `#039d91` beside the reference inset highlight: the edge keeps the fill's outer 2px and the 2px highlight sits inside it, as a CSS inset shadow sits inside a border, so the mid-bar column reads edge, highlight (`#93e7df` in the reference), gradient / 填充仅 1.9:1，加同色相 2px 边；内高光位于边内侧 |
| Rate selected stroke (`RateColors.selectedStroke`) / 评分选中描边 | `#dba90e` kept on dark paper (5.5:1); 1.9:1 on light → `#af8600` / 深色保留，浅色加深 |
| Switch unchecked boundary (`SwitchColors.trackOffBorder`, busy base `SwitchColors.busyBase`) / 开关未选边框 | `#c4b89e` (1.8:1) → `#978b73`; busy dims only track/thumb over a `#f8f8f0` base, text stays opaque (reference .7 group opacity gives 3.97:1, 4.42:1 on dark) / busy 仅淡化轨道与滑块，文字不透明 |
| Switch thumb and spinner (`SwitchColors.thumbBorderOff`/`thumbBorderOn`, `spinnerOff`/`spinnerOn`) / 开关滑块与加载圈 | thumb `#c4b89e` / checked `#6fba2c` (1.8/2.2:1 on the `#f7f3df` thumb) → `#978b73` / `#579d00`; spinner `#a89878` / `#6fba2c` over the busy 0.7 thumb → `#716244` / `#3d7200`. The checked track border stays onLeaf / 滑块边框与加载圈逐色加深 |
| Checkbox/Radio rings and mark (`ChoiceColors.ringUnchecked`/`ringChecked`/`mark`) / 复选、单选圈与勾 | unchecked `#c4b89e` → `#978b73` (3.0:1 on its `#f7f3df` fill); checked `#50b9ab` (2.1:1) → `#259689`, 3:1 on every light paper and Card pattern paper; the mark keeps the reference white (2.1:1 on `#19c8b9`) as a user-authorized exception (2026-11-16): the filled box/disc already states the checked value, so the mark is not the only cue / 圈同色相加深；勾保持参考白色，属用户授权例外（填充已表达选中状态） |
| Status warning (`InputColors.warning`, `PickerColors.triggerUnderline`) / 警告状态 | `#dba90e` (2.2:1) → the Rate value `#af8600`, 3.3:1 on the Input fill and 3.2:1 on the picker `#fffbe7` fill / 复用评分加深值 |
| Rate unselected stroke (`RateColors.idleStroke`) / 评分未选描边 | `#c4b89e` kept on dark paper (6.0:1); 1.8:1 on light → `#978b73` / 深色保留，浅色加深 |
| Button danger hover border (`ButtonColors.dangerBoundary`) / 危险按钮悬停边框 | `#e87878` (2.7:1 on the button fill) → `#dd6e6f` / 同色相加深 |
| TimePicker/DatePicker confirm hover (`PickerColors.confirmHover`) / 确认按钮悬停 | TimePicker `#8a7b66` gives white text 4.1:1 → the DatePicker reference `#796c5a` / 采用日期选择器参考值 |
| Collapse card border (`IslandTokens.outline` in `collapse.dart`) / 折叠面板边框 | `#dcd8d1` (1.4:1 on white) → `outline` `#8F8474` / 采用 outline |
| Gallery BackTop code chip (`GalleryPalette.backTopCodeInk`) / 示例代码块 | inherited `#9f927d` (2.6:1 on `#f0e8d8`) → `#746753` / 加深至 4.5:1 |
| Input boundary (`IslandTokens.outline` in `inputs.dart`) / 输入框边界 | no border; `#fffdf7` fill and `#d4c9b4` shadow are 1.1–1.6:1 on paper/card → existing 1px `outline` kept / 填色与阴影不足 3:1，保留 1px 边框 |
| Image stamp year (`ImageColors.stampYearBacking`) / 邮票年份 | white .88 + shadow over an unknown photo → same text on `rgba(0,0,0,.58)` glyph backing, the least alpha with 4.5:1 over any pixel / 照片未知，按最小透明度加黑色字底 |
| Gallery Modal `石头` (`GalleryPalette.modalEmphasis`) / 示例强调色 | demo `#FD9303` (2.0:1) → `#a45d01` / 示例内联色加深 |
| Gallery Background tiles (`GalleryPalette.backgroundTileInks`) / 背景示例块 | sprinkles/scenes drop text to 3.0–4.2:1 → glyph backing in the tile base `#fdf3e3`; 0.85 subtitles measure 3.6–4.3:1 → opaque / 图案处字底改为块底色；副标题保持不透明 |
| Time clock ink (`TimeColors.digits`, `TimeColors.gameText`) / Time 时钟墨色 | `#8b7355` 4.0–4.5:1 on light papers, the `#f8f8f0` card and the `#fffbe7` weekday capsule → `#836b4e` (4.5:1 on `#f7f3df`); the game clock and month-day on dark papers (2.7–3.3:1) → `#b59c7c` / 浅色纸面、卡片与星期胶囊加深；游戏 HUD 在深色纸面提亮 |
| Countdown default reminders (`NumberColors.reminderWarm`/`reminderUrgent`) / 倒计时默认提醒色 | `#c77c34` 3.0–3.3:1 → `#a55d05`; `#e05a5a` 3.3–3.6:1 → `#c44043`, 4.5:1 on the plate tops, `#f8f8f0` and the island `#f7f3df` surface; bordered plates follow / 同色相加深，描边随之 |
| Gallery Countdown demo reminders (`GalleryPalette.countdownReminderBerry`/`Brown`) / 示例提醒色 | demo `#b25770` / `#9a6a38` 4.2:1 → `#ac526b` / `#946533` / 示例内联色加深 |
| Upload background size text (`UploadColors.backgroundSizeText`) / 背景进度文件大小 | muted size ink 4.1–4.3:1 on the .28 fill (rest/hover) → `#6c6251` / 同色相加深 |
| Upload background fill edge (`UploadColors.backgroundFillEdge`) / 背景进度填充边 | without the percentage the .28 fill is the only cue at 1.2:1 → 2px `#008e81` end edge, 3:1 on the row, its hover tint and the card mask over any pixel; not drawn beside the percentage or for a caller `color` / 无百分比时加同色相 2px 末端边 |
| Upload card overlay (`UploadColors.cardOverlay`, `cardPercent`) / 卡片遮罩 | reference white bar-mode percentage restored; rgba(15,12,8,.55) gives 4.3:1 over a white pixel → .565, the least alpha with 4.5:1 over any pixel (Image stamp precedent) / 恢复参考白色百分比，遮罩取 4.5:1 最小透明度 |
| Calendar panel (`IslandTokens.light` `muted`/`link`/`onLeaf`/`focus`) / 日历面板 | weekday `#a09080` (2.8–3.0:1) and neighbouring-month digits `#c4b89e` (1.7–1.9:1) → `muted`; today digit and ring `#19c8b9` (1.8–2.1:1), +N → `link`; white selected digit (2.1:1) → `onLeaf`; focus ring → `focus`, as DatePicker / 与 DatePicker 同角色 |
| Calendar header (`CalendarColors.arrow`/`arrowHover`/`headerFocus`/`todayAction`/`todayActionHover`) / 日历头部 | on the host paper: arrows `#a0936e`, hover and focus `#19c8b9` kept on dark papers; on light papers (1.7–3.0:1) → `muted`/`link`/`focus`; 今天 `#8a7b66` (3.7–4.1:1 light) → `muted`, (2.9:1 dark) → `#ad9e88`; hover `#725d42` kept on light, 1.8:1 dark → `#b8a184` / 深色纸面保留达标参考值，浅色取 DatePicker 角色 |
| Calendar event text (`CalendarColors.eventTime`, `CalendarColors.teal.ink`) / 日程文字 | time `#9f927d` 2.5–2.8:1 on the five fills → `#746753` (the BackTop value); warm-orange title `#b04a1f` 4.48:1 on `#ffe4cc` → `#af4a1e` / 同色相加深 |
| NoData description (`NoDataColors.description`) / 空状态说明文字 | `#9f927d` 2.7–3.1:1 on the light papers → `#7a6d59`, 4.5:1 on every light paper; dark papers use `muted` / 同色相加深 |
| Chart secondary text (`ChartColors.secondaryInk`) / 图表次要文字 | description, axis text, ring centre, loading and notes `#9f927d` 2.9:1 on `#f8f8f0` → `#7d705c` (light); dark uses the dark product role `#b7c6b5` / 同色相加深 |
| Chart focus outline (`ChartColors.focus`) / 图表焦点轮廓 | primary `#19c8b9` 2.0:1 on the light surface → `#04a195`; dark keeps `#19c8b9` / 同色相加深 |
| Chart hidden legend label (`ChartColors.legendHiddenInk`) / 已隐藏图例文字 | the reference halves the whole pill, text 2.2:1 → the pill keeps its half opacity and the label takes the opaque `#7f6a51` / 胶囊保持半透明，文字不透明 |
| Chart rising candle (`ChartColors.candleRise`) / 上涨蜡烛 | coral `#dc7367` 2.94:1 on the light surface → `#da7166`; dark keeps the reference; the falling mint `#3b9d85` passes and is kept / 浅色加深，深色保留 |
| Chart default series, light (`ChartColors.series`) / 图表默认系列色（浅色） | seven of the eight below 3:1 on `#f8f8f0`: mint `#19b7a7`, peach `#e59266`, green `#8ac68a`, purple `#b38ad3`, yellow `#e4b84f`, blue `#7e9fc4`, pink `#dc8c9e` → `#03a193`, `#cc7b50`, `#639d64`, `#a87fc8`, `#b4890c`, `#7292b7`, `#c7798b`; brown `#9a835a` passes and is kept; dark keeps all eight (3.2:1 or more) / 七个同色相加深至 3:1，棕色与深色保留 |
| Chart gauge needle, dark (`ChartColors.needle`) / 仪表盘指针（深色） | `#725d42` 1.9:1 on the dark surface → `#937d61`; light keeps the reference / 深色提亮 |
| Gallery chart demo series (`GalleryPalette.chartMeadow`/`chartSunset`/`chartForest`/`chartFlowers`/`chartHoney`) / 示例图表系列色 | reference sets meadow `#48a891 #97bc76 #e4b75c #ce9271 #aa91ba`, sunset `#dc886b #e4b75c #c993a5 #ab8cba #8dab9b`, forest `#408f7c #68a18b #8fb6a0 #b3cbb4 #d2dfc8`, flowers `#a88abb #d38ba3 #e9b782 #92b7a0 #c1b979` measure 1.3–2.9:1 → each value moves in its own hue until it reaches 3:1 on the default, cream, mint and blossom chart surfaces (`#408f7c` passes and is kept; honey `#e4b75c` → `#b38827`); the deepened forest values are kept by the [2026-11-18 owner decision](#owner-decisions-2026-11-18) / 逐色加深至四种图表底板 3:1 |
| Gallery chart ring remainder and note (`GalleryPalette.chartRingRemainder`, `chartNote`) / 示例环形余量与注释 | 待完成 sector `#e4dcc9` 1.3:1 → `#968e7d`; `.note` `#8a7b66` 4.1:1 → `#837460` / 同色相加深 |
| Icon eye-off slash (importer `REPAIRS`, `import_v1_14.repairs`) / 眼睛关闭斜线 | upstream `#E76F51` over the cream body `#FAEDCD` is 2.66:1 → clip split: `currentColor` outside the eye, `#E05A5A` inside the cream body (3.12:1 on `#FAEDCD`); upstream `#E76F51` kept over the iris, where it passes (3.26:1 on `#264653`, 4.64:1 on `#2A2A2A`, 3.09:1 on `#FFFFFF`) / 裁切分段：眼外继承 `currentColor`，奶油色眼体内 `#E05A5A`，达标的虹膜上保留参考 `#E76F51` |
| Icon red negation slashes (importer owner rule O6, `import_v1_14.settled`) / 图标红色否定斜线 | upstream `#E76F51` in cloud-off, location-off, mic-off, phone-off and video-off is 2.90:1 on light paper `#F8F8F0` → `#E46C4F`, the first 8-bit colour along OKLCH lightness (hue and chroma fixed, no sRGB clipping needed) that reaches 3:1 there (3.00:1); dark paper 3.84 → 3.71:1, dark canvas 4.82 → 4.65:1. The light canvas `#88C9A1` stays under 3:1 (1.61 → 1.66:1): no fixed colour reaches 3:1 on both it and the dark paper `#243C33`. Where the slash crosses its own body paint it stays under 3:1, and the bodies are kept: `#FAEDCD` 2.66 → 2.75:1 (cloud-off, location-off), `#2A9D8F` 1.07 → 1.04:1 (location-off), `#588157` 1.45 → 1.40:1 (phone-off); over `#264653` it still passes, 3.26 → 3.15:1 (mic-off, video-off) / 保留色相，沿 OKLCH 明度加深至浅色纸面恰好 3:1；浅色画布仍低于 3:1（固定颜色无法同时在浅色画布与深色纸面上达到 3:1），与自身图形相交处未改 |
| Icon pale host strokes (importer owner rule O1) / 图标浅色宿主描边 | eight explicit `#FAEDCD` strokes that reach the host in six glyphs (bucket, chicken, humidifier, rice, shirt, shredder) → `currentColor`; they read visibly darker than upstream, as the earlier coffee-steam repair / 八处浅奶油色宿主描边改为 `currentColor`，明显深于上游 |
| Gallery Time custom demo date ink (`GalleryPalette.timeCustomDate`) / 示例 Time 自定义日期墨色 | demo `#9f927d` (4.46:1 on the capsule `#3d2a17`) → `#a0937e` (4.5:1) / 同色相提亮至 4.5:1 |
| Gallery Time custom demo gradient (`GalleryPalette.timeCustomGradientMiddle`) / 示例 Time 自定义渐变中间色 | 55% stop `#137f74` → `#00756a`: the cream clock ink `#fffdf4` measures 4.10:1 at the lightest gradient point under it and cannot lighten further, so the backing moves (Upload overlay precedent); the value is measured at the reference capsule height (4.54:1) / 时钟墨色已无法再提亮，改为加深底板；按参考胶囊高度测量（4.54:1） |
| Cursor selection highlight (`CursorColors.selection`, `Primitive.yellow431`) / Cursor 选区高亮 | light keeps the reference `#e9c46a` (the muted ink `#736857` reads 3.27:1 on it, an owner-accepted difference); dark → the same-hue `#654c01`, on which the dark ink is 7.2:1 and the muted ink 4.5:1; the highlight itself is then only 1.5:1 from the dark paper `#243c33` and 1.8:1 from the dark canvas `#172b26`, a stated trade-off / 浅色保留参考值；深色同色相加深使文字达标，高亮与深色纸面仅差 1.5–1.8:1 |
| Progress track border (`ProgressColors.trackBorder`) / 进度条轨道边框 | `@track-border` `#e2d6bd` 1.35:1 on the `#f8f8f0` track → `#9a8e77`, 3.0:1 on the track and 3.2:1 on white; the boundary alone shows the track extent / 同色相加深至 3:1 |
| Upload row action hover icons (`UploadColors.previewHoverIcon`, `removeHoverIcon`) / 上传行操作悬停图标 | preview `#19c8b9` (1.3–1.7:1) → `#007e72`; remove `#e05a5a` (2.2–3.0:1) → `#c64245`; 3:1 or more on the hovered row, the error row and the background fill under the reference .08 black wash / 同色相加深，覆盖悬停行、错误行与背景进度填充 |
| Upload card remove button (`UploadColors.cardAction`) / 上传卡片删除按钮 | white close on a transparent ground (1:1 over a white pixel) → the reference preview disc rgba(0,0,0,.45), on which the white icon is 3.36:1 or more over any thumbnail pixel / 采用参考预览按钮的半透明黑色圆底 |
| Countdown digits (`NumberColors.digits`) / 倒计时数字 | `#8b7355` 4.03–4.49:1 on the plates and surfaces → `#836b4e` (4.51–5.03:1), the Time clock ink / 同色相加深，与 Time 时钟墨色相同 |
| Table loading spinner (`TableColors.spinner`) / 表格加载圈 | `#19c8b9` 1.88:1 on `#f7f3df` → `#039d91` (3.02:1), the registered Progress edge value / 复用 Progress 边的加深值 |
| Drawer close glyph (`DrawerColors.close`) / 抽屉关闭符号 | rgba(114,93,66,.6), `#a79981` on the panel (2.51:1) → `#988b73` (3.00:1); the hover `#725d42` is kept / 静止态加深，悬停态保留参考值 |
| Gallery Typewriter third line (`GalleryPalette.typewriterEmphasis`) / 示例 Typewriter 第三行 | demo `#FD9303` (2.1:1 on the `#faf8f2` dashed demo box) → `#aa6000` (4.51:1), same hue / 示例内联色加深 |
| Gallery Form live values line (`GalleryPalette.formLiveValues`) / 示例 Form 实时值 | demo `#5b8def` (2.90:1 on the orange pattern card `#fff0e8`, 2.57:1 over its dot `#fadfd1`) → `#3361c7` (5.14:1 / 4.50:1), same hue / 同色相加深 |
| Gallery sidebar group labels (`GalleryPalette.navGroupInk`) / 侧边栏分组标题 | `#a0936e` (2.9:1 on the aside `#faf8f3`, 1.4:1 on the `#a2b0e7` wave) → `#504422` (9.0:1 / 4.5:1); measured on the wave, kept by the [2026-11-18 owner decision](#owner-decisions-2026-11-18) / 以波浪底色测量，所有者 2026-11-18 确认保留 |
| Gallery sidebar items (`GalleryPalette.navInk`) / 侧边栏条目 | `#8a7b66` (3.9:1 aside, 3.1:1 on the `#d6dff0` hover, 1.9:1 wave) → `#514330` (9.0:1 / 7.1:1 / 4.5:1); measured on the wave, kept by the [2026-11-18 owner decision](#owner-decisions-2026-11-18) / 以波浪底色测量，所有者 2026-11-18 确认保留 |
| Gallery sidebar active item (`GalleryPalette.navActiveInk`) / 侧边栏选中条目 | white (1.7:1 on `#b7c6e5`) → `#525252` (4.55:1), moved along lightness only; kept by the [2026-11-18 owner decision](#owner-decisions-2026-11-18) / 仅沿明度移动，所有者 2026-11-18 确认保留 |
| Gallery component page description (`GalleryPalette.pageDescription`) / 组件页说明文字 | `#794f27` (3.7:1 on `#88c9a1`, 3.05:1 over a wallpaper dot) → `#5e360b` (5.4:1 / 4.5:1) over any wallpaper pixel / 同色相加深 |
| Gallery Icon demo bulb (`GalleryPalette.iconDemoBulb`) / 示例 Icon 灯泡 | `#e9c46a` (1.7:1 on white) → `#b49033` (3.0:1) / 同色相加深至 3:1 |
| Gallery Icon tile caption (`GalleryPalette.iconTileName`) / 示例 Icon 名称 | `#a0936e` (3.0:1 on white, 2.8:1 on the `#faf7f0` hover) → `#7e714e` (4.8:1 / 4.5:1) / 同色相加深 |
| Gallery Chart header and catalog body (`GalleryPalette.chartGalleryBody`, `chartCatalogBody`) / 示例图表页说明 | `#9f927d` (3.05:1 on white; 2.86:1 on `#f8f8f0` and 2.76:1 on the `#f0f5eb` hover) → `#827561` (4.50:1 on white) and `#7a6e5a` (4.68:1 / 4.51:1) / 同色相加深 |
| Gallery Chart item link (`GalleryPalette.chartActionInk`) / 示例图表条目链接 | `#9f927d` (3.05:1 on white, 2.51:1 on the `#f0e8d8` hover) → `#746753` (5.52:1 / 4.53:1), the BackTop chip value / 采用 BackTop 代码块的值 |

Transparent per-hue Tag text is validated on the product papers; caller-filled or accent surfaces need a filled variant or an explicit style. 透明 Tag 色相文字仅在产品纸面验证，强调色或调用方表面请用填色变体或显式样式。

Kept from the 4.0.0 upgrade: the Upload background percentage `#794f27` (4.6:1 or more), the Calendar selected disc `#19c8b9` with its `#e6f9f6` cell tint (selection fill, as DatePicker and Tabs), the decorative month icon, event borders and Time rule, and the passing Calendar day inks. A caller `color` on Progress or Upload progress stays authoritative (explicit caller styles win): the library draws no same-hue edge for it, and the Gallery passes public colorway accents beside the shown percentage. 4.0.0 升级保留：Upload 背景百分比、Calendar 选中圆与格底（选中填色，同 DatePicker、Tabs）、装饰月份图标、日程边框、Time 分割线及达标日期墨色。Progress 与 Upload 的调用方 `color` 由调用方负责，库不为其加边；Gallery 使用公开色相并显示百分比。

Kept from the 4.0.0 chart and NoData ports: the NoData title `#794f27`, bordered fill `#f8f8f0` and decorative dashed outline `#e8e2d6`; the Chart light surface, ink, border, grid, zero line, crosshair, legend pill fills, separators `#fffdf7`, gauge track `#eae2ce`, gauge ticks `#b6a184`, empty map regions, the falling candle and the Gallery chart surfaces and borders (decorative or passing); and every caller-supplied series, point, `backgroundColor` and `borderColor`, which stay the caller's responsibility. NoData 的标题、描边底色与装饰性虚线轮廓，Chart 浅色的底板、墨色、边框、网格、零线、十字线、图例底色、分隔线、仪表盘轨道与刻度、无数据地图区域、下跌蜡烛及 Gallery 图表底板边框（装饰或达标）保留参考值；调用方传入的系列色、点色、`backgroundColor`、`borderColor` 由调用方负责。

Kept from the 4.0.0 page comparison: the CodeBlock selected-text ink `#2b2620` on the `#e9c46a` Cursor highlight (`CodeBlockColors.selectedInk`, 8.97:1), the Progress percentage ink `#725d42` (`ProgressColors.info`, 5.9:1 or more on the light papers) under the reference palette, while dark or customized token sets keep their `ink` role; the Gallery shell header and mobile header ink `#725d42` (`GalleryPalette.shellInk`), the Home card title `#725d42` and description `#7c5734`, the chart gallery summary `#794f27`, the API table required mark `#f0a870` (7.9:1 on `#2b2118`), and the decorative Time `·` `#c4b89e`, the Chart plot scrollbar thumb `#c4b89e` (`ChartColors.scrollbar`, light theme) and Loading sailboat water line `#2a9d8f` (`LoadingColors.water`). 4.0.0 页面对比保留：Progress 百分比墨色 `#725d42`（参考配色下；深色或自定义配色沿用 `ink` 角色）、Gallery 外壳与移动端标题墨色、首页卡片标题与说明、图表示例页摘要、API 表必填标记，以及装饰性的 Time 中点、Chart 滚动条滑块与 Loading 帆船水线，均沿用参考值。

<a id="time-colon-blink"></a>
The Time colon is a decorative separator: it blinks on the reference 1s step-end cycle, the clock value stays complete in semantics, digits never dim and reduced motion keeps it visible. Time 冒号是装饰分隔符，按参考 1s step-end 闪烁；语义值完整、数字不变暗，减少动态时常亮。

<a id="owner-decisions-2026-11-16"></a>
## Owner decisions / 所有者决定（2026-11-16）

| Item | Decision | Reason |
|---|---|---|
| Flame icon outline inside a coloured Tag / 彩色 Tag 内火焰轮廓 | Keeps following the Tag colour; differs from the reference fixed dark outline | Stays visible on light and dark hosts; the icon contrast oracle is unchanged |
| Modal and Image preview entrance / 弹层入场 | One shared dialog route and entrance; differs slightly from the two reference entrances | One mechanism, no per-consumer parameter |
| Tabs active dot / Tabs 选中圆点 | Follows the pinned 2.2.1 source: the dot inherits the active label colour | The live site (3.0.4) is outside this round's scope |

<a id="owner-decisions-2026-11-17"></a>
## Owner decisions / 所有者决定（2026-11-17）

| Item | Decision | Reason |
|---|---|---|
| Icon paint roles (709 glyphs) / 图标配色角色 | Apply the previous round's majority dispositions in bulk as importer rules: O1 coloured host stroke → `currentColor` (unless the colour is the meaning), O2 fixed `#2A2A2A` host stroke → `currentColor`, O3 inherited interior stroke → fixed ink `#2A2A2A` only where it keeps 3:1 on every own backing, O4 fixed-silhouette contours follow `currentColor`, O5 interior detail under 3:1 on its own backing keeps upstream paint as decorative. 20 roles stayed held until the [2026-11-18 decision](#owner-decisions-2026-11-18) | The earlier round chose these dispositions for most elements (148 of 167, 57 of 64, 28 of 32); the importer re-measures its output and aborts if a rule fails, and a held item never changes paint |
| Cursor selection highlight / Cursor 选区高亮 | Light theme keeps the reference `#e9c46a`; the dark theme has its own same-hue `#654c01` | Dark-theme text inks reach 4.5:1; the light muted ink at 3.27:1 is accepted; the dark highlight is only 1.5–1.8:1 from the dark papers, a stated trade-off |
| Time style / Time 自定义样式 | `IslandTime.style` takes an `IslandTimeStyle`; the Gallery reproduces the reference `.my-time` demo with two measured differences ([table](#measured-color-differences)) | One instance API restyles both variants; caller colours stay caller-owned |
| Home footer / 首页页脚 | States the licence and attribution only: `MIT License · Reference Gallery` | See [Gallery product version](#gallery-product-version) |

<a id="owner-decisions-2026-11-18"></a>
## Owner decisions / 所有者决定（2026-11-18）

| Item | Decision | Reason |
|---|---|---|
| Icon red negation slashes (5 glyphs) / 图标红色否定斜线（5 个图标） | Importer rule O6: cloud-off, location-off, mic-off, phone-off and video-off keep the slash hue and move along OKLCH lightness to the least change that reaches 3:1 on light paper, `#E76F51` → `#E46C4F` ([table](#measured-color-differences)) | The measured-colour rule. The light-canvas shortfall (1.66:1) and the crossings of the slash over its own body paint are recorded, not solved; the importer stops if the deepened colour misses 3:1 on light paper, dark paper or dark canvas |
| Icon paint roles kept (15 glyphs) / 图标保留上游配色的角色（15 个图标） | Importer rule O7: the eleven inherited interior strokes where fixed ink would fail 3:1 (air-fryer, cat mouth, peacock, picture-in-picture, police-station, projector, smartwatch, speaker, train-station, waffle, wallet) and the four coloured-fill silhouettes (barcode, bolt, grip, sparkles) keep upstream paint | No asset change; they are no longer pending. Each keeps its measurement in `import_v1_14.settled`; the host-contour matrix still lists the four silhouettes outside it, and no contrast matrix certifies these roles |
| Primary Button border / 主按钮边框 | Follows the reference: `.btn-primary` and `.btn-danger.btn-primary` set `border-color` to the fill in every state (rest, hover, active; disabled only adds opacity .5), so the primary and danger primary borders take the resolved fill colour; the 2px border keeps its space and the bottom depth shadow carries the shape. The dark theme has no reference and keeps the same principle (border equals the dark primary fill). Ghost, busy and the default, dashed, text and link variants keep their borders; the focus ring is unchanged / 跟随参考：主按钮与危险主按钮边框取填充色，2px 宽度仍占位，形状由底部阴影表达；深色主题沿用同一原则；幽灵、加载与其他变体不变 | Owner decision. Recorded measurement: the `#f8f8f0` border is 1.0–1.07:1 on the light papers (`#f8f8f0`, `#fffdf7`, `#f7f3df`, white) and 1.8:1 on the `#88c9a1` canvas, where the previous `#8f8474` outline was 3.3–3.7:1 and 1.9:1; the `#bdaea0` depth shadow below is 1.9–2.2:1 on the light papers and 1.1:1 on the canvas. No contrast guard covers this boundary; necessary-graphics 3:1 is not claimed for it |
| CodeBlock shell comments / CodeBlock shell 注释 | `//` comments italic at weight 400, colour unchanged, as reference `highlightShell`. `#` comments stay upright, as on the reference Skill page; Dart and JavaScript comments stay upright, as reference `highlightJSX` sets no italic / shell 的 `//` 注释斜体、字重 400，颜色不变；`#` 注释与 Dart、JavaScript 注释保持正体（同参考 Skill 页与 JSX 高亮） | Owner decision. The bundled Fira Code has no italic face, so the engine slants the upright face; pitch and the 1.7 line box are unchanged. Narrowed on 2026-11-19 from every shell comment to `//`, which removes the italic `#` comments the Gallery Skill page showed against the reference |
| Icon paint outcomes / 图标配色结果 | Accepted as shown in the Gallery: the outcomes of R1, role carry, O1–O7 and the eye-off split stay as imported, including role-carried decisions on redrawn geometry / 按 Gallery 现状接受：R1、角色沿用、O1–O7 与 eye-off 拆分的结果保持导入时的样子 | Owner decision 2026-11-19. The outcomes are measured by the importer and the contrast tests; the owner accepted the set as a whole, not glyph by glyph, and a single glyph can still be reopened by name |
| Gallery sidebar menu inks / Gallery 侧边栏墨色 | Keep the deepened `navGroupInk` `#504422`, `navInk` `#514330` and `navActiveInk` `#525252` ([table](#measured-color-differences)) | The measured-colour rule, confirmed: measured on the `#a2b0e7` wave the list scrolls over |
| Progress fill edge / 进度填充边 | Keep the registered 2px `ProgressColors.fillEdge` with the reference highlight inside it ([table](#measured-color-differences)) | The measured-colour rule, confirmed |
| Loading circle reveal, input and first paint / Loading 圆形揭示、输入与首帧 | Kept: the reveal removes the centred tip first (reference behaviour); input stays blocked until the surface is removed (deliberate difference, the reference lets pointer events through while the circle opens); the mask first paints one frame after it is requested, because the shared `ViewportOverlay` inserts its entry after the frame / 保留：揭示先移除提示（同参考）；移除前持续拦截输入（有意差异）；首次绘制晚一帧 | Current behaviour accepted |
| NoData and Search artwork on dark papers / 暗色纸面上的 NoData 与 Search 插图 | Kept: the built-in box and magnifier keep their fixed `#2a2a2a` ink in every theme (about 1.04–1.21:1 on dark papers; decorative and excluded from semantics); the dark bordered outline and fill use `tokens.outline` and `tokens.paper` / 保留：内置插图在各主题保持固定墨色；深色描边与填充用 `tokens.outline`、`tokens.paper` | Reference artwork kept; the dark outline is this library's own choice, as the reference has no dark theme |
| Gallery chart forest ramp / Gallery 图表 forest 渐变 | Keep the deepened `#408f7c #629a85 #719782 #7e947f #87927d` ([table](#measured-color-differences)) | The measured-colour rule, confirmed, although the deepened ramp is nearly flat |
| Chart arc end cap and map low values / 圆弧端帽与地图低值 | Keep the reference geometry: the arcbar and gauge value arc stays about 2.5:1 against its `#eae2ce` track at the end cap, and choropleth low values (fill opacity from 0.3) stay under 3:1 on the surface | Each reading is also in the tooltip and the data table |
| Caller-owned line boxes (Upload tip, NoData title and description) / 调用方文本行高 | The library does not force line boxes on caller-owned slot widgets; the Gallery Upload and NoData stories pass `StoryText`, so the Gallery's own text gets the CSS line box ([difference row](#behaviour-differences-400)) / 库不强制调用方插槽的行高；Gallery 故事改用 `StoryText` 以获得 CSS 行高 | Measured on a Windows-engine capture at 1440 (2026-11-18): section positions on the Upload page and the NoData title match the reference; the Upload tip and the NoData description were 1px low, without accumulating. Traced on 2026-11-19 to the baseline, not the line box: Blink puts it at the primary font's rounded ascent plus the floored ascent half of the leading over the rounded ascent and descent (Upload tip 12px / 1.6: 12 + floor(1.59) = 13; NoData description 13px / 1.8: 13 + floor(2.70) = 15), where Flutter split the leading evenly over fractional metrics (13.64 and 15.98). `StoryText` now uses the Blink baseline and paints wrapped lines at the fractional CSS pitch; host widget tests assert the geometry, a Windows-engine comparison with the reference is still owed / 1440 宽度 Windows 引擎截图实测：Upload 提示行与 NoData 描述曾低 1px；2026-11-19 查明为基线位置差异，`StoryText` 已按 Blink 规则放置基线并按 CSS 行距绘制折行，尚待 Windows 引擎截图复核 |

<a id="owner-decisions-2026-11-19"></a>
## Owner decisions / 所有者决定（2026-11-19）

| Item | Decision | Reason |
|---|---|---|
| Built-in copy / 内置文案 | Localized in Chinese and English through `IslandLocalizations`; parameters that defaulted to Chinese are nullable and null means the localized default. Chinese equals the reference / 中英文本地化，中文与参考一致 | An English app no longer shows Chinese defaults |
| Drawer in right-to-left text / Drawer 的从右到左 | Body aligns to the start and footer to the end of the text direction; `placement` stays physical as in the reference / 正文与页脚跟随文字方向 | The reference footer follows the direction; ours was fixed |
| Avatar content / Avatar 内容 | Keep scaling the content down to fit; the reference scale code never takes effect and clips oversized content / 保持缩小适配 | Clipped initials or icons are unreadable |
| Table row hover shape / Table 行悬停形状 | Keep the declared 30px rounded fill ([table](#behaviour-differences-400)) / 保持 30px 圆角 | The declared design, consistent with the rounded shapes of the theme |
| Cursor demo raindrop zone / Cursor 示例雨滴区域 | Keep the raindrop over the section ([table](#behaviour-differences-400)) / 保持雨滴 | The demo exists to show that cursor; the live arrow is a selector side effect |
| Focus indicator colours / 焦点指示颜色 | Keep the single `focus` role per theme ([table](#behaviour-differences-400)) / 保持统一的 focus 角色 | Reference yellow and the browser default ring fall under 3:1 on light surfaces |
| Chart tooltip builder width / 图表提示框自定义内容宽度 | Decided 2026-11-20: builder content wider than the 260px panel widens it up to min(400, viewport − 16) and wraps beyond; the default content keeps 260 / 自定义内容可把提示框撑宽到 400，超出换行 | The reference keeps 260 and scrolls horizontally, but a tooltip that follows the pointer cannot be scrolled |
| Oversized Notification icon and Badge content / 超大通知图标与徽标内容 | Decided 2026-11-20: keep them constrained to their box; Badge numbers above `overflowCount` (99) read `99+` as in the reference / 保持限制在框内，数字超过上限显示 99+ | The reference overflow covers neighbouring content |
| Form error text / Form 错误文字 | Keep the theme `dangerText`; the reference `#ff4d4f` is 3.3:1 on white, under the 4.5:1 text rule / 保持达标的 dangerText | The [measured colour rule](#measured-color-differences) |

<a id="behaviour-differences-400"></a>
## Deliberate behaviour differences (4.0.0 components) / 有意行为差异（4.0.0 新组件）

| Item | Reference | This library |
|---|---|---|
| Calendar pointer cancel / Calendar 指针取消 | The root `onPointerCancel` finishes the drag and creates the event | A cancelled pointer (the system aborted the gesture) commits nothing, as Flutter reports it as a cancel and never as a release; a release outside the panel also discards the drag / 取消不创建事件，面板外松开同样丢弃 |
| Calendar header on narrow widths / Calendar 窄屏头部 | The header is a space-between flex row of three groups with no wrapping: an overflowing row shrinks the month chip and the 今天 group to their min-content widths and their text wraps (`2026` / `年8月`, `今` / `天`), and below the summed min-content widths it overflows | The same shrinking and text wrapping; only below the summed min-content widths do the groups wrap onto another row instead of overflowing, a narrow-layout usability difference under [Gallery parent layout](#gallery-parent-layout) / 先按参考收缩换字，最小内容宽度仍放不下时才换行 |
| Chart time x outside the Date range / Chart 时间轴越界值 | A time x beyond ±8.64e15 ms yields a label "Invalid Date" | Such a value is invalid data: not drawn, not counted, keeps its index; an axis tick outside the range still reads "Invalid Date" / 视为无效数据，不绘制 |
| Chart dark theme / Chart 深色主题 | None: the reference has no dark theme | `ChartColors.dark` maps the reference variables onto the dark product roles; it is this library's own design, not a reference value / 本库自有映射，非参考值 |
| Focus indicator colours / 焦点指示颜色 | Per component: `#19c8b9` (Button, CodeBlock copy, Chart details), yellow `#ffcc00`/`#f5c31c` (Switch, Checkbox, Radio, Rate, Tag, Pagination, Notification close), the browser default ring (Select trigger, Tabs, Collapse header) | One `focus` role per theme under the 3:1 rule of [Color and ownership](#color-and-ownership), with the listed component recipes; shape and offset follow the reference. Visibility follows `:focus-visible` as the reference: keyboard only / 颜色统一为达标的 focus 角色，显示时机同参考（仅键盘） |
| Gallery sidebar keyboard access / Gallery 侧边栏键盘可达 | Sidebar rows are plain `div`s outside the Tab order | Rows and the logo are Tab stops before the content, with a focus highlight and Enter activation; a local accessibility addition (`example/test/gallery_focus_test.dart`) / 侧边栏可用键盘到达，属本库的无障碍补充 |
| DatePicker range panel on narrow widths / 窄屏日期范围面板 | The 600px panel is aligned to the right edge of the trigger: at 375 wide it spans −243…357, so the first month lies off the left edge of the page and cannot be scrolled to (measured on the live site, 2026-11-20) | The panel stays inside the viewport and scrolls horizontally to the second month (`test/date_range_narrow_test.dart`), under the [narrow usability rule](#gallery-parent-layout) / 面板留在视口内，可横向滑到第二个月 |
| Busy Button focus / 加载中按钮焦点 | The loading button stays focusable (`pointer-events: none`) | Not focusable while busy / 加载中不可聚焦 |
| Input clear / 输入框清除 | Focus moves to the page body after the clear button is pressed | The field keeps focus / 清除后保留焦点 |
| Table row hover shape / Table 行悬停形状 | `tr:hover` declares `border-radius: 30px`; the live page draws a square full-width fill because the radius does not apply to a table row | The declared 30px rounded fill / 按声明绘制 30px 圆角 |
| Cursor demo raindrop zone / Cursor 示例雨滴区域 | The demo section is a `demo-raindrop-zone`, but its selector excludes descendants of `.animal-cursor` and the app root is one, so the live page shows the arrow over the section text | The section shows the raindrop as the rule intends / 按规则意图显示雨滴 |
| Home route URL / 首页地址 | Stays `#/` | The hash is dropped for the root route (framework hash strategy) / 根路由不带 `#/` |
| Gallery page loading mask / Gallery 页面加载遮罩 | The demo shell shows a circle Loading as the `Suspense` fallback while a lazily loaded page chunk downloads (`demo/App.tsx`) | Pages are compiled into the app and there is no chunk to wait for, so no mask is shown on navigation; the Skill page keeps its own 2s circle Loading / 页面已编译进应用，无分块加载，导航时不显示遮罩 |
| Chart and Calendar chrome language / 界面文案语言 | Fixed Chinese | `IslandLocalizations`: Chinese equal to the reference under a `zh` locale, English otherwise / 随 `IslandLocalizations` |
| Balanced and pretty text wrapping / 平衡与优化换行 | CSS `text-wrap: balance` on the NoData title and description, `text-wrap: pretty` on the charts overview cards | NoData balances both slots: each takes the narrowest whole-pixel width that keeps its line count (the Gallery example breaks 10 + 10 characters as the reference does). There is no line limit, and a break can differ by one character where Blink trims full-width punctuation at a line end. `pretty` is not reproduced: greedy breaking on the charts overview cards / NoData 的标题与说明按“保持行数的最窄宽度”平衡换行；无行数上限，行末全角标点压缩处可能相差一个字；图表总览卡片的 `pretty` 未复现 |
| Line boxes of caller-owned text / 调用方文本的行高 | A CSS `line-height` uses the primary font only (NoData title 24px and description 23.4px; Upload tip 19.2px) | Flutter sizes a line by every font in it, so caller text with CJK fallback glyphs is 1–2px taller per line. These are caller-owned text slots, which the library does not inspect or rewrite; library-owned text (Time capsule, Calendar month chip, CodeBlock, Chart title, description and data summary, the NoData default title) uses the reference line box: the Chart description is set in 20.390625px lines and the default NoData title has its baseline 17px down its 24px line, where a line of fallback glyphs sat 2px lower (2026-11-20). Resolved in the Gallery by the [2026-11-18 owner decision](#owner-decisions-2026-11-18): the Upload and NoData stories pass `StoryText`, which gives the Gallery's own text the CSS line box, the Blink baseline and the fractional line pitch (the earlier 1px low Upload tip and NoData description came from the baseline). `StoryText` also paints every baseline on a whole device pixel, as Blink does for a block that fractional boxes above it have pushed off the pixel grid (the second Upload tip, 0.1875px down, was drawn 1px low) / 调用方插槽文本不被库改写；Gallery 的 Upload 与 NoData 故事改用 `StoryText` 获得 CSS 行高、Blink 基线与小数行距（此前低 1px 源于基线）；`StoryText` 另按 Blink 的做法把每条基线画在整设备像素上；图表说明与 NoData 默认标题改用参考行高（2026-11-20） |
| Gallery mobile header and reveal / 移动端页头与滚动定位 | The fixed bar overlays the content; a focused or revealed target can end up under it | The bar overlays the content in the same way, but a focused or revealed target stays below the bar / 聚焦或滚动定位的目标保持在页头下方 |
| Chart map region without data / 地图无数据区域 | A native browser tooltip from the SVG `<title>` | The library tooltip with the same text, and the same accessible name / 使用库内 Tooltip，文案与无障碍名称相同 |
| Drawer mask under reduced motion / 减弱动效下的 Drawer 遮罩 | The mask keeps its 0.36s fade | The mask settles at once with the panel (one readable-motion policy) / 遮罩随面板直接到位 |
| Gallery API table description column / Gallery API 表说明列 | The column shrinks to one or two characters per line at narrow widths | The column keeps a four-character floor and the table scrolls sideways below the summed column floors / 说明列保留四个字的最小宽度，窄屏横向滚动 |
| Upload card status and buttons / 上传卡片状态与按钮 | The status sits on the bare thumbnail mask and the card buttons fade over 0.15s | The status keeps its pale backing (the reference teal and red fail over light thumbnails) and the card buttons change at once (readable motion) / 状态保留浅色底板，按钮不渐变 |
| Table loading / 表格加载 | The table dims to opacity .7 under an rgba(247,243,223,.8) overlay with a 2px backdrop blur | An opaque `TableColors.loadingBackplane` covers the rows; no dimming or blur (readable motion) / 不透明底板覆盖，无变暗与模糊 |
| Gallery mobile menu / Gallery 移动端菜单 | The overlay and aside open and close with no transition | Opens and closes at once as the reference, and keeps system back, Escape and a focus scope that holds traversal / 同参考即时开合，保留返回、Esc 与焦点范围 |
| Fades and colour transitions (comparison of 2026-11-20) / 渐变与颜色过渡 | Opacity fades on the Select dropdown, picker panels, Tooltip, Tabs content, Notification, the Pagination size list, the Time entrance, image loading and the Home scroll hint; a Badge indicator that zooms from .6 with a fade; a Checkbox/Radio mark that draws in; colour transitions of 0.15–0.3s on picker cells and triggers, Tabs, Rate stars, Pagination, the Input status bar, the Card dashed hover border, the CodeBlock copy and Image close buttons and the Upload trigger; exits that ease out | [Readable motion](#readable-motion): content stays opaque and keeps only its translation or scale (the Time entrance is an opaque 4px rise, the Badge a 1 → 1.08 → 1 pulse, the mark appears complete), these colours switch at once, and the picker panel, Tooltip and Notification exits replay the entrance curve in reverse. Durations, distances and the remaining curves follow the reference / 内容保持不透明，只保留位移或缩放；上述颜色即时切换；面板、Tooltip、Notification 的退出为入场曲线反向播放 |
| Tag close button on hover / Tag 关闭按钮悬停 | The disc darkens to rgba(0,0,0,.18) over 0.15s and the × keeps the tag colour | The disc takes the colourway's soft fill and the × its ink at once, which keeps the × at 3:1 on every palette, variant and host; on a soft tag the disc equals the tag fill, so only the × changes / 圆底取色系浅色、× 取墨色并即时切换，保证各色系 3:1；soft 变体下圆底与标签同色 |
| Ghost primary Button on hover and press / 幽灵主按钮悬停与按下 | `.btn-primary:hover` outranks the ghost reset, so a 6px depth shadow appears under the transparent button on hover and a 1px one on press, although it has none at rest | No shadow in any state; the lift and press offsets are kept / 任何状态均无阴影，保留位移 |
| Link Button on hover and press / 链接按钮悬停与按下 | Opacity .85 with the hover or pressed colour | The colour changes; the label stays opaque / 仅变色，不降低不透明度 |
| Cursor demo native controls when pressed / Cursor 示例原生控件按下 | Drawn by the browser: the link turns the user-agent `:active` red, the button its native pressed look | Gallery stand-ins keep their colour under a Material pressed overlay / Gallery 替代控件保持颜色并显示 Material 按下层 |
| Chart legend after 恢复全部图例 / 图例恢复后的焦点 | The removed control drops focus to the document | After a pointer press focus is dropped in the same way; after Enter or Space it stays on the last legend entry, so keyboard users keep their place (that series is highlighted, as any focused entry is) / 指针操作后同参考；键盘操作后焦点留在图例内 |
| Badge number on hover / Badge 数字悬停 | The native `title` tooltip | `IslandTooltip` with the same text / 使用库内 Tooltip |
| Countdown and Time before mount (4.0.1) / 挂载前的 Countdown 与 Time | Render `--` placeholders until the component has mounted, so that server and client markup agree | No server rendering exists; the first frame shows the real value / 不存在服务端渲染，首帧即显示真实数值 |
| Notification roles (4.0.1) / 通知的语义角色 | `role="status"` with `aria-live="polite"`, `role="alert"` with `assertive` for an error; a clickable notification stays a button | On the Web the same roles; on the other platforms, whose engines do not project these roles, every notification is a polite live region, an error included. A pressable notification is a live-region button on every platform / Web 上使用相同角色；其他平台的引擎不投射这两个角色，所有通知（含错误）均为礼貌播报的 live region |
| Select `className` and `style` (4.0.1) / Select 的 className 与 style | Passed to the root element | No counterpart: `width` sizes the trigger and the parent composes everything else / 无对应参数：`width` 决定触发器宽度，其余由父级组合 |
| Font `unicode-range` subsets (4.0.1) / 字体按 unicode-range 拆分 | Latin and CJK files declare ranges, so characters outside both (arrows such as →, ✓, box-drawing) come from a system font | The Gallery draws them from its bundled font on every platform / Gallery 在各平台均用内置字体绘制这些字符 |

<a id="pending-owner-decisions-400"></a>
## Pending owner decisions (4.0.0) / 待所有者裁决（4.0.0）

The 4.0.0 ports and new components keep the reference values below, or the stated current behavior, until the owner decides. Colour items that the [measured colour rule](#measured-color-differences) settles are registered in its table; only items it does not settle remain here. Contrast figures are measured on the composited surfaces named and are not acceptance evidence. 4.0.0 版本既有组件移植与新组件暂保留下列参考值或所述现状，待所有者裁决；实测配色规则可裁定的颜色项已登记于其表格，此处仅保留该规则无法裁定的项目。对比度为在所列合成表面上的实测值，不构成验收证据。

None at present; the last two items were decided on 2026-11-20 and moved to the [owner decisions](#owner-decisions-2026-11-19). 目前没有待决项；最后两项已于 2026-11-20 裁决并移入所有者决定。

<a id="notification-type"></a>
## Notification type / 通知类型

Deliberately better than reference: a requested `type` is always shown. The reference named methods override `type`, which the user ruled a reference bug. 有意优于参考：始终显示调用方指定的 `type`；参考具名方法覆盖 `type`，经用户裁定为参考缺陷。

Verification limitations and SDK role support are recorded in [ACCEPTANCE](ACCEPTANCE.md); design contracts alone are not acceptance evidence.

验收限制及 SDK 角色支持见 [ACCEPTANCE](ACCEPTANCE.md)，设计契约本身不构成通过证据。
