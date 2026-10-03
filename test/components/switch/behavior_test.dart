import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

void main() {
  group('AnimalSwitch Tests (C13 / SW01-SW03)', () {
    setUpAll(() async {
      final FontLoader loader = FontLoader('packages/animal_island_ui/Nunito')
        ..addFont(
          rootBundle.load(
            'packages/animal_island_ui/assets/fonts/Nunito[wght].ttf',
          ),
        );
      await loader.load();
    });
    testWidgets('SW01: Tap toggles switch and invokes onChanged', (
      tester,
    ) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalSwitch(value: value, onChanged: (val) => value = val),
          ),
        ),
      );

      await tester.tap(find.byType(AnimalSwitch));
      await tester.pumpAndSettle();

      expect(value, isTrue);
    });

    testWidgets('SW01: Disabled or loading switch ignores taps', (
      tester,
    ) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalSwitch(
                  value: false,
                  disabled: true,
                  onChanged: (val) => callCount++,
                ),
                AnimalSwitch(
                  value: false,
                  loading: true,
                  onChanged: (val) => callCount++,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimalSwitch).first);
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await tester.tap(find.byType(AnimalSwitch).last);
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);
    });

    testWidgets(
      'N15 rejected switch proposal keeps the caller value and rendered state',
      (tester) async {
        final List<bool> proposals = <bool>[];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalSwitch(value: false, onChanged: proposals.add),
            ),
          ),
        );
        final Finder switchFinder = find.byType(AnimalSwitch);
        final Rect initialThumb = _switchThumbRect(tester, switchFinder);
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
        expect(proposals, <bool>[true]);
        final AnimalSwitch switchWidget = tester.widget<AnimalSwitch>(
          switchFinder,
        );
        expect(switchWidget.value, isFalse);
        expect(
          _switchThumbRect(tester, switchFinder).left,
          closeTo(initialThumb.left, 0.1),
          reason: 'A rejected proposal must not drift the thumb.',
        );
        expect(
          tester
              .getSemantics(find.byType(AnimalSwitch))
              .getSemanticsData()
              .flagsCollection
              .isToggled,
          Tristate.isFalse,
        );
      },
    );

    testWidgets(
      'SW02: Two sizes render adaptive labels and a flat end-to-end thumb',
      (tester) async {
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final AnimalIslandTheme theme in <AnimalIslandTheme>[
          AnimalIslandTheme.light,
          AnimalIslandTheme.dark,
        ]) {
          for (final AnimalSwitchSize size in AnimalSwitchSize.values) {
            for (final bool value in <bool>[false, true]) {
              tester.view.devicePixelRatio = value ? 2 : 1;
              for (final double textScale in <double>[1, 2]) {
                for (final TextDirection textDirection in <TextDirection>[
                  TextDirection.ltr,
                  TextDirection.rtl,
                ]) {
                  final FocusNode focusNode = FocusNode();
                  addTearDown(focusNode.dispose);
                  Widget matrixApp(bool currentValue) => MaterialApp(
                    localizationsDelegates:
                        AnimalLocalizations.localizationsDelegates,
                    supportedLocales: AnimalLocalizations.supportedLocales,
                    theme: theme.toThemeData(),
                    builder: (BuildContext context, Widget? child) =>
                        MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaler: TextScaler.linear(textScale)),
                          child: child!,
                        ),
                    home: Scaffold(
                      body: Directionality(
                        textDirection: textDirection,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: AnimalSwitch(
                                  value: currentValue,
                                  size: size,
                                  focusNode: focusNode,
                                  checkedChildren: const Text('ON'),
                                  unCheckedChildren: const Text('OFF'),
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              const SizedBox(
                                key: ValueKey<String>('switch-neighbor'),
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  await tester.pumpWidget(const SizedBox.shrink());
                  await tester.pumpWidget(matrixApp(value));
                  if (theme == AnimalIslandTheme.light &&
                      size == AnimalSwitchSize.small &&
                      value &&
                      textDirection == TextDirection.ltr &&
                      textScale == 1) {
                    focusNode.requestFocus();
                  }
                  await tester.pumpAndSettle();

                  final Finder switchFinder = find.byType(AnimalSwitch);
                  final Finder track = find
                      .descendant(
                        of: switchFinder,
                        matching: find.byType(AnimatedContainer),
                      )
                      .last;
                  final Finder thumb = find.descendant(
                    of: switchFinder,
                    matching: find.byWidgetPredicate((Widget widget) {
                      if (widget is! Container ||
                          widget.decoration is! BoxDecoration) {
                        return false;
                      }
                      return (widget.decoration! as BoxDecoration).shape ==
                          BoxShape.circle;
                    }),
                  );
                  final Rect trackRect = tester.getRect(track);
                  final BoxDecoration trackDecoration =
                      tester.widget<AnimatedContainer>(track).decoration!
                          as BoxDecoration;
                  final Rect thumbRect = tester.getRect(thumb);
                  final Rect hitRect = tester.getRect(
                    find.descendant(
                      of: switchFinder,
                      matching: find.byType(InteractiveRegion),
                    ),
                  );
                  final Rect neighborRect = tester.getRect(
                    find.byKey(const ValueKey<String>('switch-neighbor')),
                  );
                  final double expectedHitWidth = trackRect.width < 48
                      ? 48
                      : trackRect.width;
                  final double expectedHitHeight = trackRect.height < 48
                      ? 48
                      : trackRect.height;
                  expect(hitRect.width, closeTo(expectedHitWidth, 0.1));
                  expect(hitRect.height, closeTo(expectedHitHeight, 0.1));
                  expect(hitRect.overlaps(neighborRect), isFalse);
                  final double neighborGap = hitRect.right <= neighborRect.left
                      ? neighborRect.left - hitRect.right
                      : hitRect.left - neighborRect.right;
                  expect(neighborGap, closeTo(12, 0.1));
                  expect(trackRect.width, greaterThanOrEqualTo(size.width));
                  expect(trackRect.height, greaterThanOrEqualTo(size.height));
                  expect(
                    trackRect.width,
                    greaterThanOrEqualTo(trackRect.height),
                  );
                  final RRect renderedTrackShape = trackDecoration.borderRadius!
                      .resolve(textDirection)
                      .toRRect(trackRect)
                      .scaleRadii();
                  expect(renderedTrackShape.isStadium, isTrue);
                  expect(thumbRect.size, Size(size.thumbSize, size.thumbSize));
                  expect(
                    (thumbRect.center.dy - trackRect.center.dy).abs(),
                    lessThanOrEqualTo(1),
                  );
                  expect(
                    (thumbRect.center.dx < trackRect.center.dx),
                    value == (textDirection == TextDirection.rtl),
                  );
                  final bool thumbAtLogicalStart =
                      value == (textDirection == TextDirection.rtl);
                  final double thumbEndpointInset = thumbAtLogicalStart
                      ? thumbRect.left - trackRect.left
                      : trackRect.right - thumbRect.right;
                  final double trackBorderInset =
                      (trackDecoration.border! as Border).left.width;
                  expect(
                    thumbEndpointInset - trackBorderInset,
                    closeTo((size.height - size.thumbSize) / 2, 0.1),
                  );
                  final String labelText = value ? 'ON' : 'OFF';
                  final Finder labelFinder = find.text(labelText);
                  final Rect labelRect = tester.getRect(labelFinder);
                  final RenderParagraph paragraph = tester
                      .renderObject<RenderParagraph>(labelFinder);
                  expect(paragraph.text.toPlainText(), labelText);
                  expect(paragraph.didExceedMaxLines, isFalse);
                  final List<TextBox> glyphBoxes = paragraph
                      .getBoxesForSelection(
                        TextSelection(
                          baseOffset: 0,
                          extentOffset: labelText.length,
                        ),
                      );
                  expect(glyphBoxes, isNotEmpty);
                  expect(labelRect.left, greaterThanOrEqualTo(trackRect.left));
                  expect(labelRect.right, lessThanOrEqualTo(trackRect.right));
                  expect(labelRect.top, greaterThanOrEqualTo(trackRect.top));
                  expect(labelRect.bottom, lessThanOrEqualTo(trackRect.bottom));
                  expect(labelRect.height, lessThanOrEqualTo(trackRect.height));
                  for (final TextBox box in glyphBoxes) {
                    final Rect glyphRect = Rect.fromPoints(
                      paragraph.localToGlobal(Offset(box.left, box.top)),
                      paragraph.localToGlobal(Offset(box.right, box.bottom)),
                    );
                    final String glyphReason =
                        '${theme.colors.brightness.name} ${size.name} value=$value direction=$textDirection scale=$textScale glyph=$glyphRect label=$labelRect paragraphOrigin=${paragraph.localToGlobal(Offset.zero)} paragraphSize=${paragraph.size} track=$trackRect thumb=$thumbRect';
                    expect(
                      glyphRect.left,
                      greaterThanOrEqualTo(trackRect.left),
                      reason: glyphReason,
                    );
                    expect(
                      glyphRect.right,
                      lessThanOrEqualTo(trackRect.right),
                      reason: glyphReason,
                    );
                    expect(
                      glyphRect.top,
                      greaterThanOrEqualTo(trackRect.top),
                      reason: glyphReason,
                    );
                    expect(
                      glyphRect.bottom,
                      lessThanOrEqualTo(trackRect.bottom),
                      reason: glyphReason,
                    );
                    expect(
                      glyphRect.overlaps(thumbRect),
                      isFalse,
                      reason: glyphReason,
                    );
                  }
                  if (focusNode.hasFocus) {
                    final Finder focusedOuterTrack = find.descendant(
                      of: switchFinder,
                      matching: find.byWidgetPredicate((Widget widget) {
                        if (widget is! Container ||
                            widget.foregroundDecoration is! BoxDecoration) {
                          return false;
                        }
                        return ((widget.foregroundDecoration! as BoxDecoration)
                                .border !=
                            null);
                      }),
                    );
                    expect(tester.getSize(focusedOuterTrack), trackRect.size);
                    final BoxDecoration focusedDecoration =
                        tester
                                .widget<Container>(focusedOuterTrack)
                                .foregroundDecoration!
                            as BoxDecoration;
                    expect(
                      (focusedDecoration.border! as Border).top.color,
                      theme.colors.focusYellow,
                    );
                  }
                  await tester.pumpWidget(matrixApp(!value));
                  await tester.pumpAndSettle();
                  final Finder toggledTrack = find
                      .descendant(
                        of: switchFinder,
                        matching: find.byType(AnimatedContainer),
                      )
                      .last;
                  expect(tester.getSize(toggledTrack), trackRect.size);
                  expect(tester.takeException(), isNull);
                }
              }
            }
          }
        }
      },
    );

    testWidgets(
      'N15 finite caller bounds preserve arbitrary label identity and layout',
      (tester) async {
        final List<Object> created = <Object>[];
        final List<Object> disposed = <Object>[];
        final List<double> checkedConstraints = <double>[];
        final List<double> uncheckedConstraints = <double>[];
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          Widget app(bool value) => MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: AnimalSwitch(
                        key: const ValueKey<String>('stable-label-switch'),
                        value: value,
                        onChanged: (_) {},
                        checkedChildren: _StatefulSwitchLabel(
                          key: const ValueKey<String>('checked-layout-label'),
                          semanticLabel: 'checked custom label',
                          constraints: checkedConstraints,
                          created: created,
                          disposed: disposed,
                        ),
                        unCheckedChildren: LayoutBuilder(
                          builder:
                              (
                                BuildContext context,
                                BoxConstraints constraints,
                              ) {
                                uncheckedConstraints.add(constraints.maxWidth);
                                return Semantics(
                                  label: 'unchecked custom label',
                                  child: const SizedBox(width: 36, height: 16),
                                );
                              },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          await tester.pumpWidget(app(false));
          expect(created, hasLength(1));
          expect(checkedConstraints, isNotEmpty);
          expect(uncheckedConstraints, isNotEmpty);
          expect(
            checkedConstraints.every((double width) => width.isFinite),
            isTrue,
          );
          expect(
            uncheckedConstraints.every((double width) => width.isFinite),
            isTrue,
          );
          expect(
            checkedConstraints.last,
            closeTo(uncheckedConstraints.last, 0.1),
            reason: 'Both caller widgets receive the same child constraints.',
          );
          SemanticsData semanticsData = tester
              .getSemantics(find.byType(AnimalSwitch))
              .getSemanticsData();
          expect(semanticsData.label, 'Switch');
          expect(semanticsData.flagsCollection.isToggled, Tristate.isFalse);
          expect(find.bySemanticsLabel('checked custom label'), findsNothing);
          expect(find.bySemanticsLabel('unchecked custom label'), findsNothing);

          await tester.pumpWidget(app(true));
          await tester.pumpAndSettle();
          expect(created, hasLength(1));
          expect(disposed, isEmpty);
          expect(tester.takeException(), isNull);
          semanticsData = tester
              .getSemantics(find.byType(AnimalSwitch))
              .getSemanticsData();
          expect(semanticsData.label, 'Switch');
          expect(semanticsData.flagsCollection.isToggled, Tristate.isTrue);
          expect(find.bySemanticsLabel('checked custom label'), findsNothing);
          expect(find.bySemanticsLabel('unchecked custom label'), findsNothing);

          await tester.pumpWidget(app(false));
          await tester.pumpAndSettle();
          expect(created, hasLength(1));
          expect(disposed, isEmpty);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets(
      'N15 LayoutBuilder labels receive one finite layout under a bounded Row',
      (tester) async {
        final List<double> checkedWidths = <double>[];
        final List<double> uncheckedWidths = <double>[];

        Widget app(bool value) => MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: AnimalSwitch(
                        key: const ValueKey<String>('bounded-row-switch'),
                        value: value,
                        onChanged: (_) {},
                        checkedChildren: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints c) {
                            checkedWidths.add(c.maxWidth);
                            return const Text('ON in a Row');
                          },
                        ),
                        unCheckedChildren: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints c) {
                            uncheckedWidths.add(c.maxWidth);
                            return const Text('OFF in a Row');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(app(false));
        await tester.pumpAndSettle();
        expect(checkedWidths, isNotEmpty);
        expect(uncheckedWidths, isNotEmpty);
        expect(checkedWidths.last.isFinite, isTrue);
        expect(uncheckedWidths.last.isFinite, isTrue);
        expect(checkedWidths.last, closeTo(uncheckedWidths.last, 0.1));

        await tester.pumpWidget(app(true));
        await tester.pumpAndSettle();
        expect(checkedWidths.last, closeTo(uncheckedWidths.last, 0.1));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'N15 finite horizontal-scroll caller bound resizes stable labels',
      (tester) async {
        tester.view.physicalSize = const Size(900, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final List<double> checkedWidths = <double>[];
        final List<double> uncheckedWidths = <double>[];
        double visibleWidth = 184;
        StateSetter? resizeCallerWidth;
        final Widget checkedLabel = LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            checkedWidths.add(constraints.maxWidth);
            return const Text('A long checked label');
          },
        );
        final Widget uncheckedLabel = LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            uncheckedWidths.add(constraints.maxWidth);
            return const Text('A long unchecked label');
          },
        );
        final AnimalSwitch stableSwitch = AnimalSwitch(
          key: const ValueKey<String>('nested-viewport-switch'),
          value: false,
          onChanged: (bool _) {},
          checkedChildren: checkedLabel,
          unCheckedChildren: uncheckedLabel,
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    resizeCallerWidth = setState;
                    return SizedBox(
                      width: visibleWidth,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: visibleWidth,
                              ),
                              child: stableSwitch,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        void expectCallerMaxWidth(double maxWidth) {
          expect(checkedWidths, isNotEmpty);
          expect(uncheckedWidths, isNotEmpty);
          final double checkedWidth = checkedWidths.last;
          final double uncheckedWidth = uncheckedWidths.last;
          expect(checkedWidth.isFinite, isTrue);
          expect(uncheckedWidth.isFinite, isTrue);
          expect(checkedWidth, closeTo(uncheckedWidth, 0.1));
          expect(
            checkedWidth,
            lessThanOrEqualTo(
              maxWidth - AnimalSwitchSize.defaultSize.height - 4,
            ),
          );
          final Finder track = find
              .descendant(
                of: find.byType(AnimalSwitch),
                matching: find.byType(AnimatedContainer),
              )
              .last;
          expect(tester.getRect(track).width, lessThanOrEqualTo(maxWidth));
          expect(tester.takeException(), isNull);
        }

        expectCallerMaxWidth(184);
        final int previousCheckedLayouts = checkedWidths.length;
        final int previousUncheckedLayouts = uncheckedWidths.length;
        resizeCallerWidth!(() => visibleWidth = 152);
        await tester.pump();
        expect(checkedWidths.length, greaterThan(previousCheckedLayouts));
        expect(uncheckedWidths.length, greaterThan(previousUncheckedLayouts));
        expectCallerMaxWidth(152);
      },
    );

    testWidgets('N15 unbounded width is rejected with and without labels', (
      tester,
    ) async {
      for (final bool hasLabels in <bool>[false, true]) {
        final AnimalSwitch switchWidget = AnimalSwitch(
          value: false,
          onChanged: (_) {},
          checkedChildren: hasLabels ? const Text('ON') : null,
          unCheckedChildren: hasLabels ? const Text('OFF') : null,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[switchWidget],
                ),
              ),
            ),
          ),
        );
        final Object? error = tester.takeException();
        expect(error, isA<FlutterError>());
        expect(
          error.toString(),
          contains('AnimalSwitch requires a finite maximum width'),
        );
        expect(error.toString(), contains('Flexible'));
        expect(error.toString(), contains('horizontal scrolling'));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets(
      'N15 switch wraps complete labels within a constrained track and grows',
      (tester) async {
        Widget app(bool value) => MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 84),
                child: AnimalSwitch(
                  value: value,
                  size: AnimalSwitchSize.small,
                  onChanged: (_) {},
                  checkedChildren: const Text('ON keeps every word visible'),
                  unCheckedChildren: const Text('OFF keeps every word visible'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(app(false));
        await tester.pumpAndSettle();
        final Finder track = find
            .descendant(
              of: find.byType(AnimalSwitch),
              matching: find.byType(AnimatedContainer),
            )
            .last;
        final Size offSize = tester.getSize(track);
        expect(offSize.width, lessThanOrEqualTo(84));
        expect(offSize.height, greaterThan(AnimalSwitchSize.small.height));
        final Finder offLabel = find.text('OFF keeps every word visible');
        final RenderParagraph offParagraph = tester
            .renderObject<RenderParagraph>(offLabel);
        expect(offParagraph.didExceedMaxLines, isFalse);
        expect(offParagraph.text.toPlainText(), 'OFF keeps every word visible');
        final Rect offTrackRect = tester.getRect(track);
        final Rect offThumbRect = tester.getRect(
          find.descendant(
            of: find.byType(AnimalSwitch),
            matching: find.byWidgetPredicate((Widget widget) {
              return widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).shape ==
                      BoxShape.circle;
            }),
          ),
        );
        for (final TextBox box in offParagraph.getBoxesForSelection(
          TextSelection(
            baseOffset: 0,
            extentOffset: offParagraph.text.toPlainText().length,
          ),
        )) {
          final Rect glyph = Rect.fromPoints(
            offParagraph.localToGlobal(Offset(box.left, box.top)),
            offParagraph.localToGlobal(Offset(box.right, box.bottom)),
          );
          expect(glyph.left, greaterThanOrEqualTo(offTrackRect.left));
          expect(glyph.right, lessThanOrEqualTo(offTrackRect.right));
          expect(glyph.top, greaterThanOrEqualTo(offTrackRect.top));
          expect(glyph.bottom, lessThanOrEqualTo(offTrackRect.bottom));
          expect(glyph.overlaps(offThumbRect), isFalse);
        }

        await tester.pumpWidget(app(true));
        await tester.pumpAndSettle();
        expect(tester.getSize(track), offSize);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'N15 accepted pointer transition stages labels and preserves thumb on reverse',
      (tester) async {
        bool value = false;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    AnimalSwitch(
                      value: value,
                      onChanged: (bool next) => setState(() => value = next),
                      checkedChildren: const Text('ON'),
                      unCheckedChildren: const Text('OFF'),
                    ),
              ),
            ),
          ),
        );

        final Finder switchFinder = find.byType(AnimalSwitch);
        final Duration duration = _switchTrackDuration(tester, switchFinder);
        final Rect initialThumb = _switchThumbRect(tester, switchFinder);
        await _tapSwitchAtZero(tester, switchFinder);
        expect(value, isTrue);
        await _expectStagedTransitionFrames(
          tester,
          switchFinder,
          duration: duration,
          outgoingLabel: 'OFF',
          incomingLabel: 'ON',
        );

        await _tapSwitchAtZero(tester, switchFinder);
        expect(value, isFalse);
        final Rect firstEndThumb = _switchThumbRect(tester, switchFinder);
        await tester.pump(_switchDurationPart(duration, 0.2));
        final double reverseStart = _switchThumbRect(tester, switchFinder).left;
        expect(reverseStart, greaterThan(initialThumb.left));
        expect(reverseStart, lessThan(firstEndThumb.left));
        expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 0);
        expect(_switchLabelOpacity(tester, switchFinder, 'OFF'), 0);

        tester.widget<AnimalSwitch>(switchFinder).onChanged!(true);
        await tester.pump(Duration.zero);
        expect(value, isTrue);
        expect(
          _switchThumbRect(tester, switchFinder).left,
          closeTo(reverseStart, 0.1),
          reason: 'An external reversal starts at the current thumb position.',
        );
        expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 0);
        expect(_switchLabelOpacity(tester, switchFinder, 'OFF'), 0);
        _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);
        await tester.pump(_switchDurationPart(duration, 0.05));
        expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 0);
        expect(_switchLabelOpacity(tester, switchFinder, 'OFF'), 0);
        expect(
          _switchThumbRect(tester, switchFinder).left,
          closeTo(reverseStart, 0.1),
          reason: 'The outgoing label clears before reverse thumb travel.',
        );
        await tester.pump(_switchDurationPart(duration, 0.15));
        expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 0);
        expect(_switchLabelOpacity(tester, switchFinder, 'OFF'), 0);
        expect(
          _switchThumbRect(tester, switchFinder).left,
          greaterThan(reverseStart),
        );
        await tester.pumpAndSettle();
        expect(value, isTrue);
        expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 1);
        _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);
      },
    );

    testWidgets(
      'N15 accepted keyboard transition animates while focused without glyph overlap',
      (tester) async {
        bool value = false;
        final FocusNode focusNode = FocusNode();
        addTearDown(focusNode.dispose);
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    AnimalSwitch(
                      value: value,
                      focusNode: focusNode,
                      onChanged: (bool next) => setState(() => value = next),
                      checkedChildren: const Text('ON'),
                      unCheckedChildren: const Text('OFF'),
                    ),
              ),
            ),
          ),
        );
        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);

        final Finder switchFinder = find.byType(AnimalSwitch);
        final Duration duration = _switchTrackDuration(tester, switchFinder);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
        await tester.pump(Duration.zero);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
        await tester.pump(Duration.zero);
        expect(value, isTrue);
        expect(_switchTrackDuration(tester, switchFinder), duration);
        await _expectStagedTransitionFrames(
          tester,
          switchFinder,
          duration: duration,
          outgoingLabel: 'OFF',
          incomingLabel: 'ON',
        );
        expect(focusNode.hasFocus, isTrue);
        final Finder focusShell = find.descendant(
          of: switchFinder,
          matching: find.byWidgetPredicate((Widget widget) {
            return widget is Container &&
                widget.foregroundDecoration is BoxDecoration &&
                ((widget.foregroundDecoration! as BoxDecoration).border !=
                    null);
          }),
        );
        expect(focusShell, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('N15 reduced motion makes the switch transition immediate', (
      tester,
    ) async {
      bool value = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    AnimalSwitch(
                      value: value,
                      onChanged: (bool next) => setState(() => value = next),
                      checkedChildren: const Text('ON'),
                      unCheckedChildren: const Text('OFF'),
                    ),
              ),
            ),
          ),
        ),
      );
      final Finder switchFinder = find.byType(AnimalSwitch);
      final Rect initialThumb = _switchThumbRect(tester, switchFinder);
      final AnimatedContainer track = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: switchFinder,
              matching: find.byType(AnimatedContainer),
            )
            .last,
      );
      expect(track.duration, Duration.zero);
      await tester.tap(switchFinder);
      await tester.pump();
      expect(value, isTrue);
      expect(
        _switchThumbRect(tester, switchFinder).left,
        greaterThan(initialThumb.left),
      );
      _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(of: find.text('ON'), matching: find.byType(Opacity))
                  .first,
            )
            .opacity,
        1,
      );
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.text('OFF'),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        0,
      );
    });

    testWidgets(
      'N15 disabling TickerMode finishes an active transition at its target',
      (tester) async {
        bool value = false;
        bool tickerEnabled = true;
        late StateSetter updateHarness;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  updateHarness = setState;
                  return TickerMode(
                    enabled: tickerEnabled,
                    child: AnimalSwitch(
                      value: value,
                      onChanged: (bool next) => setState(() => value = next),
                      checkedChildren: const Text('ON'),
                      unCheckedChildren: const Text('OFF'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        final Finder switchFinder = find.byType(AnimalSwitch);
        await _tapSwitchAtZero(tester, switchFinder);
        expect(value, isTrue);
        final Duration duration = _switchTrackDuration(tester, switchFinder);
        await tester.pump(
          Duration(microseconds: duration.inMicroseconds ~/ 20),
        );
        expect(
          _switchLabelOpacity(tester, switchFinder, 'OFF'),
          greaterThan(0),
        );

        updateHarness(() => tickerEnabled = false);
        await tester.pump(Duration.zero);
        expect(_switchTrackDuration(tester, switchFinder), Duration.zero);
        expect(_switchLabelOpacity(tester, switchFinder, 'OFF'), 0);
        expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 1);
        _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'N15 pausing the app completes an active transition immediately',
      (tester) async {
        bool value = false;
        int proposals = 0;
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) =>
                    AnimalSwitch(
                      value: value,
                      onChanged: (bool next) {
                        proposals++;
                        setState(() => value = next);
                      },
                      checkedChildren: const Text('ON'),
                      unCheckedChildren: const Text('OFF'),
                    ),
              ),
            ),
          ),
        );

        final Finder switchFinder = find.byType(AnimalSwitch);
        final Duration duration = _switchTrackDuration(tester, switchFinder);
        await _tapSwitchAtZero(tester, switchFinder);
        expect(value, isTrue);
        expect(proposals, 1);
        await tester.pump(_switchDurationPart(duration, 0.2));
        expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 0);
        expect(_switchLabelOpacity(tester, switchFinder, 'OFF'), 0);
        final double midpointLeft = _switchThumbRect(tester, switchFinder).left;

        try {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          await tester.pump(Duration.zero);
          expect(_switchTrackDuration(tester, switchFinder), Duration.zero);
          expect(
            _switchThumbRect(tester, switchFinder).left,
            greaterThan(midpointLeft),
          );
          expect(_switchLabelOpacity(tester, switchFinder, 'OFF'), 0);
          expect(_switchLabelOpacity(tester, switchFinder, 'ON'), 1);
          expect(proposals, 1);
          _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);
          expect(tester.takeException(), isNull);
        } finally {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        }
      },
    );

    testWidgets(
      'SW04: Adaptive switch portrait matrix matches its rendered golden',
      (tester) async {
        tester.view.devicePixelRatio = 2;
        tester.view.physicalSize = const Size(480, 2400);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final FocusNode focusedNode = FocusNode();
        addTearDown(focusedNode.dispose);

        Widget switchPair(
          AnimalSwitchSize size,
          TextDirection direction, {
          bool focusUnchecked = false,
        }) => Directionality(
          textDirection: direction,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 200),
                child: AnimalSwitch(
                  value: false,
                  focusNode: focusUnchecked ? focusedNode : null,
                  size: size,
                  onChanged: (_) {},
                  checkedChildren: const Text('ON'),
                  unCheckedChildren: const Text('OFF'),
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 200),
                child: AnimalSwitch(
                  value: true,
                  size: size,
                  onChanged: (_) {},
                  checkedChildren: const Text('ON'),
                  unCheckedChildren: const Text('OFF'),
                ),
              ),
            ],
          ),
        );

        Widget themePanel(
          AnimalIslandTheme theme, {
          required String title,
          required bool focusUnchecked,
        }) => Theme(
          data: theme.toThemeData(),
          child: Builder(
            builder: (BuildContext context) {
              final MediaQueryData baseMedia = MediaQuery.of(context);
              return ColoredBox(
                color: theme.colors.bgContent,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(title, style: TextStyle(color: theme.colors.text)),
                      for (final double textScale in <double>[
                        1,
                        2,
                      ]) ...<Widget>[
                        const SizedBox(height: 8),
                        MediaQuery(
                          data: baseMedia.copyWith(
                            textScaler: TextScaler.linear(textScale),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '$textScale× · Small · LTR',
                                style: TextStyle(color: theme.colors.text),
                              ),
                              const SizedBox(height: 4),
                              switchPair(
                                AnimalSwitchSize.small,
                                TextDirection.ltr,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$textScale× · Default · RTL',
                                style: TextStyle(color: theme.colors.text),
                              ),
                              const SizedBox(height: 4),
                              switchPair(
                                AnimalSwitchSize.defaultSize,
                                TextDirection.rtl,
                                focusUnchecked:
                                    focusUnchecked && textScale == 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    themePanel(
                      AnimalIslandTheme.light,
                      title: 'Light',
                      focusUnchecked: false,
                    ),
                    const SizedBox(height: 12),
                    themePanel(
                      AnimalIslandTheme.dark,
                      title: 'Dark',
                      focusUnchecked: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        focusedNode.requestFocus();
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/animal_switch_n15.png'),
        );
      },
    );

    testWidgets('SW03: Semantics reports toggle status accurately', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalSwitch(value: true, onChanged: (_) {})),
          ),
        );

        expect(find.bySemanticsLabel('Switch'), findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets(
      'N15 readOnly stays focusable while null and readOnly callbacks never activate',
      (tester) async {
        final FocusNode readOnlyFocus = FocusNode();
        final FocusNode callbackNullFocus = FocusNode();
        addTearDown(readOnlyFocus.dispose);
        addTearDown(callbackNullFocus.dispose);
        final SemanticsHandle semantics = tester.ensureSemantics();
        try {
          int calls = 0;

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: Column(
                  children: <Widget>[
                    AnimalSwitch(
                      value: false,
                      readOnly: true,
                      focusNode: readOnlyFocus,
                      onChanged: (_) => calls++,
                    ),
                    AnimalSwitch(
                      value: false,
                      focusNode: callbackNullFocus,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
            ),
          );

          readOnlyFocus.requestFocus();
          await tester.pump();
          expect(readOnlyFocus.hasFocus, isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();
          await tester.tap(find.byType(AnimalSwitch).first);
          await tester.pump();
          await tester.tap(find.byType(AnimalSwitch).last);
          await tester.pump();
          expect(calls, 0);
          expect(
            tester
                .getSemantics(find.byType(AnimalSwitch).first)
                .getSemanticsData()
                .hasAction(SemanticsAction.tap),
            isFalse,
          );
          expect(
            tester
                .getSemantics(find.byType(AnimalSwitch).first)
                .getSemanticsData()
                .flagsCollection
                .isReadOnly,
            isTrue,
          );
          expect(callbackNullFocus.hasFocus, isFalse);
        } finally {
          semantics.dispose();
        }
      },
    );
  });
}

Finder _switchThumbFinder(Finder switchFinder) => find.descendant(
  of: switchFinder,
  matching: find.byWidgetPredicate((Widget widget) {
    return widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration! as BoxDecoration).shape == BoxShape.circle;
  }),
);

Rect _switchThumbRect(WidgetTester tester, Finder switchFinder) =>
    tester.getRect(_switchThumbFinder(switchFinder));

Duration _switchTrackDuration(WidgetTester tester, Finder switchFinder) =>
    tester
        .widget<AnimatedContainer>(
          find
              .descendant(
                of: switchFinder,
                matching: find.byType(AnimatedContainer),
              )
              .last,
        )
        .duration;

Finder _switchLabelFinder(Finder switchFinder, String label) =>
    find.descendant(of: switchFinder, matching: find.text(label));

double _switchLabelOpacity(
  WidgetTester tester,
  Finder switchFinder,
  String label,
) {
  final Finder labelFinder = _switchLabelFinder(switchFinder, label);
  return tester
      .widget<Opacity>(
        find.ancestor(of: labelFinder, matching: find.byType(Opacity)).first,
      )
      .opacity;
}

void _expectVisibleSwitchGlyphsClearOfThumb(
  WidgetTester tester,
  Finder switchFinder,
) {
  final Rect thumbRect = _switchThumbRect(tester, switchFinder);
  for (final String label in <String>['ON', 'OFF']) {
    final Finder labelFinder = _switchLabelFinder(switchFinder, label);
    if (labelFinder.evaluate().isEmpty ||
        _switchLabelOpacity(tester, switchFinder, label) <= 0) {
      continue;
    }
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      labelFinder,
    );
    final List<TextBox> glyphBoxes = paragraph.getBoxesForSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: paragraph.text.toPlainText().length,
      ),
    );
    expect(glyphBoxes, isNotEmpty, reason: 'Visible label $label has glyphs.');
    for (final TextBox box in glyphBoxes) {
      final Rect glyphRect = Rect.fromPoints(
        paragraph.localToGlobal(Offset(box.left, box.top)),
        paragraph.localToGlobal(Offset(box.right, box.bottom)),
      );
      expect(
        glyphRect.overlaps(thumbRect),
        isFalse,
        reason: 'Visible $label glyph $glyphRect overlaps thumb $thumbRect.',
      );
    }
  }
}

