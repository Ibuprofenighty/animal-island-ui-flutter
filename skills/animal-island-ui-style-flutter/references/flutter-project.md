# Flutter Project Usage

## 1. Setup

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  animal_island_ui:
    path: ../animal_island_ui # or git / hosted
```

## 2. App Entry

```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() => runApp(const IslandApp());

class IslandApp extends StatelessWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AnimalColors.background,
        fontFamily: 'Nunito',
        extensions: const [AnimalIslandTheme.light],
      ),
      home: const IslandHomePage(),
    );
  }
}
```

## 3. Key Recipes

```dart
// Primary 3D Button
AnimalButton(
  type: AnimalButtonType.primary,
  onPressed: () {},
  child: const Text('Save Game'),
)

// Organic Blob Modal
AnimalModal.show(
  context: context,
  title: 'Island Mail',
  content: const Text('You received a letter from Mom!'),
)
```
