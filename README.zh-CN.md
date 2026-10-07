# 🍃 Animal Island UI for Flutter (animal_island_ui)

<br/>
<div align="center">
  <h3>🏝️ 温馨可爱的海岛风格 Flutter 组件库 🏝️</h3>
  <p><a href="https://github.com/guokaigdg/animal-island-ui">animal-island-ui</a> 设计语言的 Flutter 实现：暖色调、有按压手感的按钮和手绘风海岛细节。</p>
</div>
<br/>

<div align="center">
  <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FIbuprofenighty%2Fanimal-island-ui-flutter%2Fmain%2Fcatalog%2Fsdk.lock.json&query=%24.flutter.frameworkVersion&label=Flutter&logo=flutter&color=02569B&style=flat-square" alt="Flutter 版本">
  <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FIbuprofenighty%2Fanimal-island-ui-flutter%2Fmain%2Fcatalog%2Fsdk.lock.json&query=%24.flutter.dartSdkVersion&label=Dart&logo=dart&color=0175C2&style=flat-square" alt="Dart 版本">
  <a href="https://github.com/Ibuprofenighty/animal-island-ui-flutter/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/Ibuprofenighty/animal-island-ui-flutter/ci.yml?branch=main&label=CI&style=flat-square" alt="CI"></a>
  <img src="https://img.shields.io/badge/components-36-blue?style=flat-square" alt="组件：36">
  <img src="https://img.shields.io/badge/icons-101-orange?style=flat-square" alt="图标：101">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-CC%20BY--NC%204.0%20(non--commercial)-lightgrey?style=flat-square" alt="许可证：CC BY-NC 4.0（非商业）"></a>
</div>
<br/>

<p align="center">
  <a href="README.md">English</a> | 简体中文
</p>

## 📖 简介

Animal Island UI 是一个受温馨生活模拟类海岛风格启发的 Flutter 组件库，将
[guokaigdg/animal-island-ui](https://github.com/guokaigdg/animal-island-ui)
的视觉语言移植为 Flutter 组件：奶油色底面上的大地棕文字、胶囊形控件、有按压
深度的按钮、丝带标题、水滴形对话框，以及 101 个海岛图标。

所有公开 API 都从同一个入口导入：
`package:animal_island_ui/animal_island_ui.dart`，并通过一个支持浅色与深色预设的
主题扩展统一设置样式。

## ✨ 核心亮点

- 🎮 **有手感的按钮**：主色与危险色的填充按钮带有叠层深度阴影，激活时会下沉；
  可交互控件提供轻微触感反馈。
- 🍃 **101 个矢量图标**：树叶、苹果、铃钱、化石等海岛符号，统一由 `AnimalIcon`
  渲染 `AnimalIcons` 描述符，支持尺寸、颜色与可选的弹跳动画。
- 🫧 **有机造型**：水滴形模态框、燕尾丝带标题、图案背景，以及海浪或树木页脚。
- 🎨 **一套主题、六组 token**：`AnimalIslandTheme` 是 Flutter `ThemeExtension`，
  包含颜色、字体、圆角、间距、阴影和动效，提供浅色与深色预设及 13 组色卡配对。
- 📋 **表单与数据**：带控制器和校验规则的 `AnimalForm`、日期与时间选择器，以及
  惰性构建（`rowCount` + `rowBuilder`）并可配合分页的 `AnimalTable`。
- 🌏 **内置中英文**：库内文案通过导出的 `AnimalLocalizations` 本地化；随包附带
  Nunito 与 Noto Sans SC 字体，运行时无需联网下载字体。
- ♿ **尊重动效设置**：动画遵循系统的“减少动态效果”设置。

## 🖼️ 预览

- **在线 Gallery**：<https://ibuprofenighty.github.io/animal-island-ui-flutter/>
  展示全部 36 个组件、101 图标浏览器和三个示例工作流（表单、浮层、数据表格）。
- **本地运行**：Gallery 源码位于 [`example/`](example/README.md)。

## 📦 安装

通过本 Git 仓库使用本包。在应用的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  animal_island_ui:
    git:
      url: https://github.com/Ibuprofenighty/animal-island-ui-flutter.git
      ref: main
```

然后运行 `flutter pub get`。支持的 Flutter 与 Dart 版本见上方徽章（记录于
[`catalog/sdk.lock.json`](catalog/sdk.lock.json)），最低版本约束见
[`pubspec.yaml`](pubspec.yaml)。

## 🚀 快速开始

### 1. 配置主题与本地化

```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AnimalIslandTheme.light.toThemeData(),
      darkTheme: AnimalIslandTheme.dark.toThemeData(),
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      localeResolutionCallback: (locale, _) => resolveAnimalLocale(locale),
      // 通知与全屏 Loading 在最近的 AnimalOverlayHost 中打开。
      builder: (context, child) =>
          AnimalOverlayHost(child: child ?? const SizedBox.shrink()),
      home: const IslandHomePage(),
    );
  }
}
```

任意地区的中文 locale 都解析为中文；其他或缺省 locale 解析为英文。在组件树内
使用 `AnimalIslandTheme.of(context)` 读取当前主题。

### 2. 使用组件

```dart
class IslandHomePage extends StatefulWidget {
  const IslandHomePage({super.key});

