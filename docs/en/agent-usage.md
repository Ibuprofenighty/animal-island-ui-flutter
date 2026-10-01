# Agent usage guide

Rules for AI coding agents (and people) generating code with `animal_island_ui`.
This page is navigation, not a second API definition. [中文](../zh/agent-usage.md)

1. Import only `package:animal_island_ui/animal_island_ui.dart`. Never import
   `package:animal_island_ui/src/...` or copy code from the Gallery's internals.
2. Check the actual exported constructors in `lib/animal_island_ui.dart` before
   writing a call: required parameters, defaults and nullability. Never invent
   parameters or enum values.
3. Install the theme with `AnimalIslandTheme.light.toThemeData()`, the dark preset
   or a custom theme's `toThemeData()`, and read it with `AnimalIslandTheme.of(context)`.
   See [theme and tokens](tokens.md).
4. Install `AnimalLocalizations.localizationsDelegates`,
   `AnimalLocalizations.supportedLocales` and `resolveAnimalLocale` on `MaterialApp`
   so built-in component text is localized.
5. Keep one owner for each piece of state. Dispose only the controllers and
   resources your code creates.
6. `AnimalModal` and `AnimalDrawer` are shown as routes; `AnimalNotification` and
   `AnimalLoading` are displayed in an overlay. Compose them through their
   documented APIs rather than routing every overlay through one mechanism.
7. Use the [component references](components/) and the
   [Gallery workflows](workflows.md) as starting points, and keep the result
   compiling against the package version you depend on.
8. State the license accurately: the project is CC BY-NC 4.0 and does not grant
   commercial use.

For agent tooling, the packaged
[consumer skill](../../skills/animal-island-ui-style-flutter/SKILL.md) bundles
these rules with per-component references.
