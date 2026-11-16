# Product design / 产品设计

The pinned [reference identity](reference-gallery.json) defines the 40 component families, Home and Skill pages. Windows and Web are primary targets. Preserve reference layout, typography, silhouettes, content and interaction except for the explicit differences below; adapt technical examples to Flutter. Current component details are in [the reference catalog](component-reference-details.json) and component contracts.

固定[参考身份](reference-gallery.json)定义 40 类组件、首页和 Skill 页，Windows 与 Web 优先。除下列明确差异外，保留参考布局、字形、造型、内容和交互，技术示例适配 Flutter；组件细节见[参考目录](component-reference-details.json)及各组件契约。

## Color and ownership / 配色与所有权

Maintain one light/dark product palette. Text requires 4.5:1 and necessary graphics 3:1 on their actual composited backgrounds, except the named Home/photo regions below. Every color is a named token in one of three library tiers: the primitive palette (`lib/src/foundation/palette.dart`, one name per raw value, plus the indexed IslandColorway and generated Background tables), the themable semantic roles (`IslandTokens`, `IslandColorway`), and one recipe per component (`lib/src/foundation/recipes/`) that resolves its state colors from the theme, including the reference-palette decision. Components and Gallery pages hold no color literals; Gallery demo colors live only in `example/lib/shared/palette.dart` and library values reach the Gallery through the public root. `tool/verify.py` and `test/color_literal_policy_test.dart` enforce this. Parent layout, passive slot defaults, nested controls, explicit caller styles and artwork have separate owners. Never infer arbitrary background colors, inspect/rewrite opaque child widgets or introduce a parallel palette.

仅维护一套明暗产品配色。除下述首页／照片具名区域外，文字在实际合成背景上要求 4.5:1，必要图形要求 3:1。颜色均为具名令牌，分三层归库：基础色板（`lib/src/foundation/palette.dart`，每个原始值一个名称，另含 IslandColorway 索引表与生成的 Background 表）、可定制的语义角色（`IslandTokens`、`IslandColorway`）、每个组件一处从主题解析状态色（含参考配色判断）的组件配方（`lib/src/foundation/recipes/`）；组件与 Gallery 页面不写颜色字面量，Gallery 演示色只在 `example/lib/shared/palette.dart`，库已有的值经公共入口读取，由 `tool/verify.py` 与 `test/color_literal_policy_test.dart` 检查；父布局、被动插槽、嵌套控件、显式子样式和素材各自负责，不猜测背景、不遍历改写 opaque child、不维护平行色板。

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

The existing Home badge shows the independent root `pubspec.yaml` version through the generated `example/lib/shared/version.g.dart` projection. `tool/verify.py --generate-gallery-version` owns generation and validates equality with the Gallery pubspec; source policy rejects stale output. Do not maintain per-page version literals. Badge style and layout stay unchanged. The footer retains Reference Gallery attribution without presenting its observed version as this product's version; the original observed version remains provenance in `docs/reference-gallery.json`.

首页现有徽标通过生成的 `example/lib/shared/version.g.dart` 展示独立项目根 `pubspec.yaml` 版本；生成及与 Gallery pubspec 的一致性由 `tool/verify.py --generate-gallery-version` 所有，源码检查拒绝过期输出。不在页面手工维护另一份版本值，不改变徽标样式或布局。页脚保留 Reference Gallery 归属，但不把参考观测版本当成本项目版本；原观测版本仍保留在 `docs/reference-gallery.json` 来源记录中。



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
| Progress fill edge (`ProgressColors.fillEdge`) / 进度填充边 | none; `#19c8b9` is 1.9:1 on the track → 2px `#039d91` beside the reference inset highlight / 填充仅 1.9:1，加同色相 2px 边 |
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

Transparent per-hue Tag text is validated on the product papers; caller-filled or accent surfaces need a filled variant or an explicit style. 透明 Tag 色相文字仅在产品纸面验证，强调色或调用方表面请用填色变体或显式样式。

<a id="time-colon-blink"></a>
The Time colon is a decorative separator: it blinks on the reference 1s step-end cycle, the clock value stays complete in semantics, digits never dim and reduced motion keeps it visible. Time 冒号是装饰分隔符，按参考 1s step-end 闪烁；语义值完整、数字不变暗，减少动态时常亮。

<a id="owner-decisions-2026-11-16"></a>
## Owner decisions / 所有者决定（2026-11-16）

| Item | Decision | Reason |
|---|---|---|
| Flame icon outline inside a coloured Tag / 彩色 Tag 内火焰轮廓 | Keeps following the Tag colour; differs from the reference fixed dark outline | Stays visible on light and dark hosts; the icon contrast oracle is unchanged |
| Modal and Image preview entrance / 弹层入场 | One shared dialog route and entrance; differs slightly from the two reference entrances | One mechanism, no per-consumer parameter |
| Tabs active dot / Tabs 选中圆点 | Follows the pinned 2.2.1 source: the dot inherits the active label colour | The live site (3.0.4) is outside this round's scope |

<a id="notification-type"></a>
## Notification type / 通知类型

Deliberately better than reference: a requested `type` is always shown. The reference named methods override `type`, which the user ruled a reference bug. 有意优于参考：始终显示调用方指定的 `type`；参考具名方法覆盖 `type`，经用户裁定为参考缺陷。

Verification limitations and SDK role support are recorded in [ACCEPTANCE](ACCEPTANCE.md); design contracts alone are not acceptance evidence.

验收限制及 SDK 角色支持见 [ACCEPTANCE](ACCEPTANCE.md)，设计契约本身不构成通过证据。
