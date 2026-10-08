import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _arb(String locale) =>
    jsonDecode(File('lib/l10n/gallery_$locale.arb').readAsStringSync())
        as Map<String, Object?>;

Set<String> _messages(Map<String, Object?> arb) =>
    arb.keys.where((String key) => !key.startsWith('@')).toSet();

void main() {
  test('the Gallery ARB pair declares the same messages and placeholders', () {
    final Map<String, Object?> en = _arb('en');
    final Map<String, Object?> zh = _arb('zh');
    expect(_messages(zh), _messages(en));
    for (final String key in _messages(en)) {
      final Object? enPlaceholders = (en['@$key'] as Map?)?['placeholders'];
      final Object? zhPlaceholders = (zh['@$key'] as Map?)?['placeholders'];
      if (zhPlaceholders != null) {
        expect(
          jsonEncode(zhPlaceholders),
          jsonEncode(enPlaceholders),
          reason: key,
        );
      }
      final String enText = en[key]! as String;
      final String zhText = zh[key]! as String;
      for (final RegExpMatch match in RegExp(r'\{(\w+)\}').allMatches(enText)) {
        expect(zhText, contains('{${match[1]}}'), reason: key);
      }
    }
  });
}
