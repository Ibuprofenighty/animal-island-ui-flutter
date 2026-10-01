# Changelog

All notable changes to the `animal_island_ui` package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Localization**: package text comes from English and Chinese ARB files through
  the exported `AnimalLocalizations`, with `resolveAnimalLocale` mapping any
  Chinese locale to Chinese and everything else to English.
- **Bundled fonts**: Nunito and Noto Sans SC variable fonts ship with the package
  under package-qualified family names, with their SIL OFL 1.1 license texts.
- **Typed form issues**: `AnimalValidationIssue` and `AnimalValidationIssueKind`
  expose locale-neutral validation results for programmatic checks.
- **Gallery**: the example app covers all 36 components, the 101-icon browser and
  form, overlay and data-table workflows, and is deployed to GitHub Pages.

### Changed
- **Toolchain**: requires Flutter `>=3.47.5` and Dart `>=3.13.4`.
- **Button API**: `AnimalButton` is configured with `variant`
  (`filled`, `outlined`, `dashed`, ...), `tone` and `size`.
- **Runtime dependencies**: `flutter_svg`, `characters`, `intl` and
  `flutter_localizations`.

## [1.0.0] - 2026-09-14

### Added
- First stable version of the library: 36 components and 101 vector icons on the
  single-module architecture introduced in 1.0.0-dev.1.
- Browser end-to-end tests for the web Gallery covering routing, deep links and
  offline font loading.

## [1.0.0-dev.1] - 2026-09-13

### Changed
- **Component modules**: every component lives in its own module under
  `lib/src/components/<component>/`, replacing the former category folders
  (`general/`, `feedback/`, `form_controls/`, `overlays/`, `layout/`,
  `data_display/`, `decorative/`).
- **Unified theme**: a single `AnimalIslandTheme` (`ThemeExtension<AnimalIslandTheme>`)
  with `light` and `dark` presets replaces the previous duplicate token
  implementations.
- **Icons**: the 101 standalone icon widget classes were replaced by immutable
  `AnimalIconData` descriptors on `AnimalIcons` and a single renderer,
  `AnimalIcon(data: ...)`.
- **Overlays**: `AnimalOverlayHost` scopes overlay state per app instead of
  sharing process-wide static queues.
- **Forms**: `AnimalForm` and `AnimalFormController` track revisions so a
  late-arriving asynchronous validation result cannot overwrite newer input.
- **Table**: `AnimalTable` builds rows lazily from `rowCount` + `rowBuilder`
  instead of an eager list of row widgets.
- **Gallery**: the example app was split from a single large file into separate
  component stories and workflow pages.
- **Documentation**: bilingual guides now live in `docs/en/` and `docs/zh/`, and the
  consumer skill in `skills/animal-island-ui-style-flutter/`.
