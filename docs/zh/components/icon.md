<!-- generated:api:start -->
# AnimalIcon

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalIcon`

## 属性
- `bounce`
- `color`
- `data`
- `focusNode`
- `monochrome`
- `onTap`
- `semanticLabel`
- `size`
- `strokeColor`
- `strokeWidth`

<!-- generated:api:end -->

## 本地化
交互式标准图标在未提供 semanticLabel 或 AnimalIconData.semanticLabel 时使用生成的本地图标名称。调用方标签优先；未标注的装饰图标仍从语义树中排除。

## 自定义 SVG 输入
`AnimalIconData.svg` 仅接受受限 SVG 子集：一个闭合平衡的 `<svg>` 根、白名单形状元素与呈现属性，以及本地片段引用。空输入、DTD、实体声明、脚本、样式、事件属性和外部资源都会被拒绝。输入上限为 UTF-8 256 KiB、2,000 个元素和 64 层嵌套。渲染时遇到无效或不支持的标记会抛出 `ArgumentError`。单引号和双引号都可用；`stroke="none"` 保持不可见，显式 tint 可替换可见描边，也可替换 `currentColor`。tint alpha 规范化为三位小数并替换受影响描边的 `stroke-opacity`；普通 group `opacity` 保持不变。正数自定义描边宽度规范化为两位小数；零和负数规范化为 `0`。

## 交互与无障碍

每个可操作部分响应指针点击，并在获得焦点时响应 Enter 或 Space，同时提供对应的无障碍语义和焦点处理。组件包含多个项目时，项目之间的键盘导航由组件自身处理。每个操作的命中区域为 48 逻辑像素，相邻操作互不重叠；控件失去焦点、被禁用、被隐藏、回调被替换或被卸载时，未完成的激活会被取消。

## 示例
参见示例 Gallery 中的 [`icon_story.dart`](../../../example/lib/stories/icon_story.dart)。
