# Animal Island Flutter 工作约定

## Current work scope / 当前工作范围 (2026-10-17)

用户于2026-10-17明确将所有读屏软件运行与验收从本工作范围中排除，包括NVDA及其他读屏器。不得安装或启动读屏软件、再次要求读屏验收，或将其保留为待完成的验收阻塞项。排除不等于通过或认证。保留现有语义信息、键盘导航、焦点行为、对比度要求及相应测试。验收不得安装新软件。下文历史记录中的读屏待验收说明不再定义当前工作范围。

本文件是同目录 SKILL.md 的中文说明，不是第二个独立 Skill。

先读取仓库 AGENTS.md、docs/DESIGN.md、对应组件契约和公共入口的实际声明。library.json 定义范围；reference-gallery.json 定义参考。使用 tool/reference_coverage.py 检查页面覆盖；侧栏链接不代表实现，NOT_ACCEPTED 不得改称完成。

## 验证与历史证据入口

当前源绑定验收和待验项只由原交付工作区的 `scratch/global-audit-20261014T035753Z/report.json` 维护，该记录不在库包或完整源码 ZIP 内。交付入口同时提供该记录和 `outputs/cold-archive-20261021/index.html` 冷归档索引；历史参考输入仍保留原身份，未展开的旧路径不等于证据缺失。按归档说明只读取所需成员，不把旧测试、CPU／轮次统计或匹配输入复用当成变更后整份源码的完整验收。

新增组件必须保持所有权：
- 父级负责约束、受控值和接受或拒绝变更请求。
- 组件负责自身外观、焦点、临时交互状态及自有资源清理。
- 共用模式负责完整且单一的重复职责：AnchoredPanel 管定位与外部点击关闭，ActionSurface 管激活，ContentScope 管插槽默认样式；选择和搜索仍归各组件。
- 全屏浮层使用 ViewportOverlay，避免零尺寸或屏外触发点导致语义丢失；锚定控件仍用 AnchoredPanel。全屏浮层捕获框架主题、语言、方向和媒体信息，业务 Provider 值由宿主显式传入。
- 子插槽保留显式样式、事件、焦点、Key 和语义；禁止检查任意子 Widget 类型后重写后代。子按钮不得激活父容器。
- 受控回调只是请求，拒绝更新后显示值不变。列表使用稳定标识而不是索引。
- 外部传入的控制器与焦点节点属于借用资源。取消过期异步工作并防御回调重入。

只因外观相似不能创建万能组件；先明确共同不变量和完整接口。Gallery 使用 app/pages/shared，只消费公共库入口，不能藏入展示专用组件实现。

交付顺序：契约 → 公共组件 → 显式导出 → 可运行展示与 API 文档 → 消费者和组合测试 → 平台与视觉验收。按需验证拒绝更新、嵌套事件、实例隔离、禁用、重排、焦点归还、减少动态效果和卸载。

未知外观及交互先看参考站和固定版本公开源码；不自行重设计，不复制旧本地 Flutter 库。代码示例可以适配为 Dart。结构、行为、视觉、辅助技术和发布分别报告；测试通过不等于视觉一致或可商用完成。

根目录运行 flutter test test/<相关测试>.dart、flutter analyze --fatal-infos 和 python tool/reference_coverage.py；example 下运行 flutter test、flutter build web、flutter build windows。诊断保存在 scratch/。保留资产来源和已有字体授权记录；发布须有用户授权。

- Table 负责数据切片，并向 Pagination 传入受控 IslandPaginationValue；不要建立两份已提交页码。行与列由宿主提供稳定标识，单元格操作独立于行操作。
- Table 自动列按内容固有宽度布局；LayoutBuilder 等依赖父约束的单元格必须显式设置 column.width。共享列布局归 Table 所有，不检查、重建或重复挂载单元格 Widget。
- Table 行框是最小布局约束，不是固定行高。文字缩放或更高的不透明子组件必须撑开行；内联装饰的绘制边距不能擅自扩大所属文本行。

