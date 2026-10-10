# Animal Island UI 消费者 Skill

使用 `animal_island_ui` 构建 Flutter 界面：36 个海岛风格组件和 101 个矢量图标。
这是 [SKILL.md](SKILL.md) 的中文镜像，不是独立安装的第二个 Skill。

标准图形使用 `AnimalIcons`。自定义 `AnimalIconData.svg` 须遵守[图标引用](references/components/icon.md)中的 SVG 白名单与大小限制；渲染时空输入或不支持的 SVG 会抛出 `ArgumentError`。tint alpha 使用三位小数精度；受影响的 `stroke-opacity` 会更新，普通 group `opacity` 会保留。正数自定义描边宽度使用两位小数；零和负数规范化为 `0`。

## 先读

- [包元数据](../../pubspec.yaml)：SDK 约束与依赖。
- [根导出](../../lib/animal_island_ui.dart)：唯一的导入入口；在此核对导出符号和必填参数。
- [接入](references/setup.md)、[主题与 token](../../docs/zh/tokens.md)、
  [Gallery 工作流](../../docs/zh/workflows.md)。
- 许可证：CC BY-NC 4.0。不得暗示其授予商业使用权。

## 包使用规则

1. 不虚构参数或枚举值。检查实际导出的构造函数，并确保代码能针对所用包版本编译。
2. 从 `package:animal_island_ui/animal_island_ui.dart` 导入；禁止导入 `src` 或 Gallery 内部实现。
3. 通过 `AnimalIslandTheme.light.toThemeData()`、深色预设或自定义主题的同一转换入口配置
   主题；用 `AnimalIslandTheme.of(context)` 读取六组 token（`colors`、`typography`、
   `radii`、`spacing`、`shadows`、`motion`），缺少扩展会抛 `StateError`。不存在静态
   token 常量，也不会根据宿主亮度推导主题。
4. 每份状态只有一个所有者；只释放自己代码拥有的 controller 和资源。
5. `AnimalModal` 与 `AnimalDrawer` 以 route 方式显示；`AnimalNotification` 与
   `AnimalLoading` 显示在浮层中。各自通过自己的 API 使用。
   `AnimalModal.confirm` 返回 `Future<bool>`（只有确认成功时为 `true`）；
   `AnimalModal.show<T>` 与 `AnimalDrawer.show<T>` 返回 `Future<T?>`：其 builder 收到的
   `close` 回调所传入的值，被关闭时为 `null`。两者都显示在最近的 `Navigator` 上；
   `onConfirm` 挂起期间所有关闭请求都会被忽略。
   `AnimalLoading.show` 要求 context 之上有 `AnimalOverlayHost`，返回的 handle 只能通过
   幂等的 `close()` 移除加载。
   `AnimalNotification.open` 同样需要 host，返回 `AnimalNotificationHandle`（`status`、
   幂等的 `close()`）；方位队列已满（显示 3 条、等待 50 条）时返回 `rejected`。仍在队列中的
   业务 `key` 会原位更新其通知；`AnimalNotification.closeAll(context)` 关闭该 host 的通知。
   自定义浮层时，`AnimalOverlayHost.of(context)` 返回该 host 的 `AnimalOverlayController`：
   `show(builder:, onClose:)` 返回带幂等 `close()` 与 `isClosed` 的 `AnimalOverlayEntryHandle`，
   `close(handle)` 关闭本 controller 的一个 occurrence（其他 controller 的 handle 抛出 `ArgumentError`），
   `closeAll()` 关闭该 host 的全部 occurrence。交给 host 的 controller 仍归你所有，只能在 host
   移除后 dispose。
6. 遵循各组件自身的几何与状态；例如叠层深度阴影属于主色和危险色的填充按钮，而非所有组件。
7. 定制颜色时保持前景/背景配对可读，普通表面上的文字使用语义 `*Text` 角色。
8. 组件外观只走一条定制路径：组件的 `style` 参数覆盖 `AnimalIslandTheme.components`，
   后者覆盖由 token 推导的默认值；两层使用同一种 `Animal*Style` 类型（如
   `AnimalInputStyle`）。有尺寸的组件还可在主题中按尺寸设置样式，如 `middleStyle`。
   不要为改样式而包一层组件，也不要硬编码样式或 token 已提供的值。

## 交互

