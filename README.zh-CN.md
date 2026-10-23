<div align="center">

# 🍃 Animal Island UI for Flutter

**有按压手感的控件、纸纹底板与丝带标题，组成温馨的海岛工具箱。**

[Animal Island UI 设计语言](https://github.com/guokaigdg/animal-island-ui)的全新 Flutter 实现。

<img src="https://img.shields.io/badge/version-0.0.1-blue?style=flat-square" alt="版本 0.0.1">
<img src="https://img.shields.io/badge/status-experimental-orange?style=flat-square" alt="实验版本">
<img src="https://img.shields.io/badge/components-40-4b8b63?style=flat-square" alt="40 个组件族">
<img src="https://img.shields.io/badge/SVG_glyphs-163-b88746?style=flat-square" alt="163 个 SVG 图标">
<img src="https://img.shields.io/badge/Flutter-3.47.3%2B-02569B?style=flat-square&logo=flutter" alt="Flutter 3.47.3 或更新版本">
<img src="https://img.shields.io/badge/Dart-3.13.3%2B-0175C2?style=flat-square&logo=dart" alt="Dart 3.13.3 或更新版本">

[English](README.md) · 简体中文

**[打开在线 Gallery](https://ibuprofenighty.github.io/animal-island-ui-flutter/) · [组件 API](docs/API.md) · [AI 使用 Skill](skills/animal-island-ui-flutter/SKILL.zh-CN.md)**

</div>

## ✨ 核心能力

- **40 个组件族**：覆盖表单、导航、数据、反馈和海岛装饰，统一从一个公开入口导入。
- **163 个 SVG 图标**：使用 `IslandIcon` 与 `IslandGlyph`，多色素材保留自身的绘制角色。
- **明暗主题预设**、语义 Token 与组件样式；定制能力边界由对应契约明确说明。
- **可组合交互**：受控值、调用方自有控制器、键盘／焦点行为及减少动态效果契约。
- **在线与本地 Gallery**：组件目录、首页与使用指南。`IslandLocalizations` 提供中英文默认文案，应用自己的内容由应用管理。

当前为**实验版本 0.0.1**，尚未完成全部平台视觉与生产验收。使用前请阅读[验证状态](#-验证状态)。

## 🏝️ 在线体验

[**进入 Flutter Gallery →**](https://ibuprofenighty.github.io/animal-island-ui-flutter/)

| 想先看什么 | 入口 |
| :--- | :--- |
| 海岛首页与主题 | [首页](https://ibuprofenighty.github.io/animal-island-ui-flutter/) |
| 按压、悬停与表单组合 | [Button](https://ibuprofenighty.github.io/animal-island-ui-flutter/#/button) · [Select](https://ibuprofenighty.github.io/animal-island-ui-flutter/#/select) · [Form](https://ibuprofenighty.github.io/animal-island-ui-flutter/#/form) |
| 图片、装饰与反馈 | [Carousel](https://ibuprofenighty.github.io/animal-island-ui-flutter/#/carousel) · [Icon](https://ibuprofenighty.github.io/animal-island-ui-flutter/#/icon) · [Notification](https://ibuprofenighty.github.io/animal-island-ui-flutter/#/notification) |

这是本仓库的 Flutter Web 预览；[上游 React Gallery](https://guokaigdg.github.io/animal-island-ui/#/)是设计参考。建议先用桌面 Chrome 或 Edge 体验。预览发布成功不代表全部验收通过，已知限制见下文。

## 📦 本地安装

克隆本仓库后通过本地路径使用。当前未宣称已发布到 pub.dev；无需安装即可先试用在线 Gallery。

```sh
git clone https://github.com/Ibuprofenighty/animal-island-ui-flutter.git animal_island_ui
```

将本实现的检出目录或解压包放在应用旁，目录名设为 `animal_island_ui`，然后添加：

```yaml
dependencies:
  animal_island_ui:
    path: ../animal_island_ui
```

按实际位置调整路径，运行 `flutter pub get`。包名和导入路径统一为 `animal_island_ui`；最低 SDK 约束见 [pubspec.yaml](pubspec.yaml)。

## 🚀 快速开始

<details>
<summary>展开完整 Flutter 示例</summary>

```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() => runApp(const IslandApp());

class IslandApp extends StatelessWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: IslandTheme.create(),
    localizationsDelegates: IslandLocalizations.delegates,
    supportedLocales: IslandLocalizations.supportedLocales,
    home: const IslandHome(),
  );
}

class IslandHome extends StatelessWidget {
  const IslandHome({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SizedBox(
        width: 360,
        child: IslandCard(
          header: const IslandTitle(child: Text('海岛广场')),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IslandIcon(IslandGlyph.leaf, size: 32),
              const SizedBox(height: 12),
              const Text('留一小块空间，发现日常的新意。'),
              const SizedBox(height: 20),
              IslandButton(
                variant: IslandButtonVariant.primary,
                onPressed: () => showIslandModal<void>(
                  context: context,
                  title: const Text('欢迎登岛'),
                  builder: (_) => const Text('海岛生活从这里开始。'),
                ),
                child: const Text('出发探索'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

</details>

使用 `IslandTheme.create(brightness: Brightness.dark)` 创建深色预设。运行时主题切换与组件定制遵循 [API 指南](docs/API.md)及相应[组件契约](#-文档入口)；示例不代表任意自定义配色会自动满足对比度要求。

## 🧩 组件目录

数量按目录中的组件族计算，不把每个辅助类或分组控件重复计数。

| 分类 | 组件 |
| :--- | :--- |
| 通用 | Button、Icon、Typewriter、Cursor |
| 布局与装饰 | Card、Title、Divider、Background、Footer、Collapse |
| 导航 | Tabs、Pagination、Carousel、BackTop |
| 表单与输入 | Input、Checkbox、Radio、Switch、Select、Rate、DatePicker、TimePicker、Form、Upload |
| 数据展示 | Table、Tag、Image、Avatar、Badge、CodeBlock |
| 反馈 | Tooltip、Notification、Loading、Skeleton、Progress |
| 时间与计数 | Time、Countdown、CountUp |
| 浮层 | Modal、Drawer |

公开名称包括 `IslandTextField`、`IslandRadioGroup`、`IslandCheckboxGroup` 等，以[公开入口声明](lib/animal_island_ui.dart)为准。

## 🖼️ 运行 Gallery

从完整源码检出目录运行：

```bash
flutter pub get
cd example
flutter pub get
flutter run -d windows
# 或：flutter run -d chrome
```

[Gallery 指南](example/README.md)说明其配置及素材。[原 Web 参考站](https://guokaigdg.github.io/animal-island-ui/#/)是上游设计参考，不是本 Flutter 实现的部署版本。

## 📚 文档入口

| 文档 | 用途 |
| :--- | :--- |
| [API 指南](docs/API.md) · [公开声明](lib/animal_island_ui.dart) | 配置、组合与接口能力 |
| [设计契约](docs/DESIGN.md) | 主题、颜色、动效及参考决定 |
| [验收范围](docs/ACCEPTANCE.md) | 证据要求和限制 |
| [架构](ARCHITECTURE.md) · [维护指南](docs/MAINTENANCE.md) | 所有权、扩展与开发 |
| [Agent 使用 Skill](skills/animal-island-ui-flutter/SKILL.md) · [中文](skills/animal-island-ui-flutter/SKILL.zh-CN.md) | 组件契约引用及使用指导 |
| [变更记录](CHANGELOG.md) · [权利与来源](docs/RIGHTS.md) | 版本变化及素材具体条款 |

## 🔎 验证状态

首批验收目标为 Windows 和 Web，移动端验收后续进行。**整库验收仍未完成。** 最近一次独立核验的运行时检查点保留 Notification／Tooltip 的 **18 项数值测量失败**，适用已记录的测量限制；这些失败没有改记为通过。

仍有五项边界：合格浏览器真实悬停中间帧、Edge 实际 375px 修改后画面、OS／物理呈现、当前构建现场及完整实际 Web 前后对照，以及全内容 60fps 声明。具体范围和具名例外由[验收契约](docs/ACCEPTANCE.md)及[设计权威](docs/DESIGN.md)拥有，本 README 不复制具体机制或决定。

键盘、语义及对比度契约仍在范围内；当前验收不包含读屏软件运行。不宣称可商用就绪或全面无障碍认证。

## 📄 许可与致谢

新 Dart 实现采用 [MIT 许可](LICENSE)。第三方图标、场景、照片及字体保留各自条款和[来源声明](NOTICE)。所有者已确认 21 项场景／Logo／照片素材及 GROBOLD 字体可随本公开仓库分发；这不是无条件商业许可或独立法律核验。权威记录见[权利与来源](docs/RIGHTS.md)。
