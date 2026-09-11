# Data Display Components Reference

## Table

```dart
AnimalTable({
  Key? key,
  required List<String> columns,
  required List<List<String>> rows,
  EdgeInsetsGeometry? padding,
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
  required String label,
  AnimalCardColor color = AnimalCardColor.mintTeal,
  AnimalTagSize size = AnimalTagSize.middle,
  bool closable = false,
  VoidCallback? onClose,
})
```

## Image

```dart
AnimalImage({
  Key? key,
  required String src,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  AnimalImageVariant variant = AnimalImageVariant.plain,
  bool preview = true,
  Widget? placeholder,
  Widget? fallback,
})
// Variants: plain, bordered
```
