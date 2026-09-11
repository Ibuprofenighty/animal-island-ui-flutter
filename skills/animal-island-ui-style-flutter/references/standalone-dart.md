# Standalone Dart / Single-file Prototyping

For quick interactive prototyping or isolated widget testing:

```dart
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: AnimalColors.bg,
        body: Center(
          child: AnimalCard(
            color: AnimalTileColor.mintTeal,
            pattern: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimalTitle(child: Text('Cozy Island')),
                const SizedBox(height: 16),
                AnimalButton(
                  type: AnimalButtonType.primary,
                  onPressed: () {},
                  child: const Text('Explore'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
```
