import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation_test.dart' show contrast;
import 'palette_contrast_test.dart' show foreground, readable;

const _ink = Color(0xff173a27);
const _dark = Color(0xff243c33);
const _code = "// note\nfinal value = Kind('text', 12); go();\nflutter pub get";
const _lightSyntax = <IslandCodeToken, Color>{
  IslandCodeToken.comment: Color(0xff555555),
  IslandCodeToken.literal: Color(0xff226622),
  IslandCodeToken.command: Color(0xff714821),
  IslandCodeToken.keyword: Color(0xff6a1b9a),
  IslandCodeToken.type: Color(0xff005f75),
  IslandCodeToken.function: Color(0xff0044aa),
  IslandCodeToken.punctuation: Color(0xff614e3d),
};
const _lightCode = IslandCodeBlockStyle(
  backgroundColor: Colors.white,
  foregroundColor: _ink,
  borderColor: _ink,
  syntaxColors: _lightSyntax,
  copyForegroundColor: WidgetStatePropertyAll(_ink),
  copyBackgroundColor: WidgetStatePropertyAll(Color(0xffe8f5e9)),
  copyBorderColor: WidgetStatePropertyAll(_ink),
);

Widget _host(
  Widget child, {
  Brightness brightness = Brightness.light,
  List<ThemeExtension<dynamic>> extensions = const [],
  Color backing = Colors.white,
  GlobalKey? boundary,
}) => RepaintBoundary(
  key: boundary,
  child: MaterialApp(
    theme: IslandTheme.create(brightness: brightness, fontFamily: 'P1Nunito')
        .copyWith(
          extensions: [
            brightness == Brightness.light
                ? IslandTokens.light
                : IslandTokens.dark,
            ...extensions,
          ],
        ),
    home: Scaffold(
      backgroundColor: backing,
      body: Center(child: SizedBox(width: 600, child: child)),
    ),
  ),
);

List<(String, Color)> _leaves(WidgetTester t) {
  final result = <(String, Color)>[];
  void inspect(InlineSpan span, TextStyle parent) {
    final style = parent.merge(span.style);
    if (span is TextSpan) {
      if (span.text?.trim().isNotEmpty ?? false)
        result.add((span.text!, style.foreground?.color ?? style.color!));
      for (final child in span.children ?? <InlineSpan>[])
        inspect(child, style);
    }
  }

  inspect(
    t.state<EditableTextState>(find.byType(EditableText)).renderEditable.text!,
    const TextStyle(),
  );
  return result;
}

