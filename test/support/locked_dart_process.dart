import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const Duration _processCleanupGrace = Duration(seconds: 5);

typedef BoundedDartProcessResult = ({
  int exitCode,
  int? processId,
  String stderr,
  String stdout,
  bool timedOut,
  int? treeKillExitCode,
});

String lockedDartExecutable() {
  final String? flutterHome = Platform.environment['N04_FLUTTER_HOME'];
  if (flutterHome == null) {
    throw StateError('N04_FLUTTER_HOME must identify the locked Flutter SDK.');
  }
  final String executable = p.join(
    flutterHome,
    'bin',
    'cache',
    'dart-sdk',
    'bin',
    Platform.isWindows ? 'dart.exe' : 'dart',
  );
  if (!File(executable).existsSync()) {
    throw StateError('The locked Dart executable does not exist: $executable');
  }
  return executable;
}

Future<BoundedDartProcessResult> runBoundedDartProcess(
  String dartExecutable,
  List<String> arguments, {
  required Directory packageRoot,
  required Duration watchdogDuration,
}) async {
  final Process process = await Process.start(
    dartExecutable,
    arguments,
    workingDirectory: packageRoot.path,
    runInShell: false,
  );
  final Future<String> stdoutFuture = process.stdout
      .fold<List<int>>(<int>[], (List<int> bytes, List<int> chunk) {
        bytes.addAll(chunk);
        return bytes;
      })
      .then((List<int> bytes) => utf8.decode(bytes, allowMalformed: true));
  final Future<String> stderrFuture = process.stderr
      .fold<List<int>>(<int>[], (List<int> bytes, List<int> chunk) {
        bytes.addAll(chunk);
        return bytes;
      })
      .then((List<int> bytes) => utf8.decode(bytes, allowMalformed: true));

  bool timedOut = false;
  bool exitObserved = false;
  bool streamsDrained = false;
  int? treeKillExitCode;
  Object? treeKillError;
  Future<void>? treeKillFuture;

  void scheduleTreeKill() {
    treeKillFuture = _terminateProcessTree(process)
        .then<void>((int? code) {
          treeKillExitCode = code;
        })
        .catchError((Object error, StackTrace stackTrace) {
          treeKillError = error;
        });
  }

  final Timer watchdog = Timer(watchdogDuration, () {
    timedOut = true;
    scheduleTreeKill();
  });
  try {
    await process.stdin.close();
    final int exitCode = await process.exitCode.timeout(
      watchdogDuration + _processCleanupGrace,
      onTimeout: () {
        process.kill();
        throw TimeoutException('Dart process did not exit after timeout.');
      },
    );
    exitObserved = true;
    if (treeKillFuture != null) {
      await treeKillFuture!.timeout(_processCleanupGrace);
    }
    if (treeKillError != null) {
      throw StateError(
        'Unable to terminate the Dart process tree: $treeKillError',
      );
    }
    final List<String> output =
        await Future.wait<String>(<Future<String>>[stdoutFuture, stderrFuture])
            .timeout(
              _processCleanupGrace,
              onTimeout: () {
                process.kill();
                throw TimeoutException('Dart process output did not close.');
              },
            );
    streamsDrained = true;
    return (
      exitCode: exitCode,
      processId: process.pid,
      stdout: output[0],
      stderr: output[1],
      timedOut: timedOut,
      treeKillExitCode: treeKillExitCode,
    );
  } finally {
    watchdog.cancel();
    if (!exitObserved) {
      if (treeKillFuture == null) scheduleTreeKill();
      try {
        await treeKillFuture!.timeout(_processCleanupGrace);
      } on TimeoutException {
        process.kill();
      }
      if (treeKillError != null ||
          (Platform.isWindows && treeKillExitCode != 0)) {
        try {
          treeKillExitCode = await _terminateProcessTree(process)
              .timeout(_processCleanupGrace);
        } on TimeoutException {
          process.kill();
        }
      }
      try {
        await process.exitCode.timeout(_processCleanupGrace);
      } on TimeoutException {
        process.kill();
      }
    }
    if (!streamsDrained) {
      try {
        await Future.wait<void>(<Future<void>>[
          stdoutFuture.then<void>((String _) {}),
          stderrFuture.then<void>((String _) {}),
        ]).timeout(_processCleanupGrace);
      } on TimeoutException {
        process.kill();
      }
    }
  }
}

Future<int?> _terminateProcessTree(Process process) async {
  if (!Platform.isWindows) {
    process.kill();
    return null;
  }

  final String systemRoot = Platform.environment['SystemRoot'] ?? r'C:\Windows';
  final String taskkill = p.join(systemRoot, 'System32', 'taskkill.exe');
  final Process killer = await Process.start(taskkill, <String>[
    '/PID',
    process.pid.toString(),
    '/T',
    '/F',
  ], runInShell: false);
  final Future<void> stdoutFuture = killer.stdout.drain<void>();
  final Future<void> stderrFuture = killer.stderr.drain<void>();
  await killer.stdin.close();
  bool exitObserved = false;
  bool streamsDrained = false;
  try {
    final int exitCode = await killer.exitCode.timeout(
      _processCleanupGrace,
      onTimeout: () {
        killer.kill();
        throw TimeoutException('taskkill did not finish within its bound.');
      },
    );
    exitObserved = true;
    await Future.wait<void>(<Future<void>>[stdoutFuture, stderrFuture]).timeout(
      _processCleanupGrace,
      onTimeout: () {
        killer.kill();
        throw TimeoutException('taskkill output streams did not close.');
      },
    );
    streamsDrained = true;
    return exitCode;
  } finally {
    if (!exitObserved) {
      killer.kill();
      try {
        await killer.exitCode.timeout(_processCleanupGrace);
      } on TimeoutException {
        killer.kill();
      }
    }
    if (!streamsDrained) {
      try {
        await Future.wait<void>(<Future<void>>[stdoutFuture, stderrFuture])
            .timeout(_processCleanupGrace);
      } on TimeoutException {
        killer.kill();
      }
    }
  }
}
