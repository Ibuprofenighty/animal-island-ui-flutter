# ADR 0002: Dual Design Token Architecture

## Context
Apps require compile-time type safety as well as runtime day/night theming.

## Decision
Provide static constants (`AnimalColors`, `AnimalRadii`, `AnimalShadows`) along with a dynamic `ThemeExtension<AnimalIslandTheme>`.

## Consequences
Developers get fast auto-complete and zero-cost constants, with the flexibility to override colors in `ThemeData`.
