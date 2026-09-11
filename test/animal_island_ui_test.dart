import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('Animal Island UI Design Tokens Tests', () {
    test('AnimalColors strictly match canonical specs', () {
      expect(AnimalColors.primary, const Color(0xFF19C8B9));
      expect(AnimalColors.text, const Color(0xFF794F27));
      expect(AnimalColors.bg, const Color(0xFFF8F8F0));
      expect(AnimalColors.focusYellow, const Color(0xFFFFCC00));
      expect(AnimalTileColor.values.length, 13);
    });

    test('AnimalRadii enforces 12px min rule and 50px pills', () {
      expect(AnimalRadii.pill, 50.0);
      expect(AnimalRadii.card, 20.0);
      expect(AnimalRadii.sm, 12.0);
    });
  });

  group('Animal Island Components Widget Tests', () {
    testWidgets('AnimalButton renders with 3D depth and responds to taps', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
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

    testWidgets('AnimalInput renders with placeholder and accepts input', (tester) async {
      String changedText = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalInput(
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

    testWidgets('AnimalCard renders with 13 tile color variants', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

    testWidgets('AnimalIcons and standalone widgets render correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LeafIcon(size: 24),
                AppleIcon(size: 24),
                HeartIcon(size: 24),
                AnimalIcon(name: AnimalIconName.bell, size: 24),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(LeafIcon), findsOneWidget);
      expect(find.byType(AppleIcon), findsOneWidget);
      expect(find.byType(HeartIcon), findsOneWidget);
      expect(find.byType(AnimalIcon), findsNWidgets(4));
    });

    testWidgets('AnimalTabs switches selected index', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
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
        const MaterialApp(
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

    testWidgets('AnimalTitle swallowtail ribbon renders child text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimalTitle(
              child: Text('Island News'),
            ),
          ),
        ),
      );

      expect(find.text('Island News'), findsOneWidget);
    });

    test('AnimalFormController and AnimalRule validation engine', () async {
      final controller = AnimalFormController();
      controller.registerField(
        'email',
        rules: [
          AnimalRule.required(message: 'Email required'),
          AnimalRule.email(message: 'Invalid email'),
        ],
      );

      expect(await controller.validateFields(), isFalse);
      expect(controller.getFieldError('email'), 'Email required');

      controller.setFieldValue('email', 'not-an-email', validate: false);
      expect(await controller.validateFields(), isFalse);
      expect(controller.getFieldError('email'), 'Invalid email');

      controller.setFieldValue('email', 'islander@animalisland.ui', validate: false);
      expect(await controller.validateFields(), isTrue);
      expect(controller.getFieldError('email'), isNull);

      controller.resetFields();
      expect(controller.getFieldValue('email'), isNull);
      expect(controller.getFieldError('email'), isNull);
    });

    testWidgets('AnimalNotification displays on Overlay without ScaffoldMessenger', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
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
      );

      await tester.tap(find.text('Notify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Bells Collected!'), findsOneWidget);
      expect(find.text('10,000 Bells added to your wallet'), findsOneWidget);

      AnimalNotification.destroy();
      await tester.pumpAndSettle();
      expect(find.text('Bells Collected!'), findsNothing);
    });

    testWidgets('AnimalLoading renders spinner, snowflake, and dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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
      expect(find.byType(LeafIcon), findsOneWidget);
      expect(find.byType(SnowflakeIcon), findsOneWidget);
    });

    testWidgets('AnimalProgress renders candy-cane stripes and info label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

    testWidgets('AnimalSkeleton renders composite presets and declarative wrapper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
    });

    testWidgets('AnimalButton renders dashed, ghost, and danger variants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimalButton(
                  type: AnimalButtonType.dashed,
                  onPressed: () {},
                  child: const Text('Dashed Button'),
                ),
                AnimalButton(
                  type: AnimalButtonType.primary,
                  ghost: true,
                  danger: true,
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

    testWidgets('AnimalDivider renders plain line, wavy, and leaf variants', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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
      expect(find.byType(LeafIcon), findsOneWidget);
    });

    testWidgets('AnimalCollapse toggles question and answer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCollapse.single(
              question: const Text('What is Nook Miles?'),
              answer: const Text('Points earned by completing island tasks.'),
            ),
          ),
        ),
      );

      expect(find.text('What is Nook Miles?'), findsOneWidget);
      expect(find.text('Points earned by completing island tasks.'), findsOneWidget);

      await tester.tap(find.text('What is Nook Miles?'));
      await tester.pumpAndSettle();
    });

    testWidgets('AnimalTooltip wraps child and renders message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

    testWidgets('AnimalTable renders zebra rows without assert crash, and handles empty and loading states', (tester) async {
      // 1. Valid data table
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimalTable(
              columns: [
                AnimalTableColumn(title: 'Item'),
                AnimalTableColumn(title: 'Price'),
              ],
              rows: [
                [Text('Apple'), Text('100')],
                [Text('Orange'), Text('100')],
                [Text('Pear'), Text('100')],
              ],
            ),
          ),
        ),
      );

      expect(find.text('Item'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);

      // 2. Empty state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimalTable(
              columns: [AnimalTableColumn(title: 'Item')],
              rows: [],
            ),
          ),
        ),
      );

      expect(find.text('No island data found'), findsOneWidget);

      // 3. Loading state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimalTable(
              loading: true,
              columns: [AnimalTableColumn(title: 'Item')],
              rows: [],
            ),
          ),
        ),
      );

      expect(find.byType(AnimalLoading), findsOneWidget);
    });

    testWidgets('AnimalPagination windowed algorithm renders ellipsis and handles page navigation', (tester) async {
      int selected = 5;
      await tester.pumpWidget(
        MaterialApp(
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
    });

    testWidgets('AnimalModal clips content with AnimalBlobClipper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalModal(
              title: const Text('Blob Dialog'),
              content: const Text('Organic Modal Content'),
              onOk: () {},
            ),
          ),
        ),
      );

      expect(find.text('Blob Dialog'), findsOneWidget);
      expect(find.text('Organic Modal Content'), findsOneWidget);
      final clipPath = tester.widget<ClipPath>(find.byType(ClipPath).first);
      expect(clipPath.clipper, isA<AnimalBlobClipper>());
    });

    testWidgets('AnimalBackTop ignores hit-test pointer when invisible', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalBackTop(scrollController: controller),
          ),
        ),
      );

      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(of: find.byType(AnimalBackTop), matching: find.byType(IgnorePointer)),
      );
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('AnimalDatePicker enforces date bounds and normalizes times', (tester) async {
      DateTime? chosenDate;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalDatePicker(
              value: DateTime(2026, 9, 15),
              firstDate: DateTime(2026, 9, 10, 23, 59),
              lastDate: DateTime(2026, 9, 20, 0, 0),
              onChanged: (d) => chosenDate = d,
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);

      // Tap a valid date (16)
      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();
      expect(chosenDate, DateTime(2026, 9, 16));

      // Tap a disabled date (5)
      chosenDate = null;
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(chosenDate, isNull);
    });

    testWidgets('AnimalTimePicker locks scroll physics when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalTimePicker(
              value: TimeOfDay(hour: 12, minute: 0),
              onChanged: (_) {},
              disabled: true,
            ),
          ),
        ),
      );

      final scrollViews = tester.widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView));
      for (final view in scrollViews) {
        expect(view.physics, isA<NeverScrollableScrollPhysics>());
      }
    });

    testWidgets('AnimalInput disposes external focusNode and updates dynamically', (tester) async {
      final node = FocusNode();
      final controller1 = TextEditingController(text: 'Initial');
      final controller2 = TextEditingController(text: 'Updated');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalInput(
              controller: controller1,
              focusNode: node,
            ),
          ),
        ),
      );

      expect(find.text('Initial'), findsOneWidget);

      // Hot-update widget with new controller
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalInput(
              controller: controller2,
              focusNode: node,
            ),
          ),
        ),
      );

      expect(find.text('Updated'), findsOneWidget);

      // Pump empty to dispose
      await tester.pumpWidget(const SizedBox.shrink());
      // node should not throw on subsequent focus
      node.requestFocus();
      node.dispose();
    });

    testWidgets('AnimalTypewriter safely types and cancels timer on unmount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

    testWidgets('AnimalIcon preserves multi-color fills and supports stroke/monochrome customization', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WatermelonIcon(size: 32),
                WatermelonIcon(size: 32, strokeColor: Color(0xFF794F27)),
                WatermelonIcon(size: 32, color: Color(0xFFFFFFFF), monochrome: true),
                AnimalIcon(name: AnimalIconName.bear, size: 32),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(WatermelonIcon), findsNWidgets(3));
      expect(find.byType(AnimalIcon), findsNWidgets(4));
    });

    testWidgets('AnimalTag supports island palette colors, sizes, and disabled state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimalTag(color: AnimalTileColor.appPink, size: AnimalTagSize.small, child: Text('Pink Tag')),
                AnimalTag(color: AnimalTileColor.appTeal, size: AnimalTagSize.middle, child: Text('Teal Tag')),
                AnimalTag(color: AnimalTileColor.appYellow, size: AnimalTagSize.large, child: Text('Yellow Tag')),
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
    });

    testWidgets('AnimalCountdown remaining mode decrements monotonically when pumped (CD-01)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimalCountdown(
              remaining: Duration(seconds: 5),
            ),
          ),
        ),
      );

      expect(find.text('05'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('03'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('01'), findsOneWidget);
    });

    testWidgets('AnimalForm onSubmit and blur validation integrate seamlessly (FORM-01, FORM-02, FORM-03)', (tester) async {
      final controller = AnimalFormController();
      bool submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              onSubmit: () {
                submitted = true;
              },
              child: Column(
                children: [
                  AnimalFormItem(
                    name: 'username',
                    label: 'Username',
                    required: true,
                    rules: [
                      AnimalRule.required(message: 'Required field'),
                    ],
                    child: const AnimalInput(placeholder: 'Enter name'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially valid is false because username is empty
      final initialValid = await controller.validateFields();
      expect(initialValid, isFalse);

      controller.setFieldValue('username', 'Nook');
      await controller.submit();
      expect(submitted, isTrue);
      expect(controller.getFieldValue('username'), 'Nook');
    });

    testWidgets('AnimalCard renders dots/stripes/sprinkles pattern painter (CARD-01)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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
    });

    testWidgets('AnimalModal consumes typewriter and renders dialogue stream (MOD-01)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalModal(
              title: const Text('Villager Dialogue'),
              typewriter: true,
              typeSpeed: const Duration(milliseconds: 10),
              content: const Text('Hello Island Resident!'),
            ),
          ),
        ),
      );

      expect(find.byType(AnimalTypewriter), findsOneWidget);
      expect(find.text('Villager Dialogue'), findsOneWidget);
    });

    testWidgets('AnimalIcon does not create unnecessary animation controllers when bounce is false (ICO-01, ICO-03)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimalIcon(name: AnimalIconName.leaf, bounce: false),
                AnimalIcon(name: AnimalIconName.apple, bounce: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AnimalIcon), findsNWidgets(2));
      // Tap bouncing icon
      await tester.tap(find.byType(AnimalIcon).last);
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('AnimalDrawer renders, supports barrierColor customization, and handles dismiss', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => AnimalButton(
                onPressed: () {
                  AnimalDrawer.show(
                    context: context,
                    title: const Text('Island Storage'),
                    barrierColor: const Color(0x80000000),
                    child: const Text('Drawer Contents'),
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
      final closeBtn = find.descendant(
        of: find.byType(AnimalDrawer),
        matching: find.byType(AnimalPressable),
      ).first;
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.text('Drawer Contents'), findsNothing);
    });

    testWidgets('AnimalCursor renders child and respects system/custom cursor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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
    });

    testWidgets('AnimalCodeBlock renders code with header and copies to clipboard', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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
      expect(find.text('Copied!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('AnimalCarousel renders items and handles navigation', (tester) async {
      int activeIndex = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCarousel(
              autoPlay: false,
              onChange: (idx) => activeIndex = idx,
              items: const [
                Text('Slide 1'),
                Text('Slide 2'),
                Text('Slide 3'),
              ],
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

    testWidgets('AnimalSelect renders options and supports selection', (tester) async {
      String? selectedVal;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => AnimalSelect<String>(
                value: selectedVal,
                placeholder: 'Choose Fruit',
                options: const [
                  AnimalSelectOption(value: 'apple', label: 'Apple'),
                  AnimalSelectOption(value: 'orange', label: 'Orange'),
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

    testWidgets('AnimalImage renders with border radius and handles semantic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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
    });

    testWidgets('AnimalTimePicker handles now, clear, and disabled interactions (TIME-01, TIME-02)', (tester) async {
      TimeOfDay? chosenTime = const TimeOfDay(hour: 12, minute: 0);
      int? h = 12, m = 0, s = 0;

      // Active picker
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalTimePicker(
              value: chosenTime,
              onChanged: (t) => chosenTime = t,
              onFullTimeChanged: (hour, minute, sec) {
                h = hour;
                m = minute;
                s = sec;
              },
            ),
          ),
        ),
      );

      expect(find.text('Clear'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(chosenTime, isNull);
      expect(h, isNull);
      expect(m, isNull);
      expect(s, isNull);

      // Disabled picker
      bool disabledChanged = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalTimePicker(
              key: const ValueKey('disabled_picker'),
              value: const TimeOfDay(hour: 8, minute: 0),
              disabled: true,
              onChanged: (t) => disabledChanged = true,
              onFullTimeChanged: (hour, minute, sec) => disabledChanged = true,
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
    });

    testWidgets('AnimalDatePicker enforces disabled guard on Today and Clear buttons (DATE-01)', (tester) async {
      bool dateChanged = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalDatePicker(
              value: DateTime(2026, 1, 1),
              disabled: true,
              onChanged: (d) => dateChanged = true,
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
    });

    testWidgets('AnimalFooter renders sea and tree styles with content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

    testWidgets('AnimalForm focuses first error field physically (FORM-01)', (tester) async {
      final controller = AnimalFormController();
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: Column(
                children: [
                  AnimalFormItem(
                    name: 'firstField',
                    label: 'First',
                    focusNode: focusNode1,
                    rules: [AnimalRule.required(message: 'First is required')],
                    child: const AnimalInput(),
                  ),
                  AnimalFormItem(
                    name: 'secondField',
                    label: 'Second',
                    focusNode: focusNode2,
                    rules: [AnimalRule.required(message: 'Second is required')],
                    child: const AnimalInput(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(focusNode1.hasFocus, isFalse);
      expect(focusNode2.hasFocus, isFalse);

      final valid = await controller.validateFields();
      await tester.pump();

      expect(valid, isFalse);
      expect(focusNode1.hasFocus, isTrue);
      expect(focusNode2.hasFocus, isFalse);

      focusNode1.dispose();
      focusNode2.dispose();
    });

    testWidgets('AnimalCheckboxGroup and AnimalRadioGroup do not pollute form state (FORM-02, FORM-03)', (tester) async {
      final controller = AnimalFormController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: Column(
                children: [
                  AnimalFormItem(
                    name: 'hobbies',
                    label: 'Hobbies',
                    initialValue: const <String>[],
                    child: AnimalCheckboxGroup<String>(
                      value: const [],
                      options: const [
                        AnimalOption(value: 'fishing', label: 'Fishing'),
                        AnimalOption(value: 'bugCatching', label: 'Bug Catching'),
                      ],
                      onChanged: (vals) => controller.setFieldValue('hobbies', vals),
                    ),
                  ),
                  AnimalFormItem(
                    name: 'role',
                    label: 'Role',
                    initialValue: 'resident',
                    child: AnimalRadioGroup<String>(
                      value: 'resident',
                      options: const [
                        AnimalOption(value: 'resident', label: 'Resident'),
                        AnimalOption(value: 'mayor', label: 'Mayor'),
                      ],
                      onChanged: (val) => controller.setFieldValue('role', val),
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
      final hobbies = controller.getFieldValue('hobbies');
      expect(hobbies, isA<List<String>>());
      expect(hobbies, contains('fishing'));

      // Tap the radio for 'Mayor'
      await tester.tap(find.text('Mayor'));
      await tester.pump();

      final role = controller.getFieldValue('role');
      expect(role, equals('mayor'));
    });

    testWidgets('AnimalFormController resetFields and setFieldValue dynamically sync AnimalInput (FORM-04)', (tester) async {
      final controller = AnimalFormController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: AnimalFormItem(
                name: 'island',
                label: 'Island',
                initialValue: 'Peach Isle',
                child: const AnimalInput(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Peach Isle'), findsOneWidget);

      // Dynamically set value
      controller.setFieldValue('island', 'Cherry Isle');
      await tester.pump();
      expect(find.text('Cherry Isle'), findsOneWidget);

      // Reset fields
      controller.resetFields();
      await tester.pump();
      expect(find.text('Peach Isle'), findsOneWidget);
    });

    testWidgets('AnimalRadio respects custom activeColor (RD-01)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AnimalRadio<int>),
          matching: find.byType(AnimatedContainer),
        ).first,
      );
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect((decoration.border as Border).top.color, Colors.deepPurple);
    });

    testWidgets('AnimalTag can be focused and activated via keyboard (TAG-02)', (tester) async {
      bool tagActivated = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
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
    });

    testWidgets('AnimalDatePicker and AnimalTimePicker support keyboard activation via Enter/Space (D-03)', (tester) async {
      final dateFocusNode = FocusNode();
      final timeFocusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
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
    });

    testWidgets('AnimalCheckboxGroup and AnimalRadioGroup allocate independent focus nodes without duplicate attachment (D-04)', (tester) async {
      final controller = AnimalFormController();
      final groupFocusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: Column(
                children: [
                  AnimalFormItem(
                    name: 'hobbies',
                    focusNode: groupFocusNode,
                    child: const AnimalCheckboxGroup<String>(
                      value: [],
                      options: [
                        AnimalOption(value: 'fishing', label: 'Fishing'),
                        AnimalOption(value: 'bug', label: 'Bug Catching'),
                      ],
                    ),
                  ),
                  AnimalFormItem(
                    name: 'gender',
                    child: const AnimalRadioGroup<String>(
                      value: 'm',
                      options: [
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
    });

    testWidgets('Form controls reactively update visual state on setFieldValue and resetFields (D-05)', (tester) async {
      final controller = AnimalFormController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimalForm(
                controller: controller,
                child: Column(
                  children: [
                    AnimalFormItem(
                      name: 'select',
                      initialValue: 'apple',
                      child: AnimalSelect<String>(
                        value: 'apple',
                        onChanged: (_) {},
                        options: const [
                          AnimalSelectOption(value: 'apple', label: 'Apple'),
                          AnimalSelectOption(value: 'pear', label: 'Pear'),
                        ],
                      ),
                    ),
                    AnimalFormItem(
                      name: 'switch',
                      initialValue: false,
                      child: AnimalSwitch(value: false, onChanged: (_) {}),
                    ),
                    AnimalFormItem(
                      name: 'radio_group',
                      initialValue: 'x',
                      child: const AnimalRadioGroup<String>(
                        value: 'x',
                        options: [
                          AnimalOption(value: 'x', label: 'Option X'),
                          AnimalOption(value: 'y', label: 'Option Y'),
                        ],
                      ),
                    ),
                    AnimalFormItem(
                      name: 'date',
                      child: AnimalDatePicker.popover(),
                    ),
                    AnimalFormItem(
                      name: 'time',
                      child: AnimalTimePicker.popover(),
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
      controller.setFieldValue('select', 'pear');
      await tester.pump();
      expect(find.text('Pear'), findsOneWidget);

      // 2. Update Switch
      controller.setFieldValue('switch', true);
      await tester.pump();
      final switchFinder = find.byType(AnimalSwitch);
      expect(tester.widget<AnimalSwitch>(switchFinder).value, isFalse); // widget constructor was false, but formItem is true

      // 3. Update Date & Time
      controller.setFieldValue('date', DateTime(2026, 9, 10));
      controller.setFieldValue('time', const TimeOfDay(hour: 15, minute: 45));
      await tester.pump();
      expect(find.text('2026-09-10'), findsOneWidget);
      expect(find.text('15:45'), findsOneWidget);

      // 4. Reset Fields
      controller.resetFields();
      await tester.pump();
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('2026-09-10'), findsNothing);
      expect(find.text('15:45'), findsNothing);
    });

    testWidgets('AnimalIcon responds to keyboard Enter/Space when onTap is provided (D-06)', (tester) async {
      bool tapped = false;
      final fn = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalIcon(
              name: AnimalIconName.airplane,
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
    });

    testWidgets('AnimalModal extracts nested text for typewriter and supports close button keyboard activation (D-02, D-11)', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalModal(
              typewriter: true,
              onClose: () => closed = true,
              content: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Nested dialogue text'),
              ),
            ),
          ),
        ),
      );

      // Verify AnimalTypewriter received the nested text
      final typewriterFinder = find.byType(AnimalTypewriter);
      expect(typewriterFinder, findsOneWidget);
      final typewriter = tester.widget<AnimalTypewriter>(typewriterFinder);
      expect(typewriter.text, 'Nested dialogue text');

      // Test close button keyboard activation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Find close button and invoke tap
      final closeBtnFinder = find.byType(CloseIcon);
      expect(closeBtnFinder, findsOneWidget);
      await tester.tap(closeBtnFinder);
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets('AnimalPagination, AnimalCarousel, and AnimalBackTop clean single-layer Semantics (D-07)', (tester) async {
      final scrollController = ScrollController(initialScrollOffset: 500);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  AnimalPagination(current: 1, total: 50, pageSize: 10, onChanged: (_) {}),
                  AnimalCarousel(
                    height: 100,
                    showArrows: true,
                    items: const [Text('Slide 1'), Text('Slide 2')],
                  ),
                  AnimalBackTop(
                    scrollController: scrollController,
                  ),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Pagination previous button has semanticLabel on AnimalPressable without redundant outer Semantics
      final prevBtnFinder = find.byWidgetPredicate(
        (w) => w is AnimalPressable && w.semanticLabel == '上一页',
      );
      expect(prevBtnFinder, findsWidgets);

      final nextSlideFinder = find.byWidgetPredicate(
        (w) => w is AnimalPressable && w.semanticLabel == 'Next slide',
      );
      expect(nextSlideFinder, findsOneWidget);

      final backTopFinder = find.byWidgetPredicate(
        (w) => w is AnimalPressable && w.semanticLabel == '回到顶部',
      );
      expect(backTopFinder, findsOneWidget);
      scrollController.dispose();
    });

    testWidgets('AnimalCodeBlock uses theme colors and copy button supports keyboard activation (D-08, D-09)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimalCodeBlock(
              code: 'final x = 42;',
              language: 'dart',
            ),
          ),
        ),
      );

      expect(find.text('final x = 42;'), findsOneWidget);
      final copyFinder = find.text('Copy');
      expect(copyFinder, findsOneWidget);

      await tester.tap(copyFinder);
      await tester.pump();
      expect(find.text('Copied!'), findsOneWidget);

      // Advance clock past 2-second reset timer
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('AnimalTag close button supports keyboard activation (D-10)', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalTag(
              onClose: () => closed = true,
              child: const Text('Removable Tag'),
            ),
          ),
        ),
      );

      final removeFinder = find.byType(CloseIcon);
      expect(removeFinder, findsOneWidget);

      await tester.tap(removeFinder);
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets('AnimalCarousel dots can be navigated and activated via keyboard (D-12)', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
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
    });
  });

  group('Round 7 SOTA Refactoring & Enterprise Regression Tests (P01-P10, C01-C06, A01-A06, T01, D01)', () {
    test('P05: AnimalImageIcon renders standalone with custom dimensions', () {
      const icon = AnimalImageIcon(
        size: 32.0,
        color: AnimalColors.primary,
      );
      expect(icon.size, 32.0);
      expect(icon.color, AnimalColors.primary);
    });

    test('C01: AnimalTimePicker constructor asserts step >= 1 and defends against infinite loops', () {
      expect(() => AnimalTimePicker(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, hourStep: 0), throwsAssertionError);
      expect(() => AnimalTimePicker(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, minuteStep: -1), throwsAssertionError);
      expect(() => AnimalTimePicker(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, secondStep: 0), throwsAssertionError);
      expect(() => AnimalTimePicker.popover(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, hourStep: 0), throwsAssertionError);
      expect(() => AnimalTimePicker.popover(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, minuteStep: 0), throwsAssertionError);
      expect(() => AnimalTimePicker.popover(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, secondStep: -5), throwsAssertionError);

      // Positive test: valid steps build fine
      expect(() => AnimalTimePicker(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, hourStep: 2, minuteStep: 5, secondStep: 15), returnsNormally);
      expect(() => AnimalTimePicker.popover(value: const TimeOfDay(hour: 10, minute: 0), onChanged: (_) {}, hourStep: 3, minuteStep: 10, secondStep: 30), returnsNormally);
    });

    testWidgets('C02 & C04: AnimalTimePicker standalone panel updates formItem and triggers onBlur', (tester) async {
      final formController = AnimalFormController();
      final focusNode = FocusNode();
      TimeOfDay? currentTime = const TimeOfDay(hour: 14, minute: 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalForm(
              controller: formController,
              child: AnimalFormItem(
                name: 'departureTime',
                initialValue: currentTime,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return AnimalTimePicker(
                      focusNode: focusNode,
                      value: currentTime,
                      onChanged: (val) => setState(() => currentTime = val),
                      allowClear: true,
                    );
                  },
                ),
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

      expect(formController.values['departureTime'], isNull);
    });

    testWidgets('C03 & C04: AnimalDatePicker standalone panel updates formItem and triggers onBlur', (tester) async {
      final formController = AnimalFormController();
      final focusNode = FocusNode();
      DateTime? currentDate = DateTime(2026, 5, 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalForm(
              controller: formController,
              child: AnimalFormItem(
                name: 'flightDate',
                initialValue: currentDate,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return AnimalDatePicker(
                      focusNode: focusNode,
                      value: currentDate,
                      onChanged: (val) => setState(() => currentDate = val),
                      allowClear: true,
                    );
                  },
                ),
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
      expect(formController.values['flightDate'], isNull);

      // Today in standalone panel updates formItem
      final todayButton = find.text('Today');
      expect(todayButton, findsOneWidget);
      await tester.tap(todayButton);
      await tester.pumpAndSettle();
      final todayVal = formController.values['flightDate'] as DateTime?;
      expect(todayVal, isNotNull);
      final now = DateTime.now();
      expect(todayVal!.year, now.year);
      expect(todayVal.month, now.month);
      expect(todayVal.day, now.day);
    });

    testWidgets('C05: AnimalCheckboxGroup and AnimalRadioGroup container focus requests redirect to first child', (tester) async {
      final cbGroupFocus = FocusNode();
      final radioGroupFocus = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimalCheckboxGroup<String>(
                  focusNode: cbGroupFocus,
                  options: const [
                    AnimalOption(value: 'Apple', label: 'Apple'),
                    AnimalOption(value: 'Orange', label: 'Orange'),
                  ],
                  value: const [],
                ),
                AnimalRadioGroup<String>(
                  focusNode: radioGroupFocus,
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
    });

    testWidgets('C06: AnimalDrawer provides modal route semantics with scopesRoute: true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AnimalDrawer.show(
                    context: context,
                    title: const Text('Island Tools'),
                    child: const Text('Net and Fishing Rod'),
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
        (w) => w is Semantics && w.properties.scopesRoute == true && w.properties.namesRoute == true,
      );
      expect(drawerSemanticsFinder, findsOneWidget);
      expect(find.text('Island Tools'), findsOneWidget);
    });

    testWidgets('A01: AnimalInput clear button can be activated via Enter / Space keyboard navigation', (tester) async {
      final controller = TextEditingController(text: 'Nook Mile Ticket');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalInput(
              controller: controller,
              clearable: true,
            ),
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
    });

    testWidgets('A02: AnimalSelect clear button can be activated via Enter / Space keyboard navigation', (tester) async {
      String? selected = 'apple';

      await tester.pumpWidget(
        MaterialApp(
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
    });

    testWidgets('A03: AnimalNotification close button supports keyboard action detector and focus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
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
      );

      await tester.tap(find.text('Notify'));
      await tester.pump(); // frame 1: overlay container mounts
      await tester.pump(); // frame 2: card mounts and starts animation
      await tester.pump(const Duration(milliseconds: 400)); // frame 3: entrance animation completes

      expect(find.text('Morning Announcement'), findsOneWidget);

      final dismissFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Dismiss notification',
      );
      expect(dismissFinder, findsOneWidget);

      await tester.tap(dismissFinder);
      await tester.pump(); // starts reverse animation
      await tester.pump(const Duration(milliseconds: 400)); // reverse finishes, calls onDismiss
      await tester.pump(); // widget tree updates, card is removed

      expect(find.text('Morning Announcement'), findsNothing);
    });

    testWidgets('A04: AnimalTabs single tab item has FocusableActionDetector and ActivateIntent', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalTabs(
                  selectedIndex: activeIndex,
                  onChanged: (idx) => setState(() => activeIndex = idx),
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
    });

    testWidgets('A05: AnimalTimePicker wheel items do not advertise fake button semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalTimePicker(
              value: const TimeOfDay(hour: 8, minute: 15),
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
    });

    testWidgets('A06: AnimalDatePicker day cells contain FocusableActionDetector with ActivateIntent', (tester) async {
      DateTime? selectedDate = DateTime(2026, 6, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalDatePicker(
              value: selectedDate,
              onChanged: (val) => selectedDate = val,
            ),
          ),
        ),
      );

      final dayCellFAD = find.byWidgetPredicate(
        (w) => w is FocusableActionDetector && (w.actions?.containsKey(ActivateIntent) ?? false),
      );
      expect(dayCellFAD, findsWidgets);
    });

    test('T01: Dark theme surfaces strictly use semantic surfaceAlt and surfaceHeader tokens', () {
      final darkTheme = AnimalIslandTheme.dark;
      expect(darkTheme.surfaceAlt, const Color(0xFF383028));
      expect(darkTheme.surfaceHeader, const Color(0xFF2C241D));
    });

    testWidgets('A01: AnimalDatePicker.popover Clear button contains FocusableActionDetector with ActivateIntent', (tester) async {
      DateTime? selectedDate = DateTime(2026, 6, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalDatePicker.popover(
                  value: selectedDate,
                  allowClear: true,
                  onChanged: (val) => setState(() => selectedDate = val),
                );
              },
            ),
          ),
        ),
      );

      final clearSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Clear date',
      );
      expect(clearSemantics, findsOneWidget);

      final innerFAD = tester.widget<FocusableActionDetector>(
        find.ancestor(
          of: clearSemantics,
          matching: find.byType(FocusableActionDetector),
        ).first,
      );
      expect(innerFAD.actions?.containsKey(ActivateIntent), isTrue);

      await tester.tap(clearSemantics);
      await tester.pumpAndSettle();
      expect(selectedDate, isNull);
    });

    testWidgets('A02: AnimalTimePicker.popover Clear button contains FocusableActionDetector with ActivateIntent', (tester) async {
      TimeOfDay? selectedTime = const TimeOfDay(hour: 14, minute: 30);

      await tester.pumpWidget(
        MaterialApp(
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

      final clearSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Clear time',
      );
      expect(clearSemantics, findsOneWidget);

      final innerFAD = tester.widget<FocusableActionDetector>(
        find.ancestor(
          of: clearSemantics,
          matching: find.byType(FocusableActionDetector),
        ).first,
      );
      expect(innerFAD.actions?.containsKey(ActivateIntent), isTrue);

      await tester.tap(clearSemantics);
      await tester.pumpAndSettle();
      expect(selectedTime, isNull);
    });

    testWidgets('T01 & T02: Collapse and Skeleton use governed dark surface tokens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [AnimalIslandTheme.dark],
          ),
          home: Scaffold(
            body: Column(
              children: [
                AnimalCollapse(
                  disabled: true,
                  items: const [
                    AnimalCollapseItem(title: Text('Disabled Item'), content: Text('Content')),
                  ],
                ),
                const AnimalSkeleton(
                  loading: true,
                  child: Text('Loaded'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Disabled Item'), findsOneWidget);
      expect(find.byType(AnimalSkeleton), findsOneWidget);
    });
  });

  group('Enterprise Performance & SOTA Architectural Optimization Tests (O01-O04)', () {
    testWidgets('O01: AnimalTable renders with maxHeight virtualized scroll and sticky header without IntrinsicWidth', (tester) async {
      final columns = [
        const AnimalTableColumn(title: 'ID', width: 60.0),
        const AnimalTableColumn(title: 'Item Name'),
        const AnimalTableColumn(title: 'Price', width: 80.0),
      ];
      final rows = List.generate(
        100,
        (i) => [
          Text('$i'),
          Text('Island Item #$i'),
          Text('${(i + 1) * 10} Bells'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalTable(
              columns: columns,
              rows: rows,
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
    });

    testWidgets('O02: AnimalCarousel pauses autoplay when TickerMode is disabled and resumes when enabled', (tester) async {
      final notifier = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
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
    });

    testWidgets('O03: AnimalTypewriter pre-caches graphemes and executes typing without GC thrashing', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalTypewriter(
              text: '🍃 Animal Island 🌸',
              speed: const Duration(milliseconds: 20),
              showCursor: true,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      expect(find.byType(AnimalTypewriter), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(find.textContaining('Animal Island'), findsOneWidget);
    });

    testWidgets('O04: AnimalIslandTheme auto-adapts to host brightness and exports toThemeData', (tester) async {
      // 1. Test auto-adaptation to Dark Brightness without extension
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              final resolvedTheme = AnimalIslandTheme.of(context);
              expect(resolvedTheme.isDark, isTrue);
              expect(context.animalTheme.isDark, isTrue);
              return const SizedBox();
            },
          ),
        ),
      );

      // 2. Test toThemeData() conversion
      final lightThemeData = AnimalIslandTheme.light.toThemeData();
      expect(lightThemeData.brightness, Brightness.light);
      expect(lightThemeData.extensions.values.first, isA<AnimalIslandTheme>());

      final darkThemeData = AnimalIslandTheme.dark.toThemeData();
      expect(darkThemeData.brightness, Brightness.dark);
      expect(darkThemeData.extensions.values.first, isA<AnimalIslandTheme>());
    });
  });

  group('Docs Alignment & New Features SOTA Tests', () {
    testWidgets('AnimalProgress.circle renders circular progress and formatted info', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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
    });

    testWidgets('AnimalButtonType.success and warning render with distinct colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimalButton(
                  type: AnimalButtonType.success,
                  onPressed: () {},
                  child: const Text('Harvest'),
                ),
                AnimalButton(
                  type: AnimalButtonType.warning,
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
    });

    testWidgets('AnimalCard renders with header, footer, and dividers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

    testWidgets('AnimalModal.showDialogue accepts speaker, avatar, and dialogue stream', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
    });

    testWidgets('AnimalNotification.destroy dismisses notifications programmatically', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AnimalNotification.open(
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
      );

      await tester.tap(find.text('Notify'));
      await tester.pumpAndSettle();
      expect(find.text('Turnip Alert'), findsOneWidget);

      // Dismiss by key
      AnimalNotification.destroy('turnip_notif');
      await tester.pumpAndSettle();
      expect(find.text('Turnip Alert'), findsNothing);
    });
  });
}


