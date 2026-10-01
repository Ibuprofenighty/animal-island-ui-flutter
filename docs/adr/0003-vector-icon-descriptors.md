# ADR 0003: One descriptor-based icon renderer

## Status

Accepted.

## Decision

The 101 canonical icons are immutable `AnimalIconData` descriptors exposed as
constants on `AnimalIcons`, drawn by a single `AnimalIcon` widget. SVG rendering
uses `flutter_svg` (see [ADR 0001](0001-zero-runtime-dependencies.md)). There is
no separate widget class per icon.

## Consequences

- Size, color, stroke, monochrome and bounce options behave the same for every icon.
- Adding an icon means adding a descriptor, not a new widget.
- Icon artwork derives from the upstream design and keeps its CC BY-NC 4.0
  attribution (see [provenance](../en/provenance.md)).

## 中文

101 个标准图标以不可变的 `AnimalIconData` 描述符形式作为 `AnimalIcons` 常量提供，
统一由 `AnimalIcon` 组件绘制，SVG 渲染使用 `flutter_svg`，不为每个图标单独建组件类。
图标源自上游设计并保留 CC BY-NC 4.0 署名（见[来源说明](../zh/provenance.md)）。
