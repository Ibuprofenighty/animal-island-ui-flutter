<!-- generated:api:start -->
# AnimalInput

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalInput`

## 属性
- `autofocus`
- `clearable`
- `controller`
- `disabled`
- `focusNode`
- `inputFormatters`
- `keyboardType`
- `maxLines`
- `minLines`
- `obscureText`
- `onChanged`
- `onSubmitted`
- `placeholder`
- `prefix`
- `readOnly`
- `shadow`
- `size`
- `status`
- `suffix`
- `textInputAction`

## 枚举
- `AnimalInputSize`
- `AnimalInputStatus`

<!-- generated:api:end -->

## 本地化
调用方必须提供一个稳定的 `TextEditingController`，并在 owner 生命周期结束时负责 dispose。
`AnimalInput` 借用该 controller、跟随 controller 替换且不会 dispose 它。完整
`TextEditingValue` 会保留 selection 和 IME composing 状态。`onChanged` 只向调用方报告用户编辑；
Form 直接观察同一个 controller，无需该回调再写入第二份值。

清除操作标签使用生成的 AnimalLocalizations。placeholder、前缀、后缀和输入内容仍由调用方提供。
清除操作只写入一次借用的 controller，并只调用一次 `onChanged`；只读输入不显示清除操作。

## 交互与无障碍

文本编辑由底层 `TextField` 处理。清除操作响应指针点击，并在获得焦点时响应 Enter 或 Space。传入的 `FocusNode` 仍归调用方所有，输入框会跟随替换后的节点。

错误状态会在文本框语义中标记为校验无效。`AnimalFormItem` 提供的可见标签和校验消息仍对辅助技术可见，placeholder 作为文本框提示保留。普通输入不会添加厚重的底部阴影，除非显式启用 `shadow`；不同尺寸下前后缀都位于可编辑区域之外。尺寸高度是最小高度。大字号缩放时，前后缀限制在可用宽度的一部分并可换行，输入框随之增高；文字不会缩小，可编辑区域也不会被遮挡。

## 示例
参见示例 Gallery 中的 [`input_story.dart`](../../../example/lib/stories/input_story.dart)。
