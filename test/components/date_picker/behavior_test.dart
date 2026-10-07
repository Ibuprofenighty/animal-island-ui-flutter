import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  setUpAll(() async {
    final FontLoader nunito = FontLoader('packages/animal_island_ui/Nunito')
      ..addFont(
        rootBundle.load(
          'packages/animal_island_ui/assets/fonts/Nunito[wght].ttf',
        ),
      );
    await nunito.load();

    final FontLoader notoSansSc =
        FontLoader('packages/animal_island_ui/Noto Sans SC')..addFont(
          rootBundle.load(
            'packages/animal_island_ui/assets/fonts/NotoSansSC[wght].ttf',
          ),
        );
    await notoSansSc.load();
  });

  group('AnimalDatePicker Tests (DAT01-DAT05)', () {
    test('DAT01: civil model accepts leap day and rejects invalid dates', () {
      final AnimalDate leapDate = AnimalDate(2024, 2, 29);
      expect(leapDate.year, 2024);
      expect(leapDate.month, 2);
      expect(leapDate.day, 29);
      expect(leapDate.toIso8601String(), '2024-02-29');

      expect(() => AnimalDate(2025, 2, 29), throwsArgumentError);
      expect(() => AnimalDate(2025, 4, 31), throwsArgumentError);
      expect(() => AnimalDate(2025, 13, 1), throwsArgumentError);
      expect(() => AnimalDate(2025, 0, 1), throwsArgumentError);
      expect(() => AnimalDate(0, 1, 1), throwsArgumentError);
      expect(() => AnimalDate(10000, 1, 1), throwsArgumentError);
    });

    testWidgets(
      'DAT02: Enforces date bounds and normalizes disabled dates (OLD-T024)',
      (tester) async {
        AnimalDateSelection? proposal;
        await tester.pumpWidget(
          _dateApp(
            AnimalDatePicker(
              selection: AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
              firstDate: AnimalDate(2026, 9, 10),
              lastDate: AnimalDate(2026, 9, 20),
              onChanged: (value) => proposal = value,
            ),
          ),
        );

        final Finder validDate = _dateCell(AnimalDate(2026, 9, 16));
        expect(validDate, findsOneWidget);
        final Rect validRect = tester.getRect(validDate);
        expect(validRect.width, 48);
        expect(validRect.height, 48);
        expect(tester.widget<InteractiveRegion>(validDate).disabled, isFalse);
        await tester.tap(validDate);
        await tester.pumpAndSettle();
        expect(proposal, isA<AnimalDateSingleSelection>());
        expect(
          (proposal! as AnimalDateSingleSelection).date,
          AnimalDate(2026, 9, 16),
        );

        proposal = null;
        final Finder beforeFirstDate = _dateCell(AnimalDate(2026, 9, 9));
        expect(beforeFirstDate, findsOneWidget);
        expect(
          tester.widget<InteractiveRegion>(beforeFirstDate).disabled,
          isTrue,
        );
        await tester.tap(beforeFirstDate);
        await tester.pumpAndSettle();
        expect(proposal, isNull);

        final Finder afterLastDate = _dateCell(AnimalDate(2026, 9, 21));
        expect(afterLastDate, findsOneWidget);
        expect(
          tester.widget<InteractiveRegion>(afterLastDate).disabled,
          isTrue,
        );
        await tester.tap(afterLastDate);
        await tester.pumpAndSettle();
        expect(proposal, isNull);
      },
    );

    testWidgets(
      'DAT02: Today and Clear buttons enforce disabled guard (OLD-T042)',
      (tester) async {
        const String disabledReason =
            'Disabled date picker keeps every header and month action inert';
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          final FakeClock clock = FakeClock(DateTime.utc(2026, 5, 15, 12));
          int changes = 0;
          await tester.pumpWidget(
            _dateApp(
              AnimalDatePicker(
                key: const ValueKey('disabled-date-picker'),
                selection: AnimalDateSelection.date(AnimalDate(2026, 5, 15)),
                disabled: true,
                clock: clock,
                showToday: true,
                allowClear: true,
                onChanged: (_) => changes++,
              ),
            ),
          );

          final Finder datePanel = find.descendant(
            of: find.byKey(const ValueKey('disabled-date-picker')),
            matching: find.byType(AnimalDatePickerPanel),
          );
          expect(datePanel, findsOneWidget);
          final MaterialLocalizations material = MaterialLocalizations.of(
            tester.element(datePanel),
          );
          final AnimalLocalizations localizations = AnimalLocalizations.of(
            tester.element(datePanel),
          )!;
          final String header = material.formatMonthYear(DateTime.utc(2026, 5));
          expect(
            find.descendant(of: datePanel, matching: find.text(header)),
            findsOneWidget,
          );

          final List<String> headerLabels = <String>[
            localizations.datePickerPreviousYear,
            material.previousMonthTooltip,
            material.nextMonthTooltip,
            localizations.datePickerNextYear,
          ];
          for (final String label in headerLabels) {
            final Finder control = _interactiveLabel(datePanel, label);
            expect(control, findsOneWidget, reason: label);
            final InteractiveRegion region = tester.widget<InteractiveRegion>(
              control,
            );
            expect(region.disabled, isTrue, reason: disabledReason);
            expect(region.onPressed, isNotNull, reason: disabledReason);
            expect(
              tester
                  .getSemantics(control)
                  .getSemanticsData()
                  .hasAction(SemanticsAction.tap),
              isFalse,
              reason: disabledReason,
            );

            // Exercise the live pointer route as well as the handler guard.
            await tester.tap(control);
            await tester.pumpAndSettle();
            expect(
              find.descendant(of: datePanel, matching: find.text(header)),
              findsOneWidget,
              reason: disabledReason,
            );
            region.onPressed!.call();
            await tester.pumpAndSettle();
            expect(
              find.descendant(of: datePanel, matching: find.text(header)),
              findsOneWidget,
              reason: disabledReason,
            );
          }

          final Finder today = find.descendant(
            of: datePanel,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is InteractiveRegion &&
                  widget.semanticLabel == localizations.today,
            ),
          );
          final Finder clear = find.descendant(
            of: datePanel,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is InteractiveRegion &&
                  widget.semanticLabel == localizations.clearDate,
            ),
          );
          expect(today, findsOneWidget);
          expect(clear, findsOneWidget);
          for (final Finder footerAction in <Finder>[today, clear]) {
            final InteractiveRegion region = tester.widget<InteractiveRegion>(
              footerAction,
            );
            expect(region.disabled, isTrue, reason: disabledReason);
            expect(region.onPressed, isNotNull, reason: disabledReason);
            expect(
              tester
                  .getSemantics(footerAction)
                  .getSemanticsData()
                  .hasAction(SemanticsAction.tap),
              isFalse,
              reason: disabledReason,
            );
            await tester.tap(footerAction);
            await tester.pumpAndSettle();
            region.onPressed!.call();
            await tester.pumpAndSettle();
          }

          final Finder selectedDay = _dateCell(AnimalDate(2026, 5, 15));
          final InteractiveRegion selectedDayRegion = tester
              .widget<InteractiveRegion>(selectedDay);
          expect(selectedDayRegion.disabled, isTrue, reason: disabledReason);
          expect(
            selectedDayRegion.onPressed,
            isNotNull,
            reason: disabledReason,
          );
          final List<InteractiveRegion> dateRegions = tester
              .widgetList<InteractiveRegion>(
                find.descendant(
                  of: datePanel,
                  matching: find.byWidgetPredicate((Widget widget) {
                    if (widget is! InteractiveRegion ||
                        widget.key is! ValueKey<String>) {
                      return false;
                    }
                    return (widget.key! as ValueKey<String>).value.startsWith(
                      'date-',
                    );
                  }),
                ),
              )
              .toList();
          expect(dateRegions, isNotEmpty, reason: disabledReason);
          expect(
            dateRegions.every(
              (InteractiveRegion region) =>
                  region.disabled && region.onPressed != null,
            ),
            isTrue,
            reason: disabledReason,
          );
          final Focus rootFocus = tester.widget<Focus>(
            find.descendant(of: datePanel, matching: find.byType(Focus)).first,
          );
          expect(rootFocus.canRequestFocus, isFalse, reason: disabledReason);
          await tester.tap(selectedDay);
          await tester.pumpAndSettle();
          selectedDayRegion.onPressed!.call();
          await tester.pumpAndSettle();

          _focusCell(tester, selectedDay);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(changes, 0);
          expect(
            find.descendant(of: datePanel, matching: find.text(header)),
            findsOneWidget,
          );

          await tester.pumpWidget(
            _dateApp(
              AnimalDatePicker(
                key: const ValueKey('disabled-month-picker'),
                mode: AnimalDatePickerMode.month,
                selection: AnimalDateSelection.date(AnimalDate(2026, 5, 1)),
                disabled: true,
                clock: clock,
                onChanged: (_) => changes++,
              ),
            ),
          );
          final Finder monthPanel = find.descendant(
            of: find.byKey(const ValueKey('disabled-month-picker')),
            matching: find.byType(AnimalDatePickerPanel),
          );
          final Finder may = find.byKey(const ValueKey('month-2026-5'));
          expect(may, findsOneWidget);
          final Finder mayControl = may;
          expect(mayControl, findsOneWidget);
          final InteractiveRegion monthRegion = tester
              .widget<InteractiveRegion>(mayControl);
          expect(monthRegion.disabled, isTrue);
          expect(monthRegion.onPressed, isNotNull);
          expect(
            tester
                .getSemantics(mayControl)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isFalse,
            reason: disabledReason,
          );
          await tester.tap(mayControl);
          await tester.pumpAndSettle();
          monthRegion.onPressed!.call();
          await tester.pumpAndSettle();
          expect(changes, 0);
          expect(
            find.descendant(of: monthPanel, matching: find.text('2026')),
            findsOneWidget,
          );

          // A month can also be disabled independently by its canonical first
          // day. Keep a selected, enabled month and exercise both activation
          // routes on May, whose first day is disabled by the predicate.
          await tester.pumpWidget(
            _dateApp(
              AnimalDatePicker(
                mode: AnimalDatePickerMode.month,
                selection: AnimalDateSelection.date(AnimalDate(2026, 7, 1)),
                disabledDate: (AnimalDate date) =>
                    date == AnimalDate(2026, 5, 1),
                onChanged: (_) => changes++,
              ),
            ),
          );
          final Finder predicateDisabledMonth = _monthCell(2026, 5);
          final InteractiveRegion predicateRegion = tester
              .widget<InteractiveRegion>(predicateDisabledMonth);
          expect(predicateRegion.disabled, isTrue, reason: disabledReason);
          expect(
            tester
                .getSemantics(predicateDisabledMonth)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isFalse,
            reason: disabledReason,
          );
          await tester.tap(predicateDisabledMonth);
          await tester.pumpAndSettle();
          predicateRegion.onPressed!.call();
          await tester.pumpAndSettle();
          expect(changes, 0, reason: disabledReason);

          await tester.pumpWidget(
            _dateApp(
              AnimalDatePicker(
                selection: AnimalDateSelection.date(AnimalDate(2026, 5, 15)),
                firstDate: AnimalDate(2026, 5, 15),
                lastDate: AnimalDate(2026, 5, 15),
                onChanged: (_) => changes++,
              ),
            ),
          );
          final Finder boundaryPanel = find.byType(AnimalDatePickerPanel);
          final MaterialLocalizations boundaryMaterial =
              MaterialLocalizations.of(tester.element(boundaryPanel));
          final AnimalLocalizations boundaryLocalizations =
              AnimalLocalizations.of(tester.element(boundaryPanel))!;
          final List<String> boundaryLabels = <String>[
            boundaryLocalizations.datePickerPreviousYear,
            boundaryMaterial.previousMonthTooltip,
            boundaryMaterial.nextMonthTooltip,
            boundaryLocalizations.datePickerNextYear,
          ];
          for (final String label in boundaryLabels) {
            final Finder control = _interactiveLabel(boundaryPanel, label);
            expect(control, findsOneWidget, reason: label);
            expect(tester.widget<InteractiveRegion>(control).disabled, isTrue);
            expect(
              tester
                  .getSemantics(control)
                  .getSemanticsData()
                  .hasAction(SemanticsAction.tap),
              isFalse,
              reason: disabledReason,
            );
            await tester.tap(control);
            await tester.pumpAndSettle();
            expect(
              find.descendant(
                of: boundaryPanel,
                matching: find.text(
                  boundaryMaterial.formatMonthYear(DateTime.utc(2026, 5)),
                ),
              ),
              findsOneWidget,
              reason: disabledReason,
            );
          }
          expect(changes, 0, reason: disabledReason);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets('DAT03: range selection is a parent-committed nullable union', (
      tester,
    ) async {
      AnimalDateSelection? selection;
      final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _dateApp(
            AnimalDatePicker(
              mode: AnimalDatePickerMode.range,
              selection: selection,
              clock: FakeClock(DateTime.utc(2026, 9, 1)),
              onChanged: (next) {
                proposals.add(next);
                setState(() => selection = next);
              },
            ),
          ),
        ),
      );

      await _tapDate(tester, AnimalDate(2026, 9, 12));
      expect(selection, isA<AnimalDateRangeSelection>());
      AnimalDateRangeSelection range = selection! as AnimalDateRangeSelection;
      expect(range.start, AnimalDate(2026, 9, 12));
      expect(range.end, isNull);

      // Selecting before the draft start normalizes the completed range.
      await _tapDate(tester, AnimalDate(2026, 9, 8));
      range = selection! as AnimalDateRangeSelection;
      expect(range.start, AnimalDate(2026, 9, 8));
      expect(range.end, AnimalDate(2026, 9, 12));
      expect(proposals, hasLength(2));

      // A completed range is followed by a fresh parent-controlled draft.
      await _tapDate(tester, AnimalDate(2026, 9, 20));
      range = selection! as AnimalDateRangeSelection;
      expect(range.start, AnimalDate(2026, 9, 20));
      expect(range.end, isNull);
      expect(proposals, hasLength(3));
    });

    testWidgets('DAT03: rejected range drafts do not become local state', (
      tester,
    ) async {
      final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
      await tester.pumpWidget(
        _dateApp(
          AnimalDatePicker(
            mode: AnimalDatePickerMode.range,
            clock: FakeClock(DateTime.utc(2026, 9, 1)),
            onChanged: proposals.add,
          ),
        ),
      );

      await _tapDate(tester, AnimalDate(2026, 9, 12));
      await _tapDate(tester, AnimalDate(2026, 9, 8));
      expect(proposals, <AnimalDateSelection?>[
        AnimalDateSelection.range(start: AnimalDate(2026, 9, 12)),
        AnimalDateSelection.range(start: AnimalDate(2026, 9, 8)),
      ]);
    });

    testWidgets(
      'DAT03: disabled range endpoints and interior days reject proposals',
      (tester) async {
        AnimalDateSelection? selection;
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) => _dateApp(
              AnimalDatePicker(
                mode: AnimalDatePickerMode.range,
                selection: selection,
                clock: FakeClock(DateTime.utc(2026, 9, 1)),
                disabledDate: (AnimalDate date) =>
                    date == AnimalDate(2026, 9, 8) ||
                    date == AnimalDate(2026, 9, 10) ||
                    date == AnimalDate(2026, 9, 12),
                onChanged: (next) {
                  proposals.add(next);
                  setState(() => selection = next);
                },
              ),
            ),
          ),
        );

        final Finder disabledStart = _dateCell(AnimalDate(2026, 9, 8));
        expect(
          tester.widget<InteractiveRegion>(disabledStart).disabled,
          isTrue,
        );
        await _tapVisibleDisabledDate(tester, disabledStart);
        expect(proposals, isEmpty);

        await _tapDate(tester, AnimalDate(2026, 9, 9));
        expect(proposals, hasLength(1));
        final AnimalDateSelection? committedDraft = selection;
        final Finder disabledEnd = _dateCell(AnimalDate(2026, 9, 12));
        expect(tester.widget<InteractiveRegion>(disabledEnd).disabled, isTrue);
        await _tapVisibleDisabledDate(tester, disabledEnd);
        expect(proposals, hasLength(1));

        await _tapDate(tester, AnimalDate(2026, 9, 11));
        expect(proposals, hasLength(1));
        expect(selection, committedDraft);
        expect(
          selection,
          AnimalDateSelection.range(start: AnimalDate(2026, 9, 9)),
        );
        _focusCell(tester, _dateCell(AnimalDate(2026, 9, 9)));
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, _dateCell(AnimalDate(2026, 9, 11))), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, _dateCell(AnimalDate(2026, 9, 13))), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(proposals, hasLength(1));
        expect(selection, committedDraft);
      },
    );

    testWidgets('DAT03: Today and Clear propose mode-shaped values', (
      tester,
    ) async {
      final FakeClock clock = FakeClock(DateTime.utc(2026, 11, 1, 23, 30));
      final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
      await tester.pumpWidget(
        _dateApp(
          AnimalDatePicker(
            mode: AnimalDatePickerMode.range,
            clock: clock,
            showToday: true,
            allowClear: true,
            onChanged: proposals.add,
          ),
        ),
      );

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(proposals, hasLength(1));
      expect(
        proposals.single,
        AnimalDateSelection.range(start: AnimalDate(2026, 11, 1)),
      );

      await tester.pumpWidget(
        _dateApp(
          AnimalDatePicker(
            mode: AnimalDatePickerMode.range,
            selection: AnimalDateSelection.range(
              start: AnimalDate(2026, 10, 30),
              end: AnimalDate(2026, 11, 2),
            ),
            clock: clock,
            showToday: true,
            allowClear: true,
            onChanged: proposals.add,
          ),
        ),
      );
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(proposals, hasLength(2));
      expect(proposals.last, isNull);

      await tester.pumpWidget(
        _dateApp(
          AnimalDatePicker(
            mode: AnimalDatePickerMode.range,
            clock: clock,
            showToday: false,
            allowClear: true,
            onChanged: proposals.add,
          ),
        ),
      );
      final Finder emptyClear = _interactiveLabel(
        find.byType(AnimalDatePickerPanel),
        AnimalLocalizations.of(
          tester.element(find.byType(AnimalDatePickerPanel)),
        )!.clearDate,
      );
      expect(tester.widget<InteractiveRegion>(emptyClear).disabled, isTrue);
      await tester.tap(emptyClear);
      await tester.pumpAndSettle();
      expect(proposals, hasLength(2));
    });

    testWidgets('DAT03: month selection and Today both return the first day', (
      tester,
    ) async {
      final FakeClock clock = FakeClock(DateTime.utc(2026, 11, 1, 13));
      AnimalDateSelection? proposal;
      await tester.pumpWidget(
        _dateApp(
          AnimalDatePicker(
            mode: AnimalDatePickerMode.month,
            clock: clock,
            showToday: true,
            onChanged: (next) => proposal = next,
          ),
        ),
      );

      await tester.tap(find.text('May'));
      await tester.pumpAndSettle();
      expect(proposal, isA<AnimalDateSingleSelection>());
      expect(
        (proposal! as AnimalDateSingleSelection).date,
        AnimalDate(2026, 5, 1),
      );

      proposal = null;
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(proposal, isA<AnimalDateSingleSelection>());
      expect(
        (proposal! as AnimalDateSingleSelection).date,
        AnimalDate(2026, 11, 1),
      );
    });

    testWidgets(
      'DAT04: header navigation retargets keyboard focus in the visible month',
      (tester) async {
        final AnimalDateSelection originalSelection = AnimalDateSelection.date(
          AnimalDate(2026, 9, 15),
        );
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];

        await tester.pumpWidget(
          _dateApp(
            AnimalDatePicker(
              selection: originalSelection,
              onChanged: proposals.add,
            ),
          ),
        );

        final Finder panel = find.byType(AnimalDatePickerPanel);
        final MaterialLocalizations material = MaterialLocalizations.of(
          tester.element(panel),
        );
        final Finder nextMonth = _interactiveLabel(
          panel,
          material.nextMonthTooltip,
        );
        await tester.tap(nextMonth);
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: panel,
            matching: find.text(
              material.formatMonthYear(DateTime.utc(2026, 10)),
            ),
          ),
          findsOneWidget,
        );
        expect(
          originalSelection,
          AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
        );
        expect(proposals, isEmpty);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        final Finder october16 = _dateCell(AnimalDate(2026, 10, 16));
        expect(_isFocused(tester, october16), isTrue);
        expect(
          originalSelection,
          AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
        );
        expect(proposals, isEmpty);
        expect(
          find.descendant(
            of: panel,
            matching: find.text(
              material.formatMonthYear(DateTime.utc(2026, 10)),
            ),
          ),
          findsOneWidget,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(proposals, <AnimalDateSelection?>[
          AnimalDateSelection.date(AnimalDate(2026, 10, 16)),
        ]);
        expect(
          originalSelection,
          AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
        );
      },
    );

    testWidgets(
      'DAT02: month year navigation selects the nearest enabled month',
      (tester) async {
        final AnimalDateSelection selection = AnimalDateSelection.date(
          AnimalDate(2026, 1, 1),
        );
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        await tester.pumpWidget(
          _dateApp(
            AnimalDatePicker(
              mode: AnimalDatePickerMode.month,
              selection: selection,
              firstDate: AnimalDate(2025, 6, 15),
              onChanged: proposals.add,
            ),
          ),
        );

        final Finder panel = find.byType(AnimalDatePickerPanel);
        final MaterialLocalizations material = MaterialLocalizations.of(
          tester.element(panel),
        );
        final AnimalLocalizations localizations = AnimalLocalizations.of(
          tester.element(panel),
        )!;
        final Finder previousYear = _interactiveLabel(
          panel,
          localizations.datePickerPreviousYear,
        );
        expect(
          tester.widget<InteractiveRegion>(previousYear).disabled,
          isFalse,
        );
        await tester.tap(previousYear);
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: panel,
            matching: find.text(material.formatYear(DateTime.utc(2025))),
          ),
          findsOneWidget,
        );
        expect(_isFocused(tester, _monthCell(2025, 7)), isTrue);
        expect(selection, AnimalDateSelection.date(AnimalDate(2026, 1, 1)));
        expect(proposals, isEmpty);
      },
    );

    testWidgets('DAT04: date keyboard follows civil day and month boundaries', (
      tester,
    ) async {
      AnimalDateSelection? selection = AnimalDateSelection.date(
        AnimalDate(2026, 3, 31),
      );
      final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _dateApp(
            AnimalDatePicker(
              selection: selection,
              onChanged: (next) {
                proposals.add(next);
                setState(() => selection = next);
              },
            ),
          ),
        ),
      );

      _focusCell(tester, _dateCell(AnimalDate(2026, 3, 31)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 3, 30))), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 3, 31))), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 3, 24))), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 3, 31))), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 3, 29))), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 4, 4))), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 3, 4))), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 4, 4))), isTrue);

      // Shift+PageUp changes the year while preserving the focused month/day.
      _focusCell(tester, _dateCell(AnimalDate(2026, 3, 31)));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2025, 3, 31))), isTrue);
      expect(proposals, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(selection, AnimalDateSelection.date(AnimalDate(2025, 3, 31)));
      expect(proposals, hasLength(1));
    });

    testWidgets('DAT04: PageUp clamps a civil month end to the target month', (
      tester,
    ) async {
      AnimalDateSelection? selection = AnimalDateSelection.date(
        AnimalDate(2026, 3, 31),
      );
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _dateApp(
            AnimalDatePicker(
              selection: selection,
              onChanged: (next) => setState(() => selection = next),
            ),
          ),
        ),
      );

      _focusCell(tester, _dateCell(AnimalDate(2026, 3, 31)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(AnimalDate(2026, 2, 28))), isTrue);
    });

    testWidgets('DAT04: disabled search stays within the target month grid', (
      tester,
    ) async {
      final AnimalDate start = AnimalDate(2026, 9, 1);
      final AnimalDate firstEnabledAfterRun = AnimalDate(2026, 10, 15);
      await tester.pumpWidget(
        _dateApp(
          AnimalDatePicker(
            selection: AnimalDateSelection.date(start),
            disabledDate: (AnimalDate date) =>
                date.isAfter(start) && date.isBefore(firstEnabledAfterRun),
          ),
        ),
      );

      _focusCell(tester, _dateCell(start));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(start)), isTrue);

      // A page key changes the target month, where the bounded grid search
      // reaches the first enabled date after the disabled run.
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(_isFocused(tester, _dateCell(firstEnabledAfterRun)), isTrue);
    });

    testWidgets('DAT04: Home and End clamp at civil year boundaries', (
      tester,
    ) async {
      for (final ({AnimalDate date, LogicalKeyboardKey key}) fixture
          in <({AnimalDate date, LogicalKeyboardKey key})>[
            (date: AnimalDate(1, 1, 1), key: LogicalKeyboardKey.home),
            (date: AnimalDate(9999, 12, 31), key: LogicalKeyboardKey.end),
          ]) {
        await tester.pumpWidget(
          _dateApp(
            AnimalDatePicker(selection: AnimalDateSelection.date(fixture.date)),
          ),
        );
        final Finder boundaryCell = _dateCell(fixture.date);
        _focusCell(tester, boundaryCell);
        await tester.pump();
        await tester.sendKeyEvent(fixture.key);
        await tester.pumpAndSettle();
        expect(
          _isFocused(tester, boundaryCell),
          isTrue,
          reason: 'Week movement clamps inside the supported civil domain.',
        );
      }
    });

    testWidgets(
      'DAT04: RTL arrows follow physical direction and Space activates',
      (tester) async {
        AnimalDateSelection? selection = AnimalDateSelection.date(
          AnimalDate(2026, 9, 15),
        );
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) => _dateApp(
              Directionality(
                textDirection: TextDirection.rtl,
                child: AnimalDatePicker(
                  selection: selection,
                  onChanged: (next) {
                    proposals.add(next);
                    setState(() => selection = next);
                  },
                ),
              ),
            ),
          ),
        );

        _focusCell(tester, _dateCell(AnimalDate(2026, 9, 15)));
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, _dateCell(AnimalDate(2026, 9, 16))), isTrue);
        expect(proposals, isEmpty);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(selection, AnimalDateSelection.date(AnimalDate(2026, 9, 16)));
        expect(proposals, hasLength(1));
      },
    );

    testWidgets('DAT04: month keyboard follows the visible three-column grid', (
      tester,
    ) async {
      final variants = <({AnimalIslandTheme theme, TextDirection direction})>[
        (theme: AnimalIslandTheme.light, direction: TextDirection.ltr),
        (theme: AnimalIslandTheme.dark, direction: TextDirection.rtl),
        (
          theme: AnimalIslandTheme.light.copyWith(
            // A wide xs gap; the larger steps rise with it to keep the scale
            // ordered.
            spacing: AnimalThemeSpacing.standard.copyWith(
              xs: 20,
              sm: 20,
              md: 20,
              lg: 20,
            ),
          ),
          direction: TextDirection.rtl,
        ),
      ];

      for (final variant in variants) {
        AnimalDateSelection? selection = AnimalDateSelection.date(
          AnimalDate(2026, 5, 1),
        );
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        await tester.pumpWidget(
          _dateApp(
            Directionality(
              textDirection: variant.direction,
              child: StatefulBuilder(
                builder: (context, setState) => AnimalDatePicker(
                  mode: AnimalDatePickerMode.month,
                  selection: selection,
                  onChanged: (next) {
                    proposals.add(next);
                    setState(() => selection = next);
                  },
                ),
              ),
            ),
            theme: variant.theme,
          ),
        );

        _focusCell(tester, _monthCell(2026, 5));
        await tester.pump();
        final List<Rect> monthRects = <Rect>[
          for (int month = 1; month <= 12; month++)
            tester.getRect(_monthCell(2026, month)),
        ];
        expect(monthRects.every((Rect rect) => rect.width == 86), isTrue);
        expect(monthRects.every((Rect rect) => rect.height == 48), isTrue);
        final double firstRowTop = monthRects.first.top;
        expect(
          monthRects
              .where((Rect rect) => (rect.top - firstRowTop).abs() < 1)
              .length,
          3,
        );
        final List<double> rowTops = <double>[];
        final List<double> columnCenters = <double>[];
        for (final Rect rect in monthRects) {
          if (!rowTops.any((double top) => (top - rect.top).abs() < 1)) {
            rowTops.add(rect.top);
          }
          if (!columnCenters.any(
            (double center) => (center - rect.center.dx).abs() < 1,
          )) {
            columnCenters.add(rect.center.dx);
          }
        }
        expect(rowTops, hasLength(4));
        expect(columnCenters, hasLength(3));

        final LogicalKeyboardKey forwardPhysicalKey =
            variant.direction == TextDirection.rtl
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.arrowRight;
        await tester.sendKeyEvent(forwardPhysicalKey);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, _monthCell(2026, 6)), isTrue);

        _focusCell(tester, _monthCell(2026, 5));
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        const int nextMonthInColumn = 8;
        expect(_isFocused(tester, _monthCell(2026, nextMonthInColumn)), isTrue);
        final List<Rect> settledMonthRects = <Rect>[
          for (int month = 1; month <= 12; month++)
            tester.getRect(_monthCell(2026, month)),
        ];
        final Rect settledMayRect = settledMonthRects[4];
        final Rect nextRowRect = settledMonthRects[nextMonthInColumn - 1];
        expect(nextRowRect.center.dx, closeTo(settledMayRect.center.dx, 1));
        expect(nextRowRect.top, greaterThan(settledMayRect.top));
        final List<double> lowerRowsInMayColumn = settledMonthRects
            .where(
              (Rect rect) =>
                  rect.top > settledMayRect.top &&
                  (rect.center.dx - settledMayRect.center.dx).abs() < 1,
            )
            .map((Rect rect) => rect.top)
            .toList();
        expect(lowerRowsInMayColumn, isNotEmpty);
        final double nearestLowerRowTop = lowerRowsInMayColumn.reduce(
          (double earlier, double later) => earlier < later ? earlier : later,
        );
        expect(
          nextRowRect.top,
          closeTo(nearestLowerRowTop, 1),
          reason:
              'ArrowDown focuses the nearest visible row in the same column',
        );
        final Finder monthViewport = find.descendant(
          of: find.byType(AnimalDatePickerPanel),
          matching: find.byType(SingleChildScrollView),
        );
        expect(monthViewport, findsOneWidget);
        final Rect visibleNextRowRect = nextRowRect.intersect(
          tester.getRect(monthViewport),
        );
        expect(visibleNextRowRect.width, nextRowRect.width);
        expect(visibleNextRowRect.height, nextRowRect.height);

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, _monthCell(2026, 1)), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, _monthCell(2026, 12)), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, _monthCell(2025, 12)), isTrue);
        final MaterialLocalizations material = MaterialLocalizations.of(
          tester.element(find.byType(AnimalDatePickerPanel)),
        );
        expect(
          find.text(material.formatYear(DateTime.utc(2025))),
          findsOneWidget,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();
        expect(
          find.text(material.formatYear(DateTime.utc(2026))),
          findsOneWidget,
        );
        expect(_isFocused(tester, _monthCell(2026, 12)), isTrue);
        expect(proposals, isEmpty);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(selection, AnimalDateSelection.date(AnimalDate(2026, 12, 1)));
        expect(proposals, hasLength(1));
      }
    });

    testWidgets(
      'DAT05: selected range popover remains usable at 320dp, 2x and IME inset',
      (tester) async {
        tester.view.physicalSize = const Size(640, 1600);
        tester.view.devicePixelRatio = 2;
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.view.resetViewInsets();
        });

        AnimalDateSelection? selection = AnimalDateSelection.range(
          start: AnimalDate(2026, 9, 12),
          end: AnimalDate(2026, 9, 18),
        );
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        await tester.pumpWidget(
          _dateApp(
            Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (BuildContext context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: SizedBox(
                    width: 320,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: StatefulBuilder(
                        builder: (context, setState) =>
                            AnimalDatePicker.popover(
                              key: const ValueKey('narrow-range-picker'),
                              mode: AnimalDatePickerMode.range,
                              selection: selection,
                              clock: FakeClock(DateTime.utc(2026, 9, 1)),
                              onChanged: (next) {
                                proposals.add(next);
                                setState(() => selection = next);
                              },
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        final Finder trigger = find.byKey(
          const ValueKey('narrow-range-picker'),
        );
        final MaterialLocalizations material = MaterialLocalizations.of(
          tester.element(trigger),
        );
        final String startLabel = material.formatMediumDate(
          DateTime.utc(2026, 9, 12),
        );
        final String endLabel = material.formatMediumDate(
          DateTime.utc(2026, 9, 18),
        );
        final Finder triggerText = find.descendant(
          of: trigger,
          matching: find.text('$startLabel – $endLabel'),
        );
        expect(triggerText, findsOneWidget);
        final Rect triggerRect = tester.getRect(trigger);
        expect(triggerRect.left, greaterThanOrEqualTo(0));
        expect(triggerRect.right, lessThanOrEqualTo(320));
        final RenderParagraph triggerParagraph = tester
            .renderObject<RenderParagraph>(triggerText);
        final List<LineMetrics> triggerLines = _paragraphLineMetrics(
          triggerParagraph,
        );
        expect(triggerLines.length, greaterThan(1));
        expect(
          triggerParagraph.size.height,
          greaterThanOrEqualTo(
            triggerLines.fold<double>(
                  0,
                  (double total, LineMetrics line) => total + line.height,
                ) -
                0.5,
          ),
        );
        final Rect triggerTextRect = tester.getRect(triggerText);
        expect(triggerTextRect.left, greaterThanOrEqualTo(triggerRect.left));
        expect(triggerTextRect.right, lessThanOrEqualTo(triggerRect.right));
        expect(triggerTextRect.top, greaterThanOrEqualTo(triggerRect.top));
        expect(triggerTextRect.bottom, lessThanOrEqualTo(triggerRect.bottom));

        final Finder clearIcon = find.descendant(
          of: trigger,
          matching: find.byWidgetPredicate(
            (w) => w is AnimalIcon && w.data == AnimalIcons.close,
          ),
        );
        expect(clearIcon, findsOneWidget);
        final Finder clearRegion = find
            .ancestor(of: clearIcon, matching: find.byType(InteractiveRegion))
            .first;
        final Rect clearRect = tester.getRect(clearRegion);
        expect(clearRect.width, greaterThanOrEqualTo(48));
        expect(clearRect.height, greaterThanOrEqualTo(48));
        await tester.tap(trigger);
        await tester.pumpAndSettle();
        final Finder panel = find.byType(AnimalDatePickerPanel);
        expect(panel, findsOneWidget);
        final MediaQueryData panelMedia = MediaQuery.of(tester.element(panel));
        final Rect availableScreen = Rect.fromLTWH(
          0,
          0,
          panelMedia.size.width,
          panelMedia.size.height - panelMedia.viewInsets.bottom,
        );
        final Finder menuViewport = _verticalMenuViewport(panel);
        final Rect menuViewportRect = tester.getRect(menuViewport);
        expect(
          menuViewportRect.left,
          greaterThanOrEqualTo(availableScreen.left),
        );
        expect(
          menuViewportRect.right,
          lessThanOrEqualTo(availableScreen.right),
        );
        expect(menuViewportRect.top, greaterThanOrEqualTo(availableScreen.top));
        expect(
          menuViewportRect.bottom,
          lessThanOrEqualTo(availableScreen.bottom),
        );
        final Finder dateGridViewport = _horizontalDateViewport(panel);

        final Finder focusedStartCell = _dateCell(AnimalDate(2026, 9, 12));
        _focusCell(tester, focusedStartCell);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, focusedStartCell), isTrue);
        final Rect focusedStartRect = tester.getRect(focusedStartCell);
        final Rect focusedDateGridViewportRect = tester.getRect(
          dateGridViewport,
        );
        expect(
          focusedStartRect.intersect(menuViewportRect).size,
          focusedStartRect.size,
          reason: 'The focused date cell remains visible above the IME.',
        );
        expect(
          focusedStartRect.intersect(focusedDateGridViewportRect).size,
          focusedStartRect.size,
          reason: 'The focused date cell remains visible in the date grid.',
        );

        final Rect startCellRect = await _tapDateIn(
          tester,
          panel,
          AnimalDate(2026, 9, 20),
        );
        expect(menuViewportRect.contains(startCellRect.center), isTrue);
        expect(
          selection,
          AnimalDateSelection.range(start: AnimalDate(2026, 9, 20)),
        );
        expect(find.byType(AnimalDatePickerPanel), findsOneWidget);
        final Rect endCellRect = await _tapDateIn(
          tester,
          find.byType(AnimalDatePickerPanel),
          AnimalDate(2026, 9, 16),
        );
        expect(menuViewportRect.contains(endCellRect.center), isTrue);
        expect(
          selection,
          AnimalDateSelection.range(
            start: AnimalDate(2026, 9, 16),
            end: AnimalDate(2026, 9, 20),
          ),
        );
        expect(proposals, hasLength(2));
        expect(find.byType(AnimalDatePickerPanel), findsNothing);
        expect(
          find.text(
            '${material.formatMediumDate(DateTime.utc(2026, 9, 16))} – '
            '${material.formatMediumDate(DateTime.utc(2026, 9, 20))}',
          ),
          findsOneWidget,
        );
        final Rect clearRectAfterSelection = tester.getRect(clearRegion);
        expect(
          availableScreen.contains(clearRectAfterSelection.center),
          isTrue,
        );
        await tester.tapAt(clearRectAfterSelection.center);
        await tester.pumpAndSettle();
        expect(selection, isNull);
        expect(proposals, hasLength(3));
      },
    );

    testWidgets(
      'DAT05: popover clear and dismissal restore borrowed trigger focus',
      (tester) async {
        final FocusNode triggerFocus = FocusNode(
          debugLabel: 'borrowed-date-picker-trigger',
        );
        addTearDown(triggerFocus.dispose);
        AnimalDateSelection? selection = AnimalDateSelection.date(
          AnimalDate(2026, 9, 15),
        );
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        int outsideTaps = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Stack(
                children: <Widget>[
                  Positioned(
                    top: 8,
                    left: 8,
                    child: StatefulBuilder(
                      builder: (context, setState) => AnimalDatePicker.popover(
                        key: const ValueKey('borrowed-focus-picker'),
                        selection: selection,
                        focusNode: triggerFocus,
                        onChanged: (next) {
                          proposals.add(next);
                          setState(() => selection = next);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      key: const ValueKey('outside-dismiss-target'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => outsideTaps++,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Outside'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final Finder trigger = find.byKey(
          const ValueKey('borrowed-focus-picker'),
        );
        final AnimalLocalizations localizations = AnimalLocalizations.of(
          tester.element(trigger),
        )!;
        final Finder panel = find.byType(AnimalDatePickerPanel);

        await tester.tap(trigger);
        await tester.pumpAndSettle();
        expect(panel, findsOneWidget);
        final Finder panelClear = find.descendant(
          of: panel,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is InteractiveRegion &&
                widget.semanticLabel == localizations.clearDate,
          ),
        );
        expect(panelClear, findsOneWidget);
        await tester.tap(panelClear);
        await tester.pumpAndSettle();
        expect(proposals, <AnimalDateSelection?>[null]);
        expect(selection, isNull);
        expect(panel, findsNothing);
        expect(triggerFocus.hasFocus, isTrue);

        await tester.tap(trigger);
        await tester.pumpAndSettle();
        expect(panel, findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(panel, findsNothing);
        expect(proposals, <AnimalDateSelection?>[null]);
        expect(triggerFocus.hasFocus, isTrue);

        await tester.tap(trigger);
        await tester.pumpAndSettle();
        expect(panel, findsOneWidget);
        final Finder outside = find.byKey(
          const ValueKey('outside-dismiss-target'),
        );
        expect(
          tester.getRect(outside).overlaps(tester.getRect(panel)),
          isFalse,
        );
        await tester.tap(outside);
        await tester.pumpAndSettle();
        expect(outsideTaps, 1);
        expect(panel, findsNothing);
        expect(proposals, <AnimalDateSelection?>[null]);
        expect(triggerFocus.hasFocus, isTrue);

        await tester.pumpWidget(
          MaterialApp(
            home: Focus(
              focusNode: triggerFocus,
              child: const SizedBox(width: 48, height: 48),
            ),
          ),
        );
        triggerFocus.requestFocus();
        await tester.pump();
        expect(triggerFocus.hasPrimaryFocus, isTrue);
      },
    );

    testWidgets(
      'DAT04: 320px, 2x, RTL and keyboard insets keep 48dp dates usable',
      (tester) async {
        tester.view.physicalSize = const Size(640, 1600);
        tester.view.devicePixelRatio = 2;
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        final AnimalDateSelection parentSelection = AnimalDateSelection.date(
          AnimalDate(2026, 9, 15),
        );
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.view.resetViewInsets();
        });

        await tester.pumpWidget(
          _dateApp(
            Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (BuildContext context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: SizedBox(
                    width: 320,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: AnimalDatePicker.popover(
                        key: const ValueKey('narrow-date-picker'),
                        selection: parentSelection,
                        onChanged: proposals.add,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const ValueKey('narrow-date-picker')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final Finder panel = find.byType(AnimalDatePickerPanel);
        expect(panel, findsOneWidget);
        final MediaQueryData panelMedia = MediaQuery.of(tester.element(panel));
        final Rect availableScreen = Rect.fromLTWH(
          0,
          0,
          panelMedia.size.width,
          panelMedia.size.height - panelMedia.viewInsets.bottom,
        );
        final Finder menuViewport = _verticalMenuViewport(panel);
        final Rect menuViewportRect = tester.getRect(menuViewport);
        expect(
          menuViewportRect.left,
          greaterThanOrEqualTo(availableScreen.left),
        );
        expect(
          menuViewportRect.right,
          lessThanOrEqualTo(availableScreen.right),
        );
        expect(menuViewportRect.top, greaterThanOrEqualTo(availableScreen.top));
        expect(
          menuViewportRect.bottom,
          lessThanOrEqualTo(availableScreen.bottom),
        );
        final Finder dateGridViewport = _horizontalDateViewport(panel);
        final Finder focusedCell = _dateCell(AnimalDate(2026, 9, 15));
        final Rect cellRect = tester.getRect(focusedCell);
        expect(cellRect.width, 48);
        expect(cellRect.height, greaterThanOrEqualTo(48));
        _focusCell(tester, focusedCell);
        await tester.pumpAndSettle();
        expect(_isFocused(tester, focusedCell), isTrue);
        final Rect initialFocusRect = tester.getRect(focusedCell);
        final Rect initialDateGridViewportRect = tester.getRect(
          dateGridViewport,
        );
        expect(
          initialFocusRect.intersect(menuViewportRect).size,
          initialFocusRect.size,
        );
        expect(
          initialFocusRect.intersect(initialDateGridViewportRect).size,
          initialFocusRect.size,
        );
        for (int step = 0; step < 15; step++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pumpAndSettle();
        }
        final Finder movedFocus = _dateCell(AnimalDate(2026, 9, 30));
        expect(_isFocused(tester, movedFocus), isTrue);
        final Rect movedRect = tester.getRect(movedFocus);
        final Rect movedDateGridViewportRect = tester.getRect(dateGridViewport);
        expect(movedRect.width, 48);
        expect(movedRect.height, greaterThanOrEqualTo(48));
        expect(movedRect.intersect(menuViewportRect).size, movedRect.size);
        expect(
          movedRect.intersect(movedDateGridViewportRect).size,
          movedRect.size,
        );
        expect(availableScreen.contains(movedRect.center), isTrue);
        final List<AnimalDate> firstWeek = <AnimalDate>[
          for (int day = -2; day <= 4; day++)
            AnimalDate(2026, 9, 1).addDays(day),
        ];
        final List<Rect> firstWeekRects = <Rect>[
          for (final AnimalDate date in firstWeek)
            tester.getRect(_dateCell(date)),
        ];
        expect(firstWeekRects, hasLength(7));
        expect(firstWeekRects.every((Rect rect) => rect.width == 48), isTrue);
        final List<double> sortedLefts =
            firstWeekRects.map((Rect rect) => rect.left).toList()..sort();
        for (int index = 1; index < sortedLefts.length; index++) {
          expect(sortedLefts[index] - sortedLefts[index - 1], 48);
        }
        await tester.tapAt(movedRect.center);
        await tester.pumpAndSettle();
        expect(proposals, <AnimalDateSelection?>[
          AnimalDateSelection.date(AnimalDate(2026, 9, 30)),
        ]);
        expect(
          parentSelection,
          AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DAT05: AnimalDatePicker.popover opens panel on tap and displays selected date',
      (tester) async {
        AnimalDateSelection? proposal;
        await tester.pumpWidget(
          _dateApp(
            AnimalDatePicker.popover(
              key: const ValueKey('date-picker'),
              selection: AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
              onChanged: (value) => proposal = value,
            ),
          ),
        );

        final MaterialLocalizations material = MaterialLocalizations.of(
          tester.element(find.byKey(const ValueKey('date-picker'))),
        );
        final String selectedLabel = material.formatMediumDate(
          DateTime.utc(2026, 9, 15),
        );
        expect(find.text(selectedLabel), findsOneWidget);
        await tester.tap(find.text(selectedLabel));
        await tester.pumpAndSettle();
        await _tapDate(tester, AnimalDate(2026, 9, 20));
        expect(proposal, AnimalDateSelection.date(AnimalDate(2026, 9, 20)));
      },
    );

    testWidgets('DAT05: inline and popover propose the same date sequence', (
      tester,
    ) async {
      final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
      await tester.pumpWidget(
        _dateApp(
          Column(
            children: [
              AnimalDatePicker(
                key: const ValueKey('inline'),
                selection: AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
                onChanged: proposals.add,
              ),
              AnimalDatePicker.popover(
                key: const ValueKey('popover'),
                selection: AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
                onChanged: proposals.add,
              ),
            ],
          ),
        ),
      );

      await tester.tap(_dateCell(AnimalDate(2026, 9, 20)).first);
      await tester.pumpAndSettle();
      final Finder trigger = find.byKey(const ValueKey('popover'));
      await tester.tap(trigger);
      await tester.pumpAndSettle();
      await _tapDateIn(
        tester,
        find.byType(AnimalDatePickerPanel).last,
        AnimalDate(2026, 9, 20),
      );
      expect(proposals, <AnimalDateSelection?>[
        AnimalDateSelection.date(AnimalDate(2026, 9, 20)),
        AnimalDateSelection.date(AnimalDate(2026, 9, 20)),
      ]);
    });

    testWidgets(
      'DAT05: range popover remains open for a draft and closes when complete',
      (tester) async {
        AnimalDateSelection? selection;
        final List<AnimalDateSelection?> proposals = <AnimalDateSelection?>[];
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) => _dateApp(
              AnimalDatePicker.popover(
                key: const ValueKey('range-popover'),
                mode: AnimalDatePickerMode.range,
                selection: selection,
                clock: FakeClock(DateTime.utc(2026, 9, 1)),
                onChanged: (next) {
                  proposals.add(next);
                  setState(() => selection = next);
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const ValueKey('range-popover')));
        await tester.pumpAndSettle();
        await _tapDate(tester, AnimalDate(2026, 9, 12));
        expect(
          selection,
          AnimalDateSelection.range(start: AnimalDate(2026, 9, 12)),
        );
        expect(find.byType(AnimalDatePickerPanel), findsOneWidget);

        await _tapDate(tester, AnimalDate(2026, 9, 18));
        expect(
          selection,
          AnimalDateSelection.range(
            start: AnimalDate(2026, 9, 12),
            end: AnimalDate(2026, 9, 18),
          ),
        );
        expect(proposals, hasLength(2));
        expect(find.byType(AnimalDatePickerPanel), findsNothing);
      },
    );
  });
}

Widget _dateApp(Widget child, {AnimalIslandTheme? theme}) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
  home: Scaffold(body: child),
);

Finder _dateCell(AnimalDate date) =>
    find.byKey(ValueKey<String>('date-${date.toIso8601String()}'));

Finder _monthCell(int year, int month) =>
    find.byKey(ValueKey<String>('month-$year-$month'));

Finder _verticalMenuViewport(Finder panel) => find
    .ancestor(
      of: panel,
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    )
    .first;

Finder _horizontalDateViewport(Finder panel) => find
    .descendant(
      of: panel,
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      ),
    )
    .first;

Finder _interactiveLabel(Finder scope, String label) => find.descendant(
  of: scope,
  matching: find.byWidgetPredicate(
    (Widget widget) =>
        widget is InteractiveRegion && widget.semanticLabel == label,
  ),
);

Future<void> _tapDate(WidgetTester tester, AnimalDate date) async {
  final Finder cell = _dateCell(date);
  expect(cell, findsOneWidget, reason: 'Date cell ${date.toIso8601String()}');
  await tester.ensureVisible(cell);
  await tester.tap(cell);
  await tester.pumpAndSettle();
}

Future<Rect> _tapDateIn(
  WidgetTester tester,
  Finder scope,
  AnimalDate date,
) async {
  final Finder cell = find.descendant(of: scope, matching: _dateCell(date));
  expect(cell, findsOneWidget, reason: 'Date cell ${date.toIso8601String()}');
  await tester.ensureVisible(cell);
  await tester.pumpAndSettle();
  final Rect cellRect = tester.getRect(cell);
  await tester.tapAt(cellRect.center);
  await tester.pumpAndSettle();
  return cellRect;
}

Future<void> _tapVisibleDisabledDate(WidgetTester tester, Finder cell) async {
  await tester.ensureVisible(cell);
  await tester.pumpAndSettle();
  final Rect cellRect = tester.getRect(cell);
  final Rect viewportRect = tester.getRect(
    _horizontalDateViewport(find.byType(AnimalDatePickerPanel)),
  );
  final Rect visibleCellRect = cellRect.intersect(viewportRect);
  expect(visibleCellRect.width, closeTo(cellRect.width, 0.5));
  expect(visibleCellRect.height, closeTo(cellRect.height, 0.5));
  await tester.tapAt(cellRect.center);
  await tester.pumpAndSettle();
}

void _focusCell(WidgetTester tester, Finder cell) {
  final Finder focusFinder = find.descendant(
    of: cell,
    matching: find.byType(Focus),
  );
  expect(focusFinder, findsWidgets);
  tester.widget<Focus>(focusFinder.first).focusNode!.requestFocus();
}

bool _isFocused(WidgetTester tester, Finder cell) {
  final Finder focusFinder = find.descendant(
    of: cell,
    matching: find.byType(Focus),
  );
  return focusFinder.evaluate().any(
    (element) => (element.widget as Focus).focusNode?.hasFocus == true,
  );
}

List<LineMetrics> _paragraphLineMetrics(RenderParagraph paragraph) {
  final BoxConstraints constraints = paragraph.constraints;
  final bool boundedWrap =
      paragraph.softWrap || paragraph.overflow == TextOverflow.ellipsis;
  final TextPainter painter =
      TextPainter(
        text: paragraph.text,
        textAlign: paragraph.textAlign,
        textDirection: paragraph.textDirection,
        textScaler: paragraph.textScaler,
        maxLines: paragraph.maxLines,
        ellipsis: paragraph.overflow == TextOverflow.ellipsis ? '\u2026' : null,
        locale: paragraph.locale,
        strutStyle: paragraph.strutStyle,
        textWidthBasis: paragraph.textWidthBasis,
        textHeightBehavior: paragraph.textHeightBehavior,
      )..layout(
        minWidth: constraints.minWidth,
        maxWidth: boundedWrap ? constraints.maxWidth : double.infinity,
      );
  try {
    return painter.computeLineMetrics();
  } finally {
    painter.dispose();
  }
}
