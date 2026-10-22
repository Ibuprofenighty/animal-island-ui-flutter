# Common patterns 与父子关系

## Current work scope / 当前工作范围 (2026-10-17)

User scope decision, 2026-10-17: all screen-reader execution and validation are excluded from this work, including NVDA and other readers. Do not install or start reader software, request reader validation, or keep it as a remaining acceptance blocker. Excluded is not passed or certified. Preserve existing semantic metadata, keyboard navigation, focus behavior, contrast requirements and their tests. No new software may be installed for acceptance. Historical reader-related pending notes below do not define the current work scope.

用户于2026-10-17明确将所有读屏软件运行与验收从本工作范围中排除，包括NVDA及其他读屏器。不得安装或启动读屏软件、再次要求读屏验收，或将其保留为待完成的验收阻塞项。排除不等于通过或认证。保留现有语义信息、键盘导航、焦点行为、对比度要求及相应测试。验收不得安装新软件。下文历史记录中的读屏待验收说明不再定义当前工作范围。

执行依据为 ARCHITECTURE.md；本页列出新增组件的检查入口，不维护另一套架构。

- 为新组件指定值、暂态、资源、样式、语义五类所有者。
- 有集合就用稳定 ID；不能把索引当持久身份。
- 有 child/header/footer/icon 插槽就测试父级默认值与子级显式值的优先级。
- 有父子交互就测试子级激活不触发父级、键盘同等行为、禁用不发事件。
- 有异步就测试替换、拒绝、取消、卸载、乱序返回。
- 有浮层就测试嵌套关闭、焦点返回和子主题传递。
- 公共模式先找实际第二个消费者；没有就保留局部实现。
- 展示页使用公共组件；新增组件不得修改无关组件内部。
- 更新公共导出、组件契约、展示故事、消费者和验收状态。
- 不能把无障碍或跨平台问题用改动参考视觉来掩盖；记录差异并单独解决。

IslandDialogRoute is the public shared route for caller-owned preview/alert content. Push it on the root Navigator and retain its identity for exact-route cleanup. It captures caller themes and supplies opaque displacement and reduced-motion settlement; the builder owns dialog surface, semantics and actions. Gallery Form/Notification keep their existing AlertDialog adaptations, Upload keeps its560px normal IslandModal, and core Image/Upload reuse this same route. The old internal route name/path is removed. showIslandModal retains its independently observed game-dialog scale/timing. Real platform callback geometry and input acceptance remain pending; screen-reader validation is excluded by the current user scope decision.

IslandDialogRoute 是调用者自有预览/提示内容的公共共享路由。应推入根 Navigator 并保留路由身份，以便只清理本实例。路由捕获调用者主题，统一提供不透明位移和减少动态时的结算；内容、表面、语义和操作仍归 builder。Gallery Form/Notification 保留现有 AlertDialog 适配，Upload 保留560px普通 IslandModal，核心 Image/Upload 复用同一路由。原内部路由名称及路径已移除。showIslandModal 保留已独立观察的游戏弹窗缩放和时序。真实平台的回调几何与输入仍待验收；读屏验收已按当前用户范围决定排除。
