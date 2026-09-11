# ADR 0003: Flutter Package Mode & Tree-shaking

## Context
Apps importing a UI library must not suffer binary bloat from unused widgets.

## Decision
Organize `lib/src/` into distinct sub-libraries and re-export through `lib/animal_island_ui.dart`.

## Consequences
Dart's AOT compiler and tree-shaking eliminate any unused component classes in production builds.
