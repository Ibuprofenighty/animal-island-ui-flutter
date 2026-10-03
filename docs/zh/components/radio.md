<!-- generated:api:start -->
# AnimalRadio

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalRadio`

## 属性
- `activeColor`
- `disabled`
- `focusNode`
- `groupValue`
- `label`
- `onChanged`
- `readOnly`
- `size`
- `value`

## 枚举
- `AnimalRadioSize`

<!-- generated:api:end -->

## 本地化
单选框可选标签和分组项标签均由调用方提供。调用方负责本地化；控件提供状态语义，不添加固定文字。

## 受控状态与交互

`AnimalRadio` 通过 `onChanged` 提议自己的 `value`；`AnimalRadioGroup` 使用调用方传入的选中值。组会快照选项，并拒绝重复的 `option.value`。组内只有一个 roving Tab stop。方向键在可用选项间移动（水平布局的左右键遵循文本方向）；Home/End 移到首个/末个可用项。导航移动焦点并提议目标值；`readOnly` 允许移动焦点但不发出提议。重新进入组时，焦点跟随当前仍可用的选中项，否则落在首个可用项。重排通过 `option.value` 保留焦点归属。

`readOnly` 控件仍可聚焦，并提供只读语义且不暴露 tap action；null callback 时也如此。未设置 `readOnly` 时，null callback 表现为禁用。指针、Enter/Space 和无障碍激活每次至多发出一次提议，命中区域至少为 48 逻辑像素。三个尺寸的圆角半径为 12、14、16 逻辑像素，并保留选中勾图标；`activeColor` 改变选中表面色，焦点指示仍然可见。

## 示例
参见示例 Gallery 中的 [`radio_story.dart`](../../../example/lib/stories/radio_story.dart)。
