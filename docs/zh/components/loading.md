<!-- generated:api:start -->
# AnimalLoading

## 导入
```dart
import 'package:animal_island_ui/animal_island_ui.dart';
```

## 构造函数
- `AnimalLoading`
- `AnimalLoading.dots`
- `AnimalLoading.snowflake`
- `AnimalLoading.spinner`

## 属性
- `fullScreen`
- `maxSnowCount`
- `minSnowCount`
- `size`
- `snowCount`
- `snowSeed`
- `style`
- `tip`
- `tipWidget`
- `type`

## 枚举
- `AnimalLoadingType`

<!-- generated:api:end -->

## 语言职责

默认无障碍标签使用当前生成的本地化。显式 `tip` 和 `tipWidget` 由调用者提供，
locale 改变时保持原样。

## 全屏加载

`AnimalLoading.show(context, ...)` 在最近的 `AnimalOverlayHost` 中显示全屏加载，
并返回 `AnimalLoadingHandle`：

```dart
final handle = AnimalLoading.show(context, tip: 'Syncing island...');
try {
  await sync();
} finally {
  handle.close();
}
```

`close()` 是唯一的关闭方式。重复调用会被忽略，首帧之前关闭也不会留下任何浮层条目。
host 卸载时会关闭它的加载，此时 `isClosed` 同样变为 true。两个 host（包括嵌套的）
互不共享加载。没有 host 的 context 会抛出异常；不存在根浮层回退，也没有全局 hide。

遮罩阻止对被覆盖控件的指针输入，把键盘焦点移入自身作用域（关闭时归还），并把被覆盖
控件移出无障碍树。提示文字或本地化的加载标签只播报一次。减少动态效果时指示器停止转动，
但保留加载语义。

`snowCount` 接受 `AnimalLoading.minSnowCount`（1）到 `AnimalLoading.maxSnowCount`
（100）；其他值抛出 `RangeError`。只有全屏雪花加载才会生成飘落粒子。

## 定制

`style` 接受 `AnimalLoadingStyle`，只覆盖当前指示器；`AnimalLoading.show` 接受同样的
`style`。主题的 `components.loading` 把一个 `AnimalLoadingStyle` 应用于所有指示器。
指示器颜色与全屏遮罩颜色取自样式的 `color` 与 `barrierColor` 字段。未设置的字段回落到
由当前 token 推导的默认值：指示器使用 `colors.primaryText`，提示文字为粗体
`typography.caption`，置于带 `shadows.softElevation` 的胶囊表面上，遮罩为半透明页面
背景，雪花粒子使用 `colors.info`。指示器 `size` 与圆点比例仍是构造参数；`size` 默认
无名构造器与 `spinner` 为 40、`snowflake` 为 48、`dots` 为 32。

## 示例
参见示例 Gallery 中的 [`loading_story.dart`](../../../example/lib/stories/loading_story.dart)。
