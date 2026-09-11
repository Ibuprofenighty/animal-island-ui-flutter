# Architecture Decision Records (ADRs)

This directory records the key architectural decisions made for `animal_island_ui` in Flutter.

| ADR | Title | Summary |
| :--- | :--- | :--- |
| [0001](0001-zero-runtime-dependencies.md) | Zero Runtime UI Bloat | Built entirely on pure Flutter Canvas & Widget primitives without external bloated UI packages. |
| [0002](0002-dual-design-token-system.md) | Dual Design Token Architecture | Static compile-time constants for zero-cost layout combined with `ThemeExtension` for runtime re-theming. |
| [0003](0003-flutter-package-tree-shaking.md) | Flutter Package Mode & Tree-shaking | Standard Flutter package layout with modular re-exports enabling minimal release binary footprint. |
| [0004](0004-docs-sync-automation.md) | Documentation & Skill Sync Automation | CI automation enforcing 100% component coverage, <=200 line limits, and bilingual parity. |
| [0005](0005-typography-font-bundling-contract.md) | Typography Strategy & Font Bundling Contract | Zero-bloat font strategy with graceful fallback chain and host app integration paths. |
