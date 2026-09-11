# Overlays Reference

## Modal

```dart
// Standard Modal
AnimalModal.show({
  required BuildContext context,
  required String title,
  required Widget content,
  String okText = 'OK',
  String? cancelText,
  VoidCallback? onOk,
  VoidCallback? onCancel,
})

// Dialogue Box with Character Speech Stream
AnimalModal.showDialogue({
  required BuildContext context,
  required String speaker,
  required String dialogue,
  Widget? avatar,
  VoidCallback? onFinish,
})
```

## Drawer

```dart
AnimalDrawer.show({
  required BuildContext context,
  String? title,
  Widget? footer,
  bool maskClosable = true,
  AnimalDrawerPlacement placement = AnimalDrawerPlacement.right,
  required Widget child,
})
// Placements: left, right, top, bottom
```

## Tooltip

```dart
AnimalTooltip({
  Key? key,
  required String message,
  AnimalTooltipVariant variant = AnimalTooltipVariant.bubble,
  AnimalTooltipPlacement placement = AnimalTooltipPlacement.top,
  Duration waitDuration = const Duration(milliseconds: 300),
  required Widget child,
})
// Variants: bubble, island
```
