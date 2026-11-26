# Animal Island Flutter 工作约定

本文件是同目录 SKILL.md 的中文说明，不是独立实现。`lib/animal_island_ui.dart` 列出公开内容；签名和默认值在声明该符号的文件里，对应 `components/*/contract.json` 的 `interface.inputs` 给出链接，部分类共用文件（`IslandButton` 在 `actions.dart`，`IslandSwitch` 与 `IslandTextField` 在 `inputs.dart`，图表数据类型在 `chart/model.dart`）。行为读取该契约；组合规则见 [API](../../docs/API.md)，视觉规则见 [DESIGN](../../docs/DESIGN.md)，范围由 [library.json](../../library.json) 拥有。

## 在应用中使用

适用于用本库开发应用；修改库或 Gallery 时直接看后面各节。

1. 以路径依赖引入，只导入 `package:animal_island_ui/animal_island_ui.dart`；安装步骤和完整起步示例见 [README](../../README.md)。无需另加 `flutter_localizations` 依赖。
2. 配置 `MaterialApp(theme: IslandTheme.create(), darkTheme: IslandTheme.create(brightness: Brightness.dark), localizationsDelegates: IslandLocalizations.delegates, supportedLocales: IslandLocalizations.supportedLocales)`。运行时切换明暗主题时，再按 [API](../../docs/API.md) 在 `Scaffold.body` 内用 `IslandThemeHost(data: 已解析的目标主题, child: ...)` 包住内容。
3. 颜色取自 `IslandTheme.of(context)` 的 Token 或 `IslandColorway`，不写颜色字面量。
4. Card、Title、Modal、Drawer、Notification、Tooltip 与 Table 是固定浅色表面：深色应用中它们内部的 `Theme.of(context)` 仍是浅色。读取或断言应用主题时使用它们外部的 context。
5. 内置文案（占位文字、空状态文字、关闭与清除名称、选择器页脚、Modal 默认按钮）跟随 `IslandLocalizations`，支持中文和英文：注册 delegates 且语言为 `zh` 时为中文，否则为英文。只有想改文案时才传入自己的文字；其他语言需逐项传入字符串，并给 `showIslandModal` 传 `actions:`。`IslandTime` 使用自身的 `locale`。

| 需求 | 用法 |
|---|---|
| 带校验的表单 | `IslandForm` 配合 `IslandFormTextField` 与 `IslandFormField<T>`；构建器收到的 `IslandFormBinding`（`value`、`onChanged`）用于接入 Select、Switch 和选择器。`required: true` 只画标记，规则要写成 `IslandFormValidator`（`FutureOr<String?> Function(T? value, Map<String, Object?> values)`）。编辑和提交时都会校验 |
| 在字段外提交 | 创建 `IslandFormController` 并传给 `controller:`（不能与 `initialValues:` 同时使用），调用 `controller.submit()`；校验通过触发 `onFinish`，否则触发 `onFinishFailed`。控制器由创建者释放 |
| 通知 | 用 `IslandNotifications(controller:, child:)` 包住内容，控制器由你创建和释放；调用 `controller.show(IslandNotification(...))`。默认时长 4.5 秒 |
| 确认对话框 | `showIslandModal(actions: (ctx) => [...])`；默认按钮只负责关闭。自定义按钮用 `Navigator.of(ctx, rootNavigator: true).pop(result)` 关闭 |
| 按钮 | 主操作用 `IslandButtonVariant.primary`；默认变体是 `normal` |
| 图标名称 | `lib/src/foundation/icon_names.dart` 中的 `IslandGlyph`，或 Gallery 的 Icon 页 |

应用的组件测试：给测试视图设置桌面尺寸的画布；校验是异步的，编辑和提交后使用 `pumpAndSettle`；测试结束前推进时间越过通知时长。

### 应用中的开销与无障碍

- 长列表要惰性挂载（`ListView.builder`、`GridView.builder`）。由动作表面构成的每个条目（`IslandCard`、`IslandTag`、按钮）都是带自有焦点节点的有状态元素，在 `Column` 或 `Wrap` 中一次挂载几百个，会在用户滚动之前就付出内存和构建时间。
- 普通 `IslandCard` 是开销最小的形态：只有 `hoverable: true` 才会加上悬停上浮动画。列表里的静态卡片不要打开它。
- 谁创建谁释放。库只释放它自己创建的控制器和焦点节点，你传入的 `IslandFormController`、`IslandNotificationsController`、`FocusNode`、`ScrollController` 仍归你负责。
- 控件已自带无障碍名称（`IslandIconButton.label` 是必填参数）。应用仍可能破坏的是自身布局：对关键页面用 `TextScaler.linear(2)` 和 `MediaQueryData(disableAnimations: true)` 测试，并运行 `meetsGuideline(labeledTapTargetGuideline)`。

## 选择职责所有者

