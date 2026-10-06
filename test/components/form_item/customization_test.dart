// API06 efficacy and precedence oracles for AnimalFormItem.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String labelText = 'Email address';
  const String helpText = 'Use an island email format';
  const String errorText = 'Email is required';
  const ValueKey<String> contentKey = ValueKey<String>('content');

  late AnimalFormController controller;
  setUp(() => controller = AnimalFormController());

  Future<void> pumpItem(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalFormItemStyle? style,
    bool showError = false,
  }) async {
    final AnimalFieldKey<String> fieldKey = AnimalFieldKey<String>(
      debugLabel: 'email',
    );
    controller = AnimalFormController();
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: AnimalForm(
            controller: controller,
            child: AnimalFormItem<String>(
              key: const ValueKey<String>('item'),
              fieldKey: fieldKey,
              label: labelText,
              help: helpText,
              required: true,
              style: style,
              rules: <AnimalRule<String>>[
                AnimalRule.required(message: errorText),
              ],
              builder: (context, binding) =>
                  const SizedBox(key: contentKey, width: 60, height: 24),
            ),
          ),
        ),
      ),
    );
    if (showError) {
      expect(await controller.validate(), isFalse);
    }
    await tester.pumpAndSettle();
  }

  final Finder item = find.byKey(const ValueKey<String>('item'));
  TextStyle textStyle(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!;
  double renderedBottomMargin(WidgetTester tester) {
    final Padding margin = tester.widget<Padding>(
      find.descendant(of: item, matching: find.byType(Padding)).first,
    );
    return (margin.padding as EdgeInsets).bottom;
  }

  double labelGap(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(contentKey)).dy -
      tester.getBottomLeft(find.text(labelText)).dy;
  double feedbackGap(WidgetTester tester, String feedback) =>
      tester.getTopLeft(find.text(feedback)).dy -
      tester.getBottomLeft(find.byKey(contentKey)).dy;
  Duration feedbackDuration(WidgetTester tester) => tester
      .widget<AnimatedSwitcher>(
        find.descendant(of: item, matching: find.byType(AnimatedSwitcher)),
      )
      .duration;

  AnimalIslandTheme themed(AnimalFormItemStyle formItem) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(formItem: formItem));

  group('API06 AnimalFormItem efficacy', () {
    testWidgets('light preset defaults render unchanged', (tester) async {
      await pumpItem(tester);
      expect(textStyle(tester, labelText).fontSize, 14);
      expect(textStyle(tester, labelText).fontWeight, FontWeight.w600);
      expect(textStyle(tester, '* ').fontWeight, FontWeight.bold);
      expect(textStyle(tester, helpText).fontSize, 12);
      expect(labelGap(tester), closeTo(6, 1e-9));
      expect(feedbackGap(tester, helpText), closeTo(6, 1e-9));
      expect(renderedBottomMargin(tester), 16);
      expect(feedbackDuration(tester), const Duration(milliseconds: 200));

      await pumpItem(tester, showError: true);
      expect(textStyle(tester, errorText).fontSize, 12);
      expect(textStyle(tester, errorText).fontWeight, FontWeight.w500);
      expect(feedbackGap(tester, errorText), closeTo(6, 1e-9));
    });

    testWidgets('token change reaches every derived default', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      final AnimalIslandTheme theme = light.copyWith(
        typography: light.typography.copyWith(
          body: light.typography.body.copyWith(fontSize: 28),
          caption: light.typography.caption.copyWith(fontSize: 20),
        ),
        spacing: light.spacing.copyWith(xxs: 1, sm: 10, lg: 20),
        motion: light.motion.copyWith(fast: const Duration(milliseconds: 240)),
      );
      await pumpItem(tester, theme: theme);
      expect(textStyle(tester, labelText).fontSize, 28);
      expect(textStyle(tester, '* ').fontSize, 28);
      expect(textStyle(tester, helpText).fontSize, 20);
      expect(labelGap(tester), closeTo(9, 1e-9));
      expect(feedbackGap(tester, helpText), closeTo(9, 1e-9));
      expect(renderedBottomMargin(tester), 20);
      expect(feedbackDuration(tester), const Duration(milliseconds: 320));

      await pumpItem(tester, theme: theme, showError: true);
      expect(textStyle(tester, errorText).fontSize, 20);
      expect(feedbackGap(tester, errorText), closeTo(9, 1e-9));
    });

    testWidgets('every component-theme field changes the rendered item', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalFormItemStyle(
          labelTextStyle: const TextStyle(
            color: Color(0xFFAA0000),
            fontSize: 17,
          ),
          requiredMarkTextStyle: const TextStyle(color: Color(0xFF00AA00)),
          helpTextStyle: const TextStyle(
            color: Color(0xFF0000AA),
            fontStyle: FontStyle.italic,
          ),
          errorTextStyle: const TextStyle(
            color: Color(0xFFAAAA00),
            fontWeight: FontWeight.w900,
          ),
          labelGap: 11,
          feedbackGap: 13,
          bottomMargin: 31,
          feedbackDuration: const Duration(milliseconds: 450),
        ),
      );
      await pumpItem(tester, theme: theme);
      expect(textStyle(tester, labelText).color, const Color(0xFFAA0000));
      expect(textStyle(tester, labelText).fontSize, 17);
      expect(textStyle(tester, '* ').color, const Color(0xFF00AA00));
      expect(textStyle(tester, helpText).color, const Color(0xFF0000AA));
      expect(textStyle(tester, helpText).fontStyle, FontStyle.italic);
      // The 17px label is taller than the marker, so it spans the label row.
      expect(labelGap(tester), closeTo(11, 1e-9));
      expect(feedbackGap(tester, helpText), closeTo(13, 1e-9));
      expect(renderedBottomMargin(tester), 31);
      expect(feedbackDuration(tester), const Duration(milliseconds: 450));

      await pumpItem(tester, theme: theme, showError: true);
      expect(textStyle(tester, errorText).color, const Color(0xFFAAAA00));
      expect(textStyle(tester, errorText).fontWeight, FontWeight.w900);
      expect(feedbackGap(tester, errorText), closeTo(13, 1e-9));
    });

    testWidgets('an explicit margin still wins over bottomMargin', (
      tester,
    ) async {
      final AnimalFieldKey<String> fieldKey = AnimalFieldKey<String>(
        debugLabel: 'margin',
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: themed(AnimalFormItemStyle(bottomMargin: 31)).toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              controller: controller,
              child: AnimalFormItem<String>(
                key: const ValueKey<String>('item'),
                fieldKey: fieldKey,
                margin: const EdgeInsets.only(bottom: 3),
                builder: (context, binding) => const SizedBox(height: 24),
              ),
            ),
          ),
        ),
      );
      expect(renderedBottomMargin(tester), 3);
    });
  });

  group('API06 AnimalFormItem precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalFormItemStyle(bottomMargin: 30, feedbackGap: 10),
      );

      // Token default: the light preset's spacing.lg.
      await pumpItem(tester);
      expect(renderedBottomMargin(tester), 16);
      expect(feedbackGap(tester, helpText), closeTo(6, 1e-9));

      // The theme style replaces the token default.
      await pumpItem(tester, theme: theme);
      expect(renderedBottomMargin(tester), 30);
      expect(feedbackGap(tester, helpText), closeTo(10, 1e-9));

      // The instance style wins over the theme for the fields it sets.
      await pumpItem(
        tester,
        theme: theme,
        style: AnimalFormItemStyle(bottomMargin: 40),
      );
      expect(renderedBottomMargin(tester), 40);
      expect(feedbackGap(tester, helpText), closeTo(10, 1e-9));
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpItem(
        tester,
        theme: themed(
          AnimalFormItemStyle(
            labelTextStyle: const TextStyle(letterSpacing: 1.25),
          ),
        ),
        style: AnimalFormItemStyle(
          labelTextStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
      final TextStyle style = textStyle(tester, labelText);
      expect(style.fontWeight, FontWeight.w900);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, 14);
      expect(style.color, AnimalIslandTheme.light.colors.text);
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalFormItem boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalFormItemStyle(labelGap: -1), throwsArgumentError);
      expect(
        () => AnimalFormItemStyle(feedbackGap: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalFormItemStyle(bottomMargin: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalFormItemStyle(
          feedbackDuration: const Duration(milliseconds: -1),
        ),
        throwsArgumentError,
      );
      for (final TextStyle invalid in <TextStyle>[
        const TextStyle(fontSize: 0),
        const TextStyle(fontSize: double.nan),
      ]) {
        expect(
          () => AnimalFormItemStyle(labelTextStyle: invalid),
          throwsArgumentError,
        );
        expect(
          () => AnimalFormItemStyle(requiredMarkTextStyle: invalid),
          throwsArgumentError,
        );
        expect(
          () => AnimalFormItemStyle(helpTextStyle: invalid),
          throwsArgumentError,
        );
        expect(
          () => AnimalFormItemStyle(errorTextStyle: invalid),
          throwsArgumentError,
        );
      }
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(
        AnimalFormItemStyle(
          bottomMargin: 10,
          feedbackDuration: const Duration(milliseconds: 100),
        ),
      );
      final AnimalIslandTheme b = themed(
        AnimalFormItemStyle(
          bottomMargin: 30,
          feedbackDuration: const Duration(milliseconds: 300),
        ),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      final AnimalFormItemStyle mid = a.lerp(b, 0.5).components.formItem!;
      expect(mid.bottomMargin, closeTo(20, 1e-9));
      expect(mid.feedbackDuration, const Duration(milliseconds: 200));
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      // Only one theme sets these fields; null means "use the lower layer".
      // Interpolating from 0 would collapse the margin and the transition.
      final AnimalIslandTheme a = themed(
        AnimalFormItemStyle(
          bottomMargin: 31,
          feedbackDuration: const Duration(milliseconds: 450),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.formItem!.bottomMargin, 31);
      expect(
        early.components.formItem!.feedbackDuration,
        const Duration(milliseconds: 450),
      );
      expect(late.components.formItem?.bottomMargin, isNull);
      expect(late.components.formItem?.feedbackDuration, isNull);
    });
  });
}
