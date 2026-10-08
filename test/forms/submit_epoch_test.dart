import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/form/form_controller.dart'
    show AnimalFieldRegistration, AnimalFormFieldProtocol;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../support/locked_dart_process.dart';

class _NotificationGuardController extends AnimalFormController {
  int notificationsAfterDispose = 0;
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (disposed) {
      notificationsAfterDispose++;
      return;
    }
    super.notifyListeners();
  }
}

enum _LateHandlerCompletion { accepted, rejected, failed }

const Duration _voidCallbackResolutionWatchdog = Duration(seconds: 90);

Future<void> _expectHandlerPhaseInvalidation({
  required void Function(
    AnimalFormController controller,
    AnimalFieldRegistration<String> registration,
    FutureOr<bool> Function(AnimalFormValues values) replacementHandler,
    FocusNode focusNode,
  )
  invalidate,
  bool replaceDefaultHandler = false,
  _LateHandlerCompletion lateCompletion = _LateHandlerCompletion.accepted,
}) async {
  final controller = AnimalFormController();
  final key = AnimalFieldKey<String>(debugLabel: 'handler-phase-value');
  final focusNode = FocusNode();
  final registration = controller.registerField<String>(
    key: key,
    initialValue: 'baseline',
    focusNode: focusNode,
  );
  final oldHandlerStarted = Completer<void>();
  final newHandlerStarted = Completer<void>();
  final oldHandlerResult = Completer<bool>();
  final newHandlerResult = Completer<bool>();
  var notifications = 0;
  controller.addListener(() => notifications++);

  FutureOr<bool> oldHandler(AnimalFormValues _) {
    if (!oldHandlerStarted.isCompleted) oldHandlerStarted.complete();
    return oldHandlerResult.future;
  }

  FutureOr<bool> newHandler(AnimalFormValues _) {
    if (!newHandlerStarted.isCompleted) newHandlerStarted.complete();
    return newHandlerResult.future;
  }

  if (replaceDefaultHandler) controller.defaultSubmitHandler = oldHandler;
  Future<AnimalSubmitResult>? oldSubmit;
  Future<AnimalSubmitResult>? newSubmit;
  try {
    oldSubmit = controller.submit(
      onSubmit: replaceDefaultHandler ? null : oldHandler,
    );
    await oldHandlerStarted.future.timeout(const Duration(seconds: 2));
    invalidate(controller, registration, newHandler, focusNode);

    expect(
      (await oldSubmit.timeout(const Duration(seconds: 2))).status,
      AnimalSubmitStatus.changedDuringValidation,
    );
    expect(controller.isSubmitting, isFalse);

    newSubmit = controller.submit(
      onSubmit: replaceDefaultHandler ? null : newHandler,
    );
    await newHandlerStarted.future.timeout(const Duration(seconds: 2));
    expect(controller.isSubmitting, isTrue);
    expect(
      (await controller.submit(onSubmit: newHandler)).status,
      AnimalSubmitStatus.busy,
    );

    final notificationsBeforeLateCompletion = notifications;
    switch (lateCompletion) {
      case _LateHandlerCompletion.accepted:
        oldHandlerResult.complete(true);
      case _LateHandlerCompletion.rejected:
        oldHandlerResult.complete(false);
      case _LateHandlerCompletion.failed:
        oldHandlerResult.completeError(StateError('stale handler failure'));
    }
    await Future<void>.delayed(Duration.zero);
    expect(notifications, notificationsBeforeLateCompletion);
    expect(controller.isSubmitting, isTrue);

    newHandlerResult.complete(true);
    expect((await newSubmit).status, AnimalSubmitStatus.success);
    expect(controller.isSubmitting, isFalse);
  } finally {
    if (!oldHandlerResult.isCompleted) oldHandlerResult.complete(true);
    if (!newHandlerResult.isCompleted) newHandlerResult.complete(true);
    if (oldSubmit != null) {
      await oldSubmit
          .timeout(const Duration(seconds: 2))
          .catchError((_) => AnimalSubmitResult.changedDuringValidation);
    }
    if (newSubmit != null) {
      await newSubmit
          .timeout(const Duration(seconds: 2))
          .catchError((_) => AnimalSubmitResult.changedDuringValidation);
    }
    controller.dispose();
    focusNode.dispose();
  }
}

