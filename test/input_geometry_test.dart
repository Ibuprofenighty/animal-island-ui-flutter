import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'explicit input sizes survive desktop density and parent text defaults',
    (t) async {
      for (final density in [VisualDensity.standard, VisualDensity.compact]) {
        for (final size in IslandSize.values) {
          await t.pumpWidget(
            MaterialApp(
              theme: IslandTheme.create().copyWith(visualDensity: density),
              home: Scaffold(
                body: DefaultTextStyle(
                  style: const TextStyle(fontSize: 32, height: 3),
                  child: SizedBox(
                    width: 300,
                    child: IslandTextField(
                      label: 'Field',
                      showLabel: false,
                      size: size,
                    ),
                  ),
                ),
              ),
            ),
          );
          final expected = switch (size) {
            IslandSize.small => 32.0,
            IslandSize.middle => 40.0,
            IslandSize.large => 48.0,
          };
          expect(
            t.getSize(find.byType(TextField)).height,
            closeTo(expected, .1),
            reason: '$size $density',
          );
        }
      }
    },
  );

  Widget host(Widget child, {Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: IslandTheme.create(brightness: brightness),
        home: Scaffold(
          body: Center(child: SizedBox(width: 300, child: child)),
        ),
      );
  BoxShadow? bar(WidgetTester t) {
    // The painted (possibly mid-transition) decoration of the outer layer.
    final box = t.widget<DecoratedBox>(
      find
          .descendant(
            of: find
                .descendant(
                  of: find.byType(IslandTextField),
                  matching: find.byType(AnimatedContainer),
                )
                .first,
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final shadow = (box.decoration as BoxDecoration).boxShadow!.single;
    return shadow.color.a == 0 ? null : shadow;
  }

  testWidgets('status fields keep a 3px status bar even without shadow', (
    t,
  ) async {
    // Reference error #c94444; warning #dba90e deepened in hue to #af8600.
    // A light Card paper keeps them although it rewrites passive ink; the
    // dark palette keeps its own status roles.
    for (final (status, color, dark) in [
      (
        IslandFieldStatus.error,
        const Color(0xffc94444),
        IslandTokens.dark.dangerText,
      ),
      (
        IslandFieldStatus.warning,
        const Color(0xffaf8600),
        IslandTokens.dark.warning,
      ),
    ]) {
      for (final shadow in [false, true]) {
        final field = IslandTextField(
          label: 'Field',
          showLabel: false,
          status: status,
          shadow: shadow,
        );
        await t.pumpWidget(host(field));
        await t.pumpAndSettle();
        expect(bar(t)!.offset, const Offset(0, 3), reason: '$status $shadow');
        expect(bar(t)!.color, color);
        await t.pumpWidget(
          host(IslandCard(pattern: IslandColorway.brown, child: field)),
        );
        await t.pumpAndSettle();
        expect(bar(t)!.color, color, reason: '$status in a brown Card');
        await t.pumpWidget(host(field, brightness: Brightness.dark));
        await t.pumpAndSettle();
        expect(bar(t)!.color, dark, reason: '$status dark');
      }
    }
    await t.pumpWidget(host(const IslandTextField(label: 'Field')));
    await t.pumpAndSettle();
    expect(bar(t), isNull);
  });

  testWidgets('shadow depth follows size and hover deepens it to 3px', (
    t,
  ) async {
    for (final (size, depth) in [
      (IslandSize.small, 2.0),
      (IslandSize.middle, 3.0),
      (IslandSize.large, 4.0),
    ]) {
      await t.pumpWidget(
        host(
          IslandTextField(
            label: 'Field',
            showLabel: false,
            shadow: true,
            size: size,
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(bar(t)!.offset.dy, depth, reason: '$size');
      expect(bar(t)!.color, const Color(0xffd4c9b4));
    }
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(t.getCenter(find.byType(TextField)));
    await t.pump();
    await t.pump(const Duration(milliseconds: 125));
    // 0.25s eased transition between the reference #d4c9b4 and #c4b89e.
    final mid = bar(t)!;
    expect(mid.color, isNot(const Color(0xffc4b89e)));
    expect(mid.color, isNot(const Color(0xffd4c9b4)));
    await t.pumpAndSettle();
    expect(bar(t)!.offset.dy, 3);
    expect(bar(t)!.color, const Color(0xffc4b89e));
  });

  testWidgets('text starts 2px inside the size padding; disabled dims', (
    t,
  ) async {
    for (final (size, padding) in [
      (IslandSize.small, 14.0),
      (IslandSize.middle, 18.0),
      (IslandSize.large, 22.0),
    ]) {
      await t.pumpWidget(
        host(IslandTextField(label: 'Field', showLabel: false, size: size)),
      );
      expect(
        t.getRect(find.byType(EditableText)).left -
            t.getRect(find.byType(TextField)).left,
        padding + 2,
        reason: '$size',
      );
    }
    await t.pumpWidget(
      host(
        const IslandTextField(label: 'Field', showLabel: false, enabled: false),
      ),
    );
    expect(
      t
          .widget<Opacity>(
            find
                .descendant(
                  of: find.byType(IslandTextField),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity,
      .6,
    );
  });
}
