# Theme and tokens

How Animal Island UI is themed, customized and kept readable. [中文](../zh/tokens.md)

## One theme source

`AnimalIslandTheme` is an immutable Flutter `ThemeExtension`. It composes six
token families and one set of component overrides:

| Theme property | Public value type | Responsibility |
| --- | --- | --- |
| `colors` | `AnimalThemeColors` | Semantic colors, brightness and all 13 tile pairs |
| `typography` | `AnimalThemeTypography` | Font families, text metrics and resolved text styles |
| `radii` | `AnimalThemeRadii` | Corner radii |
| `spacing` | `AnimalThemeSpacing` | Layout spacing |
| `shadows` | `AnimalThemeShadows` | Shadow values |
| `motion` | `AnimalThemeMotion` | Transition durations and curves |
| `components` | `AnimalComponentThemes` | Optional per-component overrides; empty in the presets |

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

Token constructors reject values components cannot render. Every typography role
needs a finite, positive `fontSize`, and spacing must be ordered
`xxs ≤ xs ≤ sm ≤ md ≤ lg ≤ xl ≤ xxl`.

### Component styles

A component's look resolves from three layers. The first one that sets a value
wins:

1. The component's own `style` parameter.
2. `AnimalIslandTheme.components`. For a sized component, a size-specific style
   such as `middleStyle` comes before the general `style`.
3. Defaults derived from the token families. For example, a middle input's font
   size is `typography.body` scaled by 15/14.

The instance parameter and the theme use the same style type, so one value
customizes a single widget or the whole app:

```dart
final theme = AnimalIslandTheme.light.copyWith(
  components: AnimalComponentThemes(
    input: AnimalInputThemeData(
      style: AnimalInputStyle(borderWidth: 2),
      largeStyle: AnimalInputStyle(minHeight: 56),
    ),
    focusRing: AnimalFocusRingStyle(color: const Color(0xFF2F6FDE)),
  ),
);

final input = AnimalInput(
  controller: controller,
  style: AnimalInputStyle(textStyle: const TextStyle(fontSize: 18)),
);
```

Field names follow one convention: the equivalent Flutter Material name when one
exists (`fillColor`, `trackColor`), otherwise a part plus a role such as
`labelTextStyle`, `placeholderTextColor`, `menuBorderRadius` or `optionPadding`.

Colors that change with interaction state are `WidgetStateProperty` values. A
partial text style merges with the lower layers, so overriding only the font size
keeps the theme's family and weight. To restyle one subtree, wrap it in Flutter's
`Theme` with a modified `AnimalIslandTheme`.

Accessibility floors stay fixed: 48 logical-pixel hit targets, and a focus ring
at least `AnimalFocusRingStyle.minimumWidth` wide. Choose focus and text colors
that keep the contrast targets below.

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
