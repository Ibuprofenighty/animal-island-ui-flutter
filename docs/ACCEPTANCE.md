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

Open decisions: flame icon outline tint inside a coloured Tag; one shared dialog entrance for Modal and Image preview; CountUp named easings; Rate star silhouette; Tabs active dot colour; whether near-duplicate reference colours should be merged.

42 个路由（40 组件、首页、Skill）在 1440×1000 与 375×812 下与参考经三轮比对，差异已修复或登记于[设计文档](DESIGN.md#measured-color-differences)；末轮后各页仅余已登记差异和低影响备注。此为有限范围的静态审查，不是平台验收：我方画面来自 Flutter 测试宿主（像素比 1），非 Windows 引擎或浏览器；参考画面来自线上站，已新于固定版本，上游在固定版本后改动的 16 个组件以固定源码为准；静态图只含静止状态，悬停、按压、键盘与动效依据源码比对并由测试覆盖，未并排观察；在取得 Windows、Web 实跑和所有者签收前，组件与路由状态保持 `NOT_ACCEPTED`。待决事项：彩色 Tag 内火焰图标轮廓着色、Modal 与图片预览共用入场动效、CountUp 具名缓动、Rate 星形轮廓、Tabs 选中圆点颜色、参考近似重复色是否合并。

## Not yet verified / 尚未验证

| Area | Boundary / 边界 |
|---|---|
| Browser hover | Qualified intermediate raw frames in Chrome and Edge are incomplete. / Chrome、Edge 悬停中间原始帧证据不完整。 |
| Edge narrow viewport | The required actual 375px after-state capture remains outstanding. / 仍缺实际 375px 的修复后画面。 |
| Native presentation | Rendered application pixels do not establish OS outer-window or physical-panel presentation. / 应用像素不证明系统外窗或物理屏幕呈现。 |
| Packaged onsite use | Fresh package hashes and builds do not replace a new mouse/keyboard/hover/performance run of those binaries. / 新包校验与构建不能替代对应二进制现场复测。 |
| Notification/Tooltip motion | Entry/exit translation now rounds to whole device pixels (2026-11-13); all 42 surface-sampling cases pass at the unchanged 0.25 threshold in the Flutter test host at pixel ratios 1 and 1.25. The Windows-engine run of the same oracle has not been repeated; the earlier 18 failed measurements remain historical evidence, not passes. / 进出场位移现按整设备像素取整；测试宿主（像素比 1、1.25）下 42 项表面采样在原 0.25 阈值内全部通过。同一断言尚未在 Windows 引擎重跑；此前 18 项失败保留为历史证据。 |
| Full performance | No quiet-load, all-component, all-state, all-platform 60fps certification. / 未证明低负载及全组件、全状态、全平台 60fps。 |

Screen-reader execution is outside the completed scope; excluded does not mean tested or certified. Semantic contracts and keyboard tests remain maintained. Mobile platforms need separate validation.

读屏器运行不在已执行范围内，排除不等于通过或认证；语义契约及键盘测试继续维护。移动平台需要独立验证。

## Verification method / 验证方法

Compare the same route, viewport, DPR, fonts, theme, input state and animation phase. Check entry, exit, reversal, rapid reopening, cancellation, disposal and reduced motion. Validate actual composited colors, including alpha, images, gradients and nested controls, against the design budgets. Preserve callback rejection, borrowed-resource ownership and explicit child styling.

对齐路由、视口、DPR、字体、主题、输入状态及动画阶段；覆盖进入、退出、反向、快速重开、取消、卸载和减少动态效果。按设计预算检查 alpha、图片、渐变及嵌套控件的实际合成色，并保留回调拒绝、借用资源所有权和显式子样式。

Commands and test ownership are documented in [MAINTENANCE](MAINTENANCE.md). Raw logs, source-bound measurements and private review records are stored outside the public product repository; this page publishes the user-relevant boundary without embedding workstation paths or session history. Source changes require fresh evidence for the changed scope.

命令和测试职责见[维护说明](MAINTENANCE.md)。原始日志、源绑定测量和私有审查记录保存在公开产品仓库之外；本页公开使用边界，不嵌入本机路径或会话历史。源码变更后必须按受影响范围重新验证。