- 悬停/焦点装饰变化时保持包裹层级稳定；使用空装饰，避免重新挂载子状态。ManagedImage 管解码事件；Carousel 保留子状态并只暴露当前项。子输入框保留键盘事件。
- Tooltip 观察悬停/焦点；点击由子控件显式组合 toggle 与自身动作。不得检查、改写触发子树或截获指针事件。AnchoredPanel 管定位，Tooltip 管时序。

- 通知使用局部所有的控制器和一个借用控制器的宿主。异步进度更新保留返回的句柄；关闭后的句柄拒绝更新。不得通过过期回调重新创建通知，也不得使用进程级全局单例。

- Drawer 必须位于 Navigator Overlay 下的显式 IslandDrawerHost 中；宿主只负责其页面的景深和底色，不改动无关根节点。Cursor 作用域只改变光标优先级，不重写或拦截子控件手势。
- DatePicker 使用明确的单日期/范围及受控/非受控构造器。待选值与已提交值分离；复用选择器结构和 AnchoredPanel 的可取消动效。每条提交路径都必须检查禁用日期。

- Form 通过 IslandFormField 的类型化 builder 和 IslandFormTextField 适配器绑定值。禁止识别并重写子控件来注入 value、回调或 disabled。重排时保留调用方的 Widget key。异步校验完成后，必须匹配字段注册身份及值版本，才能更新错误状态或提交。

- Upload 显式接收文件选择、请求和拖放适配器。父级拥有受控文件列表；组件拥有逐文件取消和进度串行提交。平台 IO 从 animal_island_upload_platform.dart 导入。禁止在生产上传中隐式模拟成功。触发器 child 仅承载展示内容，不嵌套其他按钮。 待决选择／预检／删除的结果与错误须仍属于当前操作世代；删除还须匹配当前文件来源。禁用、卸载或文件替换会抑制过期错误，当前有效错误仍只报告一次。仅禁用不会取消已接受的传输。

- 明确指定的输入尺寸不得被桌面紧凑密度缩小。共享浮层清理在树更新后只移除自有路由，不能直接弹出栈顶路由。Upload 预览构建器显式接收 BoxFit；预检先于图片字节读取。

- Form 标签通过 onLabelPressed 显式连接动作。文本适配器拥有内部焦点节点或借用调用方节点；不得销毁借用节点。禁用字段不响应标签点击。

- ViewportOverlay 借用展示路由的焦点作用域参与键盘遍历，Overlay 负责位置。保持装饰包装稳定，焦点轮廓不得增加边框内边距。Notification closeIcon 是不透明视觉插槽，在 22px 操作区域内按固有宽度居中；关闭逻辑使用 onDismiss。

- Button 类型配色、立体阴影和加载图形由 Button 所有；ActionSurface 只复用激活行为，不承载通用外观配方。Busy 只拥有展示动画，异步业务由宿主负责。虚线与实线边框预留相同空间，保留子内容的显式样式。 [Button 契约](../../components/button/contract.json)拥有 ButtonStyle 实际支持范围、逐状态回落与最终前景规则。IconButton 继承 IslandButtonTheme，没有实例style入口；显式 foreground Paint 保留 Flutter 优先级，不作为默认Color角色自动推导。透明是显式值，默认证据不认证任意调用方配色。

- 父级动作可选时，不得按回调有无切换包装类型。Card、Tag、Table 保持同一 ActionSurface 和稳定的子焦点连接；被动悬停不伪造动作。移除父回调时保留子焦点与局部状态；键盘激活只属于持有主焦点的动作。

- Tag 默认 soft，与实际 Gallery 和固定源码一致；参考 API 表的 solid 是文档错误。实心标签显式指定 solid。内部焦点连接不得额外插入语义分组，把独立子动作合并。Button/Tag/Collapse 共用不占布局的轮廓绘制，各自拥有颜色、形状、宽度、偏移与动效。Button/Tag 保持 2px 外圈及 2px 间隔；Collapse 使用由圆角表面裁切的 1px 黑色矩形内圈。

- Typewriter 的普通/富文本构造器支持可选 strutStyle，行高由调用方明确指定。只有设计需要时才强制行高；保留文字缩放与显式 span 样式。

