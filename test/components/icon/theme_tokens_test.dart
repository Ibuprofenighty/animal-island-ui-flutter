import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../theme_fixtures.dart';

void main() {
  testWidgets('AnimalIcon bounce uses the active theme motion duration', (
    tester,
  ) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: Scaffold(
          body: AnimalIcon(data: AnimalIcons.apple, bounce: true, onTap: () {}),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AnimalIcon)),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final scaleTransitions = tester.widgetList<ScaleTransition>(
      find.descendant(
        of: find.byType(AnimalIcon),
        matching: find.byType(ScaleTransition),
      ),
    );
    final bounce = scaleTransitions.singleWhere(
      (transition) => transition.scale.status == AnimationStatus.forward,
    );
    final firstSample = Duration(
      microseconds: (theme.motion.normal.inMicroseconds * 0.2).round(),
    );
    await tester.pump(firstSample);
    expect(
      bounce.scale.value,
      closeTo(1.0 + 0.25 * theme.motion.ease.transform(0.5), 0.0001),
    );

    final springSample = Duration(
      microseconds: (theme.motion.normal.inMicroseconds * 0.85).round(),
    );
    await tester.pump(springSample - firstSample);
    expect(
      bounce.scale.value,
      closeTo(0.92 + 0.08 * theme.motion.spring.transform(0.5), 0.0001),
    );

    await tester.pump(theme.motion.normal - springSample);
    expect(bounce.scale.value, closeTo(1.0, 0.0001));
  });
}
