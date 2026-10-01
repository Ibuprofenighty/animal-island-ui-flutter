<!-- generated:api:start -->
# AnimalTooltip

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalTooltip`

## 属性
- `bordered`
- `child`
- `message`
- `showDuration`
- `title`
- `triggerMode`
- `variant`
- `waitDuration`

## 枚举
- `AnimalTooltipVariant`

<!-- generated:api:end -->

## 语言职责

Tooltip 的 message、rich message 和 title 都由调用者提供。宿主应用应自行翻译，
并在 locale 改变时重建 tooltip。

## 示例
参见示例 Gallery 中的 [`tooltip_story.dart`](../../../example/lib/stories/tooltip_story.dart)。
