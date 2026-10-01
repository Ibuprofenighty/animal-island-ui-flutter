# Theme and tokens

How Animal Island UI is themed, customized and kept readable. [中文](../zh/tokens.md)

## One theme source

`AnimalIslandTheme` is an immutable Flutter `ThemeExtension`. It composes six
value families:

| Theme property | Public value type | Responsibility |
| --- | --- | --- |
| `colors` | `AnimalThemeColors` | Semantic colors, brightness and all 13 tile pairs |
| `typography` | `AnimalThemeTypography` | Font families, text metrics and resolved text styles |
| `radii` | `AnimalThemeRadii` | Corner radii |
| `spacing` | `AnimalThemeSpacing` | Layout spacing |
| `shadows` | `AnimalThemeShadows` | Shadow values |
| `motion` | `AnimalThemeMotion` | Transition durations and curves |

## Installing a theme

Use a preset's (or your custom theme's) `toThemeData()` as the application's
Material theme:

```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

final app = MaterialApp(
  theme: AnimalIslandTheme.light.toThemeData(),
  darkTheme: AnimalIslandTheme.dark.toThemeData(),
  home: const SizedBox(),
);
```

Below that theme, read the active values with `AnimalIslandTheme.of(context)`.
If the extension is missing, `of` throws a `StateError`; the package never
derives a fallback theme from the host brightness.

## Customizing

Customize a family with its `copyWith`, then replace that family through the
theme's `copyWith`, and install the result with `toThemeData()`. Components read
the active theme, so there is no second styling path to keep in sync.

- `AnimalTileColor` identifies a swatch; get its foreground and background from
  `theme.colors.tile(identity)`.
- When painting text directly, resolve the style through
  `theme.typography.resolve(...)` so the family's font configuration applies.
- `motion` configures transition durations and curves. Animations also follow the
  platform's reduce-motion setting.

## Visual identity and accessibility

The preset island colors, tactile button depth, ribbons, blobs, textures and
digit tiles define the look. Geometry and states are specific to each component;
for example, the stacked depth shadow belongs to filled primary and danger
buttons rather than to every component.

Color roles are chosen for readable pairs:

- Filled semantic surfaces use their matching `on*` foreground.
- Semantic foregrounds on ordinary surfaces (text and meaningful icons) use the
  `primaryText`, `successText`, `warningText`, `errorText` or `infoText` roles.
  The input's warning stroke also uses `warningText`.
- `focusYellow` is the focus-indicator color; in the light preset it is a warm
  ochre chosen to contrast with adjacent surfaces.
- Do not derive a second palette inside a component. If you override colors,
  check the contrast of your own foreground/background pairs.

Targets are 4.5:1 for enabled text and 3:1 for meaningful enabled icons and focus
outlines. Reduced-contrast text is limited to genuinely disabled or unavailable
states: disabled Collapse headers and tab items; disabled Input, Switch, Checkbox
and Radio labels; disabled Select triggers and options; disallowed calendar days;
and disabled TimePicker wheel labels and "Now" captions.

## Fonts

Nunito and Noto Sans SC variable fonts are bundled with the package and
registered under package-qualified family names, so text renders offline without
downloading fonts. Their SIL Open Font License 1.1 texts are shipped in
`assets/licenses/`. See [provenance](provenance.md) for attribution.
