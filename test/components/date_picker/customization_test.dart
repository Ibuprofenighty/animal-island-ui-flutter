// API06 efficacy and precedence oracles for AnimalDatePicker.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  // Today is 2026-05-20; the selection is 2026-05-14.
  final FakeClock clock = FakeClock(DateTime.utc(2026, 5, 20));

  Future<void> pump(
    WidgetTester tester,
    Widget picker, {
    AnimalIslandTheme? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Align(alignment: Alignment.topLeft, child: picker),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> pumpPicker(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalDatePickerStyle? style,
    AnimalDatePickerMode mode = AnimalDatePickerMode.date,
    AnimalDateSelection? selection,
    bool Function(AnimalDate date)? disabledDate,
  }) => pump(
    tester,
    AnimalDatePicker(
      mode: mode,
      selection:
          selection ??
          (mode == AnimalDatePickerMode.month
              ? AnimalDateSelection.date(AnimalDate(2026, 5, 1))
              : AnimalDateSelection.date(AnimalDate(2026, 5, 14))),
      onChanged: (_) {},
      disabledDate: disabledDate,
      clock: clock,
      style: style,
    ),
    theme: theme,
  );

  Container panel(WidgetTester tester) => tester.widget<Container>(
    find
        .descendant(
          of: find.byType(AnimalDatePickerPanel),
          matching: find.byType(Container),
        )
        .first,
  );
  BoxDecoration panelDecoration(WidgetTester tester) =>
      panel(tester).decoration! as BoxDecoration;

  TextStyle textStyle(WidgetTester tester, Finder finder) =>
      tester.widget<Text>(finder).style!;

  Finder cell(String key) => find.byKey(ValueKey<String>(key));

  Finder dayText(String date, String day) =>
      find.descendant(of: cell('date-$date'), matching: find.text(day));

  BoxDecoration dayFill(WidgetTester tester, String date) =>
      tester
              .widget<Container>(
                find
                    .descendant(
                      of: cell('date-$date'),
                      matching: find.byType(Container),
                    )
                    .last,
              )
              .decoration!
          as BoxDecoration;

  BoxDecoration monthFill(WidgetTester tester, int month) =>
      tester
              .widget<Container>(
                find
                    .descendant(
                      of: cell('month-2026-$month'),
                      matching: find.byType(Container),
                    )
                    .last,
              )
              .decoration!
          as BoxDecoration;

  Icon icon(WidgetTester tester, IconData data) =>
      tester.widget<Icon>(find.byIcon(data));

  AnimalIslandTheme themed(AnimalDatePickerStyle style) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(datePicker: style));

  group('API06 AnimalDatePicker efficacy', () {
    testWidgets('typography token changes reach every text role and mode', (
      tester,
    ) async {
      final AnimalThemeTypography t = AnimalIslandTheme.light.typography;
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        typography: t.copyWith(
          heading: t.heading.copyWith(fontSize: 28),
          body: t.body.copyWith(fontSize: 28),
          caption: t.caption.copyWith(fontSize: 20),
        ),
      );

      await pumpPicker(tester, theme: theme);
      // Heading 15/20 of heading; cells 13/14 of body; weekday and actions
      // follow caption.
      expect(
        textStyle(tester, find.text('May 2026')).fontSize,
        closeTo(21, 1e-9),
      );
      expect(
        textStyle(tester, dayText('2026-05-14', '14')).fontSize,
        closeTo(26, 1e-9),
      );
      expect(textStyle(tester, find.text('M')).fontSize, 20);
      expect(textStyle(tester, find.text('Today')).fontSize, 20);
      expect(textStyle(tester, find.text('Clear')).fontSize, 20);

      await pumpPicker(tester, theme: theme, mode: AnimalDatePickerMode.month);
      expect(textStyle(tester, find.text('2026')).fontSize, closeTo(21, 1e-9));
      expect(textStyle(tester, find.text('May')).fontSize, closeTo(26, 1e-9));
    });

    testWidgets('panel geometry, surface and header fields change the panel', (
      tester,
    ) async {
      await pumpPicker(
        tester,
        style: AnimalDatePickerStyle(
          width: 296,
          padding: const EdgeInsets.all(9),
          borderWidth: 2.5,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          navigationIconSize: 30,
          headerTextStyle: const TextStyle(fontSize: 19),
          weekdayTextStyle: const TextStyle(fontStyle: FontStyle.italic),
          actionTextStyle: const TextStyle(letterSpacing: 2),
          backgroundColor: const Color(0xFF102030),
          borderColor: const WidgetStatePropertyAll<Color>(Color(0xFF0000AA)),
          headerTextColor: const WidgetStatePropertyAll<Color>(
            Color(0xFFAA0000),
          ),
          weekdayTextColor: const Color(0xFF00AA00),
          todayTextColor: const WidgetStatePropertyAll<Color>(
            Color(0xFF00AAAA),
          ),
          clearTextColor: const WidgetStatePropertyAll<Color>(
            Color(0xFFAAAA00),
          ),
        ),
      );

      expect(tester.getSize(find.byType(AnimalDatePickerPanel)).width, 296);
      expect(panel(tester).padding, const EdgeInsets.all(9));
      final BoxDecoration d = panelDecoration(tester);
      expect(d.color, const Color(0xFF102030));
      expect(d.border!.top.color, const Color(0xFF0000AA));
      expect(d.border!.top.width, 2.5);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(5)));
      expect(
        tester.widget<Divider>(find.byType(Divider)).color,
        const Color(0xFF0000AA),
      );

      final TextStyle heading = textStyle(tester, find.text('May 2026'));
      expect(heading.fontSize, 19);
      expect(heading.color, const Color(0xFFAA0000));
      expect(icon(tester, Icons.chevron_left_rounded).size, 30);
      expect(
        icon(tester, Icons.chevron_left_rounded).color,
        const Color(0xFFAA0000),
      );
      expect(
        icon(tester, Icons.keyboard_double_arrow_left_rounded).size,
        closeTo(27, 1e-9),
      );

      final TextStyle weekday = textStyle(tester, find.text('M'));
      expect(weekday.fontStyle, FontStyle.italic);
      expect(weekday.color, const Color(0xFF00AA00));

      final TextStyle today = textStyle(tester, find.text('Today'));
      expect(today.letterSpacing, 2);
      expect(today.color, const Color(0xFF00AAAA));
      final TextStyle clear = textStyle(tester, find.text('Clear'));
      expect(clear.letterSpacing, 2);
      expect(clear.color, const Color(0xFFAAAA00));
    });

    testWidgets('date cell fields change selected, outside, disabled cells', (
      tester,
    ) async {
      await pumpPicker(
        tester,
        disabledDate: (date) => date == AnimalDate(2026, 5, 15),
        style: AnimalDatePickerStyle(
          cellInset: 3,
          cellTextStyle: const TextStyle(fontSize: 16),
          selectedBackgroundColor: const Color(0xFF123456),
          outsideMonthTextColor: const Color(0xFF654321),
          cellTextColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? const Color(0xFF999999)
                : states.contains(WidgetState.selected)
                ? const Color(0xFFFFFFFE)
                : const Color(0xFF010101),
          ),
        ),
      );

      // A 3dp inset inside the 48dp cell leaves a 42dp fill (36dp by default).
      expect(
        tester.getSize(
          find
              .descendant(
                of: cell('date-2026-05-14'),
                matching: find.byType(Container),
              )
              .last,
        ),
        const Size(42, 42),
      );
      expect(dayFill(tester, '2026-05-14').color, const Color(0xFF123456));
      final TextStyle selected = textStyle(tester, dayText('2026-05-14', '14'));
      expect(selected.fontSize, 16);
      expect(selected.fontWeight, FontWeight.bold);
      expect(selected.color, const Color(0xFFFFFFFE));
      expect(
        textStyle(tester, dayText('2026-05-13', '13')).color,
        const Color(0xFF010101),
      );
      expect(
        textStyle(tester, dayText('2026-05-15', '15')).color,
        const Color(0xFF999999),
      );
      expect(
        textStyle(tester, dayText('2026-04-30', '30')).color,
        const Color(0xFF654321),
      );
      // Today stays bold and underlined, so it is not marked by color alone.
      final TextStyle today = textStyle(tester, dayText('2026-05-20', '20'));
      expect(today.fontWeight, FontWeight.bold);
      expect(today.decoration, TextDecoration.underline);
    });

    testWidgets('range fields change endpoints and the range interior', (
      tester,
    ) async {
      await pumpPicker(
        tester,
        mode: AnimalDatePickerMode.range,
        selection: AnimalDateSelection.range(
          start: AnimalDate(2026, 5, 10),
          end: AnimalDate(2026, 5, 15),
        ),
        style: AnimalDatePickerStyle(
          rangeBackgroundColor: const Color(0xFF336699),
          rangeTextColor: const Color(0xFFEEDDCC),
          rangeBorderRadius: const BorderRadius.all(Radius.circular(9)),
        ),
      );
      expect(dayFill(tester, '2026-05-10').color, const Color(0xFF336699));
      expect(
        textStyle(tester, dayText('2026-05-15', '15')).color,
        const Color(0xFFEEDDCC),
      );
      final BoxDecoration interior = dayFill(tester, '2026-05-12');
      expect(interior.color, const Color(0xFF336699).withValues(alpha: 0.18));
      expect(interior.borderRadius, const BorderRadius.all(Radius.circular(9)));
    });

    testWidgets('gap and action padding fields change the panel spacing', (
      tester,
    ) async {
      Finder gaps(double height) => find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width == null &&
            widget.height == height &&
            widget.child == null,
      );

      await pumpPicker(
        tester,
        style: AnimalDatePickerStyle(
          padding: const EdgeInsetsDirectional.only(start: 20, top: 4),
          sectionGap: 13,
          footerGap: 7,
          cellGap: 5,
          actionHorizontalPadding: 17,
        ),
      );
      expect(
        panel(tester).padding,
        const EdgeInsetsDirectional.only(start: 20, top: 4),
      );
      // Header to grid and grid to divider.
      expect(gaps(13), findsNWidgets(2));
      // Divider to actions.
      expect(gaps(7), findsOneWidget);
      // Weekdays to the first row, then between rows.
      expect(gaps(5), findsOneWidget);
      expect(
        tester.getRect(cell('date-2026-05-14')).top -
            tester.getRect(cell('date-2026-05-07')).top,
        53,
      );
      final InteractiveRegion today = tester.widget<InteractiveRegion>(
        find
            .ancestor(
              of: find.text('Today'),
              matching: find.byType(InteractiveRegion),
            )
            .first,
      );
      expect(today.padding, const EdgeInsets.symmetric(horizontal: 17));

      await pumpPicker(
        tester,
        mode: AnimalDatePickerMode.month,
        style: AnimalDatePickerStyle(cellGap: 5),
      );
      expect(
        tester.getRect(cell('month-2026-5')).left -
            tester.getRect(cell('month-2026-4')).right,
        5,
      );
      expect(
        tester.getRect(cell('month-2026-7')).top -
            tester.getRect(cell('month-2026-4')).bottom,
        5,
      );
    });

    testWidgets('month fields change month cells', (tester) async {
      await pumpPicker(
        tester,
        mode: AnimalDatePickerMode.month,
        style: AnimalDatePickerStyle(
          monthBorderWidth: 3,
          monthBorderRadius: const BorderRadius.all(Radius.circular(6)),
          selectedBackgroundColor: const Color(0xFF224466),
          monthBorderColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? const Color(0xFF00FF00)
                : const Color(0xFFFF00FF),
          ),
          cellTextColor: const WidgetStatePropertyAll<Color>(Color(0xFF0F0F0F)),
        ),
      );
      final BoxDecoration selected = monthFill(tester, 5);
      expect(selected.color, const Color(0xFF224466));
      expect(selected.borderRadius, const BorderRadius.all(Radius.circular(6)));
      expect(selected.border!.top.width, 3);
      expect(selected.border!.top.color, const Color(0xFF00FF00));
      expect(monthFill(tester, 6).border!.top.color, const Color(0xFFFF00FF));
      expect(
        tester.widget<InteractiveRegion>(cell('month-2026-5')).borderRadius,
        const BorderRadius.all(Radius.circular(6)),
      );
      expect(
        textStyle(
          tester,
          find.descendant(of: cell('month-2026-6'), matching: find.text('Jun')),
        ).color,
        const Color(0xFF0F0F0F),
      );
    });
  });

  group('API06 AnimalDatePicker popover efficacy', () {
    Future<void> pumpPopover(
      WidgetTester tester, {
      AnimalIslandTheme? theme,
      AnimalDatePickerStyle? style,
      AnimalDateSelection? selection,
      AnimalInputStatus status = AnimalInputStatus.normal,
      bool disabled = false,
    }) => pump(
      tester,
      SizedBox(
        width: 300,
        child: AnimalDatePicker.popover(
          selection: selection,
          onChanged: (_) {},
          status: status,
          disabled: disabled,
          clock: clock,
          style: style,
        ),
      ),
      theme: theme,
    );

    InteractiveRegion trigger(WidgetTester tester) =>
        tester.widget<InteractiveRegion>(
          find
              .ancestor(
                of: find.byIcon(Icons.calendar_today_rounded),
                matching: find.byType(InteractiveRegion),
              )
              .first,
        );

    Text triggerText(WidgetTester tester) => tester.widget<Text>(
      find.descendant(
        of: find.byWidget(trigger(tester)),
        matching: find.byType(Text),
      ),
    );

    testWidgets('trigger fields change the closed trigger', (tester) async {
      await pumpPopover(
        tester,
        selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
        style: AnimalDatePickerStyle(
          borderWidth: 2.5,
          triggerIconSize: 22,
          triggerBorderRadius: const BorderRadius.all(Radius.circular(3)),
          triggerHorizontalPadding: 21,
          triggerIconGap: 11,
          triggerTextStyle: const TextStyle(fontSize: 18),
          borderColor: const WidgetStatePropertyAll<Color>(Color(0xFF0000AA)),
          triggerBackgroundColor: const WidgetStatePropertyAll<Color>(
            Color(0xFF102030),
          ),
          triggerTextColor: const WidgetStatePropertyAll<Color>(
            Color(0xFFAA0000),
          ),
          triggerIconColor: const WidgetStatePropertyAll<Color>(
            Color(0xFF00AA00),
          ),
        ),
      );
      final InteractiveRegion region = trigger(tester);
      expect(region.surfaceColor, const Color(0xFF102030));
      expect(region.border!.top.color, const Color(0xFF0000AA));
      expect(region.border!.top.width, 2.5);
      expect(region.borderRadius, const BorderRadius.all(Radius.circular(3)));
      expect(region.padding, const EdgeInsets.symmetric(horizontal: 21));
      expect(icon(tester, Icons.calendar_today_rounded).size, 22);
      expect(
        icon(tester, Icons.calendar_today_rounded).color,
        const Color(0xFF00AA00),
      );
      expect(
        tester.getRect(find.byWidget(triggerText(tester))).left -
            tester.getRect(find.byIcon(Icons.calendar_today_rounded)).right,
        11,
      );
      final AnimalIcon clear = tester.widget(
        find.byWidgetPredicate(
          (w) => w is AnimalIcon && w.data == AnimalIcons.close,
        ),
      );
      expect(clear.size, 22);
      expect(clear.color, const Color(0xFF00AA00));
      final TextStyle text = triggerText(tester).style!;
      expect(text.fontSize, 18);
      expect(text.color, const Color(0xFFAA0000));
    });

    testWidgets('trigger clear fields change the rendered clear control', (
      tester,
    ) async {
      BoxDecoration clearFill(WidgetTester tester) =>
          tester
                  .widget<AnimatedContainer>(
                    find
                        .ancestor(
                          of: find.byWidgetPredicate(
                            (w) =>
                                w is AnimalIcon && w.data == AnimalIcons.close,
                          ),
                          matching: find.byType(AnimatedContainer),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;

      await pumpPopover(
        tester,
        selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
        style: AnimalDatePickerStyle(
          triggerClearButtonPadding: const EdgeInsets.all(5),
          triggerClearButtonBorderRadius: const BorderRadius.all(
            Radius.circular(3),
          ),
          triggerClearButtonBackgroundColor:
              const WidgetStatePropertyAll<Color>(Color(0xFF0000AA)),
        ),
      );
      expect(clearFill(tester).color, const Color(0xFF0000AA));
      expect(
        clearFill(tester).borderRadius,
        const BorderRadius.all(Radius.circular(3)),
      );
      expect(
        tester
            .widget<AnimatedContainer>(
              find
                  .ancestor(
                    of: find.byWidgetPredicate(
                      (w) => w is AnimalIcon && w.data == AnimalIcons.close,
                    ),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first,
            )
            .padding,
        const EdgeInsets.all(5),
      );
    });

    testWidgets('a wide clear control still fits the bounded trigger row', (
      tester,
    ) async {
      await pumpPopover(
        tester,
        selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
        style: AnimalDatePickerStyle(
          triggerIconSize: 24,
          triggerClearButtonPadding: const EdgeInsets.symmetric(horizontal: 40),
        ),
      );
      expect(tester.takeException(), isNull);
      final Finder clear = find.byWidgetPredicate(
        (w) => w is AnimalIcon && w.data == AnimalIcons.close,
      );
      final Rect row = tester.getRect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 300),
      );
      final Rect action = tester.getRect(
        find
            .ancestor(of: clear, matching: find.byType(InteractiveRegion))
            .first,
      );
      expect(action.width, closeTo(104, 1e-6));
      expect(action.right, lessThanOrEqualTo(row.right + 1e-6));
    });

    testWidgets('the glow color is themed per state', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalDatePickerStyle(
          glowColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.error)
                ? const Color(0xFFEE00EE)
                : null,
          ),
        ),
      );
      await pumpPopover(tester, theme: theme, status: AnimalInputStatus.error);
      expect(
        trigger(tester).extraShadows!.single.color,
        const Color(0xFFEE00EE),
      );
      await pumpPopover(tester, theme: theme);
      expect(trigger(tester).extraShadows, isNull);
    });

    testWidgets('placeholder, warning, error and focused colors are themed', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalDatePickerStyle(
          placeholderTextColor: const Color(0xFF777700),
          warningColor: const Color(0xFFCC6600),
          backgroundColor: const Color(0xFF203040),
          borderColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.error)
                ? const Color(0xFFEE0000)
                : states.contains(WidgetState.focused)
                ? const Color(0xFF00EE00)
                : null,
          ),
        ),
      );

      await pumpPopover(tester, theme: theme);
      expect(triggerText(tester).style!.color, const Color(0xFF777700));

      await pumpPopover(
        tester,
        theme: theme,
        status: AnimalInputStatus.warning,
      );
      expect(trigger(tester).border!.top.color, const Color(0xFFCC6600));

      await pumpPopover(tester, theme: theme, status: AnimalInputStatus.error);
      expect(trigger(tester).border!.top.color, const Color(0xFFEE0000));
      expect(
        trigger(tester).extraShadows!.single.color,
        const Color(0xFFEE0000).withValues(alpha: 0.35),
      );

      await pumpPopover(tester, theme: theme);
      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pump(const Duration(seconds: 1));
      expect(trigger(tester).border!.top.color, const Color(0xFF00EE00));
      final MenuStyle menu = tester
          .widget<MenuAnchor>(find.byType(MenuAnchor))
          .style!;
      expect(
        menu.backgroundColor!.resolve(<WidgetState>{}),
        const Color(0xFF203040),
      );
      final RoundedRectangleBorder shape =
          menu.shape!.resolve(<WidgetState>{})! as RoundedRectangleBorder;
      expect(shape.side.color, const Color(0xFF00EE00));
    });

    testWidgets('the focus ring color themes the open trigger', (tester) async {
      await pumpPopover(
        tester,
        theme: AnimalIslandTheme.light.copyWith(
          components: AnimalComponentThemes(
            focusRing: AnimalFocusRingStyle(color: const Color(0xFF7700CC)),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pump(const Duration(seconds: 1));
      expect(trigger(tester).border!.top.color, const Color(0xFF7700CC));
    });

    testWidgets('disabled trigger colors resolve the disabled state', (
      tester,
    ) async {
      await pumpPopover(
        tester,
        disabled: true,
        selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
        style: AnimalDatePickerStyle(
          triggerBackgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? const Color(0xFF444444)
                : null,
          ),
          triggerTextColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? const Color(0xFF555555)
                : null,
          ),
        ),
      );
      expect(trigger(tester).surfaceColor, const Color(0xFF444444));
      expect(triggerText(tester).style!.color, const Color(0xFF555555));
    });
  });

  group('API06 AnimalDatePicker precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalDatePickerStyle(width: 280, borderWidth: 2.5),
      );

      // Token default: the light preset's panel.
      await pumpPicker(tester);
      expect(tester.getSize(find.byType(AnimalDatePickerPanel)).width, 300);
      expect(panelDecoration(tester).border!.top.width, 1.5);
      expect(panel(tester).padding, const EdgeInsets.all(12));

      // The theme style replaces the defaults it sets.
      await pumpPicker(tester, theme: theme);
      expect(tester.getSize(find.byType(AnimalDatePickerPanel)).width, 280);
      expect(panelDecoration(tester).border!.top.width, 2.5);

      // The instance style wins over the theme for the fields it sets.
      await pumpPicker(
        tester,
        theme: theme,
        style: AnimalDatePickerStyle(width: 270),
      );
      expect(tester.getSize(find.byType(AnimalDatePickerPanel)).width, 270);
      expect(panelDecoration(tester).border!.top.width, 2.5);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpPicker(
        tester,
        theme: themed(
          AnimalDatePickerStyle(
            headerTextStyle: const TextStyle(letterSpacing: 1.25),
          ),
        ),
        style: AnimalDatePickerStyle(
          headerTextStyle: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      final TextStyle style = textStyle(tester, find.text('May 2026'));
      expect(style.fontStyle, FontStyle.italic);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, 15);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });

    testWidgets('a narrower parent wins over the preferred width', (
      tester,
    ) async {
      await pump(
        tester,
        SizedBox(
          width: 120,
          child: AnimalDatePicker(
            selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
            onChanged: (_) {},
            clock: clock,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AnimalDatePickerPanel)).width, 120);
      // Navigation keeps 48dp targets when it moves below the label.
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.byIcon(Icons.chevron_left_rounded),
                matching: find.byType(InteractiveRegion),
              ),
            )
            .width,
        48,
      );
    });
  });

  group('API06 AnimalDatePicker invariants', () {
    testWidgets('registered layout floors hold at default metrics', (
      tester,
    ) async {
      await pumpPicker(tester);
      expect(tester.getSize(cell('date-2026-05-14')), const Size(48, 48));
      expect(
        tester.getSize(
          find
              .ancestor(of: find.text('M'), matching: find.byType(SizedBox))
              .first,
        ),
        const Size(48, 24),
      );
      expect(tester.widget<Divider>(find.byType(Divider)).height, 1);

      await pumpPicker(tester, mode: AnimalDatePickerMode.month);
      expect(tester.getSize(cell('month-2026-5')), const Size(86, 48));
      // Three month columns: April sits one row above July.
      expect(
        tester.getRect(cell('month-2026-7')).left,
        tester.getRect(cell('month-2026-4')).left,
      );

      await pump(
        tester,
        SizedBox(
          width: 300,
          child: AnimalDatePicker.popover(
            selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
            onChanged: (_) {},
            status: AnimalInputStatus.error,
            clock: clock,
          ),
        ),
      );
      final BoxShadow glow = tester
          .widget<InteractiveRegion>(
            find
                .ancestor(
                  of: find.byIcon(Icons.calendar_today_rounded),
                  matching: find.byType(InteractiveRegion),
                )
                .first,
          )
          .extraShadows!
          .single;
      expect(glow.blurRadius, 4);
      expect(glow.spreadRadius, 2);
      expect(
        tester.getSize(
          find
              .ancestor(
                of: find.byWidgetPredicate(
                  (w) => w is AnimalIcon && w.data == AnimalIcons.close,
                ),
                matching: find.byType(InteractiveRegion),
              )
              .first,
        ),
        const Size(48, 48),
      );
    });
  });

  group('API06 AnimalDatePicker boundary', () {
    test('styles reject values the picker cannot render', () {
      expect(() => AnimalDatePickerStyle(width: -1), throwsArgumentError);
      expect(
        () => AnimalDatePickerStyle(borderWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePickerStyle(padding: const EdgeInsets.only(top: -2)),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePickerStyle(
          padding: const EdgeInsetsDirectional.only(end: -2),
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePickerStyle(cellInset: double.infinity),
        throwsArgumentError,
      );
      expect(() => AnimalDatePickerStyle(cellGap: -1), throwsArgumentError);
      expect(
        () => AnimalDatePickerStyle(triggerIconGap: double.nan),
        throwsArgumentError,
      );
      expect(
        () =>
            AnimalDatePickerStyle(cellTextStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(AnimalDatePickerStyle(width: 280));
      final AnimalIslandTheme b = themed(AnimalDatePickerStyle(width: 320));
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(b, 0.5).components.datePicker!.width, closeTo(300, 1e-9));
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      // Only one theme sets these fields; null means "use the lower layer".
      // Interpolating from 0 or transparent would invent values neither
      // theme asked for.
      final AnimalIslandTheme a = themed(
        AnimalDatePickerStyle(
          borderWidth: 2.5,
          selectedBackgroundColor: const Color(0xFF123456),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.datePicker!.borderWidth, 2.5);
      expect(
        early.components.datePicker!.selectedBackgroundColor,
        const Color(0xFF123456),
      );
      expect(late.components.datePicker?.borderWidth, isNull);
      expect(late.components.datePicker?.selectedBackgroundColor, isNull);
    });
  });

  group('AnimalDatePicker header layout', () {
    RenderBox header(WidgetTester tester) =>
        tester
                .renderObject(
                  find
                      .ancestor(
                        of: find.byIcon(Icons.chevron_left_rounded),
                        matching: find.byType(Wrap),
                      )
                      .first,
                )
                .parent!
            as RenderBox;

    Rect target(WidgetTester tester, IconData data) => tester.getRect(
      find
          .ancestor(
            of: find.byIcon(data),
            matching: find.byType(InteractiveRegion),
          )
          .first,
    );

    testWidgets('right-to-left places previous navigation on the right', (
      tester,
    ) async {
      await pump(
        tester,
        Directionality(
          textDirection: TextDirection.rtl,
          child: AnimalDatePicker(
            selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
            onChanged: (_) {},
            clock: clock,
          ),
        ),
      );
      final Rect previous = target(
        tester,
        Icons.keyboard_double_arrow_left_rounded,
      );
      final Rect next = target(
        tester,
        Icons.keyboard_double_arrow_right_rounded,
      );
      final Rect label = tester.getRect(find.text('May 2026'));
      expect(previous.left, greaterThan(label.right));
      expect(next.right, lessThan(label.left));
      final RenderBox box = header(tester);
      final Rect bounds = box.localToGlobal(Offset.zero) & box.size;
      expect(label.center.dx, closeTo(bounds.center.dx, 1e-9));
      expect(previous.right, closeTo(bounds.right, 1e-9));
      expect(next.left, closeTo(bounds.left, 1e-9));
    });

    testWidgets('intrinsic and dry sizes match layout when navigation wraps', (
      tester,
    ) async {
      for (final double width in <double>[300, 160, 120]) {
        await pump(
          tester,
          SizedBox(
            width: width,
            child: AnimalDatePicker(
              selection: AnimalDateSelection.date(AnimalDate(2026, 5, 14)),
              onChanged: (_) {},
              clock: clock,
            ),
          ),
        );
        final RenderBox box = header(tester);
        expect(
          box.getMinIntrinsicHeight(box.size.width),
          box.size.height,
          reason: 'min intrinsic height at panel width $width',
        );
        expect(
          box.getMaxIntrinsicHeight(box.size.width),
          box.size.height,
          reason: 'max intrinsic height at panel width $width',
        );
        expect(
          box.getDryLayout(box.constraints),
          box.size,
          reason: 'dry layout at panel width $width',
        );
      }
    });
  });
}
