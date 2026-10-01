# Gallery workflows

Besides one page per component, the [Gallery](https://ibuprofenighty.github.io/animal-island-ui-flutter/)
contains three end-to-end examples that combine several components.
[中文](../zh/workflows.md)

| Workflow | Gallery route | Source | What it shows |
| --- | --- | --- | --- |
| Form | `/recipes/form` | [`form_workflow_recipe.dart`](../../example/lib/recipes/form_workflow_recipe.dart) | `AnimalForm` with a controller, validation rules, date/time pickers, reset and submit |
| Overlay | `/recipes/overlay` | [`overlay_orchestration_recipe.dart`](../../example/lib/recipes/overlay_orchestration_recipe.dart) | `AnimalModal`, `AnimalDrawer`, `AnimalLoading` and `AnimalNotification` working together |
| Data | `/recipes/data-table` | [`data_table_recipe.dart`](../../example/lib/recipes/data_table_recipe.dart) | A lazily built `AnimalTable` with pagination, plus `AnimalCodeBlock` and `AnimalImage` |

The workflows use only the package's public import,
`package:animal_island_ui/animal_island_ui.dart`, so they are a reasonable
starting point for your own screens. Run them locally from the
[example app](../../example/README.md).
