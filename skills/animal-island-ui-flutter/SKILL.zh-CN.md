# Animal Island Flutter 工作约定

本文件是同目录 SKILL.md 的中文说明，不是独立实现。签名读取 `lib/animal_island_ui.dart` 的公开声明，行为读取对应 `components/*/contract.json`；组合规则见 [API](../../docs/API.md)，视觉规则见 [DESIGN](../../docs/DESIGN.md)，范围由 [library.json](../../library.json) 拥有。

## 选择职责所有者

- 父级拥有约束、已提交的受控值及接受／拒绝变更请求的决定。
- 组件拥有表面、临时交互、焦点行为及自有资源；借用控制器和焦点节点仍归调用方，处理回调重入、取消和卸载。
- 共用机制只有一个所有者：AnchoredPanel 管锚定定位与外部关闭，ActionSurface 管激活，ContentScope 管被动插槽默认值，ViewportOverlay 管整窗呈现；选择、搜索和生命周期仍归组件。
- 子内容显式样式、状态、Key、操作和语义优先，不检查或重构任意 Widget；嵌套操作不得触发父容器。
- 动态列表使用稳定 ID，不维护两份已提交的分页／选择状态。Table 中依赖约束的单元格须指定列宽，不双重挂载或检查不透明单元格。
- Gallery 使用 app/pages/shared 和公共库入口；响应式换行归父行布局，组件保留尺寸契约，不做 Gallery 专用替身或平行色板。

## 配色和动效

使用既有主题／实例样式角色和规定优先级；透明是显式值。字形与语义前景分开，调用方 TextStyle.foreground Paint 保留 Flutter 优先级。任意自定义配对须验证实际合成背景及状态，不在运行时猜色。

遵循[共享配方](../../docs/DESIGN.md#original-color-restoration)、[共享强调前景](../../docs/DESIGN.md#shared-accent-foreground)及[标题前景](../../docs/DESIGN.md#title-foreground)。被动插槽颜色与嵌套控件表面数据各自负责，保留无关 ThemeExtension 和显式内容样式。

进入、退出、反向、重开、取消、卸载、主题切换和减少动态沿用唯一内容子树及生命周期。[表面采样](../../docs/DESIGN.md#surface-sampling)不授权对子文字补偿或全局加滤镜；[首页／照片例外](../../docs/DESIGN.md#home-host-and-photo-gradient)仅适用具名 Gallery 区域。

## 原子扩展

未知行为先观察固定[参考身份](../../docs/reference-gallery.json)对应实现；代码示例可适配 Dart，不能自行发明产品行为。同批更新声明、契约、实现、全部消费者、测试、文档及双语 Skill。仅维护一种机制，不添加别名、兼容分支、平行色板或仅供测试读取的生产接口。

先用公共接口测试验证受影响的所有权和生命周期，再执行所需更广检查；真实平台行为、组件测试和构建结果分别报告。[验证限制](../../docs/ACCEPTANCE.md)如实保留，排除读屏不等于认证；不能为 CI 变绿而改门槛或跳过失败。

## 命令

根目录使用 `flutter test test/<affected_test>.dart`、`flutter analyze --fatal-infos` 和 `python -B tool/reference_coverage.py`。在 `example` 中按范围运行相关测试及 `flutter build web`／`flutter build windows`。`python -B tool/verify.py --flutter <configured-flutter> --builds` 执行维护中的检查序列，详见[维护说明](../../docs/MAINTENANCE.md)。

本地诊断放入已忽略的 scratch/evidence 目录；保留来源许可及[分发边界](../../docs/RIGHTS.md)，发布须有用户授权。不在产品文档嵌入本机路径、会话指令或逐日执行记录。