- Title 拥有水平固有宽度的表面，三种变体都提供默认不换行与可见溢出。宿主负责位置和布局占位约束，表面溢出是参考行为。依赖有限宽度的不透明子组件须自行约束；保留其显式样式、Key、状态和语义，不用 Gallery 偏移或检查子树修复 Title 换行。
- Collapse 拥有问题／答案的继承排版默认值。Gallery StoryText 是自有纯字符串叶子，不是库公共组件：从继承样式派生 strut 与随缩放变化的 CSS 1/64 像素行盒，只测量自身字符串。Gallery 内 Modal／Drawer 的叶子度量共用 storyTextStrut；包消费者自行定义其叶子文字度量，不得导入 Gallery 辅助。不得把这些辅助施加到不透明子组件，也不复制组件字号／配色规则。保留文字缩放；引擎字形行推进仍独立舍入。几何测试不证明文字像素完全一致，Windows／Web 视觉核验仍待完成。

- 多行布局使用 IslandTypewriter.builder 提供的字素前缀，不另建计时器或遍历 Widget 树。Modal 拥有标题/正文默认样式、表面与路由/焦点行为；叶子 Text 可从继承样式派生强制行高度量。默认操作仅关闭所属路由，自定义操作由宿主决定提交；onClose 是 Esc 意图，不是关闭图标开关。

- 为有名称的 Modal 传入 semanticLabel，不从任意标题 Widget 提取文本。Modal 保留独立标题语义，并将对话框语义边界限定到自身表面。

- 浮层光标范围必须保留命中所有权。Modal 的表面与路由遮罩分别组合 Cursor；遮罩上方的整页光标容器会吞掉外部点击。异形与普通表面都要分别验证正文点击和遮罩点击。

- 纯视觉浮层必须在入口最外层排除语义和命中，覆盖 Focus/Localizations 等包装。只排除绘制子节点仍可能留下全屏空 Web 语义节点，挡住真实控件。借用焦点的桥接节点不生成自身语义，交互子组件保留自己的语义。

- 采用样式前先核实实际渲染行为。Select 虽有未使用的淡出样式，实际关闭是立即卸载。AnchoredPanel 拥有浮层生命周期，Select 拥有自身动效和悬停样式。清除子操作仅发出意图，不触发父级展开切换；只有已提交选择绘制选中底纹。

- Select 的父级按键处理必须忽略清除子控件的焦点。搜索编辑和 Escape 清空查询属于局部展示状态，已提交值仍由父级拥有。 保留活动输入法缓冲及范围，onSearch仅取逻辑查询后缀，提交／结束后再去掉所属标签前缀且不重复通知。候选按键归组合中的编辑器；结束会话整理不得抢清除焦点或改用宿主后来提交的标签。非搜索触发器公开自身主焦点状态与聚焦动作，搜索焦点由 TextField 保留。列表、触发器和清除按钮的语义独立；枚举存在不等于平台已支持该角色。
- Drawer 在自己拥有的遮罩和面板上组合 Cursor，装饰层不得拦截命中。显式传入 semanticLabel（默认 null），禁止读取标题子树推断名称；closeLabel（默认“关闭”）提供标题栏关闭按钮的名称。宿主负责景深，抽屉负责焦点与动画，子操作不冒泡为关闭。

- CountUp/Countdown 仅共用 NumberSurface 外层装饰和 NumberPlate 内层样式，时间轴、回调与语义仍归组件。CountUp 的 semanticLabel（String?，默认 null）显式命名数值；builder/前后缀仅展示，操作控件放在外部，不检查子 Widget 推断名称。

- 范围调整必须同时删除废弃实现、导出及专属消费者，不保留仅用于维持旧接口的迁移命令、别名、shim 或测试。新违规先登记审计 report 再修复，不能用关键词扫描代替全局清理结论。

- 公共 Dart 声明是完整签名与默认值的唯一来源；组件输入契约链接该所有者，契约保留行为要求，Gallery/文档解释用法。更改导出时核对全部引用，不再增加手工参数清单来修补漂移。

