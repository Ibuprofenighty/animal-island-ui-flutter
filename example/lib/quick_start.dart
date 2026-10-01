import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  runApp(const AnimalIslandQuickStartApp());
}

/// Standalone minimal consumer application demonstrating canonical Animal Island UI setup.
class AnimalIslandQuickStartApp extends StatelessWidget {
  const AnimalIslandQuickStartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Island UI Quick Start',
      debugShowCheckedModeBanner: false,
      theme: AnimalIslandTheme.light.toThemeData(),
      darkTheme: AnimalIslandTheme.dark.toThemeData(),
      home: const QuickStartHomePage(),
    );
  }
}

class QuickStartHomePage extends StatefulWidget {
  const QuickStartHomePage({super.key});

  @override
  State<QuickStartHomePage> createState() => _QuickStartHomePageState();
}

class _QuickStartHomePageState extends State<QuickStartHomePage> {
  int _appleCount = 3;
  bool _switchActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AnimalCard(
              header: const Text('Animal Island UI'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AnimalTitle(child: Text('Island Plaza')),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome to your cozy island workspace. All components feature 50px pill curves, tactile 3D depth displacement, and WCAG AA contrast compliance.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const AnimalIcon(data: AnimalIcons.apple, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Collected Apples: $_appleCount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AnimalButton(
                        tone: AnimalButtonTone.primary,
                        onPressed: () => setState(() => _appleCount++),
                        child: const Text('Collect Apple'),
                      ),
                      AnimalButton(
                        tone: AnimalButtonTone.neutral,
                        onPressed: _appleCount > 0
                            ? () => setState(() => _appleCount--)
                            : null,
                        child: const Text('Eat Apple'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const AnimalDivider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Island Ambient Music'),
                      AnimalSwitch(
                        value: _switchActive,
                        onChanged: (val) => setState(() => _switchActive = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
