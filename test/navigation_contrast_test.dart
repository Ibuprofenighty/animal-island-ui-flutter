import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show host, foreground;
import 'foundation_test.dart' show contrast;

Color composite(WidgetTester t, String text, Color hostColor) {
  final layers = <Color>[];
  t.element(find.text(text)).visitAncestorElements((e) {
    if (e.widget case DecoratedBox(:final decoration)) {
      if (decoration case BoxDecoration(:final color)) {
        if (color != null) layers.add(color);
      }
    }
    return true;
  });
  var result = hostColor;
  for (final c in layers.reversed) {
    result = Color.alphaBlend(c, result);
  }
  return result;
}

void focusControl(WidgetTester t, Finder target) {
  t.element(target).visitAncestorElements((e) {
    if (e.widget case Focus(:final focusNode?)) {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
        return false;
      }
    }
    return true;
  });
}

void main() {
  testWidgets('actual Tabs frame ratios', (t) async {
    var min = 100.0;
    final failures = <String>[];
    for (final b in Brightness.values) {
      final paper = b == Brightness.dark
          ? IslandTokens.dark.paper
          : IslandTokens.light.paper;
      await t.pumpWidget(
        host(
          IslandTabs<int>.uncontrolled(
            items: const [
              IslandTab(value: 0, label: Text('First'), child: Text('Panel A')),
              IslandTab(
                value: 1,
                label: Text('Second'),
                child: Text('Panel B'),
              ),
            ],
          ),
          brightness: b,
        ),
      );
      await t.pumpAndSettle();
      for (final target in ['First', 'Second', 'First']) {
        await t.tap(find.text(target));
        await t.pump();
        for (var frame = 0; frame < 11; frame++) {
          for (final text in ['First', 'Second']) {
            final ratio = contrast(
              foreground(t, text),
              composite(t, text, paper),
            );
            if (ratio < min) min = ratio;
            if (ratio < 4.5)
              failures.add('$b $target $text frame$frame $ratio');
          }
          await t.pump(const Duration(milliseconds: 25));
        }
      }
    }
    expect(min, greaterThanOrEqualTo(4.5));
    expect(failures, isEmpty);
  });
  testWidgets('actual Pagination static and transition ratios', (t) async {
    final failures = <String>[];
    for (final b in Brightness.values) {
      final paper = b == Brightness.dark
          ? IslandTokens.dark.paper
          : IslandTokens.light.paper;
      for (final variant in IslandPaginationVariant.values) {
        await t.pumpWidget(
          host(
            IslandPagination.uncontrolled(
              key: ValueKey('$b $variant'),
              total: 200,
              variant: variant,
              showTotal: true,
              showQuickJumper: true,
            ),
            brightness: b,
          ),
        );
        await t.pumpAndSettle();
        final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        for (final target in ['1', '2']) {
          await mouse.moveTo(t.getCenter(find.text(target)));
          await t.pump();
          for (var frame = 0; frame < 7; frame++) {
            final ratio = contrast(
              foreground(t, target),
              composite(t, target, paper),
            );
            if (ratio < 4.5)
              failures.add('$b $variant hover $target frame$frame $ratio');
            await t.pump(const Duration(milliseconds: 25));
          }
        }
        await mouse.removePointer();
        for (final target in ['1', '2', '1']) {
          await t.tap(find.text(target));
          await t.pump();
          for (var frame = 0; frame < 7; frame++) {
            for (final text in [
              '1',
              '2',
              '200 items',
              'Go to',
              'page',
              '···',
            ]) {
              final ratio = contrast(
                foreground(t, text),
                composite(t, text, paper),
              );
              if (ratio < 4.5)
                failures.add('$b $variant $target $text frame$frame $ratio');
            }
            await t.pump(const Duration(milliseconds: 25));
          }
        }
      }
    }
    expect(failures, isEmpty);
  });
  testWidgets('navigation focus stays visible on selected and fixed surfaces', (
    t,
  ) async {
    final strategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = strategy);

    for (final brightness in Brightness.values) {
      await t.pumpWidget(
        host(
          IslandTabs<int>.uncontrolled(
            items: const [
              IslandTab(value: 0, label: Text('First'), child: Text('A')),
              IslandTab(value: 1, label: Text('Second'), child: Text('B')),
            ],
          ),
          brightness: brightness,
        ),
      );
      await t.pumpAndSettle();
      focusControl(t, find.text('First'));
      await t.pumpAndSettle();
      final focusedTab = find.ancestor(
        of: find.text('First'),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.foregroundDecoration is BoxDecoration &&
              (w.foregroundDecoration as BoxDecoration).border != null,
        ),
      );
      expect(focusedTab, findsOneWidget);
      final surface = t.widget<Container>(focusedTab);
      final border =
          (surface.foregroundDecoration as BoxDecoration).border! as Border;
      expect(
        contrast(
          border.top.color,
          (surface.decoration as BoxDecoration).color!,
        ),
        greaterThanOrEqualTo(3),
      );
      for (final variant in IslandPaginationVariant.values) {
        await t.pumpWidget(
          host(
            IslandPagination.uncontrolled(
              key: ValueKey('$brightness $variant'),
              total: 200,
              variant: variant,
              showQuickJumper: true,
              showSizeChanger: true,
            ),
            brightness: brightness,
          ),
        );
        await t.pumpAndSettle();
        final input = t.widget<TextField>(find.byType(TextField));
        expect(
          input.decoration!.enabledBorder!.borderSide.width,
          greaterThan(0),
        );
        expect(
          contrast(
            input.decoration!.enabledBorder!.borderSide.color,
            input.decoration!.fillColor!,
          ),
          greaterThanOrEqualTo(3),
        );
        expect(
          contrast(
            input.decoration!.focusedBorder!.borderSide.color,
            input.decoration!.fillColor!,
          ),
          greaterThanOrEqualTo(3),
        );
        await t.tap(find.text('10 / page'));
        await t.pumpAndSettle();
        final popup = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == const Color(0xffffeea0),
        );
        expect(popup, findsOneWidget);
        final selected = find.descendant(
          of: popup,
          matching: find.text('10 / page'),
        );
        focusControl(t, selected);
        await t.pumpAndSettle();
        final focused = find.ancestor(
          of: selected,
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.foregroundDecoration is BoxDecoration &&
                (w.foregroundDecoration as BoxDecoration).border != null,
          ),
        );
        expect(focused, findsOneWidget);
        final focusBorder =
            (t.widget<Container>(focused).foregroundDecoration as BoxDecoration)
                    .border!
                as Border;
        expect(
          contrast(focusBorder.top.color, const Color(0xffffeea0)),
          greaterThanOrEqualTo(3),
        );
      }
    }
  });
}
