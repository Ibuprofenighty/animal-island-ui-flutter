import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../support/localization_app.dart';

class _NotificationGuardController extends AnimalFormController {
  int notificationsAfterDispose = 0;

  @override
  void notifyListeners() {
    if (isDisposed) {
      notificationsAfterDispose++;
      return;
    }
    super.notifyListeners();
  }
}

void main() {
  group('AnimalForm async validation', () {
    test(
      'M04: a value change without a new request discards the pending result',
      () async {
        final controller = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'slow-value');
        final started = Completer<void>();
        final result = Completer<String?>();
        controller.registerField<String>(
          key: key,
          initialValue: 'A',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              if (!started.isCompleted) started.complete();
              return result.future;
            }),
          ],
        );

        final pendingValidation = controller.validateField(key);
        await started.future;
        controller.setValue(key, 'B', validate: false);
        result.complete('old value failed');

        expect(await pendingValidation, isFalse);
        expect(controller.valueFor(key), 'B');
        expect(
          controller.getFieldError(key),
          isNull,
          reason: 'M04 value revision must discard a pending result even when no newer request starts',
        );
        expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
        controller.dispose();
      },
    );

    test(
      'M05: reset with an unchanged value invalidates through the form epoch',
      () async {
        final controller = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'reset-value');
        final started = Completer<void>();
        final result = Completer<String?>();
        controller.registerField<String>(
          key: key,
          initialValue: 'baseline',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              if (!started.isCompleted) started.complete();
              return result.future;
            }),
          ],
        );

        final pendingValidation = controller.validateField(key);
        await started.future;
        final revisionBeforeReset = controller.epoch;
        controller.reset();
        expect(controller.epoch, revisionBeforeReset + 1);
        result.complete('must be discarded');

        expect(await pendingValidation, isFalse);
        expect(controller.valueFor(key), 'baseline');
        expect(
          controller.getFieldError(key),
          isNull,
          reason: 'M05 reset epoch must discard the pending result',
        );
        expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
        controller.dispose();
      },
    );

    test('unrelated field changes do not stale a pending validation', () async {
      final controller = AnimalFormController();
      final key = AnimalFieldKey<String>(debugLabel: 'unrelated-pending');
      final extraKey = AnimalFieldKey<int>(debugLabel: 'unrelated-extra');
      final started = Completer<void>();
      final result = Completer<String?>();
      controller.registerField<String>(
        key: key,
        initialValue: 'value',
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            if (!started.isCompleted) started.complete();
            return result.future;
          }),
        ],
      );

      final pendingValidation = controller.validateField(key);
      await started.future;
      final extra = controller.registerField<int>(
        key: extraKey,
        initialValue: 1,
      );
      controller.defaultSubmitHandler = (_) => true;
      controller.unregisterField(extra);
      result.complete(null);

      expect(await pendingValidation, isTrue);
      expect(controller.getFieldStatus(key), AnimalValidationStatus.valid);
      controller.dispose();
    });

    test(
      'deactivate and reactivate never revive an earlier validation',
      () async {
        final controller = AnimalFormController();
        final focusNode = FocusNode();
        final key = AnimalFieldKey<String>(debugLabel: 'reactivated-field');
        final started = Completer<void>();
        final oldResult = Completer<String?>();
        var validatorCalls = 0;
        final registration = controller.registerField<String>(
          key: key,
          initialValue: 'value',
          focusNode: focusNode,
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              validatorCalls++;
              if (validatorCalls == 1) {
                started.complete();
                return oldResult.future;
              }
              return null;
            }),
          ],
        );

        final oldValidation = controller.validateField(key);
        await started.future;
        registration.deactivate();
        expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
        expect(registration.activate(), isTrue);
        expect(await controller.validateField(key), isTrue);
        expect(controller.getFieldStatus(key), AnimalValidationStatus.valid);

        oldResult.complete('stale validation');
        expect(await oldValidation, isFalse);
        expect(controller.getFieldError(key), isNull);
        expect(controller.getFieldStatus(key), AnimalValidationStatus.valid);
        controller.unregisterField(registration);
        controller.dispose();
        focusNode.dispose();
      },
    );

    test(
      'a rule replacement discards a pending result from the old rules',
      () async {
        final controller = AnimalFormController();
        final focusNode = FocusNode();
        final key = AnimalFieldKey<String>(debugLabel: 'rule-value');
        final started = Completer<void>();
        final result = Completer<String?>();
        final registration = controller.registerField<String>(
          key: key,
          initialValue: 'value',
          focusNode: focusNode,
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              if (!started.isCompleted) started.complete();
              return result.future;
            }),
          ],
        );

        final pendingValidation = controller.validateField(key);
        await started.future;
        controller.updateFieldRegistration<String>(
          registration,
          rules: const <AnimalRule<String>>[],
          focusNode: focusNode,
        );
        result.complete('old rule failed');

        expect(await pendingValidation, isFalse);
        expect(controller.getFieldError(key), isNull);
        expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
        controller.unregisterField(registration);
        controller.dispose();
        focusNode.dispose();
      },
    );

    test(
      'same-key re-registration drops the old generation result and notify',
      () async {
        final controller = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'reused-key');
        final started = Completer<void>();
        final result = Completer<String?>();
        final oldRegistration = controller.registerField<String>(
          key: key,
          initialValue: 'old',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              if (!started.isCompleted) started.complete();
              return result.future;
            }),
          ],
        );
        var oldNotifications = 0;
        oldRegistration.addListener(() => oldNotifications++);

        final pendingValidation = controller.validateField(key);
        await started.future;
        final notificationsBeforeUnregister = oldNotifications;
        controller.unregisterField(oldRegistration);
        final replacement = controller.registerField<String>(
          key: key,
          initialValue: 'new',
        );
        expect(replacement.generation, greaterThan(oldRegistration.generation));
        result.complete('old generation failed');

        expect(await pendingValidation, isFalse);
        expect(controller.valueFor(key), 'new');
        expect(controller.getFieldError(key), isNull);
        expect(oldNotifications, notificationsBeforeUnregister);
        controller.unregisterField(replacement);
        controller.dispose();
      },
    );

    test('a reentrant reset stops before invoking the validator', () async {
      final controller = AnimalFormController();
      final key = AnimalFieldKey<String>(debugLabel: 'reentrant-reset');
      var validatorCalls = 0;
      var reset = false;
      final registration = controller.registerField<String>(
        key: key,
        initialValue: 'baseline',
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            validatorCalls++;
            return null;
          }),
        ],
      );
      registration.addListener(() {
        if (!reset &&
            controller.getFieldStatus(key) ==
                AnimalValidationStatus.validating) {
          reset = true;
          controller.reset();
        }
      });

      expect(await controller.validateField(key), isFalse);
      expect(validatorCalls, 0);
      expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
      controller.dispose();
    });

    test('a reentrant rule replacement stops the old validator', () async {
      final controller = AnimalFormController();
      final focusNode = FocusNode();
      final key = AnimalFieldKey<String>(debugLabel: 'reentrant-rules');
      var validatorCalls = 0;
      var replaced = false;
      late AnimalFieldRegistration<String> registration;
      registration = controller.registerField<String>(
        key: key,
        initialValue: 'value',
        focusNode: focusNode,
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            validatorCalls++;
            return null;
          }),
        ],
      );
      registration.addListener(() {
        if (!replaced &&
            controller.getFieldStatus(key) ==
                AnimalValidationStatus.validating) {
          replaced = true;
          controller.updateFieldRegistration<String>(
            registration,
            rules: const <AnimalRule<String>>[],
            focusNode: focusNode,
          );
        }
      });

      expect(await controller.validateField(key), isFalse);
      expect(validatorCalls, 0);
      expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
      controller.unregisterField(registration);
      controller.dispose();
      focusNode.dispose();
    });

    test('disposal from a field listener stops validator invocation', () async {
      final controller = _NotificationGuardController();
      final key = AnimalFieldKey<String>(debugLabel: 'reentrant-dispose');
      var validatorCalls = 0;
      final registration = controller.registerField<String>(
        key: key,
        initialValue: 'value',
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            validatorCalls++;
            return null;
          }),
        ],
      );
      registration.addListener(controller.dispose);

      expect(await controller.validateField(key), isFalse);
      expect(validatorCalls, 0);
      expect(controller.isDisposed, isTrue);
      expect(controller.notificationsAfterDispose, 0);
    });

    testWidgets('validator exceptions become a localized field issue', (
      tester,
    ) async {
      final controller = AnimalFormController();
      final localeController = LocalizationTestController(
        initialLocale: const Locale('en'),
      );
      final key = AnimalFieldKey<String>(debugLabel: 'exception-value');

      await tester.pumpWidget(
        AnimalLocalizationTestApp(
          controller: localeController,
          child: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: AnimalFormItem<String>(
                fieldKey: key,
                rules: <AnimalRule<String>>[
                  AnimalRule<String>.custom((_) async {
                    throw StateError('private validator detail');
                  }),
                ],
                builder: (_, _) => const SizedBox(height: 1),
              ),
            ),
          ),
        ),
      );

      expect(await controller.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Validation could not be completed'), findsOneWidget);
      expect(
        controller.getFieldError(key)?.kind,
        AnimalValidationIssueKind.validationFailure,
      );

      localeController.locale = const Locale('zh', 'TW');
      await tester.pumpAndSettle();
      expect(find.text('验证暂时无法完成'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      localeController.dispose();
    });

    testWidgets('changing one of 100 fields rebuilds only its binding', (
      tester,
    ) async {
      final controller = AnimalFormController();
      final keys = List<AnimalFieldKey<String>>.generate(
        100,
        (index) => AnimalFieldKey<String>(debugLabel: 'field-$index'),
      );
      final buildCounts = List<int>.filled(keys.length, 0);

      await tester.pumpWidget(
        MaterialApp(
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (var index = 0; index < keys.length; index++)
                      AnimalFormItem<String>(
                        fieldKey: keys[index],
                        initialValue: 'value-$index',
                        builder: (_, binding) {
                          buildCounts[index]++;
                          return Text(binding.value ?? '');
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final countsBeforeChange = List<int>.of(buildCounts);
      expect(countsBeforeChange.every((count) => count > 0), isTrue);
      controller.setValue(keys.first, 'changed', validate: false);
      await tester.pump();

      expect(buildCounts.first, greaterThan(countsBeforeChange.first));
      for (var index = 1; index < buildCounts.length; index++) {
        expect(buildCounts[index], countsBeforeChange[index]);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
  });
}
