# Verification and limitations / 验证与限制

This experimental library has scoped usability evidence, not complete production or all-platform visual acceptance. A build, registered route or passing widget test does not establish every visible state. Original failed measurements remain failures; accepted limitations are not passing tests.

本实验库具有有限范围的可用性证据，尚未完成完整生产或全平台视觉验收。构建、路由登记和组件测试通过不代表全部可见状态通过；已接受的限制不将原始失败改成通过。

## Accepted limits / 已接受限制

- **Select semantics:** the supported SDK projects button/text-field semantics rather than the complete combobox role. Keyboard, focus, names, states and IME remain required. No SDK fork or DOM shim is used.
- **Home and Carousel contrast:** only the named Gallery wallpaper text and photo captions follow the reference-priority exceptions in [DESIGN](DESIGN.md#home-host-and-photo-gradient). They may fall below 4.5:1. Other text, controls and focus retain their existing requirements.
- **Icon scrolling:** actual-load scrolling can have long observation intervals. Simultaneous host activity may contribute, but has not been established as the sole cause. There is no all-content or all-platform 60fps guarantee.
- **Notification/Tooltip measurements:** 18 ink-centroid numerical tests remain failing under the retained threshold. Rigid controls also exceed that criterion, so it alone cannot identify component-specific animation desynchronization. The renderer is retained; a precise engine cause and perceptual lag have not been established. Root-test failure also prevents the current sequential CI workflow from reaching later steps; a local build does not mean hosted CI is green.

- **Select 语义：**受支持 SDK 使用 button/text-field 投射，未实现完整 combobox 角色；键盘、焦点、名称、状态和输入法要求保持，不使用 SDK 分叉或 DOM 垫片。
- **首页及轮播对比度：**仅[设计契约](DESIGN.md#home-host-and-photo-gradient)明确的首页背景文字和照片说明采用参考优先例外，可能低于 4.5:1；其他文字、控件及焦点不豁免。
- **图标滚动：**实际负载下可能出现较长观测间隔；同时使用电脑可能贡献负载，但未证明是唯一原因，不承诺全内容、全平台 60fps。
- **通知／气泡测量：**原阈值下仍有 18 项墨量质心数值测试失败。刚性对照也超限，因此不能仅凭此指标判定组件动效不同步；保留现有实现，不声称已确定引擎原因或感知延迟。根测试失败会使当前串行 CI 停在该步骤，本地构建通过不代表远端 CI 全绿。

## Not yet verified / 尚未验证

| Area | Boundary / 边界 |
|---|---|
| Browser hover | Qualified intermediate raw frames in Chrome and Edge are incomplete. / Chrome、Edge 悬停中间原始帧证据不完整。 |
| Edge narrow viewport | The required actual 375px after-state capture remains outstanding. / 仍缺实际 375px 的修复后画面。 |
| Native presentation | Rendered application pixels do not establish OS outer-window or physical-panel presentation. / 应用像素不证明系统外窗或物理屏幕呈现。 |
| Packaged onsite use | Fresh package hashes and builds do not replace a new mouse/keyboard/hover/performance run of those binaries. / 新包校验与构建不能替代对应二进制现场复测。 |
| Full performance | No quiet-load, all-component, all-state, all-platform 60fps certification. / 未证明低负载及全组件、全状态、全平台 60fps。 |

Screen-reader execution is outside the completed scope; excluded does not mean tested or certified. Semantic contracts and keyboard tests remain maintained. Mobile platforms need separate validation.

读屏器运行不在已执行范围内，排除不等于通过或认证；语义契约及键盘测试继续维护。移动平台需要独立验证。

## Verification method / 验证方法

Compare the same route, viewport, DPR, fonts, theme, input state and animation phase. Check entry, exit, reversal, rapid reopening, cancellation, disposal and reduced motion. Validate actual composited colors, including alpha, images, gradients and nested controls, against the design budgets. Preserve callback rejection, borrowed-resource ownership and explicit child styling.

对齐路由、视口、DPR、字体、主题、输入状态及动画阶段；覆盖进入、退出、反向、快速重开、取消、卸载和减少动态效果。按设计预算检查 alpha、图片、渐变及嵌套控件的实际合成色，并保留回调拒绝、借用资源所有权和显式子样式。

Commands and test ownership are documented in [MAINTENANCE](MAINTENANCE.md). Raw logs, source-bound measurements and private review records are stored outside the public product repository; this page publishes the user-relevant boundary without embedding workstation paths or session history. Source changes require fresh evidence for the changed scope.

命令和测试职责见[维护说明](MAINTENANCE.md)。原始日志、源绑定测量和私有审查记录保存在公开产品仓库之外；本页公开使用边界，不嵌入本机路径或会话历史。源码变更后必须按受影响范围重新验证。
