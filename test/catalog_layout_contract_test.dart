import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'counter_audit_test.dart' show pixel;
import 'foundation_test.dart' show contrast;

void main() {
  testWidgets(
    'Progress info inherits16px while explicit opaque styles remain authoritative',
    (t) async {
      for (final explicit in [false, true]) {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: IslandProgress(
                percent: 72,
                label: 'experience',
                infoBuilder: (_) => Text(
                  'stars',
                  key: const ValueKey('opaque-info'),
                  style: explicit
                      ? const TextStyle(fontSize: 24, letterSpacing: 1)
                      : null,
                ),
              ),
            ),
          ),
        );
        final text = find.byKey(const ValueKey('opaque-info'));
        final paragraph = find.descendant(
          of: text,
          matching: find.byType(RichText),
        );
        final span = t.widget<RichText>(paragraph).text as TextSpan;
        expect(span.style?.fontSize, explicit ? 24 : 16);
        expect(span.style?.letterSpacing, explicit ? 1 : .32);
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets('CodeBlock explicit content padding controls real owned layout', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IslandCodeBlock(
            code: 'value',
            copyable: false,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          ),
        ),
      ),
    );
    final block = find.byType(IslandCodeBlock);
    final text = find.descendant(
      of: block,
      matching: find.byType(SelectableText),
    );
    expect(t.getTopLeft(text).dx - t.getTopLeft(block).dx, 29);
    expect(t.getTopLeft(text).dy - t.getTopLeft(block).dy, 21);
    expect(t.takeException(), isNull);
  });
  testWidgets('Divider repeats complete cycles and omits a final connector', (
    t,
  ) async {
    for (final width in [293.0, 320.0, 31.0, 15.0]) {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: IslandDivider(
                iconBuilder: (_) =>
                    const ColoredBox(key: ValueKey('glyph'), color: Colors.red),
              ),
            ),
          ),
        ),
      );
      final count = (width / 32).floor().clamp(1, 100);
      final glyphs = find.byKey(const ValueKey('glyph'));
      expect(glyphs, findsNWidgets(count));
      final connectors = find.byWidgetPredicate(
        (w) => w is Container && w.color == const Color(0xffc4b89e),
      );
      expect(connectors, findsNWidgets(count - 1));
      expect(t.getSize(glyphs.first), const Size(24, 24));
      if (count > 1)
        expect(
          t.getTopLeft(glyphs.last).dx - t.getTopLeft(glyphs.first).dx,
          (count - 1) * 32,
        );
      expect(t.takeException(), isNull);
    }
  });
  testWidgets(
    'Tabs shrink opaque label slots without scrolling or remounting',
    (t) async {
      var width = 259.0, mounts = 0;
      late StateSetter update;
      for (final direction in TextDirection.values) {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Directionality(
                textDirection: direction,
                child: StatefulBuilder(
                  builder: (_, set) {
                    update = set;
                    return SizedBox(
                      width: width,
                      child: IslandTabs.uncontrolled(
                        items: [
                          IslandTab(
                            value: 'a',
                            label: _LabelProbe(
                              key: const ValueKey('island'),
                              onMount: () => mounts++,
                              text: 'A A A',
                            ),
                            child: const Text('Panel'),
                          ),
                          const IslandTab(
                            value: 'b',
                            label: Text('B B'),
                            child: Text('Shop'),
                          ),
                          const IslandTab(
                            value: 'c',
                            label: Text('C C C'),
                            child: Text('Service'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final rect = t.getRect(find.byType(IslandTabs<String>));
        for (final text in ['A A A', 'B B', 'C C C']) {
          final label = t.getRect(find.text(text));
          expect(label.left, greaterThanOrEqualTo(rect.left));
          expect(label.right, lessThanOrEqualTo(rect.right));
        }
        final original = t.state(find.byType(_LabelProbe));
        final before = mounts;
        update(() => width = 500);
        await t.pumpAndSettle();
        expect(t.state(find.byType(_LabelProbe)), same(original));
        expect(mounts, before);
        update(() => width = 259);
        await t.pumpAndSettle();
        expect(t.state(find.byType(_LabelProbe)), same(original));
        expect(t.widget<Text>(find.text('A A A')).style!.color, Colors.purple);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox.shrink());
      }
    },
  );
  testWidgets('Pagination keeps every action within narrow aligned runs', (
    t,
  ) async {
    for (final alignment in [
      AlignmentDirectional.centerStart,
      AlignmentDirectional.centerEnd,
    ]) {
      await t.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: IslandLocalizations.delegates,
          supportedLocales: IslandLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 180,
              child: IslandPagination(
                total: 30,
                value: const IslandPaginationValue(page: 1, pageSize: 5),
                onChanged: (_) {},
                showTotal: true,
                showSizeChanger: true,
                alignment: alignment,
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final parent = t.getRect(find.byType(IslandPagination));
      final label = t.getRect(
        find.byWidgetPredicate(
          (w) => w is Text && (w.data?.contains('条/') ?? false),
        ),
      );
      expect(label.left, greaterThanOrEqualTo(parent.left));
      expect(label.right, lessThanOrEqualTo(parent.right));
      final actions = find.descendant(
        of: find.byType(IslandPagination),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.button == true,
        ),
      );
      for (final action in actions.evaluate()) {
        final rect = t.getRect(find.byWidget(action.widget));
        expect(rect.left, greaterThanOrEqualTo(parent.left));
        expect(rect.right, lessThanOrEqualTo(parent.right));
        expect(rect.top, greaterThanOrEqualTo(parent.top));
        expect(rect.bottom, lessThanOrEqualTo(parent.bottom));
      }
      expect(t.takeException(), isNull);
    }
  });
  testWidgets(
    'Packaged CodeBlock font is truly monospace and caller style wins',
    (t) async {
      final loader = FontLoader(IslandTheme.codeFontFamily);
      loader.addFont(
        rootBundle.load(
          'packages/animal_island_ui/assets/fonts/FiraCode-Variable.ttf',
        ),
      );
      await loader.load();
      await t.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: const IslandCodeBlock(code: 'iiii WWWW 0000'),
          ),
        ),
      );
      await t.pumpAndSettle();
      final style = t
          .widget<SelectableText>(find.byType(SelectableText))
          .style!;
      expect(style.fontFamily, IslandTheme.codeFontFamily);
      expect(style.letterSpacing, 0);
      final widths = <double>[];
      for (final word in ['iiii', 'WWWW', '0000']) {
        final painter = TextPainter(
          text: TextSpan(text: word, style: style),
          textDirection: TextDirection.ltr,
        )..layout();
        widths.add(painter.width);
        painter.dispose();
      }
      expect(widths[0], closeTo(widths[1], .001));
      expect(widths[1], closeTo(widths[2], .001));
      const explicit = TextStyle(
        fontFamily: 'CustomCode',
        fontSize: 21,
        fontWeight: FontWeight.w400,
        letterSpacing: 2,
      );
      await t.pumpWidget(
        const MaterialApp(
          home: const Scaffold(
            body: const IslandCodeBlock(
              code: 'source',
              style: IslandCodeBlockStyle(textStyle: explicit),
            ),
          ),
        ),
      );
      final chosen = t
          .widget<SelectableText>(find.byType(SelectableText))
          .style!;
      expect(chosen.fontFamily, 'CustomCode');
      expect(chosen.fontSize, 21);
      expect(chosen.fontWeight, FontWeight.w400);
      expect(chosen.letterSpacing, 2);
    },
  );
  testWidgets(
    'Off slashes remain distinct over their own opaque cream backing',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final sample in [
          (IslandGlyph.eyeOff, const Offset(19, 19), const Offset(14, 24)),
          (IslandGlyph.bellOff, const Offset(24, 25), const Offset(17, 25)),
        ]) {
          final key = GlobalKey();
          await t.pumpWidget(
            MaterialApp(
              theme: IslandTheme.create(brightness: brightness),
              home: Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: key,
                    child: IslandIcon(sample.$1, size: 48),
                  ),
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          final origin = t.getTopLeft(find.byType(IslandIcon));
          final ink = await pixel(t, key, origin + sample.$2),
              backing = await pixel(t, key, origin + sample.$3);
          expect(
            backing,
            const Color(0xfffaedcd),
            reason: '${sample.$1.name} $brightness opaque slash backing',
          );
          expect(
            contrast(ink, backing),
            greaterThanOrEqualTo(3),
            reason: '${sample.$1.name} $brightness $ink/$backing',
          );
        }
      }
    },
  );
  testWidgets(
    'Four filled glyph semantic cores meet3 against their actual backing',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final sample in [
          (IslandGlyph.pause, const Offset(19, 24), const Offset(24, 12)),
          (IslandGlyph.play, const Offset(25, 24), const Offset(24, 12)),
          (IslandGlyph.stop, const Offset(24, 24), const Offset(24, 12)),
          (IslandGlyph.ban, const Offset(24, 24), const Offset(17, 20)),
        ]) {
          final key = GlobalKey();
          await t.pumpWidget(
            MaterialApp(
              theme: IslandTheme.create(brightness: brightness),
              home: Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: key,
                    child: IslandIcon(sample.$1, size: 48),
                  ),
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          final origin = t.getTopLeft(find.byType(IslandIcon));
          final ink = await pixel(t, key, origin + sample.$2),
              backing = await pixel(t, key, origin + sample.$3);
          expect(
            contrast(ink, backing),
            greaterThanOrEqualTo(3),
            reason: '${sample.$1.name} $brightness $ink/$backing',
          );
        }
      }
    },
  );
}

class _LabelProbe extends StatefulWidget {
  const _LabelProbe({super.key, required this.onMount, required this.text});
  final VoidCallback onMount;
  final String text;
  @override
  State<_LabelProbe> createState() => _LabelProbeState();
}

class _LabelProbeState extends State<_LabelProbe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) =>
      Text(widget.text, style: const TextStyle(color: Colors.purple));
}
