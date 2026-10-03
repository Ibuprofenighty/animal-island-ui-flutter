<!-- generated:api:start -->
# AnimalCheckbox

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalCheckbox`

## 属性
- `disabled`
- `focusNode`
- `indeterminate`
- `label`
- `onChanged`
- `readOnly`
- `size`
- `value`

## 枚举
- `AnimalCheckboxSize`

<!-- generated:api:end -->

## 本地化
复选框可选标签和分组项标签均由调用方提供。调用方负责本地化；控件提供状态语义，不添加固定文字。

## 受控状态与交互

`value` 由调用方持有，`onChanged` 提议其反值。`value` 为 false 时，`indeterminate` 提供 mixed 语义；选中状态优先。`readOnly` 阻止激活，但复选框仍可聚焦，并提供只读语义且不暴露 tap action；即使 `onChanged` 为 null 也如此。未设置 `readOnly` 时，null callback 表现为禁用。每次指针、Enter/Space 或无障碍激活至多发出一次提议，命中区域至少为 48 逻辑像素。

`AnimalCheckboxGroup` 会对 `List<T>` 值和选项创建不可变快照。选项的 `value` 必须唯一，重复值会在构造时拒绝。回调收到不可变的列表提议；组不会把每个选项注册成独立表单字段。每个复选框都是独立 Tab stop。方向键和 Home/End 可在可用选项间移动焦点，但不改变值；重排后仍按 `option.value` 保留焦点归属。

字段校验反馈由外层 `AnimalFormItem` 负责格式化和播报；复选框只持有选中与 mixed 状态。

## 示例
参见示例 Gallery 中的 [`checkbox_story.dart`](../../../example/lib/stories/checkbox_story.dart)。