可交互组件和交互图标共用一个激活与焦点 owner。只读控件仍可聚焦，但不暴露激活操作；
未设置 `readOnly` 的 null callback 表现为禁用。Radio 组只有一个 roving Tab stop，方向键/Home/End
在可用选项间导航；Checkbox 各项保留独立 Tab stop，其导航只移动焦点。命中区域至少 48 逻辑像素；
失去焦点、被禁用、隐藏或移除时，未完成的激活会被取消。Switch、Checkbox、Radio 和 Select 的值均由调用方持有，
回调只提议更新。选项列表是不可变快照，`option.value` 必须唯一。
N15 对 `AnimalSwitch` 的布局目标是：46×26 与 58×32 为药丸轨道最小尺寸。药丸轨道必须使用内阴影且没有外阴影；带边框的 thumb 保持平面。内置 `size` 预设规定 thumb 直径为 18/24 逻辑像素、轨道边框为 1.5 逻辑像素、thumb 边框为 1.2 逻辑像素、标签/thumb 间距为 4 逻辑像素；`AnimalSwitchStyle`（实例或 `components.switchControl`）可覆盖其中任一值。ON/OFF 子控件各挂载一次，并在 thumb 旁的轨道空余区域
共用稳定尺寸的标签区域；两种标签使用相同的受限布局，其实际内容尺寸共同确定可容纳任一状态的区域，轨道再按
标签、thumb、内边距和间隔所需空间扩展。过渡时旧标签先淡出，thumb 移动期间标签区域保持空白，抵达后新标签再淡入。
标签文本默认字号由预设提供：`small`/`defaultSize` 分别为 11/13 逻辑像素，并使用预设粗体；主题提供标签实际使用的字体族、回退字体、行高和字距，当前 switch 状态提供文字颜色。系统当前 `TextScaler` 仍生效，调用方可用 `Text.style` 显式覆盖这些默认值。文字自然换行，
包括 200% 缩放时也可使轨道增高，不会缩小或省略。thumb 保持原尺寸，并在扩展轨道两端的内边距之间移动；RTL 遵循
文本方向。外层焦点轮廓跟随扩大的轨道，命中区域至少为 48×48 逻辑像素。Switch 轨道与 thumb 是由用户操作触发的
有限时长过渡；N10 动效政策尊重系统减少动画偏好、`TickerMode` 和应用前后台，关闭动效时持续时间为零。焦点只控制
轮廓，不会禁用这些过渡。
`AnimalSwitch` 必须收到有限的 `maxWidth`。在有界 `Row` 中使用 `Flexible` 或有限 `ConstrainedBox`；用于横向滚动时，在滚动容器之前放置 `LayoutBuilder` 读取实际有限 viewport 宽度，再用包住 Switch 的 `ConstrainedBox` 传入该上限。无界宽度会被拒绝。
`AnimalSelect` 的所有选项行共用一个自适应 extent，根据主题正文样式、当前 `TextScaler` 和垂直间距计算。每行最多两行文字并在溢出时省略，命中区域至少为 48×48 逻辑像素。主题 token 控制菜单及选项状态样式；菜单宽度和列表视口高度上限默认为 320 逻辑像素（`menuMaxWidth`、`menuMaxHeight`），宽度还受可用视口宽度减 24 逻辑像素约束。触发器标签默认为主题 body 乘以 15/14，颜色随状态变化且系统 `TextScaler` 仍生效。`AnimalSelectStyle` 可覆盖触发器、菜单和选项的几何、文字与颜色；48 逻辑像素的选项下限保持固定，列表保持 lazy 构建。
Checkbox 字段错误由外层 `AnimalFormItem` 格式化并播报；Checkbox 只负责选中与 mixed 状态。

## 本地化与验证

`AnimalLocalizations` 和 `resolveAnimalLocale` 从包根导出。宿主 `MaterialApp` 应配置生成的
delegates 和 supported locales；中文 locale 使用中文，缺省或不支持的 locale 使用英文。
`AnimalFormController.getFieldError(key)` 返回供程序判断的 locale-neutral
`AnimalValidationIssue`。表单字段由 `AnimalFieldKey<T>` 对象身份标识。该类为 final，包外库
不能继承或实现它；标签不会标识字段。通过 `AnimalFormValues.valueFor(key)` 读取 change 和
submit 快照，以保留 key 对应的值类型。集合值使用[表单引用](references/components/form.md)中的类型化快照工厂。
内建问题文案由 `AnimalFormItem` 展示，不要再维护第二份 issue 到 message 的映射。调用者
提供的验证文案按原文显示。
`AnimalForm.onSubmit` 使用唯一 `FutureOr<bool>` 合同：true 接受快照，false 返回 typed
rejected 结果，抛出的异常交由调用者处理。没有 handler 时，合法表单完成 validation-only
submit。详情见[表单引用](references/components/form.md)。
文本字段应在调用方 `State` 中创建一个唯一的 `TextEditingController`，并同时传给
`AnimalFormItem.textController` 与 `AnimalInput.controller`。Form 从该缓冲区读取当前文本；
空文本为 null，该 key 不得同时出现在 `initialValues` 或 item 的 `initialValue` 中。
`AnimalInput.onChanged` 只通知调用方，不是第二次表单值写入。非文本 String 字段仍是标量值。
大字号缩放时，`AnimalInput` 会限制并换行前后缀内容；组件高度可超过所选尺寸的最小值，同时保持文字可读并为编辑区域留出空间。
值、规则、registration、reset 或默认 handler 变化会取消活跃的本地 submit，即使 handler
仍在等待；晚到的 handler 完成不能影响替代 operation。
`AnimalRule` 的内建配置按值比较，自定义 validator callback 按对象身份比较；重建自定义规则时
复用 callback 可保留该规则配置。

