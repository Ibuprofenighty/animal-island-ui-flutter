# Verification and limitations / 验证与限制

This experimental library has scoped usability evidence, not complete production or all-platform visual acceptance. A build, registered route or passing widget test does not establish every visible state. Original failed measurements remain failures; accepted limitations are not passing tests.

本实验库具有有限范围的可用性证据，尚未完成完整生产或全平台视觉验收。构建、路由登记和组件测试通过不代表全部可见状态通过；已接受的限制不将原始失败改成通过。

## Accepted limits / 已接受限制

- **Select semantics:** the supported SDK projects button/text-field semantics rather than the complete combobox role. Keyboard, focus, names, states and IME remain required. No SDK fork or DOM shim is used.
- **Home and Carousel contrast:** only the named Gallery wallpaper text and photo captions follow the reference-priority exceptions in [DESIGN](DESIGN.md#home-host-and-photo-gradient). They may fall below 4.5:1. Other text, controls and focus retain their existing requirements.
- **Icon scrolling:** actual-load scrolling can have long observation intervals. Simultaneous host activity may contribute, but has not been established as the sole cause. There is no all-content or all-platform 60fps guarantee.

- **Select 语义：**受支持 SDK 使用 button/text-field 投射，未实现完整 combobox 角色；键盘、焦点、名称、状态和输入法要求保持，不使用 SDK 分叉或 DOM 垫片。
- **首页及轮播对比度：**仅[设计契约](DESIGN.md#home-host-and-photo-gradient)明确的首页背景文字和照片说明采用参考优先例外，可能低于 4.5:1；其他文字、控件及焦点不豁免。
- **图标滚动：**实际负载下可能出现较长观测间隔；同时使用电脑可能贡献负载，但未证明是唯一原因，不承诺全内容、全平台 60fps。

## Reference comparison (2.2.1 round) / 参考对比（2.2.1 轮，2026-11-13）

All 42 routes (40 components, Home, Skill) were compared with the reference at 1440×1000 and 375×812 in three review passes; differences were fixed or registered in [DESIGN](DESIGN.md#measured-color-differences). After the last pass no page has an unresolved difference beyond the registered ones and low-impact notes. This is a scoped static review, not platform acceptance:

- Our frames come from the Flutter test host at pixel ratio 1, not the Windows engine or a browser.
- Reference frames come from the live site, then newer than the pinned version (2.2.1); for the 16 components changed upstream since the pin, the pinned source was the authority.
- Stills show resting states. Hover, press, keyboard and motion were compared from source and covered by tests, not observed side by side.
- Component and route statuses stay `NOT_ACCEPTED` until Windows and Web runs and the owner's sign-off exist.

Decided by the owner (2026-11-16): the checked Checkbox/Radio mark keeps the reference white as a registered exception; the flame icon outline keeps following the Tag colour; Modal and Image preview keep one shared dialog entrance; the Tabs active dot follows the pinned 2.2.1 source (it inherits the active label colour). Open decisions: CountUp named easings; Rate star silhouette; whether near-duplicate reference colours should be merged.

42 个路由（40 组件、首页、Skill）在 1440×1000 与 375×812 下与参考经三轮比对，差异已修复或登记于[设计文档](DESIGN.md#measured-color-differences)；末轮后各页仅余已登记差异和低影响备注。此为有限范围的静态审查，不是平台验收：我方画面来自 Flutter 测试宿主（像素比 1），非 Windows 引擎或浏览器；参考画面来自线上站，当时已新于固定的 2.2.1 版本，上游在固定版本后改动的 16 个组件以固定源码为准；静态图只含静止状态，悬停、按压、键盘与动效依据源码比对并由测试覆盖，未并排观察；在取得 Windows、Web 实跑和所有者签收前，组件与路由状态保持 `NOT_ACCEPTED`。所有者已决定（2026-11-16）：选中对勾保持参考白色并登记例外；火焰图标轮廓继续跟随 Tag 颜色；Modal 与图片预览保持共用入场；Tabs 选中圆点以固定 2.2.1 源码为准（继承选中标签颜色）。待决事项：CountUp 具名缓动、Rate 星形轮廓、参考近似重复色是否合并。

## Windows engine run (2.2.1 round) / Windows 引擎实跑（2.2.1 轮，2026-11-13）

All seven `example/integration_test` entries ran on the Windows engine (Debug, one workstation display) and pass: Gallery flow, catalog geometry, motion coverage, icon contexts (capture only, review pending), Select follow-up and the shared component scenarios. Three oracles that sample animation values at exact elapsed times run only under the fake clock of `flutter test` and are skipped on the engine (`test/support/fake_clock_only.dart`): Carousel curves, the sidebar NEW-badge pulse and the Background wallpaper fade. These runs do not establish OS outer-window, physical-display or frame-rate behaviour.

七个 `example/integration_test` 入口已在 Windows 引擎（Debug，单台工作站显示器）上运行并全部通过：Gallery 流程、目录几何、动效覆盖、图标上下文（仅采集，待人工审阅）、Select 后续与共享组件场景。三项按精确经过时间采样动画数值的断言只在 `flutter test` 假时钟下运行，引擎上跳过（`test/support/fake_clock_only.dart`）：Carousel 曲线、侧栏 NEW 徽标脉冲、Background 壁纸淡入。这些运行不证明系统外窗、物理屏幕或帧率表现。

## Browser run (2.2.1 round) / 浏览器实跑（2.2.1 轮，2026-11-16）

The release Web build (CanvasKit, local static server) was opened in one Chromium-based browser. All 42 routes loaded without script errors; the only failed requests are the two deliberately missing images of the Image and Avatar error examples. Observed and compared with the live reference: Button and Select pages at a 1440×1000 emulated viewport (downscaled capture), the Select side popup with its highlighted selection, the description typewriter, and at a real 322px-wide viewport the narrow shell, the game-shaped Modal with focus ring and custom cursor, and Escape closing it. This is a scoped spot check: other pages' interactions, hover intermediate frames, Edge, Firefox, Safari and the 375px capture were not observed.

发布版 Web 构建（CanvasKit，本地静态服务器）在一个 Chromium 内核浏览器中打开：42 个路由全部加载且无脚本错误，仅有 Image 与 Avatar 失败示例故意缺失的两张图片请求失败。已观察并与线上参考对照：1440×1000 模拟视口（缩小采集）下的 Button、Select 页面，Select 侧边弹层及选中高亮，说明文字打字机；实际 322px 宽视口下的窄屏外壳、异形 Modal（焦点环、自定义光标）及 Esc 关闭。此为有限抽查：其余页面的交互、悬停中间帧、Edge、Firefox、Safari 与 375px 采集均未观察。

## Reference 4.0.0 port / 4.0.0 移植（2026-11-17）

The reference is re-pinned from 2.2.1 to 4.0.0 (`docs/reference-gallery.json`; `docs/reference-page-inventory.json` lists 63 routes). All 63 routes now have Gallery stories: `tool/reference_coverage.py` reports no missing route and the status `READY_FOR_VISUAL_REVIEW`, which means a visual review can start and is not acceptance. This round implemented the ports of existing components (Divider, Progress, Upload, Select, Button, Cursor, Modal, DatePicker, TimePicker, Time, Loading, Countdown), the new Calendar, NoData and Chart (19 kinds) and the 709-glyph icon set, and updated Home, the Skill page and the Gallery shell. On the Flutter test host, after the icon rules of 2026-11-17 ([DESIGN](DESIGN.md#owner-decisions-2026-11-17)), `IslandTimeStyle`, the dark Cursor highlight the Drawer/BackTop layering change and the fixes from the page-by-page comparison, the library's 732 tests and the Gallery's 371 tests pass and analysis is clean. The Web and Windows release builds succeed; no browser run has been done for this round, so the 2.2.1 sections above do not cover these changes. Independent source reviews were done for the ported components and for Calendar, NoData and Chart, and their findings were fixed. Measured contrast figures and open owner decisions are in [DESIGN](DESIGN.md#pending-owner-decisions-400). All component and route statuses stay `NOT_ACCEPTED`.

On 2026-11-17 a page-by-page comparison against the live reference was made for the 63 inventory routes plus Home, at 1440x1000 and 375x812. The reference screenshots come from the live site, which may serve 4.0.1 rather than the pinned 4.0.0; ours come from the Flutter Windows engine in debug mode at device pixel ratio 1 with reduced motion. Hover, pressed, keyboard and motion states were compared from source only, not captured. The findings were fixed or registered in [DESIGN](DESIGN.md#measured-color-differences). A second capture and review followed those fixes, then a rework and a spot review of the eleven reworked items on a third capture: six were closed, three more (Table header at 375, Calendar toolbar at 375, Progress fill highlight) were then fixed and the Table and Calendar ones confirmed on a fourth capture; the Progress one is pinned by a host test only. The Upload tip and NoData text offsets remain as registered. The comparison does not change any status.

On 2026-11-18 all seven `example/integration_test` entries ran on the Windows engine (Debug, one workstation display, device pixel ratio 1) at the state described above and pass: Gallery flow, Select/Button follow-up (36), shared component scenarios (90, 4 skipped), motion coverage (27), icon contexts (capture only, review pending), catalog geometry (43, 1 skipped) and the 840-frame capture. Two observations from these runs: the hover-position oracle in `test/button_states_test.dart` failed two of three live-clock runs by 0.001-0.002px at its 0.001px tolerance, which is below the resolution of `Cubic.transform`; the tolerance is now 0.005px, with the derivation in the test, and three further runs pass. On 2026-11-17, runs made while a full-screen game occupied the same display stalled, timed out or exited mid-run; they were discarded and repeated, and the cause was not investigated further.

参考已由 2.2.1 重新固定到 4.0.0（`docs/reference-gallery.json`；`docs/reference-page-inventory.json` 含 63 个路由）。63 个路由现均有 Gallery 展示：`tool/reference_coverage.py` 报告无缺失路由，状态为 `READY_FOR_VISUAL_REVIEW`，仅表示可以开始视觉审查，不是验收。本轮实现了既有组件（Divider、Progress、Upload、Select、Button、Cursor、Modal、DatePicker、TimePicker、Time、Loading、Countdown）的移植、新增的 Calendar、NoData 与 Chart（19 种）以及 709 个图标，并更新了首页、Skill 页与 Gallery 外壳。在 Flutter 测试宿主上，2026-11-17 的图标规则（见[设计文档](DESIGN.md#owner-decisions-2026-11-17)）、`IslandTimeStyle`、深色 Cursor 高亮、Drawer/BackTop 层级改动与逐页对照修复之后，库的 732 项测试与 Gallery 的 371 项测试全部通过，静态分析无问题。Web 与 Windows 发布构建成功；本轮未做浏览器实跑，因此上文 2.2.1 轮各节不覆盖这些改动。已对移植组件及 Calendar、NoData、Chart 做独立源码审查，所提问题已修复。实测对比度与待决事项见[设计文档](DESIGN.md#pending-owner-decisions-400)。所有组件与路由状态保持 `NOT_ACCEPTED`。

2026-11-17 对 63 个清单路由及首页，在 1440x1000 与 375x812 两种视口下与线上参考做了逐页对比。参考截图取自线上站点，其版本可能是 4.0.1 而非固定的 4.0.0；本库截图取自 Flutter Windows 引擎，调试模式，设备像素比 1，减少动态。悬停、按下、键盘与动效状态仅按源码对比，未截图。所发现的差异已修复或登记于[设计文档](DESIGN.md#measured-color-differences)。修复后做了第二次采集与审查，随后返工，并在第三次采集上抽查了十一个返工项：六项已关闭，另有三项（375 宽度下的 Table 表头、Calendar 工具栏，以及 Progress 填充高光）随后修复，其中 Table 与 Calendar 已在第四次采集上确认，Progress 仅由宿主测试固定。Upload 提示行与 NoData 文字的偏移仍按登记保留。该对比不改变任何状态。

2026-11-18，七个 `example/integration_test` 入口在上述状态下于 Windows 引擎（Debug，单台工作站显示器，设备像素比 1）运行并全部通过：Gallery 流程、Select/Button 后续（36 项）、共享组件场景（90 项，跳过 4 项）、动效覆盖（27 项）、图标上下文（仅采集，待人工审阅）、目录几何（43 项，跳过 1 项）以及 840 帧采集。运行中的两点观察：`test/button_states_test.dart` 的悬停位置断言在真实时钟下三次运行中有两次以 0.001–0.002px 超出其 0.001px 容差，该容差小于 `Cubic.transform` 的分辨率；现改为 0.005px，推导写在测试中，此后三次运行均通过。2026-11-17 在同一显示器被全屏游戏占用时进行的运行出现停滞、超时或中途退出，这些结果已作废并重跑，原因未进一步调查。

## Not yet verified / 尚未验证

| Area | Boundary / 边界 |
|---|---|
| Browser hover | Qualified intermediate raw frames in Chrome and Edge are incomplete. / Chrome、Edge 悬停中间原始帧证据不完整。 |
| Edge narrow viewport | The required actual 375px after-state capture remains outstanding. / 仍缺实际 375px 的修复后画面。 |
| Native presentation | Rendered application pixels do not establish OS outer-window or physical-panel presentation. / 应用像素不证明系统外窗或物理屏幕呈现。 |
| Packaged onsite use | Fresh package hashes and builds do not replace a new mouse/keyboard/hover/performance run of those binaries. / 新包校验与构建不能替代对应二进制现场复测。 |
| Notification/Tooltip motion | Entry/exit translation rounds to whole device pixels (2026-11-13). The unchanged 0.25 oracle passes in the Flutter test host for all 42 cases (pixel ratios 1 and 1.25, three sample times) and on the Windows engine for the 20 cases its native entry registers (pixel ratio 1, one 16ms sample). Native pixel ratio 1.25 and the remaining sample times were not run on the engine; the earlier 18 failed measurements remain historical evidence. / 位移按整设备像素取整。测试宿主下 42 项（像素比 1、1.25，三个采样时刻）在原 0.25 阈值内全部通过；Windows 引擎下原生入口登记的 20 项（像素比 1，16ms 单次采样）全部通过。引擎上未跑像素比 1.25 与其余采样时刻；此前 18 项失败保留为历史证据。 |
| Full performance | No quiet-load, all-component, all-state, all-platform 60fps certification. / 未证明低负载及全组件、全状态、全平台 60fps。 |
| Icon paint (709 glyphs) | The outcomes of the 2026-11-17 and 2026-11-18 icon rules are measured and were accepted by the owner as a set on 2026-11-19, not glyph by glyph, including role-carried decisions on redrawn geometry such as the owl and penguin eyes ([DESIGN](DESIGN.md#owner-decisions-2026-11-18)). No role is held: the five red negation slashes are `#E46C4F`, which still measures 1.66:1 on the light canvas, and 15 roles keep upstream paint by owner decision ([DESIGN](DESIGN.md#owner-decisions-2026-11-18)). / 图标配色结果仅为实测，未做目视审查；重绘几何上沿用的角色决定（如猫头鹰、企鹅的眼睛）待所有者确认。没有搁置角色：五条红色否定斜线为 `#E46C4F`，在浅色画布上仍仅 1.66:1；15 项角色按所有者决定保留上游配色。 |

Screen-reader execution is outside the completed scope; excluded does not mean tested or certified. Semantic contracts and keyboard tests remain maintained. Mobile platforms need separate validation.

读屏器运行不在已执行范围内，排除不等于通过或认证；语义契约及键盘测试继续维护。移动平台需要独立验证。

## Verification method / 验证方法

Compare the same route, viewport, DPR, fonts, theme, input state and animation phase. Check entry, exit, reversal, rapid reopening, cancellation, disposal and reduced motion. Validate actual composited colors, including alpha, images, gradients and nested controls, against the design budgets. Preserve callback rejection, borrowed-resource ownership and explicit child styling.

对齐路由、视口、DPR、字体、主题、输入状态及动画阶段；覆盖进入、退出、反向、快速重开、取消、卸载和减少动态效果。按设计预算检查 alpha、图片、渐变及嵌套控件的实际合成色，并保留回调拒绝、借用资源所有权和显式子样式。

Commands and test ownership are documented in [MAINTENANCE](MAINTENANCE.md). Raw logs, source-bound measurements and private review records are stored outside the public product repository; this page publishes the user-relevant boundary without embedding workstation paths or session history. Source changes require fresh evidence for the changed scope.

命令和测试职责见[维护说明](MAINTENANCE.md)。原始日志、源绑定测量和私有审查记录保存在公开产品仓库之外；本页公开使用边界，不嵌入本机路径或会话历史。源码变更后必须按受影响范围重新验证。
