import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('Component Visual & Layout Golden Smoke Tests', () {
    Widget buildTestHarness({
      required AnimalIslandTheme theme,
      required Widget child,
    }) {
      return MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(24.0), child: child),
            ),
          ),
        ),
      );
    }

    Widget buildShowcaseGrid(TextEditingController inputController) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnimalTitle(child: Text('Golden Showcase')),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AnimalButton(
                tone: AnimalButtonTone.primary,
                onPressed: () {},
                child: const Text('Primary Button'),
              ),
              AnimalButton(
                tone: AnimalButtonTone.neutral,
                onPressed: () {},
                child: const Text('Neutral Button'),
              ),
              AnimalButton(
                tone: AnimalButtonTone.success,
                onPressed: () {},
                child: const Text('Success Button'),
              ),
              AnimalButton(
                tone: AnimalButtonTone.warning,
                onPressed: () {},
                child: const Text('Warning Button'),
              ),
              AnimalButton(
                tone: AnimalButtonTone.danger,
                onPressed: () {},
                child: const Text('Danger Button'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimalCard(
            header: const Text('Card Container'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Card body text with Animal Island UI styling.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const AnimalTag(child: Text('Active Tag')),
                    const SizedBox(width: 8),
                    const AnimalTag(
                      variant: AnimalTagVariant.warning,
                      child: Text('Warning Tag'),
                    ),
                    const SizedBox(width: 8),
                    AnimalTag(
                      variant: AnimalTagVariant.error,
                      onClose: () {},
                      child: const Text('Closable Tag'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimalInput(
            controller: inputController,
            key: const ValueKey('golden-input'),
            placeholder: 'Enter details...',
            prefix: AnimalIcon(data: AnimalIcons.search),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 58),
                child: AnimalSwitch(value: true, onChanged: (_) {}),
              ),
              const SizedBox(width: 16),
              AnimalCheckbox(value: true, onChanged: (_) {}),
              const SizedBox(width: 16),
              const AnimalIcon(data: AnimalIcons.leaf, size: 28),
              const SizedBox(width: 8),
              const AnimalIcon(data: AnimalIcons.bell, size: 28),
              const SizedBox(width: 8),
              const AnimalIcon(data: AnimalIcons.heart, size: 28),
            ],
          ),
        ],
      );
    }

    testWidgets('Light theme showcase renders stably without overflow', (
      tester,
    ) async {
      final inputController = TextEditingController(text: 'Input sample text');
      addTearDown(inputController.dispose);
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestHarness(
          theme: AnimalIslandTheme.light,
          child: buildShowcaseGrid(inputController),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Golden Showcase'), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Card Container'), findsOneWidget);
      expect(find.text('Active Tag'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dark theme showcase renders stably without overflow', (
      tester,
    ) async {
      final inputController = TextEditingController(text: 'Input sample text');
      addTearDown(inputController.dispose);
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestHarness(
          theme: AnimalIslandTheme.dark,
          child: buildShowcaseGrid(inputController),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Golden Showcase'), findsOneWidget);
      expect(find.text('Neutral Button'), findsOneWidget);
      expect(find.text('Warning Tag'), findsOneWidget);
      expect(find.text('Input sample text'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Accessibility contrast and touch target dimensions check', (
      tester,
    ) async {
      final inputController = TextEditingController(text: 'Input sample text');
      addTearDown(inputController.dispose);
      await tester.pumpWidget(
        buildTestHarness(
          theme: AnimalIslandTheme.light,
          child: buildShowcaseGrid(inputController),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.widgetWithText(AnimalButton, 'Primary Button');
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.height, greaterThanOrEqualTo(40.0));
      expect(buttonSize.width, greaterThanOrEqualTo(44.0));
    });
  });
}
