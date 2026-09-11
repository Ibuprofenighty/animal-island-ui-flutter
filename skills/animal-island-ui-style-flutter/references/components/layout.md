# Layout Components Reference

## Card

```dart
AnimalCard({
  Key? key,
  AnimalCardType type = AnimalCardType.card,
  AnimalCardColor color = AnimalCardColor.mintTeal,
  bool pattern = false,
  bool hoverable = false,
  EdgeInsetsGeometry? padding,
  Widget? header,
  Widget? footer,
  required Widget child,
})
// Types: card, flat, dashed
```

## Title

```dart
AnimalTitle({
  Key? key,
  required String title,
  int level = 1,
  AnimalTitleColor color = AnimalTitleColor.leafGreen,
})
```

## Divider

```dart
AnimalDivider({
  Key? key,
  AnimalDividerStyle style = AnimalDividerStyle.solid,
  bool plain = false,
  Color? color,
})

// Presets:
AnimalDivider.plain({Key? key, AnimalDividerStyle style = AnimalDividerStyle.solid, Color? color})
AnimalDivider.leaf({Key? key, Color? color})
AnimalDivider.star({Key? key, Color? color})
AnimalDivider.flower({Key? key, Color? color})
```

## Background

```dart
AnimalBackground({
  Key? key,
  AnimalBackgroundType type = AnimalBackgroundType.dots,
  required Widget child,
})
// Types: dots, sprinkles
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
  required String title,
  required Widget content,
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
