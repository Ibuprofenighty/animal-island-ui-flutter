import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/notification/notification_card.dart';

void main() {
  group('Stage S17: Independent Adversarial Challenge Tests (T17.03)', () {
    testWidgets(
      'CHALLENGE 1: High-concurrency epoch race with out-of-order async validations',
      (tester) async {
        final controller = AnimalFormController();
        final usernameBuffer = TextEditingController();
        final usernameKey = AnimalFieldKey<String>(debugLabel: 'username');
        final completers = <String, Completer<String?>>{};
        addTearDown(() {
          controller.dispose();
          usernameBuffer.dispose();
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: AnimalFormItem<String>(
                  fieldKey: usernameKey,
                  textController: usernameBuffer,
                  rules: [
                    AnimalRule.custom((value) {
                      final key = value?.toString() ?? '';
                      final c = Completer<String?>();
                      completers[key] = c;
                      return c.future;
                    }),
                  ],
                  builder: (_, _) => AnimalInput(controller: usernameBuffer),
                ),
              ),
            ),
          ),
        );

        // Trigger 20 rapid sequential updates
        for (var i = 1; i <= 20; i++) {
          controller.setValue(usernameKey, 'val_$i');
          await tester.pump(const Duration(milliseconds: 5));
        }

        // Now resolve validations in reverse / chaotic order (20 down to 1)
        for (var i = 20; i >= 1; i--) {
          final key = 'val_$i';
          if (completers.containsKey(key) && !completers[key]!.isCompleted) {
            completers[key]!.complete(
              i == 20 ? null : 'Stale Error from val_$i',
            );
          }
        }

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Monotonic epoch invariant: only the latest validation (val_20, which resolved to null) is accepted!
        expect(controller.getFieldError(usernameKey), isNull);
      },
    );

    testWidgets(
      'CHALLENGE 2: Typewriter rapid update and immediate disposal mid-stream',
      (tester) async {
        final textNotifier = ValueNotifier<String>(
          'First line of text that is fairly long',
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: ValueListenableBuilder<String>(
                valueListenable: textNotifier,
                builder: (context, text, _) {
                  return AnimalTypewriter(
                    text: text,
                    speed: const Duration(milliseconds: 10),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 25));

        // Rapidly replace text mid-type
        textNotifier.value = 'Second line replacing first';
        await tester.pump(const Duration(milliseconds: 20));

        textNotifier.value = 'Third line replacing second';
        await tester.pump(const Duration(milliseconds: 15));

        // Immediately unmount the entire widget tree while timer is active
        await tester.pumpWidget(const SizedBox.shrink());

        // Advance clock significantly to ensure no dangling timers fire
        await tester.pump(const Duration(seconds: 2));

        // Zero unhandled timer errors; test concludes cleanly
        expect(find.byType(AnimalTypewriter), findsNothing);
      },
    );

    testWidgets(
      'CHALLENGE 3: Overlay host high-frequency notification queue churn and teardown',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: AnimalOverlayHost(
              child: Scaffold(body: Center(child: Text('Overlay Host'))),
            ),
          ),
        );

        final BuildContext context = tester.element(find.text('Overlay Host'));

        // Rapidly fire 30 notifications with mixed keys
        for (var i = 1; i <= 30; i++) {
          AnimalNotification.open(
            context,
            key: 'notif_${i % 5}', // test key collision / reuse
            message: Text('Notification $i'),
            description: Text('Message content for item $i'),
            duration: const Duration(milliseconds: 100),
          );
        }

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Notification cards render cleanly without overflow
        expect(find.byType(AnimalNotificationCard), findsWidgets);

        // Tear down the entire overlay host immediately
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 200));

        // Zero unhandled timer or overlay entry errors
        expect(find.byType(AnimalNotificationCard), findsNothing);
        AnimalNotification.reset();
      },
    );

    testWidgets(
      'CHALLENGE 4: 300% accessibility text scale and zero-size boundary constraints',
      (tester) async {
        // 300% Accessibility text scaling
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const AnimalTitle(child: Text('Huge Scaled Title')),
                      AnimalCard(
                        header: const Text('Header Scaled'),
                        child: Column(
                          children: [
                            AnimalButton(
                              tone: AnimalButtonTone.primary,
                              onPressed: () {},
                              child: const Text('Scaled Button'),
                            ),
                            const SizedBox(height: 8),
                            const AnimalTag(child: Text('Scaled Tag')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Zero-dimension tight constraint stress
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(const Size(0, 0)),
                  child: const OverflowBox(
                    minWidth: 0,
                    minHeight: 0,
                    maxWidth: 0,
                    maxHeight: 0,
                    child: AnimalIcon(data: AnimalIcons.leaf, size: 24),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'CHALLENGE 5: 100,000-row virtual table virtualization bounds',
      (tester) async {
        var buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                height: 400,
                child: AnimalTable(
                  columns: const [
                    AnimalTableColumn(title: 'ID', width: 80),
                    AnimalTableColumn(title: 'Name', flex: 1),
                  ],
                  rowCount: 100000,
                  rowBuilder: (context, index) {
                    buildCount++;
                    return [Text('$index'), Text('Item #$index of 100,000')];
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // First frame must NOT build all 100,000 items (strictly <= 24 rows in viewport)
        expect(buildCount, lessThanOrEqualTo(24));
        expect(buildCount, greaterThan(0));
      },
    );

    test('CHALLENGE 6: Zero legacy forbidden tokens across entire lib/ and test/ tree', () {
      final root = Directory.current.path;
      final forbiddenTokens = [
        'AnimalColors.mintTeal',
        'textPrimary',
        'AnimalButtonType',
        'AnimalSelectOption',
        'danger: true',
      ];

      final violations = <String>[];
      final targetDirs = [Directory('$root/lib'), Directory('$root/test')];

      for (final dir in targetDirs) {
        if (!dir.existsSync()) continue;
        for (final file in dir.listSync(recursive: true).whereType<File>()) {
          if (!file.path.endsWith('.dart')) continue;
          // Skip docs_gate_test and this test which contains token name strings
          if (file.path.contains('docs_gate_test.dart')) continue;
          if (file.path.contains('adversarial_challenge_test.dart')) continue;

          final content = file.readAsStringSync();
          for (final token in forbiddenTokens) {
            if (content.contains(token)) {
              violations.add(
                '${file.path} contains forbidden legacy token: $token',
              );
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Legacy tokens found in codebase:\n${violations.join('\n')}',
      );
    });
  });
}
