# Data Display Components Reference

## Table

```dart
AnimalTable({
  Key? key,
  required List<AnimalTableColumn> columns,
  required List<List<Widget>> rows,
  bool loading = false,
  Widget? emptyWidget,
  double? minWidth,
  double? maxHeight,
})
```

## Pagination

```dart
AnimalPagination({
  Key? key,
  required int current,
  required int total,
  int pageSize = 10,
  required ValueChanged<int> onChanged,
})
```

## CodeBlock

```dart
AnimalCodeBlock({
  Key? key,
  required String code,
  String language = 'dart',
  bool showCopy = true,
})
```

## Tag

```dart
AnimalTag({
  Key? key,
  required Widget child,
  AnimalTagVariant variant = AnimalTagVariant.neutral,
  AnimalTileColor? color,
  AnimalTagSize size = AnimalTagSize.middle,
  bool disabled = false,
  Widget? icon,
  VoidCallback? onClose,
  VoidCallback? onTap,
})
// Sizes: small, middle, large
```

## Image

```dart
AnimalImage({
  Key? key,
  required ImageProvider image,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  AnimalImageVariant variant = AnimalImageVariant.standard,
  AnimalTileColor? color,
  BorderRadius? borderRadius,
  bool preview = false,
  Widget? placeholder,
  Widget? fallback,
  String? semanticLabel,
})
// Variants: standard, bordered
```
