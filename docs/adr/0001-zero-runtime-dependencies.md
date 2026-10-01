# ADR 0001: Purpose-specific runtime dependencies, no third-party UI kit

## Status

Accepted.

## Decision

The package composes its UI from Flutter primitives. It uses a small set of
purpose-specific runtime dependencies, as declared in `pubspec.yaml`:
`flutter_svg` for SVG rendering, `characters` for grapheme handling, and `intl`
with Flutter's `flutter_localizations` for localization. Third-party UI widget
libraries are not used.

## Consequences

- Every visible widget is implemented in this package and follows its theme.
- New runtime dependencies should be limited to focused, non-UI concerns.

## 中文

本包使用 Flutter 原语组合 UI，并按 `pubspec.yaml` 声明使用少量专用运行依赖：
`flutter_svg` 渲染 SVG，`characters` 处理字素，`intl` 与 Flutter 的
`flutter_localizations` 负责本地化。不使用第三方 UI 控件库。
