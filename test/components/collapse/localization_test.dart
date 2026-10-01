import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets(
    'C09 collapse keeps caller title and expanded content localized',
    (tester) async {
      final controller = LocalizationTestController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Builder(
            builder: (context) {
              final localizations = AnimalLocalizations.of(context)!;
              return AnimalCollapse.single(
                question: Text(localizations.today),
                answer: Text(localizations.clear),
                id: 'locale-item',
                defaultExpanded: true,
              );
            },
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Collapse'), findsNothing);

      controller.locale = const Locale('zh');
      await tester.pumpAndSettle();

      expect(find.text('今天'), findsOneWidget);
      expect(find.text('清空'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
      expect(find.text('Clear'), findsNothing);
    },
  );
}
