<!-- generated:api:start -->
# AnimalCursor Reference

- **Class**: `AnimalCursor`
- **Import**: `import 'package:animal_island_ui/animal_island_ui.dart';`

## Constructors
- `AnimalCursor`

## Properties
- `child`
- `customCursor`
- `forceAll`
- `type`

## Enums
- `AnimalCursorType`

<!-- generated:api:end -->

## Cursor rules

Over `child`, a mouse shows the cursor of `type`, or `customCursor` when it is
given. Art cursors (`defaultCursor`, `raindrop` and any `customCursor`) hide
the system pointer and draw the art at the mouse position, its top-left corner
6 logical pixels up and left of the pointer; `pointer`, `text` and
`notAllowed` use the system cursor. Exactly one cursor is visible at a time:
the art is drawn only where this region decides the cursor.

With `forceAll: true` (the default) the cursor also replaces the cursors of
descendants, including text fields and nested `AnimalCursor` regions. With
`forceAll: false` a descendant with its own cursor, including a nested
`AnimalCursor`, shows that cursor alone, and this cursor applies only where
descendants have none.

The region never takes taps, pointer events or hover from `child` or from
regions behind it. Touch and stylus input never show the art, and switching
`type` keeps the state of `child`. The paw and raindrop art are fixed pointer
assets, so the cursor has no style.

## Localization
AnimalCursor has no built-in copy or semantics label. Localize content in its caller-owned child.

## Example
See [`cursor_story.dart`](../../../../example/lib/stories/cursor_story.dart) in the example Gallery.
