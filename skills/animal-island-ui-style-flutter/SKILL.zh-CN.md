# Animal Island UI 消费者 Skill

使用 `animal_island_ui` 构建 Flutter 界面：36 个海岛风格组件和 101 个矢量图标。
这是 [SKILL.md](SKILL.md) 的中文镜像，不是独立安装的第二个 Skill。

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
6. 遵循各组件自身的几何与状态；例如叠层深度阴影属于主色和危险色的填充按钮，而非所有组件。
7. 定制颜色时保持前景/背景配对可读，普通表面上的文字使用语义 `*Text` 角色。

## 交互

可交互组件和交互图标通过统一的激活与焦点行为响应指针、Enter/Space 和无障碍操作。
分组控件（单选/复选组、标签页）处理箭头/Home/End 导航。命中区域至少 48 逻辑像素；
失去焦点、被禁用、隐藏或移除时，未完成的激活会被取消。

## 本地化与验证

`AnimalLocalizations` 和 `resolveAnimalLocale` 从包根导出。宿主 `MaterialApp` 应配置生成的
delegates 和 supported locales；中文 locale 使用中文，缺省或不支持的 locale 使用英文。
`AnimalFormController.getFieldError` 返回供程序判断的 locale-neutral `AnimalValidationIssue`。
内建问题文案由 `AnimalFormItem` 展示，不要再维护第二份 issue 到 message 的映射。调用者
提供的验证文案按原文显示。

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