  @override
  State<IslandHomePage> createState() => _IslandHomePageState();
}

class _IslandHomePageState extends State<IslandHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimalCard(
          header: const AnimalTitle(child: Text('海岛广场')),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimalIcon(data: AnimalIcons.leaf, size: 28, bounce: true),
              const SizedBox(height: 12),
              AnimalInput(
                controller: _searchController,
                placeholder: '搜索海岛...',
                clearable: true,
              ),
              const SizedBox(height: 12),
              AnimalButton(
                icon: const AnimalIcon(data: AnimalIcons.apple, size: 18),
                onPressed: () => AnimalModal.confirm(
                  context: context,
                  title: const Text('海岛广播'),
                  content: const Text('今晚广场有烟花大会！'),
                ),
                child: const Text('出发探索'),
              ),
              AnimalButton(
                variant: AnimalButtonVariant.outlined,
                onPressed: () =>
                    AnimalNotification.success(context, message: '已保存！'),
                child: const Text('发送通知'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

完整可运行示例见 [`example/lib/quick_start.dart`](example/lib/quick_start.dart)。

## 🧩 组件（36 个）

| 分类 | 组件 |
| :--- | :--- |
| **通用** | `AnimalButton`、`AnimalIcon`、`AnimalTypewriter`、`AnimalCursor` |
| **布局与导航** | `AnimalCard`、`AnimalTitle`、`AnimalDivider`、`AnimalBackground`、`AnimalCollapse`、`AnimalTabs`、`AnimalCarousel` |
| **表单控件** | `AnimalInput`、`AnimalSwitch`、`AnimalCheckbox`、`AnimalRadio`、`AnimalSelect`、`AnimalDatePicker`、`AnimalTimePicker` |
| **表单** | `AnimalForm`、`AnimalFormItem` |
| **浮层** | `AnimalModal`、`AnimalDrawer`、`AnimalTooltip` |
| **反馈** | `AnimalProgress`、`AnimalLoading`、`AnimalSkeleton`、`AnimalBackTop`、`AnimalCountdown`、`AnimalTime`、`AnimalNotification` |
| **数据展示** | `AnimalTable`、`AnimalPagination`、`AnimalCodeBlock`、`AnimalTag`、`AnimalImage` |
| **装饰** | `AnimalFooter` |

复选框和单选框另有 `AnimalCheckboxGroup` 与 `AnimalRadioGroup`。Switch、Checkbox、Radio 和 Select 的当前值由调用方持有，
回调只提议更新。只读控件仍可聚焦但不激活。Checkbox 各项保留独立 Tab stop；Radio 组使用一个
roving Tab stop。每个组件在 [`docs/zh/components/`](docs/zh/components/) 下都有参考页面。

## 🍎 图标（101 个）

所有图标都是 `AnimalIcons` 上的常量，并由同一个组件绘制：

```dart
const icon = AnimalIcon(data: AnimalIcons.bell, size: 28);
```

可在 [Gallery](https://ibuprofenighty.github.io/animal-island-ui-flutter/) 或
[图标索引](docs/zh/components/icons.md) 中浏览完整图标集。

## 📚 文档

| 文档 | 用途 |
| :--- | :--- |
| [文档首页](docs/zh/README.md) · [English](docs/en/README.md) | 全部指南与组件参考的索引 |
| [主题与 token](docs/zh/tokens.md) | 主题家族、定制、字体与可访问性 |
| [Gallery 工作流](docs/zh/workflows.md) | 表单、浮层与数据示例 |
| [AI Agent Skill](skills/animal-island-ui-style-flutter/SKILL.zh-CN.md) | 供 AI 编程助手使用本包的 Skill |
| [架构决策](docs/adr/README.md) | 关键设计决策 |
| [贡献指南](CONTRIBUTING.md) | 反馈问题与从源码构建（不接受 Pull Request） |
| [更新日志](CHANGELOG.md) · [安全策略](SECURITY.md) | 版本历史与漏洞报告 |

## 🛠️ 本地开发

```bash
git clone https://github.com/Ibuprofenighty/animal-island-ui-flutter.git
cd animal-island-ui-flutter
flutter pub get
flutter test

# 运行 Gallery
cd example
flutter pub get
flutter run -d chrome
```

## ⚠️ 说明与免责声明

- 本项目为独立开源项目，与任天堂或任何游戏公司无隶属关系，也未获其授权或背书。
  Animal Crossing（集合啦！动物森友会）是任天堂株式会社的商标。
- 视觉设计遵循上游 [animal-island-ui](https://github.com/guokaigdg/animal-island-ui)
  项目，署名信息见 [NOTICE](NOTICE) 与[来源说明](docs/zh/provenance.md)。

## 📄 许可证

采用 **知识共享 署名-非商业性使用 4.0 国际许可协议（CC BY-NC 4.0）**。在署名的
前提下可以使用、分享和改编本项目，但**不得用于商业目的**。完整条款见
[LICENSE](LICENSE)，署名见 [NOTICE](NOTICE)。随包附带的 Nunito 与 Noto Sans SC
字体采用 SIL Open Font License 1.1（见 `assets/licenses/`）。
