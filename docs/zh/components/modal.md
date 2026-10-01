<!-- generated:api:start -->
# AnimalModal

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalModal`

## 属性
- `cancelText`
- `content`
- `footer`
- `okText`
- `onClose`
- `onOk`
- `title`
- `typeSpeed`
- `typewriter`
- `width`

<!-- generated:api:end -->

Modal surface 是内部渲染细节。

## 语言行为

默认操作文案和 route barrier label 来自当前生成的本地化；route 打开期间也会更新。
调用者提供的操作文案和 modal 内容仍由调用者负责。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`modal_story.dart`](../../../example/lib/stories/modal_story.dart)。
