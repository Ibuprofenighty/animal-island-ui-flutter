# Animal Island UI for Flutter (animal_island_ui)

<div align="center">
  <h3>🏝️ 一款治愈系、动森风格的 Flutter 企业级开源 UI 组件库 🏝️</h3>
  <p>A Kawaii & Cozy Game-like UI Component Library for Flutter, faithfully ported from <a href="https://github.com/guokaigdg/animal-island-ui">animal-island-ui</a>.</p>
</div>

<br/>

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.19-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.3-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Components-36-brightgreen" alt="Components">
  <img src="https://img.shields.io/badge/Icons-101-orange" alt="Icons">
  <img src="https://img.shields.io/badge/License-CC--BY--NC--4.0-blue" alt="License">
  <img src="https://img.shields.io/badge/Analysis-0%20Issues-brightgreen" alt="Lints">
</div>

<br/>

---

## ✨ 核心特色 (Key Highlights)

- 🎮 **3D 拟真按压手感 (Tactile 3D Depth)**：原生微触感（`HapticFeedback.lightImpact()`）联动 4~5px 纯色切面实体下沉阴影与弹簧阻尼回弹（`Curves.easeOutBack`），还原 Nintendo Switch 动森手柄触觉！
- 🍃 **101 款可爱矢量内置图标 (101 Cute Icons)**：全套提取自原始水手与岛民矢量库，支持自适应描边变色、尺寸缩放与 Q 弹（Bounce）动效。
- 🫧 **三次贝塞尔有机气泡弹窗 (Organic Blob Modal)**：严格实现规范中 `#animal-modal-clip` 有机水滴不规则轮廓，拒绝生硬平直矩形。
- 🎀 **立体折角燕尾彩带 (Swallowtail Ribbon Title)**：双翼燕尾裁切、折叠三角阴影与三维透视倾斜。
- 🎨 **13 款动森应用瓦片配色 (Island App-Tiles)**：预设 `appPink`, `appTeal`, `appYellow`, `appGreen`, `purple`, `limeGreen` 等海岛马卡龙色板。
- 🛡️ **严格落地《七大设计法则》与《14 条视觉硬规则》**：
  - 严禁纯黑纯冷灰：文字采用大地棕色阶（`#794f27`），底色采用羊皮纸色（`#f8f8f0`）。
  - 交互控件必须为 50px 胶囊形（Pill），任何元素圆角不低于 12px。
  - 聚焦环统一采用暖黄（`#ffcc00`），严禁使用系统冷蓝色。

---

## 📦 组件总览 (36 Components Catalog)

| 分类 | 包含组件 | 说明 |
| :--- | :--- | :--- |
| **基础控件 (General)** | `AnimalButton`, `AnimalTitle`, `AnimalDivider`, `AnimalBackground`, `AnimalCursor`, `AnimalIcon` | 3D 下沉按键、燕尾彩带标题、小叶子虚线、波点背景 |
| **交互表单 (Forms)** | `AnimalInput`, `AnimalSwitch`, `AnimalCheckbox`, `AnimalRadio`, `AnimalSelect`, `AnimalDatePicker`, `AnimalTimePicker`, `AnimalForm`, `AnimalFormItem` | 50px 胶囊输入框、内阴影滑块、同心圆单选、岛屿日历与时间滚轮 |
| **数据展示 (Data Display)** | `AnimalCard`, `AnimalTag`, `AnimalCollapse`, `AnimalCarousel`, `AnimalTable`, `AnimalPagination`, `AnimalCountdown`, `AnimalTime`, `AnimalCodeBlock`, `AnimalImage` | 13 色瓦片卡片、数字翻牌瓦片倒计时、圆角斑马纹表格 |
| **反馈浮层 (Feedback)** | `AnimalModal`, `AnimalDrawer`, `AnimalTooltip`, `AnimalNotification`, `AnimalLoading`, `AnimalSkeleton`, `AnimalProgress` | 有机气泡弹窗、圆角侧抽屉、糖果条纹进度条、旋转小树叶 |
| **特色导航 (Navigation)** | `AnimalTabs`, `AnimalBackTop`, `AnimalFooter`, `AnimalTypewriter` | 胶囊滑块指示选项卡、小火箭起飞回顶、海岸线波浪底栏、NPC 对话打字机 |

---

## 🚀 快速上手 (Quick Start)

### 1. 添加依赖

在你的 Flutter 项目 `pubspec.yaml` 中引入：

```yaml
dependencies:
  animal_island_ui:
    path: ../animal_island_ui # 或发布到 pub.dev 后的版本号
```

### 2. 配置主题

在根 `MaterialApp` 中注入 `AnimalIslandTheme`：

```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AnimalColors.bg,
        extensions: const [AnimalIslandTheme.light], // 支持 AnimalIslandTheme.dark
      ),
      home: const HomePage(),
    );
  }
}
```

### 3. 使用核心组件

#### 3D 拟真按压按钮 (AnimalButton)
```dart
AnimalButton(
  type: AnimalButtonType.primary,
  size: AnimalButtonSize.middle,
  icon: const LeafIcon(size: 18, color: Colors.white),
  onPressed: () => print('Hello Island!'),
  child: const Text('Touch Me'),
)
```

#### 50px 胶囊形输入框 (AnimalInput)
```dart
AnimalInput(
  placeholder: 'Enter Island Name...',
  prefix: const SearchIcon(size: 18, color: AnimalColors.primary),
  shadow: true, // 开启 3D 实体下沉底边
  clearable: true,
  onChanged: (text) => print(text),
)
```

#### 有机气泡弹窗 (AnimalModal)
```dart
AnimalModal.show(
  context: context,
  title: const Text('Tom Nook Says...'),
  content: const Text('Welcome to your getaway island package!'),
  okText: 'Pay Mortgage',
  onOk: () => print('Paid!'),
);
```

#### 101 款可爱矢量图标 (AnimalIcons)
```dart
// 方式 A: 直接使用具名图标小部件
const LeafIcon(size: 28, color: AnimalColors.primary, bounce: true)
const AppleIcon(size: 28)
const HeartIcon(size: 28, color: AnimalColors.error)

// 方式 B: 使用通用容器
AnimalIcon(
  name: AnimalIconName.bell,
  size: 32,
  bounce: true,
  onTap: () => print('Bounced!'),
)
```

---

## 🎪 运行成品演示应用 (Animal Island Gallery)

项目内置了完整的交互式展示应用（包含全部 36 个组件的可视化 Playground 与 101 个图标的实时检索动画）：

```bash
cd example
flutter run -d chrome # 在浏览器中体验
# 或
flutter run -d windows # 在 Windows 桌面端以原生 120fps 体验
```

---

## 📜 开源协议 (License)

本项目遵循 **CC BY-NC 4.0** 协议开源（与原项目一致），仅供个人学习、技术练习与非商业用途使用。
所有设计资产及灵感归原项目 `guokaigdg/animal-island-ui` 及其版权方所有。
