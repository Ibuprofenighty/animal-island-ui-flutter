# Product design / 产品设计

The pinned [reference identity](reference-gallery.json) defines the 40 component families, Home and Skill pages. Windows and Web are primary targets. Preserve reference layout, typography, silhouettes, content and interaction except for the explicit differences below; adapt technical examples to Flutter. Current component details are in [the reference catalog](component-reference-details.json) and component contracts.

固定[参考身份](reference-gallery.json)定义 40 类组件、首页和 Skill 页，Windows 与 Web 优先。除下列明确差异外，保留参考布局、字形、造型、内容和交互，技术示例适配 Flutter；组件细节见[参考目录](component-reference-details.json)及各组件契约。

## Color and ownership / 配色与所有权

Maintain one light/dark product palette. Text requires 4.5:1 and necessary graphics 3:1 on their actual composited backgrounds, except the named Home/photo regions below. Primitive and semantic colors belong to the library; component recipes own their surfaces and state colors. Parent layout, passive slot defaults, nested controls, explicit caller styles and artwork have separate owners. Never infer arbitrary background colors, inspect/rewrite opaque child widgets or introduce a parallel palette.

仅维护一套明暗产品配色。除下述首页／照片具名区域外，文字在实际合成背景上要求 4.5:1，必要图形要求 3:1。基础及语义色归库，组件配方拥有自身表面和状态；父布局、被动插槽、嵌套控件、显式子样式和素材各自负责，不猜测背景、不遍历改写 opaque child、不维护平行色板。

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

Fractional motion must sample a complete owned backing/border/content group together. Pure translated drawing can quantize glyph pixels separately from vector edges even under one logical matrix; do not add text delays or offsets. Use the existing framework filtered Transform only where the named scene evidence validates it; this is not a blanket prescription for every moving owner. Each owning component retains its one position/scale timeline, targets, reduced-motion settlement, focus/hit testing and single child identity; shadow/color decoration can keep its separately specified interpolation. Existing SurfaceMotion composes its supplied translation/scale into one filtered matrix, remaining stateless and leaving timing/visibility to its caller. Gallery uses the same framework mechanism through public Flutter APIs, without private package imports or a new product API. Unchanged integer jumps (Upload), decorative shadow extent and nonmoving labels are distinct cases. Pixel oracles compare the Button backing alpha-edge and linear ink-mass centroids; an opaque payload inside an opaque host uses its known contrasting color-edge derivative and linear ink mass. The original0.25 tolerance is unchanged. toImage observations are output-image pixels at the declared pixelRatio, independent of OS DPR; they do not establish physical scanout. The Notification/Tooltip measurement limitation documented in ACCEPTANCE.md does not turn failing numbers intoPASS. Browser raw frames and Windows engine observations qualify platform behavior separately; no new60fps guarantee is inferred.

分数位移必须把所属底板、边界和内容作为完整整体一起采样。即使只有一个逻辑矩阵，直接平移绘制也可能让字形像素与矢量边界采用不同量化；不得给文字加延迟或补偿偏移。仅在具名场景证据有效时使用既有框架 filtered Transform，不向所有运动所有者机械推广；各组件仍拥有唯一位移/缩放时间线、目标、减少动态时结算、命中/焦点及单一子身份，阴影/配色装饰保留各自已规定的插值。既有无状态 SurfaceMotion 把调用方给定的位移/缩放合成一个 filtered 矩阵，不接管时序或显示条件；Gallery 通过公共 Flutter API 使用同一框架机制，不导入包内私有实现、不新增产品API。Upload 的整数跳变、装饰阴影外延和本就不移动的文字分别归类。像素测试比较Button底板alpha边缘与线性文字质量中心；位于不透明宿主内的受控内容则用已知对比色边缘导数与线性文字质量中心。原0.25门槛不变。toImage观测单位为声明pixelRatio下的输出图像像素，独立于OS DPR，不证明物理屏幕呈现；下述通知／气泡测量限制的接受不把失败数值改成PASS。浏览器原始帧及Windows引擎观察分别说明平台有效范围，不新增60fps承诺。


Surface-sampling owner coverage / 表面采样所有者覆盖：

| Existing owner | Active motion and classification |
| --- | --- |
| Notification | Original250ms cubic/±16px renderer retained under the user-accepted measurement limitation2026-10-21. Output-image ink-centroid failures remain; calibrated rigid glyph controls also fail, so this alone does not establish a component timing defect or pixelPASS. Slots remain opaque; leaving handles remain non-reversible. |
| Tooltip | Original250ms directional bubble retained under the same user-accepted measurement limitation. A filtered-transform proposal regressed a named native horizontal sample and was reverted. Original/control glyph changes do not prove a separate text timeline, pixelPASS or engine cause; AnchoredPanel itself has zero duration here. |
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

Verification limitations and SDK role support are recorded in [ACCEPTANCE](ACCEPTANCE.md); design contracts alone are not acceptance evidence.

验收限制及 SDK 角色支持见 [ACCEPTANCE](ACCEPTANCE.md)，设计契约本身不构成通过证据。
