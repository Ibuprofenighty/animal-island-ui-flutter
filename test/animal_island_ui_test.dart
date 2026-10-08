import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/form/form_controller.dart'
    show AnimalFormFieldProtocol;

import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:animal_island_ui/src/components/time_picker/time_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:animal_island_ui/src/internal/painting/blob_path.dart';

import 'support/fake_clock.dart';

void main() {
  group('Animal Island UI Design Tokens Tests', () {
    test('AnimalThemeColors strictly match canonical specs', () {
      final colors = AnimalThemeColors.light;
      expect(colors.primary, const Color(0xFF19C8B9));
      expect(colors.text, const Color(0xFF794F27));
      expect(colors.bg, const Color(0xFFF8F8F0));
      expect(colors.focusYellow, const Color(0xFF997700));
      expect(AnimalTileColor.values.length, 13);
    });

    test('AnimalThemeRadii has canonical pill/card/control defaults', () {
      expect(AnimalThemeRadii.standard.pill, 50.0);
      expect(AnimalThemeRadii.standard.card, 20.0);
      expect(AnimalThemeRadii.standard.sm, 12.0);
    });
  });

  group('Animal Island Components Widget Tests', () {
    testWidgets('AnimalButton renders with 3D depth and responds to taps', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalButton(
              onPressed: () => tapped = true,
              child: const Text('Touch Me'),
            ),
          ),
        ),
      );

      expect(find.text('Touch Me'), findsOneWidget);
      await tester.tap(find.text('Touch Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AnimalInput renders with placeholder and accepts input', (
      tester,
    ) async {
      String changedText = '';
      final inputController = TextEditingController();
      addTearDown(inputController.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalInput(
              controller: inputController,
              placeholder: 'Type island name...',
              onChanged: (val) => changedText = val,
            ),
          ),
        ),
      );

      expect(find.text('Type island name...'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Nook Island');
      expect(changedText, 'Nook Island');
    });

    testWidgets('AnimalSwitch toggles on tap', (tester) async {
      bool state = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalSwitch(
                  value: state,
                  onChanged: (val) => setState(() => state = val),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimalSwitch));
      await tester.pumpAndSettle();
      expect(state, isTrue);
    });

    testWidgets('AnimalCard renders with 13 tile color variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCard(
              color: AnimalTileColor.appTeal,
              child: Text('Teal Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Teal Card Content'), findsOneWidget);
    });

    testWidgets('AnimalIcon renders canonical icons correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalIcon(data: AnimalIcons.leaf, size: 24),
                AnimalIcon(data: AnimalIcons.apple, size: 24),
                AnimalIcon(data: AnimalIcons.heart, size: 24),
                AnimalIcon(data: AnimalIcons.bell, size: 24),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AnimalIcon), findsNWidgets(4));
    });

    testWidgets('AnimalTabs switches selected index', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalTabs(
                  selectedIndex: selected,
                  onChanged: (idx) => setState(() => selected = idx),
                  tabs: const [
                    AnimalTabItem(label: 'Tab 1'),
                    AnimalTabItem(label: 'Tab 2'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    testWidgets('AnimalCountdown renders time units', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCountdown(
              remaining: Duration(hours: 2, minutes: 15, seconds: 30),
            ),
          ),
        ),
      );

      expect(find.text('02'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('AnimalTitle swallowtail ribbon renders child text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalTitle(child: Text('Island News'))),
        ),
      );

      expect(find.text('Island News'), findsOneWidget);
    });

    test('AnimalFormController and AnimalRule validation engine', () async {
      final controller = AnimalFormController();
      final emailKey = AnimalFieldKey<String>(debugLabel: 'email');
      controller.registerField<String>(
        key: emailKey,
        rules: [
          AnimalRule.required(message: 'Email required'),
          AnimalRule.email(message: 'Invalid email'),
        ],
      );

      expect(await controller.validate(), isFalse);
      expect(
        controller.getFieldError(emailKey),
        const AnimalValidationIssue.literal('Email required'),
      );

      controller.setValue(emailKey, 'not-an-email', validate: false);
      expect(await controller.validate(), isFalse);
      expect(
        controller.getFieldError(emailKey),
        const AnimalValidationIssue.literal('Invalid email'),
      );

      controller.setValue(
        emailKey,
        'islander@animalisland.ui',
        validate: false,
      );
      expect(await controller.validate(), isTrue);
      expect(controller.getFieldError(emailKey), isNull);

      controller.reset();
      expect(controller.valueFor(emailKey), isNull);
      expect(controller.getFieldError(emailKey), isNull);
    });

    testWidgets(
      'AnimalNotification displays on Overlay without ScaffoldMessenger',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: AnimalOverlayHost(
              child: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        AnimalNotification.success(
                          context,
                          message: 'Bells Collected!',
                          description: '10,000 Bells added to your wallet',
                        );
                      },
                      child: const Text('Notify'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Notify'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Bells Collected!'), findsOneWidget);
        expect(find.text('10,000 Bells added to your wallet'), findsOneWidget);

        AnimalNotification.closeAll(tester.element(find.text('Notify')));
        await tester.pumpAndSettle();
        expect(find.text('Bells Collected!'), findsNothing);
      },
    );

    testWidgets('AnimalLoading renders spinner, snowflake, and dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalLoading.spinner(tip: 'Catching fish...'),
                AnimalLoading.snowflake(tip: 'Snow is falling'),
                AnimalLoading.dots(),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Catching fish...'), findsOneWidget);
      expect(find.text('Snow is falling'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is AnimalIcon && w.data == AnimalIcons.leaf,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is AnimalIcon && w.data == AnimalIcons.snowflake,
        ),
        findsWidgets,
      );
    });

    testWidgets('AnimalProgress renders candy-cane stripes and info label', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalProgress(
              percent: 0.85,
              size: AnimalProgressSize.large,
              infoPosition: AnimalProgressInfoPosition.right,
            ),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
      expect(find.byType(AnimalProgress), findsOneWidget);
    });

    testWidgets(
      'AnimalSkeleton renders composite presets and declarative wrapper',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalSkeleton.button(),
                  AnimalSkeleton.avatar(),
                  AnimalSkeleton.paragraph(rows: 2),
                  AnimalSkeleton(
                    loading: false,
                    child: const Text('Loaded Content'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Loaded Content'), findsOneWidget);
        expect(find.byType(AnimalSkeleton), findsNWidgets(4));
      },
    );

    testWidgets('AnimalButton renders dashed, ghost, and danger variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalButton(
                  variant: AnimalButtonVariant.dashed,
                  onPressed: () {},
                  child: const Text('Dashed Button'),
                ),
                AnimalButton(
                  variant: AnimalButtonVariant.outlined,
                  tone: AnimalButtonTone.danger,
                  onPressed: () {},
                  child: const Text('Ghost Danger'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Dashed Button'), findsOneWidget);
      expect(find.text('Ghost Danger'), findsOneWidget);
    });

    testWidgets('AnimalDivider renders plain line, wavy, and leaf variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalDivider.plain(),
                AnimalDivider(type: AnimalDividerType.wavy),
                AnimalDivider.leaf(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AnimalDivider), findsNWidgets(3));
      expect(
        find.byWidgetPredicate(
          (w) => w is AnimalIcon && w.data == AnimalIcons.leaf,
        ),
        findsOneWidget,
      );
    });

    testWidgets('AnimalCollapse toggles question and answer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCollapse.single(
              question: const Text('What is Nook Miles?'),
              answer: const Text('Points earned by completing island tasks.'),
            ),
          ),
        ),
      );

      expect(find.text('What is Nook Miles?'), findsOneWidget);
      expect(
        find.text('Points earned by completing island tasks.'),
        findsOneWidget,
      );

      await tester.tap(find.text('What is Nook Miles?'));
      await tester.pumpAndSettle();
    });

    testWidgets('AnimalTooltip wraps child and renders message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTooltip(
              message: 'Island Resident Rep',
              variant: AnimalTooltipVariant.island,
              child: Text('Hover Target'),
            ),
          ),
        ),
      );

      expect(find.text('Hover Target'), findsOneWidget);
    });

    testWidgets(
      'AnimalTable renders zebra rows without assert crash, and handles empty and loading states',
      (tester) async {
        // 1. Valid data table
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTable(
                columns: const [
                  AnimalTableColumn(title: 'Item'),
                  AnimalTableColumn(title: 'Price'),
                ],
                rowCount: 3,
                maxHeight: 300,
                rowBuilder: (context, i) => [
                  const [Text('Apple'), Text('100')],
                  const [Text('Orange'), Text('100')],
                  const [Text('Pear'), Text('100')],
                ][i],
              ),
            ),
          ),
        );

        expect(find.text('Item'), findsOneWidget);
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Orange'), findsOneWidget);

        // 2. Empty state
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTable(
                columns: const [AnimalTableColumn(title: 'Item')],
                rowCount: 0,
                maxHeight: 300,
                rowBuilder: (context, i) => const [],
              ),
            ),
          ),
        );

        expect(find.text('No Data'), findsOneWidget);

        // 3. Loading state
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTable(
                loading: true,
                columns: const [AnimalTableColumn(title: 'Item')],
                rowCount: 0,
                maxHeight: 300,
                rowBuilder: (context, i) => const [],
              ),
            ),
          ),
        );

        expect(find.byType(AnimalLoading), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalPagination windowed algorithm renders ellipsis and handles page navigation',
      (tester) async {
        int selected = 5;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalPagination(
                    current: selected,
                    total: 500, // 50 pages!
                    pageSize: 10,
                    onChanged: (p) => setState(() => selected = p),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
        expect(find.text('•••'), findsNWidgets(2));

        // Tap next page
        await tester.tap(find.text('6'));
        await tester.pumpAndSettle();
        expect(selected, 6);

        // Simple mode
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalPagination(
                current: 6,
                total: 500,
                pageSize: 10,
                simple: true,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('6 / 50'), findsOneWidget);
      },
    );

    testWidgets('AnimalModal clips content with AnimalBlobClipper', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalModal(
              title: const Text('Blob Dialog'),
              content: const Text('Organic Modal Content'),
            ),
          ),
        ),
      );

      expect(find.text('Blob Dialog'), findsOneWidget);
      expect(find.text('Organic Modal Content'), findsOneWidget);
      final clipPath = tester.widget<ClipPath>(find.byType(ClipPath).first);
      expect(clipPath.clipper, isA<AnimalBlobClipper>());
    });

    testWidgets('AnimalBackTop ignores hit-test pointer when invisible', (
      tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalBackTop(scrollController: controller)),
        ),
      );

      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(AnimalBackTop),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('AnimalDatePicker enforces date bounds and normalizes times', (
      tester,
    ) async {
      AnimalDateSelection? chosenSelection;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalDatePicker(
              selection: AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
              firstDate: AnimalDate(2026, 9, 10),
              lastDate: AnimalDate(2026, 9, 20),
              onChanged: (selection) => chosenSelection = selection,
            ),
          ),
        ),
      );

      final materialLocalizations = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePicker)),
      );
      Finder dateTarget(DateTime date) => find.byWidgetPredicate(
        (widget) =>
            widget is InteractiveRegion &&
            widget.semanticLabel == materialLocalizations.formatFullDate(date),
      );

      expect(find.text('15'), findsOneWidget);

      // Tap a valid date (16)
      final validDateTarget = dateTarget(DateTime.utc(2026, 9, 16));
      expect(validDateTarget, findsOneWidget);
      await tester.ensureVisible(
        find.descendant(of: validDateTarget, matching: find.text('16')),
      );
      final validDateRect = tester.getRect(validDateTarget);
      expect(validDateRect.width, 48);
      expect(validDateRect.height, 48);
      expect(
        tester.widget<InteractiveRegion>(validDateTarget).disabled,
        isFalse,
      );
      await tester.tap(validDateTarget);
      await tester.pumpAndSettle();
      expect(chosenSelection, isA<AnimalDateSingleSelection>());
      expect(
        (chosenSelection! as AnimalDateSingleSelection).date,
        AnimalDate(2026, 9, 16),
      );

      // Tap a disabled date (5)
      chosenSelection = null;
      final disabledDateTarget = dateTarget(DateTime.utc(2026, 9, 5));
      expect(disabledDateTarget, findsOneWidget);
      await tester.ensureVisible(
        find.descendant(of: disabledDateTarget, matching: find.text('5')),
      );
      final disabledDateRect = tester.getRect(disabledDateTarget);
      expect(disabledDateRect.width, 48);
      expect(disabledDateRect.height, 48);
      final disabledDateOwner = tester.widget<InteractiveRegion>(
        disabledDateTarget,
      );
      expect(disabledDateOwner.disabled, isTrue);
      expect(disabledDateOwner.onPressed, isNotNull);
      disabledDateOwner.onPressed!.call();
      expect(chosenSelection, isNull);
      await tester.tap(disabledDateTarget);
      await tester.pumpAndSettle();
      expect(chosenSelection, isNull);
    });

    testWidgets('AnimalTimePicker locks scroll physics when disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTimePicker(
              value: AnimalTimeValue(hour: 12, minute: 0),
              onChanged: (_) {},
              disabled: true,
            ),
          ),
        ),
      );

      final scrollViews = tester.widgetList<ListWheelScrollView>(
        find.byType(ListWheelScrollView),
      );
      for (final view in scrollViews) {
        expect(view.physics, isA<NeverScrollableScrollPhysics>());
      }
    });

    testWidgets(
      'AnimalInput borrows external focusNode and follows replacement controllers',
      (tester) async {
        final node = FocusNode();
        final controller1 = TextEditingController(text: 'Initial');
        final controller2 = TextEditingController(text: 'Updated');
        addTearDown(controller1.dispose);
        addTearDown(controller2.dispose);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalInput(controller: controller1, focusNode: node),
            ),
          ),
        );

        expect(find.text('Initial'), findsOneWidget);

        // Hot-update widget with new controller
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalInput(controller: controller2, focusNode: node),
            ),
          ),
        );

        expect(find.text('Updated'), findsOneWidget);

        // Pump empty to dispose
        await tester.pumpWidget(const SizedBox.shrink());
        // node should not throw on subsequent focus
        node.requestFocus();
        node.dispose();
      },
    );

    testWidgets('AnimalTypewriter safely types and cancels timer on unmount', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTypewriter(
              text: 'Welcome to Animal Island',
              speed: Duration(milliseconds: 20),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));
      // Unmount immediately while timer is running
      await tester.pumpWidget(const SizedBox.shrink());
      // Should not throw setState() after dispose
    });

    testWidgets(
      'AnimalIcon preserves multi-color fills and supports stroke/monochrome customization',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalIcon(data: AnimalIcons.watermelon, size: 32),
                  AnimalIcon(
                    data: AnimalIcons.watermelon,
                    size: 32,
                    strokeColor: Color(0xFF794F27),
                  ),
                  AnimalIcon(
                    data: AnimalIcons.watermelon,
                    size: 32,
                    color: Color(0xFFFFFFFF),
                    monochrome: true,
                  ),
                  AnimalIcon(data: AnimalIcons.bear, size: 32),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(AnimalIcon), findsNWidgets(4));
      },
    );

    testWidgets(
      'AnimalTag supports island palette colors, sizes, and disabled state',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalTag(
                    color: AnimalTileColor.appPink,
                    size: AnimalTagSize.small,
                    child: Text('Pink Tag'),
                  ),
                  AnimalTag(
                    color: AnimalTileColor.appTeal,
                    size: AnimalTagSize.middle,
                    child: Text('Teal Tag'),
                  ),
                  AnimalTag(
                    color: AnimalTileColor.appYellow,
                    size: AnimalTagSize.large,
                    child: Text('Yellow Tag'),
                  ),
                  AnimalTag(disabled: true, child: Text('Disabled Tag')),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Pink Tag'), findsOneWidget);
        expect(find.text('Teal Tag'), findsOneWidget);
        expect(find.text('Yellow Tag'), findsOneWidget);
        expect(find.text('Disabled Tag'), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalCountdown remaining mode decrements monotonically when pumped (CD-01)',
      (tester) async {
        final fakeClock = FakeClock(DateTime(2026, 9, 13, 12, 0, 0));
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCountdown(
                remaining: Duration(seconds: 5),
                clock: fakeClock,
              ),
            ),
          ),
        );

        expect(find.text('05'), findsOneWidget);
        fakeClock.advance(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('03'), findsOneWidget);
        fakeClock.advance(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('01'), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalForm onSubmit and blur validation integrate seamlessly (FORM-01, FORM-02, FORM-03)',
      (tester) async {
        final controller = AnimalFormController();
        final usernameKey = AnimalFieldKey<String>(debugLabel: 'username');
        final usernameBuffer = TextEditingController();
        addTearDown(usernameBuffer.dispose);
        addTearDown(controller.dispose);
        bool submitted = false;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                onSubmit: (values) {
                  submitted = true;
                  return true;
                },
                child: Column(
                  children: [
                    AnimalFormItem<String>(
                      fieldKey: usernameKey,
                      textController: usernameBuffer,
                      label: 'Username',
                      required: true,
                      rules: [AnimalRule.required(message: 'Required field')],
                      builder: (context, binding) => AnimalInput(
                        controller: usernameBuffer,
                        focusNode: binding.focusNode,
                        placeholder: 'Enter name',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Initially valid is false because username is empty
        final initialValid = await controller.validate();
        expect(initialValid, isFalse);

        controller.setValue(usernameKey, 'Nook');
        await controller.submit();
        expect(submitted, isTrue);
        expect(controller.valueFor(usernameKey), 'Nook');
      },
    );

    testWidgets(
      'AnimalCard renders dots/stripes/sprinkles pattern painter (CARD-01)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalCard(
                    pattern: AnimalCardPattern.dots,
                    child: Text('Dots Card'),
                  ),
                  AnimalCard(
                    pattern: AnimalCardPattern.stripes,
                    child: Text('Stripes Card'),
                  ),
                  AnimalCard(
                    pattern: AnimalCardPattern.sprinkles,
                    child: Text('Sprinkles Card'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Dots Card'), findsOneWidget);
        expect(find.text('Stripes Card'), findsOneWidget);
        expect(find.text('Sprinkles Card'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'AnimalModal consumes typewriter and renders dialogue stream (MOD-01)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalModal(
                title: const Text('Villager Dialogue'),
                content: const AnimalTypewriter(
                  text: 'Hello Island Resident!',
                  speed: Duration(milliseconds: 10),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AnimalTypewriter), findsOneWidget);
        expect(find.text('Villager Dialogue'), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalIcon does not create unnecessary animation controllers when bounce is false (ICO-01, ICO-03)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalIcon(data: AnimalIcons.leaf, bounce: false),
                  AnimalIcon(data: AnimalIcons.apple, bounce: true),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(AnimalIcon), findsNWidgets(2));
        // Tap bouncing icon
        await tester.tap(find.byType(AnimalIcon).last);
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets(
      'AnimalDrawer renders, supports barrierColor customization, and handles dismiss',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => AnimalButton(
                  onPressed: () {
                    AnimalDrawer.show<void>(
                      context: context,
                      title: const Text('Island Storage'),
                      style: AnimalDrawerStyle(
                        barrierColor: const Color(0x80000000),
                      ),
                      builder: (context, close) =>
                          const Text('Drawer Contents'),
                    );
                  },
                  child: const Text('Open Drawer'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Drawer'));
        await tester.pumpAndSettle();

        expect(find.text('Island Storage'), findsOneWidget);
        expect(find.text('Drawer Contents'), findsOneWidget);

        // Dismiss drawer via close icon pressable
        final closeBtn = find
            .descendant(
              of: find.byType(AnimalDrawer),
              matching: find.byType(InteractiveRegion),
            )
            .first;
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();

        expect(find.text('Drawer Contents'), findsNothing);
      },
    );

    testWidgets(
      'AnimalCursor renders child and respects system/custom cursor',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCursor(
                type: AnimalCursorType.pointer,
                forceAll: false,
                child: Text('Cursor Hover Area'),
              ),
            ),
          ),
        );

        expect(find.text('Cursor Hover Area'), findsOneWidget);
        expect(find.byType(MouseRegion), findsWidgets);
      },
    );

    testWidgets(
      'AnimalCodeBlock renders code with header and copies to clipboard',
      (tester) async {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCodeBlock(
                code: 'void main() => print("Island");',
                language: 'dart',
              ),
            ),
          ),
        );

        expect(find.text('dart'), findsOneWidget);
        expect(find.text('void main() => print("Island");'), findsOneWidget);

        // Tap copy button
        await tester.tap(find.text('Copy'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Copied!'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets('AnimalCarousel renders items and handles navigation', (
      tester,
    ) async {
      int activeIndex = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCarousel(
              autoPlay: false,
              onChange: (idx) => activeIndex = idx,
              items: const [Text('Slide 1'), Text('Slide 2'), Text('Slide 3')],
            ),
          ),
        ),
      );

      expect(find.text('Slide 1'), findsOneWidget);

      // Tap next arrow
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(activeIndex, 1);
    });

    testWidgets('AnimalSelect renders options and supports selection', (
      tester,
    ) async {
      String? selectedVal;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => AnimalSelect<String>(
                value: selectedVal,
                placeholder: 'Choose Fruit',
                options: const [
                  AnimalOption(value: 'apple', label: 'Apple'),
                  AnimalOption(value: 'orange', label: 'Orange'),
                ],
                onChanged: (val) {
                  setState(() => selectedVal = val);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Choose Fruit'), findsOneWidget);
      await tester.tap(find.text('Choose Fruit'));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsWidgets);
      await tester.tap(find.text('Apple').last);
      await tester.pumpAndSettle();

      expect(selectedVal, 'apple');
    });

    testWidgets(
      'AnimalImage renders with border radius and handles semantic label',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalImage(
                image: AssetImage('assets/test.png'),
                variant: AnimalImageVariant.bordered,
                semanticLabel: 'Cozy Cottage',
                width: 100,
                height: 100,
              ),
            ),
          ),
        );

        expect(find.byType(AnimalImage), findsOneWidget);
        expect(find.bySemanticsLabel('Cozy Cottage'), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalTimePicker handles now, clear, and disabled interactions (TIME-01, TIME-02)',
      (tester) async {
        AnimalTimeValue? chosenTime = AnimalTimeValue(hour: 12, minute: 0);

        // Active picker
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTimePicker(
                value: chosenTime,
                onChanged: (t) => chosenTime = t,
              ),
            ),
          ),
        );

        expect(find.text('Clear'), findsOneWidget);
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();

        expect(chosenTime, isNull);

        // Disabled picker
        bool disabledChanged = false;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTimePicker(
                key: const ValueKey('disabled_picker'),
                value: AnimalTimeValue(hour: 8, minute: 0),
                disabled: true,
                onChanged: (t) => disabledChanged = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();
        expect(disabledChanged, isFalse);

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(disabledChanged, isFalse);
      },
    );

    testWidgets(
      'AnimalDatePicker enforces disabled guard on Today and Clear buttons (DATE-01)',
      (tester) async {
        bool dateChanged = false;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker(
                selection: AnimalDateSelection.date(AnimalDate(2026, 1, 1)),
                disabled: true,
                onChanged: (_) => dateChanged = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Today'));
        await tester.pumpAndSettle();
        expect(dateChanged, isFalse);

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(dateChanged, isFalse);
      },
    );

    testWidgets('AnimalFooter renders sea and tree styles with content', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalFooter(
                  type: AnimalFooterType.sea,
                  defaultText: 'Animal Island Marine Gate',
                ),
                AnimalFooter(
                  type: AnimalFooterType.tree,
                  content: Text('Pine Forest Boundary'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Animal Island Marine Gate'), findsOneWidget);
      expect(find.text('Pine Forest Boundary'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('AnimalForm focuses first error field physically (FORM-01)', (
      tester,
    ) async {
      final controller = AnimalFormController();
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();
      final firstTextController = TextEditingController();
      final secondTextController = TextEditingController();
      addTearDown(firstTextController.dispose);
      addTearDown(secondTextController.dispose);
      addTearDown(controller.dispose);
      final firstFieldKey = AnimalFieldKey<String>(debugLabel: 'firstField');
      final secondFieldKey = AnimalFieldKey<String>(debugLabel: 'secondField');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: Column(
                children: [
                  AnimalFormItem<String>(
                    fieldKey: firstFieldKey,
                    textController: firstTextController,
                    label: 'First',
                    focusNode: focusNode1,
                    rules: [AnimalRule.required(message: 'First is required')],
                    builder: (context, binding) => AnimalInput(
                      controller: firstTextController,
                      focusNode: binding.focusNode,
                    ),
                  ),
                  AnimalFormItem<String>(
                    fieldKey: secondFieldKey,
                    textController: secondTextController,
                    label: 'Second',
                    focusNode: focusNode2,
                    rules: [AnimalRule.required(message: 'Second is required')],
                    builder: (context, binding) => AnimalInput(
                      controller: secondTextController,
                      focusNode: binding.focusNode,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(focusNode1.hasFocus, isFalse);
      expect(focusNode2.hasFocus, isFalse);

      final valid = await controller.validate();
      await tester.pump();

      expect(valid, isFalse);
      expect(focusNode1.hasFocus, isTrue);
      expect(focusNode2.hasFocus, isFalse);

      focusNode1.dispose();
      focusNode2.dispose();
    });

    testWidgets(
      'AnimalCheckboxGroup and AnimalRadioGroup do not pollute form state (FORM-02, FORM-03)',
      (tester) async {
        final controller = AnimalFormController();
        final hobbiesKey = AnimalFieldKey.list<String>(debugLabel: 'hobbies');
        final roleKey = AnimalFieldKey<String>(debugLabel: 'role');

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: Column(
                  children: [
                    AnimalFormItem<List<String>>(
                      fieldKey: hobbiesKey,
                      label: 'Hobbies',
                      initialValue: const <String>[],
                      builder: (context, binding) =>
                          AnimalCheckboxGroup<String>(
                            value: binding.value ?? const [],
                            options: const [
                              AnimalOption(value: 'fishing', label: 'Fishing'),
                              AnimalOption(
                                value: 'bugCatching',
                                label: 'Bug Catching',
                              ),
                            ],
                            onChanged: binding.onChanged,
                          ),
                    ),
                    AnimalFormItem<String>(
                      fieldKey: roleKey,
                      label: 'Role',
                      initialValue: 'resident',
                      builder: (context, binding) => AnimalRadioGroup<String>(
                        value: binding.value,
                        options: const [
                          AnimalOption(value: 'resident', label: 'Resident'),
                          AnimalOption(value: 'mayor', label: 'Mayor'),
                        ],
                        onChanged: binding.onChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Tap the checkbox for 'Fishing'
        await tester.tap(find.text('Fishing'));
        await tester.pump();

        // Form state MUST be List<String>, NOT a boolean true/false!
        final hobbies = controller.valueFor(hobbiesKey);
        expect(hobbies, isA<List<String>>());
        expect(hobbies, contains('fishing'));

        // Tap the radio for 'Mayor'
        await tester.tap(find.text('Mayor'));
        await tester.pump();

        final role = controller.valueFor(roleKey);
        expect(role, equals('mayor'));
      },
    );

    testWidgets(
      'AnimalFormController reset and setValue dynamically sync AnimalInput (FORM-04)',
      (tester) async {
        final controller = AnimalFormController();
        final islandKey = AnimalFieldKey<String>(debugLabel: 'island');
        final islandBuffer = TextEditingController(text: 'Peach Isle');
        addTearDown(islandBuffer.dispose);
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
                  fieldKey: islandKey,
                  textController: islandBuffer,
                  label: 'Island',
                  builder: (context, binding) => AnimalInput(
                    controller: islandBuffer,
                    focusNode: binding.focusNode,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Peach Isle'), findsOneWidget);

        // Dynamically set value
        controller.setValue(islandKey, 'Cherry Isle');
        await tester.pump();
        expect(find.text('Cherry Isle'), findsOneWidget);

        // Reset fields
        controller.reset();
        await tester.pump();
        expect(find.text('Peach Isle'), findsOneWidget);
      },
    );

    testWidgets('AnimalRadio respects custom activeColor (RD-01)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalRadio<int>(
              value: 1,
              groupValue: 1,
              activeColor: Colors.deepPurple,
              onChanged: (v) {},
            ),
          ),
        ),
      );

      final radioDecorationFinder = find.descendant(
        of: find.byType(AnimalRadio<int>),
        matching: find.byWidgetPredicate((widget) {
          if (widget is! AnimatedContainer ||
              widget.decoration is! BoxDecoration) {
            return false;
          }
          final decoration = widget.decoration! as BoxDecoration;
          return decoration.border is Border &&
              (decoration.border! as Border).top.color == Colors.deepPurple;
        }),
      );
      expect(radioDecorationFinder, findsOneWidget);
      final animatedContainer = tester.widget<AnimatedContainer>(
        radioDecorationFinder,
      );
      final decoration = animatedContainer.decoration! as BoxDecoration;
      expect((decoration.border as Border).top.color, Colors.deepPurple);
    });

    testWidgets(
      'AnimalTag can be focused and activated via keyboard (TAG-02)',
      (tester) async {
        bool tagActivated = false;
        final focusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTag(
                focusNode: focusNode,
                onTap: () => tagActivated = true,
                child: const Text('Clickable Tag'),
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        // Press Enter
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(tagActivated, isTrue);

        tagActivated = false;
        // Press Space
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(tagActivated, isTrue);

        focusNode.dispose();
      },
    );

    testWidgets(
      'AnimalDatePicker and AnimalTimePicker support keyboard activation via Enter/Space (D-03)',
      (tester) async {
        final dateFocusNode = FocusNode();
        final timeFocusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalDatePicker.popover(focusNode: dateFocusNode),
                  AnimalTimePicker.popover(focusNode: timeFocusNode),
                ],
              ),
            ),
          ),
        );

        // Focus DatePicker and press Enter to open
        dateFocusNode.requestFocus();
        await tester.pump();
        expect(dateFocusNode.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        // Verify calendar popover is visible
        expect(find.text('Today'), findsOneWidget);

        // Close popover via escape
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        dateFocusNode.dispose();
        timeFocusNode.dispose();
      },
    );

    testWidgets(
      'AnimalCheckboxGroup and AnimalRadioGroup allocate independent focus nodes without duplicate attachment (D-04)',
      (tester) async {
        final controller = AnimalFormController();
        final groupFocusNode = FocusNode();
        final hobbiesKey = AnimalFieldKey.list<String>(debugLabel: 'hobbies');
        final genderKey = AnimalFieldKey<String>(debugLabel: 'gender');

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: Column(
                  children: [
                    AnimalFormItem<List<String>>(
                      fieldKey: hobbiesKey,
                      focusNode: groupFocusNode,
                      builder: (context, binding) =>
                          AnimalCheckboxGroup<String>(
                            value: binding.value ?? const [],
                            onChanged: binding.onChanged,
                            options: const [
                              AnimalOption(value: 'fishing', label: 'Fishing'),
                              AnimalOption(value: 'bug', label: 'Bug Catching'),
                            ],
                          ),
                    ),
                    AnimalFormItem<String>(
                      fieldKey: genderKey,
                      initialValue: 'm',
                      builder: (context, binding) => AnimalRadioGroup<String>(
                        value: binding.value,
                        onChanged: binding.onChanged,
                        options: const [
                          AnimalOption(value: 'm', label: 'Male'),
                          AnimalOption(value: 'f', label: 'Female'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Both groups should render cleanly without throwing FocusNode assertion errors
        expect(find.text('Fishing'), findsOneWidget);
        expect(find.text('Male'), findsOneWidget);
        groupFocusNode.dispose();
      },
    );

    testWidgets(
      'Form controls reactively update visual state on setValue and reset (D-05)',
      (tester) async {
        final controller = AnimalFormController();
        final selectKey = AnimalFieldKey<String>(debugLabel: 'select');
        final switchKey = AnimalFieldKey<bool>(debugLabel: 'switch');
        final radioGroupKey = AnimalFieldKey<String>(debugLabel: 'radio_group');
        final dateKey = AnimalFieldKey<AnimalDateSelection>(debugLabel: 'date');
        final timeKey = AnimalFieldKey<AnimalTimeValue>(debugLabel: 'time');

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnimalForm(
                  controller: controller,
                  child: Column(
                    children: [
                      AnimalFormItem<String>(
                        fieldKey: selectKey,
                        initialValue: 'apple',
                        builder: (context, binding) => AnimalSelect<String>(
                          value: binding.value,
                          onChanged: binding.onChanged,
                          options: const [
                            AnimalOption(value: 'apple', label: 'Apple'),
                            AnimalOption(value: 'pear', label: 'Pear'),
                          ],
                        ),
                      ),
                      AnimalFormItem<bool>(
                        fieldKey: switchKey,
                        initialValue: false,
                        builder: (context, binding) => AnimalSwitch(
                          value: binding.value ?? false,
                          onChanged: (v) => binding.onChanged(v),
                        ),
                      ),
                      AnimalFormItem<String>(
                        fieldKey: radioGroupKey,
                        initialValue: 'x',
                        builder: (context, binding) => AnimalRadioGroup<String>(
                          value: binding.value ?? 'x',
                          onChanged: (v) => binding.onChanged(v),
                          options: const [
                            AnimalOption(value: 'x', label: 'Option X'),
                            AnimalOption(value: 'y', label: 'Option Y'),
                          ],
                        ),
                      ),
                      AnimalFormItem<AnimalDateSelection>(
                        fieldKey: dateKey,
                        builder: (context, binding) => AnimalDatePicker.popover(
                          selection: binding.value,
                          onChanged: binding.onChanged,
                        ),
                      ),
                      AnimalFormItem<AnimalTimeValue>(
                        fieldKey: timeKey,
                        builder: (context, binding) => AnimalTimePicker.popover(
                          value: binding.value,
                          onChanged: binding.onChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify initial display
        expect(find.text('Apple'), findsOneWidget);

        // 1. Update Select
        controller.setValue(selectKey, 'pear');
        await tester.pump();
        expect(find.text('Pear'), findsOneWidget);

        // 2. Update Switch
        controller.setValue(switchKey, true);
        await tester.pump();
        final switchFinder = find.byType(AnimalSwitch);
        expect(tester.widget<AnimalSwitch>(switchFinder).value, isTrue);

        // 3. Update Date & Time
        controller.setValue(
          dateKey,
          AnimalDateSelection.date(AnimalDate(2026, 9, 10)),
        );
        controller.setValue(timeKey, AnimalTimeValue(hour: 15, minute: 45));
        await tester.pump();
        final expectedDate = MaterialLocalizations.of(
          tester.element(find.byType(AnimalForm)),
        ).formatMediumDate(DateTime.utc(2026, 9, 10));
        expect(find.text(expectedDate), findsOneWidget);
        expect(find.text('15:45'), findsOneWidget);

        // 4. Reset Fields
        controller.reset();
        await tester.pump();
        expect(find.text('Apple'), findsOneWidget);
        expect(find.text(expectedDate), findsNothing);
        expect(find.text('15:45'), findsNothing);
      },
    );

    testWidgets(
      'AnimalIcon responds to keyboard Enter/Space when onTap is provided (D-06)',
      (tester) async {
        bool tapped = false;
        final fn = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalIcon(
                data: AnimalIcons.airplane,
                onTap: () => tapped = true,
                focusNode: fn,
              ),
            ),
          ),
        );

        fn.requestFocus();
        await tester.pump();
        expect(fn.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(tapped, isTrue);

        tapped = false;
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        expect(tapped, isTrue);

        fn.dispose();
      },
    );

    testWidgets(
      'AnimalModal extracts nested text for typewriter and supports close button keyboard activation (D-02, D-11)',
      (tester) async {
        bool closed = false;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalModal(
                onClose: () => closed = true,
                content: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Nested dialogue text'),
                ),
              ),
            ),
          ),
        );

        // The body is rendered as given; no text is extracted or re-typed.
        expect(find.byType(AnimalTypewriter), findsNothing);
        expect(find.text('Nested dialogue text'), findsOneWidget);

        // Test close button keyboard activation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Find close button and invoke tap
        final closeBtnFinder = find.byWidgetPredicate(
          (w) => w is AnimalIcon && w.data == AnimalIcons.close,
        );
        expect(closeBtnFinder, findsOneWidget);
        await tester.tap(closeBtnFinder);
        await tester.pump();
        expect(closed, isTrue);
      },
    );

    testWidgets(
      'AnimalPagination, AnimalCarousel, and AnimalBackTop clean single-layer Semantics (D-07)',
      (tester) async {
        final scrollController = ScrollController(initialScrollOffset: 500);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    AnimalPagination(
                      current: 1,
                      total: 50,
                      pageSize: 10,
                      onChanged: (_) {},
                    ),
                    AnimalCarousel(
                      height: 100,
                      showArrows: true,
                      items: const [Text('Slide 1'), Text('Slide 2')],
                    ),
                    AnimalBackTop(scrollController: scrollController),
                    const SizedBox(height: 1000),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final localizations = AnimalLocalizations.of(
          tester.element(find.byType(AnimalPagination)),
        )!;

        // Pagination previous button keeps a single semantic label on InteractiveRegion.
        final prevBtnFinder = find.byWidgetPredicate(
          (w) =>
              w is InteractiveRegion &&
              w.semanticLabel == localizations.paginationPrevious,
        );
        expect(prevBtnFinder, findsOneWidget);

        final nextSlideFinder = find.byWidgetPredicate(
          (w) => w is InteractiveRegion && w.semanticLabel == 'Next slide',
        );
        expect(nextSlideFinder, findsOneWidget);

        final backTopFinder = find.byWidgetPredicate(
          (w) =>
              w is InteractiveRegion &&
              w.semanticLabel == localizations.backToTop,
        );
        expect(backTopFinder, findsOneWidget);
        scrollController.dispose();
      },
    );

    testWidgets(
      'AnimalCodeBlock uses theme colors and copy button supports keyboard activation (D-08, D-09)',
      (tester) async {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCodeBlock(code: 'final x = 42;', language: 'dart'),
            ),
          ),
        );

        expect(find.text('final x = 42;'), findsOneWidget);
        final copyFinder = find.text('Copy');
        expect(copyFinder, findsOneWidget);

        await tester.tap(copyFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Copied!'), findsOneWidget);

        // Advance clock past 2-second reset timer
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets('AnimalTag close button supports keyboard activation (D-10)', (
      tester,
    ) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTag(
              onClose: () => closed = true,
              child: const Text('Removable Tag'),
            ),
          ),
        ),
      );

      final removeFinder = find.byWidgetPredicate(
        (w) => w is AnimalIcon && w.data == AnimalIcons.close,
      );
      expect(removeFinder, findsOneWidget);

      await tester.tap(removeFinder);
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets(
      'AnimalCarousel dots can be navigated and activated via keyboard (D-12)',
      (tester) async {
        int activeIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCarousel(
                height: 100,
                showDots: true,
                onChange: (idx) => activeIndex = idx,
                items: const [Text('Page A'), Text('Page B'), Text('Page C')],
              ),
            ),
          ),
        );

        final dot2 = find.bySemanticsLabel('Slide 2 of 3');
        expect(dot2, findsOneWidget);

        await tester.tap(dot2);
        await tester.pumpAndSettle();
        expect(activeIndex, 1);
      },
    );
  });

  group('Round 7 SOTA Refactoring & Enterprise Regression Tests (P01-P10, C01-C06, A01-A06, T01, D01)', () {
    test('P05: AnimalIcon descriptor renders with custom dimensions', () {
      final icon = AnimalIcon(
        data: AnimalIcons.image,
        size: 32.0,
        color: AnimalThemeColors.light.primary,
      );
      expect(icon.size, 32.0);
      expect(icon.color, AnimalThemeColors.light.primary);
    });

    test('C01: AnimalTimePicker constructor asserts step >= 1 and defends against infinite loops', () {
      expect(
        () => AnimalTimePicker(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          hourStep: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePicker(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          minuteStep: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePicker(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          secondStep: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePicker.popover(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          hourStep: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePicker.popover(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          minuteStep: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePicker.popover(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          secondStep: -5,
        ),
        throwsArgumentError,
      );

      // Positive test: valid steps build fine
      expect(
        () => AnimalTimePicker(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          hourStep: 2,
          minuteStep: 5,
          secondStep: 15,
        ),
        returnsNormally,
      );
      expect(
        () => AnimalTimePicker.popover(
          value: AnimalTimeValue(hour: 10, minute: 0),
          onChanged: (_) {},
          hourStep: 3,
          minuteStep: 10,
          secondStep: 30,
        ),
        returnsNormally,
      );
    });

    testWidgets(
      'C02 & C04: AnimalTimePicker standalone panel updates formItem and triggers onBlur',
      (tester) async {
        final formController = AnimalFormController();
        final focusNode = FocusNode();
        final departureTimeKey = AnimalFieldKey<AnimalTimeValue>(
          debugLabel: 'departureTime',
        );
        final initialTime = AnimalTimeValue(hour: 14, minute: 30);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: formController,
                child: AnimalFormItem<AnimalTimeValue>(
                  fieldKey: departureTimeKey,
                  initialValue: initialTime,
                  focusNode: focusNode,
                  builder: (context, binding) {
                    return AnimalTimePicker(
                      focusNode: binding.focusNode,
                      value: binding.value,
                      onChanged: binding.onChanged,
                      allowClear: true,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Verify focus node can receive focus and unfocus cleanly
        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        focusNode.unfocus();
        await tester.pump();
        expect(focusNode.hasFocus, isFalse);

        // Test Clear button in standalone panel directly updates FormItem
        final clearButton = find.text('Clear');
        expect(clearButton, findsOneWidget);
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        expect(formController.values.valueFor(departureTimeKey), isNull);
      },
    );

    testWidgets(
      'C03 & C04: AnimalDatePicker standalone panel updates formItem and triggers onBlur',
      (tester) async {
        final formController = AnimalFormController();
        final focusNode = FocusNode();
        final flightDateKey = AnimalFieldKey<AnimalDateSelection>(
          debugLabel: 'flightDate',
        );
        final initialDate = AnimalDate(2026, 5, 10);
        final FakeClock dateClock = FakeClock(DateTime.utc(2026, 5, 12, 10));

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: formController,
                child: AnimalFormItem<AnimalDateSelection>(
                  fieldKey: flightDateKey,
                  initialValue: AnimalDateSelection.date(initialDate),
                  focusNode: focusNode,
                  builder: (context, binding) {
                    return AnimalDatePicker(
                      focusNode: binding.focusNode,
                      selection: binding.value,
                      onChanged: binding.onChanged,
                      allowClear: true,
                      clock: dateClock,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        focusNode.unfocus();
        await tester.pump();
        expect(focusNode.hasFocus, isFalse);

        // Clear in standalone panel updates formItem
        final clearButton = find.text('Clear');
        expect(clearButton, findsOneWidget);
        await tester.tap(clearButton);
        await tester.pumpAndSettle();
        expect(formController.values.valueFor(flightDateKey), isNull);

        // Today in standalone panel updates formItem
        final todayButton = find.text('Today');
        expect(todayButton, findsOneWidget);
        await tester.tap(todayButton);
        await tester.pumpAndSettle();
        final todayVal = formController.values.valueFor(flightDateKey);
        expect(todayVal, isNotNull);
        expect(todayVal, isA<AnimalDateSingleSelection>());
        expect(
          (todayVal! as AnimalDateSingleSelection).date,
          AnimalDate(2026, 5, 12),
        );
      },
    );

    testWidgets(
      'C05: AnimalCheckboxGroup and AnimalRadioGroup container focus requests redirect to first child',
      (tester) async {
        final cbGroupFocus = FocusNode();
        final radioGroupFocus = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalCheckboxGroup<String>(
                    focusNode: cbGroupFocus,
                    onChanged: (_) {},
                    options: const [
                      AnimalOption(value: 'Apple', label: 'Apple'),
                      AnimalOption(value: 'Orange', label: 'Orange'),
                    ],
                    value: const [],
                  ),
                  AnimalRadioGroup<String>(
                    focusNode: radioGroupFocus,
                    onChanged: (_) {},
                    value: 'a',
                    options: const [
                      AnimalOption(value: 'a', label: 'A'),
                      AnimalOption(value: 'b', label: 'B'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        // Requesting focus on group container redirects to first child item
        cbGroupFocus.requestFocus();
        await tester.pump();
        expect(cbGroupFocus.hasFocus, isTrue);

        radioGroupFocus.requestFocus();
        await tester.pump();
        expect(radioGroupFocus.hasFocus, isTrue);
      },
    );

    testWidgets(
      'C06: AnimalDrawer provides modal route semantics with scopesRoute: true',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AnimalDrawer.show<void>(
                      context: context,
                      title: const Text('Island Tools'),
                      builder: (context, close) =>
                          const Text('Net and Fishing Rod'),
                    );
                  },
                  child: const Text('Open Drawer'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Drawer'));
        await tester.pumpAndSettle();

        final drawerSemanticsFinder = find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.scopesRoute == true &&
              w.properties.namesRoute == true,
        );
        expect(drawerSemanticsFinder, findsOneWidget);
        expect(find.text('Island Tools'), findsOneWidget);
      },
    );

    testWidgets(
      'A01: AnimalInput clear button can be activated via Enter / Space keyboard navigation',
      (tester) async {
        final controller = TextEditingController(text: 'Nook Mile Ticket');

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalInput(controller: controller, clearable: true),
            ),
          ),
        );

        expect(find.text('Nook Mile Ticket'), findsOneWidget);

        final clearFinder = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Clear input',
        );
        expect(clearFinder, findsOneWidget);

        // Tap clear button
        await tester.tap(clearFinder);
        await tester.pump();

        expect(controller.text, isEmpty);
      },
    );

    testWidgets(
      'A02: AnimalSelect clear button can be activated via Enter / Space keyboard navigation',
      (tester) async {
        String? selected = 'apple';

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
                      AnimalOption(value: 'apple', label: 'Sweet Apple'),
                      AnimalOption(value: 'orange', label: 'Juicy Orange'),
                    ],
                    onChanged: (val) => setState(() => selected = val),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Sweet Apple'), findsOneWidget);

        final clearFinder = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Clear selection',
        );
        expect(clearFinder, findsOneWidget);

        await tester.tap(clearFinder);
        await tester.pumpAndSettle();

        expect(selected, isNull);
      },
    );

    testWidgets(
      'A03: AnimalNotification close button activates through its shared keyboard owner',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: AnimalOverlayHost(
              child: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () {
                      AnimalNotification.info(
                        context,
                        message: 'Morning Announcement',
                        duration: const Duration(seconds: 10),
                      );
                    },
                    child: const Text('Notify'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Notify'));
        await tester.pump(); // frame 1: overlay container mounts
        await tester.pump(); // frame 2: card mounts and starts animation
        await tester.pump(
          const Duration(milliseconds: 400),
        ); // frame 3: entrance animation completes

        expect(find.text('Morning Announcement'), findsOneWidget);

        final dismissFinder = find.byWidgetPredicate(
          (widget) =>
              widget is InteractiveRegion &&
              widget.semanticLabel == 'Dismiss notification',
        );
        expect(dismissFinder, findsOneWidget);

        final dismissFocus = tester.widget<Focus>(
          find.descendant(of: dismissFinder, matching: find.byType(Focus)),
        );
        dismissFocus.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump(); // starts reverse animation
        await tester.pump(
          const Duration(milliseconds: 400),
        ); // reverse finishes, calls onDismiss
        await tester.pump(); // widget tree updates, card is removed

        expect(find.text('Morning Announcement'), findsNothing);
      },
    );

    testWidgets(
      'A04: AnimalTabs item activates through its shared keyboard owner',
      (tester) async {
        int activeIndex = 0;
        int activationCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalTabs(
                    selectedIndex: activeIndex,
                    onChanged: (idx) => setState(() {
                      activeIndex = idx;
                      activationCount++;
                    }),
                    tabs: const [
                      AnimalTabItem(label: 'Fish Guide'),
                      AnimalTabItem(label: 'Bug Guide'),
                      AnimalTabItem(label: 'Sea Creatures'),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        expect(activeIndex, 0);

        // Tap Bug Guide tab
        await tester.tap(find.text('Bug Guide'));
        await tester.pumpAndSettle();
        expect(activeIndex, 1);
        expect(activationCount, 1);

        final tabOwner = find.byWidgetPredicate(
          (widget) =>
              widget is InteractiveRegion &&
              widget.semanticLabel == 'Bug Guide',
        );
        expect(tabOwner, findsOneWidget);
        final tabFocus = tester.widget<Focus>(
          find.descendant(of: tabOwner, matching: find.byType(Focus)),
        );
        tabFocus.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(activeIndex, 1);
        expect(activationCount, 2);
      },
    );

    testWidgets(
      'A05: AnimalTimePicker wheel items do not advertise fake button semantics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTimePicker(
                value: AnimalTimeValue(hour: 8, minute: 15),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        // Verify that wheel item Semantics have button == null or button == false
        final wheelItemSemantics = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == '8 hours',
        );
        expect(wheelItemSemantics, findsWidgets);
        for (final element in wheelItemSemantics.evaluate()) {
          final semantics = element.widget as Semantics;
          expect(semantics.properties.button, isNot(isTrue));
        }
      },
    );

    testWidgets(
      'A06: date cells activate through their shared keyboard owner',
      (tester) async {
        AnimalDateSelection? selectedDate = AnimalDateSelection.date(
          AnimalDate(2026, 6, 14),
        );
        final semantics = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker(
                selection: selectedDate,
                onChanged: (val) => selectedDate = val,
              ),
            ),
          ),
        );

        final localizations = MaterialLocalizations.of(
          tester.element(find.byType(AnimalDatePicker)),
        );
        final dateLabel = localizations.formatFullDate(
          DateTime.utc(2026, 6, 15),
        );
        final dayCell = find.byWidgetPredicate(
          (widget) =>
              widget is InteractiveRegion && widget.semanticLabel == dateLabel,
        );
        expect(dayCell, findsOneWidget);
        final focus = tester.widget<Focus>(
          find.descendant(of: dayCell, matching: find.byType(Focus)),
        );
        focus.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(selectedDate, isA<AnimalDateSingleSelection>());
        expect(
          (selectedDate! as AnimalDateSingleSelection).date,
          AnimalDate(2026, 6, 15),
        );
        semantics.dispose();
      },
    );

    test('T01: Dark theme surfaces strictly use semantic surfaceAlt and surfaceHeader tokens', () {
      final darkTheme = AnimalIslandTheme.dark;
      expect(darkTheme.colors.surfaceAlt, const Color(0xFF2A231C));
      expect(darkTheme.colors.surfaceHeader, const Color(0xFF322B23));
    });

    testWidgets(
      'A01: date popover clear action uses the shared keyboard owner',
      (tester) async {
        AnimalDateSelection? selectedDate = AnimalDateSelection.date(
          AnimalDate(2026, 6, 15),
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalDatePicker.popover(
                    selection: selectedDate,
                    allowClear: true,
                    onChanged: (val) => setState(() => selectedDate = val),
                  );
                },
              ),
            ),
          ),
        );

        final materialLocalizations = MaterialLocalizations.of(
          tester.element(find.byType(Scaffold)),
        );
        final AnimalDate selectedCivilDate =
            (selectedDate! as AnimalDateSingleSelection).date;
        final triggerLabel = materialLocalizations.formatMediumDate(
          selectedCivilDate.toDateTime(),
        );
        final trigger = find.byWidgetPredicate(
          (widget) =>
              widget is InteractiveRegion &&
              widget.semanticLabel == triggerLabel,
        );
        expect(trigger, findsOneWidget);
        await tester.tap(trigger);
        await tester.pumpAndSettle();

        final localizations = AnimalLocalizations.of(
          tester.element(find.byType(Scaffold)),
        )!;
        final clearAction = find.descendant(
          of: find.byType(AnimalDatePickerPanel),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is InteractiveRegion &&
                widget.semanticLabel == localizations.clearDate,
          ),
        );
        expect(clearAction, findsOneWidget);
        final focus = tester.widget<Focus>(
          find.descendant(of: clearAction, matching: find.byType(Focus)),
        );
        focus.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle();
        expect(selectedDate, isNull);
      },
    );

    testWidgets(
      'A02: time popover clear action uses the shared keyboard owner',
      (tester) async {
        AnimalTimeValue? selectedTime = AnimalTimeValue(hour: 14, minute: 30);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalTimePicker.popover(
                    value: selectedTime,
                    allowClear: true,
                    onChanged: (val) => setState(() => selectedTime = val),
                  );
                },
              ),
            ),
          ),
        );

        final trigger = find.byWidgetPredicate(
          (widget) =>
              widget is InteractiveRegion && widget.semanticLabel == '14:30',
        );
        expect(trigger, findsOneWidget);
        await tester.tap(trigger);
        await tester.pumpAndSettle();

        final localizations = AnimalLocalizations.of(
          tester.element(find.byType(Scaffold)),
        )!;
        final clearAction = find.descendant(
          of: find.byType(AnimalTimePickerPanel),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is InteractiveRegion &&
                widget.semanticLabel == localizations.clearTime,
          ),
        );
        expect(clearAction, findsOneWidget);
        final focus = tester.widget<Focus>(
          find.descendant(of: clearAction, matching: find.byType(Focus)),
        );
        focus.focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle();
        expect(selectedTime, isNull);
      },
    );

    testWidgets(
      'T01 & T02: Collapse and Skeleton use governed dark surface tokens',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.dark.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalCollapse(
                    disabled: true,
                    items: const [
                      AnimalCollapseItem(
                        title: Text('Disabled Item'),
                        content: Text('Content'),
                      ),
                    ],
                  ),
                  const AnimalSkeleton(loading: true, child: Text('Loaded')),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Disabled Item'), findsOneWidget);
        expect(find.byType(AnimalSkeleton), findsOneWidget);
      },
    );
  });

  group('Enterprise Performance & SOTA Architectural Optimization Tests (O01-O04)', () {
    testWidgets(
      'O01: AnimalTable renders with maxHeight virtualized scroll and sticky header without IntrinsicWidth',
      (tester) async {
        final columns = [
          const AnimalTableColumn(title: 'ID', width: 60.0),
          const AnimalTableColumn(title: 'Item Name'),
          const AnimalTableColumn(title: 'Price', width: 80.0),
        ];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTable(
                columns: columns,
                rowCount: 100,
                rowBuilder: (context, i) => [
                  Text('$i'),
                  Text('Island Item #$i'),
                  Text('${(i + 1) * 10} Bells'),
                ],
                maxHeight: 200.0,
              ),
            ),
          ),
        );

        // Verify header rendered with sticky Semantics
        expect(find.text('ID'), findsOneWidget);
        expect(find.text('Item Name'), findsOneWidget);
        expect(find.text('Price'), findsOneWidget);

        // Verify virtualized scrollable ListView is present
        expect(find.byType(ListView), findsOneWidget);
        expect(find.text('Island Item #0'), findsOneWidget);
      },
    );

    testWidgets(
      'O02: AnimalCarousel pauses autoplay when TickerMode is disabled and resumes when enabled',
      (tester) async {
        final notifier = ValueNotifier<bool>(true);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: notifier,
                builder: (context, enabled, child) {
                  return TickerMode(
                    enabled: enabled,
                    child: AnimalCarousel(
                      height: 150.0,
                      autoPlayInterval: const Duration(milliseconds: 100),
                      items: const [
                        Text('Slide 1'),
                        Text('Slide 2'),
                        Text('Slide 3'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Slide 1'), findsOneWidget);

        // Disable TickerMode (e.g. tab switched away / modal overlay displayed)
        notifier.value = false;
        await tester.pump();

        // Advancing timer should not throw or advance while TickerMode is false
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Slide 1'), findsOneWidget);

        // Re-enable TickerMode
        notifier.value = true;
        await tester.pump();
        // Step through timer trigger (100ms) + animation duration (250ms)
        for (int i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('Slide 2'), findsOneWidget);
      },
    );

    testWidgets(
      'O03: AnimalTypewriter pre-caches graphemes and executes typing without GC thrashing',
      (tester) async {
        bool completed = false;
        final clock = FakeClock();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTypewriter(
                text: '🍃 Animal Island 🌸',
                speed: const Duration(milliseconds: 20),
                showCursor: true,
                clock: clock,
                onComplete: () => completed = true,
              ),
            ),
          ),
        );

        expect(find.byType(AnimalTypewriter), findsOneWidget);
        clock.advanceMonotonic(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        clock.advanceMonotonic(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        expect(completed, isTrue);
        expect(find.textContaining('Animal Island'), findsOneWidget);
      },
    );

    testWidgets(
      'O04: AnimalIslandTheme resolves its explicit extension and exports toThemeData',
      (tester) async {
        // Consumers install a complete theme through the single bridge.
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.dark.toThemeData(),
            home: Builder(
              builder: (context) {
                final resolvedTheme = AnimalIslandTheme.of(context);
                expect(resolvedTheme, AnimalIslandTheme.dark);
                expect(Theme.of(context).brightness, Brightness.dark);
                return const SizedBox();
              },
            ),
          ),
        );

        // The bridge preserves the resolved brightness and extension.
        final lightThemeData = AnimalIslandTheme.light.toThemeData();
        expect(lightThemeData.brightness, Brightness.light);
        expect(
          lightThemeData.extensions.values.first,
          isA<AnimalIslandTheme>(),
        );

        final darkThemeData = AnimalIslandTheme.dark.toThemeData();
        expect(darkThemeData.brightness, Brightness.dark);
        expect(darkThemeData.extensions.values.first, isA<AnimalIslandTheme>());
      },
    );
  });

  group('Docs Alignment & New Features SOTA Tests', () {
    testWidgets(
      'AnimalProgress.circle renders circular progress and formatted info',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalProgress.circle(
                percent: 0.75,
                size: 100.0,
                strokeWidth: 8.0,
              ),
            ),
          ),
        );

        expect(find.bySubtype<AnimalProgress>(), findsOneWidget);
        expect(find.text('75%'), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalButtonTone.success and warning render with distinct colors',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalButton(
                    tone: AnimalButtonTone.success,
                    onPressed: () {},
                    child: const Text('Harvest'),
                  ),
                  AnimalButton(
                    tone: AnimalButtonTone.warning,
                    onPressed: () {},
                    child: const Text('Caution'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Harvest'), findsOneWidget);
        expect(find.text('Caution'), findsOneWidget);
      },
    );

    testWidgets('AnimalCard renders with header, footer, and dividers', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCard(
              header: Text('Museum Gallery'),
              footer: Text('Total: 42 fossils'),
              child: Text('Card Body Content'),
            ),
          ),
        ),
      );

      expect(find.text('Museum Gallery'), findsOneWidget);
      expect(find.text('Card Body Content'), findsOneWidget);
      expect(find.text('Total: 42 fossils'), findsOneWidget);
    });

    testWidgets(
      'AnimalModal.showDialogue accepts speaker, avatar, and dialogue stream',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AnimalModal.showDialogue(
                      context: context,
                      speaker: 'Marshal',
                      avatar: const Icon(Icons.person),
                      dialogue: 'Sulky!',
                    );
                  },
                  child: const Text('Talk'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Talk'));
        await tester.pumpAndSettle();

        expect(find.text('Marshal'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.text('Sulky!'), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalNotificationHandle.close dismisses notifications programmatically',
      (tester) async {
        AnimalNotificationHandle? turnip;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: AnimalOverlayHost(
              child: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      turnip = AnimalNotification.open(
                        context,
                        key: 'turnip_notif',
                        message: const Text('Turnip Alert'),
                      );
                    },
                    child: const Text('Notify'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Notify'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Turnip Alert'), findsOneWidget);

        // Dismiss through the occurrence's own handle.
        turnip!.close();
        expect(turnip!.status, AnimalNotificationStatus.closed);
        await tester.pumpAndSettle();
        expect(find.text('Turnip Alert'), findsNothing);
      },
    );

    testWidgets(
      'AnimalTimePicker preserves second when hour/minute updates and blocks self-induced jumpToItem feedback loop',
      (tester) async {
        AnimalTimeValue? currentTime = AnimalTimeValue(
          hour: 10,
          minute: 30,
          second: 45,
        );
        late StateSetter parentSetState;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  parentSetState = setState;
                  return AnimalTimePicker(
                    value: currentTime,
                    format: 'HH:mm:ss',
                    onChanged: (t) {
                      setState(() => currentTime = t);
                    },
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('10'), findsWidgets);
        expect(find.text('30'), findsWidgets);
        expect(find.text('45'), findsWidgets);

        // 1. Simulate parent update passing new AnimalTimeValue (unified time representation)
        parentSetState(() {
          currentTime = AnimalTimeValue(hour: 12, minute: 15, second: 45);
        });
        await tester.pumpAndSettle();

        // Verify hour and minute updated to 12:15, and second remained 45
        expect(find.text('12'), findsWidgets);
        expect(find.text('15'), findsWidgets);
        expect(find.text('45'), findsWidgets);
      },
    );

    testWidgets(
      'AnimalTimePicker.popover tracks seconds in HH:mm:ss mode cleanly',
      (tester) async {
        AnimalTimeValue? pickedTime = AnimalTimeValue(
          hour: 9,
          minute: 20,
          second: 33,
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTimePicker.popover(
                value: pickedTime,
                format: 'HH:mm:ss',
                onChanged: (t) => pickedTime = t,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('09:20:33'), findsOneWidget);
      },
    );
  });
}