- 展开／收起状态必须与名称、操作位于同一触发节点；折叠、日期时间触发器和分页尺寸菜单通过 ActionSurface 表达，不加仅有展开状态的父节点，也不合并独立清除动作。保留全部对比度颜色对和门槛；参考一致不能豁免失败，详见 docs/ACCEPTANCE.md。必要配色修正已按 docs/DESIGN.md 获授权；先登记实际前景、背景、状态差异，只维护一套产品配色，不降低阈值或加并行色板。Tabs 发出稳定值而非下标。

日期/时间焦点退出使用共享 PickerFocusBoundary：仅退回焦点域、没有外部控件目标的失焦保留面板；焦点明确转移到外部控件才关闭。外部点击由 AnchoredPanel 负责，值和展开请求由组件负责，触发器与清空动作语义分离。不加入 DOM 焦点补丁或平台特例。

每个动作只保留一个语义名称来源。Picker 页脚由可见文字命名；时间值/单位和清空动作的显式名称仅排除自身重复或装饰文字。禁止通过 ActionSurface 全局屏蔽不透明子组件语义来消除重复。

- 参考动效：Title 双层纸/折角悬停以200ms ease 放大到1.06，飘带不缩放。Collapse 分别使用300ms 展开和250ms 图标/留白时间线。Checkbox/Radio 共用固定勾选路径，提交后即时绘制完整标记，散点装饰动画600ms。策略归组件所有，减少动画设置直接跳到终点；不因此改变色板或对比度阈值。

- Switch 内部标签决定固有宽度，最小宽52px（小尺寸38px）；不要为文字固定加宽。保留参考滑块内缩、250ms 缓动及600ms 加载环；加载内容保持不透明以维持对比度，减少动画时停止旋转。

自定义参考边框通过公共入口使用 IslandTheme.borderWidth(context, logicalWidth)。正边框向下取整至物理像素且至少保留一个像素；不要复制DPR公式，也不要用于字形行高。Gallery中文字体使用参考400/500/700轮廓，注册为400/500/900，使600..900使用参考粗体轮廓且不合成加粗。映射由字体配方负责，不改写不透明文字子树，也不增加另一套回退字体。

Rate键盘以已提交值为准，在边界停止：右/上增加、左/下减少。仅一颗星进入Tab顺序，受控拒绝不改变选中值。新星弹跳350ms、交错60ms，最后一颗新星扩散600ms。

Radio/Rate暴露radioGroup语义；互斥与选中标记由同一操作节点持有，Checkbox仍为独立复选框。

Skeleton 段落共用一道扫光；rowWidths 不足时重复最后一个比例，空列表使用全宽。Loading 在减少动态效果时冻结雪花、稳定入场并立即完成退出；内容和底板始终不透明。BackTop 聚焦装饰不改变其64px布局。这些局部修正不代表全状态视觉验收完成。

- 语义配色：文字、焦点和必要控件轮廓使用 IslandTokens 对应可读角色；品牌填充分别与 onLeaf/onSun/onDanger 配对。IslandColorway.ink 用于浅色纸面，onAccent 用于对应实色。不得推测祖先像素或重写不透明子内容样式。Switch 用一个自有可访问名称表达 toggled 状态。Windows/Web 全状态验证仍待完成。

- 固定浅色 Card 为后代建立浅色表面 Theme，保留其余 ThemeExtension 和显式子样式。Card/Tag 换色时前景与填面原子切换，位移/阴影动效继续；透明 Tag 采用表面文字角色。图片与 Tag 的双层焦点轮廓不依赖背景像素。Loading 装饰反向按剩余距离缩短，整体移除由独立退出计时器拥有；重新激活取消移除，必要层仍显示时背景不可操作。

Gallery 色块直接读取 IslandTokens.light，禁止在消费者文档中复制旧配色。Title 示例小字使用公开色板中适合图案表面的可读前景色。

Tabs/Pagination 的选中配色原子更新以保持可读；透明内容跟随宿主主题，固定浅底输入与弹层保持浅色配方。此配色例外不移除阴影和箭头旋转动效。

### 已批准的可读动效