BoxDecoration _copyDecoration(WidgetTester t) => t
    .widgetList<DecoratedBox>(
      find.ancestor(
        of: find.text('复制').evaluate().isNotEmpty
            ? find.text('复制')
            : find.text('复制失败'),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((w) => w.decoration)
    .whereType<BoxDecoration>()
    .first;

Future<(Color, Map<String, Object?>)> _sample(
  WidgetTester t,
  GlobalKey key,
  Offset point,
  String name, {
  Map<String, Object?> details = const {},
}) async {
  final result = await t.runAsync(() async {
    final render =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final origin = render.localToGlobal(Offset.zero);
    final local = point - origin;
    final image = await render.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final p = (local.dy.floor() * image.width + local.dx.floor()) * 4;
    final color = Color.fromARGB(
      bytes.getUint8(p + 3),
      bytes.getUint8(p),
      bytes.getUint8(p + 1),
      bytes.getUint8(p + 2),
    );
    final data = <String, Object?>{
      'sample': [local.dx, local.dy],
      'pixel': color.toARGB32().toRadixString(16),
      'dimensions': [image.width, image.height],
      'render_dpr': 1,
      'scope':
          'Widget renderer diagnostic, not physical Windows/Web presentation',
      ...details,
    };
    final out = Platform.environment['COLOR_API_EVIDENCE_OUT'];
    if (out != null) {
      await File('$out/$name.json').writeAsString(jsonEncode(data));
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await File('$out/$name.png').writeAsBytes(png.buffer.asUint8List());
    }
    image.dispose();
    return (color, data);
  });
  return result!;
}

void main() {
  setUpAll(() async {
    final mono = FontLoader(IslandTheme.codeFontFamily)
      ..addFont(
        rootBundle.load(
          'packages/animal_island_ui/assets/fonts/FiraCode-Variable.ttf',
        ),
      );
    await mono.load();
    final nunito = FontLoader('P1Nunito');
    for (final weight in [500, 700, 900]) {
      nunito.addFont(
        File('example/assets/fonts/nunito-latin-$weight-normal.ttf')
            .readAsBytes()
            .then((b) => ByteData.sublistView(b)),
      );
    }
    await nunito.load();
  });
  setUp(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional,
  );
  tearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );

  testWidgets(
    'CodeBlock highlighted roles resolve per token while source and typography survive',
    (t) async {
      final key = GlobalKey();
      for (final mode in Brightness.values) {
        for (final language in IslandCodeLanguage.values) {
          await t.pumpWidget(
            _host(
              IslandCodeBlock(
                code: _code,
                language: language,
                style: const IslandCodeBlockStyle(
                  syntaxColors: {IslandCodeToken.comment: Color(0xff006b62)},
                  textStyle: TextStyle(fontSize: 17, color: Colors.red),
                ),
              ),
              brightness: mode,
              boundary: key,
              extensions: [const IslandCodeBlockTheme(style: _lightCode)],
            ),
          );
          await t.pumpAndSettle();
          final editable = t
              .state<EditableTextState>(find.byType(EditableText))
              .renderEditable;
          expect(editable.text!.toPlainText(), _code);
          final leaves = _leaves(t);
          expect(leaves, isNotEmpty);
          final pixel = await _sample(
            t,
            key,
            Offset(
              t.getRect(find.byType(IslandCodeBlock)).center.dx,
              t.getRect(find.byType(IslandCodeBlock)).top + 3,
            ),
            'p1-code-${mode.name}-${language.name}',
            details: {
              'rows': [
                for (final leaf in leaves)
                  {
                    'text': leaf.$1,
                    'foreground': leaf.$2.toARGB32().toRadixString(16),
                    'ratio_on_white': contrast(leaf.$2, Colors.white),
                  },
              ],
            },
          );
          expect(pixel.$1, Colors.white);
          for (final leaf in leaves) {
            readable(leaf.$2, pixel.$1);
          }
          if (language != IslandCodeLanguage.plain) {
            Color token(String text) =>
                leaves.firstWhere((x) => x.$1 == text).$2;
            expect(token('// note'), const Color(0xff006b62));
            expect(token('final'), _lightSyntax[IslandCodeToken.keyword]);
            expect(token('Kind'), _lightSyntax[IslandCodeToken.type]);
            expect(token('go'), _lightSyntax[IslandCodeToken.function]);
            expect(token('value'), _ink);
            if (language == IslandCodeLanguage.shell)
              expect(token('flutter'), _lightSyntax[IslandCodeToken.command]);
          }
          final text = t.widget<SelectableText>(find.byType(SelectableText));
          expect(text.style!.fontSize, 17);
          expect(text.style!.color, _ink);
        }
      }
    },
  );

  testWidgets(
    'CodeBlock explicit transparent surface and canonical foreground do not become null fallbacks',
    (t) async {
      final key = GlobalKey();
      await t.pumpWidget(
        _host(
          const IslandCodeBlock(
            code: 'passive',
            language: IslandCodeLanguage.plain,
            style: IslandCodeBlockStyle(
              backgroundColor: Colors.transparent,
              foregroundColor: _ink,
              textStyle: TextStyle(
                color: Colors.red,
                fontSize: 21,
                letterSpacing: 2,
              ),
            ),
          ),
          backing: const Color(0xffe8f5e9),
          boundary: key,
          extensions: [const IslandCodeBlockTheme(style: _lightCode)],
        ),
      );
      await t.pumpAndSettle();
      final rect = t.getRect(find.byType(IslandCodeBlock));
      final bg = (await _sample(
        t,
        key,
        Offset(rect.center.dx, rect.top + 3),
        'p1-code-transparent',
      )).$1;
      expect(bg, const Color(0xffe8f5e9));
      expect(_leaves(t).single.$2, _ink);
      readable(_ink, bg);
      expect(
        t
            .widget<SelectableText>(find.byType(SelectableText))
            .style!
            .letterSpacing,
        2,
      );
    },
  );

  testWidgets(
    'CodeBlock copy partial state values fall back and error coexists with focus',
    (t) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData')
              throw PlatformException(code: 'test-copy-error');
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final observed = <Set<WidgetState>>[];
      final key = GlobalKey();
      final theme = IslandCodeBlockTheme(
        style: IslandCodeBlockStyle(
          backgroundColor: Colors.white,
          foregroundColor: _ink,
          syntaxColors: _lightSyntax,
          copyForegroundColor: WidgetStateProperty.resolveWith((states) {
            observed.add(Set.of(states));
            return states.contains(WidgetState.error)
                ? const Color(0xff8b1e36)
                : _ink;
          }),
          copyBackgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.hovered)
                ? const Color(0xffe8f5e9)
                : Colors.white,
          ),
          copyBorderColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.focused)
                ? const Color(0xff006b62)
                : _ink,
          ),
        ),
      );
      await t.pumpWidget(
        _host(
          IslandCodeBlock(
            code: _code,
            style: IslandCodeBlockStyle(
              copyBackgroundColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.pressed) ? Colors.white : null,
              ),
            ),
          ),
          boundary: key,
          extensions: [theme],
        ),
      );
      await t.pumpAndSettle();
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(find.text('复制')));
      await t.pump();
      expect(_copyDecoration(t).color, const Color(0xffe8f5e9));
      await mouse.down(t.getCenter(find.text('复制')));
      await t.pump();
      expect(_copyDecoration(t).color, Colors.white);
      await mouse.up();
      await t.pumpAndSettle();
      expect(find.text('复制失败'), findsOneWidget);
      expect(
        observed.any(
          (s) =>
              s.contains(WidgetState.error) && s.contains(WidgetState.focused),
        ),
        isTrue,
      );
      final dec = _copyDecoration(t);
      expect((dec.border! as Border).top.color, const Color(0xff006b62));
      expect(foreground(t, '复制失败'), const Color(0xff8b1e36));
      readable(foreground(t, '复制失败'), dec.color!);
      readable((dec.border! as Border).top.color, Colors.white, minimum: 3);
      final rect = t.getRect(find.byType(IslandCodeBlock));
      await _sample(
        t,
        key,
        Offset(rect.center.dx, rect.top + 3),
        'p1-code-copy-error-focus',
        details: {
          'observed_states': [
            for (final s in observed) s.map((v) => v.name).toList(),
          ],
          'copy_foreground': foreground(t, '复制失败').toARGB32().toRadixString(16),
          'copy_background': dec.color!.toARGB32().toRadixString(16),
        },
      );
      await mouse.removePointer();
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'CodeBlock complete theme recipes remain paired during reversal and interruption',
    (t) async {
      Widget build(bool light) => _host(
        const IslandCodeBlock(code: _code),
        extensions: [
          IslandCodeBlockTheme(
            style: light ? _lightCode : const IslandCodeBlockStyle(),
          ),
        ],
      );
      await t.pumpWidget(build(true));
      await t.pumpAndSettle();
      final state = t.state(find.byType(EditableText));
      for (final light in [false, true, false, true]) {
        await t.pumpWidget(build(light));
        for (final ms in [0, 30, 70]) {
          await t.pump(Duration(milliseconds: ms));
          final dec = t
              .widgetList<DecoratedBox>(
                find.descendant(
                  of: find.byType(IslandCodeBlock),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .map((w) => w.decoration)
              .whereType<BoxDecoration>()
              .first;
          for (final leaf in _leaves(t)) readable(leaf.$2, dec.color!);
          expect(t.state(find.byType(EditableText)), same(state));
        }
      }
      await t.pumpAndSettle();
    },
  );

  testWidgets(
    'Card final content foreground supplies default focus, keeping explicit child ink',
    (t) async {
      final key = GlobalKey();
      final sem = t.ensureSemantics();
      for (final mode in Brightness.values) {
        await t.pumpWidget(
          _host(
            IslandCard(
              onTap: () {},
              style: const IslandCardStyle(
                backgroundColor: WidgetStatePropertyAll(_dark),
                foregroundColor: WidgetStatePropertyAll(Color(0xfff5f1dc)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Paired content'),
                  Text(
                    'Explicit child',
                    style: TextStyle(color: Colors.purple),
                  ),
                ],
              ),
            ),
            brightness: mode,
            boundary: key,
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.text('Paired content'));
        await t.pumpAndSettle();
        expect(
          t
              .getSemantics(find.byType(IslandCard))
              .getSemanticsData()
              .flagsCollection
              .isFocused,
          ui.Tristate.isTrue,
        );
        final rect = t.getRect(find.byType(IslandCard));
        final stroke = (await _sample(
          t,
          key,
          Offset(rect.center.dx, rect.top + 1),
          'p1-card-focus-${mode.name}',
          details: {
            'backing': 'ff243c33',
            'threshold': 3,
            'focus_observed': true,
          },
        )).$1;
        expect(stroke, const Color(0xfff5f1dc));
        readable(stroke, _dark, minimum: 3);
        expect(foreground(t, 'Paired content'), const Color(0xfff5f1dc));
        expect(foreground(t, 'Explicit child'), Colors.purple);
      }
      sem.dispose();
    },
  );

  testWidgets(
    'Card all paint roles use one final recipe, including alpha and explicit transparency',
    (t) async {
      final key = GlobalKey();
      const theme = IslandCardTheme(
        style: IslandCardStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.black),
          foregroundColor: WidgetStatePropertyAll(Colors.black),
          borderColor: WidgetStatePropertyAll(_ink),
          dividerColor: WidgetStatePropertyAll(_ink),
          largeDotColor: WidgetStatePropertyAll(Color(0x40000000)),
          smallDotColor: WidgetStatePropertyAll(Color(0x20000000)),
        ),
      );
      await t.pumpWidget(
        _host(
          IslandCard(
            pattern: IslandColorway.neutral,
            onTap: () {},
            style: const IslandCardStyle(
              backgroundColor: WidgetStatePropertyAll(Color(0x80ffffff)),
            ),
            header: const Text('Header'),
            footer: const Text('Footer'),
            child: const Text('Body'),
          ),
          backing: const Color(0xffe8f5e9),
          boundary: key,
          extensions: [theme],
        ),
      );
      await t.pumpAndSettle();
      final rect = t.getRect(find.byType(IslandCard));
      expect(foreground(t, 'Body'), Colors.black);
      final backing = (await _sample(
        t,
        key,
        Offset(rect.left + 8, rect.center.dy),
        'p1-card-alpha-backing',
      )).$1;
      final expected = Color.alphaBlend(
        const Color(0x80ffffff),
        const Color(0xffe8f5e9),
      );
      for (final pair in [
        (backing.r, expected.r),
        (backing.g, expected.g),
        (backing.b, expected.b),
      ])
        expect(pair.$1, closeTo(pair.$2, 1 / 255));
      final dots = (await _sample(
        t,
        key,
        Offset(rect.left + 14, rect.top + 14),
        'p1-card-alpha-dots',
      )).$1;
      expect(dots, isNot(backing));
      readable(Colors.black, dots);
      final divider = t.getRect(find.byType(Divider).first);
      final line = (await _sample(
        t,
        key,
        divider.center,
        'p1-card-divider',
      )).$1;
      expect(line, _ink);
      readable(line, backing, minimum: 3);
      await t.pumpWidget(
        _host(
          const IslandCard(
            pattern: IslandColorway.neutral,
            style: IslandCardStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              largeDotColor: WidgetStatePropertyAll(Colors.transparent),
              smallDotColor: WidgetStatePropertyAll(Colors.transparent),
            ),
            child: Text('Transparent'),
          ),
          backing: const Color(0xffe8f5e9),
          boundary: key,
          extensions: [theme],
        ),
      );
      await t.pumpAndSettle();
      final after = t.getRect(find.byType(IslandCard));
      expect(
        (await _sample(
          t,
          key,
          Offset(after.left + 14, after.top + 14),
          'p1-card-explicit-transparent',
        )).$1,
        const Color(0xffe8f5e9),
      );
    },
  );

  testWidgets(
    'Card explicit semantic context owns nested states while passive ink and opaque identity stay separate',
    (t) async {
      final childKey = GlobalKey<_OpaqueState>();
      final focus = FocusNode();
      final boundary = GlobalKey();
      var parent = 0, requests = 0;
      const other = IslandCodeBlockTheme(style: _lightCode);
      final tokens = IslandTokens.dark.copyWith(
        link: const Color(0xffaddbdf),
        linkHover: const Color(0xffc5e1c6),
        linkPressed: const Color(0xff92c294),
      );
      Widget build(Brightness host, IslandColorway pattern) => _host(
        IslandCard(
          onTap: () => parent++,
          hoverable: true,
          pattern: pattern,
          style: IslandCardStyle(
            backgroundColor: const WidgetStatePropertyAll(_dark),
            foregroundColor: const WidgetStatePropertyAll(Colors.yellow),
            largeDotColor: const WidgetStatePropertyAll(Colors.transparent),
            smallDotColor: const WidgetStatePropertyAll(Colors.transparent),
            surfaceTheme: IslandSurfaceTheme(
              brightness: Brightness.dark,
              tokens: tokens,
            ),
          ),
          child: _Opaque(
            key: childKey,
            focus: focus,
            onPressed: () => requests++,
          ),
        ),
        brightness: host,
        boundary: boundary,
        extensions: [other],
      );
      await t.pumpWidget(build(Brightness.light, IslandColorway.yellow));
      await t.pumpAndSettle();
      final state = childKey.currentState!;
      expect(foreground(t, 'Passive'), Colors.yellow);
      expect(foreground(t, 'Nested 0'), tokens.ink);
      final context = t.element(find.byType(_Opaque));
      expect(IslandTheme.of(context), same(tokens));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(Theme.of(context).extension<IslandCodeBlockTheme>(), same(other));
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      for (final row in [
        (Brightness.dark, IslandColorway.lime),
        (Brightness.light, IslandColorway.blue),
      ]) {
        await t.pumpWidget(build(row.$1, row.$2));
        await t.pump(const Duration(milliseconds: 20));
        await mouse.moveTo(t.getCenter(find.text('Nested ${state.count}')));
        await t.pump(const Duration(milliseconds: 40));
        final label = find.text('Nested ${state.count}');
        final box = t.getRect(label);
        final sample = (await _sample(
          t,
          boundary,
          Offset(box.center.dx, box.top - 4),
          'p1-card-nested-${row.$1.name}',
          details: {
            'foreground': foreground(
              t,
              'Nested ${state.count}',
            ).toARGB32().toRadixString(16),
            'host_theme': row.$1.name,
            'control_theme': 'dark',
          },
        )).$1;
        readable(foreground(t, 'Nested ${state.count}'), sample);
        await mouse.down(t.getCenter(label));
        await t.pump(const Duration(milliseconds: 35));
        final pressed = t.getRect(label);
        final pressBg = (await _sample(
          t,
          boundary,
          Offset(pressed.center.dx, pressed.top - 4),
          'p1-card-nested-pressed-${row.$1.name}',
        )).$1;
        readable(foreground(t, 'Nested ${state.count}'), pressBg);
        await mouse.up();
        await t.pump();
        expect(parent, 0);
        expect(childKey.currentState, same(state));
        expect(focus.hasPrimaryFocus, isTrue);
        expect(foreground(t, 'Explicit child'), Colors.purple);
      }
      expect(requests, 2);
      await mouse.removePointer();
      await t.pumpAndSettle();
      await t.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );

  testWidgets(
    'Button six-field contract keeps state fallback and canonical foreground; IconButton inherits theme',
    (t) async {
      final focus = FocusNode();
      const themed = IslandButtonTheme(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(_ink),
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          side: const WidgetStatePropertyAll(BorderSide(color: _ink, width: 3)),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
          iconColor: const WidgetStatePropertyAll(Colors.blue),
        ),
      );
      final style = ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.pressed) ? const Color(0xff714821) : null,
        ),
        shape: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered)
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              : null,
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 19, color: Colors.red),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(17)),
      );
      await t.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IslandButton(
                focusNode: focus,
                style: style,
                onPressed: () {},
                child: const Text('Contract'),
              ),
              IslandIconButton(
                glyph: IslandGlyph.search,
                label: 'Icon theme',
                onPressed: () {},
              ),
            ],
          ),
          extensions: [themed],
        ),
      );
      await t.pumpAndSettle();
      expect(foreground(t, 'Contract'), _ink);
      final rich = t.renderObject<RenderParagraph>(find.text('Contract'));
      expect(rich.text.style!.fontSize, 19);
      expect(rich.text.style!.fontWeight, FontWeight.w900);
      final padding = t
          .widgetList<Padding>(
            find.ancestor(
              of: find.text('Contract'),
              matching: find.byType(Padding),
            ),
          )
          .first;
      expect(padding.padding, const EdgeInsets.all(17));
      final shape = t
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.text('Contract'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((w) => w.decoration)
          .whereType<ShapeDecoration>()
          .first;
      expect(shape.shape, isA<StadiumBorder>());
      expect(
        (shape.shape as OutlinedBorder).side,
        const BorderSide(color: _ink, width: 3),
      );
      final glyph = find.descendant(
        of: find.byType(IslandIconButton),
        matching: find.byType(IslandIcon),
      );
      expect(IconTheme.of(t.element(glyph)).color, _ink);
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(find.text('Contract')));
      await t.pumpAndSettle();
      await mouse.down(t.getCenter(find.text('Contract')));
      await t.pump();
      expect(foreground(t, 'Contract'), const Color(0xff714821));
      await mouse.up();
      await mouse.removePointer();
      await t.pumpAndSettle();
      expect(foreground(t, 'Contract'), _ink);
      await t.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );
  testWidgets(
    'Card partial state roles fall back independently and focus survives hover press reversal',
    (t) async {
      final key = GlobalKey();
      const theme = IslandCardTheme(
        style: IslandCardStyle(
          backgroundColor: WidgetStatePropertyAll(Color(0xffe8f5e9)),
          foregroundColor: WidgetStatePropertyAll(_ink),
          focusColor: WidgetStatePropertyAll(Color(0xff0044aa)),
        ),
      );
      final local = IslandCardStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.hovered) ? const Color(0x80ffffff) : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.pressed) ? const Color(0xff714821) : null,
        ),
        focusColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.pressed) ? const Color(0xff6a1b9a) : null,
        ),
      );
      await t.pumpWidget(
        _host(
          IslandCard(
            style: local,
            hoverable: true,
            onTap: () {},
            child: const Text('State roles'),
          ),
          boundary: key,
          extensions: [theme],
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('State roles'));
      await t.pumpAndSettle();
      Color stroke() => t
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(IslandCard),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.border != null)
          .map((d) => (d.border! as Border).top.color)
          .first;
      Future<void> check(String state, Color bg, Color fg, Color ring) async {
        final rect = t.getRect(find.byType(IslandCard));
        final actual = (await _sample(
          t,
          key,
          Offset(rect.center.dx, rect.top + 6),
          'p1-card-priority-$state',
          details: {
            'foreground': foreground(
              t,
              'State roles',
            ).toARGB32().toRadixString(16),
            'focus_stroke': stroke().toARGB32().toRadixString(16),
          },
        )).$1;
        expect(actual, bg);
        expect(foreground(t, 'State roles'), fg);
        expect(stroke(), ring);
        readable(fg, actual);
        readable(ring, actual, minimum: 3);
      }

      await check(
        'normal',
        const Color(0xffe8f5e9),
        _ink,
        const Color(0xff0044aa),
      );
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(find.text('State roles')));
      await t.pump(const Duration(milliseconds: 30));
      await check('hover', Colors.white, _ink, const Color(0xff0044aa));
      await mouse.down(t.getCenter(find.text('State roles')));
      await t.pump();
      await check(
        'pressed',
        Colors.white,
        const Color(0xff714821),
        const Color(0xff6a1b9a),
      );
      await mouse.up();
      await mouse.moveTo(Offset.zero);
      await t.pump(const Duration(milliseconds: 30));
      await check(
        'reversed',
        const Color(0xffe8f5e9),
        _ink,
        const Color(0xff0044aa),
      );
      await mouse.removePointer();
      await t.pumpAndSettle();
    },
  );

  testWidgets(
    'Explicit caller foreground Paint retains Flutter precedence without becoming a semantic Color role',
    (t) async {
      final paint = Paint()..color = const Color(0xff6a1b9a);
      final text = TextStyle(foreground: paint, fontSize: 19);
      await t.pumpWidget(
        _host(
          IslandCodeBlock(
            code: 'plain',
            language: IslandCodeLanguage.plain,
            style: IslandCodeBlockStyle(
              backgroundColor: Colors.white,
              foregroundColor: _ink,
              textStyle: text,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(_leaves(t).single.$2, paint.color);
      await t.pumpWidget(
        _host(
          IslandCard(
            style: IslandCardStyle(
              foregroundColor: const WidgetStatePropertyAll(_ink),
              textStyle: WidgetStatePropertyAll(text),
            ),
            child: const Text('Card ink'),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(
        (t.renderObject<RenderParagraph>(find.text('Card ink')).text
                as TextSpan)
            .style!
            .foreground,
        same(paint),
      );
      await t.pumpWidget(
        _host(
          IslandButton(
            onPressed: () {},
            style: ButtonStyle(
              foregroundColor: const WidgetStatePropertyAll(_ink),
              textStyle: WidgetStatePropertyAll(text),
            ),
            child: const Text('Button ink'),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(
        (t.renderObject<RenderParagraph>(find.text('Button ink')).text
                as TextSpan)
            .style!
            .foreground,
        same(paint),
      );
    },
  );
}

class _Opaque extends StatefulWidget {
  const _Opaque({super.key, required this.focus, required this.onPressed});
  final FocusNode focus;
  final VoidCallback onPressed;
  @override
  State<_Opaque> createState() => _OpaqueState();
}

class _OpaqueState extends State<_Opaque> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Passive'),
      IslandButton(
        focusNode: widget.focus,
        variant: IslandButtonVariant.text,
        onPressed: () {
          setState(() => count++);
          widget.onPressed();
        },
        child: Text('Nested $count'),
      ),
      const Text('Explicit child', style: TextStyle(color: Colors.purple)),
    ],
  );
}
