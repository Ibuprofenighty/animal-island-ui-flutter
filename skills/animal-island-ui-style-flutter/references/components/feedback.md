# Feedback Components Reference

## Progress

```dart
AnimalProgress({
  Key? key,
  required double percent,
  AnimalProgressType type = AnimalProgressType.line,
  AnimalProgressSize size = AnimalProgressSize.middle,
  AnimalProgressStatus status = AnimalProgressStatus.normal,
  AnimalProgressInfoPosition infoPosition = AnimalProgressInfoPosition.right,
  bool animatedStripes = true,
  Color? strokeColor,
  Color? trailColor,
  Widget? format,
})
```

## Loading

```dart
AnimalLoading({
  Key? key,
  AnimalLoadingVariant variant = AnimalLoadingVariant.spinner,
  double size = 32.0,
  Color? color,
  String? text,
})
```

Overlay Portal:
- `AnimalLoading.show(BuildContext context, {String? text, AnimalLoadingVariant variant})`
- `AnimalLoading.hide(BuildContext context)`

## Skeleton

```dart
AnimalSkeleton({
  Key? key,
  bool loading = true,
  double? width,
  double? height,
  BorderRadius? borderRadius,
  Widget? child,
})

// Factory Presets:
AnimalSkeleton.button({Key? key, double? width, double? height})
AnimalSkeleton.input({Key? key, double? width, double? height})
AnimalSkeleton.avatar({Key? key, double size = 40.0, BoxShape shape = BoxShape.circle})
AnimalSkeleton.paragraph({Key? key, int lines = 3, double? width})
```

## BackTop

```dart
AnimalBackTop({
  Key? key,
  required ScrollController scrollController,
  double visibilityHeight = 400.0,
  double target = 0.0,
  Duration duration = const Duration(milliseconds: 450),
  Curve curve = Curves.easeOutBack,
  Widget? child,
})
```

## Countdown

```dart
AnimalCountdown({
  Key? key,
  required DateTime targetTime,
  String format = 'HH:mm:ss',
  AnimalCountdownVariant variant = AnimalCountdownVariant.standard,
  VoidCallback? onFinish,
  ValueChanged<Duration>? onChange,
})
```

## Time

```dart
AnimalTime({
  Key? key,
  required DateTime dateTime,
  String? format,
  bool relative = false,
  bool autoUpdate = true,
})
```
