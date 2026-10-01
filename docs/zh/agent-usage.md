# Agent 使用指南

AI 编程助手（以及开发者）使用 `animal_island_ui` 生成代码时应遵循的规则。本页仅作
导航，不重复定义第二份 API。[English](../en/agent-usage.md)

1. 只导入 `package:animal_island_ui/animal_island_ui.dart`。不得导入
   `package:animal_island_ui/src/...`，也不要复制 Gallery 内部代码。
2. 编写调用前，先核对 `lib/animal_island_ui.dart` 实际导出的构造函数：必填参数、
   默认值和可空性。不得虚构参数或枚举值。
3. 通过 `AnimalIslandTheme.light.toThemeData()`、深色预设或自定义主题的
   `toThemeData()` 配置主题，并用 `AnimalIslandTheme.of(context)` 读取。参见
   [主题与 token](tokens.md)。
4. 在 `MaterialApp` 上配置 `AnimalLocalizations.localizationsDelegates`、
   `AnimalLocalizations.supportedLocales` 和 `resolveAnimalLocale`，使组件内置文案
   正确本地化。
5. 每份状态只有一个所有者；只释放自己代码创建的 controller 和资源。
6. `AnimalModal` 与 `AnimalDrawer` 以 route 方式显示；`AnimalNotification` 与
   `AnimalLoading` 显示在浮层中。请按各自文档化的 API 组合，不要让所有浮层走同一种机制。
7. 以[组件参考](components/)和 [Gallery 工作流](workflows.md)为起点，并确保代码能针对
   所依赖的包版本编译。
8. 准确说明许可证：本项目采用 CC BY-NC 4.0，不授予商业使用权。

供 Agent 工具使用的[消费者 Skill](../../skills/animal-island-ui-style-flutter/SKILL.zh-CN.md)
汇总了上述规则和各组件参考。
