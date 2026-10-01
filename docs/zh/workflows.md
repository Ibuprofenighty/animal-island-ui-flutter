# Gallery 工作流

除每个组件的独立页面外，[Gallery](https://ibuprofenighty.github.io/animal-island-ui-flutter/)
还包含三个组合多个组件的完整示例。[English](../en/workflows.md)

| 工作流 | Gallery 路由 | 源码 | 演示内容 |
| --- | --- | --- | --- |
| 表单 | `/recipes/form` | [`form_workflow_recipe.dart`](../../example/lib/recipes/form_workflow_recipe.dart) | 带控制器、校验规则、日期/时间选择器、重置与提交的 `AnimalForm` |
| 浮层 | `/recipes/overlay` | [`overlay_orchestration_recipe.dart`](../../example/lib/recipes/overlay_orchestration_recipe.dart) | `AnimalModal`、`AnimalDrawer`、`AnimalLoading` 与 `AnimalNotification` 协同使用 |
| 数据 | `/recipes/data-table` | [`data_table_recipe.dart`](../../example/lib/recipes/data_table_recipe.dart) | 惰性构建并配合分页的 `AnimalTable`，以及 `AnimalCodeBlock` 和 `AnimalImage` |

这些工作流只使用包的公共入口 `package:animal_island_ui/animal_island_ui.dart`，
适合作为编写自己页面的起点。可在本地通过[示例应用](../../example/README.md)运行。