- 父级拥有约束、已提交的受控值及接受／拒绝变更请求的决定。
- 组件拥有表面、临时交互、焦点行为及自有资源；借用控制器和焦点节点仍归调用方，处理回调重入、取消和卸载。
- 共用机制只有一个所有者：AnchoredPanel 管锚定定位与外部关闭，ActionSurface 管激活，ContentScope 管被动插槽默认值，ViewportOverlay 管整窗呈现；选择、搜索和生命周期仍归组件。
- 子内容显式样式、状态、Key、操作和语义优先，不检查或重构任意 Widget；嵌套操作不得触发父容器。
- 动态列表使用稳定 ID，不维护两份已提交的分页／选择状态。Table 中依赖约束的单元格须指定列宽，不双重挂载或检查不透明单元格。
- Gallery 使用 app/pages/shared 和公共库入口；响应式换行归父行布局，组件保留尺寸契约，不做 Gallery 专用替身或平行色板。

## 配色和动效

所有颜色都是具名 Token：基础色板 → `IslandTokens`／`IslandColorway` → 组件配方；Gallery 颜色归 `GalleryPalette`。新值作为 Token 加在所有者处；组件和 Gallery 页面不写颜色字面量，也不写 `参考 ? 字面量 : Token` 分支，由 `test/color_literal_policy_test.dart` 与 `tool/verify.py` 策略检查。因对比度而与参考不同的颜色登记在[实测配色差异](../../docs/DESIGN.md#measured-color-differences)。

使用既有主题／实例样式角色和规定优先级；透明是显式值。字形与语义前景分开，调用方 TextStyle.foreground Paint 保留 Flutter 优先级。任意自定义配对须验证实际合成背景及状态，不在运行时猜色。

遵循[共享配方](../../docs/DESIGN.md#original-color-restoration)、[共享强调前景](../../docs/DESIGN.md#shared-accent-foreground)及[标题前景](../../docs/DESIGN.md#title-foreground)。被动插槽颜色与嵌套控件表面数据各自负责，保留无关 ThemeExtension 和显式内容样式。

进入、退出、反向、重开、取消、卸载、主题切换和减少动态沿用唯一内容子树及生命周期。[表面采样](../../docs/DESIGN.md#surface-sampling)不授权对子文字补偿或全局加滤镜，Notification 与 Tooltip 改为整个表面按整设备像素位移；[首页／照片例外](../../docs/DESIGN.md#home-host-and-photo-gradient)仅适用具名 Gallery 区域。

## 图表、日历与图标

图表种类通过对应的 `IslandChartData` 具名构造函数选择，数据形状和无效数据规则见 [API](../../docs/API.md#reference-400-additions)；地图须由调用方提供区域轮廓，空状态使用 `IslandNoData`。Calendar、Chart、NoData 的界面文案取自 `IslandLocalizations`，没有其 `zh` 语言时显示英文。`IslandGlyph`（709 个，naive-icons v1.14.0）只能通过运行 `python -B tool/import_icons.py` 改动，不得手改 `assets/icons`；配色结果经实测并由所有者整体接受，未逐个审查（`docs/icon-paint-roles.json` 中 `import_v1_14.settled` 所列按所有者规则 O7 保留的 15 项角色不在对比度矩阵认证范围内）。

## 原子扩展

未知行为先观察固定[参考身份](../../docs/reference-gallery.json)对应实现；代码示例可适配 Dart，不能自行发明产品行为。同批更新声明、契约、实现、全部消费者、测试、文档及双语 Skill。仅维护一种机制，不添加别名、兼容分支、平行色板或仅供测试读取的生产接口。

先用公共接口测试验证受影响的所有权和生命周期，再执行所需更广检查；真实平台行为、组件测试和构建结果分别报告。[验证限制](../../docs/ACCEPTANCE.md)如实保留，排除读屏不等于认证；不能为 CI 变绿而改门槛或跳过失败。

## 命令

根目录使用 `flutter test test/<affected_test>.dart`、`flutter analyze --fatal-infos` 和 `python -B tool/reference_coverage.py`。在 `example` 中按范围运行相关测试及 `flutter build web`／`flutter build windows`。`python -B tool/verify.py --flutter <configured-flutter> --builds` 执行维护中的检查序列，详见[维护说明](../../docs/MAINTENANCE.md)。

本地诊断放入已忽略的 scratch/evidence 目录；保留来源许可及[分发边界](../../docs/RIGHTS.md)，发布须有用户授权。不在产品文档嵌入本机路径、会话指令或逐日执行记录。

调用方自有虚线框使用公共根入口的 `IslandDashedBorderPainter`；形状、画笔及间距配方仍归调用方，行为遵循[绘制契约](../../docs/API.md#dashed-stroke)。不复制路径切段循环，不导入包内私有源码。Gallery 受约束示例行引用[唯一父布局权威](../../docs/DESIGN.md#gallery-parent-layout)；现行性能限制引用 [ACCEPTANCE](../../docs/ACCEPTANCE.md)，不以历史可选基准提案作为当前门槛。
