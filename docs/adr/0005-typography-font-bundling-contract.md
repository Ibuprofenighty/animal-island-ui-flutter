# ADR 0005: Typography Strategy & Font Asset Bundling Contract

## Context
Animal Island UI defines a warm, organic visual personality rooted in the rounded font family `Nunito` (Latin) with fallback to `Noto Sans SC` (CJK) and system `sans-serif`.
In Flutter package distribution:
1. Direct embedding of CJK font files (such as Noto Sans SC) in a package expands binary distribution size by over 15MB–25MB per client application, violating ultralight package hygiene.
2. Hardcoding local font asset paths inside package `pubspec.yaml` without physical assets causes unresolved asset loader warnings and phantom bundle expectations.

## Decision
1. **Fallback Font Chain**: `AnimalTypography` designates `fontFamily: 'Nunito'` and `fontFamilyFallback: const ['Noto Sans SC', 'sans-serif']`.
2. **Package Asset Policy**: Keep the base package ultralight (zero physical TTF bloat).
3. **Application Layer Consumption**: Applications using `animal_island_ui` have three clear, supported typography integration paths:
   - **Default Native Fallback**: Gracefully renders system sans-serif with correct weight (400, 500, 700, 900) without asset overhead.
   - **Google Fonts Package**: Optional runtime download / caching via `google_fonts: ^6.0.0` (`GoogleFonts.nunitoTextTheme()`).
   - **Host App Bundling**: Host applications can declare `Nunito` and `Noto Sans SC` in their application-level `pubspec.yaml` under `flutter: fonts:`.

## Consequences
- Preserves package zero-bloat footprint (~100KB package vs 25MB+ bloated asset binary).
- Fully eliminates phantom font bundle assertions while maintaining exact typographical tokens and fallbacks across Web, iOS, Android, macOS, Linux, and Windows.
