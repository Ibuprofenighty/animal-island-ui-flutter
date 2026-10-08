import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

import 'src/flutter_arguments.dart';

const String _sdkLockPath = 'catalog/sdk.lock.json';
const String _licenseMarker = 'Attribution-NonCommercial 4.0 International';

// Writes the identity of one Gallery build. Declared versions come from
// catalog/sdk.lock.json and pubspec.yaml, the toolchain versions are observed
// from the Flutter SDK that runs the build, and the source is the checked-out
// commit. A build whose SDK differs from the lock fails instead of stamping a
// false identity. The same file is passed to `flutter build` with
// --dart-define-from-file and published next to the built Gallery.
Future<void> main(List<String> args) async {
  exitCode = await _runBuildInfo(args);
}

/// The Flutter and Dart versions reported by `flutter --version --machine`,
/// required to equal the `flutter` section of catalog/sdk.lock.json.
({String flutterVersion, String dartVersion}) lockedSdkVersions({
  required Map<String, dynamic> observed,
  required Map<String, dynamic> locked,
}) {
  final String flutterVersion = observed['frameworkVersion'] as String;
  final String dartVersion = (observed['dartSdkVersion'] as String)
      .split(' ')
      .first;
  if (flutterVersion != locked['frameworkVersion'] ||
      dartVersion != locked['dartSdkVersion']) {
    throw StateError(
      'running Flutter $flutterVersion / Dart $dartVersion is not the '
      'locked ${locked['frameworkVersion']} / ${locked['dartSdkVersion']} '
      'from $_sdkLockPath',
    );
  }
  return (flutterVersion: flutterVersion, dartVersion: dartVersion);
}

Future<int> _runBuildInfo(List<String> args) async {
  if (args.length != 2 || args.first != '--out') {
    stderr.writeln('usage: dart run tool/build_info.dart --out <file>');
    return 2;
  }
  try {
    final Map<String, dynamic> lock = jsonDecode(
      File(_sdkLockPath).readAsStringSync(),
    ) as Map<String, dynamic>;
    final Map<String, dynamic> lockedFlutter =
        lock['flutter'] as Map<String, dynamic>;
    final Map<String, dynamic> observed = jsonDecode(
      await _run(
        _flutter,
        scriptedArguments(_flutter, <String>['--version', '--machine']),
      ),
    ) as Map<String, dynamic>;
    final (:String flutterVersion, :String dartVersion) = lockedSdkVersions(
      observed: observed,
      locked: lockedFlutter,
    );
    if (!File('LICENSE').readAsStringSync().contains(_licenseMarker)) {
      throw StateError('LICENSE is not CC BY-NC 4.0');
    }
    final YamlMap pubspec = loadYaml(File('pubspec.yaml').readAsStringSync());
    final String status = await _run('git', <String>[
      'status',
      '--porcelain',
      '--untracked-files=no',
    ]);
    final Map<String, String> identity = <String, String>{
      'package': pubspec['name'] as String,
      'version': pubspec['version'] as String,
      'commit': (await _run('git', <String>['rev-parse', 'HEAD'])).trim(),
      'source_tree_clean': '${status.trim().isEmpty}',
      'flutter_version': flutterVersion,
      'dart_version': dartVersion,
      'public_api_sha256': sha256
          .convert(File('catalog/public_api.json').readAsBytesSync())
          .toString(),
      'license': 'CC BY-NC 4.0',
      'build_timestamp_utc': DateTime.now().toUtc().toIso8601String(),
    };
    File(args[1])
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(identity)}\n',
      );
    stdout.writeln('Build identity: ${identity['commit']} -> ${args[1]}');
    return 0;
  } on Object catch (error) {
    stderr.writeln('build-info failed closed: $error');
    return 1;
  }
}

final String _flutter = Platform.isWindows ? 'flutter.bat' : 'flutter';

Future<String> _run(String command, List<String> args) async {
  final ProcessResult result = await Process.run(
    command,
    args,
    runInShell: Platform.isWindows,
  );
  if (result.exitCode != 0) {
    throw StateError('$command ${args.join(' ')} failed: ${result.stderr}');
  }
  return result.stdout as String;
}
