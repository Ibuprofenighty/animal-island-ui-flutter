# 🍃 Animal Island UI for Flutter (animal_island_ui)

<br/>
<div align="center">
  <h3>🏝️ A cozy, kawaii island-style UI component library for Flutter 🏝️</h3>
  <p>A Flutter implementation of the <a href="https://github.com/guokaigdg/animal-island-ui">animal-island-ui</a> design language: warm colors, tactile buttons and hand-drawn island details.</p>
</div>
<br/>

<div align="center">
  <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FIbuprofenighty%2Fanimal-island-ui-flutter%2Fmain%2Fcatalog%2Fsdk.lock.json&query=%24.flutter.frameworkVersion&label=Flutter&logo=flutter&color=02569B&style=flat-square" alt="Flutter version">
  <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FIbuprofenighty%2Fanimal-island-ui-flutter%2Fmain%2Fcatalog%2Fsdk.lock.json&query=%24.flutter.dartSdkVersion&label=Dart&logo=dart&color=0175C2&style=flat-square" alt="Dart version">
  <a href="https://github.com/Ibuprofenighty/animal-island-ui-flutter/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/Ibuprofenighty/animal-island-ui-flutter/ci.yml?branch=main&label=CI&style=flat-square" alt="CI"></a>
  <img src="https://img.shields.io/badge/components-36-blue?style=flat-square" alt="Components: 36">
  <img src="https://img.shields.io/badge/icons-101-orange?style=flat-square" alt="Icons: 101">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-CC%20BY--NC%204.0%20(non--commercial)-lightgrey?style=flat-square" alt="License: CC BY-NC 4.0 (non-commercial)"></a>
</div>
<br/>

<p align="center">
  English | <a href="README.zh-CN.md">简体中文</a>
</p>

## 📖 Introduction

