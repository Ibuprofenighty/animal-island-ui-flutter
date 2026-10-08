import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

void main() {
  group('AnimalCheckbox & CheckboxGroup Tests (C14 / CHK01-CHK04)', () {
    testWidgets('CHK01: Standalone checkbox toggles on tap', (tester) async {
      bool? checked = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCheckbox(
              value: checked,
              label: const Text('Accept Terms'),
              onChanged: (val) => checked = val,
            ),
          ),
        ),
      );

      expect(find.text('Accept Terms'), findsOneWidget);

      await tester.tap(find.byType(AnimalCheckbox));
      await tester.pumpAndSettle();

      expect(checked, isTrue);
    });

    testWidgets(
      'CHK01: CheckboxGroup selects and deselects items, respects disabled options',
      (tester) async {
        List<String> selectedValues = ['apple'];

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalCheckboxGroup<String>(
                    value: selectedValues,
                    options: const [
                      AnimalOption(value: 'apple', label: 'Apple'),
                      AnimalOption(value: 'banana', label: 'Banana'),
                      AnimalOption(
                        value: 'cherry',
                        label: 'Cherry',
                        disabled: true,
                      ),
                    ],
                    onChanged: (vals) => setState(() => selectedValues = vals),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);

        // Tap Banana -> adds to selection
        await tester.tap(find.text('Banana'));
        await tester.pumpAndSettle();
        expect(selectedValues, containsAll(['apple', 'banana']));

        // Tap disabled Cherry -> ignored
        await tester.tap(find.text('Cherry'));
        await tester.pumpAndSettle();
        expect(selectedValues.contains('cherry'), isFalse);

        // Tap Apple -> removes from selection
        await tester.tap(find.text('Apple'));
        await tester.pumpAndSettle();
        expect(selectedValues.contains('apple'), isFalse);
        expect(selectedValues, ['banana']);
      },
    );

    testWidgets(
      'N15 group options show their icon and announce their semantic label',
      (tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        AnimalOption<String> option(String id) => AnimalOption<String>(
          value: id,
          label: 'Apple',
          semanticLabel: 'Red apple $id',
          icon: SizedBox(key: ValueKey<String>('icon-$id'), width: 8),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: <Widget>[
                  AnimalCheckboxGroup<String>(
                    value: const <String>[],
                    options: <AnimalOption<String>>[option('checkbox')],
                    onChanged: (_) {},
                  ),
                  AnimalRadioGroup<String>(
                    value: null,
                    options: <AnimalOption<String>>[option('radio')],
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
        );
        for (final String id in <String>['checkbox', 'radio']) {
          expect(find.byKey(ValueKey<String>('icon-$id')), findsOneWidget);
          expect(find.bySemanticsLabel('Red apple $id'), findsOneWidget);
        }
        expect(find.bySemanticsLabel('Apple'), findsNothing);
        semantics.dispose();
      },
    );

    testWidgets('CHK03: Indeterminate checkbox shows dash', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCheckbox(
                value: false,
                indeterminate: true,
                label: const Text('Indeterminate'),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Indeterminate'), findsOneWidget);
        final SemanticsData data = tester
            .getSemantics(find.byType(AnimalCheckbox))
            .getSemanticsData();
        expect(data.flagsCollection.isChecked, CheckedState.mixed);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets(
      'CHK04: FormItem errors remain live beside all checkbox sizes at 200 percent',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          for (final AnimalIslandTheme theme in <AnimalIslandTheme>[
            AnimalIslandTheme.light,
            AnimalIslandTheme.dark,
          ]) {
            for (final (AnimalCheckboxSize size, double boxSize)
                in <(AnimalCheckboxSize, double)>[
                  (AnimalCheckboxSize.small, 18),
                  (AnimalCheckboxSize.middle, 22),
                  (AnimalCheckboxSize.large, 26),
                ]) {
              for (final double textScale in <double>[1, 2]) {
                final AnimalFormController controller = AnimalFormController();
                addTearDown(controller.dispose);
                final AnimalFieldKey<bool> key = AnimalFieldKey<bool>(
                  debugLabel: 'checkbox-error-${size.name}-$textScale',
                );
                const String errorMessage = 'Choose this option';
                await tester.pumpWidget(
                  MaterialApp(
                    localizationsDelegates:
                        AnimalLocalizations.localizationsDelegates,
                    supportedLocales: AnimalLocalizations.supportedLocales,
                    theme: theme.toThemeData(),
                    home: Scaffold(
                      body: MediaQuery(
                        data: MediaQueryData(
                          size: const Size(360, 800),
                          textScaler: TextScaler.linear(textScale),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: AnimalForm(
                            controller: controller,
                            child: AnimalFormItem<bool>(
                              fieldKey: key,
                              label: 'Consent',
                              rules: <AnimalRule<bool>>[
                                AnimalRule<bool>.custom(
                                  (bool? value) =>
                                      value == true ? null : errorMessage,
                                ),
                              ],
                              builder: (context, binding) => AnimalCheckbox(
                                value: binding.value ?? false,
                                size: size,
                                focusNode: binding.focusNode,
                                label: const Text(
                                  'Accept the terms and conditions for this choice',
                                ),
                                onChanged: binding.onChanged,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                expect(await controller.validate(), isFalse);
                await tester.pumpAndSettle();
                final Finder error = find.text(errorMessage);
                expect(error, findsOneWidget);
                final Text errorWidget = tester.widget<Text>(error);
                expect(errorWidget.style!.color, theme.colors.errorText);
                expect(
                  tester
                      .getSemantics(error)
                      .getSemanticsData()
                      .flagsCollection
                      .isLiveRegion,
                  isTrue,
                );
                final Finder checkbox = find.byType(AnimalCheckbox);
                final FocusNode focusNode = tester
                    .widget<AnimalCheckbox>(checkbox)
                    .focusNode!;
                focusNode.requestFocus();
                await tester.pumpAndSettle();
                final Finder control = find.descendant(
                  of: checkbox,
                  matching: find.byType(AnimatedContainer),
                );
                final Finder controlBox = control.last;
                expect(tester.getSize(controlBox), Size(boxSize, boxSize));
                final BoxDecoration controlDecoration =
                    tester.widget<AnimatedContainer>(controlBox).decoration!
                        as BoxDecoration;
                expect(
                  (controlDecoration.border! as Border).top.color,
                  theme.colors.focusYellow,
                );
                final Rect hitRect = tester.getRect(
                  find.descendant(
                    of: checkbox,
                    matching: find.byType(InteractiveRegion),
                  ),
                );
                final Rect controlRect = tester.getRect(controlBox);
                expect(hitRect.width, greaterThanOrEqualTo(48));
                expect(hitRect.height, greaterThanOrEqualTo(48));
                expect(controlRect.width, lessThan(hitRect.width));
                expect(controlRect.height, lessThan(hitRect.height));
                expect(tester.takeException(), isNull);

                controller.setValue(key, true);
                expect(await controller.validate(), isTrue);
                await tester.pumpAndSettle();
                expect(find.text(errorMessage), findsNothing);
                controller.reset();
                await tester.pumpAndSettle();
                expect(
                  tester
                      .widget<AnimalCheckbox>(find.byType(AnimalCheckbox))
                      .value,
                  isFalse,
                );
              }
            }
          }
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'N15 checkbox Enter and Space propose once, and readOnly stays focusable without activation',
      (tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          final FocusNode focusNode = FocusNode();
          addTearDown(focusNode.dispose);
          int calls = 0;
          bool checked = false;
          late StateSetter update;

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    update = setState;
                    return AnimalCheckbox(
                      value: checked,
                      readOnly: calls >= 2,
                      focusNode: focusNode,
                      label: const Text('Controlled check'),
                      onChanged: (bool next) {
                        calls++;
                        update(() => checked = next);
                      },
                    );
                  },
                ),
              ),
            ),
          );

          focusNode.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();
          expect(calls, 1);
          expect(checked, isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pump();
          expect(calls, 2);
          expect(checked, isFalse);

          final SemanticsData readOnlyData = tester
              .getSemantics(find.byType(AnimalCheckbox))
              .getSemanticsData();
          expect(focusNode.hasFocus, isTrue);
          expect(readOnlyData.flagsCollection.isReadOnly, isTrue);
          expect(readOnlyData.hasAction(SemanticsAction.tap), isFalse);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.tap(find.text('Controlled check'));
          await tester.pump();
          expect(calls, 2);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'N15 group snapshots values and options and emits an immutable proposal',
      (tester) async {
        final List<AnimalOption<String>> sourceOptions = <AnimalOption<String>>[
          const AnimalOption<String>(value: 'apple', label: 'Apple'),
        ];
        final List<String> sourceValue = <String>['apple'];
        List<String>? proposal;
        final AnimalCheckboxGroup<String> valueSnapshotGroup =
            AnimalCheckboxGroup<String>(
              value: sourceValue,
              options: sourceOptions,
              onChanged: (_) {},
            );
        sourceValue
          ..clear()
          ..add('pear');
        expect(valueSnapshotGroup.value, <String>['apple']);

        final AnimalCheckboxGroup<String> group = AnimalCheckboxGroup<String>(
          value: const <String>[],
          options: sourceOptions,
          onChanged: (List<String> next) => proposal = next,
        );
        sourceOptions.add(
          const AnimalOption<String>(value: 'pear', label: 'Pear'),
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: group),
          ),
        );
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Pear'), findsNothing);
        await tester.tap(find.text('Apple'));
        await tester.pumpAndSettle();
        expect(proposal, <String>['apple']);
        expect(() => proposal!.add('pear'), throwsUnsupportedError);
        expect(group.value, isEmpty);
        expect(
          tester.widget<AnimalCheckbox>(find.byType(AnimalCheckbox)).value,
          isFalse,
        );
      },
    );

    testWidgets(
      'N15 option keyed focus survives reorder and readOnly groups keep focus without changing',
      (tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          List<AnimalOption<String>> options = const <AnimalOption<String>>[
            AnimalOption<String>(value: 'apple', label: 'Apple'),
            AnimalOption<String>(value: 'pear', label: 'Pear'),
          ];
          late StateSetter update;
          int calls = 0;
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    update = setState;
                    return AnimalCheckboxGroup<String>(
                      value: const <String>[],
                      options: options,
                      readOnly: true,
                      onChanged: (_) => calls++,
                    );
                  },
                ),
              ),
            ),
          );
          final Finder appleFinder = find.byWidgetPredicate(
            (Widget widget) =>
                widget is AnimalCheckbox &&
                widget.label is Text &&
                (widget.label! as Text).data == 'Apple',
          );
          final Finder pearFinder = find.byWidgetPredicate(
            (Widget widget) =>
                widget is AnimalCheckbox &&
                widget.label is Text &&
                (widget.label! as Text).data == 'Pear',
          );
          final FocusNode appleNode = tester
              .widget<AnimalCheckbox>(appleFinder)
              .focusNode!;
          final FocusNode pearNode = tester
              .widget<AnimalCheckbox>(pearFinder)
              .focusNode!;
          expect(identical(appleNode, pearNode), isFalse);
          pearNode.requestFocus();
          await tester.pump();
          expect(pearNode.hasFocus, isTrue);
          await tester.tap(find.text('Apple'));
          await tester.pump();
          expect(calls, 0);
          expect(
            tester
                .getSemantics(pearFinder)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isFalse,
          );

          update(() {
            options = <AnimalOption<String>>[options.last, options.first];
          });
          await tester.pump();
          expect(
            identical(
              pearNode,
              tester.widget<AnimalCheckbox>(pearFinder).focusNode,
            ),
            isTrue,
          );
          update(() => options = <AnimalOption<String>>[options.last]);
          await tester.pumpAndSettle();
          expect(appleNode.hasFocus, isTrue);
          expect(pearNode.hasFocus, isFalse);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets('N15 duplicate option identities fail at construction', (
      tester,
    ) async {
      expect(
        () => AnimalCheckboxGroup<String>(
          value: const <String>[],
          options: const <AnimalOption<String>>[
            AnimalOption<String>(value: 'same', label: 'First'),
            AnimalOption<String>(value: 'same', label: 'Second'),
          ],
          onChanged: (_) {},
        ),
        throwsArgumentError,
      );
    });

    testWidgets(
      'N15 FormItem group children keep independent focus nodes and one registration',
      (tester) async {
        final AnimalFormController checkboxController = AnimalFormController();
        addTearDown(checkboxController.dispose);
        final AnimalFieldKey<List<String>> checkboxKey =
            AnimalFieldKey.list<String>(debugLabel: 'checkboxes');

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: checkboxController,
                child: AnimalFormItem<List<String>>(
                  fieldKey: checkboxKey,
                  initialValue: const <String>[],
                  builder: (BuildContext context, binding) =>
                      AnimalCheckboxGroup<String>(
                        value: binding.value ?? const <String>[],
                        options: const <AnimalOption<String>>[
                          AnimalOption<String>(value: 'first', label: 'First'),
                          AnimalOption<String>(
                            value: 'second',
                            label: 'Second',
                          ),
                        ],
                        onChanged: (_) {},
                        focusNode: binding.focusNode,
                      ),
                ),
              ),
            ),
          ),
        );

        final List<AnimalCheckbox> checkboxes = tester
            .widgetList<AnimalCheckbox>(find.byType(AnimalCheckbox))
            .toList(growable: false);
        expect(checkboxes, hasLength(2));
        expect(
          identical(checkboxes[0].focusNode, checkboxes[1].focusNode),
          isFalse,
          reason: 'FormItem option children have independent focus nodes',
        );
        expect(checkboxController.values.length, 1);
        expect(checkboxController.values.containsKey(checkboxKey), isTrue);

        await tester.pumpWidget(const SizedBox.shrink());
        final AnimalFormController radioController = AnimalFormController();
        addTearDown(radioController.dispose);
        final AnimalFieldKey<String> radioKey = AnimalFieldKey<String>(
          debugLabel: 'radio',
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: radioController,
                child: AnimalFormItem<String>(
                  fieldKey: radioKey,
                  initialValue: 'first',
                  builder: (BuildContext context, binding) =>
                      AnimalRadioGroup<String>(
                        value: binding.value,
                        options: const <AnimalOption<String>>[
                          AnimalOption<String>(value: 'first', label: 'First'),
                          AnimalOption<String>(
                            value: 'second',
                            label: 'Second',
                          ),
                        ],
                        onChanged: (_) {},
                        focusNode: binding.focusNode,
                      ),
                ),
              ),
            ),
          ),
        );

        final List<AnimalRadio<String>> radios = tester
            .widgetList<AnimalRadio<String>>(find.byType(AnimalRadio<String>))
            .toList(growable: false);
        expect(radios, hasLength(2));
        expect(
          identical(radios[0].focusNode, radios[1].focusNode),
          isFalse,
          reason: 'FormItem option children have independent focus nodes',
        );
        expect(radioController.values.length, 1);
        expect(radioController.values.containsKey(radioKey), isTrue);
      },
    );
  });
}
