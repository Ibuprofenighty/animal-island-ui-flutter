<!-- generated:api:start -->
# AnimalCard

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCard`

## 属性
- `borderRadius`
- `child`
- `color`
- `customBackgroundColor`
- `customBorderColor`
- `footer`
- `header`
- `hoverable`
- `margin`
- `onTap`
- `padding`
- `pattern`
- `semanticLabel`
- `type`

## 枚举
- `AnimalCardPattern`
- `AnimalCardType`

<!-- generated:api:end -->

## 主题行为
省略 `padding` 时，卡片根据当前主题计算内边距：
`EdgeInsets.all(theme.spacing.lg + theme.spacing.xs)`。当前标准浅色和深色预设
计算结果均为 20 逻辑像素；这是预设间距 token 的结果，不是组件另有固定默认值。
显式传入 `padding` 时由调用方覆盖主题值。卡片没有默认外阴影。

## 本地化
AnimalCard 不包含自有显示文案。调用方应本地化 child、header、footer 和传入的 semanticLabel。

## 交互与无障碍

可点击卡片表面响应指针点击，并在获得焦点时响应 Enter 或 Space。嵌套动作控件保留自己的激活；激活子动作不会调用卡片回调。每个操作的命中区域为 48 逻辑像素，相邻目标互不重叠；卡片失去焦点、被禁用、被隐藏或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`card_story.dart`](../../../example/lib/stories/card_story.dart)。
