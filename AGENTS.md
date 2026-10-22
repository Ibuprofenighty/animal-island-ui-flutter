# Working in animal_island_ui

This is a fresh Flutter implementation. Do not copy implementation or assets from the old local animal_island_ui repository.

## User authority
The user requires the Gallery to match https://guokaigdg.github.io/animal-island-ui/#/ in appearance and interaction, subject to the explicitly authorized accessibility color and readable-motion differences in docs/DESIGN.md.
Read docs/DESIGN.md and docs/reference-gallery.json before visual, scope, API, or Gallery work.
These supersede the initial self-selected island illustration, forest palette, visit flow and 20-component target.
Existing source and passing tests are an unaccepted draft, not proof of reference parity.

## Method
Apply contract-first architecture, public-interface tests, and source-bound evidence.
Windows and Web are first acceptance targets. Mobile verification is later.
Observe unknown reference states before implementing them; do not invent a replacement design.
Do not claim commercial readiness or visual parity from structural validation or build success.

## Architecture
Library: foundation -> components -> explicit public root.
Gallery: app composition, pages, shared; consumes public root only.
Visual tokens belong to the library, not duplicated Gallery overrides.
Retain source/license provenance for external assets. No publishing without user authorization.