void main() {
  group('AnimalForm submit operation', () {
    test('M06: overlapping submit is busy and invokes one handler', () async {
      final controller = AnimalFormController();
      final key = AnimalFieldKey<String>(debugLabel: 'busy-value');
      final started = Completer<void>();
      final validation = Completer<String?>();
      var handlerCalls = 0;
      controller.registerField<String>(
        key: key,
        initialValue: 'valid',
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            if (!started.isCompleted) started.complete();
            return validation.future;
          }),
        ],
      );

      final firstSubmit = controller.submit(
        onSubmit: (_) {
          handlerCalls++;
          return true;
        },
      );
      await started.future;
      final secondSubmit = controller.submit(
        onSubmit: (_) {
          handlerCalls++;
          return true;
        },
      );
      expect(controller.isSubmitting, isTrue);

      validation.complete(null);
      expect(
        (await secondSubmit).status,
        AnimalSubmitStatus.busy,
        reason: 'M06 concurrent submit must return busy',
      );
      expect((await firstSubmit).status, AnimalSubmitStatus.success);
      expect(handlerCalls, 1);
      expect(controller.isSubmitting, isFalse);
      controller.dispose();
    });

    test(
      'a field change cancels its validation snapshot before the handler',
      () async {
        final controller = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'changed-value');
        final started = Completer<void>();
        final validation = Completer<String?>();
        var handlerCalls = 0;
        controller.registerField<String>(
          key: key,
          initialValue: 'old',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              if (!started.isCompleted) started.complete();
              return validation.future;
            }),
          ],
        );

        final pendingSubmit = controller.submit(
          onSubmit: (_) {
            handlerCalls++;
            return true;
          },
        );
        await started.future;
        controller.setValue(key, 'new', validate: false);

        expect(
          (await pendingSubmit).status,
          AnimalSubmitStatus.changedDuringValidation,
        );
        expect(controller.isSubmitting, isFalse);
        expect(handlerCalls, 0);
        validation.complete('stale failure');
        await Future<void>.delayed(Duration.zero);
        expect(controller.getFieldError(key), isNull);
        expect(handlerCalls, 0);
        controller.dispose();
      },
    );

    test(
      'an old operation finally cannot clear a newer submit busy state',
      () async {
        final controller = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'operation-value');
        final startedFirst = Completer<void>();
        final startedSecond = Completer<void>();
        final validations = <Completer<String?>>[];
        var handlerCalls = 0;
        controller.registerField<String>(
          key: key,
          initialValue: 'baseline',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              final validation = Completer<String?>();
              validations.add(validation);
              if (validations.length == 1) {
                startedFirst.complete();
              } else if (validations.length == 2) {
                startedSecond.complete();
              }
              return validation.future;
            }),
          ],
        );

        final firstSubmit = controller.submit(
          onSubmit: (_) {
            handlerCalls++;
            return true;
          },
        );
        await startedFirst.future;
        controller.reset();
        expect(
          (await firstSubmit).status,
          AnimalSubmitStatus.changedDuringValidation,
        );

        final secondSubmit = controller.submit(
          onSubmit: (_) {
            handlerCalls++;
            return true;
          },
        );
        await startedSecond.future;
        expect(controller.isSubmitting, isTrue);

        validations.first.complete(null);
        await Future<void>.delayed(Duration.zero);
        expect(controller.isSubmitting, isTrue);
        expect(handlerCalls, 0);

        validations.last.complete(null);
        expect((await secondSubmit).status, AnimalSubmitStatus.success);
        expect(handlerCalls, 1);
        expect(controller.isSubmitting, isFalse);
        controller.dispose();
      },
    );

    test('registering a field invalidates the captured field set', () async {
      final controller = AnimalFormController();
      final key = AnimalFieldKey<String>(debugLabel: 'existing-field');
      final addedKey = AnimalFieldKey<int>(debugLabel: 'added-field');
      final started = Completer<void>();
      final validation = Completer<String?>();
      var handlerCalls = 0;
      controller.registerField<String>(
        key: key,
        initialValue: 'valid',
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            if (!started.isCompleted) started.complete();
            return validation.future;
          }),
        ],
      );

      final pendingSubmit = controller.submit(
        onSubmit: (_) {
          handlerCalls++;
          return true;
        },
      );
      await started.future;
      final added = controller.registerField<int>(
        key: addedKey,
        initialValue: 1,
      );

      expect(
        (await pendingSubmit).status,
        AnimalSubmitStatus.changedDuringValidation,
      );
      expect(handlerCalls, 0);
      validation.complete(null);
      await Future<void>.delayed(Duration.zero);
      expect(controller.valueFor(addedKey), 1);
      controller.unregisterField(added);
      controller.dispose();
    });

    test(
      'unregister and same-key re-registration cancel the captured submit',
      () async {
        final controller = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'submit-reused-key');
        final started = Completer<void>();
        final validation = Completer<String?>();
        var handlerCalls = 0;
        final original = controller.registerField<String>(
          key: key,
          initialValue: 'old',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              if (!started.isCompleted) started.complete();
              return validation.future;
            }),
          ],
        );
        var originalNotifications = 0;
        original.addListener(() => originalNotifications++);

        final pendingSubmit = controller.submit(
          onSubmit: (_) {
            handlerCalls++;
            return true;
          },
        );
        await started.future;
        final notificationsBeforeRemoval = originalNotifications;
        controller.unregisterField(original);
        final replacement = controller.registerField<String>(
          key: key,
          initialValue: 'new',
        );

        expect(
          (await pendingSubmit).status,
          AnimalSubmitStatus.changedDuringValidation,
        );
        validation.complete('stale result');
        await Future<void>.delayed(Duration.zero);
        expect(controller.valueFor(key), 'new');
        expect(controller.getFieldError(key), isNull);
        expect(controller.getFieldStatus(key), AnimalValidationStatus.idle);
        expect(originalNotifications, notificationsBeforeRemoval);
        expect(handlerCalls, 0);
        controller.unregisterField(replacement);
        controller.dispose();
      },
    );

    testWidgets('FormItem GlobalKey reparent cancels its captured submit', (
      tester,
    ) async {
      final controller = AnimalFormController();
      final fieldKey = AnimalFieldKey<String>(debugLabel: 'reparent-submit');
      final mountKey = GlobalKey();
      final started = Completer<void>();
      final validation = Completer<String?>();
      var handlerCalls = 0;
      var moveField = false;
      ValueChanged<String?>? originalOnChanged;
      late StateSetter rebuildParent;

      Widget field() => AnimalFormItem<String>(
        key: mountKey,
        fieldKey: fieldKey,
        initialValue: 'baseline',
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            if (!started.isCompleted) started.complete();
            return validation.future;
          }),
        ],
        builder: (_, binding) {
          originalOnChanged ??= binding.onChanged;
          return Text(binding.value ?? 'null');
        },
      );

      Widget tree() => MaterialApp(
        theme: AnimalIslandTheme.light.toThemeData(),
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuildParent = setState;
            return Scaffold(
              body: AnimalForm(
                controller: controller,
                child: Row(
                  children: moveField
                      ? <Widget>[const SizedBox.shrink(), field()]
                      : <Widget>[field(), const SizedBox.shrink()],
                ),
              ),
            );
          },
        ),
      );

      Future<AnimalSubmitResult>? pendingSubmit;
      try {
        await tester.pumpWidget(tree());
        pendingSubmit = controller.submit(
          onSubmit: (_) {
            handlerCalls++;
            return true;
          },
        );
        await started.future;
        rebuildParent(() => moveField = true);
        await tester.pump();

        expect(
          (await pendingSubmit).status,
          AnimalSubmitStatus.changedDuringValidation,
        );
        expect(controller.isSubmitting, isFalse);
        validation.complete('late after reparent');
        await tester.pump();
        expect(controller.valueFor(fieldKey), 'baseline');
        expect(controller.getFieldError(fieldKey), isNull);
        expect(
          controller.getFieldStatus(fieldKey),
          AnimalValidationStatus.idle,
        );
        expect(handlerCalls, 0);
        // The reparented item kept its registration: the binding captured
        // before the move still writes the field.
        expect(() => originalOnChanged!('moved'), returnsNormally);
        expect(controller.valueFor(fieldKey), 'moved');
      } finally {
        if (!validation.isCompleted) validation.complete(null);
        if (pendingSubmit != null) await pendingSubmit;
        try {
          await tester.pumpWidget(const SizedBox.shrink());
        } finally {
          controller.dispose();
        }
      }
    });

    test(
      'disposing inside the handler returns without disposed notifications',
      () async {
        final controller = _NotificationGuardController();
        final handlerStarted = Completer<void>();
        final handlerResult = Completer<bool>();
        final pendingSubmit = controller.submit(
          onSubmit: (_) {
            handlerStarted.complete();
            controller.dispose();
            return handlerResult.future;
          },
        );

        await handlerStarted.future;
        expect(
          (await pendingSubmit).status,
          AnimalSubmitStatus.changedDuringValidation,
        );
        expect(controller.disposed, isTrue);
        expect(controller.notificationsAfterDispose, 0);
        handlerResult.complete(true);
        await Future<void>.delayed(Duration.zero);
        expect(controller.notificationsAfterDispose, 0);
      },
    );

    test(
      'a reentrant field registration stops later submit validators',
      () async {
        final controller = AnimalFormController();
        final firstKey = AnimalFieldKey<String>(debugLabel: 'reentrant-first');
        final secondKey = AnimalFieldKey<String>(
          debugLabel: 'reentrant-second',
        );
        final addedKey = AnimalFieldKey<int>(debugLabel: 'reentrant-added');
        var firstValidatorCalls = 0;
        var secondValidatorCalls = 0;
        var handlerCalls = 0;
        var registered = false;
        final firstRegistration = controller.registerField<String>(
          key: firstKey,
          initialValue: 'first',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              firstValidatorCalls++;
              return null;
            }),
          ],
        );
        final secondRegistration = controller.registerField<String>(
          key: secondKey,
          initialValue: 'second',
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              secondValidatorCalls++;
              return null;
            }),
          ],
        );
        firstRegistration.addListener(() {
          if (!registered &&
              controller.getFieldStatus(firstKey) ==
                  AnimalValidationStatus.validating) {
            registered = true;
            controller.registerField<int>(key: addedKey, initialValue: 1);
          }
        });

        final result = await controller.submit(
          onSubmit: (_) {
            handlerCalls++;
            return true;
          },
        );

        expect(result.status, AnimalSubmitStatus.changedDuringValidation);
        expect(firstValidatorCalls, 0);
        expect(secondValidatorCalls, 0);
        expect(handlerCalls, 0);
        expect(controller.isSubmitting, isFalse);
        controller.unregisterField(firstRegistration);
        controller.unregisterField(secondRegistration);
        controller.dispose();
      },
    );

    test('a rule replacement invalidates an in-flight submit', () async {
      final controller = AnimalFormController();
      final focusNode = FocusNode();
      final key = AnimalFieldKey<String>(debugLabel: 'rules-submit');
      final started = Completer<void>();
      final validation = Completer<String?>();
      final registration = controller.registerField<String>(
        key: key,
        initialValue: 'valid',
        focusNode: focusNode,
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            if (!started.isCompleted) started.complete();
            return validation.future;
          }),
        ],
      );

      final pendingSubmit = controller.submit(onSubmit: (_) => true);
      await started.future;
      controller.updateFieldRegistration<String>(
        registration,
        rules: const <AnimalRule<String>>[],
        focusNode: focusNode,
      );

      expect(
        (await pendingSubmit).status,
        AnimalSubmitStatus.changedDuringValidation,
      );
      validation.complete(null);
      await Future<void>.delayed(Duration.zero);
      expect(controller.getFieldError(key), isNull);
      controller.unregisterField(registration);
      controller.dispose();
      focusNode.dispose();
    });

    test('false rejects and thrown exceptions remain caller-visible', () async {
      final controller = AnimalFormController();
      final rejected = await controller.submit(onSubmit: (_) => false);
      expect(rejected.status, AnimalSubmitStatus.rejected);
      expect(rejected.status == AnimalSubmitStatus.success, isFalse);

      final failure = StateError('server detail');
      final failed = await controller.submit(onSubmit: (_) => throw failure);
      expect(failed.status, AnimalSubmitStatus.error);
      expect(failed.error, same(failure));
      controller.dispose();
    });

    test(
      'a value change during the handler cancels only its local submit',
      () async {
        await _expectHandlerPhaseInvalidation(
          invalidate: (controller, registration, _, _) =>
              controller.setValue(registration.key, 'changed', validate: false),
        );
      },
    );

    test(
      'a rule change during the handler cancels the pending submit',
      () async {
        await _expectHandlerPhaseInvalidation(
          invalidate: (controller, registration, _, focusNode) =>
              controller.updateFieldRegistration<String>(
                registration,
                rules: <AnimalRule<String>>[AnimalRule<String>.required()],
                focusNode: focusNode,
              ),
          lateCompletion: _LateHandlerCompletion.rejected,
        );
      },
    );

    test(
      'a fieldset change during the handler cancels the pending submit',
      () async {
        await _expectHandlerPhaseInvalidation(
          invalidate: (controller, _, _, _) {
            controller.registerField<int>(
              key: AnimalFieldKey<int>(debugLabel: 'handler-phase-added'),
              initialValue: 1,
            );
          },
          lateCompletion: _LateHandlerCompletion.failed,
        );
      },
    );

    test(
      'unregister and same-key re-registration cancel a pending handler',
      () async {
        await _expectHandlerPhaseInvalidation(
          invalidate: (controller, registration, _, _) {
            controller.unregisterField(registration);
            controller.registerField<String>(
              key: registration.key,
              initialValue: 'replacement',
            );
          },
        );
      },
    );

    test('reset during the handler cancels the pending submit', () async {
      await _expectHandlerPhaseInvalidation(
        invalidate: (controller, _, _, _) => controller.reset(),
        lateCompletion: _LateHandlerCompletion.failed,
      );
    });

    test('default handler replacement cancels a pending handler', () async {
      await _expectHandlerPhaseInvalidation(
        replaceDefaultHandler: true,
        invalidate: (controller, _, replacementHandler, _) {
          controller.defaultSubmitHandler = replacementHandler;
        },
        lateCompletion: _LateHandlerCompletion.rejected,
      );
    });

    test('an absent handler keeps validation-only successful submit', () async {
      final controller = AnimalFormController();
      final key = AnimalFieldKey<String>(debugLabel: 'validation-only');
      controller.registerField<String>(
        key: key,
        initialValue: 'valid',
        rules: <AnimalRule<String>>[AnimalRule<String>.required()],
      );

      expect((await controller.submit()).status, AnimalSubmitStatus.success);
      controller.dispose();
    });

    testWidgets('invalid submit focuses its first failing binding', (
      tester,
    ) async {
      final controller = AnimalFormController();
      final firstKey = AnimalFieldKey<String>(debugLabel: 'first-invalid');
      final secondKey = AnimalFieldKey<String>(debugLabel: 'second-invalid');
      final firstFocus = FocusNode();
      final secondFocus = FocusNode();
      var handlerCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AnimalIslandTheme.light.toThemeData(),
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: Column(
                children: <Widget>[
                  AnimalFormItem<String>(
                    fieldKey: firstKey,
                    focusNode: firstFocus,
                    rules: <AnimalRule<String>>[AnimalRule<String>.required()],
                    builder: (_, binding) => Focus(
                      focusNode: binding.focusNode,
                      child: const SizedBox(height: 1),
                    ),
                  ),
                  AnimalFormItem<String>(
                    fieldKey: secondKey,
                    focusNode: secondFocus,
                    rules: <AnimalRule<String>>[AnimalRule<String>.required()],
                    builder: (_, binding) => Focus(
                      focusNode: binding.focusNode,
                      child: const SizedBox(height: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final result = await controller.submit(
        onSubmit: (_) {
          handlerCalls++;
          return true;
        },
      );
      await tester.pump();

      expect(result.status, AnimalSubmitStatus.invalid);
      expect(firstFocus.hasFocus, isTrue);
      expect(secondFocus.hasFocus, isFalse);
      expect(handlerCalls, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      firstFocus.dispose();
      secondFocus.dispose();
    });

    test(
      'an old void callback is rejected by the public consumer API',
      () async {
        final Directory packageRoot = Directory.current;
        final Directory scratch = Directory(p.join(packageRoot.path, 'scratch'))
          ..createSync(recursive: true);
        final consumerDirectory = scratch.createTempSync(
          'form-submit-boundary-',
        );
        try {
          File(p.join(consumerDirectory.path, 'analysis_options.yaml'))
              .writeAsStringSync('analyzer:\n  exclude: []\n');
          final File consumer =
              File(p.join(consumerDirectory.path, 'void_submit.dart'))
                ..writeAsStringSync('''
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/widgets.dart';

void oldSubmitHandler(AnimalFormValues values) {}

void main() {
  AnimalForm(onSubmit: oldSubmitHandler, child: const SizedBox.shrink());
}
''');
          final String consumerPath = p.normalize(p.absolute(consumer.path));
          final String dartExecutable = lockedDartExecutable();
          expect(File(dartExecutable).existsSync(), isTrue);
          final AnalysisContextCollection contexts = AnalysisContextCollection(
            includedPaths: <String>[consumerPath],
            sdkPath: p.dirname(p.dirname(dartExecutable)),
          );
          try {
            final result = await contexts
                .contextFor(consumerPath)
                .currentSession
                .getResolvedUnit(consumerPath)
                .timeout(
                  _voidCallbackResolutionWatchdog,
                  onTimeout: () => throw TimeoutException(
                    'Resolving the external void-callback consumer exceeded '
                    'the 90-second in-process analyzer bound.',
                  ),
                );
            expect(
              result,
              isA<ResolvedUnitResult>(),
              reason: 'The external void-callback consumer must resolve.',
            );
            final ResolvedUnitResult resolved = result as ResolvedUnitResult;
            expect(resolved.diagnostics, hasLength(1));
            final diagnostic = resolved.diagnostics.single;
            expect(
              diagnostic.diagnosticCode.lowerCaseName,
              'argument_type_not_assignable',
            );
            expect(p.equals(diagnostic.source.fullName, consumerPath), isTrue);
            final String source = consumer.readAsStringSync();
            expect(
              source.substring(
                diagnostic.offset,
                diagnostic.offset + diagnostic.length,
              ),
              'oldSubmitHandler',
              reason:
                  'Only the incompatible public onSubmit argument may trigger '
                  'the callback type diagnostic.',
            );
          } finally {
            await contexts.dispose();
          }
        } finally {
          consumerDirectory.deleteSync(recursive: true);
          expect(consumerDirectory.existsSync(), isFalse);
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