全库只有一套可读动效规则：必要文字、数字、图标、操作控件及其底色/边界在入场、退出、反向和中断的每一帧保持不透明且达标。危险色彩插值改为色对同步切换，保留适度位移、缩放和装饰运动；装饰不得破坏实际内容背景。减少动态效果直接稳定同一状态机。每个所有者只保留一份内容子树和生命周期，不复制动画替身、不检查或改写不透明子内容、不提供并行版本或动画豁免。Loading必要层仍显示时继续阻挡背景操作；fadeDuration只控制装饰退出及整体移除时长，减少动态时立即完成。见docs/DESIGN.md；历史淡入记录保留为证据，由此授权取代其行为要求。

可读动效复核补充：Input焦点、范围日期提示/悬停、Avatar溢出数字、Table加载指示和CountUp庆祝文字使用实际承载面上的可读配对。Upload为任意缩略图上的状态和操作提供不透明底色，透明提示跟随宿主主题，隐藏悬停操作不接收指针命中。日期/时间导航及页脚显示不影响布局的焦点轮廓。Image/Upload共用不透明位移呈现，路由生命周期仍由组件拥有；Badge/IconButton提示复用IslandTooltip。Drawer在构建后稳定减少动态效果。阈值不变，这些修复不代表全状态或辅助技术验收。

已有名称的动作可设置IslandTooltip.excludeFromSemantics，仅省略重复提示，不屏蔽子内容语义。预览所有者把局部减少动态设置变化传给同一路由；路由在展示时捕获继承主题。

Image预览关闭图形使用参考的16×2圆头交叉条与150ms可反向缓动；不透明灰底与独立承载的焦点轮廓保持可读。Input可见标签和提示不重复其固定无障碍名称。Gallery Input通过公共Card组合满宽棕色纹理、顶部12px间距、20px内边距和18px圆角；IslandCardTheme.style.borderColor拥有边框覆盖策略。Gallery页头提示同样使用IslandTooltip。

### 原子主题区域与输入反馈
运行时切换明暗主题时，在 `Scaffold.body` 或已有 Material 内容内部使用 `IslandThemeHost(data: targetTheme, child: content)`，传入应用已经解析好的目标 ThemeData，不能传上游 AnimatedTheme 的中间帧。宿主只负责一块不透明纸色底板和同步更新的 Theme、默认文字与图标；不另存主题模式或动画控制器，不检查子内容。调用者嵌套的 Scaffold/Material/AnimatedTheme 或显式样式构成新的绘制边界。静态参考 Gallery 保留已有底色。
Input 保留一个 FormField 和 TextField；辅助/错误消息与主题切换不丢控制器、选区和焦点。填色、边框、辅助/错误行原子切换，不使用 InputDecorator 的默认淡入和插值；校验、重置、外部控制器替换及错误 live-region 语义仍由输入框负责。Countdown 开启减少动态效果时结算原数字时间线，恢复动效不会续播旧过渡。

固定浅色表面通过一个内部 LightSurfaceScope 提供可读的语义主题、文字和图标默认值，保留其他 ThemeExtension 及显式子样式。ContentScope 的默认 IconTheme 跟随明确文字角色，插槽可声明独立图标角色。固定表面组件及其自有内容角色共享这一继承机制，不检查或改写子 Widget。

Tag拥有关闭动作的状态配色：悬停时同步使用colorway.ink与colorway.soft，透明变体静止时仍用承载面文字色。保留16px目标、独立键盘/父子事件和宿主决定移除；显式不透明子样式与状态不被改写。

CodeBlock 的实例和 `IslandCodeBlockTheme.style` 共用 `IslandCodeBlockStyle`：底板、基础前景、边框、词元角色与复制操作状态色进入同一绘制路径。字形参数归 `style.textStyle`，基础Color文字归 `style.foregroundColor`，高亮词元归 `style.syntaxColors`；显式 TextStyle.foreground Paint 仍按 Flutter 优先级由调用方拥有，不自动转成语义配对；切换 plain 语言不是换肤修复。调用方提供真实配对，库不猜色或静默纠色。样式与状态支持以[CodeBlock 契约](../../components/codeblock/contract.json)为唯一行为权威。Carousel固定浅色底板复用既有浅表面作用域，保留其他主题扩展及不透明slide的显式样式/状态。ActiveStack仍只管理当前项绘制/命中/语义，选择、计时与焦点归Carousel。

