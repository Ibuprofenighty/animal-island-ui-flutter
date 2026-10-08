import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate.dart';
import '../../tool/generate_docs.dart' as docs;

void main() {
  group('Public API Contract Tests (S02)', () {
    test('public API generator check passes without drift', () async {
      await expectLater(generatePublicApi(checkOnly: true), completes);
    }, timeout: const Timeout(Duration(minutes: 5)));

    test('generated docs and the skill manifest match the public API', () {
      // The skill manifest records the public API hash; the public CI checks it.
      expect(
        () => docs.DocGenerator().generateAll(checkOnly: true),
        returnsNormally,
      );
    });

    test('catalog/public_api.json contains entrypoint and sha256', () {
      final file = File('catalog/public_api.json');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(
        content.contains('"entrypoint": "lib/animal_island_ui.dart"'),
        isTrue,
      );
      expect(content.contains('"sha256":'), isTrue);
    });
  });
}
