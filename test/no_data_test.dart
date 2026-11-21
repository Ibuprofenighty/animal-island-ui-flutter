import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation_test.dart' show contrast;

const _lightPapers = [
  Color(0xffffffff),
  Color(0xfff8f8f0),
  Color(0xfffffdf7),
  Color(0xfff7f3df),
];
const _darkPapers = [Color(0xff243c33), Color(0xff172b26)];

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('zh'),
  double width = 480,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: IslandLocalizations.delegates,
  supportedLocales: IslandLocalizations.supportedLocales,
  theme: IslandTheme.create(brightness: brightness),
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

Color _ink(WidgetTester t, String text) =>
    (t.renderObject<RenderParagraph>(find.text(text)).text as TextSpan)
        .style!
        .color!;

IslandIcon _art(WidgetTester t) => t.widget<IslandIcon>(
  find.descendant(
    of: find.byType(IslandNoData),
    matching: find.byType(IslandIcon),
  ),
);

void main() {
  testWidgets('default title follows the variant; hidden parts stay hidden', (
    t,
  ) async {
    await t.pumpWidget(_host(const IslandNoData()));
    expect(find.text('暂无数据'), findsOneWidget);
    expect(_art(t).glyph, IslandGlyph.noData);
    expect(
      find.ancestor(
        of: find.byType(IslandIcon),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );

    await t.pumpWidget(
      _host(const IslandNoData(variant: IslandNoDataVariant.search)),
    );
    expect(find.text('没有找到相关结果'), findsOneWidget);
    expect(_art(t).glyph, IslandGlyph.search);

    await t.pumpWidget(
      _host(const IslandNoData(variant: IslandNoDataVariant.simple)),
    );
    expect(find.text('暂无数据'), findsOneWidget);
    expect(_art(t).glyph, IslandGlyph.noData);

    await t.pumpWidget(
      _host(
        const IslandNoData(
          showTitle: false,
          showIcon: false,
          description: Text('请更换筛选条件'),
        ),
      ),
    );
    expect(find.text('暂无数据'), findsNothing);
    expect(find.byType(IslandIcon), findsNothing);
    expect(find.text('请更换筛选条件'), findsOneWidget);

    await t.pumpWidget(
      _host(
        const IslandNoData(
          showIcon: false,
          icon: IslandIcon(IslandGlyph.folder),
          title: Text('收藏夹还是空的'),
        ),
      ),
    );
    expect(find.byType(IslandIcon), findsNothing);
    expect(find.text('收藏夹还是空的'), findsOneWidget);
    expect(find.text('暂无数据'), findsNothing);
  });

  testWidgets('English defaults', (t) async {
    await t.pumpWidget(_host(const IslandNoData(), locale: const Locale('en')));
    expect(find.text('No data'), findsOneWidget);
    await t.pumpWidget(
      _host(
        const IslandNoData(variant: IslandNoDataVariant.search),
        locale: const Locale('en'),
      ),
    );
    expect(find.text('No matching results'), findsOneWidget);
  });

  testWidgets('actions stay keyboard operable inside a host live region', (
    t,
  ) async {
    var restored = 0;
    await t.pumpWidget(
      _host(
        Semantics(
          liveRegion: true,
          label: '列表空态',
          child: IslandNoData(
            actions: [
              IslandButton(
                onPressed: () => restored++,
                child: const Text('恢复数据'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('列表空态')), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pump();
    expect(restored, 1);
  });

  testWidgets('size presets keep the reference geometry', (t) async {
    // (size, padding top, art, icon, art gap, simple art gap, title, desc,
    //  description gap, action gap)
    const cases = [
      (
        IslandSize.small,
        18.0,
        12.0,
        64.0,
        32.0,
        14.0,
        14.0,
        14.0,
        12.0,
        5.0,
        14.0,
      ),
      (
        IslandSize.middle,
        32.0,
        24.0,
        96.0,
        52.0,
        22.0,
        16.0,
        16.0,
        13.0,
        8.0,
        22.0,
      ),
      (
        IslandSize.large,
        40.0,
        24.0,
        120.0,
        64.0,
        26.0,
        26.0,
        18.0,
        14.0,
        8.0,
        22.0,
      ),
    ];
    for (final (
          size,
          top,
          side,
          art,
          icon,
          gap,
          simpleGap,
          titleSize,
          descSize,
          descGap,
          actionGap,
        )
        in cases) {
      for (final variant in IslandNoDataVariant.values) {
        await t.pumpWidget(
          _host(
            IslandNoData(
              size: size,
              variant: variant,
              description: const Text('说明'),
              actions: const [
                SizedBox(key: ValueKey('a'), width: 40, height: 20),
                SizedBox(key: ValueKey('b'), width: 40, height: 20),
              ],
            ),
          ),
        );
        final reason = '$size $variant';
        final root = t.getRect(find.byType(IslandNoData));
        expect(root.width, 480, reason: reason);
        final artRect = t.getRect(find.byType(IslandIcon));
        final side_ = variant == IslandNoDataVariant.simple ? icon : art;
        expect(artRect.size, Size.square(side_), reason: reason);
        expect(artRect.top - root.top, top, reason: reason);
        expect(artRect.center.dx, root.center.dx, reason: reason);
        final title = t.getRect(
          find.text(
            variant == IslandNoDataVariant.search ? '没有找到相关结果' : '暂无数据',
          ),
        );
        expect(
          title.top - artRect.bottom,
          closeTo(variant == IslandNoDataVariant.simple ? simpleGap : gap, .01),
          reason: reason,
        );
        expect(title.height, closeTo(titleSize * 1.5, .5), reason: reason);
        final desc = t.getRect(find.text('说明'));
        expect(desc.top - title.bottom, closeTo(descGap, .01), reason: reason);
        expect(desc.height, closeTo(descSize * 1.8, .5), reason: reason);
        final a = t.getRect(find.byKey(const ValueKey('a')));
        final b = t.getRect(find.byKey(const ValueKey('b')));
        expect(a.top - desc.bottom, closeTo(actionGap, .01), reason: reason);
        expect(b.left - a.right, 12, reason: reason);
        expect((a.left + b.right) / 2, closeTo(root.center.dx, .01));
        expect(root.bottom - a.bottom, closeTo(top, .01), reason: reason);
      }
      await t.pumpWidget(
        _host(
          IslandNoData(
            size: size,
            showIcon: false,
            title: const SizedBox(
              key: ValueKey('full'),
              width: double.infinity,
              height: 10,
            ),
          ),
        ),
      );
      final full = t.getRect(find.byKey(const ValueKey('full')));
      final box = t.getRect(find.byType(IslandNoData));
      expect(full.left - box.left, side, reason: '$size inline padding');
      expect(box.right - full.right, side, reason: '$size inline padding');
      await t.pumpWidget(
        _host(
          IslandNoData(
            size: size,
            icon: const Icon(Icons.inbox),
            title: const Text('自定义'),
          ),
        ),
      );
      expect(
        t.getSize(
          find
              .ancestor(
                of: find.byType(FittedBox).last,
                matching: find.byType(SizedBox),
              )
              .first,
        ),
        Size.square(icon),
        reason: '$size custom',
      );
      final custom = t.getRect(find.byType(Icon));
      expect(custom.size, Size.square(icon), reason: '$size custom');
      expect(
        t.getRect(find.text('自定义')).top - custom.bottom,
        closeTo(gap, .01),
        reason: '$size custom',
      );
    }
  });

  testWidgets('description wraps within 32ch and stays centred', (t) async {
    const long =
        'The quick brown fox jumps over the lazy dog, '
        'then rests by the island pier until the tide returns.';
    await t.pumpWidget(
      _host(const IslandNoData(description: Text(long)), width: 900),
    );
    final desc = t.getRect(find.text(long));
    final root = t.getRect(find.byType(IslandNoData));
    final style =
        (t.renderObject<RenderParagraph>(find.text(long)).text as TextSpan)
            .style!;
    final zero = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final ch = zero.width;
    zero.dispose();
    expect(desc.width, lessThanOrEqualTo(32 * ch));
    expect(desc.width, greaterThan(24 * ch));
    expect(desc.center.dx, closeTo(root.center.dx, .5));
    expect(desc.height, greaterThan(13 * 1.8 * 1.5));
  });

  testWidgets('wrapped title and description lines are balanced', (t) async {
    double lineWidth(String text, String of) {
      final style =
          (t.renderObject<RenderParagraph>(find.text(of)).text as TextSpan)
              .style!;
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    // Reference `text-wrap: balance`: eight 4-letter words pass the 32ch
    // limit. Greedy lines would be 6 + 2 words; the balanced box is the
    // narrowest that still takes two lines, 4 + 4 words.
    final words = List.filled(8, 'aaaa').join(' ');
    await t.pumpWidget(
      _host(IslandNoData(description: Text(words)), width: 900),
    );
    final root = t.getRect(find.byType(IslandNoData));
    final desc = t.getRect(find.text(words));
    final half = lineWidth(List.filled(4, 'aaaa').join(' '), words);
    expect(lineWidth(words, words), greaterThan(32 * lineWidth('0', words)));
    expect(desc.width, inInclusiveRange(half, half + 1));
    expect(desc.center.dx, closeTo(root.center.dx, .5));
    final single = t.getSize(find.text(words)).height;

    // One line keeps its own width and half the height.
    await t.pumpWidget(
      _host(
        const IslandNoData(
          title: SizedBox(
            key: ValueKey('bar'),
            width: double.infinity,
            height: 4,
          ),
          description: Text('aaaa'),
        ),
        width: 900,
      ),
    );
    expect(t.getSize(find.text('aaaa')).width, lineWidth('aaaa', 'aaaa'));
    expect(t.getSize(find.text('aaaa')).height, single / 2);
    // A box that does not wrap keeps the content width.
    expect(
      t.getSize(find.byKey(const ValueKey('bar'))).width,
      t.getSize(find.byType(IslandNoData)).width - 48,
    );

    // The title balances inside the content width (150 - 2 * 24): three
    // words do not fit on one line, two do.
    await t.pumpWidget(
      _host(const IslandNoData(title: Text('aa aa aa aa')), width: 150),
    );
    final title = t.getRect(find.text('aa aa aa aa'));
    final pair = lineWidth('aa aa', 'aa aa aa aa');
    expect(lineWidth('aa aa aa', 'aa aa aa aa'), greaterThan(150 - 48));
    expect(title.width, inInclusiveRange(pair, pair + 1));
    expect(title.height, 2 * 24);
    expect(t.takeException(), isNull);
  });

  testWidgets('a custom icon follows the title ink; built-in art keeps its '
      'native ink', (t) async {
    await t.pumpWidget(
      _host(
        const IslandNoData(
          icon: IslandIcon(IslandGlyph.folder),
          title: Text('收藏夹还是空的'),
        ),
      ),
    );
    final folder = t.element(find.byType(IslandIcon));
    expect(IconTheme.of(folder).color, _ink(t, '收藏夹还是空的'));
    for (final brightness in Brightness.values) {
      await t.pumpWidget(
        _host(
          const IslandNoData(variant: IslandNoDataVariant.search),
          brightness: brightness,
        ),
      );
      expect(_art(t).color, const Color(0xff2a2a2a), reason: '$brightness');
    }
  });

  testWidgets('reference light recipe and readable theme roles', (t) async {
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      _host(const IslandNoData(description: Text('说明'), bordered: true)),
    );
    expect(_ink(t, '暂无数据'), const Color(0xff794f27));
    // #9f927d (2.7–3.1:1) deepened in its own OKLCH hue to 4.5:1.
    expect(_ink(t, '说明'), const Color(0xff7a6d59));
    for (final paper in _lightPapers) {
      expect(contrast(_ink(t, '暂无数据'), paper), greaterThanOrEqualTo(4.5));
      expect(contrast(_ink(t, '说明'), paper), greaterThanOrEqualTo(4.5));
    }
    final surface = t
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(IslandNoData),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((d) => d.decoration)
        .whereType<ShapeDecoration>()
        .single;
    expect(surface.color, const Color(0xfff8f8f0));
    expect(
      (surface.shape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(20),
    );
    final outline = t
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(IslandNoData),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((p) => p.foregroundPainter)
        .whereType<IslandDashedBorderPainter>()
        .single;
    expect(outline.color, const Color(0xffe8e2d6));
    expect(outline.strokeWidth, 1.5);

    await t.pumpWidget(
      _host(
        const IslandNoData(description: Text('说明'), bordered: true),
        brightness: Brightness.dark,
      ),
    );
    await t.pumpAndSettle();
    final title = _ink(t, '暂无数据'), desc = _ink(t, '说明');
    expect(title, IslandTokens.dark.ink);
    expect(desc, IslandTokens.dark.muted);
    for (final paper in [..._darkPapers, IslandTokens.dark.paper]) {
      expect(contrast(title, paper), greaterThanOrEqualTo(4.5));
      expect(contrast(desc, paper), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('Table empty slot hosts NoData as a block', (t) async {
    await t.pumpWidget(
      _host(
        IslandTable<String>(
          columns: [
            IslandTableColumn<String>(
              id: 'name',
              title: const Text('Name'),
              cellBuilder: (_, record, _) => Text(record),
            ),
          ],
          rows: const [],
          rowKey: (record) => record,
          empty: const IslandNoData(size: IslandSize.small),
        ),
      ),
    );
    expect(find.text('暂无数据'), findsOneWidget);
    final table = t.getRect(find.byType(IslandTable<String>));
    final empty = t.getRect(find.byType(IslandNoData));
    expect(empty.width, greaterThan(table.width - 60));
    expect(t.takeException(), isNull);
  });
}