Card 实例／主题共用 IslandCardStyle，同一最终配方驱动画笔、被动插槽默认值与既有表面作用域。显式 IslandSurfaceTheme 声明嵌套控件亮度和 tokens，被动前景不改写它；未指定则继续已知浅表面保护，暗宿主也保持。IslandTokens 不承诺任意换肤全部固定材料。支持角色／状态只由[Card 契约](../../components/card/contract.json)拥有，不另抄参数矩阵。opaque 内容／素材归调用方／资产所有者，其他 ThemeExtension 保留。实色Tag、Title与Select沿用各自已知表面配方，透明Tag保持环境语义及同一子树。

IslandDialogRoute 是调用者自有预览/提示内容的公共共享路由。应推入根 Navigator 并保留路由身份，以便只清理本实例。路由捕获调用者主题，统一提供不透明位移和减少动态时的结算；内容、表面、语义和操作仍归 builder。Gallery Form/Notification 保留现有 AlertDialog 适配，Upload 保留560px普通 IslandModal，核心 Image/Upload 复用同一路由。原内部路由名称及路径已移除。showIslandModal 保留已独立观察的游戏弹窗缩放和时序。真实平台的回调几何与输入仍待验收；读屏验收已按当前用户范围决定排除。

IslandIcon 的显式 color 为 currentColor 提供颜色，否则继承 IconTheme。资产自有的内部多色画笔必须保留，不得整幅重染。面向宿主的必要描边和关闭标记继承 currentColor，自有内部底色上的标记遵循资产自身的画笔与裁剪所有权。逐图元[图标画笔角色](../../docs/icon-paint-roles.json)是唯一权威，覆盖填色图形及外露连接线；不得推断填色资产未修改或整体豁免。不在运行时猜测背景、不增加渲染器或复制色值表，保留资产几何和子内容显式样式的所有权。

Select、DatePicker、TimePicker、Pagination 与 Tooltip 共用唯一的实际 Overlay 布局所有者。参考定位能放下时保留原位置、间距、形状、配色与内容，仅在实际越界时把弹层移回视口；内容确实放不下时沿用可用宽度约束。实际子树只布局一次，不猜测下一帧尺寸、不克隆内容、不做 Gallery 特例或并行定位路径。选择、焦点、生命周期与滚动仍归组件：Select 让键盘活动项进入可视区；单月日历过窄时可横向滚动，范围日历保留原横向滚动，短视口时间面板和长 Tooltip 可纵向滚动。显式不透明子样式和状态仍由调用者拥有。这是用户批准的限定可用性差异，不能宣称该越界状态与参考完全一致，也不代表平台整体验收通过。

垂直弹层按所附方向的可用空间约束高度，使原触发控件保持可用；能放下的定位不增加额外偏移。Select 自己创建并释放列表滚动控制器，在列表接入时显示已提交选项，键盘活动项仅滚动自己的列表，不改动调用者的滚动位置。

模态闭环即使保持同一目标或没有操作控件，也消费正向和反向 Tab。现有动作模块中的同一边界把顺序交给原有 FocusScope，仅为原本为空的 Scope 创建一个跳过遍历且不产生语义节点的内部焦点目标，并在卸载时移除借用 Scope 的监听、释放自有节点。不检查子内容、不增加第二个 FocusScope、不替换调用者的焦点目标。IslandDialogRoute 现明确默认 TraversalEdgeBehavior.closedLoop；调用者显式传入的非闭环策略（包括 null 以继承 Navigator）仍然有效。Drawer、Loading、showIslandModal 和共享预览/提示路由复用同一行为。平台输入验证独立于 Widget 测试；当前范围由上方审计入口维护。

