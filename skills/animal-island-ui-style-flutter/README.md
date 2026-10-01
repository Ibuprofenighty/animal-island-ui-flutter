# Animal Island UI consumer skill

A skill for AI coding agents (Claude Code, Cursor, Windsurf and similar) that
build Flutter screens with `animal_island_ui`.

- [SKILL.md](SKILL.md) is the entry point; [SKILL.zh-CN.md](SKILL.zh-CN.md) is its
  Chinese translation. Both describe the same package and API.
- `references/setup.md` covers package setup, theme and localization.
- `references/components/` has one reference per component plus the icon index.
  These files are generated from the package's public API by
  `tool/generate_docs.dart`.
- `references/recipes/` describes the form, overlay and data workflows.
- `manifest.json` records the package version, SDK constraint and reference counts.

To use it, point your agent at this directory (or copy it into your agent's skills
folder) and ask for island-style screens.

中文：本目录是供 AI 编程助手使用 `animal_island_ui` 构建 Flutter 界面的 Skill。
入口为 [SKILL.md](SKILL.md)，[SKILL.zh-CN.md](SKILL.zh-CN.md) 为中文译本；
`references/` 下包含接入说明、由公共 API 生成的组件参考和三个工作流示例。
