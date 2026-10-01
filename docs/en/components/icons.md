<!-- generated:api:start -->
# 101 Vector Icons

<!-- generated:api:end -->

## Overview
The 101 canonical SVG sources are represented as lightweight `AnimalIconData` descriptors exposed via static constants on `AnimalIcons`.

## Import
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## Usage
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

The enclosing application must install its Animal Island theme through
`toThemeData()`; see the [theme setup](../tokens.md).
