// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Projects catalog facts into component documentation.
///
/// Each generated page owns exactly one block between [blockStart] and
/// [blockEnd]. The block holds every fact derived from
/// `catalog/public_api.json`, `catalog/components.yaml` and
/// `catalog/assets.lock.json`; everything outside it is authored prose that
/// this generator never rewrites. The skill manifest is projected whole.
class DocGenerator {
  static const blockStart = '<!-- generated:api:start -->';
  static const blockEnd = '<!-- generated:api:end -->';
  static const _skillDir = 'skills/animal-island-ui-style-flutter';
  static const _import =
      "import 'package:animal_island_ui/animal_island_ui.dart';";

  final String root;
  late final Map<String, dynamic> publicApi;
  late final List<Map<String, dynamic>> components;

  DocGenerator({String? packageRoot})
    : root = p.normalize(packageRoot ?? Directory.current.path) {
    final apiFile = File(p.join(root, 'catalog', 'public_api.json'));
    if (!apiFile.existsSync()) {
      throw StateError(
        'catalog/public_api.json not found! Run tool/generate.dart first.',
      );
    }
    publicApi = jsonDecode(apiFile.readAsStringSync()) as Map<String, dynamic>;

    final compFile = File(p.join(root, 'catalog', 'components.yaml'));
    if (!compFile.existsSync()) {
      throw StateError('catalog/components.yaml not found!');
    }
    components = _parseComponentsYaml(compFile.readAsStringSync());
  }

