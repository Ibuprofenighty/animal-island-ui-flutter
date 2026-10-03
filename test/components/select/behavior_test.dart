import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

void main() {
  group('AnimalSelect Tests (C16 / SEL01-SEL04)', () {
    testWidgets(
      'SEL01: Tapping select opens menu and choosing an item updates value',
      (tester) async {
        String? selected = 'option_a';

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalSelect<String>(
                    value: selected,
                    options: const [
                      AnimalOption(value: 'option_a', label: 'Option A'),
                      AnimalOption(value: 'option_b', label: 'Option B'),
                      AnimalOption(
                        value: 'option_c',
                        label: 'Option C',
                        disabled: true,
                      ),
                    ],
                    onChanged: (val) => setState(() => selected = val),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Option A'), findsOneWidget);

        // Tap select trigger to open MenuAnchor
        await tester.tap(find.text('Option A'));
        await tester.pumpAndSettle();

        // Tap Option B
        await tester.tap(find.text('Option B'));
        await tester.pumpAndSettle();

        expect(selected, 'option_b');
        expect(find.text('Option B'), findsOneWidget);
      },
    );

    testWidgets('SEL02: Clear button resets value to null', (tester) async {
      String? selected = 'option_a';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalSelect<String>(
                  value: selected,
                  allowClear: true,
                  options: const [
                    AnimalOption(value: 'option_a', label: 'Option A'),
                    AnimalOption(value: 'option_b', label: 'Option B'),
                  ],
                  onChanged: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear selection'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Clear selection'));
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });

    testWidgets('N15 disabled menu option remains unavailable', (tester) async {
      String? selected = 'option_a';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalSelect<String>(
                  value: selected,
                  options: const [
                    AnimalOption(value: 'option_a', label: 'Option A'),
                    AnimalOption(
                      value: 'option_b',
                      label: 'Option B',
                      disabled: true,
                    ),
                  ],
                  onChanged: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Tap disabled option B
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();

      expect(selected, 'option_a');
    });

    testWidgets(
      'SEL01: Keyboard navigation skips disabled options and Escape restores trigger focus',
      (tester) async {
        final FocusNode triggerFocus = FocusNode();
        addTearDown(triggerFocus.dispose);
        late StateSetter update;
        String? selected = 'a';
        int changes = 0;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  update = setState;
                  return AnimalSelect<String>(
                    value: selected,
                    focusNode: triggerFocus,
                    options: const <AnimalOption<String>>[
                      AnimalOption<String>(value: 'a', label: 'Alpha'),
                      AnimalOption<String>(
                        value: 'blocked',
                        label: 'Blocked',
                        disabled: true,
                      ),
                      AnimalOption<String>(value: 'c', label: 'Charlie'),
                    ],
                    onChanged: (String? value) {
                      changes++;
                      update(() => selected = value);
                    },
                  );
                },
              ),
            ),
          ),
        );

        triggerFocus.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('Blocked'), findsOneWidget);
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(a)',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(c)',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(selected, 'c');
        expect(changes, 1);
        expect(triggerFocus.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(selected, 'c');
        expect(triggerFocus.hasFocus, isTrue);
      },
    );

    testWidgets(
      'SEL01: Outside dismissal restores trigger focus and pending option focus resolves current identity',
      (tester) async {
        final FocusNode triggerFocus = FocusNode();
        addTearDown(triggerFocus.dispose);
        late StateSetter update;
        List<AnimalOption<String>> options = const <AnimalOption<String>>[
          AnimalOption<String>(value: 'a', label: 'Alpha'),
          AnimalOption<String>(value: 'b', label: 'Beta'),
          AnimalOption<String>(value: 'c', label: 'Charlie'),
        ];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox.expand(
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 24,
                      top: 24,
                      width: 240,
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          update = setState;
                          return AnimalSelect<String>(
                            value: 'a',
                            focusNode: triggerFocus,
                            options: options,
                            onChanged: (_) {},
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Outside menu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        triggerFocus.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(a)',
        );

        // The scroll is applied for B, then its key moves before the next
        // frame requests focus. The queued request must follow B by identity.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        update(() {
          options = <AnimalOption<String>>[
            const AnimalOption<String>(value: 'c', label: 'Charlie'),
            const AnimalOption<String>(value: 'a', label: 'Alpha'),
            const AnimalOption<String>(value: 'b', label: 'Beta'),
          ];
        });
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(b)',
        );

        // A second queued request is discarded when its identity is removed.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        update(() {
          options = <AnimalOption<String>>[
            const AnimalOption<String>(value: 'b', label: 'Beta'),
            const AnimalOption<String>(value: 'a', label: 'Alpha'),
          ];
        });
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(b)',
        );

        await tester.tap(find.text('Outside menu'));
        await tester.pumpAndSettle();
        expect(find.text('Beta'), findsNothing);
        expect(triggerFocus.hasFocus, isTrue);
      },
    );

    testWidgets(
      'N15 disabling a focused menu option before activation emits no proposal',
      (tester) async {
        final FocusNode triggerFocus = FocusNode();
        addTearDown(triggerFocus.dispose);
        List<AnimalOption<String>> options = const <AnimalOption<String>>[
          AnimalOption<String>(value: 'a', label: 'Alpha'),
          AnimalOption<String>(value: 'b', label: 'Beta'),
        ];
        final List<String?> proposals = <String?>[];
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
                  return AnimalSelect<String>(
                    value: 'a',
                    focusNode: triggerFocus,
                    options: options,
                    onChanged: proposals.add,
                  );
                },
              ),
            ),
          ),
        );
        triggerFocus.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(b)',
        );

        update(() {
          options = const <AnimalOption<String>>[
            AnimalOption<String>(value: 'a', label: 'Alpha'),
            AnimalOption<String>(value: 'b', label: 'Beta', disabled: true),
          ];
        });
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(a)',
        );
        await tester.tap(find.text('Beta').last);
        await tester.pumpAndSettle();
        expect(proposals, isEmpty);
        expect(find.text('Alpha').first, findsOneWidget);
      },
    );

    testWidgets(
      'SEL02: Keyboard clear emits one null and returns focus after the proposal',
      (tester) async {
        final FocusNode triggerFocus = FocusNode();
        addTearDown(triggerFocus.dispose);
        String? selected = 'a';
        late StateSetter update;
        final List<String?> proposals = <String?>[];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  update = setState;
                  return AnimalSelect<String>(
                    value: selected,
                    allowClear: true,
                    focusNode: triggerFocus,
                    options: const <AnimalOption<String>>[
                      AnimalOption<String>(value: 'a', label: 'Alpha'),
                    ],
                    onChanged: (String? next) {
                      proposals.add(next);
                      update(() => selected = next);
                    },
                  );
                },
              ),
            ),
          ),
        );
        final Finder clear = find.byType(InteractiveRegion).last;
        final Focus clearFocus = tester.widget<Focus>(
          find.descendant(of: clear, matching: find.byType(Focus)),
        );
        clearFocus.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(proposals, <String?>[null]);
        expect(selected, isNull);
        expect(triggerFocus.hasFocus, isTrue);
      },
    );

    testWidgets(
      'N15 Select remains on its caller value when the parent rejects a keyboard proposal',
      (tester) async {
        final FocusNode triggerFocus = FocusNode();
        addTearDown(triggerFocus.dispose);
        String? selected = 'a';
        final List<String?> proposals = <String?>[];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalSelect<String>(
                value: selected,
                focusNode: triggerFocus,
                options: const <AnimalOption<String>>[
                  AnimalOption<String>(value: 'a', label: 'Alpha'),
                  AnimalOption<String>(value: 'b', label: 'Beta'),
                ],
                onChanged: proposals.add,
              ),
            ),
          ),
        );
        triggerFocus.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(proposals, <String?>['b']);
        expect(selected, 'a');
        expect(find.text('Alpha'), findsOneWidget);
      },
    );

    testWidgets(
      'SEL03: Menu stays within viewport corners with keyboard insets and 200 percent long text',
      (tester) async {
        tester.view.physicalSize = const Size(640, 1200);
        tester.view.devicePixelRatio = 2;
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.view.resetViewInsets();
        });
        const String longLabel =
            'A long option label mixes Latin characters with 中文 fallback glyphs across two hundred percent text scaling';
        final List<AnimalOption<String>> options = <AnimalOption<String>>[
          const AnimalOption<String>(value: 'long', label: longLabel),
          const AnimalOption<String>(value: 'short', label: 'Short option'),
        ];

        for (final Alignment alignment in <Alignment>[
          Alignment.topLeft,
          Alignment.topRight,
          Alignment.bottomLeft,
          Alignment.bottomRight,
        ]) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: AnimalIslandTheme.light.toThemeData(),
              builder: (BuildContext context, Widget? child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: Scaffold(
                body: Align(
                  alignment: alignment,
                  child: SizedBox(
                    width: 280,
                    child: AnimalSelect<String>(
                      value: 'long',
                      options: options,
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          );
          final Finder trigger = find.byType(InteractiveRegion).first;
          final InteractiveRegion triggerRegion = tester
              .widget<InteractiveRegion>(trigger);
          expect(triggerRegion.onPressed, isNotNull);
          expect(triggerRegion.disabled, isFalse);
          await tester.tap(trigger);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final MenuAnchor menuAnchor = tester.widget<MenuAnchor>(
            find.byType(MenuAnchor),
          );
          expect(menuAnchor.controller!.isOpen, isTrue);
          expect(find.text(longLabel), findsNWidgets(2));
          final Finder menuViewport = find.byType(ListView);
          expect(menuViewport, findsOneWidget);
          final Rect menuRect = tester.getRect(menuViewport);
          expect(menuRect.left, greaterThanOrEqualTo(0));
          expect(menuRect.top, greaterThanOrEqualTo(0));
          expect(menuRect.right, lessThanOrEqualTo(320));
          expect(menuRect.bottom, lessThanOrEqualTo(440));
          final Finder menuLongLabel = find.text(longLabel).last;
          final Finder menuOption = find.ancestor(
            of: menuLongLabel,
            matching: find.byType(InteractiveRegion),
          );
          final Rect optionRect = tester.getRect(menuOption);
          final RenderParagraph optionParagraph = tester
              .renderObject<RenderParagraph>(menuLongLabel);
          final TextSpan optionSpan = optionParagraph.text as TextSpan;
          final TextPainter twoLineMetrics = TextPainter(
            text: TextSpan(text: 'Ag\nAg', style: optionSpan.style),
            textDirection: optionParagraph.textDirection,
            textScaler: optionParagraph.textScaler,
            maxLines: 2,
            textHeightBehavior: optionParagraph.textHeightBehavior,
          )..layout();
          final TextPainter preferredLineMetrics = TextPainter(
            text: TextSpan(style: optionSpan.style),
            textDirection: optionParagraph.textDirection,
            textScaler: optionParagraph.textScaler,
            maxLines: 2,
            textHeightBehavior: optionParagraph.textHeightBehavior,
          );
          try {
            expect(
              preferredLineMetrics.preferredLineHeight * 2,
              closeTo(twoLineMetrics.height, 1),
            );
            expect(optionParagraph.didExceedMaxLines, isTrue);
            expect(
              optionParagraph.size.height,
              closeTo(twoLineMetrics.height, 1),
            );
          } finally {
            preferredLineMetrics.dispose();
            twoLineMetrics.dispose();
          }
          expect(optionRect.height, greaterThan(76));
          expect(
            optionRect.height,
            greaterThanOrEqualTo(
              optionParagraph.size.height +
                  AnimalIslandTheme.light.spacing.sm * 2,
            ),
          );
          final Rect renderedLabelRect =
              optionParagraph.localToGlobal(Offset.zero) & optionParagraph.size;
          expect(optionRect.contains(renderedLabelRect.topLeft), isTrue);
          expect(
            optionRect.contains(
              renderedLabelRect.bottomRight - const Offset(0.01, 0.01),
            ),
            isTrue,
          );
          expect(find.text(longLabel), findsNWidgets(2));
        }
      },
    );

    testWidgets(
      'SEL03: 1000 options build only a bounded visible menu window',
      (tester) async {
        final List<int> proposals = <int>[];
        final List<AnimalOption<int>> options = <AnimalOption<int>>[
          for (int index = 0; index < 1000; index++)
            AnimalOption<int>(value: index, label: 'Choice $index'),
        ];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Center(
                child: AnimalSelect<int>(
                  value: 0,
                  options: options,
                  onChanged: (int? value) {
                    if (value != null) proposals.add(value);
                  },
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(AnimalSelect<int>));
        await tester.pumpAndSettle();
        final int builtChoiceLabels = find
            .byWidgetPredicate(
              (Widget widget) =>
                  widget is Text &&
                  (widget.data?.startsWith('Choice ') ?? false),
            )
            .evaluate()
            .length;
        expect(builtChoiceLabels, lessThan(24));
        expect(find.text('Choice 999'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(999)',
        );
        expect(find.text('Choice 999'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(proposals, <int>[999]);
        expect(find.text('Choice 0'), findsOneWidget);
      },
    );

    testWidgets(
      'SEL04: Unknown value remains selected as invalid placeholder state',
      (tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          String? selected = 'missing';
          int changes = 0;
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalSelect<String>(
                  value: selected,
                  placeholder: 'Choose one',
                  allowClear: true,
                  options: const <AnimalOption<String>>[
                    AnimalOption<String>(value: 'known', label: 'Known option'),
                  ],
                  onChanged: (String? next) {
                    selected = next;
                    changes++;
                  },
                ),
              ),
            ),
          );
          expect(find.text('Choose one'), findsOneWidget);
          final SemanticsData data = tester
              .getSemantics(find.text('Choose one'))
              .getSemanticsData();
          expect(data.validationResult, SemanticsValidationResult.invalid);
          await tester.tap(find.bySemanticsLabel('Clear selection'));
          await tester.pumpAndSettle();
          expect(selected, isNull);
          expect(changes, 1);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'N15 readOnly and callback-null selects cannot activate or open',
      (tester) async {
        final FocusNode readOnlyFocus = FocusNode();
        final FocusNode nullFocus = FocusNode();
        addTearDown(readOnlyFocus.dispose);
        addTearDown(nullFocus.dispose);
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: <Widget>[
                  AnimalSelect<String>(
                    value: 'a',
                    readOnly: true,
                    allowClear: true,
                    focusNode: readOnlyFocus,
                    options: const <AnimalOption<String>>[
                      AnimalOption<String>(
                        value: 'a',
                        label: 'Read only option',
                      ),
                    ],
                    onChanged: null,
                  ),
                  AnimalSelect<String>(
                    value: 'a',
                    focusNode: nullFocus,
                    options: const <AnimalOption<String>>[
                      AnimalOption<String>(value: 'a', label: 'Null option'),
                    ],
                    onChanged: null,
                  ),
                ],
              ),
            ),
          ),
        );
        readOnlyFocus.requestFocus();
        await tester.pump();
        expect(readOnlyFocus.hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('Read only option'), findsOneWidget);
        expect(find.bySemanticsLabel('Clear selection'), findsNothing);
        expect(nullFocus.hasFocus, isFalse);
        expect(find.text('Null option'), findsOneWidget);
      },
    );

    testWidgets('N15 duplicate option identities fail at construction', (
      tester,
    ) async {
      expect(
        () => AnimalSelect<String>(
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
  });
}
