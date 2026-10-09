// API06 efficacy and precedence oracles for AnimalSkeleton.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSkeletons(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalSkeletonStyle? style,
    bool active = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              child: Column(
                children: [
                  AnimalSkeleton(
                    key: const ValueKey('rect'),
                    width: 120,
                    height: 40,
                    active: active,
                    style: style,
                  ),
                  AnimalSkeleton(
                    key: const ValueKey('text'),
                    variant: AnimalSkeletonVariant.text,
                    active: active,
                    style: style,
                  ),
                  AnimalSkeleton.paragraph(
                    key: const ValueKey('paragraph'),
                    rows: 2,
                    active: active,
                    style: style,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // Let MaterialApp finish animating a theme change.
    await tester.pump(const Duration(seconds: 1));
  }

  AnimalIslandTheme themed(AnimalSkeletonStyle skeleton) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(skeleton: skeleton));

  Container block(WidgetTester tester, String key) => tester.widget<Container>(
    find
        .descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(Container),
        )
        .first,
  );
  BoxDecoration decoration(WidgetTester tester, String key) =>
      block(tester, key).decoration! as BoxDecoration;
  Size size(WidgetTester tester, String key) => tester.getSize(
    find
        .descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(Container),
        )
        .first,
  );
  double rowGap(WidgetTester tester) => tester
      .widgetList<Padding>(
        find.descendant(
          of: find.byKey(const ValueKey('paragraph')),
          matching: find.byType(Padding),
        ),
      )
      .map((p) => (p.padding as EdgeInsets).bottom)
      .first;

  group('API06 AnimalSkeleton efficacy', () {
    testWidgets('token changes reach every derived default', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      await pumpSkeletons(
        tester,
        theme: light.copyWith(
          colors: light.colors.copyWith(bgDisabled: const Color(0xFF101010)),
          spacing: light.spacing.copyWith(md: 15, xxs: 3),
        ),
      );
      expect(decoration(tester, 'rect').color, const Color(0xFF101010));
      expect(rowGap(tester), 12);
    });

    testWidgets('every component-theme field changes the rendered skeleton', (
      tester,
    ) async {
      await pumpSkeletons(
        tester,
        active: true,
        theme: themed(
          AnimalSkeletonStyle(
            color: const Color(0xFF102030),
            highlightColor: const Color(0xFFAABBCC),
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            rowHeight: 21,
            rowGap: 9,
          ),
        ),
      );
      final LinearGradient gradient =
          decoration(tester, 'rect').gradient! as LinearGradient;
      expect(gradient.colors, const [
        Color(0xFF102030),
        Color(0xFFAABBCC),
        Color(0xFF102030),
      ]);
      expect(
        decoration(tester, 'rect').borderRadius,
        const BorderRadius.all(Radius.circular(3)),
      );
      expect(
        decoration(tester, 'text').borderRadius,
        const BorderRadius.all(Radius.circular(3)),
      );
      expect(size(tester, 'text').height, 21);
      expect(size(tester, 'paragraph').height, 21);
      expect(rowGap(tester), 9);
    });
  });

  group('API06 AnimalSkeleton precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalSkeletonStyle(color: const Color(0xFF111111), rowHeight: 18),
      );
      await pumpSkeletons(tester);
      expect(
        decoration(tester, 'rect').color,
        AnimalIslandTheme.light.colors.bgDisabled,
      );
      expect(size(tester, 'text').height, 16);
      expect(
        decoration(tester, 'rect').borderRadius,
        AnimalIslandTheme.light.radii.cardBorder,
      );
      expect(
        decoration(tester, 'text').borderRadius,
        AnimalIslandTheme.light.radii.pillBorder,
      );

      await pumpSkeletons(tester, theme: theme);
      expect(decoration(tester, 'rect').color, const Color(0xFF111111));
      expect(size(tester, 'text').height, 18);

      await pumpSkeletons(
        tester,
        theme: theme,
        style: AnimalSkeletonStyle(color: const Color(0xFF222222)),
      );
      expect(decoration(tester, 'rect').color, const Color(0xFF222222));
      expect(size(tester, 'text').height, 18);
    });
  });

  group('API06 AnimalSkeleton boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalSkeletonStyle(rowHeight: -1), throwsArgumentError);
      expect(
        () => AnimalSkeletonStyle(rowGap: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalSkeletonStyle(
          borderRadius: const BorderRadius.all(Radius.circular(-2)),
        ),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalSkeletonStyle a = AnimalSkeletonStyle(rowGap: 4);
      final AnimalSkeletonStyle b = AnimalSkeletonStyle(rowGap: 10);
      expect(AnimalSkeletonStyle.lerp(a, b, 0), same(a));
      expect(AnimalSkeletonStyle.lerp(a, b, 1), same(b));
      expect(AnimalSkeletonStyle.lerp(a, b, 0.5)!.rowGap, 7);
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalSkeletonStyle b = AnimalSkeletonStyle(
        highlightColor: const Color(0xFF00FF00),
      );
      expect(AnimalSkeletonStyle.lerp(null, b, 0.4)!.highlightColor, isNull);
      expect(
        AnimalSkeletonStyle.lerp(null, b, 0.6)!.highlightColor,
        const Color(0xFF00FF00),
      );
    });
  });
}
