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

## Reference comparison / 参考对比（2026-11-13）

All 42 routes (40 components, Home, Skill) were compared with the reference at 1440×1000 and 375×812 in three review passes; differences were fixed or registered in [DESIGN](DESIGN.md#measured-color-differences). After the last pass no page has an unresolved difference beyond the registered ones and low-impact notes. This is a scoped static review, not platform acceptance:

- Our frames come from the Flutter test host at pixel ratio 1, not the Windows engine or a browser.
- Reference frames come from the live site, now newer than the pinned version; for the 16 components changed upstream since the pin, the pinned source was the authority.
- Stills show resting states. Hover, press, keyboard and motion were compared from source and covered by tests, not observed side by side.
- Component and route statuses stay `NOT_ACCEPTED` until Windows and Web runs and the owner's sign-off exist.

Decided by the owner (2026-11-16): the checked Checkbox/Radio mark keeps the reference white as a registered exception; the flame icon outline keeps following the Tag colour; Modal and Image preview keep one shared dialog entrance; the Tabs active dot follows the pinned 2.2.1 source (it inherits the active label colour). Open decisions: CountUp named easings; Rate star silhouette; whether near-duplicate reference colours should be merged.

42 个路由（40 组件、首页、Skill）在 1440×1000 与 375×812 下与参考经三轮比对，差异已修复或登记于[设计文档](DESIGN.md#measured-color-differences)；末轮后各页仅余已登记差异和低影响备注。此为有限范围的静态审查，不是平台验收：我方画面来自 Flutter 测试宿主（像素比 1），非 Windows 引擎或浏览器；参考画面来自线上站，已新于固定版本，上游在固定版本后改动的 16 个组件以固定源码为准；静态图只含静止状态，悬停、按压、键盘与动效依据源码比对并由测试覆盖，未并排观察；在取得 Windows、Web 实跑和所有者签收前，组件与路由状态保持 `NOT_ACCEPTED`。所有者已决定（2026-11-16）：选中对勾保持参考白色并登记例外；火焰图标轮廓继续跟随 Tag 颜色；Modal 与图片预览保持共用入场；Tabs 选中圆点以固定 2.2.1 源码为准（继承选中标签颜色）。待决事项：CountUp 具名缓动、Rate 星形轮廓、参考近似重复色是否合并。

## Windows engine run / Windows 引擎实跑（2026-11-13）

All seven `example/integration_test` entries ran on the Windows engine (Debug, one workstation display) and pass: Gallery flow, catalog geometry, motion coverage, icon contexts (capture only, review pending), Select follow-up and the shared component scenarios. Three oracles that sample animation values at exact elapsed times run only under the fake clock of `flutter test` and are skipped on the engine (`test/support/fake_clock_only.dart`): Carousel curves, the sidebar NEW-badge pulse and the Background wallpaper fade. These runs do not establish OS outer-window, physical-display or frame-rate behaviour.

七个 `example/integration_test` 入口已在 Windows 引擎（Debug，单台工作站显示器）上运行并全部通过：Gallery 流程、目录几何、动效覆盖、图标上下文（仅采集，待人工审阅）、Select 后续与共享组件场景。三项按精确经过时间采样动画数值的断言只在 `flutter test` 假时钟下运行，引擎上跳过（`test/support/fake_clock_only.dart`）：Carousel 曲线、侧栏 NEW 徽标脉冲、Background 壁纸淡入。这些运行不证明系统外窗、物理屏幕或帧率表现。

## Browser run / 浏览器实跑（2026-11-16）

The release Web build (CanvasKit, local static server) was opened in one Chromium-based browser. All 42 routes loaded without script errors; the only failed requests are the two deliberately missing images of the Image and Avatar error examples. Observed and compared with the live reference: Button and Select pages at a 1440×1000 emulated viewport (downscaled capture), the Select side popup with its highlighted selection, the description typewriter, and at a real 322px-wide viewport the narrow shell, the game-shaped Modal with focus ring and custom cursor, and Escape closing it. This is a scoped spot check: other pages' interactions, hover intermediate frames, Edge, Firefox, Safari and the 375px capture were not observed.

发布版 Web 构建（CanvasKit，本地静态服务器）在一个 Chromium 内核浏览器中打开：42 个路由全部加载且无脚本错误，仅有 Image 与 Avatar 失败示例故意缺失的两张图片请求失败。已观察并与线上参考对照：1440×1000 模拟视口（缩小采集）下的 Button、Select 页面，Select 侧边弹层及选中高亮，说明文字打字机；实际 322px 宽视口下的窄屏外壳、异形 Modal（焦点环、自定义光标）及 Esc 关闭。此为有限抽查：其余页面的交互、悬停中间帧、Edge、Firefox、Safari 与 375px 采集均未观察。

## Not yet verified / 尚未验证

| Area | Boundary / 边界 |
|---|---|
| Browser hover | Qualified intermediate raw frames in Chrome and Edge are incomplete. / Chrome、Edge 悬停中间原始帧证据不完整。 |
| Edge narrow viewport | The required actual 375px after-state capture remains outstanding. / 仍缺实际 375px 的修复后画面。 |
| Native presentation | Rendered application pixels do not establish OS outer-window or physical-panel presentation. / 应用像素不证明系统外窗或物理屏幕呈现。 |
| Packaged onsite use | Fresh package hashes and builds do not replace a new mouse/keyboard/hover/performance run of those binaries. / 新包校验与构建不能替代对应二进制现场复测。 |
| Notification/Tooltip motion | Entry/exit translation rounds to whole device pixels (2026-11-13). The unchanged 0.25 oracle passes in the Flutter test host for all 42 cases (pixel ratios 1 and 1.25, three sample times) and on the Windows engine for the 20 cases its native entry registers (pixel ratio 1, one 16ms sample). Native pixel ratio 1.25 and the remaining sample times were not run on the engine; the earlier 18 failed measurements remain historical evidence. / 位移按整设备像素取整。测试宿主下 42 项（像素比 1、1.25，三个采样时刻）在原 0.25 阈值内全部通过；Windows 引擎下原生入口登记的 20 项（像素比 1，16ms 单次采样）全部通过。引擎上未跑像素比 1.25 与其余采样时刻；此前 18 项失败保留为历史证据。 |
| Full performance | No quiet-load, all-component, all-state, all-platform 60fps certification. / 未证明低负载及全组件、全状态、全平台 60fps。 |

Screen-reader execution is outside the completed scope; excluded does not mean tested or certified. Semantic contracts and keyboard tests remain maintained. Mobile platforms need separate validation.

读屏器运行不在已执行范围内，排除不等于通过或认证；语义契约及键盘测试继续维护。移动平台需要独立验证。

## Verification method / 验证方法

Compare the same route, viewport, DPR, fonts, theme, input state and animation phase. Check entry, exit, reversal, rapid reopening, cancellation, disposal and reduced motion. Validate actual composited colors, including alpha, images, gradients and nested controls, against the design budgets. Preserve callback rejection, borrowed-resource ownership and explicit child styling.

对齐路由、视口、DPR、字体、主题、输入状态及动画阶段；覆盖进入、退出、反向、快速重开、取消、卸载和减少动态效果。按设计预算检查 alpha、图片、渐变及嵌套控件的实际合成色，并保留回调拒绝、借用资源所有权和显式子样式。

Commands and test ownership are documented in [MAINTENANCE](MAINTENANCE.md). Raw logs, source-bound measurements and private review records are stored outside the public product repository; this page publishes the user-relevant boundary without embedding workstation paths or session history. Source changes require fresh evidence for the changed scope.

命令和测试职责见[维护说明](MAINTENANCE.md)。原始日志、源绑定测量和私有审查记录保存在公开产品仓库之外；本页公开使用边界，不嵌入本机路径或会话历史。源码变更后必须按受影响范围重新验证。