Duration _switchDurationPart(Duration duration, double fraction) =>
    Duration(microseconds: (duration.inMicroseconds * fraction).round());

Future<void> _tapSwitchAtZero(WidgetTester tester, Finder switchFinder) async {
  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(switchFinder),
  );
  await tester.pump(Duration.zero);
  await gesture.up();
  await tester.pump(Duration.zero);
}

Future<void> _expectStagedTransitionFrames(
  WidgetTester tester,
  Finder switchFinder, {
  required Duration duration,
  required String outgoingLabel,
  required String incomingLabel,
}) async {
  final Rect startThumb = _switchThumbRect(tester, switchFinder);
  expect(_switchLabelOpacity(tester, switchFinder, outgoingLabel), 1);
  expect(_switchLabelOpacity(tester, switchFinder, incomingLabel), 0);
  _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);

  final Duration fadeFrame = _switchDurationPart(duration, 0.05);
  await tester.pump(fadeFrame);
  expect(
    _switchLabelOpacity(tester, switchFinder, outgoingLabel),
    inExclusiveRange(0, 1),
  );
  expect(_switchLabelOpacity(tester, switchFinder, incomingLabel), 0);
  expect(
    _switchThumbRect(tester, switchFinder).left,
    closeTo(startThumb.left, 0.1),
  );
  _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);

  final Duration middleFrame = _switchDurationPart(duration, 0.5);
  await tester.pump(middleFrame - fadeFrame);
  expect(_switchLabelOpacity(tester, switchFinder, outgoingLabel), 0);
  expect(_switchLabelOpacity(tester, switchFinder, incomingLabel), 0);
  expect(
    _switchThumbRect(tester, switchFinder).left,
    greaterThan(startThumb.left),
  );
  _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);

  final Duration arrivalFrame = _switchDurationPart(duration, 0.9);
  await tester.pump(arrivalFrame - middleFrame);
  expect(_switchLabelOpacity(tester, switchFinder, outgoingLabel), 0);
  expect(
    _switchLabelOpacity(tester, switchFinder, incomingLabel),
    greaterThan(0),
  );
  _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);

  await tester.pump(duration - arrivalFrame);
  expect(_switchLabelOpacity(tester, switchFinder, outgoingLabel), 0);
  expect(_switchLabelOpacity(tester, switchFinder, incomingLabel), 1);
  _expectVisibleSwitchGlyphsClearOfThumb(tester, switchFinder);
}

class _StatefulSwitchLabel extends StatefulWidget {
  const _StatefulSwitchLabel({
    required this.semanticLabel,
    required this.constraints,
    required this.created,
    required this.disposed,
    super.key,
  });

  final String semanticLabel;
  final List<double> constraints;
  final List<Object> created;
  final List<Object> disposed;

  @override
  State<_StatefulSwitchLabel> createState() => _StatefulSwitchLabelState();
}

class _StatefulSwitchLabelState extends State<_StatefulSwitchLabel> {
  final Object _identity = Object();

  @override
  void initState() {
    super.initState();
    widget.created.add(_identity);
  }

  @override
  void dispose() {
    widget.disposed.add(_identity);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      widget.constraints.add(constraints.maxWidth);
      return Semantics(
        label: widget.semanticLabel,
        child: const SizedBox(width: 32, height: 14),
      );
    },
  );
}
