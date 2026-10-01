// ignore_for_file: avoid_print
import 'dart:io';

import 'src/dependency_graph.dart';

Future<String> generatePublicApi({
  bool checkOnly = false,
  String? packageRoot,
}) async {
  return generatePublicApiProjections(
    checkOnly: checkOnly,
    packageRoot: packageRoot,
  );
}

Future<void> main(List<String> args) async {
  final bool checkOnly = args.contains('--check');
  try {
    final String hash = await generatePublicApi(checkOnly: checkOnly);
    if (checkOnly) {
      print('[PASS] resolved public API projections are in sync ($hash)');
    } else {
      print('[GENERATED] resolved public API projections ($hash)');
    }
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
