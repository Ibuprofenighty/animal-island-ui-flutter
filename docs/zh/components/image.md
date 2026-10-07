<!-- generated:api:start -->
# AnimalImage

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalImage`

## 属性
- `borderRadius`
- `color`
- `fallback`
- `fit`
- `height`
- `image`
- `placeholder`
- `preview`
- `semanticLabel`
- `variant`
- `width`

## 枚举
- `AnimalImageVariant`

<!-- generated:api:end -->

## 本地化
预览入口使用生成的默认文案或调用者标签格式文案。预览打开后，route 名称（`imagePreviewRouteLabel`，只朗读一次）、
关闭按钮与屏障标签仍从当前语言解析，并会在路由保持打开时响应语言切换。

## 预览

预览以与 Modal、Drawer 相同的 route 呈现：关闭按钮、Escape、系统返回和点击遮罩都会关闭它；
焦点保持在预览内，关闭后回到打开时获得焦点的控件。减少动态效果时预览直接出现，没有过渡。
关闭按钮是包内共用的图标操作：48 逻辑像素目标、焦点环、本地化的关闭标签作为无障碍名称，
以及按 `WidgetState.hovered` 解析的悬停填充；减少动态效果时填充立即切换。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`image_story.dart`](../../../example/lib/stories/image_story.dart)。
