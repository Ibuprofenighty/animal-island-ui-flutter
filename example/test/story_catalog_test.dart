import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:example/stories/stories_registry.dart';

void main() {
  const allSlugs = [
    'button',
    'icon',
    'typewriter',
    'cursor',
    'card',
    'title',
    'divider',
    'background',
    'collapse',
    'tabs',
    'carousel',
    'input',
    'switch',
    'checkbox',
    'radio',
    'select',
    'date_picker',
    'time_picker',
    'form',
    'form_item',
    'modal',
    'drawer',
    'tooltip',
    'progress',
    'loading',
    'skeleton',
    'back_top',
    'countdown',
    'time',
    'notification',
    'table',
    'pagination',
    'code_block',
    'tag',
    'image',
    'footer',
  ];

  group('StoriesRegistry', () {
    test('resolves exactly 36 canonical component stories', () {
      expect(allSlugs.length, 36);
      for (final slug in allSlugs) {
        final widget = resolveStoryWidget(slug);
        expect(
          widget,
          isNotNull,
          reason: 'Slug $slug must resolve to a valid story widget',
        );
      }
    });

    test('resolves null for unknown slug', () {
      expect(resolveStoryWidget('non_existent_component'), isNull);
    });

    testWidgets('pumps each story widget cleanly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final slug in allSlugs) {
        final storyWidget = resolveStoryWidget(slug)!;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) =>
                resolveAnimalLocale(locale),
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: SingleChildScrollView(child: storyWidget)),
          ),
        );
        await tester.pump();
        expect(find.byWidget(storyWidget), findsOneWidget);
      }
    });
  });
}
