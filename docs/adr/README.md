# Architecture Decision Records (ADRs)

Key design decisions behind `animal_island_ui`. Each record states the decision
and its consequences, with a short Chinese summary.

1. [ADR 0001: Purpose-specific runtime dependencies](0001-zero-runtime-dependencies.md) — Flutter primitives plus `flutter_svg`, `characters` and localization packages; no third-party UI kit.
2. [ADR 0002: One immutable theme](0002-single-theme-system.md) — a single `AnimalIslandTheme` `ThemeExtension` owns all tokens.
3. [ADR 0003: One descriptor-based icon renderer](0003-vector-icon-descriptors.md) — 101 `AnimalIconData` descriptors drawn by `AnimalIcon`.
4. [ADR 0004: API reference generated from the public library](0004-executable-ast-contracts.md) — component references derived from the analyzed exports.
5. [ADR 0005: Bundled offline fonts](0005-offline-font-bundling.md) — Nunito and Noto Sans SC ship with the package.
