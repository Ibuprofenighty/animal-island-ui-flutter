# Feedback Components Reference

## Progress

```dart
AnimalProgress({
  Key? key,
  required double percent, // 0.0 to 1.0
  AnimalProgressSize size = AnimalProgressSize.middle,
  AnimalProgressStatus status = AnimalProgressStatus.normal,
  AnimalProgressInfoPosition infoPosition = AnimalProgressInfoPosition.right,
  bool striped = false,
  bool animated = false,
  double? height,
  Color? fillColor,
  Color? trackColor,
  String Function(double percent)? format,
})

AnimalProgress.circle({
  Key? key,
  required double percent, // 0.0 to 1.0
  double size = 120.0,
  double strokeWidth = 10.0,
  AnimalProgressStatus status = AnimalProgressStatus.normal,
  Color? fillColor,
  Color? trackColor,
  bool showInfo = true,
  String Function(double percent)? format,
})
```

## Loading

```dart
AnimalLoading({
  Key? key,
  AnimalLoadingType type = AnimalLoadingType.spinner, // spinner, snowflake, dots
  double size = 32.0,
  Color? color,
  String? tip,
  Widget? tipWidget,
  bool fullScreen = false,
})
```

Overlay Portal:
- `AnimalLoading.show(BuildContext context, {String? tip, Widget? tipWidget, AnimalLoadingType type, Color? color})`
- `AnimalLoading.hide(BuildContext context)`

## Skeleton

```dart
AnimalSkeleton({
  Key? key,
  bool loading = true,
  bool active = true,
  Widget? child,
})

// Factory Presets:
AnimalSkeleton.button({Key? key, double? width, double? height, bool active = true})
AnimalSkeleton.input({Key? key, double? width, double? height, bool active = true})
AnimalSkeleton.avatar({Key? key, double size = 40.0, BoxShape shape = BoxShape.circle, bool active = true})
AnimalSkeleton.paragraph({Key? key, int rows = 3, double? width, bool active = true})
```

## BackTop

```dart
AnimalBackTop({
  Key? key,
  required ScrollController scrollController,
  double visibilityHeight = 400.0,
  double? visibilityThreshold,
  Duration duration = const Duration(milliseconds: 500),
  Widget? icon,
  VoidCallback? onClick,
})
```

## Countdown

```dart
AnimalCountdown({
  Key? key,
  DateTime? targetTime,
  Duration? remaining,
  String format = 'HH:mm:ss',
  AnimalCountdownSize size = AnimalCountdownSize.middle,
  AnimalCountdownVariant variant = AnimalCountdownVariant.standard,
  bool bordered = true,
  ValueChanged<Duration>? onChange,
  VoidCallback? onFinish,
})
```

## Time

```dart
AnimalTime({
  Key? key,
  DateTime? time,
  bool live = false,
})
```
