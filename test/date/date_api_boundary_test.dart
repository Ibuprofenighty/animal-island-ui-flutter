import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../support/locked_dart_process.dart';

void main() {
  test('N16 external consumer resolves the new API and rejects every removed DatePicker entry', () async {
    final Directory packageRoot = _findPackageRoot();
    final File packageConfig = File(
      p.join(packageRoot.path, '.dart_tool', 'package_config.json'),
    );
    _expectPackageConfigTargetsRoot(packageConfig, packageRoot);

    final String dartExecutable = lockedDartExecutable();
    expect(File(dartExecutable).existsSync(), isTrue);

    final Directory scratch = Directory(p.join(packageRoot.path, 'scratch'))
      ..createSync(recursive: true);
    final Directory consumer = scratch.createTempSync('n16-date-api-');
    try {
      File(p.join(consumer.path, 'analysis_options.yaml'))
          .writeAsStringSync('analyzer:\n  exclude: []\n');
      final File currentApi = File(p.join(consumer.path, 'current_api.dart'))
        ..writeAsStringSync('''
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  final AnimalDate date = AnimalDate(2026, 9, 15);
  AnimalDatePicker(
    selection: AnimalDateSelection.date(date),
    onChanged: (AnimalDateSelection? proposal) {},
  );
  AnimalDatePicker(
    mode: AnimalDatePickerMode.range,
    selection: AnimalDateSelection.range(start: date),
    onChanged: (AnimalDateSelection? proposal) {},
    clock: const SystemClock(),
  );
  AnimalDatePicker.popover(
    mode: AnimalDatePickerMode.month,
    selection: AnimalDateSelection.date(AnimalDate(2026, 9, 1)),
    onChanged: (AnimalDateSelection? proposal) {},
  );
}
''');

      final Map<String, String> removedConsumers = <String, String>{
        'value.dart': '''
import 'package:animal_island_ui/animal_island_ui.dart';
void main() => AnimalDatePicker(value: AnimalDate(2026, 9, 15));
''',
        'range_value.dart': '''
import 'package:animal_island_ui/animal_island_ui.dart';
void main() => AnimalDatePicker(
  rangeValue: AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
);
''',
        'range_mode_parameter.dart': '''
import 'package:animal_island_ui/animal_island_ui.dart';
void main() => AnimalDatePicker(range: true);
''',
        'picker_parameter.dart': '''
import 'package:animal_island_ui/animal_island_ui.dart';
void main() => AnimalDatePicker(picker: AnimalDatePickerMode.month);
''',
        'range_callback.dart': '''
import 'package:animal_island_ui/animal_island_ui.dart';
void main() => AnimalDatePicker(onRangeChanged: (proposal) {});
''',
        'range_type.dart': '''
import 'package:animal_island_ui/animal_island_ui.dart';
void acceptLegacyRange(AnimalDateRange value) {}
''',
      };
      final Map<String, File> removedFiles = <String, File>{
        for (final MapEntry<String, String> entry in removedConsumers.entries)
          entry.key: File(p.join(consumer.path, entry.key))
            ..writeAsStringSync(entry.value),
      };

      final AnalysisContextCollection contexts = AnalysisContextCollection(
        includedPaths: <String>[consumer.path],
        sdkPath: p.dirname(p.dirname(dartExecutable)),
      );
      try {
        final ResolvedUnitResult valid = await _resolve(contexts, currentApi);
        expect(
          valid.diagnostics,
          isEmpty,
          reason: 'The public date, range, month and clock API must resolve.',
        );

        for (final MapEntry<String, File> entry in removedFiles.entries) {
          final ResolvedUnitResult invalid = await _resolve(
            contexts,
            entry.value,
          );
          final List<String> codes = invalid.diagnostics
              .map((diagnostic) => diagnostic.diagnosticCode.lowerCaseName)
              .toList();
          expect(
            codes,
            <String>[
              entry.key == 'range_type.dart'
                  ? 'undefined_class'
                  : 'undefined_named_parameter',
            ],
            reason:
                'The root-resolved external consumer ${entry.key} must fail '
                'for the removed API, with diagnostics $codes.',
          );
        }
      } finally {
        await contexts.dispose();
      }
    } finally {
      consumer.deleteSync(recursive: true);
      expect(consumer.existsSync(), isFalse);
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<ResolvedUnitResult> _resolve(
  AnalysisContextCollection contexts,
  File source,
) async {
  final result = await contexts
      .contextFor(source.path)
      .currentSession
      .getResolvedUnit(source.path);
  expect(
    result,
    isA<ResolvedUnitResult>(),
    reason:
        'The analyzer must resolve the real external source ${source.path}.',
  );
  return result as ResolvedUnitResult;
}

Directory _findPackageRoot() {
  Directory current = Directory.current.absolute;
  while (true) {
    final File pubspec = File(p.join(current.path, 'pubspec.yaml'));
    final File packageConfig = File(
      p.join(current.path, '.dart_tool', 'package_config.json'),
    );
    if (pubspec.existsSync() && packageConfig.existsSync()) {
      final String contents = pubspec.readAsStringSync();
      if (RegExp(
        r'^name:\s*animal_island_ui\s*$',
        multiLine: true,
      ).hasMatch(contents)) {
        return current;
      }
    }
    final Directory parent = current.parent;
    if (parent.path == current.path) {
      throw StateError('Run this oracle from the animal_island_ui package.');
    }
    current = parent;
  }
}

void _expectPackageConfigTargetsRoot(File packageConfig, Directory root) {
  final Map<String, Object?> config =
      jsonDecode(packageConfig.readAsStringSync()) as Map<String, Object?>;
  final List<Map<String, Object?>> packages = (config['packages']! as List)
      .cast<Map<String, Object?>>();
  final Map<String, Object?> package = packages.singleWhere(
    (Map<String, Object?> entry) => entry['name'] == 'animal_island_ui',
  );
  final Uri configuredRoot = packageConfig.uri.resolve(
    package['rootUri']! as String,
  );
  expect(
    p.normalize(p.fromUri(configuredRoot)),
    p.normalize(root.resolveSymbolicLinksSync()),
    reason: 'The date API analyzer must resolve the real package config.',
  );
}
