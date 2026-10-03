import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalRadio & RadioGroup Tests (C15 / RAD01-RAD04)', () {
    testWidgets('RAD01: Standalone radio taps invoke onChanged with value', (
      tester,
    ) async {
      int? selected = 1;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalRadio<int>(
              value: 2,
              groupValue: selected,
              label: const Text('Option 2'),
              onChanged: (val) => selected = val,
            ),
          ),
        ),
      );

      expect(find.text('Option 2'), findsOneWidget);

      await tester.tap(find.byType(AnimalRadio<int>));
      await tester.pumpAndSettle();

      expect(selected, 2);
    });

    testWidgets(
      'RAD01: AnimalRadioGroup enforces mutual exclusivity and respects disabled items',
      (tester) async {
        String? selectedValue = 'pear';

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalRadioGroup<String>(
                    value: selectedValue,
                    options: const [
                      AnimalOption(value: 'pear', label: 'Pear'),
                      AnimalOption(value: 'peach', label: 'Peach'),
                      AnimalOption(
                        value: 'plum',
                        label: 'Plum',
                        disabled: true,
                      ),
                    ],
                    onChanged: (val) => setState(() => selectedValue = val),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Pear'), findsOneWidget);
        expect(find.text('Peach'), findsOneWidget);
        expect(find.text('Plum'), findsOneWidget);

        // Tap Peach -> changes selection to peach
        await tester.tap(find.text('Peach'));
        await tester.pumpAndSettle();
        expect(selectedValue, 'peach');

        // Tap disabled Plum -> ignored
        await tester.tap(find.text('Plum'));
        await tester.pumpAndSettle();
        expect(selectedValue, 'peach');
      },
    );

    testWidgets(
      'RAD03: Renders the current rounded control with an SVG check',
      (tester) async {
        expect(AnimalRadioSize.small.borderRadius, 12);
        expect(AnimalRadioSize.middle.borderRadius, 14);
        expect(AnimalRadioSize.large.borderRadius, 16);
        tester.view.physicalSize = const Size(620, 196);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        const Color activeColor = Color(0xFFB52A92);
        final FocusNode focusedSmall = FocusNode();
        addTearDown(focusedSmall.dispose);
        Widget themeRow(AnimalIslandTheme theme, String key) => Theme(
          data: theme.toThemeData(),
          child: Builder(
            builder: (BuildContext context) => ColoredBox(
              color: theme.colors.bgContent,
              child: SizedBox(
                height: 96,
                child: Row(
                  children: <Widget>[
                    for (final AnimalRadioSize size in AnimalRadioSize.values)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimalRadio<int>(
                              key: ValueKey<String>(
                                '$key-${size.name}-selected',
                              ),
                              value: 1,
                              groupValue: 1,
                              size: size,
                              activeColor: activeColor,
                              focusNode:
                                  key == 'light' &&
                                      size == AnimalRadioSize.small
                                  ? focusedSmall
                                  : null,
                              onChanged: (_) {},
                            ),
                            const SizedBox(width: 8),
                            AnimalRadio<int>(
                              value: 2,
                              groupValue: 1,
                              size: size,
                              activeColor: activeColor,
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
        const ValueKey<String> matrixKey = ValueKey<String>(
          'radio-n15-visual-matrix',
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  key: matrixKey,
                  width: 620,
                  height: 196,
                  child: Column(
                    children: <Widget>[
                      themeRow(AnimalIslandTheme.light, 'light'),
                      themeRow(AnimalIslandTheme.dark, 'dark'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        focusedSmall.requestFocus();
        await tester.pumpAndSettle();
        expect(find.byType(AnimalIcon), findsNWidgets(6));
        final Finder focusedRadio = find.byKey(
          const ValueKey<String>('light-small-selected'),
        );
        final Finder controlFinder = find
            .descendant(
              of: focusedRadio,
              matching: find.byType(AnimatedContainer),
            )
            .last;
        final BoxDecoration focusedDecoration =
            tester.widget<AnimatedContainer>(controlFinder).decoration!
                as BoxDecoration;
        expect(
          tester.getSize(controlFinder),
          Size(AnimalRadioSize.small.boxSize, AnimalRadioSize.small.boxSize),
        );
        expect(focusedDecoration.color, activeColor);
        expect(
          (focusedDecoration.border! as Border).top.color,
          AnimalIslandTheme.light.colors.focusYellow,
        );
        for (final AnimalRadioSize size in AnimalRadioSize.values) {
          final Finder selectedControl = find
              .descendant(
                of: find.byKey(ValueKey<String>('dark-${size.name}-selected')),
                matching: find.byType(AnimatedContainer),
              )
              .last;
          final BoxDecoration decoration =
              tester.widget<AnimatedContainer>(selectedControl).decoration!
                  as BoxDecoration;
          expect(
            tester.getSize(selectedControl),
            Size(size.boxSize, size.boxSize),
          );
          expect(decoration.color, activeColor);
          expect(
            decoration.borderRadius,
            BorderRadius.circular(size.borderRadius),
          );
        }
        await expectLater(
          find.byKey(matrixKey),
          matchesGoldenFile('goldens/animal_radio_n15.png'),
        );
      },
    );

    testWidgets(
      'N15 Arrow Home and End rove one tab stop, skip disabled options, and keep selection controlled',
      (tester) async {
        final FocusNode before = FocusNode();
        final FocusNode after = FocusNode();
        addTearDown(before.dispose);
        addTearDown(after.dispose);
        String? selected = 'a';
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  update = setState;
                  return Column(
                    children: <Widget>[
                      TextButton(
                        focusNode: before,
                        onPressed: () {},
                        child: const Text('Before'),
                      ),
                      AnimalRadioGroup<String>(
                        value: selected,
                        options: const <AnimalOption<String>>[
                          AnimalOption<String>(value: 'a', label: 'A'),
                          AnimalOption<String>(
                            value: 'disabled',
                            label: 'Disabled',
                            disabled: true,
                          ),
                          AnimalOption<String>(value: 'c', label: 'C'),
                        ],
                        onChanged: (String next) =>
                            update(() => selected = next),
                      ),
                      TextButton(
                        focusNode: after,
                        onPressed: () {},
                        child: const Text('After'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        Finder radio(String value) => find.byWidgetPredicate(
          (Widget widget) =>
              widget is AnimalRadio<String> && widget.value == value,
        );
        final FocusNode a = tester
            .widget<AnimalRadio<String>>(radio('a'))
            .focusNode!;
        final FocusNode disabled = tester
            .widget<AnimalRadio<String>>(radio('disabled'))
            .focusNode!;
        final FocusNode c = tester
            .widget<AnimalRadio<String>>(radio('c'))
            .focusNode!;
        expect(a.skipTraversal, isFalse);
        expect(disabled.canRequestFocus, isFalse);
        expect(c.skipTraversal, isTrue);

        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(FocusManager.instance.primaryFocus, same(a));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(FocusManager.instance.primaryFocus, same(after));

        a.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(selected, 'c');
        expect(FocusManager.instance.primaryFocus, same(c));
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expect(selected, 'a');
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(selected, 'c');
        after.requestFocus();
        await tester.pump();
        update(() => selected = 'a');
        await tester.pump();
        before.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(FocusManager.instance.primaryFocus, same(a));
      },
    );

    testWidgets('N15 horizontal radio arrows follow RTL direction', (
      tester,
    ) async {
      String? selected = 'a';
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  update = setState;
                  return AnimalRadioGroup<String>(
                    value: selected,
                    options: const <AnimalOption<String>>[
                      AnimalOption<String>(value: 'a', label: 'A'),
                      AnimalOption<String>(value: 'b', label: 'B'),
                    ],
                    onChanged: (String next) => update(() => selected = next),
                  );
                },
              ),
            ),
          ),
        ),
      );
      final FocusNode a = tester
          .widget<AnimalRadio<String>>(
            find.byWidgetPredicate(
              (Widget widget) =>
                  widget is AnimalRadio<String> && widget.value == 'a',
            ),
          )
          .focusNode!;
      a.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(selected, 'b');
    });

    testWidgets(
      'N15 radio reorder preserves option focus identity and rejected proposals preserve selection',
      (tester) async {
        String selected = 'a';
        List<AnimalOption<String>> options = const <AnimalOption<String>>[
          AnimalOption<String>(value: 'a', label: 'A'),
          AnimalOption<String>(value: 'b', label: 'B'),
        ];
        final List<String> proposals = <String>[];
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  update = setState;
                  return AnimalRadioGroup<String>(
                    value: selected,
                    options: options,
                    onChanged: proposals.add,
                  );
                },
              ),
            ),
          ),
        );
        Finder radio(String identity) => find.byWidgetPredicate(
          (Widget widget) =>
              widget is AnimalRadio<String> && widget.value == identity,
        );
        final FocusNode bNode = tester
            .widget<AnimalRadio<String>>(radio('b'))
            .focusNode!;
        bNode.requestFocus();
        await tester.pump();
        expect(bNode.hasFocus, isTrue);

        final FocusNode aNode = tester
            .widget<AnimalRadio<String>>(radio('a'))
            .focusNode!;
        aNode.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(proposals, <String>['b']);
        expect(selected, 'a');
        expect(tester.widget<AnimalRadio<String>>(radio('a')).groupValue, 'a');
        expect(tester.widget<AnimalRadio<String>>(radio('b')).groupValue, 'a');

        update(() {
          options = <AnimalOption<String>>[options.last, options.first];
        });
        await tester.pumpAndSettle();
        expect(
          identical(
            tester.widget<AnimalRadio<String>>(radio('b')).focusNode,
            bNode,
          ),
          isTrue,
        );
        expect(bNode.hasFocus, isTrue);
        expect(tester.widget<AnimalRadio<String>>(radio('a')).groupValue, 'a');
        expect(proposals, <String>['b']);
      },
    );

    testWidgets(
      'N15 option group focus node cannot be requested when every option is unavailable',
      (tester) async {
        final FocusNode groupNode = FocusNode(
          debugLabel: 'all-disabled-radio-group',
        );
        addTearDown(groupNode.dispose);
        bool disabled = false;
        List<AnimalOption<String>> options = const <AnimalOption<String>>[
          AnimalOption<String>(value: 'a', label: 'A', disabled: true),
        ];
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  update = setState;
                  return AnimalRadioGroup<String>(
                    value: 'a',
                    options: options,
                    disabled: disabled,
                    focusNode: groupNode,
                    onChanged: (_) {},
                  );
                },
              ),
            ),
          ),
        );
        groupNode.requestFocus();
        await tester.pump();
        expect(groupNode.hasFocus, isFalse);
        expect(groupNode.canRequestFocus, isFalse);

        update(() {
          options = const <AnimalOption<String>>[
            AnimalOption<String>(value: 'a', label: 'A'),
          ];
          disabled = true;
        });
        await tester.pump();
        groupNode.requestFocus();
        await tester.pump();
        expect(groupNode.hasFocus, isFalse);
        expect(groupNode.canRequestFocus, isFalse);

        update(() => disabled = false);
        await tester.pump();
        expect(groupNode.canRequestFocus, isTrue);
        groupNode.requestFocus();
        await tester.pump();
        expect(groupNode.hasFocus, isTrue);
      },
    );

    testWidgets('N15 duplicate option identities fail at construction', (
      tester,
    ) async {
      expect(
        () => AnimalRadioGroup<String>(
          value: 'same',
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
      'N15 readOnly radio group with a null callback remains focusable and exposes no activation',
      (tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalRadioGroup<String>(
                  value: 'a',
                  readOnly: true,
                  options: const <AnimalOption<String>>[
                    AnimalOption<String>(value: 'a', label: 'A'),
                    AnimalOption<String>(value: 'b', label: 'B'),
                  ],
                  onChanged: null,
                ),
              ),
            ),
          );
          final Finder firstRadio = find.byWidgetPredicate(
            (Widget widget) =>
                widget is AnimalRadio<String> && widget.value == 'a',
          );
          final FocusNode focusNode = tester
              .widget<AnimalRadio<String>>(firstRadio)
              .focusNode!;
          focusNode.requestFocus();
          await tester.pump();
          expect(focusNode.hasFocus, isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();
          await tester.tap(find.text('A'));
          await tester.pump();
          expect(
            tester
                .getSemantics(firstRadio)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isFalse,
          );
          expect(
            tester
                .getSemantics(firstRadio)
                .getSemanticsData()
                .flagsCollection
                .isReadOnly,
            isTrue,
          );
        } finally {
          semantics.dispose();
        }
      },
    );
  });
}
