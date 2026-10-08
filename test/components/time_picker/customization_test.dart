// API06 efficacy and precedence oracles for AnimalTimePicker.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/time_picker/time_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    AnimalIslandTheme? theme,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: Scaffold(body: Center(child: child)),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> pumpPicker(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalTimePickerStyle? style,
    String format = 'HH:mm',
    bool disabled = false,
    double textScale = 1,
    ValueChanged<AnimalTimeValue?>? onChanged,
  }) => pump(
    tester,
    AnimalTimePicker(
      value: AnimalTimeValue(hour: 9, minute: 30, second: 15),
      format: format,
      disabled: disabled,
      style: style,
      onChanged: onChanged ?? (_) {},
    ),
    theme: theme,
    textScale: textScale,
  );

  AnimalIslandTheme themed(AnimalTimePickerStyle style) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(timePicker: style));

  Iterable<Container> containers(WidgetTester tester) =>
      tester.widgetList<Container>(
        find.descendant(
          of: find.byType(AnimalTimePickerPanel),
          matching: find.byType(Container),
        ),
      );
  Container panel(WidgetTester tester) => containers(tester).first;
  BoxDecoration panelDecoration(WidgetTester tester) =>
      panel(tester).decoration! as BoxDecoration;
  // The selection band is the first Container in the Stack around the wheels.
  Container band(WidgetTester tester) => tester
      .widgetList<Container>(
        find.descendant(
          of: find
              .ancestor(
                of: find.byType(ListWheelScrollView).first,
                matching: find.byType(Stack),
              )
              .first,
          matching: find.byType(Container),
        ),
      )
      .first;
  BoxDecoration bandDecoration(WidgetTester tester) =>
      band(tester).decoration! as BoxDecoration;
  ListWheelScrollView hourWheel(WidgetTester tester) => tester
      .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
      .first;
  TextStyle textStyle(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!;
  Finder wheelLabel(WidgetTester tester, int value) {
    final AnimalLocalizations localizations = AnimalLocalizations.of(
      tester.element(find.byType(AnimalTimePickerPanel)),
    )!;
    return find.descendant(
      of: find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label ==
                localizations.timePickerWheelValue(value, 'hours'),
      ),
      matching: find.byType(Text),
    );
  }

  TextStyle wheelStyle(WidgetTester tester, int hour) =>
      tester.widget<Text>(wheelLabel(tester, hour)).style!;
  InteractiveRegion region(WidgetTester tester, String label) =>
      tester.widget<InteractiveRegion>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(InteractiveRegion),
        ),
      );

  group('API06 AnimalTimePicker efficacy', () {
    testWidgets('typography token changes reach every text role', (
      tester,
    ) async {
      final AnimalThemeTypography t = AnimalIslandTheme.light.typography;
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        typography: t.copyWith(
          heading: t.heading.copyWith(fontSize: 26),
          subheading: t.subheading.copyWith(fontSize: 30),
          body: t.body.copyWith(fontSize: 28),
          caption: t.caption.copyWith(fontSize: 22),
        ),
      );
      await pumpPicker(tester, theme: theme);
      expect(textStyle(tester, 'Select time').fontSize, 26);
      expect(textStyle(tester, ':').fontSize, 26);
      expect(wheelStyle(tester, 9).fontSize, 30);
      expect(wheelStyle(tester, 10).fontSize, 28);
      expect(textStyle(tester, 'Now').fontSize, 22);
      expect(textStyle(tester, 'Clear').fontSize, 22);
      // 30 x 1.4 and 28 x 1.5 both need 42 logical pixels per wheel item.
      expect(hourWheel(tester).itemExtent, closeTo(42, 0.5));
      expect(
        tester.getSize(find.byWidget(band(tester))).height,
        closeTo(42, 0.5),
      );

      await pump(
        tester,
        AnimalTimePicker.popover(
          value: AnimalTimeValue(hour: 9, minute: 30),
          onChanged: (_) {},
        ),
        theme: theme,
      );
      expect(textStyle(tester, '09:30').fontSize, 28);
    });

    testWidgets('every panel style field changes the rendered panel', (
      tester,
    ) async {
      await pumpPicker(
        tester,
        theme: themed(
          AnimalTimePickerStyle(
            width: 280,
            widthWithSeconds: 330,
            padding: const EdgeInsets.all(11),
            backgroundColor: const Color(0xFF102030),
            borderColor: const Color(0xFF0000AA),
            borderWidth: 3.5,
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            headerIconSize: 23,
            headerIconColor: const Color(0xFF00AA00),
            headerGap: 13,
            titleTextStyle: const TextStyle(fontSize: 21),
            titleTextColor: const WidgetStatePropertyAll<Color>(
              Color(0xFFAA0000),
            ),
            wheelGap: 17,
            wheelHeight: 210,
            minItemExtent: 44,
            itemTextStyle: const TextStyle(fontSize: 11),
            selectedItemTextStyle: const TextStyle(fontSize: 19),
            itemTextColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF00AAAA)
                  : const Color(0xFFAAAA00),
            ),
            separatorTextStyle: const TextStyle(fontSize: 15),
            separatorTextColor: const Color(0xFFAA00AA),
            selectionBackgroundColor: const Color(0xFF223344),
            selectionBorderColor: const Color(0xFF334455),
            selectionBorderWidth: 2.25,
            selectionBorderRadius: const BorderRadius.all(Radius.circular(3)),
            selectionInset: 9,
            dividerColor: const Color(0xFF445566),
            dividerThickness: 3,
            dividerPadding: const EdgeInsets.only(top: 5, bottom: 6),
            actionPadding: const EdgeInsets.symmetric(horizontal: 14),
            nowTextStyle: const TextStyle(fontSize: 16),
            nowTextColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF556677),
            ),
            clearTextStyle: const TextStyle(fontSize: 17),
            clearTextColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF667788),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byWidget(panel(tester))).width, 280);
      expect(panel(tester).padding, const EdgeInsets.all(11));
      final BoxDecoration d = panelDecoration(tester);
      expect(d.color, const Color(0xFF102030));
      expect(d.border!.top.color, const Color(0xFF0000AA));
      expect(d.border!.top.width, 3.5);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(7)));

      final AnimalIcon icon = tester.widget(find.byType(AnimalIcon));
      expect(icon.size, 23);
      expect(icon.color, const Color(0xFF00AA00));
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 13),
        findsOneWidget,
      );
      expect(textStyle(tester, 'Select time').fontSize, 21);
      expect(textStyle(tester, 'Select time').color, const Color(0xFFAA0000));
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.height == 17),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.height == 210),
        findsOneWidget,
      );

      expect(hourWheel(tester).itemExtent, 44);
      expect(tester.getSize(find.byWidget(band(tester))).height, 44);
      expect(wheelStyle(tester, 9).fontSize, 19);
      expect(wheelStyle(tester, 9).color, const Color(0xFF00AAAA));
      expect(wheelStyle(tester, 10).fontSize, 11);
      expect(wheelStyle(tester, 10).color, const Color(0xFFAAAA00));
      expect(textStyle(tester, ':').fontSize, 15);
      expect(textStyle(tester, ':').color, const Color(0xFFAA00AA));

      final BoxDecoration b = bandDecoration(tester);
      expect(b.color, const Color(0xFF223344));
      expect(b.border!.top.color, const Color(0xFF334455));
      expect(b.border!.top.width, 2.25);
      expect(b.borderRadius, const BorderRadius.all(Radius.circular(3)));
      expect(band(tester).margin, const EdgeInsets.symmetric(horizontal: 9));

      final Divider divider = tester.widget(find.byType(Divider));
      expect(divider.color, const Color(0xFF445566));
      expect(divider.thickness, 3);
      expect(divider.height, 3);
      expect(
        tester
            .widget<Padding>(
              find
                  .ancestor(
                    of: find.byType(Divider),
                    matching: find.byType(Padding),
                  )
                  .first,
            )
            .padding,
        const EdgeInsets.only(top: 5, bottom: 6),
      );

      expect(
        region(tester, 'Now').padding,
        const EdgeInsets.symmetric(horizontal: 14),
      );
      expect(textStyle(tester, 'Now').fontSize, 16);
      expect(textStyle(tester, 'Now').color, const Color(0xFF556677));
      expect(textStyle(tester, 'Clear').fontSize, 17);
      expect(textStyle(tester, 'Clear').color, const Color(0xFF667788));

      await pumpPicker(
        tester,
        format: 'HH:mm:ss',
        theme: themed(AnimalTimePickerStyle(widthWithSeconds: 330)),
      );
      expect(tester.getSize(find.byWidget(panel(tester))).width, 330);
    });

    testWidgets('panel colors resolve against the disabled state', (
      tester,
    ) async {
      const Color disabledColor = Color(0xFF999999);
      WidgetStateProperty<Color?> onDisabled() =>
          WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? disabledColor
                : const Color(0xFF111111),
          );
      await pumpPicker(
        tester,
        disabled: true,
        style: AnimalTimePickerStyle(
          titleTextColor: onDisabled(),
          itemTextColor: onDisabled(),
          nowTextColor: onDisabled(),
          clearTextColor: onDisabled(),
        ),
      );
      expect(textStyle(tester, 'Select time').color, disabledColor);
      expect(wheelStyle(tester, 9).color, disabledColor);
      expect(wheelStyle(tester, 10).color, disabledColor);
      expect(textStyle(tester, 'Now').color, disabledColor);
      expect(textStyle(tester, 'Clear').color, disabledColor);
    });

    testWidgets('every trigger style field changes the popover trigger', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final AnimalTimePickerStyle style = AnimalTimePickerStyle(
        triggerBackgroundColor: const WidgetStatePropertyAll<Color>(
          Color(0xFF102030),
        ),
        triggerBorderColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? const Color(0xFF00AA00)
              : const Color(0xFF0000AA),
        ),
        triggerBorderWidth: 3.5,
        triggerBorderRadius: const BorderRadius.all(Radius.circular(7)),
        triggerPadding: const EdgeInsets.symmetric(horizontal: 21),
        triggerTextStyle: const TextStyle(fontSize: 19),
        triggerTextColor: const WidgetStatePropertyAll<Color>(
          Color(0xFFAA0000),
        ),
        placeholderTextColor: const Color(0xFF00AAAA),
        triggerIconSize: 22,
        triggerIconColor: const WidgetStatePropertyAll<Color>(
          Color(0xFFAAAA00),
        ),
        triggerIconGap: 13,
      );
      await pump(
        tester,
        AnimalTimePicker.popover(
          value: AnimalTimeValue(hour: 9, minute: 30),
          focusNode: focusNode,
          style: style,
          onChanged: (_) {},
        ),
      );
      InteractiveRegion trigger() => region(tester, '09:30');
      expect(trigger().surfaceColor, const Color(0xFF102030));
      expect(trigger().border!.top.color, const Color(0xFF0000AA));
      expect(trigger().border!.top.width, 3.5);
      expect(
        trigger().borderRadius,
        const BorderRadius.all(Radius.circular(7)),
      );
      expect(trigger().padding, const EdgeInsets.symmetric(horizontal: 21));
      expect(textStyle(tester, '09:30').fontSize, 19);
      expect(textStyle(tester, '09:30').color, const Color(0xFFAA0000));
      final Icon clock = tester.widget(find.byIcon(Icons.access_time_rounded));
      expect(clock.size, 22);
      expect(clock.color, const Color(0xFFAAAA00));
      final AnimalIcon clear = tester.widget(
        find.byWidgetPredicate(
          (w) => w is AnimalIcon && w.data == AnimalIcons.close,
        ),
      );
      expect(clear.size, 22);
      expect(clear.color, const Color(0xFFAAAA00));
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 13),
        findsOneWidget,
      );

      focusNode.requestFocus();
      await tester.pump(const Duration(seconds: 1));
      expect(trigger().border!.top.color, const Color(0xFF00AA00));
      expect(
        trigger().extraShadows!.single.color,
        const Color(0xFF00AA00).withValues(alpha: 0.45),
      );

      await pump(
        tester,
        AnimalTimePicker.popover(
          placeholder: 'Pick',
          style: style,
          onChanged: (_) {},
        ),
      );
      expect(textStyle(tester, 'Pick').color, const Color(0xFF00AAAA));
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

      await pump(
        tester,
        AnimalTimePicker.popover(
          value: AnimalTimeValue(hour: 9, minute: 30),
          onChanged: (_) {},
        ),
        theme: themed(
          AnimalTimePickerStyle(
            triggerClearButtonPadding: const EdgeInsets.all(5),
            triggerClearButtonBorderRadius: const BorderRadius.all(
              Radius.circular(3),
            ),
            triggerClearButtonBackgroundColor:
                const WidgetStatePropertyAll<Color>(Color(0xFF0000AA)),
          ),
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

    testWidgets('the trigger glow color is themed per state', (tester) async {
      await pump(
        tester,
        AnimalTimePicker.popover(
          placeholder: 'Pick',
          status: AnimalInputStatus.error,
          onChanged: (_) {},
        ),
        theme: themed(
          AnimalTimePickerStyle(
            triggerGlowColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.error)
                  ? const Color(0xFFEE00EE)
                  : null,
            ),
          ),
        ),
      );
      expect(
        region(tester, 'Pick').extraShadows!.single.color,
        const Color(0xFFEE00EE),
      );
    });

    testWidgets('warning color and status glow are themed', (tester) async {
      await pump(
        tester,
        AnimalTimePicker.popover(
          placeholder: 'Pick',
          status: AnimalInputStatus.warning,
          onChanged: (_) {},
        ),
        theme: themed(
          AnimalTimePickerStyle(warningColor: const Color(0xFFCC6600)),
        ),
      );
      final InteractiveRegion trigger = region(tester, 'Pick');
      expect(trigger.border!.top.color, const Color(0xFFCC6600));
      expect(
        trigger.extraShadows!.single.color,
        const Color(0xFFCC6600).withValues(alpha: 0.35),
      );
    });

    testWidgets('the focus ring color themes the focused trigger border', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pump(
        tester,
        AnimalTimePicker.popover(
          placeholder: 'Pick',
          focusNode: focusNode,
          onChanged: (_) {},
        ),
        theme: AnimalIslandTheme.light.copyWith(
          components: AnimalComponentThemes(
            focusRing: AnimalFocusRingStyle(color: const Color(0xFF7700CC)),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump(const Duration(seconds: 1));
      expect(region(tester, 'Pick').border!.top.color, const Color(0xFF7700CC));
    });

    testWidgets('wheel items grow so labels fit at 200% text scale', (
      tester,
    ) async {
      final List<AnimalTimeValue?> proposals = <AnimalTimeValue?>[];
      await pumpPicker(
        tester,
        format: 'HH:mm:ss',
        textScale: 2,
        onChanged: proposals.add,
      );
      final double extent = hourWheel(tester).itemExtent;
      // The selected label is typography.subheading: 16 x 1.4 line height x 2.
      expect(extent, closeTo(44.8, 0.5));
      expect(
        tester.getSize(wheelLabel(tester, 9)).height,
        lessThanOrEqualTo(extent),
      );
      expect(tester.getSize(find.byWidget(band(tester))).height, extent);
      expect(tester.takeException(), isNull);

      // A larger selected style grows the extent past the default minimum.
      await pumpPicker(
        tester,
        format: 'HH:mm:ss',
        textScale: 2,
        style: AnimalTimePickerStyle(
          selectedItemTextStyle: const TextStyle(fontSize: 24),
        ),
        onChanged: proposals.add,
      );
      final double grown = hourWheel(tester).itemExtent;
      // The rebuilt wheels stay centered on the shown time.
      expect(
        (hourWheel(tester).controller! as FixedExtentScrollController)
            .selectedItem,
        9,
      );
      expect(
        (hourWheel(tester).controller! as FixedExtentScrollController).offset,
        closeTo(9 * grown, 1e-6),
      );
      expect(grown, closeTo(67.2, 0.5));
      expect(
        tester.getSize(wheelLabel(tester, 9)).height,
        lessThanOrEqualTo(grown),
      );
      // Re-centring is a programmatic batch: it proposes no value.
      expect(proposals, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an item extent change does not jump a wheel the user drags', (
      tester,
    ) async {
      final List<AnimalTimeValue?> proposals = <AnimalTimeValue?>[];
      await pumpPicker(tester, format: 'HH:mm:ss', onChanged: proposals.add);
      FixedExtentScrollController wheel(int index) =>
          tester
                  .widgetList<ListWheelScrollView>(
                    find.byType(ListWheelScrollView),
                  )
                  .elementAt(index)
                  .controller!
              as FixedExtentScrollController;

      final TestGesture drag = await tester.startGesture(
        tester.getCenter(find.byType(ListWheelScrollView).first),
      );
      await drag.moveBy(const Offset(0, -20));
      await drag.moveBy(const Offset(0, -10));
      await tester.pump();
      final double dragged = wheel(0).offset;
      expect(dragged, isNot(closeTo(9 * 36, 1e-6)));

      // Larger type while the finger is still down grows the item extent.
      await pumpPicker(
        tester,
        format: 'HH:mm:ss',
        textScale: 2,
        onChanged: proposals.add,
      );
      final double grown = hourWheel(tester).itemExtent;
      expect(grown, closeTo(44.8, 0.5));
      // The dragged wheel keeps its offset; the others jump to their items.
      expect(wheel(0).offset, closeTo(dragged, 1e-6));
      expect(wheel(1).offset, closeTo(30 * grown, 1e-6));
      expect(wheel(2).offset, closeTo(15 * grown, 1e-6));

      // When the drag ends the wheel settles centred on an item of the new
      // extent (the parent keeps 09:30:15, so it returns to hour 9), and only
      // the dragged hour was proposed.
      await drag.up();
      await tester.pumpAndSettle();
      expect(wheel(0).selectedItem, 9);
      expect(wheel(0).offset, closeTo(9 * grown, 1e-6));
      expect(wheel(1).offset, closeTo(30 * grown, 1e-6));
      expect(proposals, isNotEmpty);
      for (final AnimalTimeValue? proposal in proposals) {
        expect(proposal!.minute, 30);
        expect(proposal.second, 15);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'removing the seconds wheel mid-drag does not block later reconciling',
      (tester) async {
        final List<AnimalTimeValue?> proposals = <AnimalTimeValue?>[];
        await pumpPicker(tester, format: 'HH:mm:ss', onChanged: proposals.add);
        FixedExtentScrollController wheel(int index) =>
            tester
                    .widgetList<ListWheelScrollView>(
                      find.byType(ListWheelScrollView),
                    )
                    .elementAt(index)
                    .controller!
                as FixedExtentScrollController;

        // Start dragging the seconds wheel, then remove it before the drag
        // ends; its scroll end notification never arrives.
        final TestGesture secondsDrag = await tester.startGesture(
          tester.getCenter(find.byType(ListWheelScrollView).at(2)),
        );
        await secondsDrag.moveBy(const Offset(0, -20));
        await secondsDrag.moveBy(const Offset(0, -10));
        await tester.pump();
        await pumpPicker(tester, format: 'HH:mm', onChanged: proposals.add);
        await secondsDrag.up();
        await tester.pumpAndSettle();

        // A later rejected hour drag must still reconcile to the parent's
        // value (09:30), which it cannot do while a stale drag is recorded.
        final TestGesture hourDrag = await tester.startGesture(
          tester.getCenter(find.byType(ListWheelScrollView).first),
        );
        await hourDrag.moveBy(const Offset(0, -20));
        await hourDrag.moveBy(const Offset(0, -30));
        await hourDrag.up();
        await tester.pumpAndSettle();
        expect(proposals, isNotEmpty);
        expect(wheel(0).selectedItem, 9);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('API06 AnimalTimePicker precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalTimePickerStyle(borderWidth: 2.5, headerIconSize: 22),
      );

      // Token defaults: the light preset's border and header icon.
      await pumpPicker(tester);
      expect(panelDecoration(tester).border!.top.width, 1.5);
      expect(tester.widget<AnimalIcon>(find.byType(AnimalIcon)).size, 18);
      expect(hourWheel(tester).itemExtent, 36);
      expect(tester.getSize(find.byWidget(panel(tester))).width, 250);

      // The theme style replaces the defaults.
      await pumpPicker(tester, theme: theme);
      expect(panelDecoration(tester).border!.top.width, 2.5);
      expect(tester.widget<AnimalIcon>(find.byType(AnimalIcon)).size, 22);

      // The instance style wins over the theme; unset fields keep the theme.
      await pumpPicker(
        tester,
        theme: theme,
        style: AnimalTimePickerStyle(borderWidth: 4),
      );
      expect(panelDecoration(tester).border!.top.width, 4);
      expect(tester.widget<AnimalIcon>(find.byType(AnimalIcon)).size, 22);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpPicker(
        tester,
        theme: themed(
          AnimalTimePickerStyle(
            selectedItemTextStyle: const TextStyle(letterSpacing: 1.25),
          ),
        ),
        style: AnimalTimePickerStyle(
          selectedItemTextStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
      final TextStyle style = wheelStyle(tester, 9);
      expect(style.fontWeight, FontWeight.w900);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, 16);
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalTimePicker boundary', () {
    test('styles reject values the picker cannot render', () {
      expect(
        () => AnimalTimePickerStyle(padding: const EdgeInsets.only(left: -1)),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePickerStyle(
          borderRadius: const BorderRadius.all(Radius.circular(-2)),
        ),
        throwsArgumentError,
      );
      expect(() => AnimalTimePickerStyle(width: -1), throwsArgumentError);
      expect(
        () => AnimalTimePickerStyle(minItemExtent: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePickerStyle(borderWidth: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimePickerStyle(
          selectedItemTextStyle: const TextStyle(fontSize: 0),
        ),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(
        AnimalTimePickerStyle(borderWidth: 1, wheelHeight: 140),
      );
      final AnimalIslandTheme b = themed(
        AnimalTimePickerStyle(borderWidth: 3, wheelHeight: 200),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      final AnimalTimePickerStyle mid = a.lerp(b, 0.5).components.timePicker!;
      expect(mid.borderWidth, closeTo(2, 1e-9));
      expect(mid.wheelHeight, closeTo(170, 1e-9));
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      // Only one theme sets these fields; null means "use the lower layer",
      // so interpolation snaps instead of blending from 0 or transparent.
      final AnimalIslandTheme a = themed(
        AnimalTimePickerStyle(
          minItemExtent: 40,
          selectionBackgroundColor: const Color(0xFF00AA44),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.timePicker!.minItemExtent, 40);
      expect(
        early.components.timePicker!.selectionBackgroundColor,
        const Color(0xFF00AA44),
      );
      expect(late.components.timePicker?.minItemExtent, isNull);
      expect(late.components.timePicker?.selectionBackgroundColor, isNull);
    });
  });
}
