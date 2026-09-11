# Layout Components Reference

## Card

```dart
AnimalCard({
  Key? key,
  AnimalCardType type = AnimalCardType.defaultCard,
  AnimalTileColor color = AnimalTileColor.mintTeal,
  bool pattern = false,
  bool hoverable = false,
  EdgeInsetsGeometry? padding,
  Widget? header,
  Widget? footer,
  required Widget child,
})
// Types: defaultCard, dashed
```

## Title

```dart
AnimalTitle({
  Key? key,
  AnimalTileColor color = AnimalTileColor.leafGreen,
  AnimalTitleSize size = AnimalTitleSize.medium,
  required Widget child,
})
// Sizes: small, medium, large
```

## Divider

```dart
AnimalDivider({
  Key? key,
  AnimalDividerType type = AnimalDividerType.solid,
  Color? color,
  double thickness = 2.0,
})

// Presets:
AnimalDivider.solid({Key? key, Color? color, double thickness = 2.0})
AnimalDivider.dashed({Key? key, Color? color, double thickness = 2.0})
AnimalDivider.dotted({Key? key, Color? color, double thickness = 2.0})
AnimalDivider.leaf({Key? key, Color? color})
AnimalDivider.star({Key? key, Color? color})
AnimalDivider.flower({Key? key, Color? color})
```

## Background

```dart
AnimalBackground({
  Key? key,
  AnimalBackgroundPattern pattern = AnimalBackgroundPattern.dots,
  required Widget child,
})
// Patterns: parchment, dots, grid
```

## Collapse

```dart
AnimalCollapse({
  Key? key,
  required List<AnimalCollapseItem> items,
  bool accordion = false,
  ValueChanged<List<String>>? onChanged,
})

// Single Q&A Constructor:
AnimalCollapse.single({
  Key? key,
  required String question,
  required String answer,
  bool initiallyExpanded = false,
  ValueChanged<bool>? onChanged,
})
```

## Tabs

```dart
AnimalTabs({
  Key? key,
  required List<AnimalTabItem> tabs,
  int selectedIndex = 0,
  ValueChanged<int>? onChanged,
})
```

## Carousel

```dart
AnimalCarousel({
  Key? key,
  required List<Widget> items,
  double height = 200.0,
  bool autoPlay = true,
  bool pauseOnHover = true,
  bool loop = true,
  Duration autoPlayInterval = const Duration(seconds: 3),
})
```