  static List<Map<String, dynamic>> _parseComponentsYaml(String yaml) {
    final list = <Map<String, dynamic>>[];
    Map<String, dynamic>? current;

    for (final line in yaml.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- id:')) {
        if (current != null) list.add(current);
        current = {'id': trimmed.substring(5).trim()};
      } else if (current != null && trimmed.contains(':')) {
        final colonIdx = trimmed.indexOf(':');
        final key = trimmed.substring(0, colonIdx).trim();
        var val = trimmed.substring(colonIdx + 1).trim();
        if (val.startsWith('"') && val.endsWith('"') && val.length >= 2) {
          val = val.substring(1, val.length - 1);
        }
        current[key] = val;
      }
    }
    if (current != null) list.add(current);
    return list;
  }

  Map<String, dynamic> _findClass(String className) {
    final exports = publicApi['exports'] as Map<String, dynamic>? ?? {};
    for (final fileExports in exports.values) {
      final classes = fileExports['classes'] as Map<String, dynamic>? ?? {};
      if (classes.containsKey(className)) {
        return classes[className] as Map<String, dynamic>;
      }
    }
    throw StateError('$className is not exported in catalog/public_api.json');
  }

  List<String> _findEnumsForFile(String targetPath) {
    final exports = publicApi['exports'] as Map<String, dynamic>? ?? {};
    final fileExports = exports[targetPath] as Map<String, dynamic>?;
    if (fileExports != null) {
      final enums = fileExports['enums'] as Map<String, dynamic>? ?? {};
      return enums.keys.toList();
    }
    return [];
  }

  void generateAll({bool checkOnly = false}) {
    final blocks = <String, String>{};

    for (final comp in components) {
      final name = comp['name'] as String;
      final targetPath = comp['targetPath'] as String;
      final slug = _slugFromPath(targetPath);

      final classInfo = _findClass(name);
      final api = _ApiFacts(
        name: name,
        constructors: (classInfo['constructors'] as List<dynamic>)
            .cast<String>(),
        fields: (classInfo['fields'] as List<dynamic>).cast<String>(),
        enums: _findEnumsForFile(targetPath),
      );

      blocks[p.join(root, 'docs', 'en', 'components', '$slug.md')] =
          _buildEnComponentBlock(api);
      blocks[p.join(root, 'docs', 'zh', 'components', '$slug.md')] =
          _buildZhComponentBlock(api);
      blocks[p.join(root, _skillDir, 'references', 'components', '$slug.md')] =
          _buildSkillReferenceBlock(api);
    }

    final icon = components.singleWhere(
      (comp) => _slugFromPath(comp['targetPath'] as String) == 'icon',
    );
    final iconCount =
        (_readJson('catalog/assets.lock.json')['icons']
                as Map<String, dynamic>)['count']
            as int;
    blocks[p.join(root, 'docs', 'en', 'components', 'icons.md')] =
        _buildEnIconsBlock(count: iconCount);
    blocks[p.join(root, 'docs', 'zh', 'components', 'icons.md')] =
        _buildZhIconsBlock(count: iconCount);
    blocks[p.join(root, _skillDir, 'references', 'components', 'icons.md')] =
        _buildSkillIconsBlock(name: icon['name'] as String, count: iconCount);

    final manifestPath = p.join(root, _skillDir, 'manifest.json');
    final manifest = _buildSkillManifest();

    final drift = <String>[];
    final updates = <String, String>{};
    for (final entry in blocks.entries) {
      final relative = p.relative(entry.key, from: root);
      final file = File(entry.key);
      if (!file.existsSync()) {
        drift.add('Missing generated page: $relative');
        continue;
      }
      final existing = file.readAsStringSync();
      final start = existing.indexOf(blockStart);
      final end = existing.indexOf(blockEnd);
      if (start < 0 ||
          end < start ||
          existing.indexOf(blockStart, start + 1) >= 0 ||
          existing.indexOf(blockEnd, end + 1) >= 0) {
        drift.add('Expected exactly one ordered marker pair in: $relative');
        continue;
      }
      final contentStart = start + blockStart.length;
      if (existing.substring(contentStart, end) != entry.value) {
        drift.add('Generated block drift in: $relative');
        updates[entry.key] = existing.replaceRange(
          contentStart,
          end,
          entry.value,
        );
      }
    }
    final manifestFile = File(manifestPath);
    if (!manifestFile.existsSync() ||
        manifestFile.readAsStringSync() != manifest) {
      drift.add('Drift detected in: ${p.relative(manifestPath, from: root)}');
      updates[manifestPath] = manifest;
    }

    final malformed = drift.length - updates.length;
    if (checkOnly || malformed > 0) {
      drift.forEach(print);
      if (drift.isNotEmpty) {
        throw StateError(
          'Generated documentation is out of sync. Run "dart run tool/generate_docs.dart" to synchronize.',
        );
      }
      return;
    }
    for (final entry in updates.entries) {
      File(entry.key).writeAsStringSync(entry.value);
    }
  }

  Map<String, dynamic> _readJson(String relativePath) =>
      jsonDecode(File(p.join(root, relativePath)).readAsStringSync())
          as Map<String, dynamic>;

  String _buildSkillManifest() {
    final pubspec = loadYaml(
      File(p.join(root, 'pubspec.yaml')).readAsStringSync(),
    ) as YamlMap;
    final constraints =
        _readJson('catalog/sdk.lock.json')['constraints']
            as Map<String, dynamic>;
    final icons =
        _readJson('catalog/assets.lock.json')['icons'] as Map<String, dynamic>;
    final apiHash = sha256
        .convert(
          File(p.join(root, 'catalog', 'public_api.json')).readAsBytesSync(),
        )
        .toString();
    final manifest = <String, Object?>{
      'name': 'animal-island-ui-style-flutter',
      'package': pubspec['name'],
      'version': pubspec['version'],
      'sdk': constraints['pubspecFlutter'],
      'dartSdk': constraints['pubspecSdk'],
      'publicApiSha256': apiHash,
      'singleEntrypoint': '$_skillDir/SKILL.md',
      'setupGuide': '$_skillDir/references/setup.md',
      'componentsDirectory': '$_skillDir/references/components',
      'componentsCount': components.length,
      'iconsCount': icons['count'],
      'totalReferences': components.length + 1,
      'generator': 'tool/generate_docs.dart',
    };
    return '${const JsonEncoder.withIndent('  ').convert(manifest)}\n';
  }

  String _slugFromPath(String path) {
    final fileName = p.basenameWithoutExtension(path);
    return fileName;
  }

  static String _list(List<String> items, String empty) =>
      items.isEmpty ? empty : items.map((item) => '- `$item`').join('\n');

  static String _section(String heading, List<String> items) =>
      items.isEmpty ? '' : '\n\n## $heading\n${_list(items, '')}';

  /// Wraps projected content so that markers sit on their own lines.
  static String _block(String content) => '\n$content\n\n';

  String _buildEnComponentBlock(_ApiFacts api) {
    return _block(
      '''# ${api.name}

## Import
```dart
$_import
```

## Constructors
${_list(api.constructors, '- Default constructor available')}

## Properties
${_list(api.fields, '*No public properties.*')}${_section('Enums', api.enums)}''',
    );
  }

  String _buildZhComponentBlock(_ApiFacts api) {
    return _block('''# ${api.name}

## 导入
```dart
$_import
```

## 构造函数
${_list(api.constructors, '- 提供默认构造函数')}

## 属性
${_list(api.fields, '*无公开属性。*')}${_section('枚举', api.enums)}''');
  }

  String _buildSkillReferenceBlock(_ApiFacts api) {
    return _block('''# ${api.name} Reference

- **Class**: `${api.name}`
- **Import**: `$_import`

## Constructors
${_list(api.constructors, '- `${api.name}()`')}

## Properties
${_list(api.fields, '- None')}${_section('Enums', api.enums)}''');
  }

  String _buildEnIconsBlock({required int count}) {
    return _block('# $count Vector Icons');
  }

  String _buildZhIconsBlock({required int count}) {
    return _block('# $count 款矢量图标');
  }

  String _buildSkillIconsBlock({required String name, required int count}) {
    return _block('''# $count Vector Icons Reference

- **Class**: `$name`
- **Icon data**: `AnimalIcons.<icon_name>`
- **Import**: `$_import`''');
  }
}

/// Public API facts of one component, read from `catalog/public_api.json`.
class _ApiFacts {
  const _ApiFacts({
    required this.name,
    required this.constructors,
    required this.fields,
    required this.enums,
  });

  final String name;
  final List<String> constructors;
  final List<String> fields;
  final List<String> enums;
}

void main(List<String> args) {
  final checkOnly = args.contains('--check');
  print('=== Animal Island UI Documentation Generator ===');
  print('Running mode: ${checkOnly ? "CHECK ONLY" : "GENERATE"}');

  try {
    final generator = DocGenerator();
    generator.generateAll(checkOnly: checkOnly);
    if (checkOnly) {
      print(
        '[PASS] Generated API blocks and the skill manifest match the catalog; authored prose, API resolution and snippet compilation are not checked.',
      );
    } else {
      print(
        '[GENERATED] Synchronized generated API blocks (EN, ZH, Skill References) and the skill manifest.',
      );
    }
  } catch (e) {
    stderr.writeln('[ERROR] $e');
    exit(1);
  }
}
