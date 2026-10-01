# Animal Island UI Gallery

The interactive showcase for `animal_island_ui`. It demonstrates all 36
components, the 101-icon browser and three workflows (form, overlays and data
table), with switches for light/dark theme, English/Chinese, text scale and
reduced motion.

Live version: <https://ibuprofenighty.github.io/animal-island-ui-flutter/>

## Run locally

From this directory:

```bash
flutter pub get
flutter run -d chrome   # or windows, macos, linux, android, ios
flutter test
```

## What's inside

- `lib/main.dart` and `lib/app.dart`: the Gallery app and its theme/locale setup.
- `lib/stories/`: one story per component.
- `lib/recipes/`: the form, overlay and data-table workflows
  (see [Gallery workflows](../docs/en/workflows.md)).
- `lib/quick_start.dart`: a minimal standalone app showing the basic setup.

The Gallery uses only the package's public import,
`package:animal_island_ui/animal_island_ui.dart`.

## 中文

`animal_island_ui` 的交互式展示应用，演示全部 36 个组件、101 图标浏览器以及表单、
浮层和数据表格三个工作流，并可切换浅色/深色主题、中英文、文字缩放和减少动态效果。

在线版本：<https://ibuprofenighty.github.io/animal-island-ui-flutter/>

在本目录运行 `flutter pub get`、`flutter run -d chrome` 和 `flutter test`。
`lib/stories/` 为各组件示例，`lib/recipes/` 为三个工作流（见
[Gallery 工作流](../docs/zh/workflows.md)），`lib/quick_start.dart` 是最小的独立接入示例。
Gallery 只使用包的公共入口 `package:animal_island_ui/animal_island_ui.dart`。
