import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../support/localization_app.dart';

void main() {
  testWidgets(
    'open modal and drawer update visible strings and barrier semantics after locale changes',
    (tester) async {
      final controller = LocalizationTestController(
        initialLocale: const Locale('en'),
      );
      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  TextButton(
                    key: const ValueKey('open-modal'),
                    onPressed: () {
                      AnimalModal.show<void>(
                        context: context,
                        title: const Text('Caller title'),
                        content: const Text('Caller content'),
                      );
                    },
                    child: const Text('Open modal'),
                  ),
                  TextButton(
                    key: const ValueKey('open-drawer'),
                    onPressed: () {
                      AnimalDrawer.show<void>(
                        context: context,
                        title: const Text('Caller drawer title'),
                        child: const Text('Caller drawer content'),
                      );
                    },
                    child: const Text('Open drawer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('open-modal')));
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Caller content'), findsOneWidget);
      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);

      controller.locale = const Locale('zh', 'TW');
      await tester.pumpAndSettle();
      expect(find.text('确认'), findsOneWidget);
      expect(find.text('Caller content'), findsOneWidget);
      expect(find.bySemanticsLabel('关闭'), findsOneWidget);

      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open-drawer')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('抽屉'), findsOneWidget);
      expect(find.bySemanticsLabel('关闭抽屉'), findsOneWidget);

      controller.locale = const Locale('en');
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Drawer'), findsOneWidget);
      expect(find.bySemanticsLabel('Close drawer'), findsOneWidget);
      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Close drawer'));
      await tester.pumpAndSettle();
      controller.dispose();
    },
  );

  testWidgets(
    'countdown plural copy and date formatting follow the active locale',
    (tester) async {
      final controller = LocalizationTestController(
        initialLocale: const Locale('en'),
      );
      final selectedDate = AnimalDate(2026, 9, 15);
      const dateKey = ValueKey('localized-date-value');
      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Builder(
            builder: (context) {
              final localizations = AnimalLocalizations.of(context)!;
              return Scaffold(
                body: Column(
                  children: [
                    const AnimalCountdown(
                      remaining: Duration(seconds: 2),
                      format: 'ss',
                    ),
                    Text(localizations.countdownRemaining(0)),
                    Text(localizations.countdownRemaining(1)),
                    Text(localizations.countdownRemaining(2)),
                    AnimalDatePicker.popover(
                      key: dateKey,
                      value: selectedDate,
                      showToday: false,
                      allowClear: false,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.bySemanticsLabel('2 seconds remaining'), findsOneWidget);
      expect(find.text('No time remaining'), findsOneWidget);
      expect(find.text('1 second remaining'), findsOneWidget);
      expect(find.text('2 seconds remaining'), findsOneWidget);
      final dateText = find.descendant(
        of: find.byKey(dateKey),
        matching: find.byType(Text),
      );
      final englishDate = tester.widget<Text>(dateText).data!;
      final englishMaterialLocalizations = MaterialLocalizations.of(
        tester.element(dateText),
      );
      expect(
        englishDate,
        englishMaterialLocalizations.formatMediumDate(
          selectedDate.toDateTime(),
        ),
      );

      controller.locale = const Locale('zh', 'CN');
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('剩余 2 秒'), findsOneWidget);
      expect(find.text('时间已结束'), findsOneWidget);
      expect(find.text('剩余 1 秒'), findsOneWidget);
      expect(find.text('剩余 2 秒'), findsOneWidget);
      final chineseDate = tester.widget<Text>(dateText).data!;
      final chineseMaterialLocalizations = MaterialLocalizations.of(
        tester.element(dateText),
      );
      expect(
        chineseDate,
        chineseMaterialLocalizations.formatMediumDate(
          selectedDate.toDateTime(),
        ),
      );
      expect(chineseDate, isNot(englishDate));

      controller.dispose();
    },
  );
}
