import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate.dart';
import '../../tool/generate_docs.dart' as docs;

void main() {
  group('Public API Contract Tests (S02)', () {
    test('API06 navigation and data expose no duplicate instance visual inputs', () {
      for (final (slug, name) in [
        ('collapse', 'AnimalCollapse'),
        ('tabs', 'AnimalTabs'),
        ('carousel', 'AnimalCarousel'),
        ('table', 'AnimalTable'),
        ('pagination', 'AnimalPagination'),
      ]) {
        final component = _apiClass(
          'lib/src/components/$slug/$slug.dart',
          name,
        );
        final style = _apiClass(
          'lib/src/foundation/theme/components/${slug}_theme.dart',
          '${name}Style',
        );
        final inputs = _publicFields(component);
        for (final constructor
            in component.body.members.whereType<ConstructorDeclaration>()) {
          inputs.addAll(
            constructor.parameters.parameters
                .where((parameter) => parameter.isNamed)
                .map((parameter) => parameter.name!.lexeme)
                .where((name) => !name.startsWith('_')),
          );
        }
        expect(
          inputs.intersection(_publicFields(style)),
          isEmpty,
          reason:
              'API06_SINGLE_VISUAL_INPUT: $name must use its Style for visual inputs',
        );
      }
    });

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

ClassDeclaration _apiClass(String path, String name) =>
    parseString(content: File(path).readAsStringSync()).unit.declarations
        .whereType<ClassDeclaration>()
        .singleWhere(
          (declaration) => declaration.namePart.typeName.lexeme == name,
        );

Set<String> _publicFields(ClassDeclaration declaration) => {
  for (final field in declaration.body.members.whereType<FieldDeclaration>())
    for (final variable in field.fields.variables)
      if (!variable.name.lexeme.startsWith('_')) variable.name.lexeme,
};
