import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/src/components/notification/notification_card.dart';
import 'package:animal_island_ui/src/components/notification/notification_queue.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets(
    'AnimalNotificationCard updates its dismiss semantics while mounted',
    (tester) async {
      final controller = LocalizationTestController(
        initialLocale: const Locale('en'),
      );
      var timeoutCount = 0;
      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: controller,
          child: Scaffold(
            body: AnimalNotificationCard(
              config: AnimalNotificationConfig(
                message: const Text('Caller-owned notification'),
                duration: const Duration(minutes: 1),
              ),
              onDismiss: () {},
              onTimeout: () => timeoutCount++,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      final englishDismiss = find.semantics.byLabel('Dismiss notification');
      expect(englishDismiss, findsOneWidget);
      expect(
        englishDismiss.evaluate().single.getSemanticsData().hasAction(
          SemanticsAction.tap,
        ),
        isTrue,
      );

      controller.locale = const Locale('zh', 'TW');
      await tester.pump();
      final chineseDismiss = find.semantics.byLabel('关闭通知');
      expect(chineseDismiss, findsOneWidget);
      expect(
        chineseDismiss.evaluate().single.getSemanticsData().hasAction(
          SemanticsAction.tap,
        ),
        isTrue,
      );
      expect(find.text('Caller-owned notification'), findsOneWidget);

      tester.semantics.tap(chineseDismiss);
      await tester.pumpAndSettle();
      expect(timeoutCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    },
  );
}
