# Overlays Reference

## Modal

```dart
// Standard Modal
AnimalModal.show({
  required BuildContext context,
  Widget? title,
  Widget? content,
  String? okText,
  String? cancelText,
  VoidCallback? onOk,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
})

// Dialogue Box with Character Speech Stream
AnimalModal.showDialogue({
  required BuildContext context,
  String? speaker,
  String? dialogue,
  String? message,
  Widget? avatar,
  VoidCallback? onFinish,
})
```

## Drawer

```dart
AnimalDrawer.show({
  required BuildContext context,
  required Widget child,
  Widget? title,
  Widget? footer,
  bool maskClosable = true,
  AnimalDrawerPlacement placement = AnimalDrawerPlacement.right,
  double? width,
  double? height,
})
// Placements: left, right, top, bottom
```

## Tooltip

```dart
AnimalTooltip({
  Key? key,
  required Widget child,
  required String message,
  Widget? title,
  AnimalTooltipVariant variant = AnimalTooltipVariant.standard, // standard, island
  bool bordered = true,
  TooltipTriggerMode triggerMode = TooltipTriggerMode.tap,
  Duration waitDuration = const Duration(milliseconds: 300),
})
```
