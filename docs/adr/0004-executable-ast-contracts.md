# ADR 0004: API reference generated from the analyzed public library

## Status

Accepted.

## Decision

The public API is whatever `lib/animal_island_ui.dart` exports. Reference material
is derived from that library rather than written separately:

- `dart run tool/generate.dart` analyzes the root library and records its exported
  declarations, including parameters, required/default values, nullability and enums.
- `dart run tool/generate_docs.dart` produces the English and Chinese component
  pages and the skill's component references from that record.
- Both commands accept `--check`, which fails when the generated files are out of
  date with the source.

## Consequences

- Changing a public constructor requires regenerating the references in the same
  change; the `--check` mode catches drift.
- When the prose and the code disagree, the exported Dart declarations win.

## 中文

公共 API 以 `lib/animal_island_ui.dart` 的导出为准。`tool/generate.dart` 分析根库并记录
导出声明（参数、必填/默认值、可空性与枚举），`tool/generate_docs.dart` 据此生成中英文
组件文档和 Skill 组件参考；两者的 `--check` 模式在生成结果过期时失败。修改公共构造函数
须在同一变更中重新生成；文字与代码不一致时以导出的 Dart 声明为准。
