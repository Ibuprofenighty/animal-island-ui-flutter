import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

/// The positioned art that follows the mouse; it never takes pointer input.
Iterable<Positioned> _art(WidgetTester tester) => tester
    .widgetList<Positioned>(
      find.descendant(
        of: find.byType(AnimalCursor),
        matching: find.byType(Positioned),
      ),
    )
    .where((Positioned positioned) => positioned.child is IgnorePointer);

/// Test mouse gestures report device 1.
MouseCursor? _systemCursor() =>
    RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1);

void main() {
  group('AnimalCursor Behavior Tests (S05 / C04 / CUR01-CUR03)', () {
    testWidgets(
      'CUR01: mouse hover movement, exit, and hit test transparency',
      (tester) async {
        int clickCount = 0;

        await tester.pumpWidget(
          _app(
            AnimalCursor(
              type: AnimalCursorType.defaultCursor,
              child: SizedBox(
                width: 300,
                height: 200,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => clickCount++,
                    child: const Text('Interactive Button'),
                  ),
                ),
              ),
            ),
          ),
        );

        final TestGesture mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: const Offset(150, 100));
        addTearDown(mouse.removePointer);
        await tester.pump();
        expect(_art(tester), hasLength(1));

        // The art and the forcing layer never take the click.
        await tester.tap(find.text('Interactive Button'));
        await tester.pumpAndSettle();
        expect(clickCount, equals(1));
      },
    );

    testWidgets(
      'CUR01 the art follows the mouse, hides on exit and never appears for touch',
      (tester) async {
        await tester.pumpWidget(
          _app(const AnimalCursor(child: SizedBox(width: 200, height: 200))),
        );

        // Touch input never shows the art.
        final TestGesture touch = await tester.startGesture(
          const Offset(50, 50),
        );
        await tester.pump();
        expect(_art(tester), isEmpty);
        await touch.up();
        await tester.pump();

        final TestGesture mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: const Offset(50, 50));
        addTearDown(mouse.removePointer);
        await tester.pump();
        expect(_art(tester).single.left, 44);
        expect(_art(tester).single.top, 44);
        expect(_systemCursor(), SystemMouseCursors.none);

        await mouse.moveTo(const Offset(120, 80));
        await tester.pump();
        expect(_art(tester).single.left, 114);
        expect(_art(tester).single.top, 74);

        await mouse.moveTo(const Offset(400, 400));
        await tester.pump();
        expect(_art(tester), isEmpty);
        expect(_systemCursor(), SystemMouseCursors.basic);
      },
    );

    testWidgets(
      'CUR02 nested custom, system and custom regions show exactly one cursor and the child is tapped once',
      (tester) async {
        int taps = 0;
        await tester.pumpWidget(
          _app(
            AnimalCursor(
              forceAll: false,
              child: SizedBox(
                width: 300,
                height: 300,
                child: Center(
                  child: AnimalCursor(
                    type: AnimalCursorType.pointer,
                    forceAll: false,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: AnimalCursor(
                          type: AnimalCursorType.raindrop,
                          forceAll: false,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => taps++,
                            child: const SizedBox(
                              key: ValueKey('innermost'),
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final TestGesture mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: const Offset(150, 150));
        addTearDown(mouse.removePointer);

        // Innermost raindrop: one art, no system pointer.
        await tester.pump();
        expect(_art(tester), hasLength(1));
        expect(_systemCursor(), SystemMouseCursors.none);

        // The system pointer region in between: no art at all.
        await mouse.moveTo(const Offset(60, 150));
        await tester.pump();
        expect(_art(tester), isEmpty);
        expect(_systemCursor(), SystemMouseCursors.click);

        // The outer paw region: one art again.
        await mouse.moveTo(const Offset(20, 20));
        await tester.pump();
        expect(_art(tester), hasLength(1));
        expect(_systemCursor(), SystemMouseCursors.none);

        await mouse.moveTo(const Offset(150, 150));
        await tester.pump();
        expect(_art(tester), hasLength(1));
        await tester.tap(find.byKey(const ValueKey('innermost')));
        expect(taps, 1);
      },
    );

    testWidgets(
      'CUR02 forceAll replaces descendant cursors; without it a descendant cursor wins and hides the art',
      (tester) async {
        Future<TestGesture> hoverText({required bool forceAll}) async {
          await tester.pumpWidget(
            _app(
              AnimalCursor(
                key: UniqueKey(),
                forceAll: forceAll,
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.text,
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
          );
          final TestGesture mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: const Offset(100, 100));
          await tester.pump();
          await mouse.moveTo(const Offset(101, 100));
          await tester.pump();
          return mouse;
        }

        final TestGesture forced = await hoverText(forceAll: true);
        expect(_art(tester), hasLength(1));
        expect(_systemCursor(), SystemMouseCursors.none);
        await forced.removePointer();

        final TestGesture yielding = await hoverText(forceAll: false);
        expect(_art(tester), isEmpty);
        expect(_systemCursor(), SystemMouseCursors.text);
        await yielding.removePointer();
      },
    );

    testWidgets(
      'CUR03 switching cursor types keeps the child state and one cursor',
      (tester) async {
        final ValueNotifier<AnimalCursorType> type =
            ValueNotifier<AnimalCursorType>(AnimalCursorType.defaultCursor);
        addTearDown(type.dispose);
        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<AnimalCursorType>(
              valueListenable: type,
              builder: (context, value, _) => AnimalCursor(
                type: value,
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: TextField(),
                ),
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), 'kept');
        final TestGesture mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: const Offset(100, 20));
        addTearDown(mouse.removePointer);
        await tester.pump();
        expect(_art(tester), hasLength(1));

        type.value = AnimalCursorType.pointer;
        await tester.pump();
        expect(_art(tester), isEmpty);
        await mouse.moveTo(const Offset(101, 20));
        await tester.pump();
        expect(_art(tester), isEmpty);
        expect(_systemCursor(), SystemMouseCursors.click);

        type.value = AnimalCursorType.raindrop;
        await tester.pump();
        await mouse.moveTo(const Offset(102, 20));
        await tester.pump();
        expect(_art(tester), hasLength(1));
        expect(_systemCursor(), SystemMouseCursors.none);
        expect(find.text('kept'), findsOneWidget);
      },
    );

    testWidgets(
      'CUR03: custom cursor does not dangle or leak listeners on unmount',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const AnimalCursor(
              type: AnimalCursorType.defaultCursor,
              child: Text('Transient Cursor'),
            ),
          ),
        );
        final TestGesture mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: const Offset(10, 5));
        addTearDown(mouse.removePointer);
        await tester.pump();
        expect(find.text('Transient Cursor'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await mouse.moveTo(const Offset(20, 5));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
