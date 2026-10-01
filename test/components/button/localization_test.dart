import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets(
    'C01 button caller text and label update from English to Chinese',
    (tester) async {
      final controller = LocalizationTestController();
      addTearDown(controller.dispose);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Builder(
            builder: (context) {
              final localizations = AnimalLocalizations.of(context)!;
              return AnimalButton(
                semanticLabel: localizations.clear,
                onPressed: () {},
                child: Text(localizations.today),
              );
            },
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.semantics.byLabel('Clear'), findsOneWidget);

      controller.locale = const Locale('zh');
      await tester.pumpAndSettle();

      expect(find.text('今天'), findsOneWidget);
      expect(find.semantics.byLabel('清空'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
      expect(find.semantics.byLabel('Clear'), findsNothing);
      expect(find.text('Button'), findsNothing);
      semantics.dispose();
    },
  );
}
