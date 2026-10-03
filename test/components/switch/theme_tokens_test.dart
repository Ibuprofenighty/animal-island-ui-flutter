import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('N15 Switch track renders a theme-derived inset edge', (
    tester,
  ) async {
    final AnimalIslandTheme insetProbeTheme = AnimalIslandTheme.light.copyWith(
      shadows: AnimalIslandTheme.light.shadows.copyWith(
        softElevation: const BoxShadow(
          color: Color(0xFF0022FF),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ),
    );
    for (final AnimalIslandTheme theme in <AnimalIslandTheme>[
      ...animalIslandThemeVariants(),
      insetProbeTheme,
    ]) {
      final GlobalKey boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          key: ObjectKey(theme),
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: theme.toThemeData(),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundaryKey,
                child: const AnimalSwitch(
                  value: false,
                  onChanged: _ignoreSwitchProposal,
                ),
              ),
            ),
          ),
        ),
      );
      final Finder track = find
          .descendant(
            of: find.byType(AnimalSwitch),
            matching: find.byType(AnimatedContainer),
          )
          .last;
      final Rect trackRect = tester.getRect(track);
      final Rect boundaryRect = tester.getRect(find.byKey(boundaryKey));
      final RenderRepaintBoundary boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final ui.Image image = (await tester.runAsync(
        () => boundary.toImage(pixelRatio: 1),
      ))!;
      try {
        final ByteData pixels = (await tester.runAsync<ByteData>(() async {
          return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        }))!;
        Color pixelAt(int x, int y) {
          final int offset = (y * image.width + x) * 4;
          return Color.fromARGB(
            pixels.getUint8(offset + 3),
            pixels.getUint8(offset),
            pixels.getUint8(offset + 1),
            pixels.getUint8(offset + 2),
          );
        }

        // The unchecked thumb sits at logical start; sample the free capsule
        // end at its round-cap center, 1dp inside the 1.5dp border.
        final int sampleX =
            (trackRect.right - trackRect.height / 2 - boundaryRect.left)
                .round();
        final int edgeY = (trackRect.top + 2 - boundaryRect.top).round();
        final int centerY = (trackRect.center.dy - boundaryRect.top).round();
        final Color edgePixel = pixelAt(sampleX, edgeY);
        final Color centerPixel = pixelAt(sampleX, centerY);
        expect(
          edgePixel.computeLuminance(),
          lessThan(centerPixel.computeLuminance()),
          reason:
              '${theme.colors.brightness.name} track must show an inner edge '
              'inside its border, away from the thumb and label area.',
        );
        if (identical(theme, insetProbeTheme)) {
          expect(edgePixel.b, greaterThan(centerPixel.b));
          expect(edgePixel.r, lessThan(centerPixel.r));
          expect(centerPixel, theme.colors.bgSecondary);
        }
        expect(tester.takeException(), isNull);
      } finally {
        image.dispose();
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('N15 track color and inset decoration interpolate together', (
    tester,
  ) async {
    for (final AnimalIslandTheme theme in animalIslandThemeVariants()) {
      bool value = false;
      StateSetter? rebuild;
      await tester.pumpWidget(
        MaterialApp(
          key: ObjectKey(theme),
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: theme.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuild = setState;
                return AnimalSwitch(
                  value: value,
                  onChanged: (bool next) => setState(() => value = next),
                );
              },
            ),
          ),
        ),
      );

      Finder trackDecorationFinder() => find.descendant(
        of: find.byType(AnimalSwitch),
        matching: find.byWidgetPredicate((Widget widget) {
          return widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).padding ==
                  const EdgeInsets.all(1.5);
        }),
      );

      BoxDecoration decoration() =>
          tester.widget<DecoratedBox>(trackDecorationFinder().last).decoration
              as BoxDecoration;

      expect(decoration().color, theme.colors.bgSecondary);
      expect(decoration().padding, const EdgeInsets.all(1.5));
      rebuild!(() => value = true);
      await tester.pump();
      await tester.pump(
        Duration(microseconds: theme.motion.normal.inMicroseconds ~/ 2),
      );
      expect(decoration().color, isNot(theme.colors.bgSecondary));
      expect(decoration().color, isNot(theme.colors.success));
      expect(decoration().padding, const EdgeInsets.all(1.5));
      await tester.pumpAndSettle();
      expect(decoration().color, theme.colors.success);
      expect(decoration().padding, const EdgeInsets.all(1.5));
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('checked switch uses success, themed label and motion', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimalSwitch(
                  key: const ValueKey('checked'),
                  value: true,
                  onChanged: (_) {},
                  checkedChildren: const Text('ON'),
                  focusNode: focusNode,
                ),
                AnimalSwitch(
                  key: const ValueKey('unchecked'),
                  value: false,
                  onChanged: (_) {},
                  unCheckedChildren: const Text('OFF'),
                ),
                const AnimalSwitch(
                  key: ValueKey('disabled'),
                  value: false,
                  onChanged: null,
                  disabled: true,
                  unCheckedChildren: Text('DISABLED'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      AnimatedContainer track(String name) => tester
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byKey(ValueKey<String>(name)),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is AnimatedContainer &&
                    widget.decoration is BoxDecoration &&
                    ((widget.decoration! as BoxDecoration).border != null),
              ),
            ),
          )
          .single;

      final checkedTrack = track('checked');
      expect(
        (checkedTrack.decoration! as BoxDecoration).color,
        theme.colors.success,
      );
      expect(
        (checkedTrack.decoration! as BoxDecoration).padding,
        const EdgeInsets.all(1.5),
      );
      expect(
        ((checkedTrack.decoration! as BoxDecoration).border!.top.color),
        theme.colors.success,
      );
      expect(checkedTrack.duration, theme.motion.normal);
      expect(checkedTrack.curve, theme.motion.ease);
      final Align checkedThumbAlignment = tester.widget<Align>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('checked')),
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is Align &&
                widget.alignment == AlignmentDirectional.centerEnd,
          ),
        ),
      );
      expect(checkedThumbAlignment.alignment, AlignmentDirectional.centerEnd);
      final checkedThumb = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('checked')),
              matching: find.byType(Container),
            ),
          )
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).shape ==
                    BoxShape.circle,
          );
      expect(
        (checkedThumb.decoration! as BoxDecoration).color,
        theme.colors.bgContent,
      );
      expect((checkedThumb.decoration! as BoxDecoration).boxShadow, isEmpty);
      final checkedStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('ON'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(checkedStyle.color, theme.colors.onSuccess);
      expect(checkedStyle.fontFamily, theme.typography.fontFamily);
      expect(
        checkedStyle.fontFamilyFallback,
        theme.typography.fontFamilyFallback,
      );
      expect(checkedStyle.letterSpacing, theme.typography.body.letterSpacing);
      expect(
        themeContrastRatio(checkedStyle.color!, theme.colors.success),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} checked switch text pair',
      );

      final uncheckedTrack = track('unchecked');
      expect(
        (uncheckedTrack.decoration! as BoxDecoration).color,
        theme.colors.bgSecondary,
      );
      final inactiveBorder = theme.colors.brightness == Brightness.dark
          ? theme.colors.border
          : theme.colors.borderLight;
      expect(
        (uncheckedTrack.decoration! as BoxDecoration).border!.top.color,
        inactiveBorder,
      );
      final uncheckedStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('OFF'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(uncheckedStyle.color, theme.colors.textSecondary);
      expect(uncheckedStyle.fontFamily, theme.typography.fontFamily);
      expect(
        uncheckedStyle.fontFamilyFallback,
        theme.typography.fontFamilyFallback,
      );
      expect(
        themeContrastRatio(uncheckedStyle.color!, theme.colors.bgSecondary),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} unchecked switch text pair',
      );

      final disabledTrack = track('disabled');
      final disabledTrackColor = theme.colors.brightness == Brightness.dark
          ? theme.colors.surfaceAlt
          : theme.colors.bgDisabled;
      expect(
        (disabledTrack.decoration! as BoxDecoration).color,
        disabledTrackColor,
      );
      expect(
        (disabledTrack.decoration! as BoxDecoration).border!.top.color,
        inactiveBorder,
      );
      final disabledSemantics = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('disabled')),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere((semantics) => semantics.properties.enabled == false);
      expect(disabledSemantics.properties.enabled, isFalse);
      final disabledStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('DISABLED'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(disabledStyle.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(disabledStyle.color!, disabledTrackColor),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled switch label pair',
      );
      final disabledThumb = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('disabled')),
              matching: find.byType(Container),
            ),
          )
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).shape ==
                    BoxShape.circle,
          );
      expect(
        (disabledThumb.decoration! as BoxDecoration).color,
        theme.colors.surfaceHeader,
      );
      expect((disabledThumb.decoration! as BoxDecoration).boxShadow, isEmpty);

      final focusShell = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('checked')),
              matching: find.byType(Container),
            ),
          )
          .firstWhere(
            (container) =>
                container.foregroundDecoration is BoxDecoration &&
                (container.foregroundDecoration! as BoxDecoration)
                        .border
                        ?.top
                        .color ==
                    theme.colors.focusYellow,
          );
      expect(
        (focusShell.foregroundDecoration! as BoxDecoration).border!.top.color,
        theme.colors.focusYellow,
      );
      expect(
        themeContrastRatio(theme.colors.focusYellow, theme.colors.bgSecondary),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} switch focus outline pair',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      focusNode.dispose();
    }
  });
}

void _ignoreSwitchProposal(bool value) {}
