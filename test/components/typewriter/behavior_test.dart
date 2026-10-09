import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';
import '../../support/same_frame_rebuild.dart';

Future<void> _pumpElapsed(
  WidgetTester tester,
  FakeClock clock,
  Duration elapsed,
) async {
  clock.advanceMonotonic(elapsed);
  await tester.pump(elapsed);
}

Widget _app(Widget child, {double textScale = 1}) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: child),
    ),
  ),
);

/// Mixed clusters: a letter, a family emoji (11 code units), e with a
/// combining acute accent (2) and a CJK character.
const String _clusters = 'A👨‍👩‍👧‍👦é中';

RenderParagraph _paragraph(WidgetTester tester) =>
    tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(AnimalTypewriter),
        matching: find.byType(RichText),
      ),
    );

/// The render object that paints the revealed text and the cursor.
RenderBox _reveal(WidgetTester tester) =>
    _paragraph(tester).parent! as RenderBox;

void main() {
  group('AnimalTypewriter Behavior & Linear Layout Tests (C03 / TYP01-TYP03)', () {
    testWidgets(
      'TYP01: types Unicode characters including multi-byte emoji without crashing',
      (tester) async {
        int completeCount = 0;
        const testString = 'Welcome to Animal Island! 🏝️✨';
        final clock = FakeClock();

        await tester.pumpWidget(
          _app(
            AnimalTypewriter(
              text: testString,
              speed: const Duration(milliseconds: 50),
              showCursor: true,
              clock: clock,
              onComplete: () => completeCount++,
            ),
          ),
        );

        expect(completeCount, 0);
        final graphemeCount = testString.characters.length;
        for (int i = 0; i < graphemeCount + 2; i++) {
          await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        }

        expect(completeCount, 1);
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 100));
        expect(completeCount, 1);
      },
    );

    testWidgets(
      'TYP01 each tick reveals one whole grapheme cluster and screen readers read the text once',
      (tester) async {
        final clock = FakeClock();
        await tester.pumpWidget(
          _app(
            AnimalTypewriter(
              text: _clusters,
              speed: const Duration(milliseconds: 100),
              showCursor: true,
              clock: clock,
            ),
          ),
        );
        expect(find.bySemanticsLabel(_clusters), findsOneWidget);

        final RenderParagraph paragraph = _paragraph(tester);
        final Color cursor = AnimalIslandTheme.light.colors.primary;
        Offset center(int start, int end) => paragraph
            .getBoxesForSelection(
              TextSelection(baseOffset: start, extentOffset: end),
            )
            .first
            .toRect()
            .center;
        RRect cursorAt(int offset) {
          final TextPosition position = TextPosition(
            offset: offset,
            affinity: TextAffinity.upstream,
          );
          final double height = paragraph.getFullHeightForCaret(position);
          final Offset caret = paragraph.getOffsetForCaret(
            position,
            Rect.fromLTWH(0, 0, 2, height),
          );
          return RRect.fromRectAndRadius(
            caret & Size(2, height),
            const Radius.circular(1),
          );
        }

        expect(
          _reveal(tester),
          isNot(paints..paragraph()),
          reason: 'nothing is revealed before the first tick',
        );
        const List<int> ends = <int>[1, 12, 14, 15];
        for (int index = 0; index < ends.length - 1; index++) {
          await _pumpElapsed(tester, clock, const Duration(milliseconds: 100));
          final int start = index == 0 ? 0 : ends[index - 1];
          expect(
            _reveal(tester),
            paints
              ..clipPath(
                pathMatcher: isPathThat(
                  includes: <Offset>[center(start, ends[index])],
                  excludes: <Offset>[center(ends[index], ends[index + 1])],
                ),
              )
              ..paragraph()
              ..rrect(rrect: cursorAt(ends[index]), color: cursor),
          );
        }
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 100));
        expect(_reveal(tester), isNot(paints..clipPath()));
        expect(_reveal(tester), isNot(paints..rrect(color: cursor)));
      },
    );

    testWidgets(
      'TYP02: text update resets index and restarts typing to new completion',
      (tester) async {
        int completeCount = 0;
        final textNotifier = ValueNotifier<String>('First');
        addTearDown(textNotifier.dispose);
        final clock = FakeClock();

        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<String>(
              valueListenable: textNotifier,
              builder: (context, text, _) => AnimalTypewriter(
                text: text,
                speed: const Duration(milliseconds: 50),
                clock: clock,
                onComplete: () => completeCount++,
              ),
            ),
          ),
        );

        for (int i = 0; i < 7; i++) {
          await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        }
        expect(completeCount, 1);

        textNotifier.value = 'Second Text';
        await tester.pump();
        for (int i = 0; i < 15; i++) {
          await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        }
        expect(completeCount, 2);

        // Replacing the text while it types never completes the old text.
        textNotifier.value = 'Third';
        await tester.pump();
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 100));
        textNotifier.value = 'Fourth';
        await tester.pump();
        for (int i = 0; i < 4; i++) {
          await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        }
        expect(completeCount, 2);
        for (int i = 0; i < 4; i++) {
          await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        }
        expect(completeCount, 3);
      },
    );

    testWidgets(
      'TYP02 empty text and reduced motion show the whole text and complete once after the first frame',
      (tester) async {
        final ValueNotifier<int> completions = ValueNotifier<int>(0);
        addTearDown(completions.dispose);
        final clock = FakeClock();
        // onComplete rebuilds the parent, so it must not run while the
        // typewriter is being built.
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Scaffold(
                body: ValueListenableBuilder<int>(
                  valueListenable: completions,
                  builder: (context, count, _) => Column(
                    children: [
                      Text('completed $count'),
                      AnimalTypewriter(
                        text: '',
                        clock: clock,
                        onComplete: () => completions.value++,
                      ),
                      AnimalTypewriter(
                        text: _clusters,
                        showCursor: true,
                        clock: clock,
                        onComplete: () => completions.value++,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.pump();
        expect(completions.value, 2);
        expect(find.text('completed 2'), findsOneWidget);
        final RenderBox reveal =
            tester
                    .renderObjectList<RenderParagraph>(
                      find.descendant(
                        of: find.byType(AnimalTypewriter).last,
                        matching: find.byType(RichText),
                      ),
                    )
                    .single
                    .parent!
                as RenderBox;
        expect(reveal, paints..paragraph());
        expect(reveal, isNot(paints..clipPath()));
        expect(
          reveal,
          isNot(paints..rrect(color: AnimalIslandTheme.light.colors.primary)),
        );

        await _pumpElapsed(tester, clock, const Duration(seconds: 5));
        expect(completions.value, 2);
      },
    );

    testWidgets(
      'TYP02 a completion scheduled for replaced text or a removed typewriter never runs',
      (tester) async {
        final clock = FakeClock();
        final List<String> completed = <String>[];
        await tester.pumpWidget(
          _app(
            SameFrameRebuild(
              firstWidth: 100,
              builder: (width) => AnimalTypewriter(
                text: width <= 100 ? '' : 'AB',
                speed: const Duration(milliseconds: 50),
                clock: clock,
                onComplete: () => completed.add(width <= 100 ? '' : 'AB'),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(completed, isEmpty);
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        expect(completed, <String>['AB']);

        int removed = 0;
        await tester.pumpWidget(
          _app(
            SameFrameRebuild(
              key: UniqueKey(),
              firstWidth: 100,
              builder: (width) => width <= 100
                  ? AnimalTypewriter(
                      text: '',
                      clock: clock,
                      onComplete: () => removed++,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
        await tester.pump();
        expect(removed, 0);
      },
    );

    testWidgets(
      'TYP03: TickerMode disabled pauses typing and resumes on re-enable',
      (tester) async {
        final tickerNotifier = ValueNotifier<bool>(true);
        addTearDown(tickerNotifier.dispose);
        final clock = FakeClock();
        int completeCount = 0;

        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<bool>(
              valueListenable: tickerNotifier,
              builder: (context, enabled, _) => TickerMode(
                enabled: enabled,
                child: AnimalTypewriter(
                  text: 'Long dialogue text to type out smoothly.',
                  speed: const Duration(milliseconds: 50),
                  clock: clock,
                  onComplete: () => completeCount++,
                ),
              ),
            ),
          ),
        );

        await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        expect(completeCount, 0);

        tickerNotifier.value = false;
        await tester.pump();
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 500));
        expect(completeCount, 0);

        tickerNotifier.value = true;
        await tester.pump();
        for (int i = 0; i < 50; i++) {
          await _pumpElapsed(tester, clock, const Duration(milliseconds: 50));
        }
        expect(completeCount, 1);
      },
    );

    testWidgets(
      'TYP03 retained memory stays linear from 1k to 10k grapheme clusters',
      (tester) async {
        final clock = FakeClock();
        final List<String> samples = <String>[];
        bool exceeded = false;
        for (final int count in <int>[1000, 2000, 4000, 10000]) {
          final String text = _clusters * (count ~/ 4);
          final int before = ProcessInfo.currentRss;
          int completions = 0;
          await tester.pumpWidget(
            _app(
              SingleChildScrollView(
                child: AnimalTypewriter(
                  key: ValueKey<int>(count),
                  text: text,
                  speed: const Duration(milliseconds: 1),
                  showCursor: true,
                  clock: clock,
                  onComplete: () => completions++,
                ),
              ),
            ),
          );
          await _pumpElapsed(tester, clock, Duration(milliseconds: count));
          expect(completions, 1);
          final int growth = ProcessInfo.currentRss - before;
          // A linear structure keeps a few bytes per cluster; holding
          // every prefix and suffix needs hundreds of bytes per cluster
          // at 10k.
          final int bound = 64 * 1024 * 1024 + count * 2048;
          samples.add('$count clusters: +${growth ~/ 1024} KiB');
          if (growth > bound) exceeded = true;
        }
        expect(
          exceeded,
          isFalse,
          reason:
              'TYP03 retained memory exceeded the linear bound: '
              '${samples.join(', ')}',
        );
      },
    );

    testWidgets(
      'TYP04 the layout never changes while typing, with or without the cursor',
      (tester) async {
        final clock = FakeClock();
        const String text =
            'Isabelle 在广场上说：Welcome to the island! 今天我们一起钓鱼、'
            'catch butterflies and build a bridge across the river.';
        final ValueNotifier<bool> cursor = ValueNotifier<bool>(false);
        addTearDown(cursor.dispose);
        await tester.pumpWidget(
          _app(
            SizedBox(
              width: 320,
              child: ValueListenableBuilder<bool>(
                valueListenable: cursor,
                builder: (context, showCursor, _) => AnimalTypewriter(
                  text: text,
                  speed: const Duration(milliseconds: 10),
                  showCursor: showCursor,
                  clock: clock,
                ),
              ),
            ),
            textScale: 2,
          ),
        );
        final Size start = tester.getSize(find.byType(AnimalTypewriter));
        // One selection box per laid-out line fragment.
        List<Rect> lines() => _paragraph(tester)
            .getBoxesForSelection(
              const TextSelection(baseOffset: 0, extentOffset: text.length),
            )
            .map((TextBox box) => box.toRect())
            .toList();
        final List<Rect> startLines = lines();
        expect(startLines.length, greaterThan(3));

        await _pumpElapsed(tester, clock, const Duration(milliseconds: 300));
        cursor.value = true;
        await tester.pump();
        expect(tester.getSize(find.byType(AnimalTypewriter)), start);
        expect(lines(), startLines);
        await _pumpElapsed(tester, clock, const Duration(seconds: 2));
        expect(tester.getSize(find.byType(AnimalTypewriter)), start);
      },
    );

    testWidgets('TYP03 hovering pauses typing and leaving resumes it', (
      tester,
    ) async {
      final clock = FakeClock();
      int completions = 0;
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.topLeft,
            child: AnimalTypewriter(
              text: 'ABC',
              speed: const Duration(milliseconds: 100),
              clock: clock,
              onComplete: () => completions++,
            ),
          ),
        ),
      );
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(
        location: tester.getCenter(find.byType(AnimalTypewriter)),
      );
      addTearDown(mouse.removePointer);
      await tester.pump();
      for (int i = 0; i < 5; i++) {
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 100));
      }
      expect(completions, 0, reason: 'typing pauses while hovered');

      await mouse.moveTo(const Offset(700, 500));
      await tester.pump();
      for (int i = 0; i < 3; i++) {
        await _pumpElapsed(tester, clock, const Duration(milliseconds: 100));
      }
      expect(completions, 1);
    });

    test('a speed that is not positive is rejected', () {
      expect(
        () => AnimalTypewriter(text: 'A', speed: Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => AnimalTypewriter(
          text: 'A',
          speed: const Duration(milliseconds: -1),
        ),
        throwsArgumentError,
      );
    });
  });
}