Animal Island UI is a Flutter component library inspired by cozy life-sim island
aesthetics. It ports the visual language of
[guokaigdg/animal-island-ui](https://github.com/guokaigdg/animal-island-ui) to
Flutter widgets: earth-brown text on cream surfaces, pill-shaped controls,
tactile button depth, ribbon titles, blob-shaped dialogs and a set of 101 island
icons.

Everything is exported from a single import,
`package:animal_island_ui/animal_island_ui.dart`, and styled through one theme
extension that supports light and dark presets.

## ✨ Key Highlights

- 🎮 **Tactile buttons**: filled primary and danger buttons sit on a stacked depth
  shadow and press down when activated; interactive controls give light haptic
  feedback.
- 🍃 **101 vector icons**: island symbols such as leaf, apple, bell and fossil,
  rendered by one `AnimalIcon` widget from `AnimalIcons` descriptors, with
  size, color and an optional bounce animation.
- 🫧 **Organic shapes**: blob-shaped modal surfaces, swallowtail ribbon titles,
  patterned backgrounds and wave or tree footers.
- 🎨 **One theme, six token families**: `AnimalIslandTheme` is a Flutter
  `ThemeExtension` with colors, typography, radii, spacing, shadows and motion,
  shipped as light and dark presets with 13 tile color pairs.
- 📋 **Forms and data**: `AnimalForm` with a controller and validation rules,
  date and time pickers, and a lazily built `AnimalTable` (`rowCount` +
  `rowBuilder`) with pagination.
- 🌏 **English and Chinese built in**: package text is localized through the
  exported `AnimalLocalizations`; Nunito and Noto Sans SC fonts are bundled, so
  no fonts are fetched at runtime.
- ♿ **Motion-aware**: animations follow the platform's reduce-motion setting.

## 🖼️ Preview

- **Live Gallery**: <https://ibuprofenighty.github.io/animal-island-ui-flutter/>
  shows all 36 components, the 101-icon browser and three example workflows
  (form, overlays, data table).
- **Run it locally**: the Gallery source lives in [`example/`](example/README.md).

## 📦 Installation

The package is consumed from this Git repository. Add it to your app's
`pubspec.yaml`:

```yaml
dependencies:
  animal_island_ui:
    git:
      url: https://github.com/Ibuprofenighty/animal-island-ui-flutter.git
      ref: main
```

Then run `flutter pub get`. The supported Flutter and Dart versions are the ones
shown in the badges above (recorded in [`catalog/sdk.lock.json`](catalog/sdk.lock.json));
the minimum constraints are declared in [`pubspec.yaml`](pubspec.yaml).

## 🚀 Quick Start

### 1. Install the theme and localizations

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
      home: const IslandHomePage(),
    );
  }
}
```

Chinese locales (any region) resolve to Chinese; all other or missing locales
resolve to English. Inside the tree, read the active theme with
`AnimalIslandTheme.of(context)`.

### 2. Use components

```dart
class IslandHomePage extends StatelessWidget {
  const IslandHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimalCard(
          header: const AnimalTitle(child: Text('Island Plaza')),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimalIcon(data: AnimalIcons.leaf, size: 28, bounce: true),
              const SizedBox(height: 12),
              const AnimalInput(placeholder: 'Search the island...', clearable: true),
              const SizedBox(height: 12),
              AnimalButton(
                icon: const AnimalIcon(data: AnimalIcons.apple, size: 18),
                onPressed: () => AnimalModal.show<void>(
                  context: context,
                  title: const Text('Island Broadcast'),
                  content: const Text('Fireworks at the plaza tonight!'),
                ),
                child: const Text('Explore'),
              ),
              AnimalButton(
                variant: AnimalButtonVariant.outlined,
                onPressed: () =>
                    AnimalNotification.success(context, message: 'Saved!'),
                child: const Text('Notify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

A complete runnable sample is in
[`example/lib/quick_start.dart`](example/lib/quick_start.dart).

## 🧩 Components (36)

| Category | Components |
| :--- | :--- |
| **General** | `AnimalButton`, `AnimalIcon`, `AnimalTypewriter`, `AnimalCursor` |
| **Layout & Navigation** | `AnimalCard`, `AnimalTitle`, `AnimalDivider`, `AnimalBackground`, `AnimalCollapse`, `AnimalTabs`, `AnimalCarousel` |
| **Form Controls** | `AnimalInput`, `AnimalSwitch`, `AnimalCheckbox`, `AnimalRadio`, `AnimalSelect`, `AnimalDatePicker`, `AnimalTimePicker` |
| **Forms** | `AnimalForm`, `AnimalFormItem` |
| **Overlays** | `AnimalModal`, `AnimalDrawer`, `AnimalTooltip` |
| **Feedback** | `AnimalProgress`, `AnimalLoading`, `AnimalSkeleton`, `AnimalBackTop`, `AnimalCountdown`, `AnimalTime`, `AnimalNotification` |
| **Data Display** | `AnimalTable`, `AnimalPagination`, `AnimalCodeBlock`, `AnimalTag`, `AnimalImage` |
| **Decorative** | `AnimalFooter` |

Checkbox and radio also come with `AnimalCheckboxGroup` and `AnimalRadioGroup`.
Each component has a reference page under [`docs/en/components/`](docs/en/components/).

## 🍎 Icons (101)

All icons are constants on `AnimalIcons` and are drawn with the same widget:

```dart
const icon = AnimalIcon(data: AnimalIcons.bell, size: 28);
```

Browse the full set in the [Gallery](https://ibuprofenighty.github.io/animal-island-ui-flutter/)
or in the [icon index](docs/en/components/icons.md).

## 📚 Documentation

| Document | Purpose |
| :--- | :--- |
| [Documentation home](docs/en/README.md) · [中文](docs/zh/README.md) | Index of all guides and component references |
| [Theme and tokens](docs/en/tokens.md) | Theme families, customization, fonts and accessibility |
| [Gallery workflows](docs/en/workflows.md) | The form, overlay and data examples |
| [AI agent skill](skills/animal-island-ui-style-flutter/SKILL.md) | Skill for AI coding agents building with this package |
| [Architecture decisions](docs/adr/README.md) | Key design decisions |
| [Contributing](CONTRIBUTING.md) | How to set up, check and submit changes |
| [Changelog](CHANGELOG.md) · [Security](SECURITY.md) | Release history and vulnerability reporting |

## 🛠️ Local Development

```bash
git clone https://github.com/Ibuprofenighty/animal-island-ui-flutter.git
cd animal-island-ui-flutter
flutter pub get
flutter test

# Run the Gallery
cd example
flutter pub get
flutter run -d chrome
```

## ⚠️ Notes & Disclaimer

- This is an independent open-source project. It is not affiliated with,
  authorized by or endorsed by Nintendo or any game company. Animal Crossing is a
  trademark of Nintendo Co., Ltd.
- The visual design follows the upstream
  [animal-island-ui](https://github.com/guokaigdg/animal-island-ui) project; see
  [NOTICE](NOTICE) and the [provenance page](docs/en/provenance.md) for attribution.

## 📄 License

Licensed under **Creative Commons Attribution-NonCommercial 4.0 International
(CC BY-NC 4.0)**. You may use, share and adapt this project with attribution, but
**not for commercial purposes**. See [LICENSE](LICENSE) for the full text and
[NOTICE](NOTICE) for attribution. The bundled Nunito and Noto Sans SC fonts are
licensed under the SIL Open Font License 1.1 (see `assets/licenses/`).
