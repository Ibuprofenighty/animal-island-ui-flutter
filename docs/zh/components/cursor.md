<!-- generated:api:start -->
# AnimalCursor

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCursor`

## 属性
- `child`
- `customCursor`
- `forceAll`
- `type`

## 枚举
- `AnimalCursorType`

<!-- generated:api:end -->

## 光标规则

鼠标位于 `child` 上方时显示 `type` 对应的光标；给出 `customCursor` 时显示它。图案光标
（`defaultCursor`、`raindrop` 以及任何 `customCursor`）隐藏系统指针，在鼠标位置绘制
图案，图案左上角位于指针左上方 6 逻辑像素处；`pointer`、`text`、`notAllowed` 使用系统
光标。任何时刻只显示一个光标：只有当本区域决定光标时才绘制图案。

`forceAll: true`（默认）时，该光标也替换后代的光标，包括文本框与嵌套的
`AnimalCursor` 区域。`forceAll: false` 时，自带光标的后代（包括嵌套的
`AnimalCursor`）只显示它自己的光标，本光标只作用于没有光标的后代区域。

该区域从不抢占 `child` 或其后方区域的点击、指针事件与悬停。触摸与触控笔输入从不显示
图案；切换 `type` 会保留 `child` 的状态。爪印与雨滴图案是固定的指针素材，因此光标没有
样式。

## 本地化
AnimalCursor 不包含内置文案或语义标签。请在调用方提供的 child 中完成本地化。

## 示例
参见示例 Gallery 中的 [`cursor_story.dart`](../../../example/lib/stories/cursor_story.dart)。
