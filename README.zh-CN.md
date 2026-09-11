# 🍃 Animal Island UI for Flutter

[![pub package](https://img.shields.io/badge/pub-0.0.1-blue.svg)](https://pub.dev)
[![license](https://img.shields.io/badge/license-CC%20BY--NC%204.0-brightgreen.svg)](LICENSE)
[![docs](https://img.shields.io/badge/docs-design--system-teal.svg)](docs/design-system/)

> 纯原生、零三方 UI 组件依赖（仅依赖 flutter_svg 矢量渲染引擎）、治愈系动森风格的企业级 Flutter 组件库。全量涵盖 36 个控件与 101 款可爱矢量图标。

[English](README.md) | [中文说明](README.zh-CN.md)

---

## 🌟 核心特性

- **36 款生产级控件全量覆盖**：基础、表单、数据、反馈、导航全系列支持。
- **101 款原生可爱矢量图标**：叶子、苹果、大头菜、铃钱、化石等全量 Canvas 矢量化。
- **七大设计法则与 14 条视觉硬规则**：50px 胶囊圆角、3D 纯切面下沉厚阴影、有机三次贝塞尔 Blob 模态框、燕尾彩带飘带。
- **现代响应式设计令牌**：强类型设计常量与统一运行时 `AnimalIslandTheme`（自适应 Parchment 羊皮纸白昼与 Campfire Night 篝火黑夜模式）。
- **零三方 UI 组件依赖**：纯原生组件体系（仅底层收敛依赖 `flutter_svg` 矢量渲染引擎），AOT 友好与深度 Tree-shaking。

## 📦 快速引入

```yaml
dependencies:
  animal_island_ui: ^0.0.1
```

```dart
import 'package:animal_island_ui/animal_island_ui.dart';

// 3D 实体下沉按钮
AnimalButton(
  type: AnimalButtonType.primary,
  onPressed: () {},
  child: const Text('保存游戏'),
)

// 贝塞尔有机水滴弹窗
AnimalModal.show(
  context: context,
  title: '海岛广播',
  content: const Text('今晚 8 点广场将举行烟火大会！'),
)
```

## 📚 权威设计文档

- [设计系统与规则定义](docs/design-system/README.md)
- [架构决策记录 (ADR)](docs/adr/README.md)
- [开发者指南](docs/development/README.md)
- [Agent 技能包 (animal-island-ui-style-flutter)](skills/animal-island-ui-style-flutter/README.md)
