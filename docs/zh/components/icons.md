<!-- generated:api:start -->
# 101 款矢量图标

<!-- generated:api:end -->

## 概述
101 个 canonical SVG 源文件对应轻量级不可变 `AnimalIconData` 描述符挂载在 `AnimalIcons` 静态常量上。

## 导入路径
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 基础使用示例
```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget buildIcons(BuildContext context) {
  final theme = AnimalIslandTheme.of(context);
  return Row(
    children: [
      AnimalIcon(data: AnimalIcons.leaf, size: 28, color: theme.colors.primary),
      const AnimalIcon(data: AnimalIcons.apple, size: 28),
      const AnimalIcon(data: AnimalIcons.bell, size: 28),
      const AnimalIcon(data: AnimalIcons.star, size: 28),
    ],
  );
}
```

应用须通过 `toThemeData()` 安装 Animal Island 主题，详见[主题接入](../tokens.md)。
