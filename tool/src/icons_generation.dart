// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const int canonicalIconCount = 101;

/// Generates the one runtime icon catalog from the canonical SVG source tree.
String generateIconsSource({Directory? repositoryRoot}) {
  final Directory root = repositoryRoot ?? Directory.current;
  final Directory sourceDirectory = Directory(
    p.join(root.path, 'assets', 'icons', 'source'),
  );
  if (!sourceDirectory.existsSync()) {
    throw FileSystemException(
      'Canonical icon source directory is missing',
      sourceDirectory.path,
    );
  }

  final List<File> sourceFiles =
      sourceDirectory
          .listSync(followLinks: false)
          .whereType<File>()
          .where((File file) => p.extension(file.path).toLowerCase() == '.svg')
          .toList()
        ..sort(
          (File left, File right) => p
              .basenameWithoutExtension(left.path)
              .compareTo(p.basenameWithoutExtension(right.path)),
        );
  if (sourceFiles.length != canonicalIconCount) {
    throw FormatException(
      'Expected $canonicalIconCount canonical SVG sources; found ${sourceFiles.length}.',
    );
  }

  final List<_IconSource> icons = <_IconSource>[];
  final Set<String> names = <String>{};
  for (final File file in sourceFiles) {
    final String name = p.basenameWithoutExtension(file.path);
    if (!RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(name) || !names.add(name)) {
      throw FormatException('Invalid or duplicate canonical icon name: $name');
    }

    final String bytes = utf8.decode(
      file.readAsBytesSync(),
      allowMalformed: false,
    );
    final String svg = bytes.endsWith('\n')
        ? bytes.substring(0, bytes.length - 1)
        : bytes;
    icons.add(_IconSource(name, svg));
  }

  final StringBuffer output = StringBuffer()
    ..writeln('// GENERATED FILE - DO NOT EDIT MANUALLY')
    ..writeln(
      '// Generated from ${icons.length} canonical Animal Island UI vector icons in assets/icons/source/.',
    )
    ..writeln()
    ..writeln("import 'icon_data.dart';")
    ..writeln()
    ..writeln(
      '/// Canonical collection of all ${icons.length} Animal Island UI vector icons.',
    )
    ..writeln('abstract final class AnimalIcons {');

  for (final _IconSource icon in icons) {
    output
      ..writeln("  /// Cute island icon '${icon.name}'.")
      ..writeln('  static const AnimalIconData ${icon.name} = AnimalIconData(')
      ..writeln("    name: '${icon.name}',")
      ..writeln("    svg: '${_dartString(icon.svg)}',")
      ..writeln('  );')
      ..writeln();
  }

  output
    ..writeln(
      '  /// Map of all ${icons.length} canonical icons keyed by canonical identifier.',
    )
    ..writeln('  static const Map<String, AnimalIconData> values = {');
  for (final _IconSource icon in icons) {
    output.writeln("    '${icon.name}': ${icon.name},");
  }
  output
    ..writeln('  };')
    ..writeln()
    ..writeln('  /// List of all ${icons.length} canonical icons.')
    ..writeln('  static const List<AnimalIconData> all = [');
  for (final _IconSource icon in icons) {
    output.writeln('    ${icon.name},');
  }
  output
    ..writeln('  ];')
    ..writeln('}');
  return output.toString();
}

Future<void> main(List<String> args) async {
  if (args.length != 1 ||
      !const <String>{'--check', '--write'}.contains(args.single)) {
    stderr.writeln(
      'Usage: dart run tool/src/icons_generation.dart --check|--write',
    );
    exitCode = 2;
    return;
  }

  final Directory root = Directory.current;
  final File outputFile = File(
    p.join(root.path, 'lib', 'src', 'icons', 'icons.g.dart'),
  );
  final String generated = generateIconsSource(repositoryRoot: root);
  if (args.single == '--write') {
    await outputFile.writeAsString(generated, encoding: utf8, flush: true);
    stdout.writeln('Wrote ${p.relative(outputFile.path, from: root.path)}.');
    return;
  }
  if (!outputFile.existsSync() ||
      await outputFile.readAsString(encoding: utf8) != generated) {
    stderr.writeln(
      '${p.relative(outputFile.path, from: root.path)} is stale; run '
      '`dart run tool/src/icons_generation.dart --write`.',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln('Canonical SVG sources and icons.g.dart are in sync.');
}

String _dartString(String value) {
  final StringBuffer escaped = StringBuffer();
  for (final int rune in value.runes) {
    switch (rune) {
      case 0x5C:
        escaped.write(r'\\');
      case 0x27:
        escaped.write(r"\'");
      case 0x24:
        escaped.write(r'\$');
      case 0x0A:
        escaped.write(r'\n');
      case 0x0D:
        escaped.write(r'\r');
      case 0x09:
        escaped.write(r'\t');
      default:
        if (rune < 0x20 || rune == 0x7F) {
          escaped.write('\\u{${rune.toRadixString(16)}}');
        } else {
          escaped.writeCharCode(rune);
        }
    }
  }
  return escaped.toString();
}

final class _IconSource {
  const _IconSource(this.name, this.svg);

  final String name;
  final String svg;
}
