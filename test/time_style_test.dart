import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

// Monday 2026-06-08 09:30, the reference Time test clock.
DateTime monday() => DateTime(2026, 6, 8, 9, 30);

Widget host(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

TextStyle textOf(WidgetTester t, String text) =>
    (t.renderObject<RenderParagraph>(find.text(text)).text as TextSpan).style!;

Color? capsuleOf(WidgetTester t, String text) => t
    .widgetList<Container>(
      find.ancestor(of: find.text(text), matching: find.byType(Container)),
    )
    .map((c) => c.decoration)
    .whereType<BoxDecoration>()
    .firstWhere((d) => d.borderRadius == BorderRadius.circular(999))
    .color;

Decoration? surfaceOf(WidgetTester t) => t
    .widget<Container>(
      find
          .descendant(
            of: find.byType(IslandTime),
            matching: find.byType(Container),
          )
          .first,
    )
    .decoration;

Finder rule() => find.descendant(
  of: find.byType(IslandTime),
  matching: find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter.runtimeType.toString() == '_GameRule',
  ),
);

const clockInk = Color(0xff010203);
const weekdayInk = Color(0xff040506);
const dateInk = Color(0xff070809);
const separatorInk = Color(0xff0a0b0c);
const capsuleFill = Color(0xff0d0e0f);
const surface = BoxDecoration(
  gradient: LinearGradient(colors: [Color(0xff102030), Color(0xff405060)]),
  borderRadius: BorderRadius.all(Radius.circular(28)),
);
const full = IslandTimeStyle(
  clockColor: clockInk,
  weekdayColor: weekdayInk,
  dateColor: dateInk,
  separatorColor: separatorInk,
  capsuleColor: capsuleFill,
  decoration: surface,
  padding: EdgeInsets.fromLTRB(36, 24, 36, 18),
  fontFamily: 'StyleFamily',
  capsuleFontSize: 15,
);