## 组件引用

| 组件 | 标识 | 引用 |
| :--- | :--- | :--- |
| `AnimalButton` | `button` | [button.md](references/components/button.md) |
| `AnimalIcon` | `icon` | [icon.md](references/components/icon.md) |
| `101 Icons Browser` | `icons` | [icons.md](references/components/icons.md) |
| `AnimalTypewriter` | `typewriter` | [typewriter.md](references/components/typewriter.md) |
| `AnimalCursor` | `cursor` | [cursor.md](references/components/cursor.md) |
| `AnimalCard` | `card` | [card.md](references/components/card.md) |
| `AnimalTitle` | `title` | [title.md](references/components/title.md) |
| `AnimalDivider` | `divider` | [divider.md](references/components/divider.md) |
| `AnimalBackground` | `background` | [background.md](references/components/background.md) |
| `AnimalCollapse` | `collapse` | [collapse.md](references/components/collapse.md) |
| `AnimalTabs` | `tabs` | [tabs.md](references/components/tabs.md) |
| `AnimalCarousel` | `carousel` | [carousel.md](references/components/carousel.md) |
| `AnimalInput` | `input` | [input.md](references/components/input.md) |
| `AnimalSwitch` | `switch` | [switch.md](references/components/switch.md) |
| `AnimalCheckbox` | `checkbox` | [checkbox.md](references/components/checkbox.md) |
| `AnimalRadio` | `radio` | [radio.md](references/components/radio.md) |
| `AnimalSelect` | `select` | [select.md](references/components/select.md) |
| `AnimalDatePicker` | `date_picker` | [date_picker.md](references/components/date_picker.md) |
| `AnimalTimePicker` | `time_picker` | [time_picker.md](references/components/time_picker.md) |
| `AnimalForm` | `form` | [form.md](references/components/form.md) |
| `AnimalFormItem` | `form_item` | [form_item.md](references/components/form_item.md) |
| `AnimalModal` | `modal` | [modal.md](references/components/modal.md) |
| `AnimalDrawer` | `drawer` | [drawer.md](references/components/drawer.md) |
| `AnimalTooltip` | `tooltip` | [tooltip.md](references/components/tooltip.md) |
| `AnimalProgress` | `progress` | [progress.md](references/components/progress.md) |
| `AnimalLoading` | `loading` | [loading.md](references/components/loading.md) |
| `AnimalSkeleton` | `skeleton` | [skeleton.md](references/components/skeleton.md) |
| `AnimalBackTop` | `back_top` | [back_top.md](references/components/back_top.md) |
| `AnimalCountdown` | `countdown` | [countdown.md](references/components/countdown.md) |
| `AnimalTime` | `time` | [time.md](references/components/time.md) |
| `AnimalNotification` | `notification` | [notification.md](references/components/notification.md) |
| `AnimalTable` | `table` | [table.md](references/components/table.md) |
| `AnimalPagination` | `pagination` | [pagination.md](references/components/pagination.md) |
| `AnimalCodeBlock` | `code_block` | [code_block.md](references/components/code_block.md) |
| `AnimalTag` | `tag` | [tag.md](references/components/tag.md) |
| `AnimalImage` | `image` | [image.md](references/components/image.md) |
| `AnimalFooter` | `footer` | [footer.md](references/components/footer.md) |

## 工作流

组合多个组件的完整示例：

- [表单](references/recipes/form_workflow.md)
- [浮层](references/recipes/overlay_workflow.md)
- [数据](references/recipes/data_workflow.md)

## 稳定导航与数据契约

导航和数据使用稳定标识。Tabs 的 `selectedId` 只属于调用者，挂载后的 LTR/RTL 方向变化重新对齐指示器且不发出选中提议；Carousel 明确区分受控 `activeId` 与 `.uncontrolled(defaultActiveId: ...)`，高度通过 `AnimalCarouselStyle.height` 配置。被拒绝的提议不本地提交。Table 必须传稳定唯一 row key，并校验每个请求行的单元格 schema。Pagination 按精确整数页数校验父级页码。这五个组件各用一个 Style 类型连接实例与组件主题，没有尺寸预设。

横向溢出的 Table 视口可用键盘进入：Tab、左右键（RTL 镜像）、Home/End 和 PageUp/PageDown 滚动同一表头/正文几何；子级编辑器保留自己的按键处理。

Collapse 与非受控 Carousel 每次构造都要求默认 ID 有效，删项时同批清理默认 ID；合法默认值变化不重置已挂载状态。Carousel 在政策停止时中断运行中的页面/滑点动画，RTL 箭头遵循逻辑上一项/下一项；Pagination 按页码和省略号各自字体实测窗口。
