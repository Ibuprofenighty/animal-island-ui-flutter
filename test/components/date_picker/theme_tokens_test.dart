import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

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

  testWidgets('date panel uses theme card, spacing, typography and tone pairs', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalDatePickerPanel(
              selection: AnimalDateSelection.date(AnimalDate(2024, 5, 10)),
              disabledDate: (date) =>
                  date.year == 2024 && date.month == 5 && date.day == 11,
              showToday: true,
              allowClear: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final materialLocalizations = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePickerPanel)),
      );

      final panel = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).color ==
                    theme.colors.bgContent,
          );
      final decoration = panel.decoration! as BoxDecoration;
      expect(decoration.borderRadius, theme.radii.cardBorder);
      expect(panel.padding, EdgeInsets.all(theme.spacing.md));
      final panelBorder = theme.colors.brightness == Brightness.dark
          ? theme.colors.border
          : theme.colors.borderLight;
      expect(decoration.border!.top.color, panelBorder);
      expect(
        themeContrastRatio(panelBorder, theme.colors.bgContent),
        greaterThan(1.0),
        reason: '${theme.colors.brightness.name} date panel border pair',
      );

      final monthTitle = tester.widget<Text>(
        find.text(materialLocalizations.formatMonthYear(DateTime.utc(2024, 5))),
      );
      expect(monthTitle.style!.fontSize, 15.0);
      expect(
        monthTitle.style!.letterSpacing,
        theme.typography.heading.letterSpacing,
      );
      expect(monthTitle.style!.color, theme.colors.text);
      expect(
        themeContrastRatio(monthTitle.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} date heading text pair',
      );
      final weekdayHeader = find.byWidgetPredicate((widget) {
        if (widget is! Row || widget.children.length != 7) {
          return false;
        }
        return widget.children.every(
          (child) =>
              child is SizedBox &&
              child.width == 48 &&
              child.child is Center &&
              (child.child! as Center).child is Text,
        );
      });
      final weekday = tester.widget<Text>(
        find
            .descendant(
              of: weekdayHeader,
              matching: find.text(materialLocalizations.narrowWeekdays.first),
            )
            .first,
      );
      expect(weekday.style!.fontSize, theme.typography.caption.fontSize);
      expect(weekday.style!.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(weekday.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} weekday text pair',
      );

      Semantics daySemantics(String date) => tester
          .widgetList<Semantics>(find.byType(Semantics))
          .singleWhere((semantics) => semantics.properties.label == date);

      Text dayText(Semantics semantics, String day) => tester.widget<Text>(
        find.descendant(of: find.byWidget(semantics), matching: find.text(day)),
      );

      Container dayCell(Semantics semantics, Color expectedColor) =>
          tester.widget<Container>(
            find.descendant(
              of: find.byWidget(semantics),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration! as BoxDecoration).color ==
                        expectedColor,
              ),
            ),
          );

      final selectedSemantics = daySemantics(
        materialLocalizations.formatFullDate(DateTime.utc(2024, 5, 10)),
      );
      expect(selectedSemantics.properties.selected, isTrue);
      expect(selectedSemantics.properties.enabled, isTrue);
      final selectedDay = dayText(selectedSemantics, '10');
      expect(selectedDay.style!.fontSize, 13.0);
      expect(selectedDay.style!.color, theme.colors.onPrimary);
      expect(
        selectedDay.style!.letterSpacing,
        theme.typography.body.letterSpacing,
      );
      final selectedDecoration =
          dayCell(selectedSemantics, theme.colors.primary).decoration!
              as BoxDecoration;
      expect(selectedDecoration.color, theme.colors.primary);
      expect(selectedDecoration.shape, BoxShape.circle);
      expect(
        themeContrastRatio(
          selectedDay.style!.color!,
          selectedDecoration.color!,
        ),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected date text pair',
      );

      final disabledSemantics = daySemantics(
        materialLocalizations.formatFullDate(DateTime.utc(2024, 5, 11)),
      );
      expect(disabledSemantics.properties.selected, isFalse);
      expect(disabledSemantics.properties.enabled, isFalse);
      final disabledDay = dayText(disabledSemantics, '11');
      expect(disabledDay.style!.color, theme.colors.textDisabled);
      expect(
        themeContrastRatio(disabledDay.style!.color!, theme.colors.bgContent),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled date cell text pair; exemption is scoped to this disabled cell',
      );

      final adjacentSemantics = daySemantics(
        materialLocalizations.formatFullDate(DateTime.utc(2024, 4, 28)),
      );
      expect(adjacentSemantics.properties.enabled, isTrue);
      final adjacentDay = dayText(adjacentSemantics, '28');
      expect(adjacentDay.style!.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(adjacentDay.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} adjacent-month text pair',
      );

      final todayStyle = tester.widget<Text>(find.text('Today')).style!;
      expect(todayStyle.fontSize, theme.typography.caption.fontSize);
      expect(todayStyle.color, theme.colors.primaryText);
      expect(
        themeContrastRatio(todayStyle.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} Today label text pair',
      );

      final dateGridScrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(dateGridScrollView.scrollDirection, Axis.horizontal);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalDatePickerPanel(
              selection: AnimalDateSelection.date(AnimalDate(2024, 5, 1)),
              mode: AnimalDatePickerMode.month,
              showToday: false,
              allowClear: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final monthMaterialLocalizations = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePickerPanel)),
      );
      final selectedMonthSemantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .singleWhere(
            (semantics) =>
                semantics.properties.label ==
                monthMaterialLocalizations.formatMonthYear(
                  DateTime.utc(2024, 5),
                ),
          );
      expect(selectedMonthSemantics.properties.selected, isTrue);
      expect(selectedMonthSemantics.properties.enabled, isTrue);
      final selectedMonth = tester.widget<Text>(
        find.descendant(
          of: find.byWidget(selectedMonthSemantics),
          matching: find.text('May'),
        ),
      );
      expect(selectedMonth.style!.color, theme.colors.onPrimary);
      final selectedMonthCell = tester.widget<Container>(
        find.descendant(
          of: find.byWidget(selectedMonthSemantics),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color ==
                    theme.colors.primary,
          ),
        ),
      );
      final monthDecoration = selectedMonthCell.decoration! as BoxDecoration;
      expect(monthDecoration.color, theme.colors.primary);
      expect(monthDecoration.borderRadius, theme.radii.pillBorder);
      expect(
        themeContrastRatio(selectedMonth.style!.color!, monthDecoration.color!),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected month text pair',
      );
    }
  });

  testWidgets(
    'date range endpoints and in-range days use contrasting theme pairs',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ObjectKey(theme),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: AnimalDatePickerPanel(
                mode: AnimalDatePickerMode.range,
                selection: AnimalDateSelection.range(
                  start: AnimalDate(2024, 5, 10),
                  end: AnimalDate(2024, 5, 15),
                ),
                showToday: false,
                allowClear: false,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        final materialLocalizations = MaterialLocalizations.of(
          tester.element(find.byType(AnimalDatePickerPanel)),
        );

        Semantics dateSemantics(DateTime date) => tester
            .widgetList<Semantics>(find.byType(Semantics))
            .singleWhere(
              (semantics) =>
                  semantics.properties.label ==
                  materialLocalizations.formatFullDate(date),
            );

        Text dateText(Semantics semantics, String day) => tester.widget<Text>(
          find.descendant(
            of: find.byWidget(semantics),
            matching: find.text(day),
          ),
        );

        Container dateCell(Semantics semantics, Color expectedColor) =>
            tester.widget<Container>(
              find.descendant(
                of: find.byWidget(semantics),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration! as BoxDecoration).color ==
                          expectedColor,
                ),
              ),
            );

        for (final date in <(DateTime, String)>[
          (DateTime.utc(2024, 5, 10), '10'),
          (DateTime.utc(2024, 5, 15), '15'),
        ]) {
          final semantics = dateSemantics(date.$1);
          expect(semantics.properties.selected, isTrue);
          expect(semantics.properties.enabled, isTrue);
          final text = dateText(semantics, date.$2);
          expect(text.style!.color, theme.colors.onWarning);
          final decoration =
              dateCell(semantics, theme.colors.warning).decoration!
                  as BoxDecoration;
          expect(decoration.color, theme.colors.warning);
          expect(
            themeContrastRatio(text.style!.color!, decoration.color!),
            greaterThanOrEqualTo(4.5),
            reason: '${theme.colors.brightness.name} range endpoint pair',
          );
        }

        final inRangeSemantics = dateSemantics(DateTime.utc(2024, 5, 12));
        expect(inRangeSemantics.properties.selected, isFalse);
        expect(inRangeSemantics.properties.enabled, isTrue);
        final inRangeText = dateText(inRangeSemantics, '12');
        expect(inRangeText.style!.color, theme.colors.text);
        final rangeFill = theme.colors.warning.withValues(alpha: 0.18);
        final rangeSurface = Color.alphaBlend(
          rangeFill,
          theme.colors.bgContent,
        );
        final inRangeCell = dateCell(inRangeSemantics, rangeFill);
        expect((inRangeCell.decoration! as BoxDecoration).color, rangeFill);
        expect(
          themeContrastRatio(inRangeText.style!.color!, rangeSurface),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.colors.brightness.name} range interior text pair',
        );
      }
    },
  );

  testWidgets(
    'DAT04: 2x localized date and month text fits legal theme line boxes',
    (tester) async {
      final AnimalThemeTypography standard = AnimalThemeTypography.standard;
      final AnimalIslandTheme largeLineTheme = AnimalIslandTheme.light.copyWith(
        typography: standard.copyWith(
          body: standard.body.copyWith(
            fontSize: 15,
            height: 2.1,
            letterSpacing: 0.75,
          ),
          caption: standard.caption.copyWith(
            fontSize: 13,
            height: 1.8,
            letterSpacing: 0.6,
          ),
        ),
      );
      final variants = <({Locale locale, AnimalIslandTheme theme})>[
        (locale: const Locale('en'), theme: AnimalIslandTheme.light),
        (locale: const Locale('zh'), theme: AnimalIslandTheme.dark),
        (locale: const Locale('en'), theme: largeLineTheme),
      ];

      Future<void> pumpPicker({
        required Locale locale,
        required AnimalIslandTheme theme,
        required AnimalDatePickerMode mode,
        AnimalDate? selectedDate,
        double? callerViewportHeight,
      }) async {
        final AnimalDateSelection selection = AnimalDateSelection.date(
          selectedDate ??
              (mode == AnimalDatePickerMode.month
                  ? AnimalDate(2026, 9, 1)
                  : AnimalDate(2026, 9, 15)),
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: theme.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: SizedBox(
                    width: 320,
                    height: callerViewportHeight,
                    child: SingleChildScrollView(
                      child: AnimalDatePickerPanel(
                        selection: selection,
                        mode: mode,
                        showToday: false,
                        allowClear: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      void expectAllGridTextFits(
        String label,
        AnimalIslandTheme expectedTheme,
      ) {
        final Finder panel = find.byType(AnimalDatePickerPanel);
        final Finder viewport = find.descendant(
          of: panel,
          matching: find.byType(SingleChildScrollView),
        );
        expect(viewport, findsOneWidget, reason: label);
        final List<Element> renderedText = find
            .descendant(of: viewport, matching: find.byType(RichText))
            .evaluate()
            .toList();
        expect(renderedText, isNotEmpty, reason: label);
        final List<Rect> textRects = <Rect>[];

        for (final Element element in renderedText) {
          final Finder textFinder = find.byElementPredicate(
            (Element candidate) => identical(candidate, element),
          );
          final RenderParagraph paragraph = tester
              .renderObject<RenderParagraph>(textFinder);
          final TextSpan span = paragraph.text as TextSpan;
          final String text = span.toPlainText();
          expect(
            span.style?.fontFamily,
            expectedTheme.typography.fontFamily,
            reason: '$label: themed font family must reach the real paragraph',
          );
          expect(
            span.style?.fontFamilyFallback,
            containsAll(expectedTheme.typography.fontFamilyFallback),
            reason: '$label: bundled CJK fallback must reach the paragraph',
          );
          final List<LineMetrics> lines = _paragraphLineMetrics(paragraph);
          expect(lines, isNotEmpty, reason: label);
          final double totalLineHeight = lines.fold<double>(
            0,
            (double total, LineMetrics line) => total + line.height,
          );
          expect(
            paragraph.size.height,
            greaterThanOrEqualTo(totalLineHeight - 0.5),
            reason: '$label: "$text" line box height; lines=$lines',
          );
          expect(
            lines.every(
              (LineMetrics line) => line.width <= paragraph.size.width + 0.5,
            ),
            isTrue,
            reason: '$label: "$text" line box width; lines=$lines',
          );

          final Finder interactiveCell = find.ancestor(
            of: textFinder,
            matching: find.byType(InteractiveRegion),
          );
          final Finder cell = interactiveCell.evaluate().isNotEmpty
              ? interactiveCell.first
              : find
                    .ancestor(of: textFinder, matching: find.byType(SizedBox))
                    .first;
          final Rect cellRect = tester.getRect(cell);
          final Rect textRect = tester.getRect(textFinder);
          textRects.add(textRect);
          expect(textRect.left, greaterThanOrEqualTo(cellRect.left - 0.5));
          expect(textRect.top, greaterThanOrEqualTo(cellRect.top - 0.5));
          expect(textRect.right, lessThanOrEqualTo(cellRect.right + 0.5));
          expect(textRect.bottom, lessThanOrEqualTo(cellRect.bottom + 0.5));
          final Offset paragraphOrigin = paragraph.localToGlobal(Offset.zero);
          final Rect paragraphRect = paragraphOrigin & paragraph.size;
          expect(paragraphRect.left, greaterThanOrEqualTo(cellRect.left - 0.5));
          expect(paragraphRect.top, greaterThanOrEqualTo(cellRect.top - 0.5));
          expect(paragraphRect.right, lessThanOrEqualTo(cellRect.right + 0.5));
          expect(
            paragraphRect.bottom,
            lessThanOrEqualTo(cellRect.bottom + 0.5),
          );

          final List<TextBox> selectionBoxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: text.length),
          );
          expect(
            selectionBoxes,
            isNotEmpty,
            reason: '$label selection geometry',
          );
          final List<Rect> globalSelectionRects = selectionBoxes
              .map(
                (TextBox box) => Rect.fromLTRB(
                  box.left,
                  box.top,
                  box.right,
                  box.bottom,
                ).shift(paragraphOrigin),
              )
              .toList();
          final String selectionGeometryReason =
              '$label: selection geometry for "$text"; '
              'boxes=$globalSelectionRects; lines=$lines; '
              'paragraphSize=${paragraph.size}; paragraph=$paragraphRect; '
              'textRect=$textRect; cell=$cellRect';
          expect(
            globalSelectionRects.every(
              (Rect selectionRect) =>
                  selectionRect.left >= cellRect.left - 0.5 &&
                  selectionRect.top >= cellRect.top - 0.5 &&
                  selectionRect.right <= cellRect.right + 0.5 &&
                  selectionRect.bottom <= cellRect.bottom + 0.5,
            ),
            isTrue,
            reason: selectionGeometryReason,
          );
        }

        for (int left = 0; left < textRects.length; left++) {
          for (int right = left + 1; right < textRects.length; right++) {
            expect(
              textRects[left].overlaps(textRects[right]),
              isFalse,
              reason: '$label grid labels must not overlap',
            );
          }
        }
      }

      for (final variant in variants) {
        for (final AnimalDatePickerMode mode in <AnimalDatePickerMode>[
          AnimalDatePickerMode.date,
          AnimalDatePickerMode.month,
        ]) {
          await pumpPicker(
            locale: variant.locale,
            theme: variant.theme,
            mode: mode,
          );
          expect(tester.takeException(), isNull);
          expectAllGridTextFits(
            '${variant.locale.languageCode}/${variant.theme.colors.brightness.name}/$mode',
            variant.theme,
          );
        }
      }

      await pumpPicker(
        locale: const Locale('en'),
        theme: largeLineTheme,
        mode: AnimalDatePickerMode.date,
        selectedDate: AnimalDate(2026, 8, 10),
        callerViewportHeight: 320,
      );
      expect(tester.takeException(), isNull);

      final Finder panel = find.byType(AnimalDatePickerPanel);
      final Finder callerViewport = find.ancestor(
        of: panel,
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.vertical,
        ),
      );
      expect(callerViewport, findsOneWidget);
      final Finder panelViewport = find.descendant(
        of: panel,
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
      );
      expect(panelViewport, findsOneWidget);

      final Finder targetDate = find.byKey(
        const ValueKey<String>('date-2026-08-31'),
      );
      void focusDate(Finder date) {
        final Finder focusNodes = find.descendant(
          of: date,
          matching: find.byType(Focus),
        );
        expect(focusNodes, findsWidgets);
        tester.widget<Focus>(focusNodes.first).focusNode!.requestFocus();
      }

      bool dateIsFocused(Finder date) {
        final Finder focusNodes = find.descendant(
          of: date,
          matching: find.byType(Focus),
        );
        return focusNodes.evaluate().any(
          (Element element) =>
              (element.widget as Focus).focusNode?.hasFocus == true,
        );
      }

      final Finder callerScrollable = find.ancestor(
        of: panel,
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        ),
      );
      expect(callerScrollable, findsOneWidget);
      final ScrollableState callerScrollState = tester.state<ScrollableState>(
        callerScrollable,
      );
      expect(callerScrollState.position.pixels, 0);
      final Rect targetBeforeFocusRect = tester.getRect(targetDate);
      final Rect callerBeforeFocusRect = tester.getRect(callerViewport);
      final Rect clippedTargetBeforeFocus = targetBeforeFocusRect.intersect(
        callerBeforeFocusRect,
      );
      expect(
        clippedTargetBeforeFocus.height,
        lessThan(targetBeforeFocusRect.height - 0.5),
        reason: 'The final grid row starts outside the 320dp caller viewport',
      );
      focusDate(targetDate);
      await tester.pumpAndSettle();
      expect(dateIsFocused(targetDate), isTrue);
      final Rect targetRect = tester.getRect(targetDate);
      final Rect callerRect = tester.getRect(callerViewport);
      final Rect panelRect = tester.getRect(panelViewport);
      final Rect visibleTargetRect = targetRect
          .intersect(callerRect)
          .intersect(panelRect);
      expect(visibleTargetRect.width, closeTo(targetRect.width, 0.5));
      expect(visibleTargetRect.height, closeTo(targetRect.height, 0.5));
      expect(
        callerScrollState.position.pixels,
        greaterThan(0),
        reason: 'Panel focus navigation scrolls its caller viewport to the final grid row',
      );
    },
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
