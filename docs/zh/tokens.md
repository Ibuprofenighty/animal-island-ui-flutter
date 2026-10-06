# 主题与 token

Animal Island UI 的主题配置、定制方式与可读性约定。[English](../en/tokens.md)

## 唯一主题源

`AnimalIslandTheme` 是不可变的 Flutter `ThemeExtension`，由六组 token 和一组组件覆盖组成：

| 主题属性 | 公开值类型 | 职责 |
| --- | --- | --- |
| `colors` | `AnimalThemeColors` | 语义颜色、亮暗模式和全部 13 组色卡配对 |
| `typography` | `AnimalThemeTypography` | 字体家族、文字度量和解析后的文字样式 |
| `radii` | `AnimalThemeRadii` | 圆角 |
| `spacing` | `AnimalThemeSpacing` | 布局间距 |
| `shadows` | `AnimalThemeShadows` | 阴影值 |
| `motion` | `AnimalThemeMotion` | 过渡时长和曲线 |
| `components` | `AnimalComponentThemes` | 可选的组件级覆盖；预设中为空 |

## 配置主题

将预设（或自定义主题）的 `toThemeData()` 用作应用的 Material 主题：

```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

final app = MaterialApp(
  theme: AnimalIslandTheme.light.toThemeData(),
  darkTheme: AnimalIslandTheme.dark.toThemeData(),
  home: const SizedBox(),
);
```

在该主题之下，通过 `AnimalIslandTheme.of(context)` 读取当前值。缺少扩展时
`of` 会抛出 `StateError`；本包不会根据宿主亮度推导备用主题。

## 定制

先用某个家族的 `copyWith` 定制，再通过主题的 `copyWith` 替换该家族，最后用
`toThemeData()` 安装。组件读取当前主题，因此不存在需要同步维护的第二条样式路径。

- `AnimalTileColor` 表示色卡身份，前景和背景通过 `theme.colors.tile(identity)` 获取。
- 直接绘制文字时，通过 `theme.typography.resolve(...)` 解析样式，以应用该家族的字体配置。
- `motion` 配置过渡时长与曲线；动画同时遵循系统的“减少动态效果”设置。

token 构造函数会拒绝组件无法渲染的值：每个文字角色都必须有有限正 `fontSize`；
spacing 必须满足 `xxs ≤ xs ≤ sm ≤ md ≤ lg ≤ xl ≤ xxl`。

### 组件样式

组件外观由三层决定，取第一个给出值的层：

1. 组件自己的 `style` 参数。
2. `AnimalIslandTheme.components`。有尺寸的组件中，`middleStyle` 这类按尺寸的样式
   优先于通用的 `style`。
3. 由 token 推导的默认值。例如 middle Input 的字号是 `typography.body` 乘以 15/14。

实例参数和主题使用同一种样式类型，同一个值既能定制单个组件，也能定制整个应用：

```dart
final theme = AnimalIslandTheme.light.copyWith(
  components: AnimalComponentThemes(
    input: AnimalInputThemeData(
      style: AnimalInputStyle(borderWidth: 2),
      largeStyle: AnimalInputStyle(minHeight: 56),
    ),
    focusRing: AnimalFocusRingStyle(color: const Color(0xFF2F6FDE)),
  ),
);

final input = AnimalInput(
  controller: controller,
  style: AnimalInputStyle(textStyle: const TextStyle(fontSize: 18)),
);
```

字段命名遵循同一规则：有对应 Flutter Material 名时沿用（`fillColor`、`trackColor`），
否则为部位加角色，如 `labelTextStyle`、`placeholderTextColor`、`menuBorderRadius`、
`optionPadding`。

随交互状态变化的颜色使用 `WidgetStateProperty`。部分文字样式会与下层合并，
只改字号时仍保留主题的字体与字重。要改一个子树，用 Flutter 的 `Theme` 包裹并传入
修改后的 `AnimalIslandTheme`。

无障碍下限保持固定：48 逻辑像素命中区域；焦点环宽度至少为
`AnimalFocusRingStyle.minimumWidth`。选择焦点色和文字色时，请保持下文的对比度目标。

## 视觉与可访问性

预设的海岛配色、按钮按压深度、丝带、水滴形、纹理和数字方块构成整体风格。几何与
状态因组件而异；例如叠层深度阴影属于主色和危险色的填充按钮，而不是所有组件。

颜色角色按可读的配对设计：

- 语义填充表面使用对应的 `on*` 前景色。
- 普通表面上的语义前景（文字及有含义的图标）使用 `primaryText`、`successText`、
  `warningText`、`errorText` 或 `infoText` 角色；输入框的 warning 边框也使用
  `warningText`。
- `focusYellow` 是焦点指示颜色；浅色预设采用与相邻表面形成对比的暖赭黄。
- 不要在组件内派生第二份调色表。覆盖颜色时，请自行检查前景/背景配对的对比度。

目标对比度：可用文字 4.5:1，有含义的可用图标与焦点轮廓 3:1。降低对比度的文字仅限
真正禁用或不可用的状态：禁用的 Collapse 标题和 tab 项；禁用的 Input、Switch、
Checkbox、Radio 文字；禁用的 Select 触发器和选项；不可选的日历日期；以及禁用的
TimePicker 滚轮文字和“Now”按钮文案。

## 字体

Nunito 与 Noto Sans SC 可变字体随包提供，并以包限定的 family 名称注册，因此无需
下载字体即可离线渲染文字。其 SIL Open Font License 1.1 文本位于 `assets/licenses/`。
署名信息见[来源说明](provenance.md)。
