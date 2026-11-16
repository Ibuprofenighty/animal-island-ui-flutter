import 'dart:ui' show Tristate, CheckedState;

import 'package:flutter/gestures.dart' show PointerDeviceKind;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Switch exposes toggled semantics, not checked radio/checkbox flags',
    (t) async {
      final semantics = t.ensureSemantics();
      var value = false;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return Scaffold(
                body: IslandSwitch(
                  label: 'Power',
                  value: value,
                  onChanged: (_) {},
                ),
              );
            },
          ),
        ),
      );
      final control = find.bySemanticsLabel('Power');
      expect(
        t.getSemantics(control).getSemanticsData().flagsCollection.isToggled,
        Tristate.isFalse,
      );
      expect(
        t.getSemantics(control).getSemanticsData().flagsCollection.isChecked,
        CheckedState.none,
      );
      update(() => value = true);
      await t.pumpAndSettle();
      expect(
        t.getSemantics(control).getSemanticsData().flagsCollection.isToggled,
        Tristate.isTrue,
      );
      semantics.dispose();
    },
  );
  testWidgets(
    'small busy spinner retains reference11px outside thumb interior',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: IslandSwitch(
                label: 'Busy',
                value: true,
                small: true,
                busy: true,
                showLabel: false,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(
        t.getSize(
          find.descendant(
            of: find.byType(IslandSwitch),
            matching: find.byType(RotationTransition),
          ),
        ),
        const Size.square(11),
      );
      expect(t.takeException(), isNull);
    },
  );

  for (final small in [false, true]) {
    testWidgets(
      'Switch ${small ? 'small' : 'regular'} endpoint geometry and easing',
      (t) async {
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetDevicePixelRatio);
        var value = false;
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: StatefulBuilder(
                  builder: (_, set) => IslandSwitch(
                    label: 'Switch',
                    value: value,
                    onChanged: (v) => set(() => value = v),
                    small: small,
                    showLabel: false,
                  ),
                ),
              ),
            ),
          ),
        );
        final track = find
            .descendant(
              of: find.byType(IslandSwitch),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.constraints?.minWidth == (small ? 38 : 52),
              ),
            )
            .first;
        final thumb = find
            .descendant(
              of: find.byType(IslandSwitch),
              matching: find.byType(AnimatedContainer),
            )
            .last;
        final bounds = t.getRect(track);
        expect(bounds.size, small ? const Size(38, 20) : const Size(52, 28));
        expect(t.getRect(thumb).left - bounds.left, small ? 3 : 4);
        expect(t.getRect(thumb).size, Size.square(small ? 14 : 21));
        await t.tap(track);
        await t.pump();
        await t.pump(const Duration(milliseconds: 125));
        final start = small ? 3.0 : 4.0, end = small ? 20.0 : 26.0;
        expect(
          t.getRect(thumb).left - bounds.left,
          closeTo(start + (end - start) * .77556, .02),
        );
        await t.pump(const Duration(milliseconds: 125));
        expect(t.getRect(thumb).left - bounds.left, end);
        expect(t.getRect(track), bounds);
      },
    );
  }
  testWidgets(
    'Switch label uses intrinsic width and busy motion is fixed600ms',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                IslandSwitch(
                  label: 'Label',
                  value: true,
                  checkedLabel: '开',
                  onChanged: (_) {},
                  showLabel: false,
                ),
                IslandSwitch(
                  label: 'Long',
                  value: true,
                  checkedLabel: 'A long label',
                  onChanged: (_) {},
                  showLabel: false,
                ),
                IslandSwitch(
                  label: 'Busy',
                  value: true,
                  busy: true,
                  onChanged: (_) {},
                  showLabel: false,
                ),
              ],
            ),
          ),
        ),
      );
      final switches = find.byType(IslandSwitch);
      Finder track(int i) => find
          .descendant(
            of: switches.at(i),
            matching: find.byWidgetPredicate(
              (w) => w is Container && w.constraints?.minWidth == 52,
            ),
          )
          .first;
      expect(t.getSize(track(0)).width, 52);
      expect(t.getSize(track(1)).width, greaterThan(100));
      final spin = find.descendant(
        of: switches.at(2),
        matching: find.byType(RotationTransition),
      );
      // Reference `.switch-loading { opacity: .7 }` dims only the track
      // decoration and thumb; the group and in-track text stay opaque.
      final opacities = t
          .widgetList<Opacity>(
            find.descendant(of: switches.at(2), matching: find.byType(Opacity)),
          )
          .map((o) => o.opacity)
          .toList();
      expect(opacities, [1, .7, .7]);
      await t.pump(const Duration(milliseconds: 300));
      expect(t.widget<RotationTransition>(spin).turns.value, closeTo(.5, .01));
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'busy/disabled requests are suppressed and reduced motion has no ticker',
    (t) async {
      var requests = 0;
      await t.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: IslandSwitch(
                label: 'Busy',
                value: true,
                busy: true,
                onChanged: (_) => requests++,
              ),
            ),
          ),
        ),
      );
      await t.tap(find.byType(IslandSwitch));
      await t.pump();
      expect(requests, 0);
      expect(t.hasRunningAnimations, isFalse);
    },
  );
  testWidgets('hover darkens the unchecked border; track eases over 250ms', (
    t,
  ) async {
    var value = false;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (_, set) => IslandSwitch(
                label: 'Hover',
                value: value,
                showLabel: false,
                onChanged: (v) => set(() => value = v),
              ),
            ),
          ),
        ),
      ),
    );
    BoxDecoration track() =>
        t
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find
                            .descendant(
                              of: find.byType(IslandSwitch),
                              matching: find.byType(AnimatedContainer),
                            )
                            .first,
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    Color borderOf(BoxDecoration d) => (d.border! as Border).top.color;
    // Reference #c4b89e deepened in hue to the 3:1 boundary.
    expect(borderOf(track()), const Color(0xff978b73));
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(t.getCenter(find.byType(IslandSwitch)));
    await t.pumpAndSettle();
    expect(borderOf(track()), IslandTokens.light.muted);
    await t.tap(find.byType(IslandSwitch));
    await t.pump();
    await t.pump(const Duration(milliseconds: 125));
    final mid = track().color!;
    expect(mid, isNot(const Color(0xff7ccc70)));
    expect(mid, isNot(const Color(0xffd4c9b4)));
    await t.pumpAndSettle();
    expect(track().color, const Color(0xff7ccc70));
    expect(borderOf(track()), IslandTokens.light.onLeaf);
  });

  testWidgets('thumb border and busy spinner keep the reference hues at 3:1', (
    t,
  ) async {
    Color thumbBorder() {
      final circle = t
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byType(IslandSwitch),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.shape == BoxShape.circle);
      return (circle.border! as Border).top.color;
    }

    Color spinner() =>
        (t
                        .widgetList<CustomPaint>(
                          find.descendant(
                            of: find.byType(IslandSwitch),
                            matching: find.byType(CustomPaint),
                          ),
                        )
                        .map((p) => p.painter)
                        .firstWhere(
                          (p) => p.runtimeType.toString() == '_SwitchRing',
                        )
                    as dynamic)
                .color
            as Color;
    for (final (value, border, ring) in [
      (false, const Color(0xff978b73), const Color(0xff716244)),
      (true, const Color(0xff579d00), const Color(0xff3d7200)),
    ]) {
      for (final busy in [false, true]) {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: IslandSwitch(
                  label: 'S',
                  value: value,
                  busy: busy,
                  showLabel: false,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        await t.pump();
        expect(thumbBorder(), border, reason: 'value $value busy $busy');
        if (busy) expect(spinner(), ring, reason: 'spinner $value');
      }
    }
    await t.pumpWidget(const SizedBox());
  });
}
