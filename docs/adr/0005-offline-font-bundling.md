# ADR 0005: Bundled offline fonts

## Status

Accepted.

## Decision

The package owns its typography assets. The Nunito and Noto Sans SC variable fonts
are bundled in `assets/fonts/`, declared in the package `pubspec.yaml` and
registered under package-qualified family names. Fonts are never fetched at
runtime. Their SIL Open Font License 1.1 texts ship in `assets/licenses/`.

## Consequences

- English and Chinese text render with the intended fonts offline, including in
  the Gallery, which consumes the package fonts rather than declaring its own.
- A font family name alone never counts as a bundled font; only shipped files do.

## 中文

本包自带字体资产：Nunito 与 Noto Sans SC 可变字体位于 `assets/fonts/`，在包的
`pubspec.yaml` 中声明并以包限定 family 名称注册，运行时从不下载字体。其 SIL Open
Font License 1.1 文本随包提供于 `assets/licenses/`。Gallery 使用包内字体，不另行声明。
