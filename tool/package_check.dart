// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  print('=== Running Animal Island UI Package & Consumer Verification ===\n');

  final root = Directory.current.path;
  final errors = <String>[];

  // 1. Verify distribution files
  print('[1/4] Verifying package root distribution files...');
  final requiredFiles = [
    'pubspec.yaml',
    '.pubignore',
    'README.md',
    'CHANGELOG.md',
    'LICENSE',
    'NOTICE',
    'SECURITY.md',
    'lib/animal_island_ui.dart',
  ];

  for (final rel in requiredFiles) {
    final file = File('$root/$rel');
    if (!file.existsSync()) {
      errors.add('Missing required package distribution file: $rel');
    }
  }

  // 2. Verify canonical vector assets and lock
  print('[2/4] Verifying canonical icon assets and assets.lock.json...');
  final assetsLock = File('$root/catalog/assets.lock.json');
  if (!assetsLock.existsSync()) {
    errors.add('Missing catalog/assets.lock.json');
  }

  final iconSourceDir = Directory('$root/assets/icons/source');
  if (!iconSourceDir.existsSync() ||
      iconSourceDir.listSync().whereType<File>().length < 101) {
    errors.add(
      'assets/icons/source must contain all 101 canonical SVG icon assets',
    );
  }

  // 3. Verify clean external consumer compilation
  print('[3/4] Building and running clean external consumer sandbox...');
  final consumerDir = Directory('$root/scratch/consumer_sandbox');
  if (consumerDir.existsSync()) {
    consumerDir.deleteSync(recursive: true);
  }
  consumerDir.createSync(recursive: true);

  final Map<String, dynamic> constraints =
      (jsonDecode(File('$root/catalog/sdk.lock.json').readAsStringSync())
              as Map<String, dynamic>)['constraints']
          as Map<String, dynamic>;
  final consumerPubspec =
      '''
name: consumer_sandbox
description: Clean consumer verification application
publish_to: 'none'
version: 1.0.0

environment:
  sdk: "${constraints['pubspecSdk']}"
  flutter: "${constraints['pubspecFlutter']}"

dependencies:
  flutter:
    sdk: flutter
  animal_island_ui:
    path: ../../

dev_dependencies:
  flutter_test:
    sdk: flutter
''';

  File('${consumerDir.path}/pubspec.yaml').writeAsStringSync(consumerPubspec);

  final consumerLibDir = Directory('${consumerDir.path}/lib')
    ..createSync(recursive: true);
  final consumerMainDart = '''
import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() => runApp(const ConsumerApp());

class ConsumerApp extends StatelessWidget {
  const ConsumerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AnimalIslandTheme.light.toThemeData(),
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      localeResolutionCallback: (locale, _) => resolveAnimalLocale(locale),
      home: Scaffold(
        body: Center(
          child: AnimalCard(
            header: const Text('Consumer Verification'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimalTitle(child: Text('Island Public API')),
                const SizedBox(height: 12),
                AnimalButton(
                  tone: AnimalButtonTone.primary,
                  onPressed: () {},
                  child: const Text('Verified Button'),
                ),
                const SizedBox(height: 12),
                const AnimalIcon(data: AnimalIcons.leaf, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''';
  File('${consumerLibDir.path}/main.dart').writeAsStringSync(consumerMainDart);

  final consumerTestDir = Directory('${consumerDir.path}/test')
    ..createSync(recursive: true);
  final consumerTestDart = '''
import 'package:flutter_test/flutter_test.dart';
import 'package:consumer_sandbox/main.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets('Consumer sandbox mounts package via pure public API', (tester) async {
    await tester.pumpWidget(const ConsumerApp());
    await tester.pumpAndSettle();

    expect(find.text('Consumer Verification'), findsOneWidget);
    expect(find.text('Island Public API'), findsOneWidget);
    expect(find.text('Verified Button'), findsOneWidget);
    expect(find.byType(AnimalButton), findsOneWidget);
    expect(find.byType(AnimalCard), findsOneWidget);
  });
}
''';
  File('${consumerTestDir.path}/consumer_test.dart')
      .writeAsStringSync(consumerTestDart);

  // Run flutter pub get in consumer sandbox
  final pubGet = Process.runSync(
    'flutter',
    ['pub', 'get'],
    workingDirectory: consumerDir.path,
    runInShell: true,
  );
  if (pubGet.exitCode != 0) {
    errors.add('Consumer sandbox flutter pub get failed:\n${pubGet.stderr}');
  }

  // Run flutter analyze in consumer sandbox
  final analyze = Process.runSync(
    'flutter',
    ['analyze', '--fatal-infos'],
    workingDirectory: consumerDir.path,
    runInShell: true,
  );
  if (analyze.exitCode != 0) {
    errors.add(
      'Consumer sandbox flutter analyze failed:\n${analyze.stdout}\n${analyze.stderr}',
    );
  }

  // Run flutter test in consumer sandbox
  final testRun = Process.runSync(
    'flutter',
    ['test'],
    workingDirectory: consumerDir.path,
    runInShell: true,
  );
  if (testRun.exitCode != 0) {
    errors.add(
      'Consumer sandbox flutter test failed:\n${testRun.stdout}\n${testRun.stderr}',
    );
  }

  // 4. Verify the publication dry-run. The archive carries the bundled fonts,
  // so there is no fixed size ceiling; any dry-run warning or error fails.
  print('[4/4] Verifying publication package dry-run...');
  final pubDryRun = Process.runSync(
    'flutter',
    ['pub', 'publish', '--dry-run'],
    workingDirectory: root,
    runInShell: true,
  );
  if (pubDryRun.exitCode != 0) {
    errors.add(
      'flutter pub publish --dry-run exited ${pubDryRun.exitCode}:\n'
      '${pubDryRun.stdout}\n${pubDryRun.stderr}',
    );
  }

  if (errors.isEmpty) {
    print(
      'PASS: All package checks, consumer sandbox, and publication archive verification SUCCEEDED.',
    );
    exit(0);
  } else {
    stderr.writeln('\nFAIL: Package verification errors:');
    for (final err in errors) {
      stderr.writeln('  - $err');
    }
    exit(1);
  }
}
