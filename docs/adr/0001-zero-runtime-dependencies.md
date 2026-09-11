# ADR 0001: Zero Third-Party UI Bloat & Governed SVG Engine

## Context
Third-party UI component libraries introduce version locks, unexpected styling conflicts, and runtime rendering overhead. High-fidelity kawaii animal island UI requires authentic vector illustrations with multi-color path fills and crisp borders.

## Decision
1. Eliminate all third-party UI widget libraries. All 36 components, ribbon painters, and organic blob clippers are implemented natively with pure Flutter architecture.
2. Adopt `flutter_svg` as the single, strictly-governed low-level vector rendering dependency for authentic 101 icon SVG parsing and canvas rendering.

## Consequences
- Guaranteed zero dependency resolution conflicts with other UI component systems.
- Authentic SVG multi-color rendering preserved without manual path rasterization bloat.
- Clean forward compatibility across Flutter stable releases (3.10+ through 3.47+).
