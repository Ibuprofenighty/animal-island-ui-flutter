# General Components Reference

## Button

```dart
AnimalButton({
  Key? key,
  AnimalButtonType type = AnimalButtonType.primary,
  AnimalButtonSize size = AnimalButtonSize.middle,
  bool ghost = false,
  bool danger = false,
  bool loading = false,
  bool disabled = false,
  Widget? icon,
  VoidCallback? onPressed,
  required Widget child,
})
// Types: primary, defaultButton, dashed, text, link, danger, success, warning
```

## Icon

```dart
AnimalIcon({
  Key? key,
  required AnimalIconName name,
  double size = 24.0,
  Color? color,
  bool bounce = true,
})
// 101 Standalone Widgets: LeafIcon, AppleIcon, BellIcon, HeartIcon, FossilIcon, etc.
```

## Typewriter

```dart
AnimalTypewriter({
  Key? key,
  required String text,
  TextStyle? style,
  Duration speed = const Duration(milliseconds: 50),
  bool cursor = true,
  String cursorChar = '▋',
  bool loop = false,
  VoidCallback? onFinish,
})
```

## Cursor

```dart
AnimalCursor({
  Key? key,
  AnimalCursorType type = AnimalCursorType.pointer,
  bool forceAll = false,
  required Widget child,
})
// Types: pointer, raindrop
```