[Gallery parent layout authority](../../docs/DESIGN.md#gallery-parent-layout)

Select 在弹层呈现结束后按最新焦点历史完成键盘焦点交接。鼠标打开、选择、Escape 和清除后可继续键盘操作；Tab 保留其目标，包括独立清除按钮。弹层接入或移除后的单次可取消回调，仅在应用处于活动状态且焦点落到框架根作用域时恢复焦点。明确的控件及调用者自有作用域优先；禁用、替换借用焦点及卸载会取消过期回调。不修补 DOM、不轮询、不全局拦截键盘、不增加 FocusScope。

Radio 和 Checkbox 组提供可选 spacing：有限非负间距，水平默认16、垂直默认12；换行后的行间距沿用同一个值，选择与焦点所有权保持。Gallery 首个受控示例传20，复用已有示例底板并恢复参考初始值。Input 单行占位文字在有前后缀时仍保持单行；多行占位由显式 maxLines 控制。

固定列及 LayoutBuilder 单元格使用 column.width；允许根据内容收缩的期望列宽使用与其互斥的 preferredWidth，自动及期望列必须提供有限的固有宽度。表头默认不换行，子级显式样式仍优先。Pagination 的容纳、换行及对齐只引用[Pagination 契约](../../components/pagination/contract.json)。

邮票遮罩保持居中的5px半径/16px孔距、角落部分齿孔及参考最终遮罩的阴影结果。父级负责布局，图片说明需跟随图片相同的声明宽度。

目录布局修正保持所有者清晰：Table 的分页组合选择 centerEnd。Tabs 按各胶囊的内容宽度比例收缩，保留内边距和固有最小值，并将各标签拉伸至最高换行标题的高度。不透明标题保留键、样式和生命周期，换行机会由调用者决定。Gallery 自己拥有的中文标题显式声明零宽换行机会，以映射 CSS 中文换行；公共组件不检查任意子内容。Divider 只重复完整的 size+gap 周期，不留下末端连接线；波纹保留参考的居中平铺相位。

IslandTheme.codeFontFamily 是包内 Fira Code 的完整字体族名。CodeBlock 与 Gallery 图标标识使用它，默认字距为零；显式 CodeBlock.style.textStyle 控制字形，style前景与语法角色拥有文字颜色。Fira Code 只是项目资源，不安装系统字体。Arimo 仅作为 Gallery 原生控件示例的 Arial 后备字体。docs/font-resources.json 绑定上游提交、未修改的字体字节及 OFL 声明。字体及引擎栅格差异仍单独核验；打包字体和组件测试不代表整库视觉验收通过。

### 目录实测布局后续修正

CodeBlock.padding 可显式指定内容内边距；null 保留依复制按钮状态决定的默认值。显式内边距需为可见复制按钮留出空间。首页消费者使用水平28px/垂直20px、13px/1.8文字、零外边距及最大600px宽度。Progress信息默认16px/1、字重700、字距0.32px；不透明内容的显式样式仍优先，不检查或改写公共插槽。

Gallery 自己拥有外边距、行拉伸、叶子文字度量和示例配置；库消费者不导入 Gallery 截图辅助实现，也不把截图成功当成完整视觉验收。

Carousel区域只有主焦点时绘制2px外轮廓、偏移3px；子控件获得焦点后保留各自指示器。箭头、圆点及播放控件复用FocusOutline，绘制偏移2px的2px外轮廓，并以不透明白色笔画承托未知照片上的焦点色。保持包裹层级和几何尺寸稳定，不新增焦点节点或检查slide内容。

Gallery轮播照片标题与说明仍属调用者自有内容，呈现规则引用[现行权威](../../docs/DESIGN.md#home-host-and-photo-gradient)；公共Carousel不得检查、复制或重染不透明slide。

规范场景 SVG 使用既有渲染器与离线导入流程，保留资产几何、透明度、画笔与裁剪；不得新增运行时回退、渲染分支或放宽解析上限。目标引擎解码证据由上方审计入口维护。

Card／Tag 的可选父操作须保留不透明子控件焦点，活动视图整理尊重显式外部焦点和卸载；按值标识的 Tabs 重排保留页签焦点，显式浏览器／外部控件焦点优先。可搜索 Select 在弹层变化时保留同一具名编辑节点，宿主不要替换编辑器。

Gallery 由 Flutter／平台按需启用语义，不再无条件强制 Web 无障碍文本编辑路径。控件语义元数据保留，语义契约测试显式启用；普通 Web 输入保留原生组合与首次输入行为。读屏执行仍不在范围内。

搜索框被禁用时，先退出原生编辑连接，再以宿主已提交标签替换组合缓冲；延后整理使用最新标签，重新启用、新宿主更新或卸载会取消旧回调，不提出选值请求或抢焦点。

Select 的临时选项搜索不参与原生自动填充表单，避免清除按钮改变编辑框几何时触发表单切焦点并干扰禁用。

两帧呈现焦点整理期间，若子控件／页签所有者未变，普通宿主或主题重建不会取消有效恢复。新所有者取代旧请求；替换、移除、卸载、非活动视图和显式外部焦点仍优先。

本地化验收覆盖已声明的英文／中文内部操作默认文案及继承的方向、字号缩放。应用文案与中文参考Gallery仍归调用者，不承诺自动翻译不透明内容。

Card／Tag／Table 的独立子焦点挂接到现有调用者 Focus 节点（包含 FocusScope）；没有继承节点时使用现有管理器根节点。作用域边界不能悄悄把子焦点挂回父操作检测器，或用父焦点描边覆盖子焦点。该隔离仅由共享 ActionSurface 负责，不新建作用域或复制子树。

关闭 Drawer 排除整个保留的视口浮层，包括捕获语言环境的包装语义；子内容仍挂载。不得增加第二条浮层路径或 Gallery 专用指针补丁。

### Version scope / 本版本范围 (2026-10-18)

已安装 SDK 不能投射完整的 Select combobox 角色；现有 button/TextField 投射是本版本的具名例外，不是角色已实现或测试通过。键盘、焦点、输入法、名称/状态及对比度要求保持，不修改 SDK、不增加 DOM 补丁。既有版本决定引用 [DESIGN](../../docs/DESIGN.md)。公开仓库分发按所有者新增确认执行；保留[权利与来源边界](../../docs/RIGHTS.md)。已接受限制、验证结果与待验项只由上方审计入口维护。

### Gallery visual follow-up / Gallery视觉修正

首页／轮播的现行呈现规则与具名对比度例外统一引用[DESIGN权威](../../docs/DESIGN.md#home-host-and-photo-gradient)；此引用不构成新增平台验收或全局对比度豁免。

### Gallery Background可见性与有限范围（2026-10-20）

场景预览的视口剔除仅归Gallery所有：完整预览位于最近滚动视口及其1逻辑像素保护区之外时跳过绘制，仍保留同一公共IslandBackground挂载子树、几何、语义和悬停/点击路径。部分可见场景保留现有画布；不新增公共选项、位图缓存或子内容检查，宿主应用无需复制此Gallery优化。

Icon 保留用户已接受的实际负载节奏限制，不保证物理帧交付、全平台性能或低负载基准；记录范围和待验项以本文件上方的审计入口为准，不在应用契约中复制历史 CPU、轮次和时序统计。

Surface sampling / 表面采样 authority: [DESIGN](../../docs/DESIGN.md#surface-sampling). Platform results remain source-bound in the sole audit record; this contract update is not acceptance.

通知、气泡、日期／时间浮层及不透明轮播内容的分数位移遵循[既有表面采样所有者契约](../../docs/DESIGN.md#surface-sampling)。内容仍归调用方，不需要检查子内容或在宿主补偿文字位移。

通知／气泡保留原渲染实现及已接受的墨量质心测量限制；这不等于像素门槛通过，也不证明感知延迟或引擎原因，不增加宿主文字补偿。当前源绑定结果和浏览器／物理呈现待验项归上方审计入口维护。

- Button在两种宿主主题中拥有同一份固定busy表面配方，全局品牌leaf保持不变。定制busy配对时通过既有ButtonStyle共同设置前景／背景／边框。Colorway与Title默认值仍归共享源码所有者；修改共享前景前验证嵌套文字操作的按下／关闭／焦点状态。见docs/DESIGN.md#original-color-restoration，不增加消费端色板，不改写显式子样式。
- 配色职责决定遵循[固定配对设计权威](../../docs/DESIGN.md#c6-shared-foreground)及[Title角色规则](../../docs/DESIGN.md#c7-title-foreground)；消费库角色，不复制本地色板。

- Busy 内容复用既有固定表面语义作用域提供嵌套默认角色；开关状态时保持内容树拓扑、其他 ThemeExtensions 和显式插槽样式，不增加逐子控件补偿。