void main() {
  testWidgets('every style field applies to the card', (t) async {
    await t.pumpWidget(host(const IslandTime(now: monday, style: full)));
    await t.pumpAndSettle();
    for (final text in ['09', '30']) {
      expect(textOf(t, text).color, clockInk);
      expect(textOf(t, text).fontFamily, 'StyleFamily');
    }
    expect(textOf(t, 'MONDAY').color, weekdayInk);
    expect(textOf(t, 'MONDAY').fontSize, 15);
    expect(textOf(t, 'Jun 8').color, dateInk);
    expect(textOf(t, 'Jun 8').fontSize, 15);
    expect(textOf(t, 'Jun 8').fontFamily, 'StyleFamily');
    expect(textOf(t, '·').color, separatorInk);
    expect(capsuleOf(t, 'MONDAY'), capsuleFill);
    expect(surfaceOf(t), surface);
    final root = t.getRect(find.byType(IslandTime));
    expect(t.getRect(find.text('09')).top - root.top, 24);
    expect(t.getRect(find.text('09')).left - root.left, 36);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('every style field applies to the game HUD', (t) async {
    await t.pumpWidget(
      host(
        const IslandTime(
          now: monday,
          variant: IslandTimeVariant.game,
          style: full,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(textOf(t, '09').color, clockInk);
    expect(textOf(t, '09').fontFamily, 'StyleFamily');
    expect(textOf(t, 'Monday').color, weekdayInk);
    expect(textOf(t, 'Monday').fontSize, 15);
    expect(textOf(t, 'Jun 8').color, dateInk);
    expect(textOf(t, 'Jun 8').fontSize, 22, reason: 'month-day size fixed');
    expect(capsuleOf(t, 'Monday'), capsuleFill);
    expect(surfaceOf(t), surface);
    expect(rule(), paints..rrect(color: separatorInk));
    final root = t.getRect(find.byType(IslandTime));
    expect(t.getRect(find.text('09')).top - root.top, 24);
    expect(t.getRect(rule()).left - root.left, 36);

    await t.pumpWidget(
      host(
        const IslandTime(
          now: monday,
          variant: IslandTimeVariant.game,
          style: IslandTimeStyle(capsuleFontSize: 18),
        ),
      ),
    );
    expect(textOf(t, 'Monday').fontSize, 18);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('null fields keep the recipe of each variant', (t) async {
    const partial = IslandTimeStyle(clockColor: clockInk);
    for (final style in [null, const IslandTimeStyle(), partial]) {
      await t.pumpWidget(host(IslandTime(now: monday, style: style)));
      await t.pumpAndSettle();
      expect(
        textOf(t, '09').color,
        style == partial ? clockInk : const Color(0xff836b4e),
      );
      expect(textOf(t, 'MONDAY').color, const Color(0xff006b62));
      expect(textOf(t, 'MONDAY').fontSize, 12);
      expect(textOf(t, 'Jun 8').color, const Color(0xff736857));
      // Reference decorative `.dot` #c4b89e (aria-hidden), kept as is.
      expect(textOf(t, '·').color, const Color(0xffc4b89e));
      expect(textOf(t, '09').fontFamily, isNot('StyleFamily'));
      expect(capsuleOf(t, 'MONDAY'), const Color(0xffe6f9f6));
      final card = surfaceOf(t)! as BoxDecoration;
      expect(card.color, const Color(0xfff8f8f0));
      expect(card.borderRadius, BorderRadius.circular(20));
      expect(card.boxShadow, isNotEmpty);
      final root = t.getRect(find.byType(IslandTime));
      expect(t.getRect(find.text('09')).top - root.top, 20);

      await t.pumpWidget(
        host(
          IslandTime(
            now: monday,
            variant: IslandTimeVariant.game,
            style: style,
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(
        textOf(t, '09').color,
        style == partial ? clockInk : const Color(0xff836b4e),
      );
      expect(textOf(t, 'Monday').color, const Color(0xff836b4e));
      expect(textOf(t, 'Jun 8').color, const Color(0xff836b4e));
      expect(capsuleOf(t, 'Monday'), const Color(0xfffffbe7));
      expect(surfaceOf(t), isNull);
      expect(rule(), paints..rrect(color: const Color(0x599f927d)));
      final hud = t.getRect(find.byType(IslandTime));
      expect(t.getRect(find.text('09')).top - hud.top, 50);
    }
    await t.pumpWidget(const SizedBox());
  });

  testWidgets(
    'explicit colours survive a theme change; null fields follow it',
    (t) async {
      const style = IslandTimeStyle(dateColor: dateInk);
      for (final brightness in Brightness.values) {
        await t.pumpWidget(
          host(
            const IslandTime(
              now: monday,
              variant: IslandTimeVariant.game,
              style: style,
            ),
            brightness: brightness,
          ),
        );
        await t.pump(const Duration(milliseconds: 300));
        expect(textOf(t, 'Jun 8').color, dateInk, reason: '$brightness');
        expect(
          textOf(t, '09').color,
          brightness == Brightness.dark
              ? const Color(0xffb59c7c)
              : const Color(0xff836b4e),
          reason: '$brightness',
        );
      }
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets('the card capsule uses the reference line-height: normal', (
    t,
  ) async {
    await t.pumpWidget(host(const IslandTime(now: monday)));
    await t.pumpAndSettle();
    final capsule = find
        .ancestor(of: find.text('MONDAY'), matching: find.byType(Container))
        .first;
    final line = t.getSize(find.text('MONDAY')).height;
    // 12px at the font's own metrics (1 em in the test font), not the
    // inherited body line height; padding 4px above and below.
    expect(line, 12);
    expect(t.getSize(capsule).height, 8 + line);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('a narrow game HUD wraps the weekday capsule like a flex item', (
    t,
  ) async {
    Future<void> pump(double width) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: width,
            child: const IslandTime(
              now: monday,
              variant: IslandTimeVariant.game,
              locale: IslandTimeLocale.zhCn,
              dateFormat: 'YYYY年M月D日',
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    const date = '2026年6月8日';
    await pump(600);
    final wide = t.getSize(find.text('星期一')).height;
    final wideDate = t.getSize(find.text(date)).height;
    // Test font: the date row needs 216 + 20 + 77 = 313px and the clock
    // 212px; 250px fits the clock, so both row items shrink and wrap.
    await pump(100 + 250);
    expect(t.getSize(find.text('星期一')).height, greaterThan(wide));
    expect(t.getSize(find.text(date)).height, greaterThan(wideDate));
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('style changes no semantics', (t) async {
    final handle = t.ensureSemantics();
    for (final variant in IslandTimeVariant.values) {
      final readings = <(String, String)>[];
      for (final style in [null, full]) {
        await t.pumpWidget(
          host(
            IslandTime(
              now: monday,
              variant: variant,
              semanticLabel: '岛屿时间',
              style: style,
            ),
          ),
        );
        final node = t.getSemantics(find.byType(IslandTime));
        readings.add((node.label, node.value));
      }
      expect(readings, [
        ('岛屿时间', '09:30 Monday Jun 8'),
        ('岛屿时间', '09:30 Monday Jun 8'),
      ]);
    }
    await t.pumpWidget(const SizedBox());
    handle.dispose();
  });
}
