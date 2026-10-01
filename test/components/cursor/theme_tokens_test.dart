import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../theme_fixtures.dart';

void main() {
  testWidgets('raindrop cursor art retains its component-owned geometry', (
    tester,
  ) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: const Scaffold(
          body: SizedBox(
            width: 100,
            height: 100,
            child: AnimalCursor(
              type: AnimalCursorType.raindrop,
              child: Text('content'),
            ),
          ),
        ),
      ),
    );

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: const Offset(20, 20));
    await pointer.moveTo(const Offset(40, 40));
    await tester.pump();

    expect(find.byType(AnimalCursor), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
    final dropFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).color ==
              const Color(0xFF60A5FA),
    );
    final drop = tester.widget<Container>(dropFinder);
    expect(tester.getSize(dropFinder), const Size(20, 20));
    expect((drop.decoration! as BoxDecoration).color, const Color(0xFF60A5FA));
    expect((drop.decoration! as BoxDecoration).boxShadow, isNotEmpty);
    await pointer.removePointer();
  });
}
