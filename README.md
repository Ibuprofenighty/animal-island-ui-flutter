# 🍃 Animal Island UI for Flutter (animal_island_ui)

<br/>
<div align="center">
  <h3>🏝️ A Cozy, Kawaii Island-Style UI Component Library for Flutter 🏝️</h3>
  <p>Faithfully ported and re-architected from <a href="https://github.com/guokaigdg/animal-island-ui">animal-island-ui</a> for enterprise production Flutter applications.</p>
</div>
<br/>

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.19-02569B?logo=flutter&style=flat-square" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.3-0175C2?logo=dart&style=flat-square" alt="Dart">
  <img src="https://img.shields.io/badge/components-36-blue?style=flat-square" alt="Components">
  <img src="https://img.shields.io/badge/icons-101-orange?style=flat-square" alt="Icons">
  <img src="https://img.shields.io/badge/license-CC--BY--NC--4.0-brightgreen.svg?style=flat-square" alt="License: CC BY-NC 4.0">
  <img src="https://img.shields.io/badge/analysis-0%20issues-brightgreen?style=flat-square" alt="Analysis">
</div>
<br/>

<p align="center">
  English | <a href="./docs/README.zh-CN.md">简体中文</a>
</p>

## Introduction

This project is a lightweight, healing island-style UI component library built for Flutter, faithfully ported from [guokaigdg/animal-island-ui](https://github.com/guokaigdg/animal-island-ui). It adheres strictly to the original warm life-sim game design language, while providing enterprise-grade production quality: zero third-party UI dependencies (relying solely on vector rendering), zero memory leaks, virtualized scrolling, and zero-GC frame performance.

## Key Highlights

- 🎮 **Tactile 3D Depth**: Native haptic feedback (`HapticFeedback.lightImpact()`) coupled with 4~5px solid stacked sinking shadows and smooth spring physics (`Curves.easeOutBack`), recreating the tactile response of a Nintendo Switch game console!
- 🍃 **101 Native Vector Icons**: Full suite of iconic island symbols (leaf, apple, turnip, bell, fossil, star) rendered directly with vector paths, supporting tinting, scaling, and organic bounce animations.
- 🫧 **Cubic-Bezier Organic Blob Modal**: Uses `AnimalBlobClipper` to create a natural water-droplet silhouette, rejecting rigid rectangular dialogue boxes.
- 🎀 **Swallowtail Ribbon Title**: Dual-winged swallowtail cuts, folded shadow triangles, and three-dimensional perspective tilt.
- 🎨 **13 Island App-Tile Palettes**: Earth-brown text, cream parchment backgrounds, mint-teal accents, and 13 vibrant fruit color cards out-of-the-box.
- ⚡ **High-Performance Zero-GC Architecture**: Long data tables feature virtualized scrolling ($O(\text{visibleRows})$), typewriter text uses pre-cached Unicode graphemes for zero-GC frame ticks, and carousel timers automatically pause when inactive via `TickerMode`.

## Preview

- **Interactive Gallery**: Run the comprehensive example app in the `example/` directory directly on Web, Windows, macOS, iOS, or Android.
- **Cross-Platform Verified**: Pixel-perfect fidelity across desktop, mobile, and web runtimes.

## 🚀 Use AI to Generate animal-island-ui Pages

Non-developer or want to prototype fast? Use the [one-click prompt](./docs/one-click-prompt.md) — no manual setup needed.

**4 steps:**

1. Copy the prompt block from [`docs/one-click-prompt.md`](./docs/one-click-prompt.md).
2. Paste it into any URL-capable AI tool (Cursor / Claude / ChatGPT / Gemini / Windsurf).
3. Specify what page you want (e.g. "villager journal", "island shop checkout", "inventory modal").
4. Copy the complete, ready-to-run Flutter code.

Using an AI coding agent (Claude Code / Cursor / Windsurf)? Install the official skill:
- [`skills/animal-island-ui-style-flutter/`](./skills/animal-island-ui-style-flutter/SKILL.md)

## Installation

Add the dependency to your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  animal_island_ui:
    path: ../animal_island_ui # or pub.dev version
```

Or run:

```bash
flutter pub add animal_island_ui
```

## Quick Start

### 1. Configure Theme

Wrap your root `MaterialApp` with `AnimalIslandTheme` or use the official `toThemeData()` export:

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
      home: const IslandHomePage(),
    );
  }
}
```

### 2. Use Core Components

```dart
// 3D Physical Sinking Button
AnimalButton(
  type: AnimalButtonType.primary,
  size: AnimalButtonSize.middle,
  icon: const LeafIcon(size: 18, color: Colors.white),
  onPressed: () => print('Adventure started!'),
  child: const Text('Explore Island'),
)

// 50px Pill Input
AnimalInput(
  placeholder: 'Search deserted island...',
  prefix: const SearchIcon(size: 18, color: AnimalColors.primary),
  shadow: true,
  clearable: true,
  onChanged: (text) => print(text),
)

// Organic Blob Modal
AnimalModal.show(
  context: context,
  title: const Text('Island Broadcast'),
  content: const Text('Fireworks show at the plaza tonight at 8 PM!'),
  okText: 'Check it out',
  onOk: () => print('Attending!'),
);

// 101 Vector Icons
const LeafIcon(size: 28, color: AnimalColors.primary, bounce: true)
const AppleIcon(size: 28)
const BellIcon(size: 28, color: AnimalColors.bellGold)
```

## Components Catalog (36 Components)

| Category | Components | Highlights |
| :--- | :--- | :--- |
| **General** | `AnimalButton`, `AnimalTitle`, `AnimalDivider`, `AnimalBackground`, `AnimalCursor`, `AnimalIcon` | 3D sinking buttons, swallowtail ribbon banners, leaf dividers, polka-dot backgrounds, pointer cursor |
| **Form Controls** | `AnimalInput`, `AnimalSwitch`, `AnimalCheckbox` (+Group), `AnimalRadio` (+Group), `AnimalSelect`, `AnimalDatePicker`, `AnimalTimePicker`, `AnimalForm`, `AnimalFormItem` | 50px pill inputs, warm focus glow switches, concentric radios, island calendar & time wheels |
| **Data Display** | `AnimalCard`, `AnimalTag`, `AnimalCollapse`, `AnimalCarousel`, `AnimalTable`, `AnimalPagination`, `AnimalCountdown`, `AnimalTime`, `AnimalCodeBlock`, `AnimalImage` | 13-color fruit cards, sticky-header virtualized tables, odometer countdown tiles, typewriter cards |
| **Feedback** | `AnimalModal`, `AnimalDrawer`, `AnimalTooltip`, `AnimalNotification`, `AnimalLoading`, `AnimalSkeleton`, `AnimalProgress` | Water-droplet modals, slide drawers, speech balloon tooltips, twirling leaf loaders, striped progress |
| **Navigation** | `AnimalTabs`, `AnimalBackTop`, `AnimalFooter`, `AnimalTypewriter` | Pill slider tabs, blast-off rocket back-to-top, coastline ocean wave footer, dialogue stream typewriter |

## Documentation

Routed by audience and scenario (English primary; Chinese mirrors under [`docs/zh-CN/`](./docs/zh-CN/)):

| Document | Path | Purpose |
| :--- | :--- | :--- |
| 🎨 **Design System & Rules** | [`docs/design-system/`](./docs/design-system/README.md) | Canonical design definition — tokens, 7 design laws & 14 visual hard rules, per-component specs. |
| 🤖 **AI Agent Skill** | [`skills/animal-island-ui-style-flutter/`](./skills/animal-island-ui-style-flutter/SKILL.md) | Official skill for Cursor / Claude Code / Windsurf coding agents with component API references. |
| 🚀 **One-Click Prompt** | [`docs/one-click-prompt.md`](./docs/one-click-prompt.md) | Single bootstrap prompt for non-developers to generate complete island-style pages with AI. |
| 💡 **Design Prompts** | [`docs/design-prompts.md`](./docs/design-prompts.md) | Prompts for design and image tools (v0, Figma AI, Midjourney, DALL-E). |
| 🛠️ **Development Guide** | [`docs/development/`](./docs/development/README.md) | Repository architecture, component development, coding standards, testing & build contracts. |
| 🏛️ **Architecture Decisions** | [`docs/adr/`](./docs/adr/README.md) | Architecture decision records (ADR-0001 through ADR-0005). |
| 🤝 **Contributing** | [`CONTRIBUTING.md`](./CONTRIBUTING.md) | Guidelines for filing issues and submitting pull requests. |

## Local Development

```bash
# 1. Clone the repository
git clone https://github.com/Ibuprofenighty/animal-island-ui-flutter.git
cd animal-island-ui-flutter

# 2. Run the interactive gallery
cd example
flutter run -d chrome # Web preview
# or
flutter run -d windows # Native Windows 120fps
```

## Notes & Disclaimer

- This project is intended strictly for personal learning, research, and non-commercial demonstration. **Any form of commercial use, resale, or monetization is strictly prohibited**.
- This is an independent open-source Flutter component library. It is not an official product of Nintendo or any game company and has no association, authorization, or partnership with them.
- All visual assets (icons, illustrations, widgets) in this repository are independently drawn and coded.

## License

Licensed under **Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**.
See the [LICENSE](LICENSE) file for the full text.
