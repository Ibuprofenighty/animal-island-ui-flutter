import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets(
    'C34 removable tag semantics follow locale and preserve content',
    (tester) async {
      final controller = LocalizationTestController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: const AnimalTag(onClose: _ignoreClose, child: Text('Urgent')),
        ),
      );
      expect(find.bySemanticsLabel('Remove tag'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);

      controller.locale = const Locale('zh');
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('移除标签'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
    },
  );
}

void _ignoreClose() {}
