import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalForm RED Tests (F06 / FOR01)', () {
    testWidgets(
      'slow outdated async validation must not overwrite newer fast validation (latest-wins)',
      (tester) async {
        final controller = AnimalFormController();
        final usernameKey = AnimalFieldKey<String>(debugLabel: 'username');
        final usernameBuffer = TextEditingController();
        addTearDown(usernameBuffer.dispose);
        addTearDown(controller.dispose);

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
                    AnimalRule.custom((value) async {
                      if (value == 'slow_invalid') {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 200),
                        );
                        return 'Error: Slow Invalid';
                      }
                      if (value == 'fast_valid') {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 50),
                        );
                        return null;
                      }
                      return null;
                    }),
                  ],
                  builder: (context, binding) => AnimalInput(
                    controller: usernameBuffer,
                    focusNode: binding.focusNode,
                  ),
                ),
              ),
            ),
          ),
        );

        // Step 1: Input "slow_invalid" -> triggers slow async validation (200ms)
        controller.setValue(usernameKey, 'slow_invalid');
        await tester.pump(const Duration(milliseconds: 10));

        // Step 2: Quickly change to "fast_valid" -> triggers fast async validation (50ms)
        controller.setValue(usernameKey, 'fast_valid');
        await tester.pump(const Duration(milliseconds: 10));

        // Step 3: Advance 70ms (fast_valid finishes and sets error to null)
        await tester.pump(const Duration(milliseconds: 70));
        expect(
          controller.getFieldError(usernameKey),
          isNull,
          reason: 'fast_valid should be valid',
        );

        // Step 4: Advance another 160ms (slow_invalid finishes and late-delivers stale error)
        await tester.pump(const Duration(milliseconds: 160));

        // Contract: Stale validation from previous value must NOT overwrite current valid state!
        expect(
          controller.getFieldError(usernameKey),
          isNull,
          reason: 'Stale slow validation result must be discarded and never overwrite current valid state',
        );
      },
    );
  });
}
