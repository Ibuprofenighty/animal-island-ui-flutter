import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets(
    'C16 open select refreshes built-in and caller text on locale change',
    (tester) async {
      final controller = LocalizationTestController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Builder(
            builder: (context) {
              final localizations = AnimalLocalizations.of(context)!;
              final options = <AnimalOption<String>>[
                AnimalOption<String>(
                  value: 'today',
                  label: localizations.today,
                ),
              ];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimalSelect<String>(
                    key: const ValueKey('empty-select'),
                    value: null,
                    options: options,
                    onChanged: (_) {},
                  ),
                  AnimalSelect<String>(
                    key: const ValueKey('selected-select'),
                    value: 'today',
                    options: options,
                    onChanged: (_) {},
                    allowClear: true,
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Please select'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.semantics.byLabel('Clear selection'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('selected-select')));
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsNWidgets(2));

      controller.locale = const Locale('zh');
      await tester.pumpAndSettle();

      expect(find.text('请选择'), findsOneWidget);
      expect(find.text('今天'), findsNWidgets(2));
      expect(find.semantics.byLabel('清除所选项'), findsOneWidget);
      expect(find.semantics.byLabel('Clear selection'), findsNothing);
      expect(find.text('Please select'), findsNothing);
      expect(find.text('Today'), findsNothing);
    },
  );
}
