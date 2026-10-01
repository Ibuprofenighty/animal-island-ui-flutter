# ADR 0002: One immutable theme

## Status

Accepted.

## Decision

Semantic colors, typography, radii, spacing, shadows and motion have a single
runtime owner: the `AnimalIslandTheme` `ThemeExtension`. Each family lives in its
own file, but components never keep competing private defaults. Typography does
not depend back on the theme. Light and dark presets are provided, and custom
themes use the same `toThemeData()` conversion.

## Consequences

- Customizing a family through `copyWith` restyles every component consistently.
- A preset or color name does not by itself guarantee contrast; custom colors
  should be checked as actual foreground/background pairs.

See [theme and tokens](../en/tokens.md).

## 中文

颜色、字体、圆角、间距、阴影和动效统一由 `AnimalIslandTheme` 这一 `ThemeExtension`
持有；按职责分文件，但组件不保留相互竞争的私有默认值，typography 不反向依赖主题。
提供浅色与深色预设，自定义主题使用同一 `toThemeData()` 转换。参见
[主题与 token](../zh/tokens.md)。
