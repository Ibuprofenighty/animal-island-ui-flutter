import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../support/locked_dart_process.dart';

void main() {
  group('AnimalInput Behavior & Contract Tests (C12 / INP01-INP04)', () {
    testWidgets(
      'INP01: caller TextEditingValue is retained and its controller is borrowed',
      (tester) async {
        final controller = TextEditingController.fromValue(
          const TextEditingValue(
            text: 'Initial external',
            selection: TextSelection.collapsed(offset: 7),
            composing: TextRange(start: 0, end: 7),
          ),
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _localizedApp(AnimalInput(controller: controller)),
        );

        expect(controller.value.text, 'Initial external');
        expect(
          controller.value.selection,
          const TextSelection.collapsed(offset: 7),
        );
        expect(controller.value.composing, const TextRange(start: 0, end: 7));

        await tester.pumpWidget(_localizedApp(const SizedBox.shrink()));
        controller.value = const TextEditingValue(text: 'Still works');
        expect(controller.text, 'Still works');
      },
    );

    testWidgets(
      'INP02: typing updates the borrowed buffer and caller callback',
      (tester) async {
        _installInMemoryClipboard(tester);
        String? changed;
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _localizedApp(
            AnimalInput(
              controller: controller,
              placeholder: 'Type island name',
              onChanged: (value) => changed = value,
            ),
          ),
        );

        await tester.enterText(find.byType(AnimalInput), 'Horizon Island');

        expect(changed, 'Horizon Island');
        expect(controller.text, 'Horizon Island');
        expect(find.text('Horizon Island'), findsOneWidget);

        await Clipboard.setData(const ClipboardData(text: ' 海岛🏝️'));
        controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        );
        final EditableTextState editable = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        await editable.pasteText(SelectionChangedCause.keyboard);
        await tester.pump();

        expect(controller.text, 'Horizon Island 海岛🏝️');
        expect(changed, 'Horizon Island 海岛🏝️');
      },
    );

    testWidgets('INP03: clear notifies once and readOnly cannot clear', (
      tester,
    ) async {
      _installInMemoryClipboard(tester);
      var changes = 0;
      final controller = TextEditingController(text: 'Clear me');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _localizedApp(
          AnimalInput(
            controller: controller,
            clearable: true,
            onChanged: (_) => changes++,
          ),
        ),
      );

      expect(find.bySemanticsLabel('Clear input'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Clear input'));
      await tester.pumpAndSettle();
      expect(controller.text, '');
      expect(changes, 1);

      Future<void> activateClearByKeyboard(LogicalKeyboardKey key) async {
        final Finder clearFinder = find.bySemanticsLabel('Clear input');
        final Focus focus = tester.widget<Focus>(
          find.descendant(of: clearFinder, matching: find.byType(Focus)).first,
        );
        focus.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
      }

      controller.text = 'Space me';
      await tester.pump();
      await activateClearByKeyboard(LogicalKeyboardKey.space);
      expect(controller.text, '');
      expect(changes, 2);

      controller.text = 'Enter me';
      await tester.pump();
      await activateClearByKeyboard(LogicalKeyboardKey.enter);
      expect(controller.text, '');
      expect(changes, 3);

      controller.text = 'Disabled';
      await tester.pumpWidget(
        _localizedApp(
          AnimalInput(
            controller: controller,
            clearable: true,
            disabled: true,
            onChanged: (_) => changes++,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Clear input'), findsNothing);
      expect(controller.text, 'Disabled');
      expect(changes, 3);

      controller.text = 'Copyable';
      await tester.pumpWidget(
        _localizedApp(
          AnimalInput(
            controller: controller,
            clearable: true,
            readOnly: true,
            onChanged: (_) => changes++,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Clear input'), findsNothing);
      expect(controller.text, 'Copyable');
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).readOnly,
        isTrue,
      );
      expect(changes, 3);

      controller.value = TextEditingValue(
        text: 'Copyable',
        selection: const TextSelection(baseOffset: 0, extentOffset: 8),
      );
      final EditableTextState editable = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      editable.copySelection(SelectionChangedCause.keyboard);
      await tester.pump();
      expect((await Clipboard.getData(Clipboard.kTextPlain))?.text, 'Copyable');
      expect(controller.text, 'Copyable');
      expect(changes, 3);
    });

    testWidgets(
      'INP04: status error and label semantics, default shadow, and large adornments',
      (tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        final AnimalFormController form = AnimalFormController();
        final AnimalFieldKey<String> key = AnimalFieldKey<String>(
          debugLabel: 'input-semantics',
        );
        final TextEditingController controller = TextEditingController();
        addTearDown(() {
          controller.dispose();
          form.dispose();
        });
        try {
          await tester.pumpWidget(
            _localizedApp(
              AnimalForm(
                controller: form,
                child: AnimalFormItem<String>(
                  fieldKey: key,
                  textController: controller,
                  label: 'Island name',
                  rules: <AnimalRule<String>>[
                    AnimalRule<String>.required(message: 'Name is required'),
                  ],
                  builder: (context, binding) => AnimalInput(
                    controller: controller,
                    placeholder: 'Enter an island name',
                    status: binding.error == null
                        ? AnimalInputStatus.normal
                        : AnimalInputStatus.error,
                  ),
                ),
              ),
            ),
          );

          expect(await form.validate(), isFalse);
          await tester.pumpAndSettle();
          final SemanticsData fieldSemantics = tester
              .getSemantics(find.byType(EditableText))
              .getSemanticsData();
          final SemanticsData errorSemantics = tester
              .getSemantics(find.text('Name is required'))
              .getSemanticsData();
          expect(
            fieldSemantics.validationResult,
            SemanticsValidationResult.invalid,
          );
          expect(
            tester
                .getSemantics(find.text('Island name'))
                .getSemanticsData()
                .label,
            'Island name',
          );
          expect(errorSemantics.flagsCollection.isLiveRegion, isTrue);
          expect(find.text('Name is required'), findsOneWidget);

          final TextEditingController layoutController = TextEditingController(
            text: 'text',
          );
          addTearDown(layoutController.dispose);
          await tester.pumpWidget(
            _localizedApp(
              MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: SizedBox(
                  width: 360,
                  child: AnimalInput(
                    controller: layoutController,
                    size: AnimalInputSize.large,
                    prefix: const Text('Prefix'),
                    suffix: const Text('Suffix'),
                  ),
                ),
              ),
            ),
          );
          final AnimatedContainer surface = tester.widget<AnimatedContainer>(
            find.descendant(
              of: find.byType(AnimalInput),
              matching: find.byType(AnimatedContainer),
            ),
          );
          expect((surface.decoration as BoxDecoration).boxShadow, isEmpty);
          final Rect prefixRect = tester.getRect(find.text('Prefix'));
          final Rect editableRect = tester.getRect(find.byType(EditableText));
          final Rect suffixRect = tester.getRect(find.text('Suffix'));
          final Rect inputRect = tester.getRect(find.byType(AnimalInput));
          expect(inputRect.height, greaterThan(AnimalInputSize.large.height));
          expect(prefixRect.width, lessThanOrEqualTo(80));
          expect(suffixRect.width, lessThanOrEqualTo(80));
          expect(prefixRect.height, greaterThan(AnimalInputSize.large.height));
          expect(suffixRect.height, greaterThan(AnimalInputSize.large.height));
          expect(
            editableRect.width,
            greaterThanOrEqualTo(AnimalInputSize.large.fontSize * 4),
          );
          expect(prefixRect.right, lessThanOrEqualTo(editableRect.left));
          expect(editableRect.right, lessThanOrEqualTo(suffixRect.left));
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'N14 single-line minimum height shrinkwraps and multiline grows with its editing value',
      (tester) async {
        final TextEditingController singleLineController =
            TextEditingController();
        final TextEditingController shortMultilineController =
            TextEditingController(text: 'short');
        final String multilineText = 'First\n第二🙂\nThird';
        final TextEditingValue multilineValue = TextEditingValue(
          text: multilineText,
          selection: TextSelection.collapsed(offset: multilineText.length),
          composing: const TextRange(start: 0, end: 5),
        );
        final TextEditingController multilineController =
            TextEditingController.fromValue(multilineValue);
        addTearDown(singleLineController.dispose);
        addTearDown(shortMultilineController.dispose);
        addTearDown(multilineController.dispose);

        Future<Rect> pumpInput({
          required TextEditingController controller,
          required AnimalInputSize size,
          required int? maxLines,
          required int? minLines,
        }) async {
          await tester.pumpWidget(
            _localizedApp(
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 700),
                  child: SizedBox(
                    width: 360,
                    child: AnimalInput(
                      controller: controller,
                      size: size,
                      minLines: minLines,
                      maxLines: maxLines,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          return tester.getRect(find.byType(AnimalInput));
        }

        final Rect singleLineRect = await pumpInput(
          controller: singleLineController,
          size: AnimalInputSize.middle,
          minLines: null,
          maxLines: 1,
        );
        expect(
          singleLineRect.height,
          greaterThanOrEqualTo(AnimalInputSize.middle.height),
        );
        expect(singleLineRect.height, lessThan(100));

        for (final AnimalInputSize size in AnimalInputSize.values) {
          for (final int? maxLines in <int?>[3, null]) {
            final Rect shortMultilineRect = await pumpInput(
              controller: shortMultilineController,
              size: size,
              minLines: 1,
              maxLines: maxLines,
            );
            expect(
              shortMultilineRect.height,
              greaterThanOrEqualTo(size.height),
              reason:
                  '${size.name} maxLines=$maxLines keeps its minimum height',
            );
            expect(
              shortMultilineRect.height,
              lessThan(100),
              reason: 'Short content must shrink-wrap for ${size.name}',
            );
          }
        }

        final Rect multilineRect = await pumpInput(
          controller: multilineController,
          size: AnimalInputSize.large,
          minLines: 1,
          maxLines: 3,
        );
        final Size editableSize = tester.getSize(find.byType(EditableText));
        expect(multilineRect.height, greaterThan(AnimalInputSize.large.height));
        expect(
          editableSize.height,
          greaterThanOrEqualTo(AnimalInputSize.large.fontSize * 3),
        );
        expect(multilineController.value, multilineValue);

        final Rect unboundedMultilineRect = await pumpInput(
          controller: multilineController,
          size: AnimalInputSize.large,
          minLines: 1,
          maxLines: null,
        );
        final Size unboundedEditableSize = tester.getSize(
          find.byType(EditableText),
        );
        expect(
          unboundedMultilineRect.height,
          greaterThan(AnimalInputSize.large.height),
        );
        expect(
          unboundedEditableSize.height,
          greaterThanOrEqualTo(AnimalInputSize.large.fontSize * 3),
        );
        expect(multilineController.value, multilineValue);
        expect(tester.takeException(), isNull);
      },
    );

    test('N14 old Input value and initialValue APIs fail to compile', () async {
      final Directory packageRoot = _findPackageRoot();
      final Directory scratch = Directory(p.join(packageRoot.path, 'scratch'))
        ..createSync(recursive: true);
      final Directory consumer = scratch.createTempSync('input-api-boundary-');
      try {
        File(p.join(consumer.path, 'analysis_options.yaml'))
            .writeAsStringSync('analyzer:\n  exclude: []\n');
        final File oldValue = File(p.join(consumer.path, 'old_value.dart'))
          ..writeAsStringSync('''
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/widgets.dart';

void main() {
  AnimalInput(controller: TextEditingController(), value: 'old');
}
''');
        final File oldInitialValue =
            File(p.join(consumer.path, 'old_initial_value.dart'))
              ..writeAsStringSync('''
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/widgets.dart';

void main() {
  AnimalInput(controller: TextEditingController(), initialValue: 'old');
}
''');
        final File missingController =
            File(p.join(consumer.path, 'missing_controller.dart'))
              ..writeAsStringSync('''
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  AnimalInput();
}
''');

        final String sdkPath = p.dirname(p.dirname(lockedDartExecutable()));
        final AnalysisContextCollection contexts = AnalysisContextCollection(
          includedPaths: <String>[consumer.path],
          sdkPath: sdkPath,
        );
        try {
          Future<void> expectDiagnostic(
            File source,
            String expectedCode,
          ) async {
            final result = await contexts
                .contextFor(source.path)
                .currentSession
                .getResolvedUnit(source.path);
            expect(
              result,
              isA<ResolvedUnitResult>(),
              reason: 'Analyzer did not resolve ${source.path}',
            );
            final ResolvedUnitResult resolved = result as ResolvedUnitResult;
            final List<String> codes = resolved.diagnostics
                .map((diagnostic) => diagnostic.diagnosticCode.lowerCaseName)
                .toList();
            expect(codes, <String>[expectedCode], reason: source.path);
          }

          await expectDiagnostic(oldValue, 'undefined_named_parameter');
          await expectDiagnostic(oldInitialValue, 'undefined_named_parameter');
          await expectDiagnostic(
            missingController,
            'missing_required_argument',
          );
        } finally {
          await contexts.dispose();
        }
      } finally {
        consumer.deleteSync(recursive: true);
        expect(consumer.existsSync(), isFalse);
      }
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('AnimalForm text buffer N14', () {
    testWidgets(
      'external controller edits drive binding and submit snapshots without callback writes',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'external-text');
        final buffer = TextEditingController();
        addTearDown(buffer.dispose);
        addTearDown(form.dispose);
        var inputNotifications = 0;
        var formNotifications = 0;
        AnimalFieldBinding<String>? liveBinding;

        await tester.pumpWidget(
          _localizedApp(
            AnimalForm(
              controller: form,
              onChanged: (_) => formNotifications++,
              child: AnimalFormItem<String>(
                fieldKey: key,
                textController: buffer,
                builder: (context, binding) {
                  liveBinding = binding;
                  return AnimalInput(
                    controller: buffer,
                    focusNode: binding.focusNode,
                    onChanged: (_) => inputNotifications++,
                  );
                },
              ),
            ),
          ),
        );
        formNotifications = 0;

        buffer.value = const TextEditingValue(
          text: 'from full value',
          selection: TextSelection.collapsed(offset: 5),
          composing: TextRange(start: 0, end: 4),
        );
        expect(liveBinding!.value, 'from full value');
        await tester.pump();

        expect(form.valueFor(key), 'from full value');
        expect(form.values.valueFor(key), 'from full value');
        expect(liveBinding!.value, 'from full value');
        expect(form.isDirty, isTrue);
        expect(formNotifications, 1);
        expect(inputNotifications, 0);

        buffer.text = '';
        expect(liveBinding!.value, isNull);
        await tester.pump();
        expect(form.valueFor(key), isNull);
        expect(form.values.valueFor(key), isNull);
        expect(liveBinding!.value, isNull);
        expect(form.isDirty, isFalse);

        final AnimalSubmitResult result = await form.submit(
          onSubmit: (values) {
            expect(values.valueFor(key), isNull);
            return true;
          },
        );
        expect(result.status, AnimalSubmitStatus.success);
      },
    );

    testWidgets(
      'Chinese IME composing edits update Form once and preserve composition',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'ime-text');
        final buffer = TextEditingController();
        var validations = 0;
        addTearDown(buffer.dispose);
        addTearDown(form.dispose);

        await tester.pumpWidget(
          _textForm(
            form,
            key,
            buffer,
            rules: <AnimalRule<String>>[
              AnimalRule<String>.custom((_) {
                validations++;
                return null;
              }),
            ],
          ),
        );
        await tester.showKeyboard(find.byType(TextField));

        const TextEditingValue composing = TextEditingValue(
          text: '海岛',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 0, end: 2),
        );
        tester.testTextInput.updateEditingValue(composing);
        await tester.pumpAndSettle();
        expect(buffer.value, composing);
        expect(form.valueFor(key), '海岛');
        expect(validations, 1);

        const TextEditingValue committed = TextEditingValue(
          text: '海岛',
          selection: TextSelection.collapsed(offset: 2),
        );
        tester.testTextInput.updateEditingValue(committed);
        await tester.pumpAndSettle();
        expect(buffer.value, committed);
        expect(form.valueFor(key), '海岛');
        expect(validations, 1);
      },
    );

    testWidgets(
      'same text preserves editing state while set reset and clear use the buffer',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'buffer-reset');
        const initial = TextEditingValue(
          text: 'seed',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 0, end: 2),
        );
        final buffer = TextEditingController.fromValue(initial);
        addTearDown(buffer.dispose);
        addTearDown(form.dispose);
        var bufferWrites = 0;
        buffer.addListener(() => bufferWrites++);

        await tester.pumpWidget(_textForm(form, key, buffer));
        await tester.showKeyboard(find.byType(EditableText));
        await tester.pump();
        expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isTrue,
        );

        // Focus can update selection, so restore the full seed before counting
        // Form-originated writes.
        buffer.value = initial;
        await tester.pump();
        expect(buffer.value, initial);
        bufferWrites = 0;

        form.setValue(key, 'seed');
        expect(buffer.value, initial);
        expect(bufferWrites, 0);

        form.setValue(key, 'replacement');
        await tester.pump();
        expect(form.valueFor(key), 'replacement');
        expect(bufferWrites, 1);
        expect(
          buffer.value,
          const TextEditingValue(
            text: 'replacement',
            selection: TextSelection.collapsed(offset: 11),
            composing: TextRange.empty,
          ),
        );

        form.clear();
        await tester.pump();
        expect(buffer.text, '');
        expect(form.valueFor(key), isNull);
        expect(bufferWrites, 2);

        form.reset();
        await tester.pump();
        expect(form.valueFor(key), 'seed');
        expect(bufferWrites, 3);
        expect(
          buffer.value,
          const TextEditingValue(
            text: 'seed',
            selection: TextSelection.collapsed(offset: 4),
            composing: TextRange.empty,
          ),
        );

        buffer.value = initial;
        await tester.pump();
        expect(buffer.value, initial);
        bufferWrites = 0;
        form.reset();
        await tester.pump();
        expect(buffer.value, initial);
        expect(bufferWrites, 0);
        expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isTrue,
        );
      },
    );

    testWidgets(
      'empty text and null setValue are the same without staling work',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'empty-text-alias');
        const TextEditingValue initial = TextEditingValue(
          selection: TextSelection.collapsed(offset: 0),
        );
        final buffer = TextEditingController.fromValue(initial);
        final validationStarted = Completer<void>();
        final validationResult = Completer<String?>();
        final handlerStarted = Completer<void>();
        final handlerResult = Completer<bool>();
        var validationCalls = 0;
        addTearDown(buffer.dispose);
        addTearDown(form.dispose);

        await tester.pumpWidget(
          _textForm(
            form,
            key,
            buffer,
            rules: <AnimalRule<String>>[
              AnimalRule<String>.custom((_) {
                validationCalls++;
                if (!validationStarted.isCompleted) {
                  validationStarted.complete();
                }
                return validationResult.future;
              }),
            ],
          ),
        );

        final Future<bool> validation = form.validateField(key);
        await validationStarted.future;
        form.setValue<String>(key, '', validate: true);
        form.setValue<String>(key, null, validate: true);
        expect(form.isDirty, isFalse);
        expect(buffer.value, initial);
        validationResult.complete(null);
        expect(await validation, isTrue);
        expect(validationCalls, 1);

        final Future<AnimalSubmitResult> submission = form.submit(
          onSubmit: (_) {
            handlerStarted.complete();
            return handlerResult.future;
          },
        );
        await handlerStarted.future;
        form.setValue<String>(key, '', validate: true);
        form.setValue<String>(key, null, validate: true);
        expect(form.isSubmitting, isTrue);
        expect(form.isDirty, isFalse);
        expect(buffer.value, initial);
        expect(validationCalls, 2);

        handlerResult.complete(true);
        expect((await submission).status, AnimalSubmitStatus.success);
      },
    );

    testWidgets(
      'selection and composing only changes keep a pending validation current',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'selection-only');
        final buffer = TextEditingController(text: 'pending');
        final started = Completer<void>();
        final result = Completer<String?>();
        var calls = 0;
        addTearDown(buffer.dispose);
        addTearDown(form.dispose);

        await tester.pumpWidget(
          _textForm(
            form,
            key,
            buffer,
            rules: <AnimalRule<String>>[
              AnimalRule<String>.custom((_) {
                calls++;
                if (!started.isCompleted) started.complete();
                return result.future;
              }),
            ],
          ),
        );
        final Future<bool> validation = form.validateField(key);
        await started.future;
        buffer.value = const TextEditingValue(
          text: 'pending',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 1, end: 5),
        );
        result.complete('selection did not change text');

        expect(await validation, isFalse);
        expect(calls, 1);
        expect(form.valueFor(key), 'pending');
        expect(
          form.getFieldError(key)?.literalText,
          'selection did not change text',
        );
      },
    );

    testWidgets(
      'external text edits stale old validation while validate false suppresses replacement validation',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'external-validation');
        final buffer = TextEditingController(text: 'first');
        final firstStarted = Completer<void>();
        final firstResult = Completer<String?>();
        final secondFocus = FocusNode()..debugLabel = 'no-validate';
        var calls = 0;
        addTearDown(buffer.dispose);
        addTearDown(secondFocus.dispose);
        addTearDown(form.dispose);

        await tester.pumpWidget(
          _textForm(
            form,
            key,
            buffer,
            rules: <AnimalRule<String>>[
              AnimalRule<String>.custom((value) {
                calls++;
                if (value == 'first') {
                  if (!firstStarted.isCompleted) firstStarted.complete();
                  return firstResult.future;
                }
                return null;
              }),
            ],
          ),
        );

        final Future<bool> staleValidation = form.validateField(key);
        await firstStarted.future;
        buffer.text = 'second';
        await tester.pump();
        firstResult.complete('obsolete error');
        expect(await staleValidation, isFalse);
        await tester.pump();
        expect(form.valueFor(key), 'second');
        expect(form.getFieldError(key), isNull);
        expect(form.getFieldStatus(key), AnimalValidationStatus.valid);
        expect(calls, 2);

        final nextStarted = Completer<void>();
        final nextResult = Completer<String?>();
        // Install a validator with a pending invocation before the no-validate
        // update so the old result can prove it was invalidated.
        final secondKey = AnimalFieldKey<String>(debugLabel: 'no-validate');
        final secondBuffer = TextEditingController(text: 'waiting');
        addTearDown(secondBuffer.dispose);
        final secondRegistration = form.registerTextField(
          key: secondKey,
          textController: secondBuffer,
          focusNode: secondFocus,
          rules: <AnimalRule<String>>[
            AnimalRule<String>.custom((_) {
              if (!nextStarted.isCompleted) nextStarted.complete();
              return nextResult.future;
            }),
          ],
        );
        final Future<bool> pending = form.validateField(secondKey);
        await nextStarted.future;
        form.setRegistrationValue<String>(
          secondRegistration,
          'quiet',
          validate: false,
        );
        expect(form.getFieldStatus(secondKey), AnimalValidationStatus.idle);
        nextResult.complete('must not apply');
        expect(await pending, isFalse);
        expect(form.getFieldError(secondKey), isNull);
        expect(form.getFieldStatus(secondKey), AnimalValidationStatus.idle);
        expect(form.valueFor(secondKey), 'quiet');
      },
    );

    testWidgets(
      'text controller swap creates a generation and detaches the old buffer',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'swap-text');
        final first = TextEditingController(text: 'first baseline');
        final second = TextEditingController(text: 'second baseline');
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        addTearDown(form.dispose);
        TextEditingController active = first;
        late StateSetter updateHarness;
        var generation = 0;
        AnimalFieldBinding<String>? firstBinding;

        Widget tree() => _localizedApp(
          StatefulBuilder(
            builder: (context, setState) {
              updateHarness = setState;
              return AnimalForm(
                controller: form,
                child: AnimalFormItem<String>(
                  fieldKey: key,
                  textController: active,
                  builder: (context, binding) {
                    generation = binding.generation;
                    firstBinding ??= binding;
                    return AnimalInput(
                      controller: active,
                      focusNode: binding.focusNode,
                    );
                  },
                ),
              );
            },
          ),
        );

        await tester.pumpWidget(tree());
        final int firstGeneration = generation;
        updateHarness(() => active = second);
        await tester.pumpWidget(tree());
        expect(generation, greaterThan(firstGeneration));
        expect(form.valueFor(key), 'second baseline');
        expect(
          () => firstBinding!.onChanged('stale old binding'),
          throwsStateError,
        );
        expect(form.valueFor(key), 'second baseline');

        first.text = 'stale old buffer';
        expect(form.valueFor(key), 'second baseline');
        second.text = 'new current';
        expect(form.valueFor(key), 'new current');

        await tester.pumpWidget(_localizedApp(const SizedBox.shrink()));
        first.text = 'still borrowed';
        second.text = 'also borrowed';
        expect(first.text, 'still borrowed');
        expect(second.text, 'also borrowed');
      },
    );

    testWidgets(
      'GlobalKey reparent retains the text registration and buffer listener',
      (tester) async {
        final form = AnimalFormController();
        final key = AnimalFieldKey<String>(debugLabel: 'reparent-text');
        final mountKey = GlobalKey();
        final buffer = TextEditingController(text: 'baseline');
        addTearDown(buffer.dispose);
        addTearDown(form.dispose);
        var moveField = false;
        late StateSetter updateHarness;
        var generation = 0;

        Widget field() => AnimalFormItem<String>(
          key: mountKey,
          fieldKey: key,
          textController: buffer,
          builder: (context, binding) {
            generation = binding.generation;
            return AnimalInput(
              controller: buffer,
              focusNode: binding.focusNode,
            );
          },
        );

        Widget tree() => _localizedApp(
          StatefulBuilder(
            builder: (context, setState) {
              updateHarness = setState;
              return AnimalForm(
                controller: form,
                child: Row(
                  children: moveField
                      ? <Widget>[
                          const SizedBox(width: 1),
                          Expanded(child: field()),
                        ]
                      : <Widget>[
                          Expanded(child: field()),
                          const SizedBox(width: 1),
                        ],
                ),
              );
            },
          ),
        );

        await tester.pumpWidget(tree());
        final int originalGeneration = generation;
        updateHarness(() => moveField = true);
        await tester.pumpWidget(tree());
        expect(generation, originalGeneration);
        buffer.text = 'after reparent';
        expect(form.valueFor(key), 'after reparent');
      },
    );

    testWidgets('direct buffer changes cancel a pending submit handler', (
      tester,
    ) async {
      final form = AnimalFormController();
      final key = AnimalFieldKey<String>(debugLabel: 'pending-handler-text');
      final buffer = TextEditingController(text: 'ready');
      final handlerStarted = Completer<void>();
      final handlerResult = Completer<bool>();
      addTearDown(buffer.dispose);
      addTearDown(form.dispose);

      await tester.pumpWidget(_textForm(form, key, buffer));
      final Future<AnimalSubmitResult> submission = form.submit(
        onSubmit: (_) {
          handlerStarted.complete();
          return handlerResult.future;
        },
      );
      await handlerStarted.future;
      buffer.text = 'changed externally';

      final AnimalSubmitResult result = await submission;
      expect(result.status, AnimalSubmitStatus.changedDuringValidation);
      handlerResult.complete(true);
      await tester.pump();
      expect(form.valueFor(key), 'changed externally');
      expect(form.isSubmitting, isFalse);
    });

    test('form writes are reconciled from the buffer after synchronous caller normalization', () async {
      final AnimalFormController form = AnimalFormController();
      final AnimalFieldKey<String> key = AnimalFieldKey<String>(
        debugLabel: 'normalized-write',
      );
      final TextEditingController buffer = TextEditingController(
        text: 'baseline',
      );
      final FocusNode focusNode = FocusNode();
      final List<String?> validatedValues = <String?>[];
      var replaceRequestedText = true;
      buffer.addListener(() {
        if (replaceRequestedText &&
            buffer.text == 'requested normalized value') {
          replaceRequestedText = false;
          buffer.text = 'actual normalized value';
        }
      });
      addTearDown(buffer.dispose);
      addTearDown(focusNode.dispose);
      addTearDown(form.dispose);
      final AnimalFieldRegistration<String> registration = form
          .registerTextField(
            key: key,
            textController: buffer,
            focusNode: focusNode,
            rules: <AnimalRule<String>>[
              AnimalRule<String>.custom((value) {
                validatedValues.add(value);
                return null;
              }),
            ],
          );
      var returnToRequestedText = true;
      buffer.addListener(() {
        if (returnToRequestedText && buffer.text == 'actual normalized value') {
          returnToRequestedText = false;
          buffer.text = 'requested normalized value';
        }
      });

      form.setValue<String>(key, 'requested normalized value', validate: false);
      expect(form.valueFor(key), 'requested normalized value');
      expect(form.bindingFor(registration).value, 'requested normalized value');
      expect(form.isDirty, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(validatedValues, <String?>[
        'actual normalized value',
        'requested normalized value',
      ]);
    });

    test('reset and clear derive dirty from the final buffer after synchronous restoration', () {
      final AnimalFormController form = AnimalFormController();
      final AnimalFieldKey<String> resetKey = AnimalFieldKey<String>(
        debugLabel: 'reset-restoration',
      );
      final TextEditingController resetBuffer = TextEditingController(
        text: 'reset baseline',
      );
      final FocusNode resetFocus = FocusNode();
      var restoreResetValue = false;
      resetBuffer.addListener(() {
        if (restoreResetValue && resetBuffer.text == 'reset baseline') {
          resetBuffer.text = 'changed value';
        }
      });
      final AnimalFieldKey<String> clearKey = AnimalFieldKey<String>(
        debugLabel: 'clear-restoration',
      );
      final TextEditingController clearBuffer = TextEditingController(
        text: 'clear baseline',
      );
      final FocusNode clearFocus = FocusNode();
      var restoreClearedValue = false;
      clearBuffer.addListener(() {
        if (restoreClearedValue && clearBuffer.text.isEmpty) {
          clearBuffer.text = 'clear baseline';
        }
      });
      addTearDown(resetBuffer.dispose);
      addTearDown(clearBuffer.dispose);
      addTearDown(resetFocus.dispose);
      addTearDown(clearFocus.dispose);
      addTearDown(form.dispose);
      final AnimalFieldRegistration<String> resetRegistration = form
          .registerTextField(
            key: resetKey,
            textController: resetBuffer,
            focusNode: resetFocus,
          );
      final AnimalFieldRegistration<String> clearRegistration = form
          .registerTextField(
            key: clearKey,
            textController: clearBuffer,
            focusNode: clearFocus,
          );

      form.setValue<String>(resetKey, 'changed value', validate: false);
      restoreResetValue = true;
      form.reset();
      expect(form.valueFor(resetKey), 'changed value');
      expect(form.bindingFor(resetRegistration).dirty, isTrue);
      expect(form.isDirty, isTrue);

      form.setValue<String>(clearKey, 'changed before clear', validate: false);
      restoreClearedValue = true;
      form.clear();
      expect(form.valueFor(clearKey), 'clear baseline');
      expect(form.bindingFor(clearRegistration).dirty, isFalse);
      expect(form.isDirty, isTrue);
    });

    test('inactive text edits stay silent and reconcile when the registration activates', () async {
      final AnimalFormController form = AnimalFormController();
      final AnimalFieldKey<String> inactiveKey = AnimalFieldKey<String>(
        debugLabel: 'inactive-text',
      );
      final AnimalFieldKey<String> activeKey = AnimalFieldKey<String>(
        debugLabel: 'active-text',
      );
      final TextEditingController inactiveBuffer = TextEditingController(
        text: 'before deactivation',
      );
      final TextEditingController activeBuffer = TextEditingController(
        text: 'pending validation',
      );
      final Completer<void> validationStarted = Completer<void>();
      final Completer<String?> validationResult = Completer<String?>();
      addTearDown(inactiveBuffer.dispose);
      addTearDown(activeBuffer.dispose);
      addTearDown(form.dispose);
      final AnimalFieldRegistration<String> inactiveRegistration = form
          .registerTextField(key: inactiveKey, textController: inactiveBuffer);
      form.registerTextField(
        key: activeKey,
        textController: activeBuffer,
        rules: <AnimalRule<String>>[
          AnimalRule<String>.custom((_) {
            if (!validationStarted.isCompleted) {
              validationStarted.complete();
            }
            return validationResult.future;
          }),
        ],
      );
      inactiveRegistration.deactivate();

      var formNotifications = 0;
      form.addListener(() => formNotifications++);
      final Future<bool> pendingValidation = form.validateField(activeKey);
      await validationStarted.future;
      final int notificationsBeforeInactiveEdit = formNotifications;
      inactiveBuffer.text = 'edited while inactive';
      expect(formNotifications, notificationsBeforeInactiveEdit);
      expect(form.valueFor(inactiveKey), 'edited while inactive');

      validationResult.complete(null);
      expect(await pendingValidation, isTrue);
      expect(form.getFieldStatus(activeKey), AnimalValidationStatus.valid);
      expect(form.isDirty, isFalse);

      expect(inactiveRegistration.activate(), isTrue);
      expect(form.valueFor(inactiveKey), 'edited while inactive');
      expect(form.isDirty, isTrue);
    });

    testWidgets(
      'text registration rejects competing initial values, wrong types and duplicate buffers',
      (tester) async {
        final form = AnimalFormController();
        final buffer = TextEditingController(text: 'caller seed');
        final firstKey = AnimalFieldKey<String>(debugLabel: 'first-text');
        final secondKey = AnimalFieldKey<String>(debugLabel: 'second-text');
        final firstFocus = FocusNode();
        final secondFocus = FocusNode();
        addTearDown(firstFocus.dispose);
        addTearDown(secondFocus.dispose);
        addTearDown(buffer.dispose);
        addTearDown(form.dispose);

        form.registerTextField(
          key: firstKey,
          textController: buffer,
          focusNode: firstFocus,
        );
        expect(
          () => form.registerTextField(
            key: secondKey,
            textController: buffer,
            focusNode: secondFocus,
          ),
          throwsArgumentError,
        );

        final conflictKey = AnimalFieldKey<String>(debugLabel: 'seed-conflict');
        final conflictBuffer = TextEditingController();
        addTearDown(conflictBuffer.dispose);
        await tester.pumpWidget(
          _localizedApp(
            AnimalForm(
              child: AnimalFormItem<String>(
                fieldKey: conflictKey,
                textController: conflictBuffer,
                initialValue: '',
                builder: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isArgumentError);

        final initialValuesKey = AnimalFieldKey<String>(
          debugLabel: 'initial-values-conflict',
        );
        final initialBuffer = TextEditingController();
        addTearDown(initialBuffer.dispose);
        await tester.pumpWidget(
          _localizedApp(
            AnimalForm(
              initialValues: AnimalFormValues.fromEntries(
                <AnimalFieldValue<String>>[
                  AnimalFieldValue<String>(initialValuesKey, null),
                ],
              ),
              child: AnimalFormItem<String>(
                fieldKey: initialValuesKey,
                textController: initialBuffer,
                builder: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isArgumentError);

        final wrongTypeBuffer = TextEditingController();
        addTearDown(wrongTypeBuffer.dispose);
        await tester.pumpWidget(
          _localizedApp(
            AnimalForm(
              child: AnimalFormItem<int>(
                fieldKey: AnimalFieldKey<int>(debugLabel: 'wrong-text-type'),
                textController: wrongTypeBuffer,
                builder: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isArgumentError);
      },
    );
  });
}

void _installInMemoryClipboard(WidgetTester tester) {
  String? clipboardText;
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    switch (call.method) {
      case 'Clipboard.setData':
        clipboardText =
            (call.arguments as Map<Object?, Object?>)['text'] as String?;
        return null;
      case 'Clipboard.getData':
        return clipboardText == null
            ? null
            : <String, dynamic>{'text': clipboardText};
      case 'Clipboard.hasStrings':
        return <String, dynamic>{'value': clipboardText != null};
      default:
        return null;
    }
  });
  addTearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });
}

Widget _localizedApp(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: child),
);

Widget _textForm(
  AnimalFormController form,
  AnimalFieldKey<String> key,
  TextEditingController buffer, {
  List<AnimalRule<String>>? rules,
}) => _localizedApp(
  AnimalForm(
    controller: form,
    child: AnimalFormItem<String>(
      fieldKey: key,
      textController: buffer,
      rules: rules,
      builder: (context, binding) =>
          AnimalInput(controller: buffer, focusNode: binding.focusNode),
    ),
  ),
);

Directory _findPackageRoot() {
  Directory current = Directory.current.absolute;
  while (true) {
    final File pubspec = File(p.join(current.path, 'pubspec.yaml'));
    final File packageConfig = File(
      p.join(current.path, '.dart_tool', 'package_config.json'),
    );
    if (pubspec.existsSync() && packageConfig.existsSync()) {
      final String contents = pubspec.readAsStringSync();
      if (RegExp(
        r'^name:\s*animal_island_ui\s*$',
        multiLine: true,
      ).hasMatch(contents)) {
        return current;
      }
    }
    final Directory parent = current.parent;
    if (parent.path == current.path) {
      throw StateError('Could not find the animal_island_ui package root.');
    }
    current = parent;
  }
}
