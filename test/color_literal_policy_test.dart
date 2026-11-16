import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Colour owners: the only source files that may hold raw colour values.
/// Everything else in lib/ and example/lib references their names.
const _owners = {
  // Tier 1 primitive palette.
  'lib/src/foundation/palette.dart',
  // Indexed per-colorway tables (accent/soft/ink/onAccent, Tag/Badge/paper
  // and Title palettes) behind the public IslandColorway/IslandPalette.
  'lib/src/foundation/colorway.dart',
  // Generated from the pinned Background CSS by
  // tool/extract_background_patterns.py; regenerating must not need edits.
  'lib/src/foundation/background_type.dart',
  'lib/src/foundation/sprinkle_data.dart',
  // The one Gallery demonstration palette.
  'example/lib/shared/palette.dart',
};

/// Raw colour constructions: a bare `Color(...)`, `Color.from*`, an ARGB hex
/// integer, or a Material `Colors.*` swatch other than `transparent`.
final _patterns = <(String, RegExp)>[
  ('Color constructor', RegExp(r'(?<![\w$.])Color\s*\(')),
  ('Color.from constructor', RegExp(r'(?<![\w$.])Color\s*\.\s*from\w*\s*\(')),
  ('ARGB hex literal', RegExp(r'\b0[xX][0-9a-fA-F]{8}\b')),
  (
    'Material Colors swatch',
    RegExp(r'(?<![\w$.])Colors\s*\.\s*(?!transparent\b)\w+'),
  ),
];

/// Dart source with comments and string literal contents blanked (newlines
/// kept), so code samples shown as text and documentation are not scanned.
String codeOnly(String source) {
  final out = StringBuffer();
  // Each frame is a string (quote, raw, triple) or an interpolation depth.
  final stack = <Object>[];
  var i = 0;
  bool at(String token) => source.startsWith(token, i);
  void blank(int count) {
    for (var k = 0; k < count && i < source.length; k++, i++) {
      out.write(source[i] == '\n' ? '\n' : ' ');
    }
  }

  while (i < source.length) {
    final top = stack.isEmpty ? null : stack.last;
    final c = source[i];
    if (top is _Str) {
      if (!top.raw && c == r'\') {
        blank(2);
      } else if (at(top.close)) {
        stack.removeLast();
        blank(top.close.length);
      } else if (!top.raw && at(r'${')) {
        stack.add(_Interp());
        blank(2);
      } else if (!top.triple && c == '\n') {
        stack.removeLast();
        out.write('\n');
        i++;
      } else {
        blank(1);
      }
      continue;
    }
    if (at('//')) {
      while (i < source.length && source[i] != '\n') {
        blank(1);
      }
      continue;
    }
    if (at('/*')) {
      var depth = 0;
      do {
        if (at('/*')) {
          depth++;
          blank(2);
        } else if (at('*/')) {
          depth--;
          blank(2);
        } else {
          blank(1);
        }
      } while (depth > 0 && i < source.length);
      continue;
    }
    if (c == "'" || c == '"') {
      final raw =
          i > 0 &&
          source[i - 1] == 'r' &&
          (i < 2 || !RegExp(r'[\w$]').hasMatch(source[i - 2]));
      final triple = at(c * 3);
      final close = triple ? c * 3 : c;
      stack.add(_Str(close, raw: raw, triple: triple));
      blank(close.length);
      continue;
    }
    if (top is _Interp) {
      if (c == '{') top.depth++;
      if (c == '}' && --top.depth == 0) {
        stack.removeLast();
        blank(1);
        continue;
      }
    }
    out.write(c);
    i++;
  }
  return out.toString();
}

class _Str {
  _Str(this.close, {required this.raw, required this.triple});
  final String close;
  final bool raw, triple;
}

class _Interp {
  int depth = 1;
}

List<String> violations(String path, String source) {
  final code = codeOnly(source);
  final found = <String>[];
  for (final (name, pattern) in _patterns) {
    for (final match in pattern.allMatches(code)) {
      final line = '\n'.allMatches(code.substring(0, match.start)).length + 1;
      found.add('$path:$line $name `${match[0]}`');
    }
  }
  return found;
}

void main() {
  test('scanner ignores comments and strings, finds raw colours', () {
    expect(
      violations('sample.dart', r'''
// Color(0xff000000) in a comment
/* Colors.white /* nested */ Color.fromRGBO(0, 0, 0, 1) */
final a = 'Color(0xff000000) ${'Colors.red'} $b';
final b = r"Colors.white \";
final c = """
Color(0xffffffff)
""";
final ok = [Colors.transparent, Color.lerp(x, y, .5), IslandColorway.red];
'''),
      isEmpty,
    );
    expect(
      violations('sample.dart', r'''
final a = const Color(0x1a725d42);
final b = Color.fromRGBO(1, 2, 3, .5);
final c = Color(value);
final d = 0xffece7f8;
final e = Colors.white;
final f = '${Color(0xff000000)}';
''').length,
      8,
    );
  });

  test('colours are named tokens outside their owners', () {
    final found = <String>[];
    for (final root in ['lib', 'example/lib']) {
      for (final file in Directory(root).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        final path = file.path.replaceAll(r'\', '/');
        if (_owners.contains(path)) continue;
        found.addAll(violations(path, file.readAsStringSync()));
      }
    }
    expect(
      found,
      isEmpty,
      reason:
          'Name the colour in lib/src/foundation (palette.dart, a recipe in '
          'recipes/) or, for Gallery demo colours, example/lib/shared/'
          'palette.dart.',
    );
    for (final owner in _owners) {
      expect(File(owner).existsSync(), isTrue, reason: 'stale owner $owner');
    }
  });
}
