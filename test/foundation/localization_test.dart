import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../support/localization_app.dart';

void main() {
  testWidgets(
    'locale resolution defaults to English and maps Chinese regions',
    (tester) async {
      expect(resolveAnimalLocale(null), const Locale('en'));
      expect(resolveAnimalLocale(const Locale('zh', 'TW')), const Locale('zh'));
      expect(resolveAnimalLocale(const Locale('zh', 'CN')), const Locale('zh'));
      expect(resolveAnimalLocale(const Locale('fr', 'CA')), const Locale('en'));

      final controller = LocalizationTestController();
      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Builder(
            builder: (context) =>
                Text(AnimalLocalizations.of(context)!.modalConfirm),
          ),
        ),
      );
      expect(find.text('Confirm'), findsOneWidget);

      controller.locale = const Locale('fr', 'CA');
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsOneWidget);

      controller.locale = const Locale('zh', 'TW');
      await tester.pumpAndSettle();
      expect(find.text('确认'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );

  testWidgets(
    'mounted localization consumers update after an in-place locale change',
    (tester) async {
      final controller = LocalizationTestController();
      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Builder(
            builder: (context) =>
                Text(AnimalLocalizations.of(context)!.modalConfirm),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      controller.locale = const Locale('zh', 'TW');
      await tester.pumpAndSettle();
      expect(find.text('确认'), findsOneWidget);

      controller.locale = const Locale('fr', 'CA');
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsOneWidget);
    },
  );
}
